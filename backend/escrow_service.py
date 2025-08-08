import os
import httpx
import json
from typing import Dict, Any, Optional, List
from datetime import datetime, timedelta
import logging
from abc import ABC, abstractmethod
from config import settings
import stripe

logger = logging.getLogger(__name__)

class DisputeEscrowService:
    """
    Legal escrow service for dispute resolution
    No gambling license required - similar to Escrow.com or court bonds
    """
    
    def __init__(self):
        stripe.api_key = os.getenv("STRIPE_SECRET_KEY")
        self.service_fee_percent = float(os.getenv("ESCROW_SERVICE_FEE", "5.0"))
        
    async def create_dispute_escrow(
        self,
        dispute_id: str,
        party1_email: str,
        party2_email: str,
        disputed_amount: float,
        dispute_description: str,
        escrow_type: str = "standard"  # standard, expedited, binding_arbitration
    ) -> Dict[str, Any]:
        """
        Create escrow for dispute resolution
        Both parties must deposit to show good faith
        """
        try:
            # Calculate fees based on escrow type
            base_fee = disputed_amount * (self.service_fee_percent / 100)
            
            fee_multipliers = {
                "standard": 1.0,        # 5% - AI mediation only
                "expedited": 1.5,       # 7.5% - Priority handling
                "binding_arbitration": 2.0  # 10% - Legal arbitrator
            }
            
            total_fee = base_fee * fee_multipliers.get(escrow_type, 1.0)
            
            # Create Stripe payment intent for party 1
            intent1 = stripe.PaymentIntent.create(
                amount=int((disputed_amount + total_fee/2) * 100),  # Convert to cents
                currency='usd',
                metadata={
                    'dispute_id': dispute_id,
                    'party': 'party1',
                    'email': party1_email,
                    'escrow_type': escrow_type
                },
                description=f"Escrow deposit for dispute: {dispute_description[:100]}"
            )
            
            # Create Stripe payment intent for party 2
            intent2 = stripe.PaymentIntent.create(
                amount=int((disputed_amount + total_fee/2) * 100),
                currency='usd',
                metadata={
                    'dispute_id': dispute_id,
                    'party': 'party2',
                    'email': party2_email,
                    'escrow_type': escrow_type
                },
                description=f"Escrow deposit for dispute: {dispute_description[:100]}"
            )
            
            escrow_data = {
                'escrow_id': f"esc_{dispute_id}",
                'dispute_id': dispute_id,
                'escrow_type': escrow_type,
                'disputed_amount': disputed_amount,
                'total_fee': total_fee,
                'status': 'awaiting_deposits',
                'created_at': datetime.utcnow().isoformat(),
                'deadline': (datetime.utcnow() + timedelta(days=7)).isoformat(),
                'party1': {
                    'email': party1_email,
                    'payment_intent_id': intent1.id,
                    'client_secret': intent1.client_secret,
                    'amount_required': disputed_amount + total_fee/2,
                    'deposited': False
                },
                'party2': {
                    'email': party2_email,
                    'payment_intent_id': intent2.id,
                    'client_secret': intent2.client_secret,
                    'amount_required': disputed_amount + total_fee/2,
                    'deposited': False
                },
                'features': self._get_escrow_features(escrow_type)
            }
            
            logger.info(f"Created escrow for dispute {dispute_id}")
            return escrow_data
            
        except Exception as e:
            logger.error(f"Failed to create escrow: {str(e)}")
            raise
            
    def _get_escrow_features(self, escrow_type: str) -> List[str]:
        """Get features included with each escrow type"""
        features = {
            "standard": [
                "AI-powered mediation",
                "Secure fund holding",
                "Digital contract generation",
                "7-day resolution timeline",
                "Basic support"
            ],
            "expedited": [
                "Priority AI mediation",
                "Secure fund holding",
                "Digital contract generation",
                "48-hour resolution timeline",
                "Priority support",
                "Human mediator review"
            ],
            "binding_arbitration": [
                "Licensed arbitrator",
                "Legally binding decision",
                "Secure fund holding",
                "Legal contract generation",
                "14-day resolution timeline",
                "Premium support",
                "Court-admissible documentation"
            ]
        }
        return features.get(escrow_type, features["standard"])
        
    async def check_deposit_status(self, payment_intent_id: str) -> bool:
        """Check if a payment intent has been completed"""
        try:
            intent = stripe.PaymentIntent.retrieve(payment_intent_id)
            return intent.status == 'succeeded'
        except Exception as e:
            logger.error(f"Failed to check payment status: {str(e)}")
            return False
            
    async def release_escrow(
        self,
        escrow_id: str,
        winner_email: str,
        loser_email: str,
        resolution_details: Dict[str, Any],
        split_percentage: Optional[Dict[str, float]] = None
    ) -> Dict[str, Any]:
        """
        Release escrow funds based on resolution
        Default: winner takes all minus fees
        Optional: custom split (for settlements)
        """
        try:
            if split_percentage:
                # Custom settlement split
                winner_percent = split_percentage.get(winner_email, 50)
                loser_percent = split_percentage.get(loser_email, 50)
            else:
                # Winner takes all
                winner_percent = 100
                loser_percent = 0
                
            # Calculate payouts
            # Note: In production, fetch actual amounts from database
            disputed_amount = resolution_details.get('disputed_amount', 0)
            winner_payout = disputed_amount * (winner_percent / 100)
            loser_payout = disputed_amount * (loser_percent / 100)
            
            # Create transfers
            if winner_payout > 0:
                transfer1 = stripe.Transfer.create(
                    amount=int(winner_payout * 100),
                    currency='usd',
                    destination=winner_email,  # In production: use Stripe Connect account ID
                    description=f"Dispute resolution payout - {winner_percent}%"
                )
                
            if loser_payout > 0:
                transfer2 = stripe.Transfer.create(
                    amount=int(loser_payout * 100),
                    currency='usd',
                    destination=loser_email,  # In production: use Stripe Connect account ID
                    description=f"Dispute resolution payout - {loser_percent}%"
                )
                
            return {
                'escrow_id': escrow_id,
                'status': 'completed',
                'resolution': resolution_details,
                'payouts': {
                    winner_email: winner_payout,
                    loser_email: loser_payout
                },
                'completed_at': datetime.utcnow().isoformat()
            }
            
        except Exception as e:
            logger.error(f"Failed to release escrow: {str(e)}")
            raise
            
    async def offer_settlement(
        self,
        escrow_id: str,
        proposing_party: str,
        settlement_split: Dict[str, float],
        settlement_reason: str
    ) -> Dict[str, Any]:
        """
        Allow one party to propose a settlement
        Other party must accept for it to be executed
        """
        return {
            'escrow_id': escrow_id,
            'settlement_id': f"stl_{escrow_id}_{datetime.utcnow().timestamp()}",
            'proposed_by': proposing_party,
            'proposed_split': settlement_split,
            'reason': settlement_reason,
            'status': 'pending_acceptance',
            'expires_at': (datetime.utcnow() + timedelta(hours=48)).isoformat(),
            'legal_notice': "This settlement is legally binding once accepted by both parties."
        }
        
    async def get_escrow_analytics(self) -> Dict[str, Any]:
        """Get analytics for business metrics"""
        # In production: Query from database
        return {
            'total_disputes_handled': 1250,
            'total_escrow_volume': 2_500_000,
            'average_dispute_value': 2000,
            'average_resolution_time_hours': 72,
            'settlement_rate': 0.65,  # 65% settle before full arbitration
            'revenue_generated': 125_000,  # 5% of volume
            'customer_satisfaction': 4.7  # out of 5
        }

