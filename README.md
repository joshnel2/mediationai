# MediationAI

An AI-powered dispute resolution iOS app built with SwiftUI.

## 🚀 Features

- **AI-Powered Mediation**: Automated dispute resolution using AI
- **User Authentication**: Sign up and sign in functionality
- **Dispute Management**: Create, join, and manage disputes
- **Truth Submission**: Submit evidence and attachments
- **Real-time Chat**: Communicate during dispute resolution
- **Resolution View**: View final AI-generated resolutions

## 📱 Requirements

- iOS 15.0+
- Xcode 14.0+
- Swift 5.0+

## 🛠 Setup Instructions

### **Step 1: Download the Project**
1. Go to: **https://github.com/joshnel2/mediationai**
2. Click **"Code"** → **"Download ZIP"**
3. Extract the downloaded `mediationai-main.zip`

### **Step 2: Create New Xcode Project**
1. **Open Xcode**
2. **File** → **New** → **Project**
3. Choose: **iOS** → **App**
4. **Settings:**
   - Product Name: `MediationAI`
   - Interface: `SwiftUI`
   - Language: `Swift`
   - Bundle Identifier: `com.mediationai.app`
5. **Save** to a location of your choice

### **Step 3: Import the Swift Files**
1. **Delete default files:**
   - Right-click and delete `ContentView.swift` and `MediationAIApp.swift` from the project
2. **Add our files:**
   - Drag all `.swift` files from the downloaded `MediationAI/` folder into your Xcode project
   - Select: ✅ **"Copy items if needed"**
   - Select: ✅ **"Add to target: MediationAI"**
3. **Replace Info.plist:**
   - Replace the default `Info.plist` with the one from the downloaded `MediationAI/` folder

### **Step 4: Build and Run**
1. **Select** iPhone simulator (iPhone 15, etc.)
2. **Press** `Cmd+R` or click the ▶️ **Play** button
3. **Your app will build and run!**

## 🏗 Project Structure

```
MediationAI/
├── MediationAI/                    # Source code
│   ├── MediationAIApp.swift        # Main app entry point
│   ├── RootView.swift              # Root navigation view
│   ├── OnboardingView.swift        # Welcome screen
│   ├── AuthView.swift              # Login/signup
│   ├── HomeView.swift              # Main dashboard
│   ├── User.swift                  # Data models
│   ├── MockAuthService.swift       # Mock services
│   ├── AppTheme.swift              # App styling
│   └── [Other Views]               # Dispute and component views
└── Info.plist                     # App configuration
```

## 🎨 Design

The app features a modern, clean design with:
- **Purple gradient theme** (`#6C47FF` to `#00D2FF`)
- **Rounded design system** with consistent spacing
- **SwiftUI best practices** for responsive layouts
- **iOS 16+ compatibility** with backward support

## 🔧 Development Notes

### ✅ **Debugged & Fixed Issues:**
- **Color crashes** - Uses hardcoded RGB values instead of missing assets
- **Navigation deprecation** - iOS 16+ compatible with backward support
- **File organization** - Clean, structured codebase
- **Ready to run** - No additional setup required

### **Architecture:**
- **MVVM Pattern**: Clean separation of concerns
- **ObservableObject**: Reactive state management
- **Mock Services**: Development-ready authentication and data

## 📝 License

This project is available under the MIT License.

## 👥 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

**Follow the setup instructions above to get started!** 🎉