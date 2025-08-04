import os
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    # AI API Keys
    openai_api_key: str = ""
    anthropic_api_key: str = ""
    
    # Legal Database APIs
    harvard_caselaw_api_key: str = ""
    lexis_nexis_api_key: str = ""
    westlaw_api_key: str = ""
    
    # Database Configuration
    database_url: str = "sqlite:///./legal_ai.db"
    vector_db_url: str = "http://localhost:8000"
    
    # Application Settings
    secret_key: str = "legal-ai-secret-key-change-in-production"
    algorithm: str = "HS256"
    access_token_expire_minutes: int = 30
    debug: bool = True
    host: str = "0.0.0.0"
    port: int = 8000
    
    # Legal System Configuration
    max_conversation_turns: int = 50
    evidence_upload_max_size: int = 10485760
    case_timeout_hours: int = 24
    enable_bias_detection: bool = True
    enable_fact_checking: bool = True
    
    # Rate Limiting
    rate_limit_requests: int = 100
    rate_limit_minutes: int = 60
    
    # AI Cost Control Settings
    max_ai_interventions_per_dispute: int = 3
    max_ai_response_tokens: int = 300
    ai_intervention_cooldown_minutes: int = 10
    enable_ai_cost_optimization: bool = True
    
    # AI Response Configuration
    ai_response_temperature: float = 0.3
    ai_model_preference: str = "gpt-3.5-turbo"  # Cheaper than GPT-4
    enable_ai_response_caching: bool = True

    # Observability
    sentry_dsn: str = ""  # Leave blank to disable

    # Push notifications (APNs)
    apns_key_id: str = ""
    apns_team_id: str = ""
    apns_key_base64: str = ""  # Base64-encoded .p8 content

    # Bank Connection (Plaid)
    plaid_client_id: str = ""
    plaid_secret: str = ""
    plaid_env: str = "sandbox"
    plaid_products: str = "auth,transactions"
    plaid_country_codes: str = "US"

    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"

settings = Settings()

# ---------------- Firebase admin init -----------------
import os, json
try:
    import firebase_admin
    from firebase_admin import credentials
    if not firebase_admin._apps and os.getenv("FIREBASE_SA_JSON"):
        cred = credentials.Certificate(json.loads(os.getenv("FIREBASE_SA_JSON")))
        firebase_admin.initialize_app(cred)
except ImportError:
    # firebase-admin not installed – optional dependency
    pass