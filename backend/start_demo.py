#!/usr/bin/env python3
"""
Demo startup script for the AI Legal Decision-Making System
This script allows you to test the system without API keys (with mock responses)
"""

import os
import sys
import json
import time
from datetime import datetime, timedelta

# Mock API responses for demo mode
MOCK_RESPONSES = {
    "prosecutor_opening": """
    Your Honor, we will demonstrate that the defendant, Sarah Johnson, materially breached the service agreement 
    dated January 1, 2024. The evidence will show that Ms. Johnson failed to deliver the promised marketing 
    campaign within the contractually agreed 60-day timeframe, causing significant damages to the plaintiff's 
    business operations.
    
    Key facts we will prove:
    1. A valid contract existed between the parties
    2. The defendant failed to perform within the agreed timeframe
    3. The plaintiff suffered damages as a result of this breach
    4. The defendant's excuses do not constitute valid legal justification
    
    We ask the court to find in favor of the plaintiff and award appropriate damages.
    """,
    
    "defense_strategy": """
    Your Honor, the defense will show that any delay in performance was directly caused by the plaintiff's 
    failure to provide timely payments as required under the contract. The evidence will demonstrate that 
    Mr. Smith materially breached the payment terms, excusing any performance delays on our client's part.
    
    Our defense strategy includes:
    1. Proving the plaintiff's material breach of payment obligations
    2. Demonstrating that our client's performance was substantially complete
    3. Showing that any delays were caused by the plaintiff's own actions
    4. Establishing that the defendant is entitled to full compensation
    
    We request the court dismiss the plaintiff's claims and award judgment in favor of the defendant.
    """,
    
    "evidence_analysis": """
    This evidence supports the prosecution's case by clearly establishing the contractual obligations 
    and demonstrating the defendant's failure to meet the agreed timeline. The contract language is 
    unambiguous regarding the 60-day performance requirement.
    
    However, we must consider potential weaknesses:
    1. The payment schedule may create reciprocal obligations
    2. Client revisions could constitute changed circumstances
    3. The force majeure clause may be relevant
    
    This evidence should be presented alongside the payment records to establish the full timeline 
    of events and each party's performance under the contract.
    """,
    
    "cross_examination": [
        "Isn't it true that you received only 50% of the agreed payment before beginning work?",
        "Can you explain why you didn't notify the client about potential delays until February 15th?",
        "Did you consider the client's revision requests to be outside the original scope of work?",
        "How many hours did you actually work on this project before claiming delays?",
        "Did you have other client projects that may have interfered with this timeline?"
    ],
    
    "judge_verdict": """
    VERDICT AND JUDGMENT

    After careful consideration of all evidence presented, the testimony of the parties, and applicable law, 
    this court renders the following decision:

    FINDINGS OF FACT:
    1. A valid contract existed between the parties dated January 1, 2024
    2. The defendant failed to complete performance within the agreed 60-day timeframe
    3. The plaintiff made only partial payment before requesting performance
    4. Both parties bear some responsibility for the contractual breakdown

    CONCLUSIONS OF LAW:
    Under contract law principles, both parties committed material breaches of their obligations. 
    However, the defendant's failure to complete performance within the specified timeframe constitutes 
    the more significant breach.

    VERDICT: In favor of the plaintiff, with damages reduced by 30% due to plaintiff's contributory breach.

    CONFIDENCE SCORE: 78%

    The court orders judgment in favor of the plaintiff in the amount of $3,500, representing 70% of the 
    contract value, less any amounts already paid.
    """
}

def setup_mock_environment():
    """Setup mock environment variables"""
    os.environ['OPENAI_API_KEY'] = 'mock-key'
    os.environ['ANTHROPIC_API_KEY'] = 'mock-key'
    os.environ['DEBUG'] = 'True'
    os.environ['DEMO_MODE'] = 'True'

