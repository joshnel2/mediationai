from fastapi import FastAPI, HTTPException, WebSocket, WebSocketDisconnect
from fastapi.middleware.cors import CORSMiddleware
from typing import List, Dict, Optional, Any
import json
import logging
from datetime import datetime, timedelta
import asyncio
import uuid
from enum import Enum
from pydantic import BaseModel, Field

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Enhanced Models for the demo workflow
class InvestigationPhase(str, Enum):
    CREATED = "created"
    INITIAL_REVIEW = "initial_review"
    PARTY_1_INVESTIGATION = "party_1_investigation"
    PARTY_2_INVESTIGATION = "party_2_investigation"
    CROSS_EXAMINATION = "cross_examination"
    FINAL_ANALYSIS = "final_analysis"
    RESOLUTION_READY = "resolution_ready"
    RESOLVED = "resolved"

class ConversationType(str, Enum):
    PRIVATE_INVESTIGATION = "private_investigation"
    CLARIFICATION = "clarification"
    CROSS_EXAMINATION = "cross_examination"
    RESOLUTION = "resolution"

class PrivateConversation(BaseModel):
    id: str = Field(default_factory=lambda: str(uuid.uuid4()))
    dispute_id: str
    participant_id: str
    conversation_type: ConversationType
    messages: List[Dict[str, Any]] = Field(default_factory=list)
    created_at: datetime = Field(default_factory=datetime.now)
    updated_at: datetime = Field(default_factory=datetime.now)
    is_complete: bool = False
    summary: Optional[str] = None
    key_findings: List[str] = Field(default_factory=list)

class EnhancedDispute(BaseModel):
    id: str = Field(default_factory=lambda: str(uuid.uuid4()))
    title: str
    description: str
    category: str
    created_by: str
    phase: InvestigationPhase = InvestigationPhase.CREATED
    participants: List[Dict[str, Any]] = Field(default_factory=list)
    evidence: List[Dict[str, Any]] = Field(default_factory=list)
    private_conversations: Dict[str, PrivateConversation] = Field(default_factory=dict)
    investigation_summary: Optional[Dict[str, Any]] = None
    final_resolution: Optional[Dict[str, Any]] = None
    created_at: datetime = Field(default_factory=datetime.now)
    updated_at: datetime = Field(default_factory=datetime.now)
    timeline: List[Dict[str, Any]] = Field(default_factory=list)

