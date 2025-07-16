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
import openai
from config import settings

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Enhanced Models for the new workflow
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

class InvestigationSummary(BaseModel):
    dispute_id: str
    party_1_findings: List[str]
    party_2_findings: List[str]
    credibility_assessment: Dict[str, float]
    evidence_analysis: Dict[str, Any]
    contradictions: List[str]
    corroborations: List[str]
    recommendation: str

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
    investigation_summary: Optional[InvestigationSummary] = None
    final_resolution: Optional[Dict[str, Any]] = None
    created_at: datetime = Field(default_factory=datetime.now)
    updated_at: datetime = Field(default_factory=datetime.now)
    timeline: List[Dict[str, Any]] = Field(default_factory=list)

class AIInvestigator:
    """AI agent that conducts private investigations with each party"""
    
    def __init__(self):
        self.openai_client = openai.OpenAI(api_key=settings.openai_api_key) if settings.openai_api_key else None
    
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
        opening_prompt = f"""You are a skilled legal investigator conducting a private interview about this dispute:

Dispute: {dispute.title}
Description: {dispute.description}
Participant Role: {participant['role']}
Participant Name: {participant['name']}

Your job is to:
1. Gather detailed information about what happened
2. Ask probing questions to understand the full story
3. Identify key facts, evidence, and witnesses
4. Assess credibility and consistency
5. Uncover any additional relevant information

Start with a professional introduction and explain that this is a private investigation to gather facts. Ask your first question to begin understanding their version of events.

Remember:
- This is confidential - only you and this participant can see this conversation
- Be thorough and professional like a lawyer
- Ask follow-up questions based on their responses
- Look for inconsistencies or gaps in their story
- Gather specific dates, times, amounts, and details
"""
        
        opening_message = await self._generate_ai_response(opening_prompt)
        
        # Add AI message to conversation
        conversation.messages.append({
            "sender": "ai_investigator",
            "content": opening_message,
            "timestamp": datetime.now().isoformat(),
            "type": "investigation"
        })
        
        dispute.private_conversations[participant_id] = conversation
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
        
        # Generate follow-up question based on conversation history
        context = self._build_conversation_context(conversation)
        participant = next((p for p in dispute.participants if p['id'] == participant_id), None)
        
        follow_up_prompt = f"""Based on this investigation conversation, generate your next question or response:

Dispute: {dispute.title}
Participant Role: {participant['role']}
Conversation History: {context}

Your latest response should:
1. Acknowledge what they just shared
2. Ask probing follow-up questions to clarify details
3. Explore any inconsistencies or gaps
4. Gather more specific information
5. Look for corroborating evidence or witnesses

If you feel you have enough information from this participant, you can conclude the investigation and provide a summary of key findings.

Current conversation length: {len(conversation.messages)} messages
"""
        
        ai_response = await self._generate_ai_response(follow_up_prompt)
        
        # Add AI response to conversation
        conversation.messages.append({
            "sender": "ai_investigator",
            "content": ai_response,
            "timestamp": datetime.now().isoformat(),
            "type": "investigation"
        })
        
        conversation.updated_at = datetime.now()
        
        # Check if investigation should be completed
        should_complete = len(conversation.messages) >= 15 or "investigation complete" in ai_response.lower()
        
        if should_complete:
            await self._complete_investigation(conversation)
        
        return {
            "conversation_id": conversation.id,
            "message": ai_response,
            "is_complete": conversation.is_complete,
            "phase": "investigation_ongoing"
        }
    
    async def _complete_investigation(self, conversation: PrivateConversation):
        """Complete the investigation and generate summary"""
        context = self._build_conversation_context(conversation)
        
        summary_prompt = f"""Based on this complete investigation conversation, provide a comprehensive summary:

Conversation: {context}

Please provide:
1. Key facts and claims made by this participant
2. Evidence or documentation they referenced
3. Timeline of events from their perspective
4. Any inconsistencies or gaps in their story
5. Credibility assessment (1-10 scale)
6. Additional witnesses or evidence they mentioned
7. Overall strength of their position

Format as a structured summary that will be used for final analysis."""
        
        summary = await self._generate_ai_response(summary_prompt)
        
        # Extract key findings
        key_findings = self._extract_key_findings(summary)
        
        conversation.summary = summary
        conversation.key_findings = key_findings
        conversation.is_complete = True
        conversation.updated_at = datetime.now()
    
    def _build_conversation_context(self, conversation: PrivateConversation) -> str:
        """Build context string from conversation messages"""
        context = ""
        for msg in conversation.messages:
            sender = "AI" if msg["sender"] == "ai_investigator" else "Participant"
            context += f"\n{sender}: {msg['content']}\n"
        return context
    
    def _extract_key_findings(self, summary: str) -> List[str]:
        """Extract key findings from summary"""
        findings = []
        lines = summary.split('\n')
        
        for line in lines:
            line = line.strip()
            if line.startswith('-') or line.startswith('•') or line.startswith('1.'):
                findings.append(line)
        
        return findings[:10]  # Top 10 findings
    
    async def _generate_ai_response(self, prompt: str) -> str:
        """Generate AI response using OpenAI"""
        if not self.openai_client:
            return "AI not configured. This is a demo response."
        
        try:
            response = self.openai_client.chat.completions.create(
                model="gpt-4",
                messages=[{"role": "user", "content": prompt}],
                max_tokens=1000,
                temperature=0.7
            )
            return response.choices[0].message.content
        except Exception as e:
            logger.error(f"AI generation error: {str(e)}")
            return "I apologize, but I'm having trouble processing your request right now. Please try again."

