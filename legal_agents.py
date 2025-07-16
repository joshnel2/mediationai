import openai
import anthropic
from typing import List, Dict, Any, Optional
from config import settings
from models import MessageRole, ConversationMessage, LegalCase, Evidence, VerdictType, DecisionFactor, Verdict
from legal_database import legal_research_engine
import logging
import json
import asyncio

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class BaseAgent:
    """Base class for all legal AI agents"""
    
    def __init__(self, name: str, role: MessageRole, model: str = "gpt-4"):
        self.name = name
        self.role = role
        self.model = model
        self.conversation_history = []
        self.openai_client = openai.OpenAI(api_key=settings.openai_api_key) if settings.openai_api_key else None
        self.anthropic_client = anthropic.Anthropic(api_key=settings.anthropic_api_key) if settings.anthropic_api_key else None
    
    def add_to_history(self, message: ConversationMessage):
        """Add message to conversation history"""
        self.conversation_history.append(message)
    
    def clear_history(self):
        """Clear conversation history"""
        self.conversation_history = []
    
    async def generate_response(self, prompt: str, context: str = None, case_data: Dict = None) -> str:
        """Generate response using AI model"""
        try:
            # Use Claude for complex legal reasoning, GPT for general responses
            if self.role == MessageRole.JUDGE or "claude" in self.model.lower():
                return await self._generate_claude_response(prompt, context, case_data)
            else:
                return await self._generate_openai_response(prompt, context, case_data)
        except Exception as e:
            logger.error(f"Error generating response for {self.name}: {str(e)}")
            return f"I apologize, but I encountered an error while processing your request. Please try again."
    
    async def _generate_openai_response(self, prompt: str, context: str = None, case_data: Dict = None) -> str:
        """Generate response using OpenAI"""
        if not self.openai_client:
            return "OpenAI client not configured"
        
        try:
            messages = [
                {"role": "system", "content": self._get_system_prompt()},
            ]
            
            if context:
                messages.append({"role": "user", "content": f"Context: {context}"})
            
            if case_data:
                messages.append({"role": "user", "content": f"Case Information: {json.dumps(case_data, indent=2)}"})
            
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
    
    async def _generate_claude_response(self, prompt: str, context: str = None, case_data: Dict = None) -> str:
        """Generate response using Anthropic Claude"""
        if not self.anthropic_client:
            return await self._generate_openai_response(prompt, context, case_data)
        
        try:
            full_prompt = self._get_system_prompt() + "\n\n"
            
            if context:
                full_prompt += f"Context: {context}\n\n"
            
            if case_data:
                full_prompt += f"Case Information: {json.dumps(case_data, indent=2)}\n\n"
            
            full_prompt += f"Human: {prompt}\n\nAssistant:"
            
            response = self.anthropic_client.messages.create(
                model="claude-3-sonnet-20240229",
                max_tokens=1000,
                messages=[{"role": "user", "content": full_prompt}]
            )
            
            return response.content[0].text
            
        except Exception as e:
            logger.error(f"Anthropic API error: {str(e)}")
            return await self._generate_openai_response(prompt, context, case_data)
    
    def _get_system_prompt(self) -> str:
        """Get system prompt for the agent - to be overridden by subclasses"""
        return f"You are a {self.role.value} in a legal proceeding. Be professional and thorough."

class ProsecutorAgent(BaseAgent):
    """AI agent acting as a prosecutor"""
    
    def __init__(self):
        super().__init__("Prosecutor", MessageRole.PROSECUTOR, "gpt-4")
    
    def _get_system_prompt(self) -> str:
        return """You are an experienced prosecutor in a legal proceeding. Your role is to:

1. Present arguments supporting the prosecution's case
2. Analyze evidence to build a strong case
3. Cross-examine witnesses and challenge defense arguments
4. Maintain objectivity while advocating for justice
5. Cite relevant legal precedents and statutes
6. Be thorough, professional, and ethical

Always:
- Focus on facts and evidence
- Maintain professional courtroom demeanor
- Support arguments with legal precedents when possible
- Be respectful but firm in cross-examination
- Acknowledge weaknesses in your case when appropriate

Format your responses clearly with numbered points when presenting multiple arguments."""
    
    async def present_opening_argument(self, case: LegalCase) -> str:
        """Present opening argument for the case"""
        case_summary = {
            "title": case.title,
            "description": case.description,
            "parties": [{"name": p.name, "type": p.party_type} for p in case.parties],
            "evidence_count": len(case.evidence),
            "key_evidence": [{"title": e.title, "type": e.evidence_type} for e in case.evidence[:3]]
        }
        
        prompt = f"""Present a compelling opening argument for this case. 
        
        Structure your argument as follows:
        1. Brief case overview
        2. Key facts we will prove
        3. Evidence we will present
        4. Legal theory of our case
        5. What we ask the court to find
        
        Be persuasive but factual."""
        
        return await self.generate_response(prompt, case_data=case_summary)
    
    async def analyze_evidence(self, evidence: Evidence, case_context: str) -> str:
        """Analyze evidence from prosecution perspective"""
        prompt = f"""Analyze this evidence from a prosecution perspective:
        
        Evidence: {evidence.title}
        Type: {evidence.evidence_type}
        Description: {evidence.description}
        Content: {evidence.content}
        
        Case Context: {case_context}
        
        Provide:
        1. How this evidence supports our case
        2. Potential weaknesses or challenges
        3. How to present it effectively
        4. Related legal precedents if applicable"""
        
        return await self.generate_response(prompt)

