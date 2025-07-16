import openai
import anthropic
from typing import List, Dict, Any, Optional
from config import settings
from dispute_models import *
import logging
import json
import asyncio
from datetime import datetime, timedelta

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class BaseMediationAgent:
    """Base class for all mediation AI agents"""
    
    def __init__(self, name: str, agent_type: str, model: str = "gpt-4"):
        self.name = name
        self.agent_type = agent_type
        self.model = model
        self.conversation_history = []
        self.openai_client = openai.OpenAI(api_key=settings.openai_api_key) if settings.openai_api_key else None
        self.anthropic_client = anthropic.Anthropic(api_key=settings.anthropic_api_key) if settings.anthropic_api_key else None
    
    async def generate_response(self, prompt: str, context: str = None, dispute_data: Dict = None) -> str:
        """Generate response using AI model"""
        try:
            if self.agent_type == "arbitrator" or "claude" in self.model.lower():
                return await self._generate_claude_response(prompt, context, dispute_data)
            else:
                return await self._generate_openai_response(prompt, context, dispute_data)
        except Exception as e:
            logger.error(f"Error generating response for {self.name}: {str(e)}")
            return f"I apologize, but I'm having trouble processing your request right now. Please try again."
    
    async def _generate_openai_response(self, prompt: str, context: str = None, dispute_data: Dict = None) -> str:
        """Generate response using OpenAI"""
        if not self.openai_client:
            return "OpenAI client not configured"
        
        try:
            messages = [
                {"role": "system", "content": self._get_system_prompt()},
            ]
            
            if context:
                messages.append({"role": "user", "content": f"Context: {context}"})
            
            if dispute_data:
                messages.append({"role": "user", "content": f"Dispute Information: {json.dumps(dispute_data, indent=2)}"})
            
            messages.append({"role": "user", "content": prompt})
            
            response = self.openai_client.chat.completions.create(
                model=self.model,
                messages=messages,
                max_tokens=1000,
                temperature=0.7
            )
            
            return response.choices[0].message.content
            
        except Exception as e:
            logger.error(f"OpenAI API error: {str(e)}")
            return "I apologize, but I'm having trouble processing your request right now."
    
    async def _generate_claude_response(self, prompt: str, context: str = None, dispute_data: Dict = None) -> str:
        """Generate response using Anthropic Claude"""
        if not self.anthropic_client:
            return await self._generate_openai_response(prompt, context, dispute_data)
        
        try:
            full_prompt = self._get_system_prompt() + "\n\n"
            
            if context:
                full_prompt += f"Context: {context}\n\n"
            
            if dispute_data:
                full_prompt += f"Dispute Information: {json.dumps(dispute_data, indent=2)}\n\n"
            
            full_prompt += f"Human: {prompt}\n\nAssistant:"
            
            response = self.anthropic_client.messages.create(
                model="claude-3-sonnet-20240229",
                max_tokens=1000,
                messages=[{"role": "user", "content": full_prompt}]
            )
            
            return response.content[0].text
            
        except Exception as e:
            logger.error(f"Anthropic API error: {str(e)}")
            return await self._generate_openai_response(prompt, context, dispute_data)
    
    def _get_system_prompt(self) -> str:
        """Get system prompt for the agent - to be overridden by subclasses"""
        return f"You are a {self.agent_type} in a dispute resolution system. Be helpful and professional."

