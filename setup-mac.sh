#!/bin/bash

echo "🚀 Setting up MediationAI Web App on your Mac..."
echo "================================================"

# Create project directory
mkdir -p ~/mediation-web
cd ~/mediation-web

# Initialize git
git init
git branch -M main

# Create package.json
cat > package.json << 'EOF'
{
  "name": "mediation-web",
  "version": "0.1.0",
  "private": true,
  "dependencies": {
    "@testing-library/jest-dom": "^5.16.4",
    "@testing-library/react": "^13.3.0",
    "@testing-library/user-event": "^13.5.0",
    "@types/jest": "^27.5.2",
    "@types/node": "^16.11.47",
    "@types/react": "^18.0.15",
    "@types/react-dom": "^18.0.6",
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "react-scripts": "5.0.1",
    "typescript": "^4.7.4",
    "web-vitals": "^2.1.4"
  },
  "scripts": {
    "start": "react-scripts start",
    "build": "react-scripts build",
    "test": "react-scripts test",
    "eject": "react-scripts eject"
  },
  "eslintConfig": {
    "extends": [
      "react-app",
      "react-app/jest"
    ]
  },
  "browserslist": {
    "production": [
      ">0.2%",
      "not dead",
      "not op_mini all"
    ],
    "development": [
      "last 1 chrome version",
      "last 1 firefox version",
      "last 1 safari version"
    ]
  }
}
EOF

# Create tsconfig.json
cat > tsconfig.json << 'EOF'
{
  "compilerOptions": {
    "target": "es5",
    "lib": [
      "dom",
      "dom.iterable",
      "es6"
    ],
    "allowJs": true,
    "skipLibCheck": true,
    "esModuleInterop": true,
    "allowSyntheticDefaultImports": true,
    "strict": true,
    "forceConsistentCasingInFileNames": true,
    "noFallthroughCasesInSwitch": true,
    "module": "esnext",
    "moduleResolution": "node",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noEmit": true,
    "jsx": "react-jsx"
  },
  "include": [
    "src"
  ]
}
EOF

# Create .gitignore
cat > .gitignore << 'EOF'
# dependencies
/node_modules
/.pnp
.pnp.js

# testing
/coverage

# production
/build

# misc
.DS_Store
.env.local
.env.development.local
.env.test.local
.env.production.local

npm-debug.log*
yarn-debug.log*
yarn-error.log*
EOF

# Create public directory and files
mkdir -p public

cat > public/index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <link rel="icon" href="%PUBLIC_URL%/favicon.ico" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <meta name="theme-color" content="#000000" />
    <meta name="description" content="MediationAI - AI-powered dispute resolution" />
    <link rel="apple-touch-icon" href="%PUBLIC_URL%/logo192.png" />
    <link rel="manifest" href="%PUBLIC_URL%/manifest.json" />
    <title>MediationAI</title>
  </head>
  <body>
    <noscript>You need to enable JavaScript to run this app.</noscript>
    <div id="root"></div>
  </body>
</html>
EOF

cat > public/manifest.json << 'EOF'
{
  "short_name": "MediationAI",
  "name": "MediationAI - AI Dispute Resolution",
  "icons": [
    {
      "src": "favicon.ico",
      "sizes": "64x64 32x32 24x24 16x16",
      "type": "image/x-icon"
    },
    {
      "src": "logo192.png",
      "type": "image/png",
      "sizes": "192x192"
    },
    {
      "src": "logo512.png",
      "type": "image/png",
      "sizes": "512x512"
    }
  ],
  "start_url": ".",
  "display": "standalone",
  "theme_color": "#000000",
  "background_color": "#ffffff"
}
EOF

cat > public/robots.txt << 'EOF'
User-agent: *
Disallow:
EOF

# Create src directory and files
mkdir -p src

cat > src/index.tsx << 'EOF'
import React from 'react';
import ReactDOM from 'react-dom/client';
import './index.css';
import App from './App';
import reportWebVitals from './reportWebVitals';

const root = ReactDOM.createRoot(
  document.getElementById('root') as HTMLElement
);
root.render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
);

reportWebVitals();
EOF

cat > src/App.tsx << 'EOF'
import React from 'react';
import './App.css';