class DemoAIInvestigator:
    """Demo AI investigator with predefined responses"""
    
    def __init__(self):
        self.question_counter = {}
    
    async def start_investigation(self, dispute: EnhancedDispute, participant_id: str) -> Dict[str, Any]:
        """Start private investigation with a participant"""
        participant = next((p for p in dispute.participants if p['id'] == participant_id), None)
        if not participant:
            raise ValueError("Participant not found")
        
        # Create private conversation
        conversation = PrivateConversation(
            dispute_id=dispute.id,
            participant_id=participant_id,
            conversation_type=ConversationType.PRIVATE_INVESTIGATION
        )
        
        # Generate opening investigation message
        opening_message = f"""Hello {participant['name']},

I am an AI investigator conducting a private and confidential investigation regarding the dispute: "{dispute.title}".

This conversation is completely private - only you and I can see what we discuss here. The other party will not have access to this conversation.

I need to gather detailed information about what happened from your perspective. Let me start with some basic questions:

1. Can you tell me, in your own words, what this dispute is about?
2. What is your main concern or complaint?
3. When did this issue first arise?

Please provide as much detail as possible. I'll ask follow-up questions to understand the full situation."""
        
        # Add AI message to conversation
        conversation.messages.append({
            "sender": "ai_investigator",
            "content": opening_message,
            "timestamp": datetime.now().isoformat(),
            "type": "investigation"
        })
        
        dispute.private_conversations[participant_id] = conversation
        self.question_counter[participant_id] = 1
        
        return {
            "conversation_id": conversation.id,
            "message": opening_message,
            "phase": "investigation_started"
        }
    
    async def continue_investigation(self, dispute: EnhancedDispute, participant_id: str, user_response: str) -> Dict[str, Any]:
        """Continue the investigation conversation"""
        conversation = dispute.private_conversations.get(participant_id)
        if not conversation:
            raise ValueError("Investigation not found")
        
        # Add user response to conversation
        conversation.messages.append({
            "sender": "user",
            "content": user_response,
            "timestamp": datetime.now().isoformat(),
            "type": "response"
        })
        
        # Generate follow-up question based on question counter
        participant = next((p for p in dispute.participants if p['id'] == participant_id), None)
        question_num = self.question_counter.get(participant_id, 1)
        
        follow_up_questions = [
            f"Thank you for that information. Can you provide more specific details about the timeline of events? What exactly happened first, and when?",
            f"I see. Can you tell me about any documentation, emails, or evidence you have related to this dispute?",
            f"What efforts have you made to resolve this issue directly with the other party?",
            f"Are there any witnesses or third parties who can support your version of events?",
            f"What would you consider a fair resolution to this dispute?",
            f"Based on our conversation, I have a good understanding of your position. Let me summarize what I've learned and conclude this investigation."
        ]
        
        if question_num < len(follow_up_questions):
            ai_response = follow_up_questions[question_num]
            self.question_counter[participant_id] = question_num + 1
        else:
            # Complete investigation
            ai_response = f"""Thank you for providing detailed information about this dispute. 

Based on our private conversation, I have gathered the following key information:
- Your version of events and timeline
- Evidence and documentation you've referenced
- Your desired resolution
- Witness information and supporting details

This investigation is now complete. I will analyze all the information along with the other party's investigation to reach a fair decision.

You will be notified once the final analysis and decision are ready."""
            
            await self._complete_investigation(conversation, user_response)
        
        # Add AI response to conversation
        conversation.messages.append({
            "sender": "ai_investigator",
            "content": ai_response,
            "timestamp": datetime.now().isoformat(),
            "type": "investigation"
        })
        
        conversation.updated_at = datetime.now()
        
        return {
            "conversation_id": conversation.id,
            "message": ai_response,
            "is_complete": conversation.is_complete,
            "phase": "investigation_ongoing"
        }
    
    async def _complete_investigation(self, conversation: PrivateConversation, final_response: str):
        """Complete the investigation and generate summary"""
        # Create a summary based on the conversation
        summary = f"""Investigation Summary:

Key Claims:
- Primary complaint based on participant responses
- Timeline of events from their perspective
- Evidence and documentation mentioned
- Desired resolution

Credibility Assessment: 7/10 (Based on consistency and detail provided)

Key Findings:
- Participant provided detailed timeline
- Referenced specific evidence
- Appeared cooperative and forthcoming
- Story remained consistent throughout questioning

This investigation is complete and ready for final analysis."""
        
        # Extract key findings
        key_findings = [
            "Provided detailed timeline of events",
            "Referenced supporting documentation",
            "Appeared cooperative during investigation",
            "Story remained consistent",
            "Expressed willingness to resolve dispute"
        ]
        
        conversation.summary = summary
        conversation.key_findings = key_findings
        conversation.is_complete = True
        conversation.updated_at = datetime.now()

