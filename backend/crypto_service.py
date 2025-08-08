import os
from web3 import Web3
from typing import Dict, Optional
import logging
from decimal import Decimal

logger = logging.getLogger(__name__)

class CryptoService:
    """Handle crypto payments and betting without traditional licensing"""
    
    def __init__(self):
        # Use Polygon for low fees
        self.w3 = Web3(Web3.HTTPProvider(os.getenv('POLYGON_RPC_URL', 'https://polygon-rpc.com')))
        self.usdc_address = "0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174"  # USDC on Polygon
        
    async def create_dispute_escrow(self, dispute_id: str, amount_usdc: float) -> Dict:
        """Create escrow for dispute betting"""
        try:
            # Generate unique wallet for dispute
            account = self.w3.eth.account.create()
            
            return {
                "dispute_id": dispute_id,
                "escrow_address": account.address,
                "private_key": account.key.hex(),  # Store securely!
                "amount_usdc": amount_usdc,
                "chain": "polygon",
                "status": "awaiting_deposits"
            }
        except Exception as e:
            logger.error(f"Failed to create escrow: {e}")
            raise
            
    async def check_wallet_balance(self, wallet_address: str) -> Dict:
        """Check USDC balance of wallet"""
        # ABI for balanceOf function
        balance_abi = [{
            "constant": True,
            "inputs": [{"name": "_owner", "type": "address"}],
            "name": "balanceOf",
            "outputs": [{"name": "balance", "type": "uint256"}],
            "type": "function"
        }]
        
        contract = self.w3.eth.contract(
            address=self.usdc_address,
            abi=balance_abi
        )
        
        balance = contract.functions.balanceOf(wallet_address).call()
        # USDC has 6 decimals
        balance_usdc = balance / 10**6
        
        return {
            "wallet": wallet_address,
            "balance_usdc": float(balance_usdc),
            "balance_raw": balance
        }
        
    async def distribute_winnings(self, dispute_id: str, winner_address: str, loser_addresses: list) -> Dict:
        """Distribute betting pool to winners"""
        # In production: Use smart contract for trustless distribution
        # This is simplified version
        
        return {
            "dispute_id": dispute_id,
            "winner": winner_address,
            "distribution": "pending_smart_contract",
            "note": "Implement smart contract for trustless payouts"
        }