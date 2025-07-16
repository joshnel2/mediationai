# MediationAI Backend API

FastAPI backend for the MediationAI dispute resolution system.

## 🚀 Deploy to Vercel

### Prerequisites
- [Vercel Account](https://vercel.com) (free)
- OpenAI API Key (required)
- Anthropic API Key (optional)

### Step 1: Get API Keys
1. **OpenAI API Key** (Required):
   - Go to https://platform.openai.com/api-keys
   - Create account and generate API key
   - Copy the key (starts with `sk-`)

2. **Anthropic API Key** (Optional):
   - Go to https://console.anthropic.com/
   - Create account and generate API key

### Step 2: Deploy to Vercel

#### Option A: Deploy via Vercel CLI
```bash
# Install Vercel CLI
npm i -g vercel

# Login to Vercel
vercel login

# Deploy from backend directory
cd backend
vercel

# Follow prompts:
# - Link to existing project? No
# - Project name: mediation-ai-backend
# - Directory: ./
# - Override settings? No
```

#### Option B: Deploy via Vercel Dashboard
1. Go to https://vercel.com/dashboard
2. Click "New Project"
3. Import your Git repository
4. Set **Root Directory** to `backend`
5. Click "Deploy"

### Step 3: Set Environment Variables
After deployment, add these environment variables in Vercel:

1. Go to your project dashboard on Vercel
2. Click **Settings** → **Environment Variables**
3. Add these variables:

```
OPENAI_API_KEY=your_openai_key_here
ANTHROPIC_API_KEY=your_anthropic_key_here
SECRET_KEY=your_secret_key_here
DEBUG=False
```

### Step 4: Get Your API URL
After successful deployment, Vercel will provide you with a URL like:
```
https://mediation-ai-backend.vercel.app
```

**Save this URL** - you'll need it for the iOS app configuration!

## 📱 Connect to iOS App

Your iOS app needs to connect to the deployed backend:

1. In your Swift code, find the API base URL configuration
2. Replace `http://localhost:8000` with your Vercel URL
3. Example: `https://mediation-ai-backend.vercel.app`

## 🔧 Local Development

```bash
# Install dependencies
pip install -r requirements.txt

# Copy environment file
cp .env.example .env

# Edit .env with your API keys
nano .env

# Run locally
python main.py
```

## 📋 API Endpoints

Once deployed, your API will be available at:
- `https://your-vercel-url.vercel.app/docs` - Interactive API documentation
- `https://your-vercel-url.vercel.app/api/users/register` - User registration
- `https://your-vercel-url.vercel.app/api/disputes/create` - Create dispute
- And more...

## 🔍 Troubleshooting

### Common Issues:

1. **Build Failed**: Check requirements.txt for unsupported packages
2. **API Key Error**: Verify environment variables are set in Vercel
3. **Function Timeout**: Vercel free tier has 10s timeout limit
4. **CORS Issues**: Update CORS settings in `mediation_api.py`

### Getting Help:
- Check Vercel deployment logs in dashboard
- Test API endpoints using the `/docs` page
- Verify environment variables are properly set

## 🎯 Quick Test

After deployment, test your API:
```bash
curl https://your-vercel-url.vercel.app/api/health
```

Should return: `{"status": "healthy"}`

## 📝 Next Steps

1. ✅ Deploy backend to Vercel
2. ✅ Set up environment variables
3. ✅ Get your API URL
4. 🔄 Configure iOS app with your API URL
5. 🔄 Test the connection

Your backend is now live and ready for your iOS app! 🎉