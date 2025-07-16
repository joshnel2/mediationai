#!/usr/bin/env python3
"""
MediationAI Demo Script
This script demonstrates the AI-powered dispute resolution system with mock responses
Perfect for testing the iOS app integration without requiring API keys
"""

import os
import sys
import json
import time
from datetime import datetime, timedelta

# Mock responses for different mediation scenarios
MOCK_MEDIATION_RESPONSES = {
    "mediator_opening": """
    Welcome to the AI-powered mediation session. I'm here to help both parties work together 
    toward a fair resolution of your dispute.
    
    Ground Rules:
    • Please be respectful and constructive in all communications
    • Focus on your interests and needs, not just your positions
    • Listen actively to understand the other party's perspective
    • Work together to find mutually acceptable solutions
    
    Let's begin by having each party share their perspective on the dispute. 
    What are your main concerns and what would you like to see as an outcome?
    """,
    
    "mediator_facilitation": """
    I can see both parties have valid concerns. Let me help identify some common ground:
    
    Areas of Agreement:
    • Both parties want a fair resolution
    • There seems to be some miscommunication about expectations
    • Both parties invested time and effort in this relationship
    
    Let's explore some questions:
    1. What would an ideal resolution look like for each of you?
    2. Are there creative solutions that could benefit both parties?
    3. How can we prevent similar misunderstandings in the future?
    
    I encourage you to consider compromise solutions that address both parties' core needs.
    """,
    
    "arbitrator_decision": """
    ARBITRATION DECISION
    
    After careful review of all evidence and arguments presented, I render the following decision:
    
    FINDINGS:
    • Both parties entered into an agreement with specific terms
    • There were communication issues that led to misunderstandings
    • Both parties bear some responsibility for the dispute
    • The complainant has suffered some damages
    • The respondent made efforts to address concerns
    
    DECISION:
    • The respondent is found to be in partial breach of the agreement
    • Damages are awarded at 60% of the claimed amount
    • Both parties must implement better communication protocols
    • Future disputes should be resolved through mediation first
    
    MONETARY AWARD: $1,800 to be paid within 30 days
    
    This decision is final and binding on both parties.
    """,
    
    "sentiment_analysis": {
        "positive_indicators": ["thank you", "appreciate", "understand", "agree", "willing", "compromise"],
        "negative_indicators": ["unfair", "ridiculous", "never", "impossible", "waste", "stupid"],
        "neutral_indicators": ["however", "but", "although", "consider", "perhaps", "maybe"]
    }
}

def setup_mock_environment():
    """Setup environment for demo mode"""
    os.environ['OPENAI_API_KEY'] = 'demo-key'
    os.environ['ANTHROPIC_API_KEY'] = 'demo-key'
    os.environ['DEBUG'] = 'True'
    os.environ['DEMO_MODE'] = 'True'
    print("🎭 Demo environment configured")

