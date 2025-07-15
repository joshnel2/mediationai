//
//  User.swift
//  MediationAI
//
//  Created by Linda Alster on 7/14/25.
//

import Foundation
import SwiftUI

struct User: Identifiable, Codable {
    let id: UUID
    let email: String
    var profile: UserProfile
    var reputation: ReputationScore
    var verification: VerificationStatus
    var stats: UserStats
    var preferences: UserPreferences
    var hasUsedFreeDispute: Bool = false
    
    init(id: UUID = UUID(), email: String) {
        self.id = id
        self.email = email
        self.profile = UserProfile()
        self.reputation = ReputationScore()
        self.verification = VerificationStatus()
        self.stats = UserStats()
        self.preferences = UserPreferences()
        self.hasUsedFreeDispute = false
    }
}

struct UserProfile: Codable {
    var displayName: String = ""
    var profileImage: String? = nil
    var bio: String = ""
    var location: String = ""
    var languages: [String] = ["English"]
    var expertise: [DisputeCategory] = []
    var joinedDate: Date = Date()
    
    var isComplete: Bool {
        !displayName.isEmpty && !bio.isEmpty
    }
}

struct ReputationScore: Codable {
    var overall: Double = 500.0  // Start at neutral 500
    var truthfulness: Double = 500.0
    var fairness: Double = 500.0
    var responsiveness: Double = 500.0
    var level: ReputationLevel {
        switch overall {
        case 0..<200: return .unreliable
        case 200..<400: return .novice
        case 400..<600: return .trusted
        case 600..<800: return .expert
        case 800..<950: return .master
        default: return .legendary
        }
    }
    
    var badge: String {
        switch level {
        case .unreliable: return "⚪"
        case .novice: return "🔵"
        case .trusted: return "⚫"
        case .expert: return "🔷"
        case .master: return "◆"
        case .legendary: return "★"
        }
    }
    
    var achievements: [Achievement] = []
}

enum ReputationLevel: String, Codable, CaseIterable {
    case unreliable = "Unreliable"
    case novice = "Novice"
    case trusted = "Trusted"
    case expert = "Expert"
    case master = "Master"
    case legendary = "Legendary"
}

struct Achievement: Identifiable, Codable {
    let id = UUID()
    let title: String
    let description: String
    let icon: String
    let earnedDate: Date
    let rarity: AchievementRarity
}

enum AchievementRarity: String, Codable {
    case common = "Common"
    case rare = "Rare"
    case epic = "Epic"
    case legendary = "Legendary"
}

struct VerificationStatus: Codable {
    var isEmailVerified: Bool = false
    var isPhoneVerified: Bool = false
    var isIdentityVerified: Bool = false
    var isBiometricEnabled: Bool = false
    var verificationLevel: VerificationLevel {
        let count = [isEmailVerified, isPhoneVerified, isIdentityVerified].filter { $0 }.count
        switch count {
        case 0: return .unverified
        case 1: return .basic
        case 2: return .verified
        default: return .premium
        }
    }
}

enum VerificationLevel: String, Codable {
    case unverified = "Unverified"
    case basic = "Basic"
    case verified = "Verified"
    case premium = "Premium"
}

enum SubscriptionTier: String, Codable, CaseIterable {
    case basic = "Basic"
    case premium = "Premium"
    case expert = "Expert"
    case enterprise = "Enterprise"
    
    var monthlyPrice: Double {
        switch self {
        case .basic: return 0.0
        case .premium: return 9.99
        case .expert: return 29.99
        case .enterprise: return 99.99
        }
    }
    
    var features: [String] {
        switch self {
        case .basic:
            return ["$1 per dispute", "Basic AI resolution", "24-48hr response time"]
        case .premium:
            return ["Unlimited disputes", "Advanced AI models", "Priority processing", "Evidence analysis", "6-12hr response time"]
        case .expert:
            return ["All Premium features", "Human expert backup", "Legal precedent analysis", "2-4hr response time", "Dispute coaching"]
        case .enterprise:
            return ["All Expert features", "Custom integrations", "Dedicated support", "1hr response time", "Legal document generation"]
        }
    }
    
    var maxDisputeValue: Double {
        switch self {
        case .basic: return 500
        case .premium: return 5000
        case .expert: return 50000
        case .enterprise: return 500000
        }
    }
}

struct UserStats: Codable {
    var totalDisputes: Int = 0
    var disputesWon: Int = 0
    var disputesLost: Int = 0
    var averageResolutionTime: TimeInterval = 0
    var totalSaved: Double = 0  // Money saved vs legal fees
    var satisfactionRating: Double = 0
    var streakDays: Int = 0
    var lastActiveDate: Date = Date()
    
    var winRate: Double {
        guard totalDisputes > 0 else { return 0 }
        return Double(disputesWon) / Double(totalDisputes) * 100
    }
    
    var level: Int {
        return min(totalDisputes / 10 + 1, 50)  // Level up every 10 disputes, max level 50
    }
}

