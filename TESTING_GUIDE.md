# 🧪 MediationAI Testing Guide

## How to Test Your App Without Distributing It

### 🎯 **Testing Options**

#### 1. **iOS Simulator (Multiple Users)**
Use multiple simulator instances to test different users:

```bash
# Open multiple iOS simulators
xcrun simctl boot "iPhone 15 Pro"
xcrun simctl boot "iPhone 15"

# Or use different iOS versions
xcrun simctl boot "iPhone 15 Pro" "iOS 17.0"
xcrun simctl boot "iPhone 14" "iOS 16.0"
```

#### 2. **Physical Device Testing**
- **Your iPhone**: Test as User A
- **Friend's iPhone**: Install via Xcode for User B
- **iPad**: Test different screen sizes

#### 3. **TestFlight Beta Testing**
- Upload to App Store Connect
- Add up to 100 internal testers
- Get feedback from real users

---

## 🔍 **Database Testing Scenarios**

### **User Registration & Login**
1. **Test User Persistence**:
   - Create account → Close app → Reopen → Should stay logged in
   - Sign out → Should require login again
   - Uninstall/Reinstall → Should require new registration

2. **Test Multiple Users**:
   - Register `user1@test.com` and `user2@test.com`
   - Switch between accounts
   - Verify data isolation

### **Dispute Management**
1. **Create & Join Disputes**:
   - User A creates dispute
   - User B joins via share link
   - Both users can see dispute data

2. **Data Persistence**:
   - Add evidence → Close app → Reopen → Evidence should remain
   - Submit truths → Data should persist
   - Resolve dispute → Resolution should be saved

---

## 📱 **App Testing Checklist**

### ✅ **Authentication Tests**
- [ ] Sign up with new email
- [ ] Sign in with existing account
- [ ] Auto-login after app restart
- [ ] Face ID/Touch ID login
- [ ] Sign out functionality
- [ ] Invalid credentials handling

### ✅ **Dispute Flow Tests**
- [ ] Create new dispute
- [ ] Join dispute via share link
- [ ] Add evidence (photos, documents)
- [ ] Submit truth statements
- [ ] AI mediation responses
- [ ] Resolution generation
- [ ] Dispute resolution acceptance

### ✅ **Data Persistence Tests**
- [ ] User data survives app restart
- [ ] Dispute data survives app restart
- [ ] Evidence files are preserved
- [ ] Truth statements are saved
- [ ] Resolution history is maintained

### ✅ **Backend Integration Tests**
- [ ] Registration API call succeeds
- [ ] Login API call succeeds
- [ ] Dispute creation API works
- [ ] Evidence upload API works
- [ ] AI mediation API responds
- [ ] Database queries work correctly

---

## 🚀 **Quick Test Scenarios**

### **Scenario 1: End-to-End Dispute**
1. **User A**: Register → Create dispute → Share link
2. **User B**: Register → Join dispute → Add evidence
3. **Both**: Submit truth statements
4. **System**: AI generates resolution
5. **Both**: Accept/reject resolution

### **Scenario 2: Persistence Test**
1. **User A**: Create dispute → Add evidence → Close app
2. **Reopen app**: Verify user still logged in
3. **Check dispute**: Evidence should still be there
4. **User B**: Join dispute → Close app → Reopen
5. **Verify**: Both users' data persists

### **Scenario 3: Multiple Disputes**
1. **User A**: Create 3 different disputes
2. **User B**: Join 2 disputes
3. **User C**: Join 1 dispute
4. **Verify**: Each user sees correct disputes
5. **Test**: Data isolation between disputes

---

## 🛠️ **Development Testing Tools**

### **Backend Testing**
```bash
# Test health endpoint
curl https://mediationai-3ueg.vercel.app/api/health

# Test registration
curl -X POST https://mediationai-3ueg.vercel.app/api/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password123"}'

# Test login
curl -X POST https://mediationai-3ueg.vercel.app/api/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password123"}'
```

### **Database Verification**
```bash
# Check database file (if using SQLite)
sqlite3 backend/mediationai.db ".tables"
sqlite3 backend/mediationai.db "SELECT * FROM users;"
sqlite3 backend/mediationai.db "SELECT * FROM disputes;"
```

### **iOS Debug Console**
Look for these logs in Xcode console:
- ✅ `User registered successfully`
- ✅ `User logged in successfully`
- ✅ `Dispute created successfully`
- ✅ `Evidence uploaded successfully`
- ❌ `SignUp Error: ...`
- ❌ `SignIn Error: ...`

---

## 🎭 **Mock User Scenarios**

### **Business Dispute**
- **User**: `business@test.com`
- **Dispute**: Service contract disagreement
- **Evidence**: Contract documents, email chains
- **Resolution**: Partial refund + service completion

### **Rental Dispute**
- **User**: `tenant@test.com` vs `landlord@test.com`
- **Dispute**: Security deposit return
- **Evidence**: Photos, receipts, lease agreement
- **Resolution**: Deposit return timeline

### **E-commerce Dispute**
- **User**: `buyer@test.com` vs `seller@test.com`
- **Dispute**: Product quality issues
- **Evidence**: Photos, order confirmation
- **Resolution**: Return authorization

---

## 📊 **Success Metrics**

### **Technical Metrics**
- **Authentication**: 100% successful login/signup
- **Data Persistence**: 0 data loss incidents
- **API Calls**: < 2 second response times
- **Database**: No query errors

### **User Experience Metrics**
- **Dispute Creation**: < 2 minutes
- **Evidence Upload**: < 30 seconds
- **AI Response**: < 10 seconds
- **Resolution Time**: < 5 minutes

---

## 🔧 **Troubleshooting**

### **Common Issues**
1. **"User not found"**: Check if registration completed
2. **"Invalid credentials"**: Verify email/password format
3. **"Network error"**: Check Vercel backend URL
4. **"Database error"**: Check SQLite file permissions

### **Reset Commands**
```bash
# Reset backend database
rm backend/mediationai.db
python backend/database.py

# Reset iOS app data
iOS Settings → General → iPhone Storage → MediationAI → Delete App
```

---

## 🎯 **Next Steps**

1. **Deploy backend** to Vercel with database
2. **Test core functionality** with multiple users
3. **Fix any bugs** found during testing
4. **Prepare for TestFlight** beta release
5. **Gather feedback** from beta testers

Your app now has:
- ✅ **Persistent user authentication**
- ✅ **Database-backed storage**
- ✅ **JWT token-based sessions**
- ✅ **Automatic login persistence**
- ✅ **Secure password hashing**