def create_mock_legal_agents():
    """Create mock legal agents that return predefined responses"""
    mock_agents_content = '''
import asyncio
from typing import Dict, Any, List
from models import MessageRole, ConversationMessage, LegalCase, Evidence, VerdictType, DecisionFactor, Verdict

# Mock responses for demo mode
MOCK_RESPONSES = ''' + json.dumps(MOCK_RESPONSES, indent=4) + '''

class MockAgent:
    def __init__(self, name: str, role: MessageRole):
        self.name = name
        self.role = role
    
    async def generate_response(self, prompt: str, context: str = None, case_data: Dict = None) -> str:
        await asyncio.sleep(0.5)  # Simulate API delay
        return f"[MOCK {self.role.value.upper()}] This is a simulated response to: {prompt[:100]}..."

class MockProsecutorAgent(MockAgent):
    def __init__(self):
        super().__init__("Prosecutor", MessageRole.PROSECUTOR)
    
    async def present_opening_argument(self, case: LegalCase) -> str:
        await asyncio.sleep(1)
        return MOCK_RESPONSES["prosecutor_opening"]
    
    async def analyze_evidence(self, evidence: Evidence, case_context: str) -> str:
        await asyncio.sleep(0.8)
        return MOCK_RESPONSES["evidence_analysis"]

class MockDefenseAgent(MockAgent):
    def __init__(self):
        super().__init__("Defense Attorney", MessageRole.DEFENSE)
    
    async def present_defense_strategy(self, case: LegalCase) -> str:
        await asyncio.sleep(1)
        return MOCK_RESPONSES["defense_strategy"]
    
    async def cross_examine_evidence(self, evidence: Evidence, prosecution_argument: str) -> str:
        await asyncio.sleep(0.8)
        return "The defense challenges this evidence on multiple grounds: chain of custody, relevance, and potential bias in collection methods."

class MockCrossExaminerAgent(MockAgent):
    def __init__(self):
        super().__init__("Cross-Examiner", MessageRole.CROSS_EXAMINER)
    
    async def generate_cross_examination_questions(self, target_party: str, context: str, evidence: List[Evidence]) -> List[str]:
        await asyncio.sleep(1)
        return MOCK_RESPONSES["cross_examination"]

class MockJudgeAgent(MockAgent):
    def __init__(self):
        super().__init__("Judge", MessageRole.JUDGE)
    
    async def render_final_verdict(self, case: LegalCase) -> Verdict:
        await asyncio.sleep(2)
        
        decision_factors = [
            DecisionFactor(
                factor="Evidence Analysis",
                weight=0.4,
                reasoning="Comprehensive analysis of all submitted evidence",
                supporting_evidence=[]
            ),
            DecisionFactor(
                factor="Legal Precedents",
                weight=0.3,
                reasoning="Application of relevant contract law principles",
                supporting_evidence=[]
            ),
            DecisionFactor(
                factor="Witness Credibility",
                weight=0.2,
                reasoning="Assessment of party testimony and reliability",
                supporting_evidence=[]
            ),
            DecisionFactor(
                factor="Procedural Compliance",
                weight=0.1,
                reasoning="Adherence to legal procedures and due process",
                supporting_evidence=[]
            )
        ]
        
        return Verdict(
            case_id=case.id,
            verdict_type=VerdictType.LIABLE,
            confidence_score=0.78,
            reasoning=MOCK_RESPONSES["judge_verdict"],
            decision_factors=decision_factors,
            legal_precedents=["Smith v. Jones (2020)", "Contract Corp v. Breach Ltd (2019)"]
        )

class MockLegalAgentsOrchestrator:
    def __init__(self):
        self.prosecutor = MockProsecutorAgent()
        self.defense = MockDefenseAgent()
        self.cross_examiner = MockCrossExaminerAgent()
        self.judge = MockJudgeAgent()
    
    async def conduct_case_proceedings(self, case: LegalCase) -> LegalCase:
        # Simulate legal proceedings with delays
        print("🎭 DEMO MODE: Simulating legal proceedings...")
        
        # Opening arguments
        prosecutor_opening = await self.prosecutor.present_opening_argument(case)
        case.add_message(ConversationMessage(
            role=MessageRole.PROSECUTOR,
            content=prosecutor_opening,
            case_id=case.id
        ))
        
        defense_strategy = await self.defense.present_defense_strategy(case)
        case.add_message(ConversationMessage(
            role=MessageRole.DEFENSE,
            content=defense_strategy,
            case_id=case.id
        ))
        
        # Evidence analysis
        for evidence in case.evidence:
            prosecutor_analysis = await self.prosecutor.analyze_evidence(evidence, case.description)
            case.add_message(ConversationMessage(
                role=MessageRole.PROSECUTOR,
                content=f"Evidence Analysis - {evidence.title}: {prosecutor_analysis}",
                case_id=case.id
            ))
            
            defense_analysis = await self.defense.cross_examine_evidence(evidence, prosecutor_analysis)
            case.add_message(ConversationMessage(
                role=MessageRole.DEFENSE,
                content=f"Defense Response - {evidence.title}: {defense_analysis}",
                case_id=case.id
            ))
        
        # Cross-examination
        if len(case.parties) > 1:
            questions = await self.cross_examiner.generate_cross_examination_questions(
                case.parties[0].name,
                case.description,
                case.evidence
            )
            
            cross_exam_content = "Cross-Examination Questions:\\n" + "\\n".join(f"{i+1}. {q}" for i, q in enumerate(questions))
            case.add_message(ConversationMessage(
                role=MessageRole.CROSS_EXAMINER,
                content=cross_exam_content,
                case_id=case.id
            ))
        
        # Final verdict
        verdict = await self.judge.render_final_verdict(case)
        case.verdict = verdict
        case.add_message(ConversationMessage(
            role=MessageRole.JUDGE,
            content=f"FINAL VERDICT: {verdict.reasoning}",
            case_id=case.id
        ))
        
        from models import CaseStatus
        case.status = CaseStatus.VERDICT_RENDERED
        
        return case

# Global instance
legal_agents = MockLegalAgentsOrchestrator()
'''
    
    # Write mock agents file
    with open('mock_legal_agents.py', 'w') as f:
        f.write(mock_agents_content)