function App() {
  return (
    <div className="App">
      <header className="App-header">
        <h1>🤖 MediationAI</h1>
        <p>AI-Powered Dispute Resolution</p>
        <p>Welcome to the future of mediation!</p>
        <div style={{ marginTop: '20px' }}>
          <p>📱 Install this app on your iPhone:</p>
          <ol style={{ textAlign: 'left', maxWidth: '300px' }}>
            <li>Open this page in Safari</li>
            <li>Tap the Share button</li>
            <li>Select "Add to Home Screen"</li>
            <li>Tap "Add"</li>
          </ol>
        </div>
      </header>
    </div>
  );
}

export default App;
EOF

cat > src/App.css << 'EOF'
.App {
  text-align: center;
}

.App-header {
  background-color: #282c34;
  padding: 20px;
  color: white;
  min-height: 100vh;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  font-size: calc(10px + 2vmin);
}

.App-header h1 {
  margin: 0;
  font-size: 3rem;
}

.App-header p {
  margin: 10px 0;
}

.App-header ol {
  font-size: 1rem;
  line-height: 1.6;
}
EOF

cat > src/index.css << 'EOF'
body {
  margin: 0;
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Oxygen',
    'Ubuntu', 'Cantarell', 'Fira Sans', 'Droid Sans', 'Helvetica Neue',
    sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}

code {
  font-family: source-code-pro, Menlo, Monaco, Consolas, 'Courier New',
    monospace;
}
EOF

# Create other required files
cat > src/react-app-env.d.ts << 'EOF'
/// <reference types="react-scripts" />
EOF

cat > src/reportWebVitals.ts << 'EOF'
import { ReportHandler } from 'web-vitals';

const reportWebVitals = (onPerfEntry?: ReportHandler) => {
  if (onPerfEntry && onPerfEntry instanceof Function) {
    import('web-vitals').then(({ getCLS, getFID, getFCP, getLCP, getTTFB }) => {
      getCLS(onPerfEntry);
      getFID(onPerfEntry);
      getFCP(onPerfEntry);
      getLCP(onPerfEntry);
      getTTFB(onPerfEntry);
    });
  }
};

export default reportWebVitals;
EOF

cat > src/setupTests.ts << 'EOF'
import '@testing-library/jest-dom';
EOF

cat > src/App.test.tsx << 'EOF'
import React from 'react';
import { render, screen } from '@testing-library/react';
import App from './App';

test('renders MediationAI header', () => {
  render(<App />);
  const headerElement = screen.getByText(/MediationAI/i);
  expect(headerElement).toBeInTheDocument();
});
EOF

# Create README
cat > README.md << 'EOF'
# MediationAI Web Demo

## 🚀 Quick Deploy to Your Phone

### Deploy to Vercel (Recommended - 5 minutes)
1. Push this code to GitHub
2. Connect to Vercel.com (free)
3. Your app will be live at: `https://your-app.vercel.app`

### Deploy to Netlify (Alternative - 5 minutes)
1. Push this code to GitHub
2. Connect to Netlify.com (free)
3. Your app will be live at: `https://your-app.netlify.app`

## 📱 Installing on iPhone

Once deployed, anyone can:
1. Open the link in Safari on iPhone
2. Tap the "Share" button
3. Select "Add to Home Screen"
4. The app icon appears like a native app!

## 🔧 Local Development
```bash
npm start
```

## 🚀 Production Build
```bash
npm run build
```

## 🎯 Next Steps
1. Customize the app components
2. Add your app's styling/branding
3. Deploy to web hosting
4. Share link with friends!
EOF

echo "✅ Project files created!"
echo "📦 Installing dependencies..."
npm install

echo "🔗 Setting up Git..."
git add .
git commit -m "Initial commit: MediationAI web app ready for deployment"

echo "🚀 Adding GitHub remote..."
git remote add origin https://github.com/joshnel2/mediation-web.git

echo "📤 Pushing to GitHub..."
git push -u origin main

echo ""
echo "🎉 SUCCESS! Your MediationAI web app is now on GitHub!"
echo ""
echo "🚀 Next steps:"
echo "1. Go to vercel.com"
echo "2. Sign in with GitHub"
echo "3. Import your 'mediation-web' repository"
echo "4. Deploy and share the URL!"
echo ""
echo "📱 Your friends can install it on iPhone by:"
echo "   - Opening the URL in Safari"
echo "   - Tapping Share → Add to Home Screen"
echo ""