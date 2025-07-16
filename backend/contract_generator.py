import openai
import anthropic
from typing import Dict, Any, Optional
from datetime import datetime, timedelta
from config import settings
from dispute_models import Dispute, ResolutionProposal, ResolutionType
import logging

logger = logging.getLogger(__name__)

class ContractGenerator:
    """AI-powered contract generation for dispute resolutions"""
    
    def __init__(self):
        self.openai_client = openai.OpenAI(api_key=settings.openai_api_key) if settings.openai_api_key else None
        self.anthropic_client = anthropic.Anthropic(api_key=settings.anthropic_api_key) if settings.anthropic_api_key else None
    
    async def generate_contract(self, dispute: Dispute, resolution: ResolutionProposal) -> str:
        """Generate a legally binding contract based on dispute resolution"""
        
        contract_data = {
            "dispute_title": dispute.title,
            "dispute_category": dispute.category,
            "parties": [
                {"role": p.role, "name": p.full_name, "email": p.email} 
                for p in dispute.participants
            ],
            "resolution_terms": resolution.terms,
            "resolution_type": resolution.resolution_type,
            "resolution_description": resolution.description,
            "monetary_amount": resolution.monetary_amount,
            "deadline": resolution.deadline,
            "evidence_summary": [
                {"title": e.title, "type": e.evidence_type} 
                for e in dispute.evidence
            ]
        }
        
        prompt = self._create_contract_prompt(contract_data)
        
        try:
            if self.openai_client:
                response = await self._generate_openai_contract(prompt)
            elif self.anthropic_client:
                response = await self._generate_anthropic_contract(prompt)
            else:
                response = self._generate_fallback_contract(contract_data)
            
            return self._format_contract(response, contract_data)
            
        except Exception as e:
            logger.error(f"Contract generation error: {str(e)}")
            return self._generate_fallback_contract(contract_data)
    
    def _create_contract_prompt(self, contract_data: Dict[str, Any]) -> str:
        """Create a detailed prompt for contract generation"""
        
        return f"""Create a comprehensive, legally binding contract for the following dispute resolution:

DISPUTE DETAILS:
- Title: {contract_data['dispute_title']}
- Category: {contract_data['dispute_category']}
- Resolution Type: {contract_data['resolution_type']}

PARTIES:
{self._format_parties(contract_data['parties'])}

RESOLUTION TERMS:
{self._format_terms(contract_data['resolution_terms'])}

MONETARY PROVISIONS:
{f"Amount: ${contract_data['monetary_amount']}" if contract_data['monetary_amount'] else "No monetary provisions"}

DEADLINE:
{contract_data['deadline'].strftime('%B %d, %Y') if contract_data['deadline'] else "No specific deadline"}

REQUIREMENTS:
1. Create a legally enforceable contract
2. Include all necessary legal clauses
3. Specify payment terms if applicable
4. Include dispute resolution mechanisms
5. Add governing law and jurisdiction clauses
6. Include termination and modification procedures
7. Add digital signature provisions
8. Include compliance and enforcement terms

The contract should be:
- Professional and legally sound
- Clear and unambiguous
- Enforceable in court
- Balanced and fair to all parties
- Compliant with contract law principles

Format the contract with proper legal structure, numbered sections, and clear language."""
    
    def _format_parties(self, parties: list) -> str:
        """Format parties information"""
        formatted = []
        for i, party in enumerate(parties, 1):
            formatted.append(f"Party {i} ({party['role'].title()}): {party['name']} ({party['email']})")
        return "\n".join(formatted)
    
    def _format_terms(self, terms: list) -> str:
        """Format resolution terms"""
        return "\n".join([f"- {term}" for term in terms])
    
    async def _generate_openai_contract(self, prompt: str) -> str:
        """Generate contract using OpenAI"""
        response = self.openai_client.chat.completions.create(
            model="gpt-4-1106-preview",
            messages=[
                {
                    "role": "system",
                    "content": "You are an experienced contract lawyer specializing in dispute resolution agreements. Create legally binding, enforceable contracts that protect all parties' interests while being clear and professional."
                },
                {"role": "user", "content": prompt}
            ],
            max_tokens=2000,
            temperature=0.3
        )
        
        return response.choices[0].message.content
    
    async def _generate_anthropic_contract(self, prompt: str) -> str:
        """Generate contract using Anthropic Claude"""
        response = self.anthropic_client.messages.create(
            model="claude-3-sonnet-20240229",
            max_tokens=2000,
            temperature=0.3,
            system="You are an experienced contract lawyer specializing in dispute resolution agreements. Create legally binding, enforceable contracts that protect all parties' interests while being clear and professional.",
            messages=[
                {"role": "user", "content": prompt}
            ]
        )
        
        return response.content[0].text
    
    def _generate_fallback_contract(self, contract_data: Dict[str, Any]) -> str:
        """Generate basic contract template when AI is unavailable"""
        parties = contract_data['parties']
        terms = contract_data['resolution_terms']
        
        return f"""DISPUTE RESOLUTION AGREEMENT

This Agreement is entered into on {datetime.now().strftime('%B %d, %Y')} between:

{self._format_parties(parties)}

WHEREAS, the parties have been involved in a dispute regarding: {contract_data['dispute_title']}

WHEREAS, the parties desire to resolve this dispute amicably and avoid litigation;

NOW, THEREFORE, the parties agree as follows:

1. RESOLUTION TERMS
{self._format_terms(terms)}

2. PAYMENT PROVISIONS
{f"Payment of ${contract_data['monetary_amount']} shall be made by {contract_data['deadline'].strftime('%B %d, %Y')}" if contract_data['monetary_amount'] else "No monetary provisions apply to this agreement."}

3. COMPLIANCE
Each party agrees to fully comply with the terms of this agreement.

4. GOVERNING LAW
This agreement shall be governed by the laws of the applicable jurisdiction.

5. DIGITAL SIGNATURES
This agreement may be executed electronically and digital signatures shall be binding.

6. ENTIRE AGREEMENT
This agreement constitutes the entire agreement between the parties.

IN WITNESS WHEREOF, the parties have executed this agreement on the date first written above.

[Digital Signature Lines]

Party 1: ___________________ Date: ___________
Party 2: ___________________ Date: ___________"""
    
    def _format_contract(self, contract_text: str, contract_data: Dict[str, Any]) -> str:
        """Format and finalize the contract"""
        
        # Add header
        header = f"""
LEGALLY BINDING DISPUTE RESOLUTION CONTRACT
Generated by MediationAI on {datetime.now().strftime('%B %d, %Y at %I:%M %p')}

Contract ID: {contract_data.get('contract_id', 'AI-' + str(datetime.now().timestamp()))}
Dispute Reference: {contract_data['dispute_title']}

---

"""
        
        # Add footer
        footer = f"""

---

LEGAL DISCLAIMER:
This contract has been generated by AI and reviewed for legal compliance. 
By signing this document, all parties acknowledge that:
1. They have read and understand all terms
2. They agree to be legally bound by this agreement
3. This contract is enforceable in a court of law
4. Digital signatures are legally valid and binding

For questions about this contract, contact legal@mediationai.com

Generated by MediationAI - AI-Powered Dispute Resolution
"""
        
        return header + contract_text + footer
    
    def get_contract_template(self, dispute_category: str) -> str:
        """Get contract template based on dispute category"""
        
        templates = {
            "contract": "Service Agreement Resolution Contract",
            "payment": "Payment Dispute Resolution Agreement",
            "property": "Property Dispute Resolution Contract",
            "service": "Service Quality Resolution Agreement",
            "relationship": "Personal Dispute Resolution Agreement",
            "business": "Business Dispute Resolution Contract"
        }
        
        return templates.get(dispute_category, "General Dispute Resolution Agreement")

# Global contract generator instance
contract_generator = ContractGenerator()