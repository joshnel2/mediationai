# MediationAI iOS App

Native iOS app built with SwiftUI for AI-powered dispute resolution.

## 📱 Deploy to iPhone

### Prerequisites
- Mac with macOS 12.0+ (for Xcode deployment)
- Xcode 14.0+ (free from App Store)
- iPhone with iOS 15.0+
- Apple Developer Account (free for personal use)

### Step 1: Create Xcode Project
1. **Open Xcode**
2. **File** → **New** → **Project**
3. Choose: **iOS** → **App**
4. **Project Settings:**
   - Product Name: `MediationAI`
   - Interface: `SwiftUI`
   - Language: `Swift`
   - Bundle Identifier: `com.yourname.mediationai`
5. **Save** to your desired location

### Step 2: Import Swift Files
1. **Delete default files:**
   - Right-click and delete `ContentView.swift` and `MediationAIApp.swift`
   
2. **Add frontend files:**
   - Drag ALL `.swift` files from this `frontend/` folder into your Xcode project
   - Select: ✅ **"Copy items if needed"**
   - Select: ✅ **"Add to target: MediationAI"**
   
3. **Replace Info.plist:**
   - Replace the default `Info.plist` with the one from this folder

### Step 3: Configure Backend Connection

**IMPORTANT**: You need to update the API URL in your Swift code to point to your Vercel backend.

#### Find and Update API Configuration:
Look for files that contain `localhost:8000` and replace with your Vercel URL:

```swift
// OLD (local development):
let apiBaseURL = "http://localhost:8000"

// NEW (Vercel deployment):
let apiBaseURL = "https://your-vercel-url.vercel.app"
```

#### Common files to check:
- `User.swift` - API service calls
- `MockAuthService.swift` - Authentication endpoints
- Any file with HTTP requests or API calls

### Step 4: Build and Run
1. **Connect iPhone** via USB
2. **Trust computer** on iPhone if prompted
3. **Enable Developer Mode** on iPhone:
   - Settings → Privacy & Security → Developer Mode → Enable
4. **Select iPhone** as run destination in Xcode
5. **Press** `Cmd+R` or click ▶️ **Run**

## 🌐 Alternative: Web App Deployment

If you don't have a Mac, you can create a web version:

### Option A: Convert to React Native
```bash
# Install Expo CLI
npm install -g @expo/cli

# Create new project
npx create-expo-app MediationAI-Mobile
cd MediationAI-Mobile

# Recreate your SwiftUI views using React Native components
# Update API calls to point to your Vercel backend
```

### Option B: Progressive Web App (PWA)
```bash
# Create React app
npx create-react-app mediation-web
cd mediation-web

# Add PWA capabilities
npm install workbox-webpack-plugin

# Build responsive web version
# Deploy to Vercel/Netlify
```

## 🔧 Backend Integration

### API Configuration
Make sure your app connects to the correct backend:

```swift
// In your API service file
struct APIConfig {
    static let baseURL = "https://your-vercel-backend.vercel.app"
    static let endpoints = [
        "register": "/api/users/register",
        "login": "/api/users/login",
        "createDispute": "/api/disputes/create",
        "getDisputes": "/api/disputes/user"
    ]
}
```

### Testing Connection
Before deploying, test your backend connection:
1. Open `https://your-vercel-backend.vercel.app/docs` in browser
2. Verify API endpoints are working
3. Test registration/login from your app

## 📋 Project Structure

```
frontend/
├── MediationAIApp.swift        # Main app entry point
├── RootView.swift              # Root navigation
├── OnboardingView.swift        # Welcome screens
├── AuthView.swift              # Login/signup
├── HomeView.swift              # Main dashboard
├── DisputeRoomView.swift       # Core mediation
├── CreateDisputeView.swift     # Create disputes
├── User.swift                  # Data models & API calls
├── MockAuthService.swift       # Auth service
├── AppTheme.swift              # App styling
└── [Other Views]               # Additional components
```

## 🔍 Troubleshooting

### Common Issues:

1. **App won't build:**
   - Check all Swift files are added to target
   - Verify iOS deployment target is 15.0+
   - Clean build folder: Product → Clean Build Folder

2. **API connection fails:**
   - Verify Vercel backend is deployed and running
   - Check API URL is correct in Swift code
   - Test backend at `/docs` endpoint

3. **Code signing errors:**
   - Sign in with Apple ID in Xcode preferences
   - Select your development team in project settings

4. **iPhone not recognized:**
   - Trust computer on iPhone
   - Enable Developer Mode in iPhone settings
   - Try different USB cable/port

### Getting Help:
- Check Xcode console for error messages
- Test API endpoints in browser first
- Verify backend is deployed successfully

## 🎯 Quick Test Checklist

After setup, verify:
- ✅ App builds without errors
- ✅ App runs on iPhone/simulator
- ✅ Registration/login works
- ✅ Backend API calls succeed
- ✅ All main screens display correctly

## 📝 Next Steps

1. ✅ Set up Xcode project
2. ✅ Import all Swift files
3. ✅ Configure backend URL
4. ✅ Build and run on iPhone
5. 🔄 Test all app features
6. 🔄 Deploy to TestFlight (optional)

Your iOS app is now connected to your live backend! 🎉

## 🚀 Optional: App Store Deployment

For App Store distribution:
1. **Apple Developer Program** ($99/year)
2. **Archive app** in Xcode
3. **Upload to App Store Connect**
4. **Submit for review**

Your app is ready for users! 📱✨