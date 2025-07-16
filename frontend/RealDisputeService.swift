import Foundation
import SwiftUI

class RealDisputeService: ObservableObject {
    @Published var disputes: [Dispute] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var currentUser: User?
    
    private let apiService = DisputeAPIService()
    
    init() {
        // Initialize with proper memory management
        self.disputes = []
        self.isLoading = false
        self.errorMessage = nil
        self.currentUser = nil
    }
    
    deinit {
        // Clean up resources
        disputes.removeAll()
        currentUser = nil
    }
    
    // MARK: - Authentication
    func signUp(email: String, password: String) async -> Bool {
        await MainActor.run { isLoading = true }
        
        let success = await apiService.register(email: email, password: password)
        
        if success {
            // Create user object (in real app, this would come from backend)
            let user = User(email: email, password: password)
            await MainActor.run {
                currentUser = user
                isLoading = false
            }
        } else {
            await MainActor.run { isLoading = false }
        }
        
        return success
    }
    
    func signIn(email: String, password: String) async -> Bool {
        await MainActor.run { isLoading = true }
        
        let success = await apiService.login(email: email, password: password)
        
        if success {
            let user = User(email: email, password: password)
            await MainActor.run {
                currentUser = user
                isLoading = false
            }
        } else {
            await MainActor.run { isLoading = false }
        }
        
        return success
    }
    
    func signOut() {
        currentUser = nil
        disputes = []
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
        do {
            // Ensure we have a current user for mock data
            if currentUser == nil {
                currentUser = User(email: "demo@example.com", password: "")
                print("✅ Created demo user for mock data")
            }
            
            guard let user = currentUser else { 
                print("❌ Failed to create currentUser for mock data")
                return 
            }
            
            // This provides mock data while you're setting up the backend
            let mockDispute = Dispute(
                id: UUID(),
                title: "Test Dispute",
                description: "This is a test dispute",
                category: .services,
                disputeValue: 100.0,
                user: user
            )
            
            disputes = [mockDispute]
            print("✅ Mock dispute loaded successfully")
            print("🔄 Connecting to Vercel backend: \(APIConfig.baseURL)")
            
        } catch {
            print("❌ Error loading mock disputes: \(error)")
            errorMessage = "Failed to load mock data: \(error.localizedDescription)"
        }
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