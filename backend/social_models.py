from datetime import datetime
import uuid

from sqlalchemy import Column, String, DateTime, Boolean, Integer, ForeignKey
from sqlalchemy.orm import relationship

from database import Base


class Follow(Base):
    """Represents a follow relationship between two users (social graph)."""

    __tablename__ = "follows"

    follower_id = Column(String, ForeignKey("users.id"), primary_key=True)
    followee_id = Column(String, ForeignKey("users.id"), primary_key=True)
    followed_at = Column(DateTime, default=datetime.utcnow)


class ClashRoom(Base):
    """A live debate room between two streamers / creators."""

    __tablename__ = "clash_rooms"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))

    # Streamers involved
    streamer_a_id = Column(String, ForeignKey("users.id"), nullable=False)
    streamer_b_id = Column(String, ForeignKey("users.id"), nullable=False)

    status = Column(String, default="live")  # live, ended, scheduled
    viewer_count = Column(Integer, default=0)

    created_at = Column(DateTime, default=datetime.utcnow)
    ended_at = Column(DateTime, nullable=True)

    # Relationships (optional)
    streamer_a = relationship("User", foreign_keys=[streamer_a_id])
    streamer_b = relationship("User", foreign_keys=[streamer_b_id])


class ClashVote(Base):
    """Stores a user's vote in a clash (who they think is winning)."""
    __tablename__ = "clash_votes"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    clash_id = Column(String, ForeignKey("clash_rooms.id"), index=True, nullable=False)
    user_id = Column(String, ForeignKey("users.id"), index=True, nullable=False)
    vote_for = Column(String, nullable=False)  # "A" or "B"
    created_at = Column(DateTime, default=datetime.utcnow)

    # ensure one vote per user per clash (SQLite lacks constraints easily – enforce in code)

class Badge(Base):
    """Badges earned by users based on XP or achievements."""
    __tablename__ = "badges"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id = Column(String, ForeignKey("users.id"), index=True, nullable=False)
    badge_type = Column(String, nullable=False)
    awarded_at = Column(DateTime, default=datetime.utcnow)
    user = relationship("User", back_populates="badges")

class InviteCode(Base):
    __tablename__ = "invite_codes"

    code = Column(String, primary_key=True)
    inviter_id = Column(String, ForeignKey("users.id"), nullable=False)
    used_by_id = Column(String, ForeignKey("users.id"), nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)

    inviter = relationship("User", foreign_keys=[inviter_id])
    used_by = relationship("User", foreign_keys=[used_by_id])

class HighlightClip(Base):
    __tablename__ = "highlight_clips"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    clash_id = Column(String, ForeignKey("clash_rooms.id"))
    file_url = Column(String, nullable=False)
    caption = Column(String, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)


class XPLog(Base):
    __tablename__ = "xp_log"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id = Column(String, ForeignKey("users.id"), index=True)
    points = Column(Integer)
    created_at = Column(DateTime, default=datetime.utcnow)

    user = relationship("User")

class PredictionVote(Base):
    """User predicts dispute winner before resolution"""
    __tablename__ = "prediction_votes"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    dispute_id = Column(String, index=True)
    user_id = Column(String, ForeignKey("users.id"))
    guess = Column(String)  # partyA, partyB, draw
    created_at = Column(DateTime, default=datetime.utcnow)
    processed = Column(Boolean, default=False)