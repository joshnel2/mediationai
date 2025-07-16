from pydantic import BaseModel, Field
from typing import List, Optional, Dict, Any
from datetime import datetime
from enum import Enum
import uuid

class DisputeStatus(str, Enum):
    CREATED = "created"
    PARTIES_JOINED = "parties_joined"
    EVIDENCE_SUBMISSION = "evidence_submission"
    MEDIATION_IN_PROGRESS = "mediation_in_progress"
    RESOLUTION_PROPOSED = "resolution_proposed"
    RESOLVED = "resolved"
    ESCALATED = "escalated"
    CLOSED = "closed"

class ParticipantRole(str, Enum):
    COMPLAINANT = "complainant"
    RESPONDENT = "respondent"
    MEDIATOR = "mediator"
    WITNESS = "witness"

class EvidenceType(str, Enum):
    TEXT = "text"
    IMAGE = "image"
    DOCUMENT = "document"
    AUDIO = "audio"
    VIDEO = "video"
    LINK = "link"

class ResolutionType(str, Enum):
    MONETARY = "monetary"
    APOLOGY = "apology"
    ACTION_REQUIRED = "action_required"
    COMPROMISE = "compromise"
    DISMISSAL = "dismissal"

class MediationTone(str, Enum):
    COLLABORATIVE = "collaborative"
    ASSERTIVE = "assertive"
    NEUTRAL = "neutral"
    CONCILIATORY = "conciliatory"

# Core Models
class User(BaseModel):
    id: str = Field(default_factory=lambda: str(uuid.uuid4()))
    username: str
    email: str
    full_name: Optional[str] = None
    phone: Optional[str] = None
    created_at: datetime = Field(default_factory=datetime.now)
    is_verified: bool = False

class DisputeParticipant(BaseModel):
    id: str = Field(default_factory=lambda: str(uuid.uuid4()))
    user_id: str
    dispute_id: str
    role: ParticipantRole
    joined_at: datetime = Field(default_factory=datetime.now)
    is_active: bool = True
    
    # User details (denormalized for easy access)
    username: str
    email: str
    full_name: Optional[str] = None

class Evidence(BaseModel):
    id: str = Field(default_factory=lambda: str(uuid.uuid4()))
    dispute_id: str
    submitted_by: str  # User ID
    title: str
    description: str
    evidence_type: EvidenceType
    content: str  # Text content or file path
    file_url: Optional[str] = None  # For file uploads
    metadata: Optional[Dict[str, Any]] = None
    submitted_at: datetime = Field(default_factory=datetime.now)
    is_verified: bool = False

class MediationMessage(BaseModel):
    id: str = Field(default_factory=lambda: str(uuid.uuid4()))
    dispute_id: str
    sender_id: str  # User ID or "system" for AI
    sender_type: str  # "user", "ai_mediator", "ai_arbitrator"
    content: str
    message_type: str = "text"  # "text", "proposal", "decision", "system"
    timestamp: datetime = Field(default_factory=datetime.now)
    is_private: bool = False  # Private messages to specific parties
    recipient_id: Optional[str] = None  # For private messages
    metadata: Optional[Dict[str, Any]] = None

class ResolutionProposal(BaseModel):
    id: str = Field(default_factory=lambda: str(uuid.uuid4()))
    dispute_id: str
    proposed_by: str  # "ai_mediator" or user_id
    resolution_type: ResolutionType
    title: str
    description: str
    terms: List[str]
    monetary_amount: Optional[float] = None
    deadline: Optional[datetime] = None
    created_at: datetime = Field(default_factory=datetime.now)
    
    # Acceptance tracking
    accepted_by: List[str] = []  # User IDs who accepted
    rejected_by: List[str] = []  # User IDs who rejected
    is_final: bool = False