class DemoAIJudge:
    """Demo AI judge with predefined decision-making logic"""
    
    async def analyze_investigations(self, dispute: EnhancedDispute) -> Dict[str, Any]:
        """Analyze all private investigations and create summary"""
        if len(dispute.private_conversations) < 2:
            raise ValueError("Need at least 2 completed investigations")
        
        # Get all completed investigations
        completed_investigations = {
            pid: conv for pid, conv in dispute.private_conversations.items() 
            if conv.is_complete
        }
        
        if len(completed_investigations) < 2:
            raise ValueError("Need at least 2 completed investigations")
        
        # Create analysis summary
        analysis = f"""Judicial Analysis of Private Investigations:

INVESTIGATION SUMMARY:
Both parties have been interviewed privately and thoroughly. Each provided their version of events, supporting evidence, and desired resolution.

CREDIBILITY ASSESSMENT:
- Party 1: Consistent story, provided documentation, cooperative
- Party 2: Detailed timeline, referenced evidence, forthcoming

KEY FINDINGS:
- Both parties agree on basic facts but disagree on interpretation
- Evidence supports elements of both sides' claims
- Some contradictions in timeline details
- Both parties appeared genuine in their responses

AREAS OF AGREEMENT:
- Basic timeline of initial interaction
- General nature of the dispute
- Desire to resolve the matter

CONTRADICTIONS:
- Different interpretations of key events
- Disagreement on responsibility
- Varying claims about communications

RECOMMENDATION:
Ready for final judicial decision based on thorough investigation of both parties."""
        
        return {
            "dispute_id": dispute.id,
            "analysis": analysis,
            "credibility_scores": {"party_1": 7.0, "party_2": 7.0},
            "ready_for_decision": True
        }
    
    async def render_final_decision(self, dispute: EnhancedDispute) -> Dict[str, Any]:
        """Render final binding decision"""
        # Create a comprehensive judicial decision
        decision = f"""FINAL JUDICIAL DECISION

Case: {dispute.title}
Date: {datetime.now().strftime('%B %d, %Y')}

FINDINGS OF FACT:
After conducting thorough private investigations with both parties, I find:

1. Both parties entered into an agreement with specific terms and expectations
2. There were communications and interactions that led to the current dispute
3. Both parties have legitimate concerns and grievances
4. There is evidence supporting elements of both parties' positions

ANALYSIS:
Based on the private investigations conducted, both parties provided credible testimony. While there are disagreements about specific details and interpretations, the core facts are established.

DECISION:
1. Both parties share responsibility for the current situation
2. Each party should take specific actions to resolve the dispute
3. A fair resolution requires compromise from both sides

RESOLUTION TERMS:
1. Party 1 shall: Take corrective action within 30 days
2. Party 2 shall: Provide necessary cooperation and documentation
3. Both parties: Maintain professional communication going forward
4. Timeline: All actions to be completed within 45 days

ENFORCEMENT:
This decision is final and binding. Both parties are expected to comply with the terms outlined above.

IMPLEMENTATION:
Both parties will receive this decision and should begin implementation immediately. No further litigation or dispute resolution is needed if both parties comply with these terms.

Rendered by: AI Judge
Date: {datetime.now().isoformat()}"""
        
        return {
            "decision": decision,
            "ruling_date": datetime.now().isoformat(),
            "is_final": True,
            "implementation_deadline": (datetime.now() + timedelta(days=45)).isoformat(),
            "required_actions": [
                "Party 1: Take corrective action within 30 days",
                "Party 2: Provide cooperation and documentation",
                "Both parties: Maintain professional communication"
            ]
        }

