import os
import stripe
import httpx
from typing import Dict, Any, Optional
from datetime import datetime
import logging
import hashlib
import hmac

logger = logging.getLogger(__name__)

# Initialize Stripe
stripe.api_key = os.getenv("STRIPE_SECRET_KEY")

class PaymentService:
    """Unified payment service supporting multiple providers"""
    
    def __init__(self):
        self.stripe_key = os.getenv("STRIPE_SECRET_KEY")
        self.paypal_client_id = os.getenv("PAYPAL_CLIENT_ID")
        self.paypal_secret = os.getenv("PAYPAL_SECRET")
        self.coinbase_api_key = os.getenv("COINBASE_API_KEY")
        self.coinbase_webhook_secret = os.getenv("COINBASE_WEBHOOK_SECRET")
        
        # PayPal URLs
        self.paypal_base_url = "https://api-m.sandbox.paypal.com" if os.getenv("PAYPAL_SANDBOX", "true") == "true" else "https://api-m.paypal.com"
    
    async def create_payment_intent(self, amount: float, currency: str, 
                                  payment_method: str, metadata: Dict[str, Any]) -> Dict[str, Any]:
        """Create a payment intent with the specified provider"""
        
        if payment_method == "stripe":
            return await self._create_stripe_payment(amount, currency, metadata)
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
                "description": f"Bet on dispute {metadata.get('dispute_id', '')}"
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
                    "name": f"Bet on dispute",
                    "description": f"Bet on dispute {metadata.get('dispute_id', '')}",
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
        elif payment_method == "paypal":
            return await self._create_paypal_payout(amount, currency, destination, metadata)
        elif payment_method == "crypto":
            return await self._create_crypto_payout(amount, currency, destination, metadata)
        else:
            raise ValueError(f"Unsupported payout method: {payment_method}")
    
    async def _create_stripe_payout(self, amount: float, currency: str, 
                                  destination: str, metadata: Dict[str, Any]) -> Dict[str, Any]:
        """Create Stripe payout"""
        
        try:
            # Create transfer to connected account or external account
            transfer = stripe.Transfer.create(
                amount=int(amount * 100),
                currency=currency.lower(),
                destination=destination,  # Stripe account ID or bank account
                metadata=metadata
            )
            
            return {
                "payout_id": transfer.id,
                "status": transfer.status,
                "estimated_arrival": transfer.arrival_date
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
                "email_subject": "You won your bet!",
                "email_message": "Congratulations on winning your Crashout bet!"
            },
            "items": [{
                "recipient_type": "EMAIL",
                "amount": {
                    "value": str(amount),
                    "currency": currency
                },
                "receiver": destination,
                "note": f"Payout for bet winnings",
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
                "estimated_arrival": "1-3 business days"
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
        
        if payment_method == "stripe":
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

# Global instance
payment_service = PaymentService()