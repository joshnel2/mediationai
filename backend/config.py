import os
from dotenv import load_dotenv
from pydantic import BaseSettings

load_dotenv()

class Settings(BaseSettings):
    # AI API Keys
    openai_api_key: str = os.getenv("OPENAI_API_KEY", "")
    anthropic_api_key: str = os.getenv("ANTHROPIC_API_KEY", "")
    
    # Legal Database APIs
    harvard_caselaw_api_key: str = os.getenv("HARVARD_CASELAW_API_KEY", "")
    lexis_nexis_api_key: str = os.getenv("LEXIS_NEXIS_API_KEY", "")
    westlaw_api_key: str = os.getenv("WESTLAW_API_KEY", "")
    
    # Database Configuration
    database_url: str = os.getenv("DATABASE_URL", "sqlite:///./legal_ai.db")
    vector_db_url: str = os.getenv("VECTOR_DB_URL", "http://localhost:8000")
    
    # Application Settings
    secret_key: str = os.getenv("SECRET_KEY", "legal-ai-secret-key-change-in-production")
    algorithm: str = os.getenv("ALGORITHM", "HS256")
    access_token_expire_minutes: int = int(os.getenv("ACCESS_TOKEN_EXPIRE_MINUTES", "30"))
    debug: bool = os.getenv("DEBUG", "True").lower() == "true"
    host: str = os.getenv("HOST", "0.0.0.0")
    port: int = int(os.getenv("PORT", "8000"))
    
    # Legal System Configuration
    max_conversation_turns: int = int(os.getenv("MAX_CONVERSATION_TURNS", "50"))
    evidence_upload_max_size: int = int(os.getenv("EVIDENCE_UPLOAD_MAX_SIZE", "10485760"))
    case_timeout_hours: int = int(os.getenv("CASE_TIMEOUT_HOURS", "24"))
    enable_bias_detection: bool = os.getenv("ENABLE_BIAS_DETECTION", "True").lower() == "true"
    enable_fact_checking: bool = os.getenv("ENABLE_FACT_CHECKING", "True").lower() == "true"
    
    # Rate Limiting
    rate_limit_requests: int = int(os.getenv("RATE_LIMIT_REQUESTS", "100"))
    rate_limit_minutes: int = int(os.getenv("RATE_LIMIT_MINUTES", "60"))
    
    class Config:
        env_file = ".env"

settings = Settings()