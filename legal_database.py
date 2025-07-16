import requests
import json
from typing import List, Dict, Any, Optional
from config import settings
import logging
from datetime import datetime

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class LegalDatabaseClient:
    """Client for accessing legal databases and case law"""
    
    def __init__(self):
        self.harvard_base_url = "https://api.case.law/v1"
        self.headers = {
            "Authorization": f"Token {settings.harvard_caselaw_api_key}",
            "Content-Type": "application/json"
        }
    
    async def search_case_law(self, query: str, jurisdiction: str = None, limit: int = 10) -> List[Dict]:
        """Search case law using Harvard Caselaw Access Project"""
        try:
            url = f"{self.harvard_base_url}/cases/"
            params = {
                "search": query,
                "full_case": "true",
                "page_size": limit
            }
            
            if jurisdiction:
                params["jurisdiction"] = jurisdiction
            
            response = requests.get(url, headers=self.headers, params=params)
            
            if response.status_code == 200:
                data = response.json()
                return self._process_case_results(data.get("results", []))
            else:
                logger.error(f"Error searching case law: {response.status_code}")
                return []
                
        except Exception as e:
            logger.error(f"Exception in search_case_law: {str(e)}")
            return []
    
    def _process_case_results(self, results: List[Dict]) -> List[Dict]:
        """Process and format case law results"""
        processed_results = []
        
        for case in results:
            processed_case = {
                "id": case.get("id"),
                "name": case.get("name"),
                "name_abbreviation": case.get("name_abbreviation"),
                "decision_date": case.get("decision_date"),
                "court": case.get("court", {}).get("name"),
                "jurisdiction": case.get("jurisdiction", {}).get("name"),
                "citations": case.get("citations", []),
                "url": case.get("url"),
                "preview": case.get("preview", [])
            }
            processed_results.append(processed_case)
        
        return processed_results
    
    async def get_case_details(self, case_id: str) -> Optional[Dict]:
        """Get detailed information about a specific case"""
        try:
            url = f"{self.harvard_base_url}/cases/{case_id}/"
            response = requests.get(url, headers=self.headers)
            
            if response.status_code == 200:
                return response.json()
            else:
                logger.error(f"Error getting case details: {response.status_code}")
                return None
                
        except Exception as e:
            logger.error(f"Exception in get_case_details: {str(e)}")
            return None
    
    async def search_statutes(self, query: str, jurisdiction: str = None) -> List[Dict]:
        """Search for statutory law (placeholder for future implementation)"""
        # This would integrate with statutory databases
        # For now, return mock data
        return [
            {
                "id": "mock_statute_1",
                "title": f"Statute related to: {query}",
                "jurisdiction": jurisdiction or "Federal",
                "text": f"Mock statute text for query: {query}",
                "citations": ["Mock Citation 1"],
                "effective_date": "2023-01-01"
            }
        ]
    
    async def verify_citation(self, citation: str) -> Dict:
        """Verify if a legal citation is valid"""
        try:
            # Search for the citation
            url = f"{self.harvard_base_url}/cases/"
            params = {"cite": citation}
            
            response = requests.get(url, headers=self.headers, params=params)
            
            if response.status_code == 200:
                data = response.json()
                results = data.get("results", [])
                
                if results:
                    case = results[0]
                    return {
                        "valid": True,
                        "case_name": case.get("name"),
                        "court": case.get("court", {}).get("name"),
                        "decision_date": case.get("decision_date"),
                        "url": case.get("url")
                    }
                else:
                    return {"valid": False, "reason": "Citation not found"}
            else:
                return {"valid": False, "reason": "API error"}
                
        except Exception as e:
            logger.error(f"Exception in verify_citation: {str(e)}")
            return {"valid": False, "reason": str(e)}
    
    async def get_precedent_cases(self, legal_issue: str, jurisdiction: str = None) -> List[Dict]:
        """Find precedent cases for a specific legal issue"""
        # This combines search functionality with relevance scoring
        cases = await self.search_case_law(legal_issue, jurisdiction)
        
        # Add relevance scoring (simplified)
        for case in cases:
            case["relevance_score"] = self._calculate_relevance_score(case, legal_issue)
        
        # Sort by relevance
        cases.sort(key=lambda x: x.get("relevance_score", 0), reverse=True)
        
        return cases
    
    def _calculate_relevance_score(self, case: Dict, query: str) -> float:
        """Calculate relevance score for a case (simplified implementation)"""
        score = 0.0
        query_terms = query.lower().split()
        
        # Check case name
        case_name = case.get("name", "").lower()
        for term in query_terms:
            if term in case_name:
                score += 1.0
        
        # Check preview text
        preview = " ".join(case.get("preview", [])).lower()
        for term in query_terms:
            if term in preview:
                score += 0.5
        
        # Boost recent cases slightly
        decision_date = case.get("decision_date")
        if decision_date:
            try:
                date_obj = datetime.strptime(decision_date, "%Y-%m-%d")
                years_ago = (datetime.now() - date_obj).days / 365
                if years_ago < 5:
                    score += 0.2
            except ValueError:
                pass
        
        return score

class LegalResearchEngine:
    """High-level interface for legal research"""
    
    def __init__(self):
        self.db_client = LegalDatabaseClient()
    
    async def research_legal_question(self, question: str, context: str = None) -> Dict:
        """Comprehensive legal research for a question"""
        results = {
            "question": question,
            "context": context,
            "case_law": [],
            "statutes": [],
            "analysis": "",
            "confidence": 0.0
        }
        
        try:
            # Search case law
            cases = await self.db_client.search_case_law(question)
            results["case_law"] = cases[:5]  # Top 5 most relevant
            
            # Search statutes
            statutes = await self.db_client.search_statutes(question)
            results["statutes"] = statutes[:3]  # Top 3 most relevant
            
            # Calculate overall confidence
            results["confidence"] = self._calculate_research_confidence(results)
            
            # Generate analysis summary
            results["analysis"] = self._generate_analysis_summary(results)
            
        except Exception as e:
            logger.error(f"Error in research_legal_question: {str(e)}")
            results["analysis"] = f"Error conducting research: {str(e)}"
        
        return results
    
    def _calculate_research_confidence(self, results: Dict) -> float:
        """Calculate confidence score for research results"""
        case_count = len(results["case_law"])
        statute_count = len(results["statutes"])
        
        # Base confidence on number of relevant sources found
        confidence = min(1.0, (case_count * 0.15) + (statute_count * 0.1))
        
        # Boost confidence if we have high-relevance cases
        if results["case_law"]:
            avg_relevance = sum(case.get("relevance_score", 0) for case in results["case_law"]) / len(results["case_law"])
            confidence += min(0.3, avg_relevance * 0.1)
        
        return confidence
    
    def _generate_analysis_summary(self, results: Dict) -> str:
        """Generate a summary of research findings"""
        summary_parts = []
        
        if results["case_law"]:
            summary_parts.append(f"Found {len(results['case_law'])} relevant cases.")
            top_case = results["case_law"][0]
            summary_parts.append(f"Most relevant case: {top_case.get('name', 'Unknown')}")
        
        if results["statutes"]:
            summary_parts.append(f"Found {len(results['statutes'])} relevant statutes.")
        
        if not results["case_law"] and not results["statutes"]:
            summary_parts.append("No specific legal precedents found. Further research may be needed.")
        
        return " ".join(summary_parts)

# Global instance
legal_research_engine = LegalResearchEngine()