class Dispute(BaseModel):
    id: str = Field(default_factory=lambda: str(uuid.uuid4()))
    title: str
    description: str
    category: str  # "contract", "service", "product", "relationship", "property", "other"
    status: DisputeStatus = DisputeStatus.CREATED
    
    # Timing
    created_at: datetime = Field(default_factory=datetime.now)
    updated_at: datetime = Field(default_factory=datetime.now)
    resolution_deadline: Optional[datetime] = None
    
    # Participants
    participants: List[DisputeParticipant] = []
    created_by: str  # User ID
    
    # Evidence and Communication
    evidence: List[Evidence] = []
    messages: List[MediationMessage] = []
    
    # Resolution
    proposals: List[ResolutionProposal] = []
    final_resolution: Optional[ResolutionProposal] = None
    
    # AI Configuration
    mediation_tone: MediationTone = MediationTone.NEUTRAL
    ai_enabled: bool = True
    escalation_enabled: bool = True
    
    # Metadata
    tags: List[str] = []
    priority: str = "medium"  # "low", "medium", "high", "urgent"
    
    def add_participant(self, participant: DisputeParticipant):
        self.participants.append(participant)
        self.updated_at = datetime.now()
        
        # Update status based on participants
        if len(self.participants) >= 2:
            self.status = DisputeStatus.PARTIES_JOINED
    
    def add_evidence(self, evidence: Evidence):
        self.evidence.append(evidence)
        self.updated_at = datetime.now()
        
        if self.status == DisputeStatus.PARTIES_JOINED:
            self.status = DisputeStatus.EVIDENCE_SUBMISSION
    
    def add_message(self, message: MediationMessage):
        self.messages.append(message)
        self.updated_at = datetime.now()
        
        if self.status == DisputeStatus.EVIDENCE_SUBMISSION and message.sender_type == "ai_mediator":
            self.status = DisputeStatus.MEDIATION_IN_PROGRESS
    
    def add_proposal(self, proposal: ResolutionProposal):
        self.proposals.append(proposal)
        self.updated_at = datetime.now()
        
        if self.status == DisputeStatus.MEDIATION_IN_PROGRESS:
            self.status = DisputeStatus.RESOLUTION_PROPOSED
    
    def get_complainant(self) -> Optional[DisputeParticipant]:
        for participant in self.participants:
            if participant.role == ParticipantRole.COMPLAINANT:
                return participant
        return None
    
    def get_respondent(self) -> Optional[DisputeParticipant]:
        for participant in self.participants:
            if participant.role == ParticipantRole.RESPONDENT:
                return participant
        return None

# Request/Response Models for iOS App Integration
class CreateDisputeRequest(BaseModel):
    title: str
    description: str
    category: str
    created_by: str  # User ID
    mediation_tone: MediationTone = MediationTone.NEUTRAL
    resolution_deadline: Optional[datetime] = None

class JoinDisputeRequest(BaseModel):
    user_id: str
    role: ParticipantRole
    join_code: Optional[str] = None

class SubmitEvidenceRequest(BaseModel):
    title: str
    description: str
    evidence_type: EvidenceType
    content: str
    submitted_by: str

class SendMessageRequest(BaseModel):
    sender_id: str
    content: str
    message_type: str = "text"
    is_private: bool = False
    recipient_id: Optional[str] = None

class CreateProposalRequest(BaseModel):
    proposed_by: str
    resolution_type: ResolutionType
    title: str
    description: str
    terms: List[str]
    monetary_amount: Optional[float] = None
    deadline: Optional[datetime] = None

class AcceptProposalRequest(BaseModel):
    user_id: str
    proposal_id: str
    accept: bool  # True for accept, False for reject

# Response Models
class DisputeResponse(BaseModel):
    dispute: Dispute
    status: str
    message: str

class MediationResponse(BaseModel):
    dispute_id: str
    ai_response: str
    suggested_actions: List[str]
    next_steps: List[str]

class ResolutionResponse(BaseModel):
    dispute_id: str
    resolution: ResolutionProposal
    is_accepted: bool
    next_steps: List[str]

# iOS App Specific Models
class DisputeSummary(BaseModel):
    """Lightweight dispute model for iOS app lists"""
    id: str
    title: str
    category: str
    status: DisputeStatus
    created_at: datetime
    updated_at: datetime
    participant_count: int
    evidence_count: int
    unread_messages: int
    priority: str

class UserDisputesResponse(BaseModel):
    disputes: List[DisputeSummary]
    total_count: int
    unresolved_count: int
    
class NotificationEvent(BaseModel):
    """Push notification model for iOS app"""
    id: str = Field(default_factory=lambda: str(uuid.uuid4()))
    dispute_id: str
    user_id: str
    type: str  # "new_message", "evidence_added", "proposal_received", "resolution_reached"
    title: str
    message: str
    data: Dict[str, Any] = {}
    created_at: datetime = Field(default_factory=datetime.now)
    is_read: bool = False

class MediationAnalytics(BaseModel):
    """Analytics data for disputes"""
    dispute_id: str
    total_messages: int
    evidence_count: int
    resolution_time_hours: Optional[float] = None
    ai_interventions: int
    sentiment_score: float  # -1 to 1
    escalation_risk: float  # 0 to 1
    resolution_probability: float  # 0 to 1