class DemoDisputeManager:
    """Demo dispute manager with enhanced workflow"""
    
    def __init__(self):
        self.disputes: Dict[str, EnhancedDispute] = {}
        self.investigator = DemoAIInvestigator()
        self.judge = DemoAIJudge()
    
    def create_dispute(self, title: str, description: str, category: str, created_by: str, participants: List[Dict[str, Any]]) -> EnhancedDispute:
        """Create a new dispute with enhanced workflow"""
        dispute = EnhancedDispute(
            title=title,
            description=description,
            category=category,
            created_by=created_by,
            participants=participants
        )
        
        # Add timeline entry
        dispute.timeline.append({
            "phase": "created",
            "timestamp": datetime.now().isoformat(),
            "description": "Dispute created and participants added"
        })
        
        self.disputes[dispute.id] = dispute
        return dispute
    
    async def start_investigation_phase(self, dispute_id: str) -> Dict[str, Any]:
        """Start the investigation phase"""
        dispute = self.disputes.get(dispute_id)
        if not dispute:
            raise ValueError("Dispute not found")
        
        if dispute.phase != InvestigationPhase.CREATED:
            raise ValueError(f"Cannot start investigation from phase {dispute.phase}")
        
        dispute.phase = InvestigationPhase.INITIAL_REVIEW
        dispute.timeline.append({
            "phase": "initial_review",
            "timestamp": datetime.now().isoformat(),
            "description": "AI beginning initial review and preparation for private investigations"
        })
        
        initial_review = f"""Initial Investigation Review:

Dispute: {dispute.title}
Participants: {len(dispute.participants)} parties

KEY ISSUES TO INVESTIGATE:
1. Timeline of events from each party's perspective
2. Evidence and documentation available
3. Communication history between parties
4. Attempts at resolution
5. Desired outcomes

INVESTIGATION APPROACH:
- Private interviews with each party separately
- Thorough questioning to understand all perspectives
- Assessment of credibility and consistency
- Gathering of supporting evidence
- Analysis of contradictions and corroborations

NEXT STEPS:
Ready to begin private investigations with each party. Each will be interviewed separately and confidentially."""
        
        return {
            "dispute_id": dispute_id,
            "phase": dispute.phase,
            "initial_review": initial_review,
            "next_step": "Ready to begin private investigations"
        }
    
    async def start_private_investigation(self, dispute_id: str, participant_id: str) -> Dict[str, Any]:
        """Start private investigation with a participant"""
        dispute = self.disputes.get(dispute_id)
        if not dispute:
            raise ValueError("Dispute not found")
        
        # Update phase based on which participant
        if participant_id == dispute.participants[0]['id']:
            dispute.phase = InvestigationPhase.PARTY_1_INVESTIGATION
        elif participant_id == dispute.participants[1]['id']:
            dispute.phase = InvestigationPhase.PARTY_2_INVESTIGATION
        
        dispute.timeline.append({
            "phase": f"investigating_{participant_id}",
            "timestamp": datetime.now().isoformat(),
            "description": f"Started private investigation with participant {participant_id}"
        })
        
        return await self.investigator.start_investigation(dispute, participant_id)
    
    async def continue_private_investigation(self, dispute_id: str, participant_id: str, response: str) -> Dict[str, Any]:
        """Continue private investigation conversation"""
        dispute = self.disputes.get(dispute_id)
        if not dispute:
            raise ValueError("Dispute not found")
        
        result = await self.investigator.continue_investigation(dispute, participant_id, response)
        
        # Check if all investigations are complete
        completed_investigations = [
            conv for conv in dispute.private_conversations.values() 
            if conv.is_complete
        ]
        
        if len(completed_investigations) >= 2:
            dispute.phase = InvestigationPhase.FINAL_ANALYSIS
            dispute.timeline.append({
                "phase": "final_analysis",
                "timestamp": datetime.now().isoformat(),
                "description": "All investigations complete. Beginning final analysis."
            })
        
        return result
    
    async def conduct_final_analysis(self, dispute_id: str) -> Dict[str, Any]:
        """Conduct final analysis of all investigations"""
        dispute = self.disputes.get(dispute_id)
        if not dispute:
            raise ValueError("Dispute not found")
        
        if dispute.phase != InvestigationPhase.FINAL_ANALYSIS:
            raise ValueError(f"Cannot conduct final analysis from phase {dispute.phase}")
        
        # Generate investigation summary
        summary = await self.judge.analyze_investigations(dispute)
        dispute.investigation_summary = summary
        
        dispute.phase = InvestigationPhase.RESOLUTION_READY
        dispute.timeline.append({
            "phase": "resolution_ready",
            "timestamp": datetime.now().isoformat(),
            "description": "Final analysis complete. Ready for judicial decision."
        })
        
        return {
            "dispute_id": dispute_id,
            "phase": dispute.phase,
            "analysis_complete": True,
            "ready_for_decision": True
        }
    
    async def render_final_decision(self, dispute_id: str) -> Dict[str, Any]:
        """Render final judicial decision"""
        dispute = self.disputes.get(dispute_id)
        if not dispute:
            raise ValueError("Dispute not found")
        
        if dispute.phase != InvestigationPhase.RESOLUTION_READY:
            raise ValueError(f"Cannot render decision from phase {dispute.phase}")
        
        # Generate final decision
        decision = await self.judge.render_final_decision(dispute)
        dispute.final_resolution = decision
        
        dispute.phase = InvestigationPhase.RESOLVED
        dispute.timeline.append({
            "phase": "resolved",
            "timestamp": datetime.now().isoformat(),
            "description": "Final decision rendered. Dispute resolved."
        })
        
        return {
            "dispute_id": dispute_id,
            "phase": dispute.phase,
            "resolution": decision,
            "resolved": True
        }
    
    def get_dispute_status(self, dispute_id: str) -> Dict[str, Any]:
        """Get current status of dispute"""
        dispute = self.disputes.get(dispute_id)
        if not dispute:
            raise ValueError("Dispute not found")
        
        return {
            "dispute_id": dispute_id,
            "title": dispute.title,
            "phase": dispute.phase,
            "participants": dispute.participants,
            "investigations_complete": len([c for c in dispute.private_conversations.values() if c.is_complete]),
            "has_final_resolution": dispute.final_resolution is not None,
            "timeline": dispute.timeline
        }

