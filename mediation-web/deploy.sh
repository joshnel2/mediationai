#!/bin/bash

echo "🚀 MediationAI Web App Deployment Script"
echo "========================================"

# Check if we're in the right directory
if [ ! -f "package.json" ]; then
    echo "❌ Error: package.json not found. Please run this script from the mediation-web directory."
    exit 1
fi

echo "📋 Building the app for production..."
npm run build

if [ $? -eq 0 ]; then
    echo "✅ Build successful!"
    echo ""
    echo "🎯 Next steps:"
    echo "1. Push this repository to GitHub"
    echo "2. Go to vercel.com and import your GitHub repository"
    echo "3. Or run: npx vercel --prod"
    echo ""
    echo "📱 Once deployed, share the URL with your friends!"
    echo "   They can install it on iPhone by:"
    echo "   - Opening the link in Safari"
    echo "   - Tapping Share → Add to Home Screen"
    echo ""
else
    echo "❌ Build failed. Please check the error messages above."
    exit 1
fi