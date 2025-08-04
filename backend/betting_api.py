from fastapi import APIRouter, HTTPException, Depends, BackgroundTasks
from sqlalchemy.orm import Session
from sqlalchemy import func
from typing import List, Optional, Dict, Any
from datetime import datetime, timedelta
import logging

from database import get_db
from auth import get_current_user
from dispute_models import Dispute
from betting_models import (
    Bet, BetStatus, EscrowAccount, EscrowStatus, 
    BettingPool, Payout, PayoutStatus, UserWallet, Transaction
)
from escrow_service import escrow_service
from payment_service import payment_service  # We'll create this next
from pydantic import BaseModel, Field, validator

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/api/betting", tags=["betting"])

# Pydantic models for requests/responses
class PlaceBetRequest(BaseModel):
    dispute_id: str
    amount: float = Field(gt=0, le=10000)  # Max $10k per bet
    predicted_winner: str  # "partyA" or "partyB"
    payment_method: str = "wallet"  # wallet, stripe, paypal, crypto
    escrow_provider: Optional[str] = "escrow.com"
    
    @validator('predicted_winner')
    def validate_winner(cls, v):
        if v not in ["partyA", "partyB"]:
            raise ValueError("predicted_winner must be 'partyA' or 'partyB'")
        return v

class BetResponse(BaseModel):
    bet_id: str
    status: str
    amount: float
    odds: float
    potential_payout: float
    escrow_status: Optional[str]
    payment_required: bool
    payment_url: Optional[str]

class WalletResponse(BaseModel):
    balance: float
    pending_balance: float
    is_verified: bool
    daily_limit: float
    monthly_limit: float

class DepositRequest(BaseModel):
    amount: float = Field(gt=0, le=10000)
    payment_method: str

class WithdrawRequest(BaseModel):
    amount: float = Field(gt=0)
    payment_method: str
    destination: str  # Bank account, PayPal email, crypto address