class DefenseAgent(BaseAgent):
    """AI agent acting as defense attorney"""
    
    def __init__(self):
        super().__init__("Defense Attorney", MessageRole.DEFENSE, "gpt-4")
    
    def _get_system_prompt(self) -> str:
        return """You are an experienced defense attorney in a legal proceeding. Your role is to:

1. Defend your client's interests vigorously but ethically
2. Challenge prosecution evidence and arguments
3. Present alternative theories and interpretations
4. Protect your client's rights throughout the process
5. Cross-examine witnesses to reveal inconsistencies
6. Cite relevant legal precedents and statutes that support your defense

Always:
- Presume innocence and challenge assumptions
- Look for reasonable doubt in criminal cases
- Examine evidence critically for flaws or alternative explanations
- Maintain professional demeanor while being a strong advocate
- Respect the court and opposing counsel
- Focus on protecting your client's constitutional rights

Format your responses clearly with numbered points when presenting multiple arguments."""
    
    async def present_defense_strategy(self, case: LegalCase) -> str:
        """Present defense strategy for the case"""
        case_summary = {
            "title": case.title,
            "description": case.description,
            "parties": [{"name": p.name, "type": p.party_type} for p in case.parties],
            "evidence": [{"title": e.title, "type": e.evidence_type, "description": e.description} for e in case.evidence]
        }
        
        prompt = f"""Develop a comprehensive defense strategy for this case.
        
        Provide:
        1. Key defensive arguments
        2. Challenges to prosecution evidence
        3. Alternative theories or explanations
        4. Constitutional or procedural issues
        5. Witnesses or evidence to support defense
        6. Overall legal strategy
        
        Be thorough and consider all possible defenses."""
        
        return await self.generate_response(prompt, case_data=case_summary)
    
    async def cross_examine_evidence(self, evidence: Evidence, prosecution_argument: str) -> str:
        """Cross-examine evidence from defense perspective"""
        prompt = f"""Cross-examine this evidence from a defense perspective:
        
        Evidence: {evidence.title}
        Type: {evidence.evidence_type}
        Description: {evidence.description}
        Content: {evidence.content}
        
        Prosecution's Argument: {prosecution_argument}
        
        Provide:
        1. Questions about the evidence's reliability
        2. Alternative interpretations
        3. Gaps or inconsistencies
        4. Chain of custody or procedural issues
        5. How this evidence might actually support the defense"""
        
        return await self.generate_response(prompt)

