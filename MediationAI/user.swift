//
//  User.swift
//  MediationAI
//
//  Created by Linda Alster on 7/14/25.
//


import Foundation

struct User: Identifiable, Equatable {
    let id: UUID
    var email: String
    var password: String // For mock only; never store plaintext in production
}

enum DisputeStatus: String, CaseIterable {
    case inviteSent = "Invite Sent"
    case inProgress = "In Progress"
    case resolved = "View Resolution"
}

struct Dispute: Identifiable {
    let id: UUID
    var title: String
    var description: String
    var partyA: User?
    var partyB: User?
    var truths: [Truth]
    var isResolved: Bool
    var resolution: String?
    var shareCode: String // Legacy - keeping for backward compatibility
    var shareLink: String // New shareable link
    var status: DisputeStatus
    var creatorPaid: Bool
    var joinerPaid: Bool
    var createdAt: Date
}

struct Truth: Identifiable {
    let id: UUID
    let userId: UUID
    var text: String
    var attachments: [Attachment]
    var submittedAt: Date
}

struct Attachment: Identifiable {
    let id: UUID
    var fileName: String
    var fileData: Data
    var fileType: AttachmentType
}

enum AttachmentType: String, Codable {
    case image
    case document
}
