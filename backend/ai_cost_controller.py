from datetime import datetime, timedelta
from typing import Dict, List, Optional
from config import settings
import logging

logger = logging.getLogger(__name__)

class AICostController:
    """Controls AI API usage to minimize costs while maintaining quality"""
    
    def __init__(self):
        self.dispute_interventions: Dict[str, List[datetime]] = {}
        self.response_cache: Dict[str, str] = {}
        self.last_intervention: Dict[str, datetime] = {}
    
    def can_intervene(self, dispute_id: str) -> bool:
        """Check if AI can intervene based on cost controls"""
        if not settings.enable_ai_cost_optimization:
            return True
        
        # Check intervention count limit
        if self._get_intervention_count(dispute_id) >= settings.max_ai_interventions_per_dispute:
            logger.info(f"AI intervention limit reached for dispute {dispute_id}")
            return False
        
        # Check cooldown period
        if self._is_in_cooldown(dispute_id):
            logger.info(f"AI intervention in cooldown for dispute {dispute_id}")
            return False
        
        return True
    
    def should_intervene(self, dispute_id: str, messages: List, sentiment_score: float) -> bool:
        """Smart logic to determine if AI intervention is actually needed"""
        if not self.can_intervene(dispute_id):
            return False
        
        # Only intervene when really necessary
        intervention_triggers = [
            sentiment_score < -0.4,  # Very negative sentiment
            len(messages) % 10 == 0,  # Every 10 messages
            self._detect_escalation(messages),  # Escalation detected
            self._detect_stalemate(messages)  # Conversation stalled
        ]
        
        return any(intervention_triggers)
    
    def record_intervention(self, dispute_id: str):
        """Record that AI has intervened"""
        now = datetime.now()
        
        if dispute_id not in self.dispute_interventions:
            self.dispute_interventions[dispute_id] = []
        
        self.dispute_interventions[dispute_id].append(now)
        self.last_intervention[dispute_id] = now
    
    def get_optimized_prompt(self, original_prompt: str, dispute_category: str) -> str:
        """Optimize prompt to get concise, cost-effective responses"""
        
        # Add cost optimization instructions
        optimization_suffix = f"""

RESPONSE REQUIREMENTS:
- Keep response under {settings.max_ai_response_tokens} tokens
- Be concise and direct
- Focus on 1-2 key points maximum
- Avoid lengthy explanations
- Use bullet points when possible

EXAMPLE FORMAT:
• Key point 1
• Key point 2
• Next step

Respond concisely:"""
        
        # Category-specific optimizations
        category_instructions = {
            'contract': "Focus on contract terms and obligations only.",
            'payment': "Address payment amount and timeline only.",
            'service': "Focus on service quality and resolution only.",
            'property': "Address property-specific issues only."
        }
        
        category_instruction = category_instructions.get(dispute_category, "")
        
        return f"{original_prompt}\n{category_instruction}\n{optimization_suffix}"
    
    def get_cached_response(self, prompt_hash: str) -> Optional[str]:
        """Get cached response to avoid duplicate API calls"""
        if not settings.enable_ai_response_caching:
            return None
        
        return self.response_cache.get(prompt_hash)
    
    def cache_response(self, prompt_hash: str, response: str):
        """Cache AI response for future use"""
        if settings.enable_ai_response_caching:
            self.response_cache[prompt_hash] = response
    
    def _get_intervention_count(self, dispute_id: str) -> int:
        """Get number of AI interventions for a dispute"""
        if dispute_id not in self.dispute_interventions:
            return 0
        
        # Count interventions in the last 24 hours
        cutoff = datetime.now() - timedelta(hours=24)
        recent_interventions = [
            intervention for intervention in self.dispute_interventions[dispute_id]
            if intervention > cutoff
        ]
        
        return len(recent_interventions)
    
    def _is_in_cooldown(self, dispute_id: str) -> bool:
        """Check if AI is in cooldown period"""
        if dispute_id not in self.last_intervention:
            return False
        
        cooldown_period = timedelta(minutes=settings.ai_intervention_cooldown_minutes)
        return datetime.now() - self.last_intervention[dispute_id] < cooldown_period
    
    def _detect_escalation(self, messages: List) -> bool:
        """Detect if conversation is escalating (simple heuristic)"""
        if len(messages) < 2:
            return False
        
        # Look for escalation keywords in recent messages
        escalation_keywords = [
            'angry', 'frustrated', 'unfair', 'ridiculous', 'stupid', 
            'liar', 'dishonest', 'wrong', 'ridiculous', 'unacceptable'
        ]
        
        recent_messages = messages[-3:]
        for msg in recent_messages:
            content = msg.get('content', '').lower()
            if any(keyword in content for keyword in escalation_keywords):
                return True
        
        return False
    
    def _detect_stalemate(self, messages: List) -> bool:
        """Detect if conversation has stalled"""
        if len(messages) < 6:
            return False
        
        # Check if parties are repeating the same points
        recent_messages = messages[-6:]
        contents = [msg.get('content', '') for msg in recent_messages]
        
        # Simple repetition detection
        for i, content in enumerate(contents):
            for j, other_content in enumerate(contents[i+1:], i+1):
                if len(content) > 20 and content.lower() in other_content.lower():
                    return True
        
        return False
    
    def get_cost_summary(self, dispute_id: str) -> Dict:
        """Get cost summary for a dispute"""
        intervention_count = self._get_intervention_count(dispute_id)
        estimated_cost = intervention_count * 0.05  # Rough estimate
        
        return {
            'interventions': intervention_count,
            'estimated_cost': estimated_cost,
            'limit_reached': intervention_count >= settings.max_ai_interventions_per_dispute,
            'in_cooldown': self._is_in_cooldown(dispute_id)
        }

# Global cost controller instance
ai_cost_controller = AICostController()