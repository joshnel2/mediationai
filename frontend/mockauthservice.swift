//
//  MockAuthService.swift
//  MediationAI
//
//  Created by Linda Alster on 7/14/25.
//

import Foundation
import SwiftUI
import LocalAuthentication

// MARK: - Mock Auth Service

class MockAuthService: ObservableObject {
    @Published var currentUser: User?
    @Published var users: [User] = []
    @Published var isFaceIDEnabled = false
    @Published var isAutoLoginEnabled = false
    
    private let userDefaults = UserDefaults.standard
    private let userKey = "mediationAI_currentUser"
    private let tokenKey = "mediationAI_access_token"
    private let faceIDKey = "mediationAI_faceID_enabled"
    private let autoLoginKey = "mediationAI_autoLogin_enabled"
    
    init() {
        loadUserSettings()
        // Enable auto-login by default for better UX
        if !userDefaults.bool(forKey: "hasSetAutoLogin") {
            isAutoLoginEnabled = true
            userDefaults.set(true, forKey: autoLoginKey)
            userDefaults.set(true, forKey: "hasSetAutoLogin")
        }
        attemptAutoLogin()
    }
    
    func signUp(email: String, password: String) async -> Bool {
        guard !email.isEmpty, !password.isEmpty else { return false }

        // Attempt real backend registration first
        if let url = URL(string: "\(APIConfig.baseURL)/api/register"),
           let body = try? JSONSerialization.data(withJSONObject: ["email": email, "password": password]),
           let (data, response) = try? await URLSession.shared.upload(for: urlRequest(url: url, body: body), from: body),
           let http = response as? HTTPURLResponse, 200...299 ~= http.statusCode,
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let userDict = json["user"] as? [String: Any],
           let idStr = userDict["id"] as? String, let uuid = UUID(uuidString: idStr) {

            let newUser = User(id: uuid, email: email)
            await MainActor.run { self.currentUser = newUser }
            return true
        }

        // Fallback to mock when backend not reachable
        return await mockSignUp(email: email, password: password)
    }
    
    private func mockSignUp(email: String, password: String) async -> Bool {
        // Create new mock user
        let newUser = User(
            id: UUID(),
            email: email
        )
        
        await MainActor.run {
            // Remove any existing user with same email first (for development)
            users.removeAll { $0.email == email }
            
            currentUser = newUser
            users.append(newUser)
            
            // Save mock token and user data
            userDefaults.set("mock_token_\(UUID().uuidString)", forKey: tokenKey)

            // Automatically enable auto-login
            enableAutoLogin()
            saveUserSettings()
        }
        
        return true
    }
    
    private func mockSignIn(email: String, password: String) async -> Bool {
        // Find existing user or create demo user
        let existingUser = users.first(where: { $0.email == email })
        let user = existingUser ?? User(id: UUID(), email: email)
        
        await MainActor.run {
            currentUser = user
            if existingUser == nil {
                users.append(user)
            }
            
            // Save mock token and user data
            userDefaults.set("mock_token_\(UUID().uuidString)", forKey: tokenKey)

            // Ensure auto-login remains active
            enableAutoLogin()
            saveUserSettings()
        }
        
        return true
    }

    func signIn(email: String, password: String) async -> Bool {
        guard !email.isEmpty, !password.isEmpty else { return false }

        if let url = URL(string: "\(APIConfig.baseURL)/api/login"),
           let body = try? JSONSerialization.data(withJSONObject: ["email": email, "password": password]),
           let (data, response) = try? await URLSession.shared.upload(for: urlRequest(url: url, body: body), from: body),
           let http = response as? HTTPURLResponse, 200...299 ~= http.statusCode,
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let userDict = json["user"] as? [String: Any],
           let idStr = userDict["id"] as? String, let uuid = UUID(uuidString: idStr) {

            let user = User(id: uuid, email: email)
            await MainActor.run { self.currentUser = user }
            return true
        }

        return await mockSignIn(email: email, password: password)
    }

    // MARK: - Firebase Phone Auth Mock Signup
    /// Handles signup when using Firebase phone authentication. Since this is a purely local mock we simply create a new `User` instance using the provided display name and a synthesized e-mail address derived from the ID token. The newly created user is also persisted so subsequent app launches keep the user logged in if auto-login is enabled.
    @MainActor
    func firebaseSignUp(idToken: String, displayName: String) async -> Bool {
        // Derive a mock e-mail from the token so that the field is not empty and remains unique enough for local development.
        let mockEmail = "user_\(idToken.prefix(8))@firebase.mock"

        // Create a user using the extended convenience initialiser so the display name is preserved in the profile.
        let newUser = User(email: mockEmail, phoneNumber: nil, displayName: displayName)

        // Persist on the main actor because `@Published` properties are being mutated.
        currentUser = newUser
        if !users.contains(where: { $0.id == newUser.id }) {
            users.append(newUser)
        }

        // Store a mock JWT so the rest of the app can treat the session as authenticated.
        userDefaults.set("mock_token_\(UUID().uuidString)", forKey: tokenKey)

        // Ensure auto-login remains consistent with the established behaviour of other signup paths.
        enableAutoLogin()
        saveUserSettings()

        return true
    }

