# ClashAI – TestFlight Launch Guide

This is a **complete, step-by-step playbook** for taking the current `main` branch to a public TestFlight build and live backend.

---
## 1 Repo status (already done)
* All code features pushed to `main` – last commit `588bf44`.
* Backend FastAPI + PostgreSQL & Redis ready (Dockerfile).
* iOS app renamed **ClashAI**, neon UI, viral loops, push-notifications.

Nothing else needs to be merged – you’re up-to-date.

---
## 2 Apple Developer Portal (15 min)
1.  Add **App ID** `com.your.bundleid` (Capabilities: Push Notifications, Associated Domains).  
2.  Keys ▸ Create **APNs Auth Key** → download `AuthKey_XXXX.p8`.  
   * Note `KEY_ID` + `TEAM_ID`.
3.  Certificates ▸ Create **Production Push SSL** (if using legacy) – optional.
4.  Users ▸ Invite beta testers (later).

---
## 3 Firebase (Crashlytics + Analytics) (20 min)
1.  Console ▸ Add iOS app (`com.your.bundleid`).  
2.  Download `GoogleService-Info.plist` → drag into Xcode target.  
3.  Xcode ▸ File ▸ Add Packages… → `https://github.com/firebase/firebase-ios-sdk`  
   * Select **Analytics** & **Crashlytics**.
4.  Accept Crashlytics run-script build phase.

---
## 4 iOS Project tweaks (10 min)
1.  Open `MediationAIApp.swift` – confirm `@UIApplicationDelegateAdaptor(PushDelegate.self)` exists.  
2.  In target ➜ Signing & Capabilities add **Push Notifications**.
3.  Replace placeholder **Bundle identifier** & Team in Signing.
4.  Product ▸ Archive ▸ Distribute ➜ **TestFlight** (upload).

---
## 5 Backend deployment (30 min)
1.  Choose host: Render, Fly, Railway, or Docker VM.
2.  Env vars:
   ```bash
   OPENAI_API_KEY=sk-...
   DATABASE_URL=postgres://...
   UPSTASH_REDIS_REST_URL=...
   UPSTASH_REDIS_REST_TOKEN=...
   APNS_KEY_BASE64=<base64 of AuthKey_XXXX.p8>
   APNS_KEY_ID=XXXX
   APNS_TEAM_ID=YYYY
   BUNDLE_ID=com.your.bundleid
   ```
3.  `docker build -t clashai . && docker run -p 8080:8080 ...` (or let host build).  
4.  Verify health: `GET https://api.clashai.app/api/health` → `{"status":"healthy"}`.

---
## 6 Domain & Deep-Links (20 min)
1.  DNS A record `api.clashai.app` → backend IP / CNAME.  
2.  Root domain or Vercel for **www.clashai.app** (marketing site).  
3.  Upload `.well-known/apple-app-site-association` with:
   ```json
   {"applinks":{"apps":[],"details":[{"appIDs":["YYY.com.your.bundleid"],"paths":["/clash/*"]}]}}
   ```
4.  Confirm `clashai://clash/123` opens the app (use Notes link).

---
## 7 Push-notification smoke test (10 min)
1.  Install TestFlight build on physical iPhone.  
2.  Accept notif permission.  
3.  Log in on a second account.
4.  Start a Clash, toggle **Public** – first device should receive “X is live!” push.

---
## 8 Firebase verification (5 min)
* Open **Crashlytics ▸ Logs** – force crash with `fatalError()` in debug to see event.  
* **Analytics ▸ DebugView** should show `clash_start`, `vote_send`.

---
## 9 Moderation & Safety (next sprint)
* Add OpenAI Moderation key → filter spectator chat.  
* Implement `/report` endpoint + manual admin page.

---
## 10 Marketing checklist
* Create simple landing page + streamer pages using `/streamers/{slug}` JSON.  
* Record 30-sec demo for Discord/Twitter share.  
* Prepare App Store screenshots (5.5-inch & 6.5-inch).  

---
You’re good to hit **Submit for Review** once the above steps pass.  Happy clashing!