class MediatorAgent(BaseMediationAgent):
    """AI agent focused on mediation and finding common ground"""
    
    def __init__(self):
        super().__init__("AI Mediator", "mediator", "gpt-4")
    
    def _get_system_prompt(self) -> str:
        return """You are an experienced AI mediator specializing in dispute resolution. Your role is to:

1. Facilitate productive dialogue between disputing parties
2. Help parties understand each other's perspectives
3. Identify common ground and shared interests
4. Guide parties toward mutually acceptable solutions
5. De-escalate tensions and maintain a constructive atmosphere
6. Suggest compromise solutions when appropriate

Mediation Principles:
- Remain neutral and impartial at all times
- Focus on interests, not positions
- Encourage active listening and empathy
- Reframe negative statements constructively
- Look for win-win solutions
- Maintain confidentiality and respect
- Use collaborative language

Communication Style:
- Be empathetic and understanding
- Use "I" statements and neutral language
- Ask open-ended questions to explore interests
- Acknowledge emotions while focusing on solutions
- Summarize and clarify key points
- Encourage direct communication between parties

Always aim to help parties reach a voluntary agreement that addresses their core needs."""
    
    async def initiate_mediation(self, dispute: Dispute) -> str:
        """Start the mediation process"""
        dispute_summary = {
            "title": dispute.title,
            "description": dispute.description,
            "category": dispute.category,
            "participants": [{"role": p.role, "username": p.username} for p in dispute.participants],
            "evidence_count": len(dispute.evidence)
        }
        
        prompt = f"""Welcome to the mediation session for this dispute. Please provide an opening statement that:

1. Introduces yourself and your role
2. Explains the mediation process
3. Sets ground rules for respectful communication
4. Invites each party to share their perspective
5. Emphasizes the goal of finding a mutually acceptable solution

Make this welcoming and professional, setting a constructive tone for the mediation."""
        
        return await self.generate_response(prompt, dispute_data=dispute_summary)
    
    async def facilitate_discussion(self, dispute: Dispute, recent_messages: List[MediationMessage]) -> str:
        """Facilitate ongoing discussion between parties"""
        # Analyze recent messages for tension, progress, or need for intervention
        messages_summary = []
        for msg in recent_messages[-5:]:  # Last 5 messages
            messages_summary.append({
                "sender_type": msg.sender_type,
                "content": msg.content[:200],
                "timestamp": msg.timestamp.isoformat()
            })
        
        prompt = f"""Based on the recent conversation, please provide mediation guidance that:

1. Acknowledges what has been shared so far
2. Identifies any areas of agreement or common ground
3. Addresses any tensions or misunderstandings
4. Asks clarifying questions to better understand interests
5. Suggests next steps to move toward resolution

Recent conversation: {json.dumps(messages_summary, indent=2)}

Focus on keeping the discussion productive and solution-oriented."""
        
        return await self.generate_response(prompt, context=dispute.description)
    
    async def suggest_resolution(self, dispute: Dispute) -> ResolutionProposal:
        """Suggest a resolution based on the dispute information"""
        dispute_data = {
            "title": dispute.title,
            "description": dispute.description,
            "category": dispute.category,
            "evidence": [{"title": e.title, "type": e.evidence_type, "description": e.description} for e in dispute.evidence],
            "messages": [{"sender_type": m.sender_type, "content": m.content[:100]} for m in dispute.messages[-10:]]
        }
        
        prompt = f"""Based on all the information shared, please suggest a fair resolution that addresses both parties' core interests.

Consider:
1. What each party really needs (not just what they're asking for)
2. Areas where compromise is possible
3. Creative solutions that could benefit both parties
4. Practical steps for implementation
5. How to prevent similar disputes in the future

Provide a specific, actionable proposal that both parties might accept."""
        
        response = await self.generate_response(prompt, dispute_data=dispute_data)
        
        # Parse the response to create a structured proposal
        return self._parse_resolution_proposal(response, dispute.id)
    
    def _parse_resolution_proposal(self, response: str, dispute_id: str) -> ResolutionProposal:
        """Parse AI response into a structured resolution proposal"""
        lines = response.split('\n')
        
        # Extract key information (simplified parsing)
        title = "AI-Mediated Resolution Proposal"
        description = response
        terms = []
        resolution_type = ResolutionType.COMPROMISE
        
        # Look for specific terms or monetary amounts
        for line in lines:
            if line.strip().startswith('-') or line.strip().startswith('•'):
                terms.append(line.strip()[1:].strip())
            elif '$' in line:
                resolution_type = ResolutionType.MONETARY
        
        if not terms:
            terms = ["Both parties agree to the mediated resolution", "Implementation timeline to be determined"]
        
        return ResolutionProposal(
            dispute_id=dispute_id,
            proposed_by="ai_mediator",
            resolution_type=resolution_type,
            title=title,
            description=description,
            terms=terms,
            deadline=datetime.now() + timedelta(days=7)
        )