class CrossExaminerAgent(BaseAgent):
    """AI agent specialized in cross-examination"""
    
    def __init__(self):
        super().__init__("Cross-Examiner", MessageRole.CROSS_EXAMINER, "gpt-4")
    
    def _get_system_prompt(self) -> str:
        return """You are a skilled cross-examiner in a legal proceeding. Your role is to:

1. Ask probing questions to reveal truth and inconsistencies
2. Challenge witness testimony and evidence
3. Expose bias, motive, or credibility issues
4. Use strategic questioning to advance your side's case
5. Maintain control of the examination while being respectful
6. Follow proper courtroom procedures and ethics

Cross-examination techniques:
- Ask only leading questions that suggest the answer
- Break down complex issues into simple, clear questions
- Use prior statements to highlight inconsistencies
- Focus on facts, not opinions
- Never ask questions you don't know the answer to
- End strong with your most important points

Always be professional, respectful, and focused on the truth."""
    
    async def generate_cross_examination_questions(self, target_party: str, context: str, evidence: List[Evidence]) -> List[str]:
        """Generate strategic cross-examination questions"""
        evidence_summary = [{"title": e.title, "type": e.evidence_type, "description": e.description} for e in evidence]
        
        prompt = f"""Generate strategic cross-examination questions for {target_party}.
        
        Context: {context}
        Available Evidence: {json.dumps(evidence_summary, indent=2)}
        
        Generate 8-10 specific, leading questions that:
        1. Test the witness's knowledge and memory
        2. Reveal potential bias or motive
        3. Highlight inconsistencies or contradictions
        4. Challenge the reliability of their testimony
        5. Advance our case theory
        
        Format each question clearly and explain the purpose."""
        
        response = await self.generate_response(prompt)
        
        # Parse response to extract questions (simplified)
        questions = []
        for line in response.split('\n'):
            if line.strip() and ('?' in line or 'Q:' in line):
                questions.append(line.strip())
        
        return questions[:10]  # Return top 10 questions
    
    async def evaluate_witness_response(self, question: str, response: str, case_context: str) -> str:
        """Evaluate a witness response and suggest follow-up"""
        prompt = f"""Evaluate this witness response to cross-examination:
        
        Question: {question}
        Response: {response}
        Case Context: {case_context}
        
        Provide:
        1. Analysis of the response (helpful, harmful, evasive, etc.)
        2. Inconsistencies or problems with the answer
        3. Follow-up questions to pursue
        4. Whether to continue this line of questioning
        5. Strategic recommendations"""
        
        return await self.generate_response(prompt)

class JudgeAgent(BaseAgent):
    """AI agent acting as a judge"""
    
    def __init__(self):
        super().__init__("Judge", MessageRole.JUDGE, "claude-3-sonnet-20240229")
    
    def _get_system_prompt(self) -> str:
        return """You are an experienced and impartial judge in a legal proceeding. Your role is to:

1. Ensure fair and orderly proceedings
2. Make evidence admissibility decisions
3. Rule on objections and procedural matters
4. Provide guidance on legal standards and procedures
5. Render final verdicts based on evidence and law
6. Maintain neutrality and avoid bias

Judicial principles:
- Presumption of innocence in criminal cases
- Burden of proof standards (beyond reasonable doubt, preponderance of evidence)
- Rules of evidence and procedure
- Constitutional protections and due process
- Precedent and stare decisis
- Reasoned decision-making with clear explanations

Always:
- Remain neutral and impartial
- Base decisions on evidence and law, not emotion
- Provide clear reasoning for all rulings
- Ensure due process for all parties
- Cite relevant legal authorities when making decisions
- Be respectful to all participants

Format your decisions clearly with reasoning and legal citations when applicable."""
    
    async def make_evidentiary_ruling(self, evidence: Evidence, objection: str, legal_arguments: Dict) -> str:
        """Make ruling on evidence admissibility"""
        prompt = f"""Make an evidentiary ruling on this evidence:
        
        Evidence: {evidence.title}
        Type: {evidence.evidence_type}
        Description: {evidence.description}
        Content: {evidence.content}
        
        Objection: {objection}
        Legal Arguments: {json.dumps(legal_arguments, indent=2)}
        
        Provide:
        1. Ruling (SUSTAINED/OVERRULED)
        2. Legal reasoning for the decision
        3. Relevant rules of evidence
        4. Any limitations on how evidence may be used
        5. Instructions to the parties"""
        
        return await self.generate_response(prompt)
    
    async def render_final_verdict(self, case: LegalCase) -> Verdict:
        """Render final verdict based on all evidence and arguments"""
        # Research relevant legal precedents
        research_results = await legal_research_engine.research_legal_question(
            f"{case.title} - {case.description}",
            f"Case type: {case.case_type}"
        )
        
        case_summary = {
            "title": case.title,
            "description": case.description,
            "case_type": case.case_type,
            "parties": [{"name": p.name, "type": p.party_type, "description": p.description} for p in case.parties],
            "evidence": [{"title": e.title, "type": e.evidence_type, "description": e.description, "content": e.content[:200]} for e in case.evidence],
            "arguments": [{"party": arg.party_id, "argument": arg.argument_text} for arg in case.arguments],
            "legal_research": research_results
        }
        
        prompt = f"""Render a final verdict for this case based on all evidence and arguments presented.
        
        Case Information: {json.dumps(case_summary, indent=2)}
        
        Consider:
        1. Strength of evidence presented by each side
        2. Credibility of witnesses and testimony
        3. Applicable legal standards and burden of proof
        4. Relevant legal precedents and statutes
        5. Constitutional considerations
        
        Provide:
        1. Final verdict (guilty/not guilty, liable/not liable, etc.)
        2. Confidence score (0.0-1.0)
        3. Detailed reasoning for the decision
        4. Key decision factors with weights
        5. Legal precedents supporting the decision
        6. Any dissenting considerations
        
        Format your response as a formal court decision."""
        
        verdict_response = await self.generate_response(prompt)
        
        # Parse the response to create a structured verdict
        verdict = self._parse_verdict_response(verdict_response, case.id, research_results)
        
        return verdict
    
    def _parse_verdict_response(self, response: str, case_id: str, research_results: Dict) -> Verdict:
        """Parse AI response into structured verdict"""
        # This is a simplified parsing - in production, you'd want more robust parsing
        lines = response.split('\n')
        
        # Extract verdict type (simplified)
        verdict_type = VerdictType.NOT_GUILTY  # Default
        confidence_score = 0.75  # Default
        
        if "guilty" in response.lower() and "not guilty" not in response.lower():
            verdict_type = VerdictType.GUILTY
        elif "liable" in response.lower() and "not liable" not in response.lower():
            verdict_type = VerdictType.LIABLE
        elif "not liable" in response.lower():
            verdict_type = VerdictType.NOT_LIABLE
        
        # Extract confidence score
        for line in lines:
            if "confidence" in line.lower():
                try:
                    # Extract number from line
                    import re
                    numbers = re.findall(r'0\.\d+|1\.0', line)
                    if numbers:
                        confidence_score = float(numbers[0])
                except:
                    pass
        
        # Create decision factors
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
                reasoning="Application of relevant case law and statutes",
                supporting_evidence=[]
            ),
            DecisionFactor(
                factor="Witness Credibility",
                weight=0.2,
                reasoning="Assessment of witness reliability and testimony",
                supporting_evidence=[]
            ),
            DecisionFactor(
                factor="Procedural Compliance",
                weight=0.1,
                reasoning="Adherence to legal procedures and due process",
                supporting_evidence=[]
            )
        ]
        
        # Extract legal precedents from research
        legal_precedents = []
        if research_results.get("case_law"):
            legal_precedents = [case.get("name", "Unknown Case") for case in research_results["case_law"][:3]]
        
        verdict = Verdict(
            case_id=case_id,
            verdict_type=verdict_type,
            confidence_score=confidence_score,
            reasoning=response,
            decision_factors=decision_factors,
            legal_precedents=legal_precedents
        )
        
        return verdict

