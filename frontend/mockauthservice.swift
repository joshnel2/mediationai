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
        
        let url = URL(string: "\(APIConfig.baseURL)/api/register")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody = [
            "email": email,
            "password": password
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                
                if let userData = json?["user"] as? [String: Any],
                   let accessToken = json?["access_token"] as? String {
                    
                    // Parse user data
                    var user = User(
                        id: UUID(uuidString: userData["id"] as? String ?? "") ?? UUID(),
                        email: userData["email"] as? String ?? email
                    )
                    
                    // Update user properties from API response
                    user.profile.displayName = userData["displayName"] as? String ?? email.components(separatedBy: "@")[0]
                    user.stats.totalDisputes = userData["totalDisputes"] as? Int ?? 0
                    user.stats.disputesWon = userData["disputesWon"] as? Int ?? 0
                    user.stats.disputesLost = userData["disputesLost"] as? Int ?? 0
                    user.preferences.notificationsEnabled = userData["notificationsEnabled"] as? Bool ?? true
                    
                    // These are stored in the auth service, not user preferences
                    if let faceIDEnabled = userData["faceIDEnabled"] as? Bool {
                        self.isFaceIDEnabled = faceIDEnabled
                    }
                    if let autoLoginEnabled = userData["autoLoginEnabled"] as? Bool {
                        self.isAutoLoginEnabled = autoLoginEnabled
                    }
                    
                    await MainActor.run {
                        currentUser = user
                        users.append(user)
                        
                        // Save token and user data
                        userDefaults.set(accessToken, forKey: tokenKey)
                        saveUserSettings()
                    }
                    
                    return true
                }
            }
        } catch {
            print("❌ SignUp Error: \(error)")
        }
        
        return false
    }
    
    func signIn(email: String, password: String) async -> Bool {
        guard !email.isEmpty, !password.isEmpty else { return false }
        
        let url = URL(string: "\(APIConfig.baseURL)/api/login")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody = [
            "email": email,
            "password": password
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                
                if let userData = json?["user"] as? [String: Any],
                   let accessToken = json?["access_token"] as? String {
                    
                    // Parse user data
                    var user = User(
                        id: UUID(uuidString: userData["id"] as? String ?? "") ?? UUID(),
                        email: userData["email"] as? String ?? email
                    )
                    
                    // Update user properties from API response
                    user.profile.displayName = userData["displayName"] as? String ?? email.components(separatedBy: "@")[0]
                    user.stats.totalDisputes = userData["totalDisputes"] as? Int ?? 0
                    user.stats.disputesWon = userData["disputesWon"] as? Int ?? 0
                    user.stats.disputesLost = userData["disputesLost"] as? Int ?? 0
                    user.preferences.notificationsEnabled = userData["notificationsEnabled"] as? Bool ?? true
                    
                    // These are stored in the auth service, not user preferences
                    if let faceIDEnabled = userData["faceIDEnabled"] as? Bool {
                        self.isFaceIDEnabled = faceIDEnabled
                    }
                    if let autoLoginEnabled = userData["autoLoginEnabled"] as? Bool {
                        self.isAutoLoginEnabled = autoLoginEnabled
                    }
                    
                    await MainActor.run {
                        currentUser = user
                        
                        // Save token and user data
                        userDefaults.set(accessToken, forKey: tokenKey)
                        saveUserSettings()
                    }
                    
                    return true
                }
            }
        } catch {
            print("❌ SignIn Error: \(error)")
        }
        
        return false
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
        userDefaults.removeObject(forKey: userKey)
        userDefaults.removeObject(forKey: tokenKey)
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
        let url = URL(string: "\(APIConfig.baseURL)/api/me")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                // Token is valid, proceed with auto-login
                await MainActor.run {
                    if isFaceIDEnabled {
                        authenticateWithFaceID { [weak self] success in
                            if success {
                                self?.currentUser = user
                                self?.users.append(user)
                            }
                        }
                    } else {
                        currentUser = user
                        users.append(user)
                    }
                }
            } else {
                // Token is invalid, clear stored data
                await MainActor.run {
                    userDefaults.removeObject(forKey: userKey)
                    userDefaults.removeObject(forKey: tokenKey)
                }
            }
        } catch {
            // Network error, try to use cached user data
            await MainActor.run {
                if !isFaceIDEnabled {
                    currentUser = user
                    users.append(user)
                }
            }
        }
    }
}

// MARK: - Mock Dispute Service

class MockDisputeService: ObservableObject {
    @Published var disputes: [Dispute] = []
    
    func createDispute(title: String, description: String, user: User, requiresContract: Bool = false, requiresSignature: Bool = false, requiresEscrow: Bool = false) -> Dispute {
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