def create_mock_mediation_agents():
    """Create mock mediation agents file"""
    mock_agents_content = '''
import asyncio
import json
from typing import Dict, Any, List, Optional
from datetime import datetime, timedelta
from dispute_models import *

# Mock responses
MOCK_RESPONSES = ''' + json.dumps(MOCK_MEDIATION_RESPONSES, indent=4) + '''

class MockMediationAgent:
    def __init__(self, name: str, agent_type: str):
        self.name = name
        self.agent_type = agent_type
    
    async def generate_response(self, prompt: str, context: str = None, dispute_data: Dict = None) -> str:
        await asyncio.sleep(0.5)  # Simulate thinking time
        return f"[DEMO {self.agent_type.upper()}] {prompt[:50]}..."

class MockMediatorAgent(MockMediationAgent):
    def __init__(self):
        super().__init__("AI Mediator", "mediator")
    
    async def initiate_mediation(self, dispute: Dispute) -> str:
        await asyncio.sleep(1)
        return MOCK_RESPONSES["mediator_opening"]
    
    async def facilitate_discussion(self, dispute: Dispute, recent_messages: List[MediationMessage]) -> str:
        await asyncio.sleep(0.8)
        return MOCK_RESPONSES["mediator_facilitation"]
    
    async def suggest_resolution(self, dispute: Dispute) -> ResolutionProposal:
        await asyncio.sleep(1.5)
        
        # Analyze dispute to create relevant proposal
        if "website" in dispute.description.lower() or "development" in dispute.description.lower():
            resolution_type = ResolutionType.COMPROMISE
            title = "Website Development Resolution"
            description = "Mediated resolution for website development dispute"
            terms = [
                "Contractor completes remaining website work within 2 weeks",
                "Client pays 70% of remaining amount ($1,400)",
                "Both parties agree to clearer communication protocols",
                "Future change requests require written approval"
            ]
        else:
            resolution_type = ResolutionType.COMPROMISE
            title = "Mediated Resolution Agreement"
            description = "Fair resolution addressing both parties' concerns"
            terms = [
                "Both parties agree to compromise solution",
                "Implementation timeline: 30 days",
                "Regular check-ins to ensure compliance"
            ]
        
        return ResolutionProposal(
            dispute_id=dispute.id,
            proposed_by="ai_mediator",
            resolution_type=resolution_type,
            title=title,
            description=description,
            terms=terms,
            deadline=datetime.now() + timedelta(days=14)
        )

class MockArbitratorAgent(MockMediationAgent):
    def __init__(self):
        super().__init__("AI Arbitrator", "arbitrator")
    
    async def render_arbitration_decision(self, dispute: Dispute) -> ResolutionProposal:
        await asyncio.sleep(2)
        
        # Determine monetary amount based on dispute
        monetary_amount = 1800.0  # Default
        if "3000" in dispute.description or "$3,000" in dispute.description:
            monetary_amount = 1800.0  # 60% of $3,000
        elif "5000" in dispute.description or "$5,000" in dispute.description:
            monetary_amount = 3000.0  # 60% of $5,000
        
        return ResolutionProposal(
            dispute_id=dispute.id,
            proposed_by="ai_arbitrator",
            resolution_type=ResolutionType.MONETARY,
            title="Arbitration Decision",
            description=MOCK_RESPONSES["arbitrator_decision"],
            terms=[
                f"Monetary award: ${monetary_amount:,.2f}",
                "Payment due within 30 days",
                "Decision is final and binding"
            ],
            monetary_amount=monetary_amount,
            is_final=True,
            deadline=datetime.now() + timedelta(days=30)
        )

class MockFacilitatorAgent(MockMediationAgent):
    def __init__(self):
        super().__init__("AI Facilitator", "facilitator")
    
    async def guide_next_steps(self, dispute: Dispute) -> Dict[str, Any]:
        await asyncio.sleep(0.7)
        
        # Determine next steps based on dispute status
        if dispute.status == DisputeStatus.CREATED:
            guidance = "Add more parties and evidence before starting mediation"
            actions = ["Invite respondent to join", "Submit relevant evidence", "Review dispute details"]
        elif dispute.status == DisputeStatus.EVIDENCE_SUBMISSION:
            guidance = "Ready to begin mediation process"
            actions = ["Start AI mediation", "Review all evidence", "Set mediation tone"]
        elif dispute.status == DisputeStatus.MEDIATION_IN_PROGRESS:
            guidance = "Mediation is ongoing - encourage productive dialogue"
            actions = ["Continue discussion", "Consider compromise", "Ask clarifying questions"]
        else:
            guidance = "Consider next steps based on current status"
            actions = ["Review progress", "Adjust approach", "Consider escalation"]
        
        return {
            "guidance": guidance,
            "recommended_actions": actions,
            "timeline": "2-3 days for next milestone",
            "escalation_needed": len(dispute.messages) > 20
        }

class MockAnalystAgent(MockMediationAgent):
    def __init__(self):
        super().__init__("AI Analyst", "analyst")
    
    async def analyze_dispute(self, dispute: Dispute) -> MediationAnalytics:
        await asyncio.sleep(1)
        
        # Simple sentiment analysis
        sentiment_score = self._analyze_sentiment(dispute.messages)
        
        # Mock escalation risk
        escalation_risk = min(0.8, len(dispute.messages) * 0.05)
        
        # Mock resolution probability
        resolution_probability = max(0.3, 1.0 - (len(dispute.messages) * 0.02))
        
        return MediationAnalytics(
            dispute_id=dispute.id,
            total_messages=len(dispute.messages),
            evidence_count=len(dispute.evidence),
            resolution_time_hours=None,
            ai_interventions=len([m for m in dispute.messages if m.sender_type.startswith('ai_')]),
            sentiment_score=sentiment_score,
            escalation_risk=escalation_risk,
            resolution_probability=resolution_probability
        )
    
    def _analyze_sentiment(self, messages: List[MediationMessage]) -> float:
        """Simple sentiment analysis"""
        if not messages:
            return 0.0
        
        positive_count = 0
        negative_count = 0
        
        for message in messages[-10:]:  # Last 10 messages
            content = message.content.lower()
            
            for indicator in MOCK_RESPONSES["sentiment_analysis"]["positive_indicators"]:
                if indicator in content:
                    positive_count += 1
            
            for indicator in MOCK_RESPONSES["sentiment_analysis"]["negative_indicators"]:
                if indicator in content:
                    negative_count += 1
        
        if positive_count + negative_count == 0:
            return 0.0
        
        return (positive_count - negative_count) / (positive_count + negative_count)

class MockMediationOrchestrator:
    def __init__(self):
        self.mediator = MockMediatorAgent()
        self.arbitrator = MockArbitratorAgent()
        self.facilitator = MockFacilitatorAgent()
        self.analyst = MockAnalystAgent()
    
    async def handle_dispute_message(self, dispute: Dispute, message: MediationMessage) -> Optional[MediationMessage]:
        # Simulate AI intervention logic
        if len(dispute.messages) % 3 == 0:  # Intervene every 3 messages
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
        opening_statement = await self.mediator.initiate_mediation(dispute)
        
        return MediationMessage(
            dispute_id=dispute.id,
            sender_id="ai_mediator",
            sender_type="ai_mediator",
            content=opening_statement,
            message_type="mediation"
        )
    
    async def escalate_to_arbitration(self, dispute: Dispute) -> ResolutionProposal:
        return await self.arbitrator.render_arbitration_decision(dispute)
    
    async def get_process_guidance(self, dispute: Dispute) -> Dict[str, Any]:
        return await self.facilitator.guide_next_steps(dispute)

# Global instance
mediation_orchestrator = MockMediationOrchestrator()
'''
    
    with open('mock_mediation_agents.py', 'w') as f:
        f.write(mock_agents_content)
    
    print("✅ Mock mediation agents created")

