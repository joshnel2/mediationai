# MediationAI

An AI-powered dispute resolution system with a **Python FastAPI backend** and **Swift iOS frontend**.

## 📁 Project Structure

```
mediationai/
├── backend/                    # Python FastAPI Backend
│   ├── main.py                 # Vercel entry point
│   ├── mediation_api.py        # Main API application
│   ├── mediation_agents.py     # AI mediation agents
│   ├── dispute_models.py       # Data models
│   ├── config.py               # Configuration
│   ├── requirements.txt        # Python dependencies
│   ├── vercel.json             # Vercel deployment config
│   ├── .env.example            # Environment variables template
│   └── README.md               # Backend deployment guide
│
├── frontend/                   # Swift iOS Frontend
│   ├── MediationAIApp.swift    # Main app entry point
│   ├── HomeView.swift          # Main dashboard
│   ├── DisputeRoomView.swift   # Core mediation interface
│   ├── User.swift              # Data models & API calls
│   ├── Info.plist              # iOS app configuration
│   └── README.md               # Frontend deployment guide
│
└── README.md                   # This file
```

## 🚀 Quick Start

### 1. Deploy Backend to Vercel
```bash
cd backend
# Follow backend/README.md for complete instructions
```
**Get your API URL**: `https://your-project.vercel.app`

### 2. Deploy Frontend to iPhone
```bash
cd frontend
# Follow frontend/README.md for complete instructions
```
**Update API URL** in Swift code to point to your Vercel backend.

## 🔧 Deployment Options

### Backend (Python FastAPI)
- ✅ **Vercel** (Recommended) - Serverless, free tier
- ⚡ **Railway** - Simple deployment with database support
- 🐳 **Docker** - Containerized deployment
- 🖥️ **VPS** - Traditional server deployment

### Frontend (Swift iOS)
- ✅ **Xcode** (Recommended) - Native iOS deployment
- 📱 **TestFlight** - Beta testing distribution
- 🌐 **Web App** - Progressive Web App alternative
- ⚛️ **React Native** - Cross-platform mobile

## 📋 Prerequisites

### For Backend:
- Python 3.8+
- OpenAI API Key (required)
- Vercel account (free)

### For Frontend:
- macOS 12.0+
- Xcode 14.0+
- iPhone with iOS 15.0+
- Apple Developer Account (free)

## 🎯 Complete Setup Guide

### Step 1: Backend Setup
1. **Get API Keys**:
   - OpenAI: https://platform.openai.com/api-keys
   - Anthropic: https://console.anthropic.com/ (optional)

2. **Deploy to Vercel**:
   ```bash
   cd backend
   # Follow detailed instructions in backend/README.md
   ```

3. **Save your API URL**: `https://your-project.vercel.app`

### Step 2: Frontend Setup
1. **Create Xcode Project**:
   - Open Xcode → New Project → iOS App
   - Product Name: `MediationAI`
   - Interface: SwiftUI

2. **Import Swift Files**:
   ```bash
   # Copy all .swift files from frontend/ to Xcode project
   ```

3. **Configure Backend URL**:
   - Update API URLs in Swift code
   - Replace `localhost:8000` with your Vercel URL

4. **Build and Run**:
   - Connect iPhone → Run in Xcode

## 🔑 Environment Variables

Create `backend/.env` with your API keys:
```bash
# Required (choose one or both)
OPENAI_API_KEY=sk-your-openai-key-here
ANTHROPIC_API_KEY=your-anthropic-key-here

# Optional (free Harvard Law API for legal precedents)
HARVARD_CASELAW_API_KEY=your-free-harvard-key-here

# System
SECRET_KEY=your-secret-key-here
```

**📖 See `API_SETUP_GUIDE.md` for detailed API setup instructions**

## 🧪 Testing

### Backend Testing:
```bash
# Test API after deployment
curl https://your-vercel-url.vercel.app/docs
```

### Frontend Testing:
1. Build app in Xcode
2. Test registration/login
3. Verify API connectivity
4. Test dispute creation

## 🚨 Important Notes

### Backend Deployment:
- **Vercel** has 10-second timeout for free tier
- **Environment variables** must be set in Vercel dashboard
- **API keys** are required for AI functionality

### Frontend Deployment:
- **Mac required** for Xcode deployment
- **API URL** must be updated in Swift code
- **Bundle identifier** must be unique

## 📚 Documentation

- **Backend API**: Visit `/docs` endpoint after deployment
- **Frontend Guide**: See `frontend/README.md`
- **Backend Guide**: See `backend/README.md`

## 🔍 Troubleshooting

### Common Issues:
1. **Backend won't deploy**: Check requirements.txt and Python version
2. **API connection fails**: Verify Vercel URL and environment variables
3. **iOS build errors**: Ensure all Swift files are in Xcode project
4. **API keys not working**: Check environment variables in Vercel

### Getting Help:
- Check deployment logs in Vercel dashboard
- Test API endpoints in browser
- Verify environment variables are set
- Check Xcode console for iOS errors

## 🎉 Success!

After following both guides:
- ✅ Backend running on Vercel
- ✅ iOS app connected to backend
- ✅ Full dispute resolution system ready

Your AI-powered mediation app is now live! 🚀

## 📝 Next Steps

1. **Customize UI** - Update colors, branding, features
2. **Add Features** - Implement additional functionality
3. **Beta Testing** - Deploy to TestFlight for user testing
4. **Production** - Deploy to App Store when ready

## 🤝 Contributing

1. Fork the repository
2. Create feature branch
3. Make changes in appropriate directory (backend/ or frontend/)
4. Submit pull request

## 📄 License

This project is available under the MIT License.