struct UserPreferences: Codable {
    var notificationsEnabled: Bool = true
    var emailUpdates: Bool = true
    var preferredLanguage: String = "en"
    var autoAcceptFairResolutions: Bool = false
    var allowPublicProfile: Bool = false
    var preferredResolutionStyle: ResolutionStyle = .balanced
    var maxDisputeValue: Double = 1000
}

enum ResolutionStyle: String, Codable, CaseIterable {
    case conservative = "Conservative"
    case balanced = "Balanced"
    case progressive = "Progressive"
    
    var description: String {
        switch self {
        case .conservative: return "Favor traditional solutions and precedents"
        case .balanced: return "Consider all perspectives equally"
        case .progressive: return "Favor innovative and forward-thinking solutions"
        }
    }
}

enum DisputeCategory: String, Codable, CaseIterable {
    case ecommerce = "E-commerce"
    case rental = "Rental & Housing"
    case employment = "Employment"
    case services = "Services"
    case relationships = "Relationships"
    case technology = "Technology"
    case finance = "Finance"
    case travel = "Travel"
    case education = "Education"
    case healthcare = "Healthcare"
    case other = "Other"
    
    var icon: String {
        switch self {
        case .ecommerce: return "cart.fill"
        case .rental: return "house.fill"
        case .employment: return "briefcase.fill"
        case .services: return "wrench.and.screwdriver.fill"
        case .relationships: return "heart.fill"
        case .technology: return "laptopcomputer"
        case .finance: return "dollarsign.circle.fill"
        case .travel: return "airplane"
        case .education: return "graduationcap.fill"
        case .healthcare: return "cross.case.fill"
        case .other: return "questionmark.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .ecommerce: return Color(red: 0.11, green: 0.63, blue: 0.95) // Twitter blue
        case .rental: return Color(red: 0.05, green: 0.46, blue: 0.86) // Darker blue
        case .employment: return Color(red: 0.20, green: 0.70, blue: 1.0) // Bright blue
        case .services: return Color(red: 0.0, green: 0.78, blue: 0.0) // Clean green
        case .relationships: return Color.white.opacity(0.9) // Clean white
        case .technology: return Color(red: 0.11, green: 0.63, blue: 0.95) // Twitter blue
        case .finance: return Color(red: 0.0, green: 0.78, blue: 0.0) // Clean green
        case .travel: return Color(red: 0.05, green: 0.46, blue: 0.86) // Darker blue
        case .education: return Color(red: 0.20, green: 0.70, blue: 1.0) // Bright blue
        case .healthcare: return Color(red: 0.95, green: 0.24, blue: 0.24) // Clean red
        case .other: return Color.white.opacity(0.6) // Muted white
        }
    }
}

// Enhanced Dispute model
struct Dispute: Identifiable, Codable {
    let id: UUID
    var title: String
    var description: String
    var category: DisputeCategory
    var disputeValue: Double
    var priority: DisputePriority
    var status: DisputeStatus
    var partyA: User?
    var partyB: User?
    var createdAt: Date
    var resolvedAt: Date?
    var resolution: Resolution?
    var truths: [Truth]
    var evidence: [Evidence]
    var shareLink: String
    var creatorPaid: Bool
    var joinerPaid: Bool
    var isPublic: Bool
    var tags: [String]
    var expertReviewRequested: Bool
    var urgencyLevel: UrgencyLevel
    var satisfactionRatings: [SatisfactionRating]
    
    var isResolved: Bool {
        resolution != nil
    }
    
    var timeToResolution: TimeInterval? {
        guard let resolvedAt = resolvedAt else { return nil }
        return resolvedAt.timeIntervalSince(createdAt)
    }
    
    var averageSatisfaction: Double {
        guard !satisfactionRatings.isEmpty else { return 0 }
        return satisfactionRatings.map { $0.rating }.reduce(0, +) / Double(satisfactionRatings.count)
    }
    
    init(id: UUID = UUID(), title: String, description: String, category: DisputeCategory = .other, disputeValue: Double = 100, user: User) {
        self.id = id
        self.title = title
        self.description = description
        self.category = category
        self.disputeValue = disputeValue
        self.priority = DisputePriority.from(value: disputeValue)
        self.status = .inviteSent
        self.partyA = user
        self.partyB = nil
        self.createdAt = Date()
        self.resolvedAt = nil
        self.resolution = nil
        self.truths = []
        self.evidence = []
        self.shareLink = "https://mediationai.app/join/\(id.uuidString)"
        self.creatorPaid = false
        self.joinerPaid = false
        self.isPublic = false
        self.tags = []
        self.expertReviewRequested = false
        self.urgencyLevel = .normal
        self.satisfactionRatings = []
    }
}

enum DisputePriority: String, Codable {
    case low = "Low"
    case normal = "Normal"
    case high = "High"
    case urgent = "Urgent"
    
