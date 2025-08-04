import os
import httpx
import json
from typing import Dict, Any, Optional
from datetime import datetime
import logging
from abc import ABC, abstractmethod
from config import settings

logger = logging.getLogger(__name__)

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