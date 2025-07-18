from fastapi import FastAPI
from datetime import datetime

app = FastAPI()

@app.get("/api/admin/users")
async def admin_users():
    """Return an empty user list – used as a fallback when the main API is broken."""
    return {
        "users": [],
        "generated_at": datetime.utcnow().isoformat()
    }