    // Helper to build URLRequest
    private func urlRequest(url: URL, body: Data) -> URLRequest {
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = body
        return req
    }
    
    func signOut() {
        currentUser = nil
        userDefaults.removeObject(forKey: userKey)
        userDefaults.removeObject(forKey: tokenKey)
        userDefaults.removeObject(forKey: autoLoginKey)
    }
    
    func updateUser(_ user: User) {
        currentUser = user
        if let index = users.firstIndex(where: { $0.id == user.id }) {
            users[index] = user
        }
        saveUserSettings()
    }
    
    // MARK: - Auto Login & Face ID
    
    func enableAutoLogin() {
        isAutoLoginEnabled = true
        userDefaults.set(true, forKey: autoLoginKey)
        saveUserSettings()
    }
    
    func disableAutoLogin() {
        isAutoLoginEnabled = false
        userDefaults.set(false, forKey: autoLoginKey)
        // We intentionally keep the cached credentials so Face ID (if enabled)
        // can still retrieve them and unlock the session next launch.
    }
    
    func enableFaceID() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            isFaceIDEnabled = true
            userDefaults.set(true, forKey: faceIDKey)
        }
    }
    
    func disableFaceID() {
        isFaceIDEnabled = false
        userDefaults.set(false, forKey: faceIDKey)
    }
    
    func authenticateWithFaceID(completion: @escaping (Bool) -> Void) {
        let context = LAContext()
        let reason = "Authenticate to access your MediationAI account"
        
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, error in
            DispatchQueue.main.async {
                completion(success)
            }
        }
    }
    
    private func loadUserSettings() {
        isAutoLoginEnabled = userDefaults.bool(forKey: autoLoginKey)
        isFaceIDEnabled = userDefaults.bool(forKey: faceIDKey)
    }
    
    private func saveUserSettings() {
        if let user = currentUser, isAutoLoginEnabled {
            if let encoded = try? JSONEncoder().encode(user) {
                userDefaults.set(encoded, forKey: userKey)
            }
        }
    }
    
    private func attemptAutoLogin() {
        guard isAutoLoginEnabled else { return }
        
        if let savedUserData = userDefaults.data(forKey: userKey),
           let user = try? JSONDecoder().decode(User.self, from: savedUserData),
           let accessToken = userDefaults.string(forKey: tokenKey) {
            
            // Verify token is still valid by making a request to the backend
            Task {
                await verifyTokenAndLogin(user: user, token: accessToken)
            }
        }
    }
    
    private func verifyTokenAndLogin(user: User, token: String) async {
        // If we're using a mock token, skip remote validation and accept it.
        if token.hasPrefix("mock_token") {
            await MainActor.run {
                self.currentUser = user
                if !self.users.contains(where: { $0.id == user.id }) {
                    self.users.append(user)
                }
            }
            return
        }

        // For real tokens, hit the backend verification endpoint
        let url = URL(string: "\(APIConfig.baseURL)/api/me")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                await MainActor.run {
                    self.currentUser = user
                }
            } else {
                await MainActor.run {
                    userDefaults.removeObject(forKey: userKey)
                    userDefaults.removeObject(forKey: tokenKey)
                }
            }
        } catch {
            // Network issue; fallback to local user data
            await MainActor.run { self.currentUser = user }
        }
    }
}

// MARK: - Mock Dispute Service

class MockDisputeService: ObservableObject {
    @Published var disputes: [Dispute] = []
    
    // Added `demoGhost` parameter (default = false) so that view code passing this flag compiles without "extra argument" errors. The flag is currently unused here but keeps the interface consistent with `RealDisputeService`.
    func createDispute(title: String, description: String, user: User, requiresContract: Bool = false, requiresSignature: Bool = false, requiresEscrow: Bool = false, demoGhost: Bool = false) -> Dispute {
        let shareCode = UUID().uuidString.prefix(6).uppercased()
        let disputeId = UUID()
        let shareLink = "https://mediationai.app/join/\(disputeId.uuidString)"
        
        var dispute = Dispute(
            id: disputeId,
            title: title,
            description: description,
            user: user
        )
        
        dispute.requiresContract = requiresContract
        dispute.requiresSignature = requiresSignature
        dispute.requiresEscrow = requiresEscrow
        
        disputes.append(dispute)
        return dispute
    }
    
    func joinDispute(shareLink: String, user: User) -> Dispute? {
        // Extract dispute ID from share link
        guard let disputeIdString = shareLink.components(separatedBy: "/").last,
              let disputeId = UUID(uuidString: disputeIdString),
              let index = disputes.firstIndex(where: { $0.id == disputeId }) else { return nil }
        
        if disputes[index].partyB == nil && disputes[index].partyA?.id != user.id {
            disputes[index].partyB = user
            disputes[index].joinerPaid = true // Assuming payment was successful
            disputes[index].status = .inProgress
        }
        return disputes[index]
    }
    