def patch_main_for_demo():
    """Patch the main.py to use mock agents in demo mode"""
    with open('main.py', 'r') as f:
        content = f.read()
    
    # Replace the import statement
    content = content.replace(
        'from legal_agents import legal_agents',
        '''
if os.getenv('DEMO_MODE') == 'True':
    from mock_legal_agents import legal_agents
else:
    from legal_agents import legal_agents
'''
    )
    
    # Write back
    with open('main.py', 'w') as f:
        f.write(content)

def main():
    """Main demo function"""
    print("🎭 AI Legal Decision-Making System - DEMO MODE")
    print("=" * 60)
    print("This demo mode allows you to test the system without API keys.")
    print("All AI responses are simulated with realistic legal content.")
    print("=" * 60)
    
    # Setup mock environment
    setup_mock_environment()
    
    # Create mock agents
    create_mock_legal_agents()
    
    # Import and patch
    patch_main_for_demo()
    
    print("🔧 Demo environment configured successfully!")
    print("📱 Starting demo server...")
    print("🌐 Application will be available at: http://localhost:8000")
    print("⏹️  Press Ctrl+C to stop the demo")
    print("=" * 60)
    
    try:
        # Import and run the main application
        import uvicorn
        from main import app
        
        uvicorn.run(app, host="0.0.0.0", port=8000, log_level="info")
        
    except KeyboardInterrupt:
        print("\\n🛑 Demo stopped by user")
    except Exception as e:
        print(f"❌ Error running demo: {e}")
        print("💡 Make sure you have installed the requirements: pip install -r requirements.txt")
    finally:
        # Cleanup
        if os.path.exists('mock_legal_agents.py'):
            os.remove('mock_legal_agents.py')
        print("✅ Demo cleanup completed")

if __name__ == "__main__":
    main()