class EscrowProvider(ABC):
    """Abstract base class for escrow providers"""
    
    @abstractmethod
    async def create_transaction(self, amount: float, buyer_email: str, seller_email: str, 
                               description: str, metadata: Dict[str, Any]) -> Dict[str, Any]:
        pass
    
    @abstractmethod
    async def fund_transaction(self, transaction_id: str, payment_method: Dict[str, Any]) -> Dict[str, Any]:
        pass
    
    @abstractmethod
    async def release_funds(self, transaction_id: str, recipient: str) -> Dict[str, Any]:
        pass
    
    @abstractmethod
    async def refund_transaction(self, transaction_id: str) -> Dict[str, Any]:
        pass
    
    @abstractmethod
    async def get_transaction_status(self, transaction_id: str) -> Dict[str, Any]:
        pass

class EscrowComProvider(EscrowProvider):
    """Integration with Escrow.com API"""
    
    def __init__(self):
        self.api_key = os.getenv("ESCROW_COM_API_KEY")
        self.api_secret = os.getenv("ESCROW_COM_API_SECRET")
        self.base_url = "https://api.escrow.com/2017-09-01"
        self.sandbox_url = "https://api.escrow-sandbox.com/2017-09-01"
        self.use_sandbox = os.getenv("ESCROW_SANDBOX", "true").lower() == "true"
        
    @property
    def api_url(self):
        return self.sandbox_url if self.use_sandbox else self.base_url
    
    async def create_transaction(self, amount: float, buyer_email: str, seller_email: str,
                               description: str, metadata: Dict[str, Any]) -> Dict[str, Any]:
        """Create an escrow transaction on Escrow.com"""
        
        transaction_data = {
            "parties": [
                {
                    "role": "buyer",
                    "customer": buyer_email,
                    "agreed": True
                },
                {
                    "role": "seller", 
                    "customer": seller_email,
                    "agreed": True
                }
            ],
            "currency": "usd",
            "description": description,
            "items": [
                {
                    "title": f"Crashout Bet: {metadata.get('dispute_id', 'Unknown')}",
                    "description": description,
                    "type": "general_merchandise",
                    "quantity": 1,
                    "price": amount,
                    "currency": "usd"
                }
            ]
        }
        
        async with httpx.AsyncClient() as client:
            response = await client.post(
                f"{self.api_url}/transaction",
                json=transaction_data,
                auth=(self.api_key, self.api_secret)
            )
            response.raise_for_status()
            return response.json()
    
    async def fund_transaction(self, transaction_id: str, payment_method: Dict[str, Any]) -> Dict[str, Any]:
        """Fund an escrow transaction"""
        
        # In production, this would integrate with payment processor
        # For now, simulate funding
        async with httpx.AsyncClient() as client:
            response = await client.post(
                f"{self.api_url}/transaction/{transaction_id}/payment",
                json={
                    "method": payment_method.get("type", "wire_transfer"),
                    "amount": payment_method.get("amount")
                },
                auth=(self.api_key, self.api_secret)
            )
            response.raise_for_status()
            return response.json()
    
    async def release_funds(self, transaction_id: str, recipient: str) -> Dict[str, Any]:
        """Release funds to the winner"""
        
        async with httpx.AsyncClient() as client:
            response = await client.post(
                f"{self.api_url}/transaction/{transaction_id}/release",
                json={"action": "release"},
                auth=(self.api_key, self.api_secret)
            )
            response.raise_for_status()
            return response.json()
    
    async def refund_transaction(self, transaction_id: str) -> Dict[str, Any]:
        """Refund the transaction"""
        
        async with httpx.AsyncClient() as client:
            response = await client.post(
                f"{self.api_url}/transaction/{transaction_id}/refund",
                json={"action": "refund"},
                auth=(self.api_key, self.api_secret)
            )
            response.raise_for_status()
            return response.json()
    
    async def get_transaction_status(self, transaction_id: str) -> Dict[str, Any]:
        """Get transaction status"""
        
        async with httpx.AsyncClient() as client:
            response = await client.get(
                f"{self.api_url}/transaction/{transaction_id}",
                auth=(self.api_key, self.api_secret)
            )
            response.raise_for_status()
            return response.json()

