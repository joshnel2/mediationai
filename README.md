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

## 🛠 Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/joshnel2/mediationai.git
   cd mediationai
   ```

2. **Open in Xcode:**
   ```bash
   open MediationAI.xcodeproj
   ```

3. **Build and Run:**
   - Select your target device or simulator
   - Press `Cmd+R` to build and run

## 🏗 Project Structure

```
MediationAI/
├── MediationAI.xcodeproj/          # Xcode project files
├── MediationAI/                    # Source code
│   ├── MediationAIApp.swift        # Main app entry point
│   ├── Models/
│   │   ├── User.swift              # User and data models
│   │   └── MockAuthService.swift   # Mock authentication service
│   ├── Views/
│   │   ├── RootView.swift          # Root navigation view
│   │   ├── OnboardingView.swift    # Welcome screen
│   │   ├── AuthView.swift          # Login/signup
│   │   ├── HomeView.swift          # Main dashboard
│   │   ├── DisputeViews/           # Dispute-related views
│   │   └── Components/             # Reusable UI components
│   ├── Theme/
│   │   └── AppTheme.swift          # App styling and colors
│   └── Info.plist                  # App configuration
├── DEBUG_REPORT.md                 # Debugging information
└── README.md                       # This file
```

## 🎨 Design

The app features a modern, clean design with:
- **Purple gradient theme** (`#6C47FF` to `#00D2FF`)
- **Rounded design system** with consistent spacing
- **SwiftUI best practices** for responsive layouts
- **iOS 16+ compatibility** with backward support

## 🔧 Development Notes

### Fixed Issues:
- ✅ Color asset dependencies (replaced with hardcoded colors)
- ✅ Navigation deprecation warnings (iOS 16+ compatibility)
- ✅ File naming inconsistencies
- ✅ Project structure organization

### Architecture:
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

**Ready to build and run in Xcode!** 🎉