class ArbitratorAgent(BaseMediationAgent):
    """AI agent for making binding arbitration decisions"""
    
    def __init__(self):
        super().__init__("AI Arbitrator", "arbitrator", "claude-3-sonnet-20240229")
    
    def _get_system_prompt(self) -> str:
        return """You are an experienced AI arbitrator who makes binding decisions in disputes. Your role is to:

1. Analyze all evidence and arguments objectively
2. Apply relevant laws, regulations, and precedents
3. Make fair and reasoned decisions
4. Explain your reasoning clearly and thoroughly
5. Consider the interests of all parties
6. Ensure decisions are practical and enforceable

Arbitration Principles:
- Strict neutrality and impartiality
- Base decisions on facts and applicable law
- Consider precedents and best practices
- Ensure due process for all parties
- Provide clear reasoning for all decisions
- Make decisions that are fair and enforceable
- Consider practical implications

Decision-Making Framework:
1. Review all evidence and arguments
2. Identify key legal and factual issues
3. Apply relevant standards and precedents
4. Consider the credibility of evidence
5. Weigh competing interests fairly
6. Render a clear, final decision
7. Explain reasoning and implementation

Your decisions are final and binding on all parties."""
    
    async def render_arbitration_decision(self, dispute: Dispute) -> ResolutionProposal:
        """Render a binding arbitration decision"""
        dispute_data = {
            "title": dispute.title,
            "description": dispute.description,
            "category": dispute.category,
            "participants": [{"role": p.role, "username": p.username} for p in dispute.participants],
            "evidence": [{"title": e.title, "type": e.evidence_type, "description": e.description, "content": e.content[:200]} for e in dispute.evidence],
            "messages": [{"sender_type": m.sender_type, "content": m.content} for m in dispute.messages],
            "previous_proposals": [{"title": p.title, "terms": p.terms} for p in dispute.proposals]
        }
        
        prompt = f"""As an arbitrator, render a final, binding decision for this dispute.

Your decision should include:
1. Summary of the dispute and key issues
2. Analysis of the evidence presented
3. Applicable standards or precedents
4. Reasoning for your decision
5. Specific terms of resolution
6. Implementation timeline and requirements
7. Any ongoing obligations for the parties

Consider:
- Fairness to all parties
- Practical enforceability
- Prevention of future disputes
- Industry standards and best practices
- Legal principles relevant to this type of dispute

Make a clear, definitive decision that resolves all issues."""
        
        response = await self.generate_response(prompt, dispute_data=dispute_data)
        
        # Create binding resolution proposal
        return ResolutionProposal(
            dispute_id=dispute.id,
            proposed_by="ai_arbitrator",
            resolution_type=self._determine_resolution_type(response),
            title="Arbitration Decision",
            description=response,
            terms=self._extract_terms(response),
            is_final=True,
            deadline=datetime.now() + timedelta(days=30)
        )
    
    def _determine_resolution_type(self, response: str) -> ResolutionType:
        """Determine the type of resolution from the response"""
        response_lower = response.lower()
        
        if '$' in response or 'payment' in response_lower or 'compensation' in response_lower:
            return ResolutionType.MONETARY
        elif 'apology' in response_lower or 'apologize' in response_lower:
            return ResolutionType.APOLOGY
        elif 'action' in response_lower or 'must' in response_lower or 'shall' in response_lower:
            return ResolutionType.ACTION_REQUIRED
        elif 'dismiss' in response_lower or 'rejected' in response_lower:
            return ResolutionType.DISMISSAL
        else:
            return ResolutionType.COMPROMISE
    
    def _extract_terms(self, response: str) -> List[str]:
        """Extract specific terms from the arbitration decision"""
        terms = []
        lines = response.split('\n')
        
        for line in lines:
            line = line.strip()
            if line.startswith('-') or line.startswith('•') or line.startswith('1.') or line.startswith('2.'):
                terms.append(line)
        
        if not terms:
            terms = ["Final arbitration decision as detailed above"]
        
        return terms

