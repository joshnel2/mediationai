# MediationAI Deployment Guide

Complete guide to deploy your AI-powered dispute resolution system with **backend on Vercel** and **frontend on iOS**.

## 🎯 Overview

Your project is now separated into:
- **Backend** (`/backend/`) - Python FastAPI → Deploy to Vercel
- **Frontend** (`/frontend/`) - Swift iOS App → Deploy to iPhone

## 📋 Prerequisites Checklist

### ✅ Backend Requirements:
- [ ] Python 3.8+ installed
- [ ] Vercel account (free at https://vercel.com)
- [ ] OpenAI API key (required)
- [ ] Anthropic API key (optional)

### ✅ Frontend Requirements:
- [ ] Mac with macOS 12.0+
- [ ] Xcode 14.0+ installed
- [ ] iPhone with iOS 15.0+
- [ ] Apple Developer Account (free)

## 🚀 Step-by-Step Deployment

### Phase 1: Backend Deployment (Vercel)

#### 1.1 Get API Keys
```bash
# Get OpenAI API Key (REQUIRED)
# Visit: https://platform.openai.com/api-keys
# Create account → Generate new key → Copy key

# Get Anthropic API Key (OPTIONAL)
# Visit: https://console.anthropic.com/
# Create account → Generate new key → Copy key
```

#### 1.2 Deploy to Vercel
```bash
# Install Vercel CLI
npm install -g vercel

# Navigate to backend directory
cd backend

# Login to Vercel
vercel login

# Deploy backend
vercel

# Follow prompts:
# - Link to existing project? → No
# - Project name → mediation-ai-backend
# - Directory → ./
# - Override settings? → No
```

#### 1.3 Set Environment Variables
1. Go to https://vercel.com/dashboard
2. Select your project → **Settings** → **Environment Variables**
3. Add these variables:

```env
OPENAI_API_KEY=sk-your-actual-openai-key-here
ANTHROPIC_API_KEY=your-anthropic-key-here
SECRET_KEY=your-secret-key-change-this
DEBUG=False
```

#### 1.4 Save Your API URL
After deployment, Vercel gives you a URL like:
```
https://mediation-ai-backend-xxx.vercel.app
```
**🔥 SAVE THIS URL - You'll need it for the frontend!**

#### 1.5 Test Backend
```bash
# Test your deployed API
curl https://your-vercel-url.vercel.app/docs

# Should show API documentation
```

### Phase 2: Frontend Deployment (iOS)

#### 2.1 Create Xcode Project
1. **Open Xcode**
2. **File** → **New** → **Project**
3. **iOS** → **App**
4. **Settings:**
   - Product Name: `MediationAI`
   - Interface: `SwiftUI`
   - Language: `Swift`
   - Bundle Identifier: `com.yourname.mediationai`

#### 2.2 Import Frontend Files
1. **Delete default files:**
   - Delete `ContentView.swift` and `MediationAIApp.swift`

2. **Add all Swift files:**
   - Drag ALL `.swift` files from `frontend/` folder to Xcode
   - ✅ Check **"Copy items if needed"**
   - ✅ Check **"Add to target: MediationAI"**

3. **Replace Info.plist:**
   - Replace default `Info.plist` with the one from `frontend/`

#### 2.3 Configure Backend URL
1. **Open `APIConfig.swift`** in Xcode
2. **Update the baseURL:**
   ```swift
   // Replace this line:
   static let baseURL = "https://your-vercel-backend.vercel.app"
   
   // With your actual Vercel URL:
   static let baseURL = "https://mediation-ai-backend-xxx.vercel.app"
   ```

#### 2.4 Build and Deploy
1. **Connect iPhone** via USB
2. **Trust computer** on iPhone
3. **Enable Developer Mode:**
   - iPhone Settings → Privacy & Security → Developer Mode → Enable
4. **Select iPhone** as target in Xcode
5. **Press** `Cmd+R` or click ▶️ **Run**

## 🧪 Testing Your Deployment

### Backend Tests:
```bash
# Test API documentation
open https://your-vercel-url.vercel.app/docs

# Test health endpoint
curl https://your-vercel-url.vercel.app/api/health

# Test user registration
curl -X POST https://your-vercel-url.vercel.app/api/users/register \
  -H "Content-Type: application/json" \
  -d '{"username":"testuser","email":"test@test.com","password":"testpass"}'
```

### Frontend Tests:
1. **App launches** without crashes
2. **Registration works** (creates new user)
3. **Login works** (authenticates user)
4. **API calls succeed** (check Xcode console)
5. **Dispute creation works**

## 🔧 Configuration Details

### Backend Configuration (`backend/.env`):
```env
# Core API Keys
OPENAI_API_KEY=sk-your-key-here
ANTHROPIC_API_KEY=your-key-here

# Security
SECRET_KEY=change-this-in-production
DEBUG=False

# Optional Legal APIs
HARVARD_CASELAW_API_KEY=your-key-here
LEXIS_NEXIS_API_KEY=your-key-here
WESTLAW_API_KEY=your-key-here
```

### Frontend Configuration (`frontend/APIConfig.swift`):
```swift
// Update this with your Vercel URL
static let baseURL = "https://your-vercel-backend.vercel.app"

// App configuration
static let appDomain = "mediationai.app"
static let requestTimeout: TimeInterval = 30.0
```

## 🚨 Troubleshooting

### Backend Issues:

**❌ Build Failed:**
```bash
# Check Python version
python --version  # Should be 3.8+

# Check requirements
pip install -r requirements.txt

# Test locally first
python main.py
```

**❌ API Key Errors:**
- Verify environment variables in Vercel dashboard
- Check API key format (OpenAI keys start with `sk-`)
- Test API keys locally first

**❌ Timeout Errors:**
- Vercel free tier has 10-second timeout
- Consider upgrading to Pro for longer timeouts
- Optimize slow API calls

### Frontend Issues:

**❌ Build Errors:**
- Ensure all Swift files are in Xcode project
- Check deployment target is iOS 15.0+
- Clean build: Product → Clean Build Folder

**❌ API Connection Failed:**
- Verify backend URL is correct in `APIConfig.swift`
- Test backend URL in browser first
- Check network permissions in iOS

**❌ iPhone Not Recognized:**
- Trust computer on iPhone
- Enable Developer Mode
- Try different USB cable

## 🎉 Success Checklist

### ✅ Backend Success:
- [ ] Vercel deployment completed
- [ ] Environment variables set
- [ ] API documentation accessible at `/docs`
- [ ] Health check returns success
- [ ] User registration works

### ✅ Frontend Success:
- [ ] Xcode project builds without errors
- [ ] App launches on iPhone
- [ ] Registration/login works
- [ ] API calls succeed
- [ ] Dispute creation works

## 📱 Next Steps

### Optional Enhancements:
1. **Custom Domain:** Add custom domain in Vercel
2. **Database:** Add persistent database (PostgreSQL)
3. **TestFlight:** Deploy to TestFlight for beta testing
4. **Push Notifications:** Add real-time notifications
5. **App Store:** Submit to App Store for public release

### Production Considerations:
- **Security:** Use proper authentication tokens
- **Monitoring:** Add error tracking and analytics
- **Scaling:** Consider database and caching
- **Backup:** Implement data backup strategies

## 🤝 Need Help?

### Resources:
- **Backend Issues:** Check Vercel logs and `/docs` endpoint
- **Frontend Issues:** Check Xcode console and device logs
- **API Issues:** Test endpoints individually
- **Deployment Issues:** Follow error messages step-by-step

### Support:
- Check deployment logs in Vercel dashboard
- Test API endpoints in browser
- Use Xcode debugger for iOS issues
- Review error messages carefully

---

## 🏆 Congratulations!

You now have:
- ✅ **Backend** running on Vercel with AI capabilities
- ✅ **iOS app** connected to your backend
- ✅ **Complete dispute resolution system** ready for users

Your AI-powered mediation platform is live! 🚀

**Share your app and help resolve disputes with AI!** 🤝⚖️