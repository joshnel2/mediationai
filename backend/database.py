from sqlalchemy import create_engine, Column, String, DateTime, Boolean, Float, Text, Integer, ForeignKey
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, Session, relationship
from sqlalchemy.dialects.postgresql import UUID
from datetime import datetime
import uuid
import os

# Database URL - will use SQLite for development, PostgreSQL for productions
DATABASE_URL = os.getenv("DATABASE_URL", "sqlite:///./mediationai.db")

# Ensure SSL for Supabase/Postgres deployments
if DATABASE_URL.startswith("postgresql") and "sslmode" not in DATABASE_URL:
    DATABASE_URL += "?sslmode=require"

# Create SQLAlchemy engine
if DATABASE_URL.startswith("sqlite"):
    engine = create_engine(DATABASE_URL, connect_args={"check_same_thread": False})
else:
    engine = create_engine(DATABASE_URL)

# Create SessionLocal class
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# Create Base class
Base = declarative_base()

# Database Models
class User(Base):
    __tablename__ = "users"
    
    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    email = Column(String, unique=True, index=True, nullable=False)
    password_hash = Column(String, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # User profile fields
    display_name = Column(String, nullable=True)
    has_used_free_dispute = Column(Boolean, default=False)
    total_disputes = Column(Integer, default=0)
    disputes_won = Column(Integer, default=0)
    disputes_lost = Column(Integer, default=0)
    
    # Settings
    face_id_enabled = Column(Boolean, default=False)
    auto_login_enabled = Column(Boolean, default=True)
    notifications_enabled = Column(Boolean, default=True)
    
    # Relationships
    created_disputes = relationship("Dispute", foreign_keys="Dispute.party_a_id", back_populates="party_a")
    joined_disputes = relationship("Dispute", foreign_keys="Dispute.party_b_id", back_populates="party_b")

class Dispute(Base):
    __tablename__ = "disputes"
    
    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    title = Column(String, nullable=False)
    description = Column(Text, nullable=False)
    category = Column(String, nullable=False)
    dispute_value = Column(Float, nullable=False)
    status = Column(String, default="inviteSent")
    priority = Column(String, default="medium")
    
    # Parties
    party_a_id = Column(String, ForeignKey("users.id"), nullable=False)
    party_b_id = Column(String, ForeignKey("users.id"), nullable=True)
    
    # Timestamps
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    resolved_at = Column(DateTime, nullable=True)
    
    # Settings
    requires_contract = Column(Boolean, default=False)
    requires_signature = Column(Boolean, default=False)
    requires_escrow = Column(Boolean, default=False)
    is_public = Column(Boolean, default=False)
    
    # Payment tracking
    creator_paid = Column(Boolean, default=False)
    joiner_paid = Column(Boolean, default=False)
    
    # Share settings
    share_link = Column(String, nullable=True)
    share_code = Column(String, nullable=True)
    
    # Resolution
    resolution_text = Column(Text, nullable=True)
    urgency_level = Column(String, default="normal")
    
    # Relationships
    party_a = relationship("User", foreign_keys=[party_a_id], back_populates="created_disputes")
    party_b = relationship("User", foreign_keys=[party_b_id], back_populates="joined_disputes")
    truths = relationship("Truth", back_populates="dispute")
    evidence = relationship("Evidence", back_populates="dispute")
    messages = relationship("Message", back_populates="dispute")

class Truth(Base):
    __tablename__ = "truths"
    
    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    dispute_id = Column(String, ForeignKey("disputes.id"), nullable=False)
    user_id = Column(String, ForeignKey("users.id"), nullable=False)
    content = Column(Text, nullable=False)
    timestamp = Column(DateTime, default=datetime.utcnow)
    
    # Relationships
    dispute = relationship("Dispute", back_populates="truths")
    user = relationship("User")

class Evidence(Base):
    __tablename__ = "evidence"
    
    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    dispute_id = Column(String, ForeignKey("disputes.id"), nullable=False)
    user_id = Column(String, ForeignKey("users.id"), nullable=False)
    filename = Column(String, nullable=False)
    file_type = Column(String, nullable=False)
    file_size = Column(Integer, nullable=False)
    uploaded_at = Column(DateTime, default=datetime.utcnow)
    
    # Relationships
    dispute = relationship("Dispute", back_populates="evidence")
    user = relationship("User")

class Message(Base):
    __tablename__ = "messages"
    
    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    dispute_id = Column(String, ForeignKey("disputes.id"), nullable=False)
    sender_id = Column(String, ForeignKey("users.id"), nullable=False)
    content = Column(Text, nullable=False)
    message_type = Column(String, default="user")  # user, ai, system
    timestamp = Column(DateTime, default=datetime.utcnow)
    
    # Relationships
    dispute = relationship("Dispute", back_populates="messages")
    sender = relationship("User")

# Database dependency
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# Create tables
def create_tables():
    Base.metadata.create_all(bind=engine)

# Initialize database
def init_db():
    create_tables()
    print("✅ Database initialized successfully")

if __name__ == "__main__":
    init_db()