    func joinDisputeWithCode(shareCode: String, user: User) -> Dispute? {
        guard let index = disputes.firstIndex(where: { $0.shareCode == shareCode }) else { return nil }
        if disputes[index].partyB == nil && disputes[index].partyA?.id != user.id {
            disputes[index].partyB = user
            disputes[index].joinerPaid = true
            disputes[index].status = .inProgress
        }
        return disputes[index]
    }
    
    func addTruth(to dispute: Dispute, truth: Truth) {
        guard let index = disputes.firstIndex(where: { $0.id == dispute.id }) else { return }
        disputes[index].truths.append(truth)
        
        // Check if both parties have submitted truths
        let userIds = Set(disputes[index].truths.map { $0.userId })
        if userIds.count >= 2 {
            // Both parties have submitted - trigger AI resolution
            triggerAIResolution(for: disputes[index])
        }
    }
    
    func addCreatorSignature(to dispute: Dispute, signature: DigitalSignature) {
        guard let index = disputes.firstIndex(where: { $0.id == dispute.id }) else { return }
        disputes[index].partyASignature = signature
    }
    
    func addJoinerSignature(to dispute: Dispute, signature: DigitalSignature) {
        guard let index = disputes.firstIndex(where: { $0.id == dispute.id }) else { return }
        disputes[index].partyBSignature = signature
    }
    
    private func triggerAIResolution(for dispute: Dispute) {
        guard let index = disputes.firstIndex(where: { $0.id == dispute.id }) else { return }
        
        MockGrokAPI().resolveDispute(truths: dispute.truths) { [weak self] resolutionText in
            guard let self = self else { return }
            let resolution = Resolution(
                summary: "AI Analysis Complete",
                decision: resolutionText,
                reasoning: "Based on submitted evidence and AI analysis"
            )
            self.disputes[index].resolution = resolution
            self.disputes[index].resolvedAt = Date()
            self.disputes[index].status = .resolved
        }
    }
    
    func resolveDispute(_ dispute: Dispute, resolutionText: String) {
        guard let index = disputes.firstIndex(where: { $0.id == dispute.id }) else { return }
        let resolution = Resolution(
            summary: "Manual Resolution",
            decision: resolutionText,
            reasoning: "Resolution provided by mediator"
        )
        disputes[index].resolution = resolution
        disputes[index].resolvedAt = Date()
        disputes[index].status = .resolved
    }
    
    func getDisputeStatus(_ dispute: Dispute) -> DisputeStatus {
        if dispute.isResolved {
            return .resolved
        } else if dispute.partyB != nil {
            return .inProgress
        } else {
            return .inviteSent
        }
    }
}

// MARK: - Enhanced Grok API

class MockGrokAPI {
    func resolveDispute(truths: [Truth], completion: @escaping (String) -> Void) {
        // Simulate API delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            let resolution = self.generateResolution(from: truths)
            completion(resolution)
        }
    }
    
    private func generateResolution(from truths: [Truth]) -> String {
        // Enhanced AI-like resolution logic
        let resolutions = [
            """
            **AI MEDIATION RESOLUTION**
            
            After carefully analyzing both parties' submissions, I recommend the following resolution:
            
            🎯 **Key Finding**: Both parties have valid concerns that can be addressed through compromise.
            
            📋 **Recommended Actions**:
            1. Each party should acknowledge the other's perspective
            2. Split any disputed costs 50/50
            3. Establish clear communication guidelines moving forward
            4. Set a timeline for implementing these changes
            
            ⚖️ **Rationale**: This resolution balances fairness while addressing both parties' core concerns.
            """,
            """
            **AI MEDIATION RESOLUTION**
            
            Based on the evidence presented, here is my recommended resolution:
            
            🎯 **Primary Issue**: Miscommunication led to unmet expectations on both sides.
            
            📋 **Resolution Steps**:
            1. Party A should provide the agreed-upon deliverable within 7 days
            2. Party B should extend the deadline and provide additional clarification
            3. Both parties should establish weekly check-ins for future projects
            4. Any additional costs should be shared equally
            
            ⚖️ **This resolution promotes mutual understanding and prevents future disputes.**
            """,
            """
            **AI MEDIATION RESOLUTION**
            
            After reviewing all submitted evidence and statements:
            
            🎯 **Central Issue**: Different interpretations of the original agreement.
            
            📋 **Fair Resolution**:
            1. Refund 75% of disputed amount to requesting party
            2. Provide service credit for remaining 25%
            3. Update terms of service to prevent future misunderstandings
            4. Both parties to leave positive feedback acknowledging the resolution
            
            ⚖️ **This solution addresses the immediate concern while maintaining a positive relationship.**
            """
        ]
        
        return resolutions.randomElement() ?? resolutions[0]
    }
}
