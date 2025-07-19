import Foundation
import SwiftUI
import Security

class RealDisputeService: ObservableObject {
    @Published var disputes: [Dispute] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var currentUser: User?
    
    private let apiService = DisputeAPIService()
    // Keychain key for JWT storage
    private let tokenAccount = "mediationAI_JWT"

    init() {
        // Attempt to restore previous session
        if let token = loadToken() {
            Task { await restoreSession(with: token) }
        }
    }

    // MARK: - Keychain helpers
    private func saveToken(_ token: String) {
        guard let data = token.data(using: .utf8) else { return }
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: tokenAccount,
            kSecValueData: data,
            kSecAttrAccessible: kSecAttrAccessibleAfterFirstUnlock
        ]
        SecItemDelete(query as CFDictionary) // remove old
        SecItemAdd(query as CFDictionary, nil)
    }

    private func loadToken() -> String? {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: tokenAccount,
            kSecReturnData: kCFBooleanTrue!,
            kSecMatchLimit: kSecMatchLimitOne
        ]
        var item: CFTypeRef?
        guard SecItemCopyMatching(query as CFDictionary, &item) == errSecSuccess,
              let data = item as? Data,
              let token = String(data: data, encoding: .utf8) else { return nil }
        return token
    }

    private func clearToken() {
        SecItemDelete([kSecClass: kSecClassGenericPassword, kSecAttrAccount: tokenAccount] as CFDictionary)
    }

    // MARK: - Restore session
    private func restoreSession(with token: String) async {
        guard let url = URL(string: "\(APIConfig.baseURL)/api/me") else { return }
        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        do {
            let (data, response) = try await URLSession.shared.data(for: req)
            guard let http = response as? HTTPURLResponse, 200...299 ~= http.statusCode,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let userDict = json["user"] as? [String: Any],
                  let email = userDict["email"] as? String else {
                clearToken()
                return
            }
            await MainActor.run {
                self.currentUser = User(email: email)
                self.apiService.setAuthToken(token)
            }
        } catch {
            // Network error – keep token and try next launch
        }
    }
    
    // MARK: - Authentication
    func signUp(email: String, password: String) async -> Bool {
        await MainActor.run { isLoading = true }
        let endpoint = "\(APIConfig.baseURL)/api/register"
        let body = ["email": email, "password": password]
        if let result = await performAuthRequest(endpoint: endpoint, body: body) {
            await MainActor.run { self.currentUser = result.user; self.isLoading = false }
            return true
        } else {
            await MainActor.run { self.isLoading = false }
            return false
        }
    }

    func signIn(email: String, password: String) async -> Bool {
        await MainActor.run { isLoading = true }
        let endpoint = "\(APIConfig.baseURL)/api/login"
        let body = ["email": email, "password": password]
        if let result = await performAuthRequest(endpoint: endpoint, body: body) {
            await MainActor.run { self.currentUser = result.user; self.isLoading = false }
            return true
        } else {
            await MainActor.run { self.isLoading = false }
            return false
        }
    }

    private func performAuthRequest(endpoint: String, body: [String: String]) async -> (user: User, token: String)? {
        guard let url = URL(string: endpoint),
              let data = try? JSONSerialization.data(withJSONObject: body) else { return nil }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = data
        do {
            let (respData, resp) = try await URLSession.shared.data(for: req)
            guard let http = resp as? HTTPURLResponse, 200...299 ~= http.statusCode,
                  let json = try? JSONSerialization.jsonObject(with: respData) as? [String: Any],
                  let token = json["access_token"] as? String,
                  let userDict = json["user"] as? [String: Any],
                  let email = userDict["email"] as? String else { return nil }
            let user = User(email: email)
            saveToken(token)
            apiService.setAuthToken(token)
            return (user, token)
        } catch { return nil }
    }

    // MARK: - Phone-based auth ------------------------------------------------

    @MainActor
    func requestCode(phone: String) async -> Bool {
        guard let url = URL(string: APIConfig.url(for: "requestCode")),
              let data = try? JSONSerialization.data(withJSONObject: ["phone": phone]) else { return false }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            let (_, resp) = try await URLSession.shared.data(for: req)
            guard let http = resp as? HTTPURLResponse, 200...299 ~= http.statusCode else { return false }
            return true
        } catch { return false }
    }

    @MainActor
    func phoneSignUp(phone: String, code: String, displayName: String, email: String?, password: String?) async -> Bool {
        guard let url = URL(string: APIConfig.url(for: "register")) else { return false }
        var body: [String: Any] = [
            "phone": phone,
            "code": code,
            "displayName": displayName
        ]
        if let email = email { body["email"] = email }
        if let password = password { body["password"] = password }
        guard let data = try? JSONSerialization.data(withJSONObject: body) else { return false }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.httpBody = data
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            let (respData, resp) = try await URLSession.shared.data(for: req)
            guard let http = resp as? HTTPURLResponse, 200...299 ~= http.statusCode,
                  let json = try? JSONSerialization.jsonObject(with: respData) as? [String: Any],
                  let token = json["access_token"] as? String,
                  let userDict = json["user"] as? [String: Any] else { return false }
            let user = User(email: userDict["email"] as? String ?? "", phoneNumber: phone, displayName: displayName)
            saveToken(token)
            apiService.setAuthToken(token)
            currentUser = user
            return true
        } catch { return false }
    }

    func signOut() {
        currentUser = nil
        disputes = []
        clearToken()
        apiService.setAuthToken(nil)
    }
    
    // MARK: - Dispute Management
    func createDispute(title: String, description: String, category: String, createContract: Bool) async -> String? {
        await MainActor.run { isLoading = true }
        
        let disputeId = await apiService.createDispute(
            title: title,
            description: description,
            category: category,
            createContract: createContract
        )
        
        await MainActor.run { isLoading = false }
        
        if let disputeId = disputeId {
            // Refresh disputes list
            await loadUserDisputes()
        }
        
        return disputeId
    }
    
    func loadUserDisputes() async {
        await MainActor.run { isLoading = true }
        
        let fetchedDisputes = await apiService.getDisputes()
        
        await MainActor.run {
            disputes = fetchedDisputes
            isLoading = false
        }
    }
    
    func submitTruth(disputeId: String, content: String, attachments: [Attachment] = []) async -> Bool {
        await MainActor.run { isLoading = true }
        
        let success = await apiService.submitTruth(
            disputeId: disputeId,
            content: content,
            attachments: attachments
        )
        
        await MainActor.run { isLoading = false }
        
        if success {
            // Refresh dispute details
            await loadUserDisputes()
        }
        
        return success
    }
    
    func joinDispute(inviteCode: String) async -> Bool {
        await MainActor.run { isLoading = true }
        
        // Implementation for joining dispute
        // This would call the backend API to join a dispute
        
        await MainActor.run { isLoading = false }
        return true
    }
    
    // MARK: - Mock Data for Development
    func loadMockDisputes() {
        // This provides mock data while you're setting up the backend
        guard let user = currentUser else {
            print("⚠️ Cannot load mock disputes: currentUser is nil")
            return
        }
        
        let mockDispute = Dispute(
            id: UUID(),
            title: "Test Dispute",
            description: "This is a test dispute",
            category: .services,
            disputeValue: 100.0,
            user: user
        )
        
        disputes = [mockDispute]
    }
    
    // MARK: - Helper Methods
    func getDisputeById(_ id: UUID) -> Dispute? {
        return disputes.first { $0.id == id }
    }
    
    func refreshDispute(_ disputeId: UUID) async {
        // Refresh specific dispute from backend
        await loadUserDisputes()
    }
}