def patch_api_for_demo():
    """Patch the API to use mock agents"""
    try:
        with open('mediation_api.py', 'r') as f:
            content = f.read()
        
        # Replace the import
        content = content.replace(
            'from mediation_agents import mediation_orchestrator',
            '''
if os.getenv('DEMO_MODE') == 'True':
    from mock_mediation_agents import mediation_orchestrator
else:
    from mediation_agents import mediation_orchestrator
'''
        )
        
        with open('mediation_api.py', 'w') as f:
            f.write(content)
        
        print("✅ API patched for demo mode")
        
    except Exception as e:
        print(f"❌ Error patching API: {e}")

def run_demo():
    """Run the demo server"""
    print("🚀 Starting MediationAI Demo Server...")
    print("=" * 60)
    
    try:
        import uvicorn
        from mediation_api import app
        
        print("📱 MediationAI backend running at: http://localhost:8000")
        print("🎯 Perfect for testing your iOS app integration!")
        print("📚 API documentation at: http://localhost:8000/docs")
        print("⏹️  Press Ctrl+C to stop")
        print("=" * 60)
        
        uvicorn.run(app, host="0.0.0.0", port=8000, log_level="info")
        
    except KeyboardInterrupt:
        print("\n🛑 Demo server stopped")
    except Exception as e:
        print(f"❌ Error running demo: {e}")
        print("💡 Make sure dependencies are installed: pip install -r requirements.txt")

def cleanup():
    """Clean up demo files"""
    try:
        if os.path.exists('mock_mediation_agents.py'):
            os.remove('mock_mediation_agents.py')
        print("✅ Demo cleanup completed")
    except:
        pass

def print_demo_info():
    """Print demo information"""
    print("🎭 MediationAI Demo Mode")
    print("=" * 60)
    print("This demo allows you to test the AI mediation system without API keys.")
    print("Perfect for integrating with your iOS MediationAI app!")
    print()
    print("🔧 Features Available:")
    print("• Create and manage disputes")
    print("• AI-powered mediation responses")
    print("• Automatic arbitration decisions")
    print("• Real-time messaging with WebSocket")
    print("• Evidence management")
    print("• User authentication")
    print("• Resolution proposals")
    print()
    print("📱 iOS Integration:")
    print("• Update your app's base URL to: http://localhost:8000/api")
    print("• Test all endpoints with realistic mock responses")
    print("• WebSocket support for real-time updates")
    print("• Sample dispute creation for testing")
    print()
    print("🎯 Test Endpoints:")
    print("• GET /api/health - Health check")
    print("• GET /api/demo/create-sample-dispute - Create test dispute")
    print("• GET /api/docs - API documentation")
    print("=" * 60)

def main():
    """Main demo function"""
    print_demo_info()
    
    # Setup demo environment
    setup_mock_environment()
    
    # Create mock agents
    create_mock_mediation_agents()
    
    # Patch API for demo
    patch_api_for_demo()
    
    try:
        # Run demo server
        run_demo()
    finally:
        # Clean up
        cleanup()

if __name__ == "__main__":
    main()