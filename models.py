from pydantic import BaseModel, Field
from typing import List, Optional, Dict, Any
from datetime import datetime
from enum import Enum
import uuid

class PartyType(str, Enum):
    PLAINTIFF = "plaintiff"
    DEFENDANT = "defendant"
    WITNESS = "witness"

class CaseStatus(str, Enum):
    INITIATED = "initiated"
    EVIDENCE_COLLECTION = "evidence_collection"
    CROSS_EXAMINATION = "cross_examination"
    DELIBERATION = "deliberation"
    VERDICT_RENDERED = "verdict_rendered"
    CLOSED = "closed"

class MessageRole(str, Enum):
    SYSTEM = "system"
    PROSECUTOR = "prosecutor"
    DEFENSE = "defense"
    JUDGE = "judge"
    CROSS_EXAMINER = "cross_examiner"
    USER = "user"

class EvidenceType(str, Enum):
    DOCUMENT = "document"
    TESTIMONY = "testimony"
    PHYSICAL = "physical"
    DIGITAL = "digital"
    EXPERT_OPINION = "expert_opinion"

class VerdictType(str, Enum):
    GUILTY = "guilty"
    NOT_GUILTY = "not_guilty"
    LIABLE = "liable"
    NOT_LIABLE = "not_liable"
    SETTLEMENT = "settlement"

class Party(BaseModel):
    id: str = Field(default_factory=lambda: str(uuid.uuid4()))
    name: str
    party_type: PartyType
    description: Optional[str] = None
    contact_info: Optional[Dict[str, str]] = None
    created_at: datetime = Field(default_factory=datetime.now)

class Evidence(BaseModel):
    id: str = Field(default_factory=lambda: str(uuid.uuid4()))
    title: str
    description: str
    evidence_type: EvidenceType
    content: str
    submitted_by: str  # Party ID
    file_path: Optional[str] = None
    metadata: Optional[Dict[str, Any]] = None
    relevance_score: Optional[float] = None
    created_at: datetime = Field(default_factory=datetime.now)

class ConversationMessage(BaseModel):
    id: str = Field(default_factory=lambda: str(uuid.uuid4()))
    role: MessageRole
    content: str
    case_id: str
    timestamp: datetime = Field(default_factory=datetime.now)
    metadata: Optional[Dict[str, Any]] = None
    citations: Optional[List[str]] = None

class LegalArgument(BaseModel):
    id: str = Field(default_factory=lambda: str(uuid.uuid4()))
    party_id: str
    argument_text: str
    supporting_evidence: List[str]  # Evidence IDs
    legal_precedents: Optional[List[str]] = None
    strength_score: Optional[float] = None
    created_at: datetime = Field(default_factory=datetime.now)

class CrossExaminationQuestion(BaseModel):
    id: str = Field(default_factory=lambda: str(uuid.uuid4()))
    question: str
    target_party: str
    context: str
    expected_outcome: Optional[str] = None
    follow_up_questions: Optional[List[str]] = None

class DecisionFactor(BaseModel):
    factor: str
    weight: float
    reasoning: str
    supporting_evidence: List[str]

class Verdict(BaseModel):
    id: str = Field(default_factory=lambda: str(uuid.uuid4()))
    case_id: str
    verdict_type: VerdictType
    confidence_score: float
    reasoning: str
    decision_factors: List[DecisionFactor]
    legal_precedents: Optional[List[str]] = None
    dissenting_opinion: Optional[str] = None
    created_at: datetime = Field(default_factory=datetime.now)

class LegalCase(BaseModel):
    id: str = Field(default_factory=lambda: str(uuid.uuid4()))
    title: str
    description: str
    case_type: str  # e.g., "civil", "criminal", "contract"
    status: CaseStatus = CaseStatus.INITIATED
    parties: List[Party] = []
    evidence: List[Evidence] = []
    arguments: List[LegalArgument] = []
    conversation_history: List[ConversationMessage] = []
    verdict: Optional[Verdict] = None
    created_at: datetime = Field(default_factory=datetime.now)
    updated_at: datetime = Field(default_factory=datetime.now)
    
    def add_party(self, party: Party):
        self.parties.append(party)
        self.updated_at = datetime.now()
    
    def add_evidence(self, evidence: Evidence):
        self.evidence.append(evidence)
        self.updated_at = datetime.now()
    
    def add_message(self, message: ConversationMessage):
        self.conversation_history.append(message)
        self.updated_at = datetime.now()

# Request/Response Models for API
class CreateCaseRequest(BaseModel):
    title: str
    description: str
    case_type: str

class AddPartyRequest(BaseModel):
    name: str
    party_type: PartyType
    description: Optional[str] = None

class SubmitEvidenceRequest(BaseModel):
    title: str
    description: str
    evidence_type: EvidenceType
    content: str
    submitted_by: str

class StartCrossExaminationRequest(BaseModel):
    target_party: str
    initial_question: str
    context: str

class MessageRequest(BaseModel):
    role: MessageRole
    content: str

class CaseResponse(BaseModel):
    case: LegalCase
    status: str
    message: str

class VerdictResponse(BaseModel):
    verdict: Verdict
    case_status: CaseStatus
    final_summary: str