# Create FastAPI app
app = FastAPI(
    title="Demo Enhanced MediationAI API",
    description="Demo version of AI-powered dispute resolution with private investigations",
    version="2.0.0-demo"
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Request/Response Models
class CreateEnhancedDisputeRequest(BaseModel):
    title: str
    description: str
    category: str
    created_by: str
    participants: List[Dict[str, Any]]

class InvestigationMessageRequest(BaseModel):
    participant_id: str
    message: str

# Global manager instance
dispute_manager = DemoDisputeManager()

# WebSocket connections
websocket_connections: Dict[str, WebSocket] = {}

# ==============================================================================
# ENHANCED DISPUTE WORKFLOW ENDPOINTS
# ==============================================================================

@app.post("/api/v2/disputes")
async def create_enhanced_dispute(request: CreateEnhancedDisputeRequest):
    """Create a new dispute with enhanced investigation workflow"""
    try:
        # Validate participants
        if len(request.participants) < 2:
            raise HTTPException(status_code=400, detail="At least 2 participants required")
        
        # Create dispute
        dispute = dispute_manager.create_dispute(
            title=request.title,
            description=request.description,
            category=request.category,
            created_by=request.created_by,
            participants=request.participants
        )
        
        logger.info(f"Created demo dispute: {dispute.id}")
        
        return {
            "status": "success",
            "message": "Demo dispute created successfully",
            "dispute_id": dispute.id,
            "phase": dispute.phase,
            "next_step": "Call /start-investigation to begin AI investigation",
            "dispute": dispute.dict()
        }
        
    except Exception as e:
        logger.error(f"Error creating demo dispute: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/api/v2/disputes/{dispute_id}/start-investigation")
async def start_investigation(dispute_id: str):
    """Start the AI investigation phase"""
    try:
        result = await dispute_manager.start_investigation_phase(dispute_id)
        return {
            "status": "success",
            "message": "Investigation phase started",
            **result
        }
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        logger.error(f"Error starting investigation: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/api/v2/disputes/{dispute_id}/investigate/{participant_id}")
async def start_private_investigation(dispute_id: str, participant_id: str):
    """Start private investigation with a specific participant"""
    try:
        result = await dispute_manager.start_private_investigation(dispute_id, participant_id)
        return {
            "status": "success",
            "message": "Private investigation started",
            **result
        }
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        logger.error(f"Error starting private investigation: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/api/v2/disputes/{dispute_id}/investigate/{participant_id}/continue")
async def continue_investigation(dispute_id: str, participant_id: str, request: InvestigationMessageRequest):
    """Continue private investigation conversation"""
    try:
        result = await dispute_manager.continue_private_investigation(
            dispute_id, 
            participant_id, 
            request.message
        )
        return {
            "status": "success",
            "message": "Investigation continued",
            **result
        }
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        logger.error(f"Error continuing investigation: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/api/v2/disputes/{dispute_id}/analyze")
async def conduct_final_analysis(dispute_id: str):
    """Conduct final analysis of all investigations"""
    try:
        result = await dispute_manager.conduct_final_analysis(dispute_id)
        return {
            "status": "success",
            "message": "Final analysis completed",
            **result
        }
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        logger.error(f"Error conducting final analysis: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/api/v2/disputes/{dispute_id}/render-decision")
async def render_final_decision(dispute_id: str):
    """Render final judicial decision"""
    try:
        result = await dispute_manager.render_final_decision(dispute_id)
        return {
            "status": "success",
            "message": "Final decision rendered",
            **result
        }
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        logger.error(f"Error rendering final decision: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/v2/disputes/{dispute_id}/status")
async def get_dispute_status(dispute_id: str):
    """Get current status of dispute"""
    try:
        status = dispute_manager.get_dispute_status(dispute_id)
        return {
            "status": "success",
            **status
        }
    except ValueError as e:
        raise HTTPException(status_code=404, detail=str(e))
    except Exception as e:
        logger.error(f"Error getting dispute status: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/v2/disputes/{dispute_id}/conversation/{participant_id}")
async def get_private_conversation(dispute_id: str, participant_id: str):
    """Get private conversation for a participant"""
    try:
        dispute = dispute_manager.disputes.get(dispute_id)
        if not dispute:
            raise HTTPException(status_code=404, detail="Dispute not found")
        
        conversation = dispute.private_conversations.get(participant_id)
        if not conversation:
            raise HTTPException(status_code=404, detail="Private conversation not found")
        
        return {
            "status": "success",
            "conversation": conversation.dict()
        }
    except Exception as e:
        logger.error(f"Error getting private conversation: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/v2/disputes/{dispute_id}/resolution")
async def get_final_resolution(dispute_id: str):
    """Get final resolution"""
    try:
        dispute = dispute_manager.disputes.get(dispute_id)
        if not dispute:
            raise HTTPException(status_code=404, detail="Dispute not found")
        
        if dispute.phase != InvestigationPhase.RESOLVED:
            raise HTTPException(status_code=400, detail="Dispute not yet resolved")
        
        return {
            "status": "success",
            "resolution": dispute.final_resolution,
            "phase": dispute.phase,
            "resolved_at": dispute.timeline[-1]["timestamp"]
        }
    except Exception as e:
        logger.error(f"Error getting final resolution: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

# ==============================================================================
# DEMO ENDPOINTS
# ==============================================================================

@app.get("/api/v2/demo/create-sample-dispute")
async def create_sample_enhanced_dispute():
    """Create a sample dispute for testing"""
    try:
        participants = [
            {
                "id": "participant_1",
                "name": "John Doe",
                "role": "complainant",
                "email": "john@example.com"
            },
            {
                "id": "participant_2", 
                "name": "Jane Smith",
                "role": "respondent",
                "email": "jane@example.com"
            }
        ]
        
        dispute = dispute_manager.create_dispute(
            title="Service Contract Dispute - Demo",
            description="Demo dispute over incomplete website development services.",
            category="service",
            created_by="participant_1",
            participants=participants
        )
        
        return {
            "status": "success",
            "message": "Demo dispute created",
            "dispute_id": dispute.id,
            "participants": participants,
            "next_steps": [
                f"1. POST /api/v2/disputes/{dispute.id}/start-investigation",
                f"2. POST /api/v2/disputes/{dispute.id}/investigate/participant_1",
                f"3. POST /api/v2/disputes/{dispute.id}/investigate/participant_2",
                f"4. Continue conversations, then analyze and render-decision"
            ]
        }
    except Exception as e:
        logger.error(f"Error creating demo dispute: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/v2/health")
async def health_check():
    """Health check endpoint"""
    return {
        "status": "healthy",
        "version": "2.0.0-demo",
        "timestamp": datetime.now().isoformat(),
        "active_disputes": len(dispute_manager.disputes),
        "features": [
            "private_investigations",
            "judicial_decisions",
            "demo_mode",
            "enhanced_workflow"
        ]
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "demo_enhanced_api:app",
        host="0.0.0.0",
        port=8000,
        debug=True,
        reload=True
    )