#!/usr/bin/env python3
"""
Simple run script for the AI Legal Decision-Making System
"""

import os
import sys
import subprocess
import signal

def check_environment():
    """Check if the environment is properly set up"""
    if not os.path.exists(".env"):
        print("❌ .env file not found. Please run setup.py first.")
        return False
    
    if not os.path.exists("venv"):
        print("❌ Virtual environment not found. Please run setup.py first.")
        return False
    
    return True

def get_python_command():
    """Get the appropriate Python command based on OS"""
    if os.name == 'nt':  # Windows
        return "venv\\Scripts\\python"
    else:  # Unix/Linux/Mac
        return "venv/bin/python"

def main():
    """Main function to run the application"""
    print("🚀 Starting AI Legal Decision-Making System...")
    print("=" * 50)
    
    # Check environment
    if not check_environment():
        print("\n💡 Run 'python setup.py' first to set up the environment.")
        sys.exit(1)
    
    # Get Python command
    python_cmd = get_python_command()
    
    try:
        print("🔧 Starting FastAPI server...")
        print("📱 Application will be available at: http://localhost:8000")
        print("⏹️  Press Ctrl+C to stop the server")
        print("=" * 50)
        
        # Run the main application
        process = subprocess.Popen([python_cmd, "main.py"])
        
        # Wait for the process to complete
        process.wait()
        
    except KeyboardInterrupt:
        print("\n🛑 Stopping server...")
        if process:
            process.terminate()
            process.wait()
        print("✅ Server stopped successfully")
    
    except Exception as e:
        print(f"❌ Error starting server: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()