class AIJudge:
    """AI agent that makes final decisions based on investigation findings"""
    
    def __init__(self):
        self.openai_client = openai.OpenAI(api_key=settings.openai_api_key) if settings.openai_api_key else None
    
    async def analyze_investigations(self, dispute: EnhancedDispute) -> InvestigationSummary:
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
        
        # Build analysis context
        party_findings = {}
        for pid, conv in completed_investigations.items():
            participant = next((p for p in dispute.participants if p['id'] == pid), None)
            party_findings[participant['name']] = {
                "role": participant['role'],
                "summary": conv.summary,
                "key_findings": conv.key_findings
            }
        
        analysis_prompt = f"""You are an AI judge analyzing private investigations for this dispute:

Dispute: {dispute.title}
Description: {dispute.description}

Investigation Results:
{json.dumps(party_findings, indent=2)}

Evidence Submitted:
{json.dumps(dispute.evidence, indent=2)}

As an impartial judge, provide:
1. Credibility assessment for each party (1-10 scale)
2. Analysis of contradictions between their stories
3. Points where their accounts corroborate each other
4. Strength of evidence presented
5. Key facts that are established
6. Areas of uncertainty or missing information
7. Your preliminary assessment of the merits

Be thorough and analytical like a real judge reviewing case materials."""
        
        analysis = await self._generate_ai_response(analysis_prompt)
        
        # Extract structured findings
        party_names = list(party_findings.keys())
        
        return InvestigationSummary(
            dispute_id=dispute.id,
            party_1_findings=party_findings[party_names[0]]["key_findings"],
            party_2_findings=party_findings[party_names[1]]["key_findings"],
            credibility_assessment={name: 7.0 for name in party_names},  # Default, should be extracted
            evidence_analysis={"strength": "moderate", "completeness": "partial"},
            contradictions=self._extract_contradictions(analysis),
            corroborations=self._extract_corroborations(analysis),
            recommendation=analysis
        )
    
    async def render_final_decision(self, dispute: EnhancedDispute) -> Dict[str, Any]:
        """Render final binding decision"""
        if not dispute.investigation_summary:
            raise ValueError("Investigation summary required")
        
        decision_prompt = f"""You are an AI judge rendering a final decision in this dispute:

Dispute: {dispute.title}
Category: {dispute.category}

Investigation Summary:
{dispute.investigation_summary.recommendation}

Party 1 Findings: {dispute.investigation_summary.party_1_findings}
Party 2 Findings: {dispute.investigation_summary.party_2_findings}

Contradictions Found: {dispute.investigation_summary.contradictions}
Corroborations Found: {dispute.investigation_summary.corroborations}

Evidence Analysis: {dispute.investigation_summary.evidence_analysis}

As a judge, render your final decision including:
1. Summary of key findings
2. Determination of facts
3. Application of relevant principles
4. Final ruling and resolution
5. Specific actions required by each party
6. Timeline for implementation
7. Reasoning for your decision

This decision is final and binding. Make it clear, fair, and enforceable."""
        
        decision = await self._generate_ai_response(decision_prompt)
        
        return {
            "decision": decision,
            "ruling_date": datetime.now().isoformat(),
            "is_final": True,
            "implementation_deadline": (datetime.now() + timedelta(days=30)).isoformat(),
            "required_actions": self._extract_required_actions(decision)
        }
    
    def _extract_contradictions(self, analysis: str) -> List[str]:
        """Extract contradictions from analysis"""
        contradictions = []
        lines = analysis.split('\n')
        
        for line in lines:
            if 'contradict' in line.lower() or 'inconsistent' in line.lower():
                contradictions.append(line.strip())
        
        return contradictions
    
    def _extract_corroborations(self, analysis: str) -> List[str]:
        """Extract corroborations from analysis"""
        corroborations = []
        lines = analysis.split('\n')
        
        for line in lines:
            if 'corroborate' in line.lower() or 'consistent' in line.lower() or 'agree' in line.lower():
                corroborations.append(line.strip())
        
        return corroborations
    
    def _extract_required_actions(self, decision: str) -> List[str]:
        """Extract required actions from decision"""
        actions = []
        lines = decision.split('\n')
        
        for line in lines:
            if any(word in line.lower() for word in ['must', 'shall', 'required', 'ordered']):
                actions.append(line.strip())
        
        return actions
    
    async def _generate_ai_response(self, prompt: str) -> str:
        """Generate AI response using OpenAI"""
        if not self.openai_client:
            return "AI not configured. This is a demo response."
        
        try:
            response = self.openai_client.chat.completions.create(
                model="gpt-4",
                messages=[{"role": "user", "content": prompt}],
                max_tokens=1500,
                temperature=0.3  # Lower temperature for more consistent legal decisions
            )
            return response.choices[0].message.content
        except Exception as e:
            logger.error(f"AI generation error: {str(e)}")
            return "I apologize, but I'm having trouble processing your request right now. Please try again."

class EnhancedDisputeManager:
    """Enhanced dispute manager with investigation workflow"""
    
    def __init__(self):
        self.disputes: Dict[str, EnhancedDispute] = {}
        self.investigator = AIInvestigator()
        self.judge = AIJudge()
    
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
        
        # Generate initial review
        review_prompt = f"""You are beginning the investigation of this dispute:

Title: {dispute.title}
Description: {dispute.description}
Participants: {[p['name'] + ' (' + p['role'] + ')' for p in dispute.participants]}

Provide an initial review that outlines:
1. Key issues to investigate
2. Questions to ask each party
3. Evidence to look for
4. Timeline for investigation
5. Approach for fair and thorough fact-finding

This review helps set the stage for private investigations with each party."""
        
        initial_review = await self.investigator._generate_ai_response(review_prompt)
        
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

# Global manager instance
dispute_manager = EnhancedDisputeManager()