# 🤖⚖️ MediationAI - AI-Powered Dispute Resolution with Secure Escrow

**Resolve disputes fairly with AI mediation, secure escrow services, legal precedent lookup, and automated contract generation.**

![AI Mediation](https://img.shields.io/badge/AI-Mediation-blue)
![Legal Research](https://img.shields.io/badge/Legal-Research-green)
![Contract Generation](https://img.shields.io/badge/Contract-Generation-orange)
![Cost Optimized](https://img.shields.io/badge/Cost-Optimized-red)

## 📋 Table of Contents

- [📁 Project Organization](#-project-organization)
- [🗄️ Data Storage](#️-data-storage)
- [🌟 Features](#-features)
- [🏗️ Architecture](#️-architecture)
- [🚀 Quick Start](#-quick-start)
- [💰 Cost Control](#-cost-control)
- [📱 Mobile App](#-mobile-app)
- [🔧 Configuration](#-configuration)
- [🧪 Testing](#-testing)
- [🚢 Deployment](#-deployment)
- [🏛️ Legal Research](#️-legal-research)
- [📄 Contract Generation](#-contract-generation)
- [📄 Legal Documents](#legal-documents)
- [🔄 API Endpoints](#-api-endpoints)
- [🤝 Contributing](#-contributing)

---

## 📁 Project Organization

**This is the main project structure - clean and organized:**

```
📁 MediationAI/
├── 📄 README.md                 # Main project documentation
├── 📁 backend/                  # Python FastAPI backend
│   ├── 🔧 .env                 # Environment variables
│   ├── 📋 .env.example         # Environment template
│   ├── 📦 requirements.txt     # Python dependencies
│   ├── 🚀 vercel.json          # Vercel deployment config
│   ├── 🤖 mediation_api.py     # Main API endpoints
│   ├── 🧠 mediation_agents.py  # AI mediation agents
│   ├── 💰 ai_cost_controller.py # Cost optimization
│   ├── 📄 contract_generator.py # Legal contract creation
│   ├── 🏛️ legal_research.py    # Harvard Law API integration
│   ├── 📊 dispute_models.py    # Data models
│   ├── ⚙️ config.py            # Configuration settings
│   ├── 🏃 run.py               # Application runner
│   ├── 🎬 start_demo.py        # Demo launcher
│   ├── 🛠️ setup.py             # Setup script
│   └── 🧪 demo_mediation.py    # Demo mediation flow
├── 📁 frontend/                 # Swift iOS frontend
│   ├── 📱 MediationAIApp.swift # Main app entry point
│   ├── 🏠 homeview.swift       # Dashboard
│   ├── 💬 disputeroomview.swift # Dispute interface
│   ├── ➕ createdisputeview.swift # Create new disputes
│   ├── 🌐 RealDisputeService.swift # API communication
│   ├── ⚙️ APIConfig.swift      # Backend connection
│   ├── 📋 Info.plist          # iOS app configuration
│   └── ... (all other Swift UI files)
└── 📁 guides/                   # Documentation & Guides
    ├── 🔧 API_SETUP_GUIDE.md
    ├── 🚀 DEPLOYMENT_GUIDE.md
    ├── 💰 COST_OPTIMIZATION_GUIDE.md
    ├── 📊 DISPUTE_FLOW_ANALYSIS.md
    ├── 📱 iOS_Deployment_Guide.md
    ├── 🎨 iPhone_UI_Improvements_Summary.md
    ├── 📝 MediationAI_Revisions_Summary.md
    └── 🔮 NEXT_ESCROW_FEATURES.md
```

**✅ All duplicates removed • ✅ Clean organization • ✅ Ready for development**

---

## 🗄️ Data Storage

### **Production Data Architecture**

```
📊 Data Flow:
iOS App → HTTPS → Vercel Backend → SQLite Database → Persistent Storage
     ↓
UserDefaults (JWT Token) → Auto-login on app restart
```

### **📍 Where Your Data Lives**

Supabase API - eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVzdmFjd21kZHZ6YXRzaGxpb3h5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTI3ODc0OTcsImV4cCI6MjA2ODM2MzQ5N30.hoecoakSQLvff7rYPWSNTi6RaTKq6WNshBnQutv8fn4

Secret API - eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVzdmFjd21kZHZ6YXRzaGxpb3h5Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1Mjc4NzQ5NywiZXhwIjoyMDY4MzYzNDk3fQ.t16cR8BxjxvGtq1b40_J8xk8Y_yFkmLEu0jXO3IE2c4

#### **🔐 User Authentication Data**
- **Location**: SQLite database on Vercel + iOS UserDefaults
- **What's Stored**: 
  - Email addresses (encrypted)
  - Password hashes (bcrypt)
  - JWT tokens (30-day expiration)
  - User preferences (Face ID, notifications)
  - Profile information (display name, bio)

#### **⚖️ Dispute Data**
- **Location**: SQLite database on Vercel
- **What's Stored**:
  - Dispute details (title, description, category)
  - Party information (User A, User B)
  - Truth statements from both parties
  - Evidence files (photos, documents)
  - AI mediation responses
  - Resolution agreements
  - Digital signatures

#### **📱 Local iOS Storage**
- **Location**: Device UserDefaults (secure)
- **What's Stored**:
  - JWT authentication tokens
  - Auto-login preferences
  - Face ID/Touch ID settings
  - App preferences and settings

### **🔍 How to Access Your Data**

#### **📊 Database Access (Development)**
```bash
# View database tables
sqlite3 backend/mediationai.db ".tables"

# Check users
sqlite3 backend/mediationai.db "SELECT id, email, created_at FROM users;"

# Check disputes
sqlite3 backend/mediationai.db "SELECT id, title, status, created_at FROM disputes;"

# Check evidence
sqlite3 backend/mediationai.db "SELECT id, filename, file_type FROM evidence;"
```

#### **🌐 API Access (Production)**
```bash
# Health check
curl https://mediationai-3ueg.vercel.app/api/health

# Get current user (requires JWT token)
curl -H "Authorization: Bearer YOUR_JWT_TOKEN" \
     https://mediationai-3ueg.vercel.app/api/me

# Get user disputes
curl -H "Authorization: Bearer YOUR_JWT_TOKEN" \
     https://mediationai-3ueg.vercel.app/api/disputes
```

### **🔒 Data Security**

#### **🛡️ Security Features**
- **Password Hashing**: bcrypt with salt rounds
- **JWT Tokens**: Secure authentication with expiration
- **HTTPS Only**: All API communication encrypted
- **Token Validation**: Server-side token verification
- **Auto-Logout**: Expired tokens automatically cleared

#### **📋 Data Retention**
- **User Accounts**: Stored until account deletion
- **Dispute Data**: Stored permanently for legal compliance
- **JWT Tokens**: 30-day expiration, auto-refresh
- **Evidence Files**: Stored with dispute for legal record
- **AI Responses**: Cached for performance, stored for audit

### **🔄 Data Persistence**

#### **✅ What Persists**
- User login state (stays signed in)
- All dispute data across app restarts
- Evidence files and attachments
- Truth statements and responses
- AI mediation history
- Digital signatures and contracts

#### **🔄 What Resets**
- Temporary UI state
- Form inputs (cleared after submission)
- Error messages
- Loading states

---

## 🌟 Features

### 🤖 **AI-Powered Mediation**
- **Smart Interventions**: AI only intervenes when necessary (cost-optimized)
- **Multiple AI Agents**: Mediator, Arbitrator, Facilitator, and Analyst
- **Sentiment Analysis**: Detects escalation and emotional states
- **Truth Discovery**: AI asks targeted questions to uncover facts

### 🏛️ **Legal Research Integration**
- **Harvard Law API**: 6.5 million legal cases (FREE)
- **Precedent Lookup**: Finds relevant case law automatically
- **Legal Analysis**: AI considers actual court decisions
- **360 Years**: of U.S. legal precedent

### 📄 **Contract Generation**
- **AI-Generated Contracts**: Legally binding dispute resolution agreements
- **Digital Signatures**: Electronic signing capability
- **Legal Compliance**: Proper legal structure and clauses
- **Automatic Creation**: When user selects "Make Contract" checkbox

### 💰 **Cost Optimization**
- **Smart Limits**: Maximum 3 AI interventions per dispute
- **Response Caching**: Avoids duplicate API calls
- **Token Limits**: Caps response length (300 tokens max)
- **Cooldown Periods**: 10-minute delays between interventions
- **Cheap Models**: Uses GPT-3.5-turbo by default

---

## 🏗️ Architecture

### **Backend** (Python FastAPI)
```
backend/
├── mediation_api.py        # Main API endpoints
├── mediation_agents.py     # AI mediation agents
├── ai_cost_controller.py   # Cost optimization
├── contract_generator.py   # Legal contract creation
├── legal_research.py       # Harvard Law API integration
├── dispute_models.py       # Data models
├── config.py              # Configuration settings
├── requirements.txt        # Python dependencies
└── vercel.json            # Vercel deployment config
```

### **Frontend** (Swift iOS)
```
frontend/
├── MediationAIApp.swift    # Main app entry point
├── homeview.swift          # Dashboard
├── disputeroomview.swift   # Dispute interface
├── createdisputeview.swift # Create new disputes
├── RealDisputeService.swift # API communication
├── APIConfig.swift         # Backend connection
└── Info.plist            # iOS app configuration
```

### **Guides** (Documentation)
```
guides/
├── API_SETUP_GUIDE.md             # API setup instructions
├── DEPLOYMENT_GUIDE.md            # Deployment instructions
├── COST_OPTIMIZATION_GUIDE.md     # Cost management
├── DISPUTE_FLOW_ANALYSIS.md       # Dispute flow analysis
├── iOS_Deployment_Guide.md        # iOS deployment guide
├── iPhone_UI_Improvements_Summary.md # UI improvements
├── MediationAI_Revisions_Summary.md # Recent revisions
└── NEXT_ESCROW_FEATURES.md        # Upcoming features
```

### **Communication Flow**
```
iOS App → HTTP/HTTPS → Vercel Backend → OpenAI/Anthropic → Harvard Law API
```

---

## 🚀 Quick Start

### **Step 1: Get API Keys**

#### **1.1 OpenAI API Key (Required)**
1. **Visit**: https://platform.openai.com/api-keys
2. **Sign up** for an OpenAI account (if you don't have one)
3. **Click** "Create new secret key"
4. **Name it**: "MediationAI"
5. **Copy the key** (starts with `sk-`)
6. **Save it** - you'll need it for deployment

   Api key - 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

**Cost**: ~$5-20/month for typical usage

#### **1.2 Harvard Law API Key (Optional but Recommended - FREE)**
1. **Visit**: https://case.law/api/
2. **Click** "Register for API Access"
3. **Fill out form** with:
   - Name: Your name
   - Email: Your email
   - Project: "MediationAI - AI-powered dispute resolution"
   - Use case: "Legal precedent research for dispute mediation"
4. **Submit** and wait for approval email (usually instant)
5. **Copy your API key** from the email

**Cost**: Completely FREE!

#### **1.3 Anthropic API Key (Optional)**
1. **Visit**: https://console.anthropic.com/
2. **Sign up** for Anthropic account
3. **Go to** API Keys section
4. **Create new key**
5. **Copy the key**

**Cost**: ~$5-20/month (only if you want both OpenAI and Anthropic)

### **Step 2: Deploy Backend to Vercel**

**📝 Summary: You just need to (1) upload the backend folder to Vercel, then (2) add 3 API keys in the dashboard. That's it!**

#### **2.1 Create Vercel Account**
1. **Visit**: https://vercel.com
2. **Sign up** for a free account (GitHub login recommended)
3. **Verify your email** if prompted
4. **Complete setup** - you're ready to deploy!

#### **2.2 Deploy Using Vercel Website**
**⚠️ Important: You DON'T need to edit any .env files! Just upload the backend folder as-is.**
1. **Go to** https://vercel.com/dashboard
2. **Click** "Add New..." → "Project"
3. **Import** your project:
   - If from GitHub: Click "Import Git Repository" and select your repo
   - If from computer: Click "Deploy" and drag your `backend/` folder
4. **Configure project**:
   - Project Name: `mediation-ai-backend`
   - Framework: `Other` (for Python)
   - Root Directory: `./` (if you uploaded just the backend folder)
5. **Click** "Deploy"
6. **Wait** for deployment (usually 1-2 minutes)

📱 **Vercel will automatically detect your Python app and deploy it!**

#### **2.3 Add Your API Keys (This is the ONLY place you need to put them!)**
1. **Go to** https://vercel.com/dashboard
2. **Click** your deployed project (`mediation-ai-backend`)
3. **Go to** **Settings** → **Environment Variables**
4. **Add ONLY these 3 variables** by clicking "Add New":

| Variable Name | Value | Where to Get It |
|---------------|-------|-----------------|
| `OPENAI_API_KEY` | `sk-your-actual-openai-key-here` | From Step 1.1 above |
| `HARVARD_CASELAW_API_KEY` | `your-harvard-key-here` | From Step 1.2 above (optional) |
| `SECRET_KEY` | `your-secure-password-123` | Make up any secure password |

**That's it! The other settings are already configured in the code.**

5. **Click** "Save" after adding each variable
6. **Wait** for Vercel to redeploy automatically (about 30 seconds)

#### **2.4 Get Your API URL**
1. **After deployment** completes, go to your project dashboard
2. **Copy the Production URL** (looks like: `https://mediation-ai-backend-abc123.vercel.app`)
3. **Or click** "Visit" to see your live backend

**🔥 SAVE THIS URL - You need it for the iOS app!**

https://mediationai-3ueg.vercel.app

### **Step 3: Test Your Backend**

#### **3.1 Test API Documentation**
1. **Visit** `https://your-vercel-url.vercel.app/docs` in your browser
2. **You should see** the FastAPI documentation interface
3. **This confirms** your backend is working correctly

#### **3.2 Test Health Check**
1. **Visit** `https://your-vercel-url.vercel.app/api/health` in your browser
2. **You should see** a JSON response like:
```json
{
  "status": "healthy",
  "service": "MediationAI API",
  "features": {
    "ai_mediation": true,
    "legal_research": true,
    "contract_generation": true,
    "cost_optimization": true
  }
}
```

#### **3.3 Test Cost Settings**
1. **Visit** `https://your-vercel-url.vercel.app/api/cost-settings` in your browser
2. **You should see** cost optimization settings:
```json
{
  "cost_optimization_enabled": true,
  "max_interventions_per_dispute": 3,
  "max_tokens_per_response": 300,
  "ai_model": "gpt-3.5-turbo"
}
```

**✅ If all tests pass, your backend is ready!**

### **Step 4: Configure iOS App**

#### **4.1 Create Xcode Project**
1. **Open Xcode**
2. **File** → **New** → **Project**
3. **iOS** → **App**
4. **Settings:**
   - Product Name: `MediationAI`
   - Interface: `SwiftUI`
   - Language: `Swift`
   - Bundle Identifier: `com.yourname.mediationai`
5. **Save** to your desired location

#### **4.2 Import Frontend Files**
1. **Delete default files** from Xcode:
   - Right-click `ContentView.swift` → Delete
   - Right-click `MediationAIApp.swift` → Delete

2. **Add all Swift files** from `frontend/` folder:
   - Drag all `.swift` files into Xcode project
   - ✅ Check **"Copy items if needed"**
   - ✅ Check **"Add to target: MediationAI"**

3. **Replace Info.plist**:
   - Replace default `Info.plist` with the one from `frontend/` folder

#### **4.3 Update API Configuration**
1. **Open `APIConfig.swift`** in Xcode
2. **Replace the baseURL** with your Vercel URL:
   ```swift
   // Replace this line:
   static let baseURL = "https://your-vercel-backend.vercel.app"
   
   // With your actual Vercel URL:
   static let baseURL = "https://mediation-ai-backend-abc123.vercel.app"
   ```

#### **4.4 Replace Mock Services**
1. **Find your main app file** (usually `MediationAIApp.swift`)
2. **Replace MockAuthService** with RealDisputeService:
   ```swift
   // OLD (remove this):
   @StateObject private var authService = MockAuthService()
   
   // NEW (add this):
   @StateObject private var disputeService = RealDisputeService()
   ```

#### **4.5 Build and Test**
1. **Connect your iPhone** via USB
2. **Trust the computer** on your iPhone if prompted
3. **Enable Developer Mode** on iPhone:
   - Settings → Privacy & Security → Developer Mode → Enable
4. **Select your iPhone** as the run destination in Xcode
5. **Build and run**: Press `Cmd+R` or click ▶️

### **Step 5: Test the Complete Flow**

#### **5.1 Test Backend Connection**
```bash
# Test from terminal
curl https://your-vercel-url.vercel.app/api/health

# Expected response:
{
  "status": "healthy",
  "service": "MediationAI API",
  "features": {
    "ai_mediation": true,
    "legal_research": true,
    "contract_generation": true,
    "cost_optimization": true
  }
}
```

#### **5.2 Test iOS App Flow**
1. **Open app** on iPhone
2. **Register new user** (test registration)
3. **Create dispute** with these settings:
   - Title: "Test Contract Dispute"
   - Description: "Testing the AI mediation system"
   - Category: "Contract"
   - ✅ **Check "Create Contract"** checkbox
4. **Submit evidence** from both parties
5. **Watch AI analyze** and generate resolution
6. **View generated contract** (if checkbox was checked)

#### **5.3 Monitor Costs**
```bash
# Check cost settings
curl https://your-vercel-url.vercel.app/api/cost-settings

# Expected response shows cost optimization is enabled
{
  "cost_optimization_enabled": true,
  "max_interventions_per_dispute": 3,
  "max_tokens_per_response": 300,
  "ai_model": "gpt-3.5-turbo"
}
```

---

## 💰 Cost Control

### **Built-in Cost Optimization**

Your system includes smart cost controls to keep API expenses minimal:

```python
# Configuration (.env)
MAX_AI_INTERVENTIONS=3          # Max AI responses per dispute
MAX_AI_TOKENS=300              # Token limit per response
AI_COOLDOWN_MINUTES=10         # Delay between interventions
AI_MODEL_PREFERENCE=gpt-3.5-turbo  # Cheaper than GPT-4
```

### **Smart Intervention Logic**

AI only intervenes when:
- ✅ Sentiment becomes very negative (< -0.4)
- ✅ Every 10 messages (to check progress)
- ✅ Escalation detected (angry language)
- ✅ Conversation stalls (repetitive messages)

### **Cost Estimates**

| Usage Level | Monthly Cost | Disputes/Month |
|-------------|-------------|----------------|
| **Light**   | $5-10       | 50-100         |
| **Medium**  | $10-20      | 100-200        |
| **Heavy**   | $20-40      | 200-400        |

*Based on OpenAI pricing with cost optimization enabled*

---

## 📱 Mobile App

### **Setup Instructions**

1. **Create Xcode Project**
   - Product Name: `MediationAI`
   - Interface: SwiftUI
   - Language: Swift

2. **Add Swift Files**
   - Copy all `.swift` files from `frontend/` to Xcode
   - Include `APIConfig.swift`, `RealDisputeService.swift`

3. **Configure Backend Connection**
   ```swift
   // APIConfig.swift
   static let baseURL = "https://your-vercel-url.vercel.app"
   ```

4. **Replace Mock Services**
   ```swift
   // In your main app file
   @StateObject private var disputeService = RealDisputeService()
   ```

### **Key Features**
- ✅ User authentication
- ✅ Dispute creation with contract checkbox
- ✅ Truth/evidence submission
- ✅ Real-time AI mediation
- ✅ Resolution viewing
- ✅ Contract generation and signing

---

## 🔧 Configuration

### **Environment Variables**

```bash
# AI API Keys (Required - choose one or both)
OPENAI_API_KEY=sk-your-openai-key-here
ANTHROPIC_API_KEY=your-anthropic-key-here

# Legal Research (Optional - FREE)
HARVARD_CASELAW_API_KEY=your-free-harvard-key

# Cost Control (Important!)
MAX_AI_INTERVENTIONS=3
MAX_AI_TOKENS=300
AI_COOLDOWN_MINUTES=10
ENABLE_AI_COST_OPTIMIZATION=True

# AI Model Settings
AI_MODEL_PREFERENCE=gpt-3.5-turbo
AI_TEMPERATURE=0.3
ENABLE_AI_CACHING=True

# System Settings
SECRET_KEY=your-secret-key-here
DEBUG=False
```

### **Cost Control Settings**

| Setting | Default | Purpose |
|---------|---------|---------|
| `MAX_AI_INTERVENTIONS` | 3 | Maximum AI responses per dispute |
| `MAX_AI_TOKENS` | 300 | Token limit per response |
| `AI_COOLDOWN_MINUTES` | 10 | Delay between interventions |
| `AI_MODEL_PREFERENCE` | gpt-3.5-turbo | Cheaper than GPT-4 |
| `ENABLE_AI_CACHING` | True | Avoid duplicate API calls |

---

## 🧪 Testing

### **Backend Testing**
```bash
# Test API endpoints
curl https://your-vercel-url.vercel.app/docs

# Test dispute creation
curl -X POST https://your-vercel-url.vercel.app/api/disputes \
  -H "Content-Type: application/json" \
  -d '{"title":"Test","description":"Testing","category":"contract"}'
```

### **Frontend Testing**
1. Build app in Xcode
2. Test user registration/login
3. Create dispute with contract checkbox
4. Submit evidence from both parties
5. Verify AI generates resolution + contract

## 🔧 Troubleshooting

### **Common Backend Issues**

#### **❌ "OpenAI API key not found"**
```bash
# Check if environment variables are set
vercel env ls

# Add missing OpenAI key
vercel env add OPENAI_API_KEY
```

#### **❌ "Build failed on Vercel"**
```bash
# Check your requirements.txt
cat requirements.txt

# Redeploy with verbose output
vercel --debug
```

#### **❌ "API timeout errors"**
```bash
# Check cost optimization settings
curl https://your-vercel-url.vercel.app/api/cost-settings

# Verify MAX_AI_TOKENS is set to 300 or less
vercel env add MAX_AI_TOKENS
# Enter: 300
```

### **Common Frontend Issues**

#### **❌ "Cannot connect to backend"**
1. **Check APIConfig.swift** has correct Vercel URL
2. **Test backend** in browser: `https://your-vercel-url.vercel.app/api/health`
3. **Check network permissions** in iOS app

#### **❌ "App won't build in Xcode"**
1. **Clean build folder**: Product → Clean Build Folder
2. **Check iOS deployment target**: iOS 15.0+
3. **Ensure all Swift files** are added to target

#### **❌ "iPhone not recognized"**
1. **Trust computer** on iPhone
2. **Enable Developer Mode**: Settings → Privacy & Security → Developer Mode
3. **Try different USB cable**

### **Performance Issues**

#### **❌ "AI responses are slow"**
```bash
# Check if you're using GPT-4 (expensive and slow)
vercel env add AI_MODEL_PREFERENCE
# Enter: gpt-3.5-turbo

# Reduce token limit
vercel env add MAX_AI_TOKENS
# Enter: 200
```

#### **❌ "High API costs"**
```bash
# Enable cost optimization
vercel env add ENABLE_AI_COST_OPTIMIZATION
# Enter: true

# Reduce interventions
vercel env add MAX_AI_INTERVENTIONS
# Enter: 2
```

### **Getting Help**

#### **Check Logs**
```bash
# View Vercel deployment logs
vercel logs

# Check function logs
vercel logs --follow
```

#### **Test Individual Components**
```bash
# Test OpenAI connection
curl -X POST https://your-vercel-url.vercel.app/api/test-openai

# Test Harvard Law API
curl https://your-vercel-url.vercel.app/api/test-harvard

# Test cost controller
curl https://your-vercel-url.vercel.app/api/cost-settings
```

### **Success Indicators**

#### **✅ Backend is Working**
- Health check returns status "healthy"
- API docs accessible at `/docs`
- Cost settings show optimization enabled
- No errors in Vercel logs

#### **✅ Frontend is Working**
- App builds without errors
- Can register and login users
- Can create disputes with contract checkbox
- AI responds to evidence submissions
- Contracts are generated when requested

### **Cost Monitoring**
```python
# Check cost summary
GET /api/disputes/{dispute_id}/cost-summary

# Response:
{
    "interventions": 2,
    "estimated_cost": 0.10,
    "limit_reached": false,
    "in_cooldown": false
}
```

---

## 🚢 Deployment

### **Backend Deployment (Vercel)**

```bash
# Deploy to Vercel
cd backend
vercel

# Set environment variables
vercel env add OPENAI_API_KEY
vercel env add HARVARD_CASELAW_API_KEY
```

### **Frontend Deployment (iOS)**

1. **Xcode Deployment**
   - Connect iPhone via USB
   - Select iPhone as target
   - Build and run

2. **TestFlight (Optional)**
   - Archive app in Xcode
   - Upload to App Store Connect
   - Distribute via TestFlight

### **Alternative: Web App**
```bash
# Create React/Vue.js version
npx create-react-app mediation-web
# Add PWA capabilities
# Deploy to Vercel/Netlify
```

---

## 🏛️ Legal Research

### **Harvard Law API Integration**

Your system automatically looks up legal precedents:

```python
# Example: Contract dispute
search_terms = ["contract breach", "payment dispute", "service agreement"]
precedents = await harvard_api.find_precedents("contract", search_terms)

# AI uses these in resolution:
"""
RELEVANT LEGAL CASES:
- Smith v. Jones (2020): Contract breach with similar terms
- ABC Corp v. XYZ (2019): Payment dispute resolution

LEGAL ANALYSIS:
Based on precedent in Smith v. Jones, the contract terms clearly state...

RESOLUTION:
Considering legal precedent and evidence submitted...
"""
```

### **Supported Categories**
- ✅ Contract disputes
- ✅ Payment disputes  
- ✅ Service agreements
- ✅ Property disputes
- ✅ Business partnerships
- ✅ Employment issues

---

## 📄 Contract Generation

### **AI-Powered Legal Contracts**

When users check "Make Contract" checkbox:

```python
# AI generates legal contract
contract = await contract_generator.generate_contract(dispute, resolution)

# Includes:
- Party information
- Resolution terms
- Payment provisions
- Deadlines
- Legal clauses
- Digital signature fields
```

### **Contract Features**
- ✅ Legally binding language
- ✅ Proper legal structure
- ✅ Digital signature support
- ✅ Jurisdiction clauses
- ✅ Enforcement provisions

---

## 🔄 API Endpoints

### **Core Endpoints**

```python
# User Management
POST /api/users/register
POST /api/users/login

# Dispute Management
POST /api/disputes                    # Create dispute
GET /api/disputes/{id}               # Get dispute details
POST /api/disputes/{id}/evidence     # Submit evidence
POST /api/disputes/{id}/resolve      # Trigger resolution

# Contract Generation
POST /api/disputes/{id}/contract/generate  # Generate contract
GET /api/disputes/{id}/contract           # Get contract
POST /api/disputes/{id}/contract/sign     # Sign contract

# Cost Monitoring
GET /api/disputes/{id}/cost-summary       # Cost breakdown
```

### **API Documentation**
After deployment, visit: `https://your-vercel-url.vercel.app/docs`

---

## 🤝 Contributing

### **Development Setup**

```bash
# Backend setup
cd backend
pip install -r requirements.txt
python main.py

# Frontend setup
# Open Xcode project
# Build and run
```

### **Code Structure**
- **Backend**: Python FastAPI with AI integrations
- **Frontend**: Swift/SwiftUI for iOS
- **AI**: OpenAI GPT-3.5/GPT-4 and Anthropic Claude
- **Legal**: Harvard Law API integration
- **Deployment**: Vercel for backend, Xcode for frontend

### **Next Features**
- 🔄 **Escrow System** (coming next)
- 🔐 **Enhanced Security**
- 📊 **Analytics Dashboard**
- 🌐 **Multi-language Support**

---

## 📊 Project Status

- ✅ **AI Mediation**: Fully implemented
- ✅ **Cost Control**: Smart limits and caching
- ✅ **Legal Research**: Harvard Law API integrated
- ✅ **Contract Generation**: AI-powered legal contracts
- ✅ **iOS App**: Native Swift/SwiftUI interface
- ✅ **Backend**: FastAPI with Vercel deployment
- 🔄 **Escrow System**: Coming next

---

## 📧 Support

For questions or issues:
- 📖 **Documentation**: Check `guides/API_SETUP_GUIDE.md`
- 🚀 **Deployment**: See `guides/DEPLOYMENT_GUIDE.md`
- 💰 **Cost Management**: See `guides/COST_OPTIMIZATION_GUIDE.md`
- 🐛 **Issues**: Create GitHub issue
- 💡 **Feature Requests**: Open GitHub discussion

---

## 📝 License

This project is available under the MIT License.

---

## ✅ Deployment Checklist

### **Pre-Deployment**
- [ ] **OpenAI API key** obtained from platform.openai.com
- [ ] **Harvard Law API key** obtained from case.law/api (optional but recommended)
- [ ] **Vercel account** created (free)
- [ ] **Xcode installed** (for iOS app)
- [ ] **iPhone** for testing (iOS 15.0+)

### **Backend Deployment**
- [ ] **Vercel CLI installed**: `npm install -g vercel`
- [ ] **Repository cloned**: `git clone https://github.com/yourusername/mediationai.git`
- [ ] **Dependencies installed**: `pip install -r requirements.txt`
- [ ] **Environment variables set** in `.env` file
- [ ] **Deployed to Vercel**: `vercel`
- [ ] **Environment variables added** to Vercel dashboard
- [ ] **API URL saved** from Vercel output
- [ ] **Health check passes**: `curl https://your-url.vercel.app/api/health`

### **Frontend Deployment**
- [ ] **Xcode project created** (iOS App, SwiftUI)
- [ ] **Swift files imported** from frontend/ folder
- [ ] **APIConfig.swift updated** with Vercel URL
- [ ] **MockAuthService replaced** with RealDisputeService
- [ ] **App builds successfully** in Xcode
- [ ] **iPhone connected** and recognized
- [ ] **Developer Mode enabled** on iPhone
- [ ] **App runs on iPhone**

### **Testing**
- [ ] **Backend API accessible** at /docs endpoint
- [ ] **User registration works** in iOS app
- [ ] **Dispute creation works** with contract checkbox
- [ ] **Evidence submission works** from both parties
- [ ] **AI generates resolution** automatically
- [ ] **Contract generation works** when checkbox selected
- [ ] **Cost optimization active** (check /api/cost-settings)

### **Production Ready**
- [ ] **Cost limits configured** (MAX_AI_INTERVENTIONS=3)
- [ ] **Token limits set** (MAX_AI_TOKENS=300)
- [ ] **Caching enabled** (ENABLE_AI_CACHING=true)
- [ ] **Monitoring setup** for costs and usage
- [ ] **Error handling tested**
- [ ] **User acceptance testing** completed

---

**🎉 Ready to resolve disputes with AI! Your cost-optimized mediation system is ready for production.**

**Next up: Escrow system for secure payment handling** 💰🔐

## Legal Documents

Publicly accessible versions (required for App Store Connect):

* **Privacy Policy** – https://mediationai-3ueg.vercel.app/privacy-policy.html
* **Terms of Service** – https://mediationai-3ueg.vercel.app/terms-of-service.html

## Last front-end sync

Updated on $(date)
