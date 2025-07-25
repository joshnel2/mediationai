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