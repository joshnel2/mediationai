import requests
import asyncio
from typing import List, Dict, Any, Optional
from config import settings
import logging

logger = logging.getLogger(__name__)

class HarvardLawAPI:
    """Harvard Law School Caselaw Access Project API integration"""
    
    def __init__(self):
        self.base_url = "https://api.case.law/v1"
        self.api_key = settings.harvard_caselaw_api_key
        self.session = requests.Session()
        
        # Set up authentication if API key is provided
        if self.api_key:
            self.session.headers.update({
                'Authorization': f'Token {self.api_key}',
                'Content-Type': 'application/json'
            })
    
    async def search_cases(self, query: str, jurisdiction: str = None, 
                          court: str = None, limit: int = 10) -> List[Dict[str, Any]]:
        """Search for relevant legal cases"""
        try:
            params = {
                'search': query,
                'full_case': 'true',
                'limit': limit
            }
            
            if jurisdiction:
                params['jurisdiction'] = jurisdiction
            if court:
                params['court'] = court
            
            response = self.session.get(f"{self.base_url}/cases/", params=params)
            response.raise_for_status()
            
            data = response.json()
            return data.get('results', [])
            
        except Exception as e:
            logger.error(f"Harvard Law API search error: {str(e)}")
            return []
    
    async def get_case_by_id(self, case_id: str) -> Optional[Dict[str, Any]]:
        """Get specific case details by ID"""
        try:
            response = self.session.get(f"{self.base_url}/cases/{case_id}/")
            response.raise_for_status()
            return response.json()
        except Exception as e:
            logger.error(f"Harvard Law API case lookup error: {str(e)}")
            return None
    
    async def find_precedents(self, dispute_category: str, key_terms: List[str], 
                            jurisdiction: str = "us") -> List[Dict[str, Any]]:
        """Find legal precedents relevant to a dispute"""
        
        # Category-specific search terms
        category_terms = {
            'contract': ['contract breach', 'contract dispute', 'breach of contract', 'contract law'],
            'payment': ['payment dispute', 'debt collection', 'money owed', 'payment default'],
            'service': ['service agreement', 'service quality', 'professional negligence'],
            'property': ['property dispute', 'property damage', 'real estate', 'landlord tenant'],
            'business': ['business dispute', 'partnership', 'commercial law', 'business contract'],
            'employment': ['employment law', 'wrongful termination', 'workplace dispute']
        }
        
        search_terms = category_terms.get(dispute_category, [])
        search_terms.extend(key_terms)
        
        # Search for relevant cases
        all_cases = []
        for term in search_terms[:3]:  # Limit to avoid too many API calls
            cases = await self.search_cases(term, jurisdiction=jurisdiction, limit=3)
            all_cases.extend(cases)
        
        # Remove duplicates and return most relevant
        unique_cases = []
        seen_ids = set()
        for case in all_cases:
            if case.get('id') not in seen_ids:
                unique_cases.append(case)
                seen_ids.add(case.get('id'))
        
        return unique_cases[:5]  # Return top 5 most relevant
    
    def extract_case_summary(self, case_data: Dict[str, Any]) -> Dict[str, Any]:
        """Extract key information from case data"""
        return {
            'case_name': case_data.get('name_abbreviation', ''),
            'citation': case_data.get('citations', [{}])[0].get('cite', ''),
            'court': case_data.get('court', {}).get('name', ''),
            'decision_date': case_data.get('decision_date', ''),
            'url': case_data.get('frontend_url', ''),
            'jurisdiction': case_data.get('jurisdiction', {}).get('name', ''),
            'summary': case_data.get('casebody', {}).get('data', {}).get('head_matter', '')[:500] + '...'
        }
    
    def is_available(self) -> bool:
        """Check if Harvard Law API is available"""
        return bool(self.api_key)

class LegalResearchService:
    """Enhanced legal research service with Harvard Law integration"""
    
    def __init__(self):
        self.harvard_api = HarvardLawAPI()
    
    async def research_dispute(self, dispute_title: str, dispute_category: str, 
                              evidence_summary: List[str]) -> Dict[str, Any]:
        """Conduct comprehensive legal research for a dispute"""
        
        # Extract key terms from dispute
        key_terms = self._extract_key_terms(dispute_title, evidence_summary)
        
        research_results = {
            'precedents': [],
            'relevant_laws': [],
            'case_summaries': [],
            'recommendations': []
        }
        
        # Search for legal precedents if Harvard API is available
        if self.harvard_api.is_available():
            precedents = await self.harvard_api.find_precedents(
                dispute_category, key_terms
            )
            
            research_results['precedents'] = [
                self.harvard_api.extract_case_summary(case) 
                for case in precedents
            ]
            
            # Generate legal recommendations based on precedents
            research_results['recommendations'] = self._generate_recommendations(
                precedents, dispute_category
            )
        
        return research_results
    
    def _extract_key_terms(self, title: str, evidence: List[str]) -> List[str]:
        """Extract key legal terms from dispute information"""
        # Simple keyword extraction (can be enhanced with NLP)
        all_text = title + " " + " ".join(evidence)
        
        legal_keywords = [
            'contract', 'breach', 'payment', 'service', 'damage', 'property',
            'negligence', 'liability', 'dispute', 'agreement', 'violation',
            'refund', 'compensation', 'warranty', 'delivery', 'quality'
        ]
        
        found_terms = []
        for keyword in legal_keywords:
            if keyword.lower() in all_text.lower():
                found_terms.append(keyword)
        
        return found_terms
    
    def _generate_recommendations(self, precedents: List[Dict], category: str) -> List[str]:
        """Generate legal recommendations based on precedents"""
        recommendations = []
        
        if precedents:
            recommendations.append(f"Found {len(precedents)} relevant legal precedents")
            recommendations.append("Consider similar case outcomes when determining resolution")
            
            # Category-specific recommendations
            if category == 'contract':
                recommendations.append("Review contract terms and applicable contract law principles")
            elif category == 'payment':
                recommendations.append("Consider payment dispute resolution standards")
            elif category == 'service':
                recommendations.append("Evaluate service quality against industry standards")
        
        return recommendations

# Global service instance
legal_research_service = LegalResearchService()