@router.post("/place-bet", response_model=BetResponse)
async def place_bet(
    request: PlaceBetRequest,
    background_tasks: BackgroundTasks,
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Place a bet on a dispute outcome"""
    
    # Check if dispute exists and is active
    dispute = db.query(Dispute).filter_by(id=request.dispute_id).first()
    if not dispute:
        raise HTTPException(status_code=404, detail="Dispute not found")
    
    if dispute.status not in ["active", "in_mediation"]:
        raise HTTPException(status_code=400, detail="Dispute is not accepting bets")
    
    # Get or create user wallet
    wallet = db.query(UserWallet).filter_by(user_id=current_user["id"]).first()
    if not wallet:
        wallet = UserWallet(user_id=current_user["id"])
        db.add(wallet)
        db.commit()
    
    # Check wallet balance if using wallet payment
    if request.payment_method == "wallet":
        if wallet.balance < request.amount:
            raise HTTPException(status_code=400, detail="Insufficient wallet balance")
        
        # Check daily/monthly limits
        today_total = db.query(func.sum(Bet.amount)).filter(
            Bet.user_id == current_user["id"],
            Bet.placed_at >= datetime.utcnow() - timedelta(days=1)
        ).scalar() or 0
        
        if today_total + request.amount > wallet.daily_limit:
            raise HTTPException(status_code=400, detail="Daily betting limit exceeded")
    
    # Get or create betting pool
    pool = db.query(BettingPool).filter_by(dispute_id=request.dispute_id).first()
    if not pool:
        pool = BettingPool(dispute_id=request.dispute_id)
        db.add(pool)
    
    # Calculate odds based on current pool
    if request.predicted_winner == "partyA":
        # More bets on A = lower odds for A
        pool.party_a_amount += request.amount
        odds = (pool.party_b_amount + pool.total_pool_amount * 0.1) / (pool.party_a_amount + 0.1)
    else:
        pool.party_b_amount += request.amount
        odds = (pool.party_a_amount + pool.total_pool_amount * 0.1) / (pool.party_b_amount + 0.1)
    
    odds = max(1.1, min(odds, 10.0))  # Cap odds between 1.1x and 10x
    potential_payout = request.amount * odds * (1 - pool.platform_fee_percentage)
    
    # Create bet record
    bet = Bet(
        user_id=current_user["id"],
        dispute_id=request.dispute_id,
        amount=request.amount,
        predicted_winner=request.predicted_winner,
        odds=odds,
        potential_payout=potential_payout,
        payment_method=request.payment_method,
        status=BetStatus.PENDING
    )
    db.add(bet)
    
    # Update pool totals
    pool.total_pool_amount += request.amount
    pool.party_a_odds = pool.party_b_amount / (pool.party_a_amount + 0.1)
    pool.party_b_odds = pool.party_a_amount / (pool.party_b_amount + 0.1)
    
    payment_required = request.payment_method != "wallet"
    payment_url = None
    
    if request.payment_method == "wallet":
        # Deduct from wallet immediately
        wallet.balance -= request.amount
        wallet.pending_balance += request.amount
        wallet.total_bet += request.amount
        
        # Create transaction record
        transaction = Transaction(
            user_id=current_user["id"],
            wallet_id=wallet.id,
            type="bet",
            amount=-request.amount,
            bet_id=bet.id,
            description=f"Bet on dispute {dispute.title}"
        )
        db.add(transaction)
        
        # Create escrow account
        escrow_data = await escrow_service.create_escrow_for_bet({
            "bet_id": bet.id,
            "amount": request.amount,
            "dispute_id": request.dispute_id,
            "user_id": current_user["id"],
            "buyer_email": current_user["email"]
        }, provider=request.escrow_provider)
        
        escrow = EscrowAccount(
            dispute_id=request.dispute_id,
            provider=request.escrow_provider,
            provider_account_id=escrow_data.get("transaction_id"),
            total_amount=request.amount,
            payer_user_id=current_user["id"],
            status=EscrowStatus.FUNDED,
            funded_at=datetime.utcnow()
        )
        db.add(escrow)
        
        bet.escrow_id = escrow.id
        bet.status = BetStatus.ACTIVE
        
    else:
        # External payment required
        # Create pending escrow
        escrow = EscrowAccount(
            dispute_id=request.dispute_id,
            provider=request.escrow_provider,
            total_amount=request.amount,
            payer_user_id=current_user["id"],
            status=EscrowStatus.PENDING
        )
        db.add(escrow)
        bet.escrow_id = escrow.id
        
        # Generate payment URL
        payment_data = await payment_service.create_payment_intent(
            amount=request.amount,
            currency="USD",
            payment_method=request.payment_method,
            metadata={
                "bet_id": bet.id,
                "user_id": current_user["id"],
                "dispute_id": request.dispute_id
            }
        )
        
        bet.payment_id = payment_data["payment_id"]
        payment_url = payment_data["payment_url"]
        payment_required = True
    
    db.commit()
    
    # Schedule background task to monitor payment
    if payment_required:
        background_tasks.add_task(monitor_payment_status, bet.id, db)
    
    return BetResponse(
        bet_id=bet.id,
        status=bet.status.value,
        amount=bet.amount,
        odds=bet.odds,
        potential_payout=bet.potential_payout,
        escrow_status=escrow.status.value if escrow else None,
        payment_required=payment_required,
        payment_url=payment_url
    )

@router.get("/my-bets", response_model=List[Dict[str, Any]])
async def get_my_bets(
    status: Optional[str] = None,
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get user's betting history"""
    
    query = db.query(Bet).filter(Bet.user_id == current_user["id"])
    
    if status:
        try:
            status_enum = BetStatus(status)
            query = query.filter(Bet.status == status_enum)
        except ValueError:
            raise HTTPException(status_code=400, detail="Invalid status")
    
    bets = query.order_by(Bet.placed_at.desc()).all()
    
    return [{
        "id": bet.id,
        "dispute_id": bet.dispute_id,
        "dispute_title": bet.dispute.title,
        "amount": bet.amount,
        "predicted_winner": bet.predicted_winner,
        "odds": bet.odds,
        "potential_payout": bet.potential_payout,
        "status": bet.status.value,
        "placed_at": bet.placed_at.isoformat(),
        "settled_at": bet.settled_at.isoformat() if bet.settled_at else None
    } for bet in bets]

@router.get("/wallet", response_model=WalletResponse)
async def get_wallet(
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get user's wallet information"""
    
    wallet = db.query(UserWallet).filter_by(user_id=current_user["id"]).first()
    if not wallet:
        wallet = UserWallet(user_id=current_user["id"])
        db.add(wallet)
        db.commit()
    
    return WalletResponse(
        balance=wallet.balance,
        pending_balance=wallet.pending_balance,
        is_verified=wallet.is_verified,
        daily_limit=wallet.daily_limit,
        monthly_limit=wallet.monthly_limit
    )

@router.post("/deposit")
async def deposit_funds(
    request: DepositRequest,
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Deposit funds into wallet"""
    
    wallet = db.query(UserWallet).filter_by(user_id=current_user["id"]).first()
    if not wallet:
        wallet = UserWallet(user_id=current_user["id"])
        db.add(wallet)
    
    # Create payment intent
    payment_data = await payment_service.create_payment_intent(
        amount=request.amount,
        currency="USD",
        payment_method=request.payment_method,
        metadata={
            "type": "deposit",
            "user_id": current_user["id"],
            "wallet_id": wallet.id
        }
    )
    
    # Create pending transaction
    transaction = Transaction(
        user_id=current_user["id"],
        wallet_id=wallet.id,
        type="deposit",
        amount=request.amount,
        status="pending",
        external_id=payment_data["payment_id"],
        payment_method=request.payment_method
    )
    db.add(transaction)
    db.commit()
    
    return {
        "transaction_id": transaction.id,
        "payment_url": payment_data["payment_url"],
        "amount": request.amount
    }

@router.post("/withdraw")
async def withdraw_funds(
    request: WithdrawRequest,
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Withdraw funds from wallet"""
    
    wallet = db.query(UserWallet).filter_by(user_id=current_user["id"]).first()
    if not wallet:
        raise HTTPException(status_code=404, detail="Wallet not found")
    
    if wallet.balance < request.amount:
        raise HTTPException(status_code=400, detail="Insufficient balance")
    
    if not wallet.is_verified:
        raise HTTPException(status_code=403, detail="Account verification required for withdrawals")
    
    # Create payout
    payout_data = await payment_service.create_payout(
        amount=request.amount,
        currency="USD",
        payment_method=request.payment_method,
        destination=request.destination,
        metadata={
            "user_id": current_user["id"],
            "wallet_id": wallet.id
        }
    )
    
    # Deduct from wallet
    wallet.balance -= request.amount
    wallet.total_withdrawn += request.amount
    
    # Create transaction
    transaction = Transaction(
        user_id=current_user["id"],
        wallet_id=wallet.id,
        type="withdrawal",
        amount=-request.amount,
        status="pending",
        external_id=payout_data["payout_id"],
        payment_method=request.payment_method
    )
    db.add(transaction)
    db.commit()
    
    return {
        "transaction_id": transaction.id,
        "amount": request.amount,
        "status": "processing",
        "estimated_arrival": payout_data.get("estimated_arrival")
    }

@router.get("/pool/{dispute_id}")
async def get_betting_pool(
    dispute_id: str,
    db: Session = Depends(get_db)
):
    """Get betting pool statistics for a dispute"""
    
    pool = db.query(BettingPool).filter_by(dispute_id=dispute_id).first()
    if not pool:
        return {
            "total_pool": 0,
            "party_a_pool": 0,
            "party_b_pool": 0,
            "party_a_odds": 1.0,
            "party_b_odds": 1.0,
            "is_active": True
        }
    
    return {
        "total_pool": pool.total_pool_amount,
        "party_a_pool": pool.party_a_amount,
        "party_b_pool": pool.party_b_amount,
        "party_a_odds": pool.party_a_odds,
        "party_b_odds": pool.party_b_odds,
        "is_active": pool.is_active,
        "platform_fee": pool.platform_fee_percentage
    }

@router.post("/settle/{dispute_id}")
async def settle_bets(
    dispute_id: str,
    winner: str,  # "partyA" or "partyB"
    background_tasks: BackgroundTasks,
    db: Session = Depends(get_db)
):
    """Settle all bets for a resolved dispute (admin only)"""
    
    # TODO: Add admin authentication check
    
    # Get all active bets for this dispute
    bets = db.query(Bet).filter(
        Bet.dispute_id == dispute_id,
        Bet.status == BetStatus.ACTIVE
    ).all()
    
    if not bets:
        return {"message": "No active bets to settle"}
    
    # Get betting pool
    pool = db.query(BettingPool).filter_by(dispute_id=dispute_id).first()
    if pool:
        pool.is_active = False
        pool.closed_at = datetime.utcnow()
    
    winners = []
    losers = []
    
    for bet in bets:
        if bet.predicted_winner == winner:
            winners.append(bet)
        else:
            losers.append(bet)
        
        bet.status = BetStatus.SETTLED
        bet.settled_at = datetime.utcnow()
    
    # Process payouts for winners
    for bet in winners:
        # Create payout record
        payout = Payout(
            bet_id=bet.id,
            user_id=bet.user_id,
            amount=bet.potential_payout,
            payment_method=bet.payment_method or "wallet",
            status=PayoutStatus.PENDING
        )
        db.add(payout)
        
        # Update wallet if using wallet payment
        wallet = db.query(UserWallet).filter_by(user_id=bet.user_id).first()
        if wallet and bet.payment_method == "wallet":
            wallet.balance += bet.potential_payout
            wallet.pending_balance -= bet.amount
            wallet.total_won += bet.potential_payout
            
            # Create transaction
            transaction = Transaction(
                user_id=bet.user_id,
                wallet_id=wallet.id,
                type="payout",
                amount=bet.potential_payout,
                bet_id=bet.id,
                payout_id=payout.id,
                description=f"Won bet on dispute: {bet.dispute.title}"
            )
            db.add(transaction)
            
            payout.status = PayoutStatus.COMPLETED
            payout.completed_at = datetime.utcnow()
        
        # Release escrow funds
        if bet.escrow_id:
            escrow = db.query(EscrowAccount).filter_by(id=bet.escrow_id).first()
            if escrow:
                background_tasks.add_task(
                    release_escrow_funds,
                    escrow.id,
                    bet.user.email,
                    escrow.provider
                )
    
    # Update pending balance for losers
    for bet in losers:
        wallet = db.query(UserWallet).filter_by(user_id=bet.user_id).first()
        if wallet and bet.payment_method == "wallet":
            wallet.pending_balance -= bet.amount
    
    db.commit()
    
    return {
        "settled_bets": len(bets),
        "winners": len(winners),
        "losers": len(losers),
        "total_payout": sum(w.potential_payout for w in winners)
    }

# Background tasks
async def monitor_payment_status(bet_id: str, db: Session):
    """Monitor external payment status"""
    # Implementation would check payment provider APIs
    pass

async def release_escrow_funds(escrow_id: str, recipient_email: str, provider: str):
    """Release funds from escrow to winner"""
    try:
        await escrow_service.release_winnings(escrow_id, recipient_email, provider)
    except Exception as e:
        logger.error(f"Failed to release escrow {escrow_id}: {str(e)}")