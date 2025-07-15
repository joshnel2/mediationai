//
//  MockAuthService.swift
//  MediationAI
//
//  Created by Linda Alster on 7/14/25.
//

import Foundation
import SwiftUI

// MARK: - Mock Auth Service

class MockAuthService: ObservableObject {
    @Published var currentUser: User?
    @Published var users: [User] = []
    
    func signUp(email: String, password: String) -> Bool {
        guard !users.contains(where: { $0.email == email }) else { return false }
        let user = User(id: UUID(), email: email, password: password)
        users.append(user)
        currentUser = user
        return true
    }
    
    func signIn(email: String, password: String) -> Bool {
        guard let user = users.first(where: { $0.email == email && $0.password == password }) else { return false }
        currentUser = user
        return true
    }
    
    func signOut() {
        currentUser = nil
    }
    
    func updateUser(_ user: User) {
        currentUser = user
        if let index = users.firstIndex(where: { $0.id == user.id }) {
            users[index] = user
        }
    }
}

// MARK: - Mock Dispute Service

class MockDisputeService: ObservableObject {
    @Published var disputes: [Dispute] = []
    
    func createDispute(title: String, description: String, user: User) -> Dispute {
        let shareCode = UUID().uuidString.prefix(6).uppercased()
        let disputeId = UUID()
        let shareLink = "https://mediationai.app/join/\(disputeId.uuidString)"
        
        let dispute = Dispute(
            id: disputeId,
            title: title,
            description: description,
            user: user
        )
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