    static func from(value: Double) -> DisputePriority {
        switch value {
        case 0..<100: return .low
        case 100..<1000: return .normal
        case 1000..<10000: return .high
        default: return .urgent
        }
    }
    
    var color: Color {
        switch self {
        case .low: return Color(red: 0.0, green: 0.78, blue: 0.0) // Clean green
        case .normal: return Color(red: 0.11, green: 0.63, blue: 0.95) // Twitter blue
        case .high: return Color.white.opacity(0.9) // Clean white
        case .urgent: return Color(red: 0.95, green: 0.24, blue: 0.24) // Clean red
        }
    }
}

enum UrgencyLevel: String, Codable {
    case normal = "Normal"
    case express = "Express (2x fee)"
    case emergency = "Emergency (5x fee)"
    
    var multiplier: Double {
        switch self {
        case .normal: return 1.0
        case .express: return 2.0
        case .emergency: return 5.0
        }
    }
}

struct Evidence: Identifiable, Codable {
    let id = UUID()
    let type: EvidenceType
    let url: String
    let description: String
    let uploadedBy: UUID  // User ID
    let uploadedAt: Date
    let verified: Bool
}

enum EvidenceType: String, Codable {
    case image = "Image"
    case document = "Document"
    case video = "Video"
    case audio = "Audio"
    case receipt = "Receipt"
    case contract = "Contract"
    case screenshot = "Screenshot"
    case other = "Other"
}

struct SatisfactionRating: Identifiable, Codable {
    let id = UUID()
    let userId: UUID
    let rating: Double  // 1-5 stars
    let feedback: String
    let createdAt: Date
}

struct Truth: Identifiable, Codable {
    let id: UUID
    let userId: UUID
    let text: String
    let attachments: [Attachment]
    let submittedAt: Date
    let wordCount: Int
    let sentiment: SentimentScore?
    let credibilityScore: Double?
    
    init(id: UUID = UUID(), userId: UUID, text: String, attachments: [Attachment] = [], submittedAt: Date = Date()) {
        self.id = id
        self.userId = userId
        self.text = text
        self.attachments = attachments
        self.submittedAt = submittedAt
        self.wordCount = text.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }.count
        self.sentiment = nil  // Would be analyzed by AI
        self.credibilityScore = nil  // Would be analyzed by AI
    }
}

struct SentimentScore: Codable {
    let positive: Double
    let negative: Double
    let neutral: Double
    let confidence: Double
}

struct Attachment: Identifiable, Codable {
    let id: UUID
    let name: String
    let type: String
    let size: Int64
    let url: String?
    
    init(id: UUID = UUID(), name: String, type: String, size: Int64 = 0, url: String? = nil) {
        self.id = id
        self.name = name
        self.type = type
        self.size = size
        self.url = url
    }
}

struct Resolution: Identifiable, Codable {
    let id: UUID
    let summary: String
    let decision: String
    let reasoning: String
    let compensationAwarded: Double
    let winner: UUID?  // User ID of winner, nil for tie/compromise
    let confidence: Double
    let createdAt: Date
    let aiModel: AIModel
    let humanReviewed: Bool
    let actionItems: [ActionItem]
    let precedents: [LegalPrecedent]
    
    init(id: UUID = UUID(), summary: String, decision: String, reasoning: String, compensationAwarded: Double = 0, winner: UUID? = nil, confidence: Double = 0.85, aiModel: AIModel = .grokAdvanced) {
        self.id = id
        self.summary = summary
        self.decision = decision
        self.reasoning = reasoning
        self.compensationAwarded = compensationAwarded
        self.winner = winner
        self.confidence = confidence
        self.createdAt = Date()
        self.aiModel = aiModel
        self.humanReviewed = false
        self.actionItems = []
        self.precedents = []
    }
}

enum AIModel: String, Codable {
    case grokBasic = "Grok Basic"
    case grokAdvanced = "Grok Advanced"
    case grokLegal = "Grok Legal Expert"
    case humanExpert = "Human Expert"
    
    var accuracy: Double {
        switch self {
        case .grokBasic: return 0.75
        case .grokAdvanced: return 0.85
        case .grokLegal: return 0.92
        case .humanExpert: return 0.98
        }
    }
}

struct ActionItem: Identifiable, Codable {
    let id = UUID()
    let description: String
    let assignedTo: UUID  // User ID
    let dueDate: Date?
    let completed: Bool
}

struct LegalPrecedent: Identifiable, Codable {
    let id = UUID()
    let caseTitle: String
    let jurisdiction: String
    let relevanceScore: Double
    let summary: String
    let url: String?
}

enum DisputeStatus: String, Codable, CaseIterable {
    case inviteSent = "Invite Sent"
    case inProgress = "In Progress"
    case aiAnalyzing = "AI Analyzing"
    case expertReview = "Expert Review"
    case resolved = "Resolved"
    case appealed = "Appealed"
    case archived = "Archived"
}