class SmartContractEscrow(EscrowProvider):
    """Blockchain-based smart contract escrow (Ethereum)"""
    
    def __init__(self):
        self.web3_provider = os.getenv("WEB3_PROVIDER_URL", "https://mainnet.infura.io/v3/YOUR_KEY")
        self.contract_address = os.getenv("ESCROW_CONTRACT_ADDRESS")
        self.private_key = os.getenv("ESCROW_WALLET_PRIVATE_KEY")
        
    async def create_transaction(self, amount: float, buyer_email: str, seller_email: str,
                               description: str, metadata: Dict[str, Any]) -> Dict[str, Any]:
        """Deploy or interact with smart contract for escrow"""
        
        # This would interact with a deployed smart contract
        # For now, return mock data
        return {
            "transaction_id": f"0x{os.urandom(32).hex()}",
            "contract_address": self.contract_address,
            "status": "deployed",
            "amount_wei": int(amount * 10**18),  # Convert to Wei
            "created_at": datetime.utcnow().isoformat()
        }
    
    async def fund_transaction(self, transaction_id: str, payment_method: Dict[str, Any]) -> Dict[str, Any]:
        """Fund smart contract with cryptocurrency"""
        
        # Would send ETH/USDC to smart contract
        return {
            "transaction_hash": f"0x{os.urandom(32).hex()}",
            "status": "funded",
            "block_number": 12345678
        }
    
    async def release_funds(self, transaction_id: str, recipient: str) -> Dict[str, Any]:
        """Release funds from smart contract"""
        
        # Would call release function on smart contract
        return {
            "transaction_hash": f"0x{os.urandom(32).hex()}",
            "status": "released",
            "recipient": recipient
        }
    
    async def refund_transaction(self, transaction_id: str) -> Dict[str, Any]:
        """Refund from smart contract"""
        
        return {
            "transaction_hash": f"0x{os.urandom(32).hex()}",
            "status": "refunded"
        }
    
    async def get_transaction_status(self, transaction_id: str) -> Dict[str, Any]:
        """Query smart contract state"""
        
        return {
            "transaction_id": transaction_id,
            "status": "active",
            "balance": "1000000000000000000"  # 1 ETH in Wei
        }

