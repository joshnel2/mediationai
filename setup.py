#!/usr/bin/env python3
"""
AI Legal Decision-Making System Setup Script
This script helps you set up the AI legal system environment
"""

import os
import sys
import subprocess
import shutil
from pathlib import Path

def run_command(command, description, check=True):
    """Run a shell command with error handling"""
    print(f"🔧 {description}...")
    try:
        result = subprocess.run(command, shell=True, check=check, capture_output=True, text=True)
        if result.returncode == 0:
            print(f"✅ {description} completed successfully")
            return True
        else:
            print(f"❌ {description} failed: {result.stderr}")
            return False
    except subprocess.CalledProcessError as e:
        print(f"❌ {description} failed: {e}")
        return False

def check_python_version():
    """Check if Python version is compatible"""
    print("🔍 Checking Python version...")
    version = sys.version_info
    if version.major < 3 or (version.major == 3 and version.minor < 8):
        print("❌ Python 3.8 or higher is required")
        return False
    print(f"✅ Python {version.major}.{version.minor}.{version.micro} is compatible")
    return True

def create_virtual_environment():
    """Create a virtual environment"""
    if os.path.exists("venv"):
        print("📁 Virtual environment already exists")
        return True
    
    return run_command("python -m venv venv", "Creating virtual environment")

def activate_virtual_environment():
    """Get activation command for the virtual environment"""
    if os.name == 'nt':  # Windows
        return "venv\\Scripts\\activate"
    else:  # Unix/Linux/Mac
        return "source venv/bin/activate"

def install_dependencies():
    """Install required dependencies"""
    # Determine pip command based on OS
    if os.name == 'nt':  # Windows
        pip_cmd = "venv\\Scripts\\pip"
    else:  # Unix/Linux/Mac
        pip_cmd = "venv/bin/pip"
    
    return run_command(f"{pip_cmd} install -r requirements.txt", "Installing dependencies")

def create_env_file():
    """Create .env file from template"""
    if os.path.exists(".env"):
        print("📁 .env file already exists")
        return True
    
    if os.path.exists(".env.example"):
        shutil.copy(".env.example", ".env")
        print("✅ Created .env file from template")
        print("⚠️  Please edit .env file and add your API keys")
        return True
    else:
        print("❌ .env.example file not found")
        return False

def create_directories():
    """Create necessary directories"""
    directories = ["logs", "uploads", "static/uploads"]
    
    for directory in directories:
        Path(directory).mkdir(parents=True, exist_ok=True)
        print(f"📁 Created directory: {directory}")
    
    return True

def check_api_keys():
    """Check if API keys are configured"""
    print("🔑 Checking API key configuration...")
    
    if not os.path.exists(".env"):
        print("❌ .env file not found")
        return False
    
    with open(".env", "r") as f:
        content = f.read()
    
    missing_keys = []
    
    # Check for essential API keys
    if "OPENAI_API_KEY=your_openai_api_key_here" in content or "OPENAI_API_KEY=" in content:
        missing_keys.append("OPENAI_API_KEY")
    
    if "ANTHROPIC_API_KEY=your_anthropic_api_key_here" in content or "ANTHROPIC_API_KEY=" in content:
        missing_keys.append("ANTHROPIC_API_KEY")
    
    if missing_keys:
        print(f"⚠️  Missing API keys: {', '.join(missing_keys)}")
        print("   Please add your API keys to the .env file")
        return False
    
    print("✅ API keys appear to be configured")
    return True

def test_installation():
    """Test if the installation works"""
    print("🧪 Testing installation...")
    
    # Determine python command based on OS
    if os.name == 'nt':  # Windows
        python_cmd = "venv\\Scripts\\python"
    else:  # Unix/Linux/Mac
        python_cmd = "venv/bin/python"
    
    # Test imports
    test_command = f"{python_cmd} -c \"import fastapi, openai, anthropic; print('All imports successful')\""
    
    return run_command(test_command, "Testing core imports", check=False)

def main():
    """Main setup function"""
    print("🚀 AI Legal Decision-Making System Setup")
    print("=" * 50)
    
    success = True
    
    # Check Python version
    if not check_python_version():
        success = False
    
    # Create virtual environment
    if success and not create_virtual_environment():
        success = False
    
    # Install dependencies
    if success and not install_dependencies():
        success = False
    
    # Create .env file
    if success and not create_env_file():
        success = False
    
    # Create directories
    if success and not create_directories():
        success = False
    
    # Test installation
    if success and not test_installation():
        print("⚠️  Installation test failed, but you can still try running the system")
    
    print("\n" + "=" * 50)
    
    if success:
        print("🎉 Setup completed successfully!")
        print("\nNext steps:")
        print("1. Edit the .env file and add your API keys:")
        print("   - OpenAI API key (required)")
        print("   - Anthropic API key (optional but recommended)")
        print("   - Harvard Caselaw API key (optional)")
        print("")
        print("2. Activate the virtual environment:")
        print(f"   {activate_virtual_environment()}")
        print("")
        print("3. Run the application:")
        print("   python main.py")
        print("")
        print("4. Open your browser and go to:")
        print("   http://localhost:8000")
        print("")
        print("📖 For more information, see README.md")
    else:
        print("❌ Setup failed. Please check the errors above and try again.")
        sys.exit(1)

if __name__ == "__main__":
    main()