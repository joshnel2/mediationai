# 🤖⚖️ MediationAI - AI-Powered Dispute Resolution

**Resolve disputes fairly and efficiently with AI mediation, legal precedent lookup, and automated contract generation.**

![AI Mediation](https://img.shields.io/badge/AI-Mediation-blue)
![Legal Research](https://img.shields.io/badge/Legal-Research-green)
![Contract Generation](https://img.shields.io/badge/Contract-Generation-orange)
![Cost Optimized](https://img.shields.io/badge/Cost-Optimized-red)

## 📋 Table of Contents

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
- [🔄 API Endpoints](#-api-endpoints)
- [🤝 Contributing](#-contributing)

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
Backend/
├── mediation_api.py        # Main API endpoints
├── mediation_agents.py     # AI mediation agents
├── ai_cost_controller.py   # Cost optimization
├── contract_generator.py   # Legal contract creation
├── legal_research.py       # Harvard Law API integration
├── dispute_models.py       # Data models
└── config.py              # Configuration settings
```

### **Frontend** (Swift iOS)
```
Frontend/
├── MediationAIApp.swift    # Main app entry point
├── HomeView.swift          # Dashboard
├── DisputeRoomView.swift   # Dispute interface
├── CreateDisputeView.swift # Create new disputes
├── RealDisputeService.swift # API communication
└── APIConfig.swift         # Backend connection
```

### **Communication Flow**
```
iOS App → HTTP/HTTPS → Vercel Backend → OpenAI/Anthropic → Harvard Law API
```

---

## 🚀 Quick Start

### **1. Get API Keys**

#### **Required (Choose One):**
- **OpenAI**: https://platform.openai.com/api-keys ($5-20/month)
- **Anthropic**: https://console.anthropic.com/ ($5-20/month)

#### **Optional (Free):**
- **Harvard Law**: https://case.law/api/ (FREE - legal precedents)

### **2. Deploy Backend**

```bash
# Clone repository
git clone https://github.com/yourusername/mediationai.git
cd mediationai/backend

# Install dependencies
pip install -r requirements.txt

# Set up environment variables
cp .env.example .env
# Edit .env with your API keys

# Deploy to Vercel
npm install -g vercel
vercel login
vercel

# Set environment variables in Vercel dashboard
# Settings → Environment Variables
```

### **3. Configure iOS App**

```bash
# Update APIConfig.swift with your Vercel URL
static let baseURL = "https://your-vercel-backend.vercel.app"

# In Xcode, replace MockAuthService with RealDisputeService
@StateObject private var disputeService = RealDisputeService()
```

### **4. Test the Flow**

```swift
// Create dispute with contract
let disputeId = await disputeService.createDispute(
    title: "Test Dispute",
    description: "Testing the system",
    category: "contract",
    createContract: true  // ✅ Enables contract generation
)

// Submit evidence
await disputeService.submitTruth(
    disputeId: disputeId,
    content: "My side of the story with evidence...",
    attachments: []
)
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
- 📖 **Documentation**: Check `API_SETUP_GUIDE.md`
- 🐛 **Issues**: Create GitHub issue
- 💡 **Feature Requests**: Open GitHub discussion

---

## 📝 License

This project is available under the MIT License.

---

**🎉 Ready to resolve disputes with AI! Your cost-optimized mediation system is ready for production.**

**Next up: Escrow system for secure payment handling** 💰🔐