class FacilitatorAgent(BaseMediationAgent):
    """AI agent for process facilitation and guidance"""
    
    def __init__(self):
        super().__init__("AI Facilitator", "facilitator", "gpt-4")
    
    def _get_system_prompt(self) -> str:
        return """You are an AI process facilitator who helps guide dispute resolution effectively. Your role is to:

1. Guide parties through the dispute resolution process
2. Suggest appropriate next steps and timelines
3. Help organize information and evidence
4. Ensure all parties have opportunity to be heard
5. Identify when to escalate or change approaches
6. Provide process guidance and best practices

Facilitation Focus:
- Keep discussions on track and productive
- Ensure fair participation from all parties
- Manage timelines and deadlines
- Suggest appropriate tools and techniques
- Help parties prepare for each stage
- Maintain momentum toward resolution

Process Expertise:
- Know when mediation vs arbitration is appropriate
- Understand evidence gathering and presentation
- Guide effective communication strategies
- Recognize when intervention is needed
- Suggest procedural improvements
- Help parties understand options and consequences

Always focus on improving the process to achieve better outcomes."""
    
    async def guide_next_steps(self, dispute: Dispute) -> Dict[str, Any]:
        """Provide guidance on next steps in the dispute resolution process"""
        dispute_summary = {
            "status": dispute.status,
            "participants": len(dispute.participants),
            "evidence_count": len(dispute.evidence),
            "messages_count": len(dispute.messages),
            "proposals_count": len(dispute.proposals),
            "days_since_created": (datetime.now() - dispute.created_at).days
        }
        
        prompt = f"""Based on the current dispute status, provide guidance on next steps:

Current situation: {json.dumps(dispute_summary, indent=2)}

Please provide:
1. Assessment of current progress
2. Specific next steps recommended
3. Timeline for completion
4. Any potential obstacles or concerns
5. Alternative approaches if current method isn't working
6. Resources or tools that might help

Focus on actionable guidance that moves the dispute toward resolution."""
        
        response = await self.generate_response(prompt, context=dispute.description)
        
        return {
            "guidance": response,
            "recommended_actions": self._extract_actions(response),
            "timeline": self._extract_timeline(response),
            "escalation_needed": self._assess_escalation(dispute)
        }
    
    def _extract_actions(self, response: str) -> List[str]:
        """Extract specific actions from the guidance"""
        actions = []
        lines = response.split('\n')
        
        for line in lines:
            line = line.strip()
            if any(word in line.lower() for word in ['should', 'need to', 'must', 'recommend', 'suggest']):
                actions.append(line)
        
        return actions[:5]  # Top 5 actions
    
    def _extract_timeline(self, response: str) -> Optional[str]:
        """Extract timeline information from the guidance"""
        timeline_keywords = ['days', 'weeks', 'hours', 'deadline', 'by']
        lines = response.split('\n')
        
        for line in lines:
            if any(keyword in line.lower() for keyword in timeline_keywords):
                return line.strip()
        
        return None
    
    def _assess_escalation(self, dispute: Dispute) -> bool:
        """Assess if the dispute needs escalation"""
        # Simple heuristics for escalation
        days_active = (datetime.now() - dispute.created_at).days
        message_count = len(dispute.messages)
        
        if days_active > 14 and message_count > 50:  # Long-running with many messages
            return True
        
        if len(dispute.proposals) > 3 and not any(p.accepted_by for p in dispute.proposals):  # Multiple rejected proposals
            return True
        
        return False