class TrustlyEscrow(EscrowProvider):
    """Integration with Trustly payment and escrow services"""
    
    def __init__(self):
        self.merchant_id = os.getenv("TRUSTLY_MERCHANT_ID")
        self.api_key = os.getenv("TRUSTLY_API_KEY")
        self.base_url = "https://api.trustly.com/1.0"
        
    async def create_transaction(self, amount: float, buyer_email: str, seller_email: str,
                               description: str, metadata: Dict[str, Any]) -> Dict[str, Any]:
        """Create Trustly escrow transaction"""
        
        transaction_data = {
            "method": "Deposit",
            "params": {
                "Signature": self._generate_signature(),
                "UUID": metadata.get("transaction_uuid"),
                "Data": {
                    "Username": self.merchant_id,
                    "Password": self.api_key,
                    "NotificationURL": f"{settings.api_base_url}/webhooks/trustly",
                    "EndUserID": buyer_email,
                    "MessageID": metadata.get("dispute_id"),
                    "Amount": str(amount),
                    "Currency": "USD"
                }
            }
        }
        
        async with httpx.AsyncClient() as client:
            response = await client.post(self.base_url, json=transaction_data)
            response.raise_for_status()
            return response.json()
    
    async def fund_transaction(self, transaction_id: str, payment_method: Dict[str, Any]) -> Dict[str, Any]:
        """Fund via Trustly"""
        
        # Trustly handles funding through their UI
        return {"status": "pending_user_action", "payment_url": f"https://trustly.com/pay/{transaction_id}"}
    
    async def release_funds(self, transaction_id: str, recipient: str) -> Dict[str, Any]:
        """Release funds via Trustly"""
        
        payout_data = {
            "method": "AccountPayout",
            "params": {
                "Signature": self._generate_signature(),
                "UUID": transaction_id,
                "Data": {
                    "Username": self.merchant_id,
                    "Password": self.api_key,
                    "NotificationURL": f"{settings.api_base_url}/webhooks/trustly",
                    "AccountID": recipient,
                    "Amount": "0",  # Will be filled from escrow
                    "Currency": "USD"
                }
            }
        }
        
        async with httpx.AsyncClient() as client:
            response = await client.post(self.base_url, json=payout_data)
            response.raise_for_status()
            return response.json()
    
    async def refund_transaction(self, transaction_id: str) -> Dict[str, Any]:
        """Refund via Trustly"""
        
        refund_data = {
            "method": "Refund",
            "params": {
                "Signature": self._generate_signature(),
                "UUID": transaction_id,
                "Data": {
                    "Username": self.merchant_id,
                    "Password": self.api_key,
                    "OrderID": transaction_id
                }
            }
        }
        
        async with httpx.AsyncClient() as client:
            response = await client.post(self.base_url, json=refund_data)
            response.raise_for_status()
            return response.json()
    
    async def get_transaction_status(self, transaction_id: str) -> Dict[str, Any]:
        """Get Trustly transaction status"""
        
        # Would query Trustly API
        return {"transaction_id": transaction_id, "status": "active"}
    
    def _generate_signature(self) -> str:
        """Generate Trustly API signature"""
        # Implementation would use Trustly's signature algorithm
        return "mock_signature"

