from sqlalchemy import Column, String, Float, DateTime, Boolean, Integer, ForeignKey, Enum, JSON
from sqlalchemy.orm import relationship
from database import Base
import uuid
from datetime import datetime
import enum

class BetStatus(enum.Enum):
    PENDING = "pending"
    ACTIVE = "active"
    SETTLED = "settled"
    CANCELLED = "cancelled"
    REFUNDED = "refunded"

class PayoutStatus(enum.Enum):
    PENDING = "pending"
    PROCESSING = "processing"
    COMPLETED = "completed"
    FAILED = "failed"

class EscrowStatus(enum.Enum):
    PENDING = "pending"
    FUNDED = "funded"
    RELEASED = "released"
    REFUNDED = "refunded"
    DISPUTED = "disputed"

class Bet(Base):
    __tablename__ = "bets"
    
    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id = Column(String, ForeignKey("users.id"), nullable=False)
    dispute_id = Column(String, ForeignKey("disputes.id"), nullable=False)
    crashout_user_id = Column(String, ForeignKey("users.id"), nullable=True)  # User being bet on
    
    # Bet details
    amount = Column(Float, nullable=False)  # USD amount
    predicted_winner = Column(String, nullable=False)  # "partyA" or "partyB"
    odds = Column(Float, nullable=False, default=1.0)
    potential_payout = Column(Float, nullable=False)
    
    # Status tracking
    status = Column(Enum(BetStatus), default=BetStatus.PENDING)
    placed_at = Column(DateTime, default=datetime.utcnow)
    settled_at = Column(DateTime, nullable=True)
    
    # Payment details
    payment_method = Column(String, nullable=True)  # stripe, paypal, crypto
    payment_id = Column(String, nullable=True)  # External payment reference
    
    # Escrow reference
    escrow_id = Column(String, ForeignKey("escrow_accounts.id"), nullable=True)
    
    # Relationships
    user = relationship("User", foreign_keys=[user_id], backref="bets")
    dispute = relationship("Dispute", backref="bets")
    crashout_user = relationship("User", foreign_keys=[crashout_user_id])
    escrow = relationship("EscrowAccount", back_populates="bet")

class EscrowAccount(Base):
    __tablename__ = "escrow_accounts"
    
    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    dispute_id = Column(String, ForeignKey("disputes.id"), nullable=False)
    
    # Escrow provider details
    provider = Column(String, nullable=False)  # "escrow.com", "trulioo", etc.
    provider_account_id = Column(String, nullable=True)
    provider_transaction_id = Column(String, nullable=True)
    
    # Financial details
    total_amount = Column(Float, nullable=False)
    currency = Column(String, default="USD")
    funded_amount = Column(Float, default=0.0)
    
    # Status
    status = Column(Enum(EscrowStatus), default=EscrowStatus.PENDING)
    created_at = Column(DateTime, default=datetime.utcnow)
    funded_at = Column(DateTime, nullable=True)
    released_at = Column(DateTime, nullable=True)
    
    # Parties
    payer_user_id = Column(String, ForeignKey("users.id"), nullable=False)
    recipient_user_id = Column(String, ForeignKey("users.id"), nullable=True)
    
    # Metadata
    metadata = Column(JSON, nullable=True)  # Additional provider-specific data
    
    # Relationships
    dispute = relationship("Dispute", backref="escrow_accounts")
    payer = relationship("User", foreign_keys=[payer_user_id])
    recipient = relationship("User", foreign_keys=[recipient_user_id])
    bet = relationship("Bet", back_populates="escrow", uselist=False)