class AnalystAgent(BaseMediationAgent):
    """AI agent for dispute analysis and insights"""
    
    def __init__(self):
        super().__init__("AI Analyst", "analyst", "gpt-4")
    
    def _get_system_prompt(self) -> str:
        return """You are an AI analyst specializing in dispute resolution analytics. Your role is to:

1. Analyze dispute patterns and trends
2. Assess sentiment and emotional dynamics
3. Predict resolution likelihood and outcomes
4. Identify risk factors and escalation triggers
5. Provide strategic insights and recommendations
6. Generate reports and summaries

Analysis Areas:
- Communication patterns and sentiment
- Evidence strength and credibility
- Negotiation dynamics and positioning
- Resolution probability and timelines
- Risk assessment and escalation factors
- Success factors and best practices

Analytical Approach:
- Use data-driven insights
- Identify patterns and correlations
- Assess probability and likelihood
- Provide quantitative metrics where possible
- Offer strategic recommendations
- Maintain objectivity and neutrality

Focus on actionable insights that improve dispute resolution outcomes."""
    
    async def analyze_dispute(self, dispute: Dispute) -> MediationAnalytics:
        """Perform comprehensive dispute analysis"""
        # Analyze message sentiment
        sentiment_score = await self._analyze_sentiment(dispute.messages)
        
        # Assess escalation risk
        escalation_risk = self._assess_escalation_risk(dispute)
        
        # Predict resolution probability
        resolution_probability = self._predict_resolution_probability(dispute)
        
        # Count AI interventions
        ai_interventions = len([m for m in dispute.messages if m.sender_type.startswith('ai_')])
        
        # Calculate resolution time if resolved
        resolution_time = None
        if dispute.status == DisputeStatus.RESOLVED:
            resolution_time = (dispute.updated_at - dispute.created_at).total_seconds() / 3600
        
        return MediationAnalytics(
            dispute_id=dispute.id,
            total_messages=len(dispute.messages),
            evidence_count=len(dispute.evidence),
            resolution_time_hours=resolution_time,
            ai_interventions=ai_interventions,
            sentiment_score=sentiment_score,
            escalation_risk=escalation_risk,
            resolution_probability=resolution_probability
        )
    
    async def _analyze_sentiment(self, messages: List[MediationMessage]) -> float:
        """Analyze overall sentiment of the conversation"""
        if not messages:
            return 0.0
        
        # Use AI to analyze sentiment
        recent_messages = [m.content for m in messages[-10:] if m.sender_type == "user"]
        
        if not recent_messages:
            return 0.0
        
        prompt = f"""Analyze the sentiment of these messages from a dispute resolution context:

Messages: {json.dumps(recent_messages, indent=2)}

Rate the overall sentiment from -1 (very negative/hostile) to +1 (very positive/collaborative).
Consider:
- Tone and language used
- Willingness to compromise
- Respect for other parties
- Progress toward resolution

Provide just a single number between -1 and +1."""
        
        try:
            response = await self.generate_response(prompt)
            # Extract number from response
            import re
            numbers = re.findall(r'-?\d*\.?\d+', response)
            if numbers:
                score = float(numbers[0])
                return max(-1, min(1, score))  # Clamp between -1 and 1
        except:
            pass
        
        return 0.0
    
    def _assess_escalation_risk(self, dispute: Dispute) -> float:
        """Assess risk of escalation (0-1 scale)"""
        risk_factors = 0
        total_factors = 5
        
        # Time factor
        days_active = (datetime.now() - dispute.created_at).days
        if days_active > 14:
            risk_factors += 1
        
        # Communication factor
        if len(dispute.messages) > 50:
            risk_factors += 1
        
        # Proposal rejection factor
        rejected_proposals = sum(1 for p in dispute.proposals if p.rejected_by)
        if rejected_proposals > 2:
            risk_factors += 1
        
        # Evidence complexity factor
        if len(dispute.evidence) > 10:
            risk_factors += 1
        
        # Category factor (some categories are more contentious)
        contentious_categories = ['contract', 'property', 'relationship']
        if dispute.category in contentious_categories:
            risk_factors += 1
        
        return risk_factors / total_factors
    
    def _predict_resolution_probability(self, dispute: Dispute) -> float:
        """Predict likelihood of successful resolution"""
        positive_factors = 0
        total_factors = 6
        
        # Participation factor
        if len(dispute.participants) == 2:  # Ideal number
            positive_factors += 1
        
        # Evidence factor
        if 2 <= len(dispute.evidence) <= 8:  # Reasonable amount
            positive_factors += 1
        
        # Proposal factor
        if dispute.proposals:
            positive_factors += 1
        
        # AI mediation factor
        ai_messages = [m for m in dispute.messages if m.sender_type.startswith('ai_')]
        if ai_messages:
            positive_factors += 1
        
        # Timeline factor
        days_active = (datetime.now() - dispute.created_at).days
        if days_active <= 21:  # Not too long
            positive_factors += 1
        
        # Status factor
        if dispute.status in [DisputeStatus.MEDIATION_IN_PROGRESS, DisputeStatus.RESOLUTION_PROPOSED]:
            positive_factors += 1
        
        return positive_factors / total_factors