// MARK: - Real API Service Integration
extension RealDisputeService {
    
    func setupRealAPI() {
        // Configure API service with Vercel backend
        // This ensures all API calls go to your deployed backend
        print("🔄 Connecting to Vercel backend: \(APIConfig.baseURL)")
    }
    
    func enableMockMode() {
        // For development/testing when backend is not available
        print("⚠️ Using mock mode - switch to real API when backend is deployed")
        loadMockDisputes()
    }
}

// MARK: - Usage Instructions
/*
 To use this service in your SwiftUI views:

 1. Replace MockAuthService with RealDisputeService:
    @StateObject private var disputeService = RealDisputeService()

 2. Update your APIConfig.swift with your Vercel URL:
    static let baseURL = "https://your-vercel-backend.vercel.app"

 3. Use the service in your views:
    // Create dispute
    let disputeId = await disputeService.createDispute(
        title: "My Dispute",
        description: "Description here",
        category: "contract",
        createContract: true  // This enables contract generation!
    )

    // Submit truth
    let success = await disputeService.submitTruth(
        disputeId: disputeId,
        content: "My side of the story...",
        attachments: []
    )

 4. The backend will:
    - Process both parties' truths
    - AI will ask clarifying questions
    - AI will generate fair resolution
    - AI will create legal contract (if checkbox was checked)
*/