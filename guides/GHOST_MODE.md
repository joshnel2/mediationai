# Ghost Demo Mode

This feature automatically adds an AI "ghost" respondent to new disputes so you can demo the flow with only one real user.

## How it works (backend)
1. `CreateDisputeRequest` has a `demoGhost` boolean (default `false`).
2. When `true`, `/api/disputes` adds:
   - A synthetic `User` named *GhostAI* as the RESPONDENT.
   - An opening AI message so the chat room isn’t empty.
3. Everything else (mediation, analytics, contract) behaves normally.

## How it works (iOS)
1. *Create Dispute* screen now has a checkbox **“Demo Ghost Opponent”**.
2. The SwiftUI view passes `demoGhost: true` to the backend.
3. The user lands in a populated dispute instantly.

---

## Removing the Feature
1. **Backend** – delete or comment:
   ```python
   if request.demoGhost:
       ... (block that adds Ghost)
   ```
   in `backend/mediation_api.py`.
2. **Mobile** – remove the toggle block in `createdisputeview.swift` and stop sending `demoGhost` in the API call.

## Keeping the Code but Hiding the UI
If you only want to hide the option without touching backend:
1. In `createdisputeview.swift`, set `@State private var useGhostDemo = false` and **do not** render the toggle. Hard-code `demoGhost: false` when calling `createDispute`.

---

That’s it—ghost mode is a single boolean flag and can be disabled in under 2 minutes when you’re ready to go live.