class MediationOrchestrator:
    """Orchestrates interactions between mediation agents"""
    
    def __init__(self):
        self.mediator = MediatorAgent()
        self.arbitrator = ArbitratorAgent()
        self.facilitator = FacilitatorAgent()
        self.analyst = AnalystAgent()
    
    async def handle_dispute_message(self, dispute: Dispute, message: MediationMessage) -> Optional[MediationMessage]:
        """Handle a new message in the dispute and determine if AI intervention is needed"""
        # Analyze if AI intervention is needed
        analytics = await self.analyst.analyze_dispute(dispute)
        
        # Determine if mediation is needed
        if self._should_mediate(dispute, analytics):
            # Get mediation response
            mediation_response = await self.mediator.facilitate_discussion(dispute, [message])
            
            return MediationMessage(
                dispute_id=dispute.id,
                sender_id="ai_mediator",
                sender_type="ai_mediator",
                content=mediation_response,
                message_type="mediation"
            )
        
        return None
    
    async def initiate_mediation(self, dispute: Dispute) -> MediationMessage:
        """Start formal mediation process"""
        opening_statement = await self.mediator.initiate_mediation(dispute)
        
        return MediationMessage(
            dispute_id=dispute.id,
            sender_id="ai_mediator",
            sender_type="ai_mediator",
            content=opening_statement,
            message_type="mediation"
        )
    
    async def escalate_to_arbitration(self, dispute: Dispute) -> ResolutionProposal:
        """Escalate dispute to arbitration"""
        return await self.arbitrator.render_arbitration_decision(dispute)
    
    async def get_process_guidance(self, dispute: Dispute) -> Dict[str, Any]:
        """Get guidance on dispute resolution process"""
        return await self.facilitator.guide_next_steps(dispute)
    
    def _should_mediate(self, dispute: Dispute, analytics: MediationAnalytics) -> bool:
        """Determine if AI mediation intervention is needed"""
        # Recent messages from users
        recent_user_messages = [m for m in dispute.messages[-5:] if m.sender_type == "user"]
        
        # No recent AI mediation
        recent_ai_messages = [m for m in dispute.messages[-3:] if m.sender_type == "ai_mediator"]
        
        # Conditions for mediation
        if len(recent_user_messages) >= 3 and not recent_ai_messages:
            return True
        
        if analytics.sentiment_score < -0.3:  # Negative sentiment
            return True
        
        if analytics.escalation_risk > 0.6:  # High escalation risk
            return True
        
        return False

# Global orchestrator instance
mediation_orchestrator = MediationOrchestrator()