class BettingPool(Base):
    __tablename__ = "betting_pools"
    
    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    dispute_id = Column(String, ForeignKey("disputes.id"), nullable=False, unique=True)
    
    # Pool statistics
    total_pool_amount = Column(Float, default=0.0)
    party_a_amount = Column(Float, default=0.0)
    party_b_amount = Column(Float, default=0.0)
    
    # Odds calculation
    party_a_odds = Column(Float, default=1.0)
    party_b_odds = Column(Float, default=1.0)
    
    # Pool status
    is_active = Column(Boolean, default=True)
    closed_at = Column(DateTime, nullable=True)
    
    # House take (platform fee)
    platform_fee_percentage = Column(Float, default=0.05)  # 5% default
    platform_fee_collected = Column(Float, default=0.0)
    
    # Relationships
    dispute = relationship("Dispute", backref="betting_pool", uselist=False)

class Payout(Base):
    __tablename__ = "payouts"
    
    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    bet_id = Column(String, ForeignKey("bets.id"), nullable=False)
    user_id = Column(String, ForeignKey("users.id"), nullable=False)
    
    # Payout details
    amount = Column(Float, nullable=False)
    currency = Column(String, default="USD")
    
    # Payment details
    payment_method = Column(String, nullable=False)
    payment_destination = Column(String, nullable=True)  # Account details
    transaction_id = Column(String, nullable=True)
    
    # Status
    status = Column(Enum(PayoutStatus), default=PayoutStatus.PENDING)
    created_at = Column(DateTime, default=datetime.utcnow)
    processed_at = Column(DateTime, nullable=True)
    completed_at = Column(DateTime, nullable=True)
    
    # Error handling
    error_message = Column(String, nullable=True)
    retry_count = Column(Integer, default=0)
    
    # Relationships
    bet = relationship("Bet", backref="payouts")
    user = relationship("User", backref="payouts")

class UserWallet(Base):
    __tablename__ = "user_wallets"
    
    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id = Column(String, ForeignKey("users.id"), nullable=False, unique=True)
    
    # Balance tracking
    balance = Column(Float, default=0.0)
    pending_balance = Column(Float, default=0.0)  # Funds in escrow
    
    # Lifetime statistics
    total_deposited = Column(Float, default=0.0)
    total_withdrawn = Column(Float, default=0.0)
    total_bet = Column(Float, default=0.0)
    total_won = Column(Float, default=0.0)
    
    # Wallet status
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    last_activity = Column(DateTime, default=datetime.utcnow)
    
    # KYC/AML compliance
    is_verified = Column(Boolean, default=False)
    verification_level = Column(Integer, default=0)  # 0=unverified, 1=basic, 2=full
    daily_limit = Column(Float, default=1000.0)
    monthly_limit = Column(Float, default=10000.0)
    
    # Relationships
    user = relationship("User", backref="wallet", uselist=False)

class Transaction(Base):
    __tablename__ = "transactions"
    
    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id = Column(String, ForeignKey("users.id"), nullable=False)
    wallet_id = Column(String, ForeignKey("user_wallets.id"), nullable=False)
    
    # Transaction details
    type = Column(String, nullable=False)  # deposit, withdrawal, bet, payout, fee
    amount = Column(Float, nullable=False)
    currency = Column(String, default="USD")
    
    # Reference to related entities
    bet_id = Column(String, ForeignKey("bets.id"), nullable=True)
    payout_id = Column(String, ForeignKey("payouts.id"), nullable=True)
    escrow_id = Column(String, ForeignKey("escrow_accounts.id"), nullable=True)
    
    # External references
    external_id = Column(String, nullable=True)  # Stripe, PayPal, etc.
    payment_method = Column(String, nullable=True)
    
    # Status and metadata
    status = Column(String, default="completed")
    description = Column(String, nullable=True)
    metadata = Column(JSON, nullable=True)
    
    created_at = Column(DateTime, default=datetime.utcnow)
    
    # Relationships
    user = relationship("User", backref="transactions")
    wallet = relationship("UserWallet", backref="transactions")
    bet = relationship("Bet", backref="transactions")
    payout = relationship("Payout", backref="transactions")
    escrow = relationship("EscrowAccount", backref="transactions")