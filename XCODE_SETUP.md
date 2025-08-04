# Xcode Setup Guide

## Prerequisites
- Xcode 15.0 or later
- iOS 17.0+ deployment target
- Swift 5.9+

## Setup Steps

1. **Clone the Repository**
   ```bash
   git clone https://github.com/joshnel2/mediationai.git
   cd mediationai
   ```

2. **Open in Xcode**
   - Open Xcode
   - Select "Open an existing project"
   - Navigate to the `frontend` folder
   - Open the `.xcodeproj` or `.xcworkspace` file

3. **Configure Bundle Identifier**
   - Select the project in the navigator
   - Go to the "Signing & Capabilities" tab
   - Update the Bundle Identifier to your own (e.g., `com.yourcompany.crashout`)

4. **Add Required Capabilities**
   - Push Notifications (if using)
   - In-App Purchase
   - Sign in with Apple

5. **Configure Environment**
   - Copy `backend/.env.example` to `backend/.env`
   - Update with your API keys:
     - Stripe keys
     - Plaid keys (for bank connections)
     - Other service keys as needed

6. **Install Dependencies**
   If using CocoaPods:
   ```bash
   cd frontend
   pod install
   ```

7. **Build and Run**
   - Select your target device or simulator
   - Press Cmd+R to build and run

## Key Files Added

### Swift Views
- `HomeView.swift` - Main feed with professional UI
- `BettingView.swift` - Clean betting interface
- `AddFundsView.swift` - Professional payment flow
- `BankConnectionView.swift` - Plaid integration for bank transfers
- `CreateDisputeView.swift` - Dispute creation interface

### Backend Files
- `betting_api.py` - Betting endpoints
- `betting_models.py` - Database models
- `payment_service.py` - Payment processing
- `escrow_service.py` - Escrow management
- `webhooks.py` - Payment webhooks

## Common Issues

### Build Errors
1. **Missing Swift files**: Make sure all Swift files in the `frontend` folder are added to your Xcode project
2. **Module not found**: Check that all imported frameworks are properly linked
3. **Signing errors**: Update the team and bundle identifier in project settings

### API Connection
1. Ensure the backend is running: `python3 backend/main.py`
2. Update API endpoints in your Swift code if needed
3. Check that all environment variables are set

## Testing Payments

### Test Mode
- Use Stripe test keys (start with `sk_test_`)
- Plaid sandbox environment
- Test card: 4242 4242 4242 4242

### Bank Connection Testing
- Plaid sandbox credentials:
  - Username: `user_good`
  - Password: `pass_good`

## Next Steps
1. Update app icons and launch screen
2. Configure push notification certificates
3. Set up App Store Connect
4. Submit for TestFlight testing