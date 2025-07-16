# MediationAI iOS App - Deployment Guide

## Overview
Your MediationAI app is a native iOS Swift/SwiftUI application. To get it running on your iPhone, you have several options:

## Option 1: Deploy via macOS with Xcode (Recommended)

### Prerequisites
- Mac computer with macOS 12.0 or later
- Xcode 14.0 or later (free from Mac App Store)
- Apple Developer Account (free for personal use, $99/year for App Store distribution)
- iPhone with iOS 15.0 or later

### Steps:

1. **Transfer your code to a Mac**
   - Copy the entire `MediationAI` folder to your Mac
   - Or use git to clone this repository on your Mac

2. **Create Xcode Project**
   ```bash
   # On your Mac, navigate to your project folder
   cd MediationAI
   
   # Create a new iOS app in Xcode:
   # File → New → Project → iOS → App
   # Choose SwiftUI interface and Swift language
   # Bundle Identifier: com.yourname.mediationai
   ```

3. **Add your Swift files**
   - Copy all your .swift files into the Xcode project
   - Make sure to add them to the target

4. **Configure Project Settings**
   - Set deployment target to iOS 15.0+
   - Configure signing with your Apple ID
   - Enable developer mode on your iPhone (Settings → Privacy & Security → Developer Mode)

5. **Deploy to iPhone**
   - Connect iPhone via USB
   - Trust the computer on iPhone
   - Select your iPhone as the run destination in Xcode
   - Click the "Run" button or press Cmd+R

## Option 2: Use Expo/React Native (Alternative Approach)

If you want to deploy quickly without a Mac, consider converting your app to React Native:

### Prerequisites
- Node.js and npm installed
- Expo CLI: `npm install -g @expo/cli`
- Expo Go app on your iPhone (free from App Store)

### Steps:
1. **Create Expo project**
   ```bash
   npx create-expo-app MediationAI-Mobile
   cd MediationAI-Mobile
   ```

2. **Convert SwiftUI logic to React Native**
   - Recreate your UI components using React Native
   - Implement similar navigation and state management
   - Add authentication and dispute management features

3. **Deploy via Expo**
   ```bash
   expo start
   # Scan QR code with iPhone camera
   # Opens in Expo Go app
   ```

## Option 3: TestFlight Distribution

### For Mac users with Apple Developer Account:

1. **Archive your app in Xcode**
   - Product → Archive
   - Upload to App Store Connect

2. **Set up TestFlight**
   - Go to App Store Connect
   - Add internal testers (your email)
   - Upload build to TestFlight

3. **Install on iPhone**
   - Download TestFlight app
   - Accept invitation email
   - Install your app via TestFlight

## Option 4: Web App Alternative

Convert to a Progressive Web App (PWA) for immediate iPhone access:

### Steps:
1. **Create React/Vue.js web version**
   ```bash
   npx create-react-app mediation-web
   cd mediation-web
   ```

2. **Add PWA capabilities**
   - Service worker for offline functionality
   - Web app manifest for home screen installation
   - Responsive design for mobile

3. **Deploy to web hosting**
   - Vercel, Netlify, or similar
   - HTTPS required for iPhone installation

4. **Install on iPhone**
   - Open in Safari
   - Share → Add to Home Screen
   - Behaves like native app

## Current Project Structure Analysis

Your app includes these key components:
- `MediationAIApp.swift` - Main app entry point
- `OnboardingView.swift` - User onboarding flow
- `AuthView.swift` - Authentication system
- `HomeView.swift` - Main dashboard
- `DisputeRoomView.swift` - Core mediation functionality
- `CreateDisputeView.swift` - Dispute creation
- And several other supporting views

## Recommended Next Steps

**For immediate demo:**
1. Use Option 4 (Web App) for fastest deployment
2. Can be accessed on iPhone within hours

**For best user experience:**
1. Use Option 1 (Xcode) if you have access to a Mac
2. Native iOS performance and features

**For cross-platform:**
1. Use Option 2 (React Native/Expo)
2. Works on both iPhone and Android

## Development Tools Setup

If pursuing Option 1, you'll need:
```bash
# Install Xcode from Mac App Store
# Install iOS Simulator
# Configure Apple Developer account
# Enable Developer Mode on iPhone
```

## Troubleshooting

**Common issues:**
- Code signing errors: Ensure Apple ID is configured
- Device not recognized: Trust computer on iPhone
- Build errors: Check deployment target compatibility
- App crashes: Review console logs in Xcode

## Questions?

Let me know which option you'd like to pursue, and I can provide more detailed steps for your chosen deployment method!