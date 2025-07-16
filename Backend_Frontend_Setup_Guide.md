# MediationAI Backend & Frontend Setup Guide

## 🎯 Project Overview

Your MediationAI project consists of two main components:

### **Backend (Python FastAPI)**
- **Location**: Root directory files (`mediation_api.py`, `mediation_agents.py`, etc.)
- **Purpose**: AI-powered dispute resolution API that handles the lawyer-like cross-examination and judge-like decision process
- **Tech Stack**: FastAPI, OpenAI/Anthropic AI, WebSockets for real-time communication

### **Frontend (iOS SwiftUI App)**
- **Location**: `MediationAI/` directory (all .swift files)
- **Purpose**: Native iOS app that provides the user interface for creating disputes and communicating with the AI system
- **Tech Stack**: SwiftUI, iOS 15+, WebSocket connections to backend

## 🔄 How The AI Mediation Workflow Works

Your system implements a sophisticated 3-stage AI process:

### **Stage 1: Lawyer-Like Information Gathering**
- **Mediator Agent**: Asks clarifying questions to both parties
- **Cross-Examination**: AI probes for inconsistencies and gathers evidence
- **Information Collection**: Each party provides their side of the story privately

### **Stage 2: Evidence Analysis**
- **Analyst Agent**: Reviews all submissions for consistency and facts
- **Fact-Checking**: Verifies claims and identifies contradictions
- **Pattern Recognition**: Identifies key issues and points of contention

### **Stage 3: Judge-Like Resolution**
- **Arbitrator Agent**: Makes final decisions based on evidence and legal principles
- **Resolution Generation**: Creates binding resolutions with confidence scores
- **Privacy Protection**: Only the final resolution is shared with both parties

## 🚀 Getting the Backend Running

### **Step 1: Install Dependencies**
```bash
# Navigate to your project directory
cd /workspace

# Install Python dependencies
pip install -r requirements.txt
```

### **Step 2: Configure Environment Variables**
Create a `.env` file in your project root:
```bash
# AI API Keys (Required for full functionality)
OPENAI_API_KEY=your_openai_api_key_here
ANTHROPIC_API_KEY=your_anthropic_api_key_here

# Database Configuration
DATABASE_URL=sqlite:///./legal_ai.db

# Application Settings
SECRET_KEY=your-secret-key-here
HOST=0.0.0.0
PORT=8000
DEBUG=True

# Demo Mode (Use this if you don't have API keys yet)
DEMO_MODE=True
```

### **Step 3: Start the Backend Server**

**Option A: Full AI Mode (with API keys)**
```bash
# Start the FastAPI server
uvicorn mediation_api:app --host 0.0.0.0 --port 8000 --reload
```

**Option B: Demo Mode (without API keys)**
```bash
# Start with mock responses for testing
python start_demo.py
```

The backend will be running at: `http://localhost:8000`

### **Step 4: Test the API**
Visit `http://localhost:8000/docs` to see the interactive API documentation.

## 📱 Getting the iOS App Working

### **Step 1: Xcode Setup (Mac Required)**
1. **Transfer Files**: Copy the entire `MediationAI/` folder to a Mac
2. **Open Xcode**: Create a new iOS project
   - Product Name: `MediationAI`
   - Interface: `SwiftUI`
   - Language: `Swift`
   - Bundle ID: `com.yourname.mediationai`

### **Step 2: Import Swift Files**
1. Delete default `ContentView.swift` and `MediationAIApp.swift`
2. Drag all `.swift` files from `MediationAI/` into your Xcode project
3. Select "Copy items if needed" and "Add to target"
4. Replace `Info.plist` with the one from `MediationAI/`

### **Step 3: Configure Backend Connection**
Update the API endpoints in your Swift files to point to your backend:

```swift
// In your Swift files, update API URLs
let baseURL = "http://your-backend-url:8000"
// For local testing: "http://localhost:8000"
// For production: "https://your-domain.com"
```

### **Step 4: Build and Run**
1. Select iPhone simulator or connected device
2. Press `Cmd+R` to build and run
3. The app will launch on your device

## 🔗 Backend API Endpoints

Your backend provides these key endpoints:

### **User Management**
- `POST /api/users/register` - Register new users
- `POST /api/users/login` - User authentication

### **Dispute Management**
- `POST /api/disputes/create` - Create new disputes
- `GET /api/disputes/{dispute_id}` - Get dispute details
- `POST /api/disputes/{dispute_id}/join` - Join existing dispute

