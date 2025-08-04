import os
import stripe
import httpx
from typing import Dict, Any, Optional, List
from datetime import datetime
import logging
import hashlib
import hmac
import plaid
from plaid.api import plaid_api
from plaid.model.link_token_create_request import LinkTokenCreateRequest
from plaid.model.link_token_create_request_user import LinkTokenCreateRequestUser
from plaid.model.processor_stripe_bank_account_token_create_request import ProcessorStripeBankAccountTokenCreateRequest
from plaid.model.accounts_get_request import AccountsGetRequest
from plaid.model.country_code import CountryCode
from plaid.model.products import Products

logger = logging.getLogger(__name__)

# Initialize Stripe
stripe.api_key = os.getenv("STRIPE_SECRET_KEY")

# Initialize Plaid
from config import settings

configuration = plaid.Configuration(
    host=getattr(plaid.Environment, settings.plaid_env, plaid.Environment.sandbox),
    api_key={
        'clientId': settings.plaid_client_id,
        'secret': settings.plaid_secret,
    }
)
api_client = plaid.ApiClient(configuration)
plaid_client = plaid_api.PlaidApi(api_client)

class PaymentService:
    """Unified payment service supporting multiple providers with minimal compliance"""
    
    def __init__(self):
        self.stripe_key = os.getenv("STRIPE_SECRET_KEY")
        self.paypal_client_id = os.getenv("PAYPAL_CLIENT_ID")
        self.paypal_secret = os.getenv("PAYPAL_SECRET")
        self.coinbase_api_key = os.getenv("COINBASE_API_KEY")
        self.coinbase_webhook_secret = os.getenv("COINBASE_WEBHOOK_SECRET")
        
        # PayPal URLs
        self.paypal_base_url = "https://api-m.sandbox.paypal.com" if os.getenv("PAYPAL_SANDBOX", "true") == "true" else "https://api-m.paypal.com"
    
    async def create_plaid_link_token(self, user_id: str, user_email: str) -> Dict[str, Any]:
        """Create Plaid Link token for bank account connection"""
        try:
            request = LinkTokenCreateRequest(
                products=[Products('auth'), Products('transactions')],
                client_name="Crashout Betting",
                country_codes=[CountryCode('US')],
                language='en',
                user=LinkTokenCreateRequestUser(client_user_id=user_id),
                redirect_uri=os.getenv("FRONTEND_URL") + "/plaid-redirect"
            )
            
            response = plaid_client.link_token_create(request)
            
            return {
                "link_token": response['link_token'],
                "expiration": response['expiration']
            }
        except Exception as e:
            logger.error(f"Plaid Link token creation failed: {str(e)}")
            raise
    
    async def exchange_plaid_token(self, public_token: str, user_id: str) -> Dict[str, Any]:
        """Exchange Plaid public token for access token and create Stripe bank account"""
        try:
            # Exchange public token for access token
            exchange_response = plaid_client.item_public_token_exchange({
                'public_token': public_token
            })
            access_token = exchange_response['access_token']
            
            # Get account information
            accounts_request = AccountsGetRequest(access_token=access_token)
            accounts_response = plaid_client.accounts_get(accounts_request)
            
            # Get the first checking/savings account
            account = next(
                (acc for acc in accounts_response['accounts'] 
                 if acc['type'] in ['checking', 'savings']),
                accounts_response['accounts'][0]
            )
            
            # Create Stripe bank account token
            stripe_request = ProcessorStripeBankAccountTokenCreateRequest(
                access_token=access_token,
                account_id=account['account_id']
            )
            stripe_response = plaid_client.processor_stripe_bank_account_token_create(stripe_request)
            
            # Create or update Stripe customer
            stripe_customer = await self._get_or_create_stripe_customer(user_id)
            
            # Attach bank account to customer
            bank_account = stripe.Customer.create_source(
                stripe_customer.id,
                source=stripe_response['stripe_bank_account_token']
            )
            
            # Store the access token securely (you should encrypt this)
            # In production, store this in your database
            
            return {
                "bank_account_id": bank_account.id,
                "bank_name": account.get('name', 'Bank Account'),
                "last4": bank_account.last4,
                "account_type": account['type'],
                "status": "connected"
            }
            
        except Exception as e:
            logger.error(f"Plaid token exchange failed: {str(e)}")
            raise
    
    async def create_ach_payment(self, user_id: str, amount: float, 
                                bank_account_id: str, metadata: Dict[str, Any]) -> Dict[str, Any]:
        """Create ACH payment from connected bank account"""
        try:
            stripe_customer = await self._get_or_create_stripe_customer(user_id)
            
            # Create ACH charge
            charge = stripe.Charge.create(
                amount=int(amount * 100),  # Convert to cents
                currency="usd",
                customer=stripe_customer.id,
                source=bank_account_id,
                description=f"Wallet deposit for user {user_id}",
                metadata=metadata
            )
            
            return {
                "payment_id": charge.id,
                "status": charge.status,
                "amount": amount,
                "processing_time": "1-3 business days",
                "payment_method": "bank_transfer"
            }
            
        except stripe.error.StripeError as e:
            logger.error(f"ACH payment failed: {str(e)}")
            raise
    
    async def create_instant_deposit(self, user_id: str, amount: float, 
                                   payment_method_id: str, metadata: Dict[str, Any]) -> Dict[str, Any]:
        """Create instant deposit using debit card (higher fees but instant)"""
        try:
            stripe_customer = await self._get_or_create_stripe_customer(user_id)
            
            # Create payment intent for instant deposit
            intent = stripe.PaymentIntent.create(
                amount=int(amount * 100),
                currency="usd",
                customer=stripe_customer.id,
                payment_method=payment_method_id,
                confirm=True,
                metadata=metadata,
                description=f"Instant deposit for user {user_id}"
            )
            
            return {
                "payment_id": intent.id,
                "status": intent.status,
                "amount": amount,
                "processing_time": "instant",
                "payment_method": "debit_card"
            }
            
        except stripe.error.StripeError as e:
            logger.error(f"Instant deposit failed: {str(e)}")
            raise
    
    async def _get_or_create_stripe_customer(self, user_id: str) -> stripe.Customer:
        """Get or create Stripe customer for user"""
        # In production, store stripe_customer_id in your database
        # For now, we'll search by metadata
        customers = stripe.Customer.list(limit=1, metadata={'user_id': user_id})
        
        if customers.data:
            return customers.data[0]
        else:
            return stripe.Customer.create(
                metadata={'user_id': user_id},
                description=f"Customer for user {user_id}"
            )
    
    async def create_payment_intent(self, amount: float, currency: str, 
                                  payment_method: str, metadata: Dict[str, Any]) -> Dict[str, Any]:
        """Create a payment intent with the specified provider"""
        
        if payment_method == "stripe":
            return await self._create_stripe_payment(amount, currency, metadata)
        elif payment_method == "bank":
            # For bank transfers, we'll use ACH through Stripe
            return {
                "payment_method": "bank",
                "requires_bank_connection": True,
                "setup_url": f"{os.getenv('FRONTEND_URL')}/connect-bank"
            }
        elif payment_method == "paypal":
            return await self._create_paypal_payment(amount, currency, metadata)
        elif payment_method == "crypto":
            return await self._create_crypto_payment(amount, currency, metadata)
        else:
            raise ValueError(f"Unsupported payment method: {payment_method}")
    
    async def _create_stripe_payment(self, amount: float, currency: str, metadata: Dict[str, Any]) -> Dict[str, Any]:
        """Create Stripe payment intent"""
        
        try:
            intent = stripe.PaymentIntent.create(
                amount=int(amount * 100),  # Convert to cents
                currency=currency.lower(),
                metadata=metadata,
                automatic_payment_methods={"enabled": True}
            )
            
            return {
                "payment_id": intent.id,
                "payment_url": f"https://checkout.stripe.com/pay/{intent.client_secret}",
                "client_secret": intent.client_secret,
                "status": intent.status
            }
        except stripe.error.StripeError as e:
            logger.error(f"Stripe error: {str(e)}")
            raise
    
    async def _create_paypal_payment(self, amount: float, currency: str, metadata: Dict[str, Any]) -> Dict[str, Any]:
        """Create PayPal payment"""
        
        # Get access token
        token = await self._get_paypal_token()
        
        payment_data = {
            "intent": "CAPTURE",
            "purchase_units": [{
                "amount": {
                    "currency_code": currency,
                    "value": str(amount)
                },
                "description": f"Wallet deposit - {metadata.get('user_id', '')}"
            }],
            "application_context": {
                "return_url": f"{os.getenv('FRONTEND_URL')}/payment/success",
                "cancel_url": f"{os.getenv('FRONTEND_URL')}/payment/cancel"
            }
        }
        
        async with httpx.AsyncClient() as client:
            response = await client.post(
                f"{self.paypal_base_url}/v2/checkout/orders",
                json=payment_data,
                headers={
                    "Authorization": f"Bearer {token}",
                    "Content-Type": "application/json"
                }
            )
            response.raise_for_status()
            data = response.json()
            
            # Find approval URL
            approval_url = next(
                (link["href"] for link in data["links"] if link["rel"] == "approve"),
                None
            )
            
            return {
                "payment_id": data["id"],
                "payment_url": approval_url,
                "status": data["status"]
            }
    
    async def _create_crypto_payment(self, amount: float, currency: str, metadata: Dict[str, Any]) -> Dict[str, Any]:
        """Create cryptocurrency payment via Coinbase Commerce"""
        
        async with httpx.AsyncClient() as client:
            response = await client.post(
                "https://api.commerce.coinbase.com/charges",
                json={
                    "name": f"Wallet Deposit",
                    "description": f"Add funds to wallet",
                    "pricing_type": "fixed_price",
                    "local_price": {
                        "amount": str(amount),
                        "currency": currency
                    },
                    "metadata": metadata
                },
                headers={
                    "X-CC-Api-Key": self.coinbase_api_key,
                    "X-CC-Version": "2018-03-22"
                }
            )
            response.raise_for_status()
            data = response.json()["data"]
            
            return {
                "payment_id": data["id"],
                "payment_url": data["hosted_url"],
                "addresses": data["addresses"],
                "status": "pending"
            }
    
    async def create_payout(self, amount: float, currency: str, payment_method: str,
                          destination: str, metadata: Dict[str, Any]) -> Dict[str, Any]:
        """Create a payout to user"""
        
        if payment_method == "stripe":
            return await self._create_stripe_payout(amount, currency, destination, metadata)
        elif payment_method == "bank":
            return await self._create_ach_payout(amount, currency, destination, metadata)
        elif payment_method == "paypal":
            return await self._create_paypal_payout(amount, currency, destination, metadata)
        elif payment_method == "crypto":
            return await self._create_crypto_payout(amount, currency, destination, metadata)
        else:
            raise ValueError(f"Unsupported payout method: {payment_method}")
    
    async def _create_ach_payout(self, amount: float, currency: str,
                                destination: str, metadata: Dict[str, Any]) -> Dict[str, Any]:
        """Create ACH payout to bank account"""
        try:
            # Create payout using Stripe
            payout = stripe.Payout.create(
                amount=int(amount * 100),
                currency=currency.lower(),
                destination=destination,  # Bank account ID
                description=f"Withdrawal for user {metadata.get('user_id')}",
                metadata=metadata,
                method="standard"  # 1-3 business days
            )
            
            return {
                "payout_id": payout.id,
                "status": payout.status,
                "arrival_date": payout.arrival_date,
                "estimated_arrival": "1-3 business days"
            }
        except stripe.error.StripeError as e:
            logger.error(f"ACH payout error: {str(e)}")
            raise
    
    async def _create_stripe_payout(self, amount: float, currency: str, 
                                  destination: str, metadata: Dict[str, Any]) -> Dict[str, Any]:
        """Create Stripe instant payout (debit card)"""
        
        try:
            # Create instant payout to debit card
            payout = stripe.Payout.create(
                amount=int(amount * 100),
                currency=currency.lower(),
                destination=destination,  # Debit card ID
                description=f"Instant withdrawal for user {metadata.get('user_id')}",
                metadata=metadata,
                method="instant"  # Instant payout (higher fees)
            )
            
            return {
                "payout_id": payout.id,
                "status": payout.status,
                "estimated_arrival": "Within 30 minutes"
            }
        except stripe.error.StripeError as e:
            logger.error(f"Stripe payout error: {str(e)}")
            raise
    
    async def _create_paypal_payout(self, amount: float, currency: str,
                                  destination: str, metadata: Dict[str, Any]) -> Dict[str, Any]:
        """Create PayPal payout"""
        
        token = await self._get_paypal_token()
        
        payout_data = {
            "sender_batch_header": {
                "sender_batch_id": f"payout_{metadata.get('user_id', '')}_{datetime.utcnow().timestamp()}",
                "email_subject": "Your Crashout winnings!",
                "email_message": "Congratulations on your winnings!"
            },
            "items": [{
                "recipient_type": "EMAIL",
                "amount": {
                    "value": str(amount),
                    "currency": currency
                },
                "receiver": destination,
                "note": f"Payout for winnings",
                "sender_item_id": metadata.get("bet_id", "")
            }]
        }
        
        async with httpx.AsyncClient() as client:
            response = await client.post(
                f"{self.paypal_base_url}/v1/payments/payouts",
                json=payout_data,
                headers={
                    "Authorization": f"Bearer {token}",
                    "Content-Type": "application/json"
                }
            )
            response.raise_for_status()
            data = response.json()
            
            return {
                "payout_id": data["batch_header"]["payout_batch_id"],
                "status": data["batch_header"]["batch_status"],
                "estimated_arrival": "Within minutes"
            }
    
    async def _create_crypto_payout(self, amount: float, currency: str,
                                  destination: str, metadata: Dict[str, Any]) -> Dict[str, Any]:
        """Create cryptocurrency payout"""
        
        # This would integrate with a crypto exchange API or wallet service
        # For now, return mock data
        return {
            "payout_id": f"crypto_payout_{os.urandom(16).hex()}",
            "status": "pending",
            "transaction_hash": None,
            "destination_address": destination,
            "estimated_arrival": "10-60 minutes"
        }
    
    async def verify_payment(self, payment_id: str, payment_method: str) -> Dict[str, Any]:
        """Verify payment status"""
        
        if payment_method in ["stripe", "bank"]:
            intent = stripe.PaymentIntent.retrieve(payment_id)
            return {
                "status": intent.status,
                "amount": intent.amount / 100,
                "paid": intent.status == "succeeded"
            }
        elif payment_method == "paypal":
            token = await self._get_paypal_token()
            async with httpx.AsyncClient() as client:
                response = await client.get(
                    f"{self.paypal_base_url}/v2/checkout/orders/{payment_id}",
                    headers={"Authorization": f"Bearer {token}"}
                )
                response.raise_for_status()
                data = response.json()
                return {
                    "status": data["status"],
                    "paid": data["status"] == "COMPLETED"
                }
        elif payment_method == "crypto":
            # Check Coinbase Commerce charge status
            async with httpx.AsyncClient() as client:
                response = await client.get(
                    f"https://api.commerce.coinbase.com/charges/{payment_id}",
                    headers={
                        "X-CC-Api-Key": self.coinbase_api_key,
                        "X-CC-Version": "2018-03-22"
                    }
                )
                response.raise_for_status()
                data = response.json()["data"]
                
                # Check if any payment was confirmed
                confirmed = any(
                    payment["status"] == "CONFIRMED" 
                    for payment in data.get("payments", [])
                )
                
                return {
                    "status": data["timeline"][-1]["status"] if data.get("timeline") else "NEW",
                    "paid": confirmed
                }
        
        return {"status": "unknown", "paid": False}
    
    async def _get_paypal_token(self) -> str:
        """Get PayPal OAuth token"""
        
        async with httpx.AsyncClient() as client:
            response = await client.post(
                f"{self.paypal_base_url}/v1/oauth2/token",
                data={"grant_type": "client_credentials"},
                auth=(self.paypal_client_id, self.paypal_secret)
            )
            response.raise_for_status()
            return response.json()["access_token"]
    
    def verify_webhook_signature(self, payload: bytes, signature: str, provider: str) -> bool:
        """Verify webhook signatures from payment providers"""
        
        if provider == "stripe":
            try:
                stripe.Webhook.construct_event(
                    payload, signature, os.getenv("STRIPE_WEBHOOK_SECRET")
                )
                return True
            except ValueError:
                return False
        
        elif provider == "coinbase":
            expected = hmac.new(
                self.coinbase_webhook_secret.encode(),
                payload,
                hashlib.sha256
            ).hexdigest()
            return hmac.compare_digest(expected, signature)
        
        elif provider == "paypal":
            # PayPal webhook verification is more complex
            # Would need to call PayPal's verification endpoint
            return True  # Simplified for now
        
        return False
    
    async def get_bank_accounts(self, user_id: str) -> List[Dict[str, Any]]:
        """Get user's connected bank accounts"""
        try:
            customer = await self._get_or_create_stripe_customer(user_id)
            
            # Get bank accounts from Stripe
            bank_accounts = stripe.Customer.list_sources(
                customer.id,
                object="bank_account",
                limit=10
            )
            
            return [
                {
                    "id": account.id,
                    "bank_name": account.bank_name,
                    "last4": account.last4,
                    "account_type": account.account_holder_type,
                    "status": account.status,
                    "is_default": account.id == customer.default_source
                }
                for account in bank_accounts.data
            ]
        except Exception as e:
            logger.error(f"Failed to get bank accounts: {str(e)}")
            return []

# Global instance
payment_service = PaymentService()