class EscrowService:
    """Main escrow service that manages multiple providers"""
    
    def __init__(self):
        self.providers = {
            "escrow.com": EscrowComProvider(),
            "smart_contract": SmartContractEscrow(),
            "trustly": TrustlyEscrow()
        }
        self.default_provider = os.getenv("DEFAULT_ESCROW_PROVIDER", "escrow.com")
    
    def get_provider(self, provider_name: Optional[str] = None) -> EscrowProvider:
        """Get escrow provider instance"""
        
        provider_name = provider_name or self.default_provider
        provider = self.providers.get(provider_name)
        
        if not provider:
            raise ValueError(f"Unknown escrow provider: {provider_name}")
        
        return provider
    
    async def create_escrow_for_bet(self, bet_data: Dict[str, Any], provider: Optional[str] = None) -> Dict[str, Any]:
        """Create escrow account for a bet"""
        
        escrow_provider = self.get_provider(provider)
        
        try:
            result = await escrow_provider.create_transaction(
                amount=bet_data["amount"],
                buyer_email=bet_data["buyer_email"],
                seller_email="platform@clashout.ai",  # Platform holds funds
                description=f"Bet on dispute {bet_data['dispute_id']}",
                metadata={
                    "dispute_id": bet_data["dispute_id"],
                    "bet_id": bet_data["bet_id"],
                    "user_id": bet_data["user_id"]
                }
            )
            
            logger.info(f"Created escrow transaction: {result}")
            return result
            
        except Exception as e:
            logger.error(f"Failed to create escrow: {str(e)}")
            raise
    
    async def release_winnings(self, escrow_id: str, winner_email: str, provider: Optional[str] = None) -> Dict[str, Any]:
        """Release funds to the winner"""
        
        escrow_provider = self.get_provider(provider)
        
        try:
            result = await escrow_provider.release_funds(escrow_id, winner_email)
            logger.info(f"Released funds to {winner_email}: {result}")
            return result
            
        except Exception as e:
            logger.error(f"Failed to release funds: {str(e)}")
            raise
    
    async def refund_bet(self, escrow_id: str, provider: Optional[str] = None) -> Dict[str, Any]:
        """Refund a bet (e.g., if dispute is cancelled)"""
        
        escrow_provider = self.get_provider(provider)
        
        try:
            result = await escrow_provider.refund_transaction(escrow_id)
            logger.info(f"Refunded transaction {escrow_id}: {result}")
            return result
            
        except Exception as e:
            logger.error(f"Failed to refund: {str(e)}")
            raise

# Global instance
escrow_service = EscrowService()