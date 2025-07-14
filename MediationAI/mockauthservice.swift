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
}

// MARK: - Mock Dispute Service

class MockDisputeService: ObservableObject {
    @Published var disputes: [Dispute] = []
    
    func createDispute(title: String, description: String, user: User) -> Dispute {
        let shareCode = UUID().uuidString.prefix(6).uppercased()
        let dispute = Dispute(
            id: UUID(),
            title: title,
            description: description,
            partyA: user,
            partyB: nil,
            truths: [],
            isResolved: false,
            resolution: nil,
            shareCode: String(shareCode)
        )
        disputes.append(dispute)
        return dispute
    }
    
    func joinDispute(shareCode: String, user: User) -> Dispute? {
        guard let index = disputes.firstIndex(where: { $0.shareCode == shareCode }) else { return nil }
        if disputes[index].partyB == nil && disputes[index].partyA?.id != user.id {
            disputes[index].partyB = user
        }
        return disputes[index]
    }
    
    func addTruth(to dispute: Dispute, truth: Truth) {
        guard let index = disputes.firstIndex(where: { $0.id == dispute.id }) else { return }
        disputes[index].truths.append(truth)
    }
    
    func resolveDispute(_ dispute: Dispute, resolution: String) {
        guard let index = disputes.firstIndex(where: { $0.id == dispute.id }) else { return }
        disputes[index].isResolved = true
        disputes[index].resolution = resolution
    }
}

// MARK: - Mock Grok API

class MockGrokAPI {
    func resolveDispute(truths: [Truth], completion: @escaping (String) -> Void) {
        // Simulate API delay and return a mock resolution
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            completion("After reviewing both parties' submissions, the recommended resolution is: Compromise and split the difference.")
        }
    }
}
