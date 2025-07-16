import sys
import traceback
import uvicorn
import os

# Add debugging information
print("Python version:", sys.version)
print("Current working directory:", os.getcwd())
print("Files in current directory:", os.listdir('.'))

try:
    from mediation_api import app
    print("✅ Successfully imported mediation_api")
    
    # Add a simple test endpoint to verify deployment
    @app.get("/")
    async def root():
        return {"message": "MediationAI API is running", "status": "healthy"}
    
    print("✅ Successfully added root endpoint")
    
except Exception as e:
    print(f"❌ Error during import: {e}")
    traceback.print_exc()
    # Re-raise the error so Vercel can see it
    raise

# For local development
if __name__ == "__main__":
    port = int(os.environ.get("PORT", 8000))
    uvicorn.run(app, host="0.0.0.0", port=port)