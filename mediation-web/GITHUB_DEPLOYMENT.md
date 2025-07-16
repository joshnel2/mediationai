# 🚀 Deploy MediationAI Web App to Vercel

## ✅ **Current Status:**
- ✅ React web app is ready
- ✅ Git repository is initialized
- ✅ All files are committed to main branch
- ✅ Ready to push to GitHub!

## 📋 **Step-by-Step Deployment Guide:**

### **Step 1: Create GitHub Repository**

1. **Go to GitHub.com** and sign in
2. **Click "New" or "+" → "New repository"**
3. **Repository settings:**
   - Repository name: `mediation-web` (or any name you prefer)
   - Description: `MediationAI Web App - Demo for iPhone deployment`
   - Set to **Public** (required for free Vercel deployment)
   - ❌ **DO NOT** initialize with README, .gitignore, or license (we already have these)

4. **Click "Create repository"**

### **Step 2: Push Your Code to GitHub**

Copy and paste these commands **one by one** in your terminal:

```bash
# Make sure you're in the mediation-web directory
cd /workspace/mediation-web

# Add your GitHub repository as remote (replace with YOUR GitHub username)
git remote add origin https://github.com/YOUR-USERNAME/mediation-web.git

# Push to GitHub
git push -u origin main
```

**Replace `YOUR-USERNAME` with your actual GitHub username!**

### **Step 3: Deploy to Vercel**

#### **Option A: Via Vercel Dashboard (Recommended)**
1. **Go to [vercel.com](https://vercel.com)**
2. **Sign in with GitHub**
3. **Click "New Project"**
4. **Select your `mediation-web` repository**
5. **Click "Deploy"** (no configuration needed!)
6. **Wait 1-2 minutes** for deployment to complete
7. **Get your live URL!** (e.g., `https://mediation-web-abc123.vercel.app`)

#### **Option B: Via Command Line**
```bash
# Install Vercel CLI and deploy
npx vercel --prod
```

### **Step 4: Share with Friends**

Once deployed, share the URL with your friends:

1. **Send them the Vercel URL**
2. **They open it in Safari on iPhone**
3. **Tap Share → "Add to Home Screen"**
4. **The app appears like a native app!**

---

## 🎯 **Quick Commands Summary:**

```bash
# 1. Create GitHub repo at github.com/new
# 2. Push to GitHub:
git remote add origin https://github.com/YOUR-USERNAME/mediation-web.git
git push -u origin main

# 3. Deploy to Vercel:
# Go to vercel.com → New Project → Import from GitHub
```

## 📱 **iPhone Installation:**
- Open the Vercel URL in Safari
- Tap Share button
- Select "Add to Home Screen"
- App installs like native app!

## 🔧 **Troubleshooting:**
- **Git push fails:** Make sure you replaced `YOUR-USERNAME` with your actual GitHub username
- **Vercel deployment fails:** Ensure the repository is public
- **App doesn't work on iPhone:** Clear Safari cache and try again

---

## 🎉 **You're Done!**
Once deployed, you'll have a live URL that works on any iPhone. Your friends can install it directly from Safari!

**Need help?** Let me know if you get stuck on any step!