class LegalAgentsOrchestrator:
    """Orchestrates interactions between legal agents"""
    
    def __init__(self):
        self.prosecutor = ProsecutorAgent()
        self.defense = DefenseAgent()
        self.cross_examiner = CrossExaminerAgent()
        self.judge = JudgeAgent()
    
    async def conduct_case_proceedings(self, case: LegalCase) -> LegalCase:
        """Conduct full case proceedings with all agents"""
        try:
            # Phase 1: Opening Arguments
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
            
            # Phase 2: Evidence Analysis
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
            
            # Phase 3: Cross-Examination (if applicable)
            if len(case.parties) > 1:
                questions = await self.cross_examiner.generate_cross_examination_questions(
                    case.parties[0].name,
                    case.description,
                    case.evidence
                )
                
                cross_exam_content = "Cross-Examination Questions:\n" + "\n".join(f"{i+1}. {q}" for i, q in enumerate(questions))
                case.add_message(ConversationMessage(
                    role=MessageRole.CROSS_EXAMINER,
                    content=cross_exam_content,
                    case_id=case.id
                ))
            
            # Phase 4: Final Verdict
            verdict = await self.judge.render_final_verdict(case)
            case.verdict = verdict
            case.add_message(ConversationMessage(
                role=MessageRole.JUDGE,
                content=f"FINAL VERDICT: {verdict.reasoning}",
                case_id=case.id
            ))
            
            # Update case status
            from models import CaseStatus
            case.status = CaseStatus.VERDICT_RENDERED
            
            return case
            
        except Exception as e:
            logger.error(f"Error in case proceedings: {str(e)}")
            case.add_message(ConversationMessage(
                role=MessageRole.SYSTEM,
                content=f"Error in proceedings: {str(e)}",
                case_id=case.id
            ))
            return case

# Global orchestrator instance
legal_agents = LegalAgentsOrchestrator()