### **AI Mediation**
- `POST /api/disputes/{dispute_id}/messages` - Send messages
- `GET /api/disputes/{dispute_id}/messages` - Get conversation history
- `POST /api/disputes/{dispute_id}/initiate-mediation` - Start AI mediation
- `WebSocket /ws/disputes/{dispute_id}` - Real-time updates

### **Resolution**
- `POST /api/disputes/{dispute_id}/escalate` - Escalate to arbitration
- `GET /api/disputes/{dispute_id}/resolution` - Get final resolution

## 🤖 AI Agent Workflow

The system uses specialized AI agents:

### **1. MediatorAgent**
- Facilitates initial discussions
- Asks clarifying questions
- Guides the conversation flow
- Identifies when escalation is needed

### **2. AnalystAgent**
- Analyzes evidence and submissions
- Detects sentiment and escalation risk
- Provides recommendations for next steps
- Calculates confidence scores

### **3. ArbitratorAgent**
- Makes final binding decisions
- Applies legal principles
- Generates detailed resolutions
- Provides confidence ratings

### **4. FacilitatorAgent**
- Guides users through the process
- Explains next steps
- Provides process education
- Manages timeline expectations

## 🔐 Privacy Protection

**Key Privacy Features:**
- Each party's submissions are kept private during information gathering
- AI agents analyze submissions separately
- Cross-examination happens through AI, not direct party-to-party
- Only the final resolution is shared with both parties
- All intermediate analysis remains confidential

## 🔄 Real-Time Communication

The app uses WebSockets for real-time updates:

### **Frontend (iOS)**
```swift
// WebSocket connection for real-time updates
let websocket = WebSocket(url: URL(string: "ws://localhost:8000/ws/disputes/\(disputeId)")!)
```

### **Backend (Python)**
```python
# WebSocket endpoint for real-time communication
@app.websocket("/ws/disputes/{dispute_id}")
async def dispute_websocket(websocket: WebSocket, dispute_id: str):
    # Handle real-time messaging
```

## 🧪 Testing the Complete System

### **Test Scenario:**
1. **Start Backend**: Run `python start_demo.py`
2. **Launch iOS App**: Open in Xcode simulator
3. **Create Dispute**: Use the app to create a new dispute
4. **Submit Evidence**: Both parties submit their sides
5. **AI Processing**: Watch AI agents gather information
6. **Resolution**: Receive final arbitration decision

### **Demo Mode Features:**
- Mock AI responses for testing without API keys
- Simulated legal analysis and cross-examination
- Example dispute scenarios pre-loaded
- Full workflow demonstration

## 🚧 Current Status & Next Steps

### **What's Working:**
✅ Backend API with all endpoints
✅ iOS SwiftUI app with complete UI
✅ AI agent system with mediation workflow
✅ WebSocket real-time communication
✅ Demo mode for testing

### **What You Need to Do:**
1. **Get API Keys**: OpenAI and/or Anthropic for full AI functionality
2. **Deploy Backend**: Host on cloud service (AWS, Google Cloud, etc.)
3. **Update iOS App**: Point to your deployed backend URL
4. **Test Integration**: Verify iOS app connects to backend
5. **Deploy iOS App**: Use Xcode to install on iPhone

## 🌐 Deployment Options

### **Backend Deployment:**
- **Railway**: Simple Python app deployment
- **AWS Lambda**: Serverless deployment
- **Google Cloud Run**: Container-based deployment
- **DigitalOcean**: VPS deployment

### **iOS App Deployment:**
- **Xcode**: Direct installation to iPhone
- **TestFlight**: Beta testing platform
- **App Store**: Full public release

## 📋 Quick Start Commands

```bash
# Clone/navigate to project
cd /workspace

# Install dependencies
pip install -r requirements.txt

# Start backend in demo mode
python start_demo.py

# Or start with full AI (requires API keys)
uvicorn mediation_api:app --host 0.0.0.0 --port 8000 --reload

# Test the API
curl http://localhost:8000/api/health
```

## 🎯 Key Features Summary

Your MediationAI system provides:
- **AI-Powered Mediation**: Sophisticated legal analysis
- **Privacy Protection**: Confidential information gathering
- **Real-Time Communication**: WebSocket-based updates
- **Cross-Platform Ready**: iOS app with backend API
- **Scalable Architecture**: FastAPI backend, SwiftUI frontend
- **Demo Mode**: Test without API keys

The system is designed to handle complex dispute resolution with AI agents that act like legal professionals, ensuring fair and thorough analysis while maintaining privacy and providing clear resolutions.