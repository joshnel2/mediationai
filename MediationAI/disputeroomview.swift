//
//  DisputeRoomView.swift
//  MediationAI
//
//  Created by Linda Alster on 7/14/25.
//

import SwiftUI

struct DisputeRoomView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authService: MockAuthService
    @EnvironmentObject var disputeService: MockDisputeService
    @State private var message = ""
    @State private var attachments: [Attachment] = []
    @State private var error: String?
    @State private var isPickerPresented = false
    @State private var showAIProcessing = false
    @State private var animateElements = false
    
    let dispute: Dispute
    
    var myTruth: Truth? {
        dispute.truths.first(where: { $0.userId == authService.currentUser?.id })
    }
    
    var otherTruth: Truth? {
        dispute.truths.first(where: { $0.userId != authService.currentUser?.id })
    }
    
    var canSubmitTruth: Bool {
        dispute.partyB != nil && !dispute.isResolved && myTruth == nil
    }
    
    var waitingForOtherParty: Bool {
        dispute.partyB == nil
    }
    
    var body: some View {
        ZStack {
            // Background gradient
            AppTheme.backgroundGradient
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                headerSection
                
                // Main content
                ScrollView {
                    LazyVStack(spacing: AppTheme.spacingXL) {
                        // Dispute details card
                        disputeDetailsCard
                        
                        // Status banner
                        if waitingForOtherParty {
                            waitingBanner
                        }
                        
                        // Truth submissions
                        truthSubmissionsSection
                        
                        // AI Processing indicator
                        if showAIProcessing {
                            aiProcessingCard
                        }
                        
                        // Resolution
                        if dispute.isResolved, let resolution = dispute.resolution {
                            ResolutionCardView(resolution: resolution)
                                .padding(.horizontal, AppTheme.spacingLG)
                        }
                        
                        Spacer(minLength: AppTheme.spacingXXL)
                    }
                    .padding(.top, AppTheme.spacingLG)
                }
                
                // Input section
                inputSection
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            withAnimation(.easeOut(duration: 0.8).delay(0.2)) {
                animateElements = true
            }
        }
        .onChange(of: dispute.truths) { _ in
            // Show AI processing when both parties have submitted
            if myTruth != nil && otherTruth != nil && !dispute.isResolved {
                showAIProcessing = true
            }
            
            // Hide AI processing when resolved
            if dispute.isResolved {
                showAIProcessing = false
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: AppTheme.spacingMD) {
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundColor(AppTheme.textPrimary)
                        .frame(width: 32, height: 32)
                        .background(AppTheme.glassPrimary)
                        .cornerRadius(AppTheme.radiusSM)
                }
                
                Spacer()
                
                Text("Dispute Room")
                    .font(AppTheme.title3())
                    .foregroundColor(AppTheme.textPrimary)
                    .fontWeight(.semibold)
                
                Spacer()
                
                // Status indicator
                statusIndicator
            }
        }
        .padding(.horizontal, AppTheme.spacingLG)
        .padding(.top, AppTheme.spacingSM)
    }
    
    private var statusIndicator: some View {
        HStack(spacing: AppTheme.spacingSM) {
            Circle()
                .fill(statusColor)
                .frame(width: 8, height: 8)
            
            Text(dispute.status.rawValue)
                .font(AppTheme.caption())
                .foregroundColor(statusColor)
                .fontWeight(.medium)
        }
        .padding(.horizontal, AppTheme.spacingMD)
        .padding(.vertical, AppTheme.spacingSM)
        .background(statusColor.opacity(0.1))
        .cornerRadius(AppTheme.radiusMD)
    }
    
    private var statusColor: Color {
        switch dispute.status {
        case .inviteSent: return AppTheme.warning
        case .inProgress: return AppTheme.info
        case .resolved: return AppTheme.success
        }
    }
    
    private var disputeDetailsCard: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingLG) {
            VStack(alignment: .leading, spacing: AppTheme.spacingMD) {
                Text(dispute.title)
                    .font(AppTheme.title2())
                    .foregroundColor(AppTheme.textPrimary)
                    .fontWeight(.bold)
                
                Text(dispute.description)
                    .font(AppTheme.body())
                    .foregroundColor(AppTheme.textSecondary)
                    .lineSpacing(4)
            }
            
            HStack {
                Label("Created \(dispute.createdAt.formatted(date: .abbreviated, time: .omitted))", 
                      systemImage: "calendar")
                .font(AppTheme.caption())
                .foregroundColor(AppTheme.textTertiary)
                
                Spacer()
                
                if dispute.partyB != nil {
                    Label("Both parties joined", systemImage: "person.2.fill")
                        .font(AppTheme.caption())
                        .foregroundColor(AppTheme.success)
                } else {
                    Label("Waiting for other party", systemImage: "clock.fill")
                        .font(AppTheme.caption())
                        .foregroundColor(AppTheme.warning)
                }
            }
        }
        .padding(AppTheme.spacingLG)
        .glassCard()
        .padding(.horizontal, AppTheme.spacingLG)
        .scaleEffect(animateElements ? 1.0 : 0.95)
        .opacity(animateElements ? 1.0 : 0.0)
        .animation(.easeOut(duration: 0.6).delay(0.1), value: animateElements)
    }
    
    private var waitingBanner: some View {
        HStack(spacing: AppTheme.spacingMD) {
            Image(systemName: "clock.fill")
                .foregroundColor(AppTheme.warning)
                .font(.title3)
            
            VStack(alignment: .leading, spacing: AppTheme.spacingSM) {
                Text("Waiting for other party to join")
                    .font(AppTheme.headline())
                    .foregroundColor(AppTheme.textPrimary)
                    .fontWeight(.semibold)
                
                Text("Share your dispute link to get them involved")
                    .font(AppTheme.caption())
                    .foregroundColor(AppTheme.textSecondary)
            }
            
            Spacer()
        }
        .padding(AppTheme.spacingLG)
        .background(AppTheme.warning.opacity(0.1))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.radiusLG)
                .stroke(AppTheme.warning.opacity(0.3), lineWidth: 1)
        )
        .cornerRadius(AppTheme.radiusLG)
        .padding(.horizontal, AppTheme.spacingLG)
    }
    
    private var truthSubmissionsSection: some View {
        VStack(spacing: AppTheme.spacingXL) {
            if let partyA = dispute.partyA {
                ModernTruthBubble(
                    user: partyA,
                    truth: dispute.truths.first(where: { $0.userId == partyA.id }),
                    isMe: partyA.id == authService.currentUser?.id
                )
                .scaleEffect(animateElements ? 1.0 : 0.95)
                .opacity(animateElements ? 1.0 : 0.0)
                .animation(.easeOut(duration: 0.6).delay(0.2), value: animateElements)
            }
            
            if let partyB = dispute.partyB {
                ModernTruthBubble(
                    user: partyB,
                    truth: dispute.truths.first(where: { $0.userId == partyB.id }),
                    isMe: partyB.id == authService.currentUser?.id
                )
                .scaleEffect(animateElements ? 1.0 : 0.95)
                .opacity(animateElements ? 1.0 : 0.0)
                .animation(.easeOut(duration: 0.6).delay(0.3), value: animateElements)
            }
        }
    }
    
    private var aiProcessingCard: some View {
        VStack(spacing: AppTheme.spacingLG) {
            HStack(spacing: AppTheme.spacingMD) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.primary))
                    .scaleEffect(1.2)
                
                VStack(alignment: .leading, spacing: AppTheme.spacingSM) {
                    Text("🤖 Grok AI is analyzing...")
                        .font(AppTheme.headline())
                        .foregroundColor(AppTheme.textPrimary)
                        .fontWeight(.semibold)
                    
                    Text("Processing both submissions to provide a fair resolution")
                        .font(AppTheme.caption())
                        .foregroundColor(AppTheme.textSecondary)
                }
                
                Spacer()
            }
        }
        .padding(AppTheme.spacingLG)
        .glassCard()
        .padding(.horizontal, AppTheme.spacingLG)
    }
    
    private var inputSection: some View {
        VStack(spacing: 0) {
            if canSubmitTruth {
                truthInputCard
            } else if !dispute.isResolved && myTruth != nil && otherTruth == nil {
                waitingForOtherTruthCard
            }
        }
    }
    
    private var truthInputCard: some View {
        VStack(spacing: AppTheme.spacingLG) {
            VStack(alignment: .leading, spacing: AppTheme.spacingMD) {
                HStack {
                    Text("📝 Submit Your Truth")
                        .font(AppTheme.headline())
                        .foregroundColor(AppTheme.textPrimary)
                        .fontWeight(.semibold)
                    
                    Spacer()
                }
                
                Text("Share your side of the story with evidence. Once both parties submit, Grok AI will provide a resolution.")
                    .font(AppTheme.caption())
                    .foregroundColor(AppTheme.textSecondary)
                    .lineSpacing(3)
            }
            
            VStack(spacing: AppTheme.spacingMD) {
                TextField("Describe your truth...", text: $message, axis: .vertical)
                    .modernTextField()
                    .frame(minHeight: 80)
                
                HStack {
                    Button(action: { isPickerPresented = true }) {
                        Label("Attach Files", systemImage: "paperclip")
                            .font(AppTheme.caption())
                            .foregroundColor(AppTheme.textSecondary)
                            .padding(.horizontal, AppTheme.spacingMD)
                            .padding(.vertical, AppTheme.spacingSM)
                            .background(AppTheme.glassSecondary)
                            .cornerRadius(AppTheme.radiusSM)
                    }
                    .sheet(isPresented: $isPickerPresented) {
                        AttachmentPicker(attachments: $attachments)
                    }
                    
                    if !attachments.isEmpty {
                        Text("\(attachments.count) file(s)")
                            .font(AppTheme.caption2())
                            .foregroundColor(AppTheme.textTertiary)
                    }
                    
                    Spacer()
                    
                    Button(action: handleSend) {
                        HStack {
                            if authService.currentUser?.hasUsedFreeDispute == true && !hasUserPaidForThisDispute() {
                                Image(systemName: "creditcard.fill")
                                    .font(.headline)
                                Text("Pay $1 & Submit Truth")
                                    .font(AppTheme.headline())
                                    .fontWeight(.semibold)
                            } else {
                                Image(systemName: "paperplane.fill")
                                    .font(.headline)
                                Text("Submit Truth")
                                    .font(AppTheme.headline())
                                    .fontWeight(.semibold)
                            }
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, AppTheme.spacingLG)
                        .padding(.vertical, AppTheme.spacingMD)
                        .background(AppTheme.mainGradient)
                        .cornerRadius(AppTheme.radiusLG)
                        .shadow(color: AppTheme.primary.opacity(0.3), radius: 4, x: 0, y: 2)
                    }
                }
                
                if let error = error {
                    Text(error)
                        .font(AppTheme.caption())
                        .foregroundColor(AppTheme.error)
                        .padding(.horizontal, AppTheme.spacingSM)
                }
            }
        }
        .padding(AppTheme.spacingLG)
        .glassCard()
        .padding(.horizontal, AppTheme.spacingLG)
        .padding(.bottom, AppTheme.spacingLG)
    }
    
    private var waitingForOtherTruthCard: some View {
        VStack(spacing: AppTheme.spacingMD) {
            HStack(spacing: AppTheme.spacingMD) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(AppTheme.success)
                    .font(.title3)
                
                VStack(alignment: .leading, spacing: AppTheme.spacingSM) {
                    Text("Your truth has been submitted")
                        .font(AppTheme.headline())
                        .foregroundColor(AppTheme.success)
                        .fontWeight(.semibold)
                    
                    Text("Waiting for the other party to submit their truth...")
                        .font(AppTheme.caption())
                        .foregroundColor(AppTheme.textSecondary)
                }
                
                Spacer()
            }
        }
        .padding(AppTheme.spacingLG)
        .background(AppTheme.success.opacity(0.1))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.radiusLG)
                .stroke(AppTheme.success.opacity(0.3), lineWidth: 1)
        )
        .cornerRadius(AppTheme.radiusLG)
        .padding(.horizontal, AppTheme.spacingLG)
        .padding(.bottom, AppTheme.spacingLG)
    }
    
    private func handleSend() {
        error = nil
        guard let user = authService.currentUser else { return }
        if message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            error = "Please enter your truth."
            return
        }
        
        // Check if user needs to pay for truth submission
        let needsPayment = user.hasUsedFreeDispute && !hasUserPaidForThisDispute()
        
        if needsPayment {
            // Show payment required
            processTruthPayment { success in
                if success {
                    submitTruth()
                } else {
                    error = "Payment failed. Please try again."
                }
            }
        } else {
            submitTruth()
        }
    }
    
    private func hasUserPaidForThisDispute() -> Bool {
        // Check if user has already paid for this dispute
        // For now, we'll assume they pay once per dispute participation
        return dispute.creatorPaid && dispute.partyA?.id == authService.currentUser?.id ||
               dispute.joinerPaid && dispute.partyB?.id == authService.currentUser?.id
    }
    
    private func processTruthPayment(completion: @escaping (Bool) -> Void) {
        // In a real app, this would process the $1 payment
        // For demo purposes, we'll simulate success
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            completion(true)
        }
    }
    
    private func submitTruth() {
        guard let user = authService.currentUser else { return }
        
        let truth = Truth(
            id: UUID(),
            userId: user.id,
            text: message,
            attachments: attachments,
            submittedAt: Date()
        )
        
        disputeService.addTruth(to: dispute, truth: truth)
        message = ""
        attachments = []
    }
}

struct ModernTruthBubble: View {
    let user: User
    let truth: Truth?
    let isMe: Bool
    @State private var animateIn = false
    
    var body: some View {
        HStack {
            if isMe { Spacer() }
            
            VStack(alignment: isMe ? .trailing : .leading, spacing: AppTheme.spacingMD) {
                // User label
                HStack {
                    if !isMe {
                        Text(user.email.components(separatedBy: "@").first?.capitalized ?? user.email)
                            .font(AppTheme.caption())
                            .fontWeight(.semibold)
                            .foregroundColor(AppTheme.textSecondary)
                        Spacer()
                    } else {
                        Spacer()
                        Text("You")
                            .font(AppTheme.caption())
                            .fontWeight(.semibold)
                            .foregroundColor(AppTheme.textSecondary)
                    }
                }
                
                if let truth = truth {
                    VStack(alignment: isMe ? .trailing : .leading, spacing: AppTheme.spacingMD) {
                        // Truth content
                        VStack(alignment: .leading, spacing: AppTheme.spacingMD) {
                            Text(truth.text)
                                .font(AppTheme.body())
                                .foregroundColor(isMe ? .white : AppTheme.textPrimary)
                                .lineSpacing(4)
                            
                            // Attachments
                            if !truth.attachments.isEmpty {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: AppTheme.spacingMD) {
                                        ForEach(truth.attachments) { attachment in
                                            AttachmentPreview(attachment: attachment)
                                        }
                                    }
                                    .padding(.horizontal, AppTheme.spacingLG)
                                }
                            }
                        }
                        .padding(AppTheme.spacingLG)
                        .background(
                            isMe ? AppTheme.mainGradient : AppTheme.cardGradient
                        )
                        .cornerRadius(AppTheme.radiusLG)
                        .shadow(color: AppTheme.shadowMD, radius: 4, x: 0, y: 2)
                        
                        // Timestamp
                        Text("Submitted \(truth.submittedAt.formatted(date: .omitted, time: .shortened))")
                            .font(AppTheme.caption2())
                            .foregroundColor(AppTheme.textTertiary)
                    }
                } else {
                    VStack(alignment: isMe ? .trailing : .leading, spacing: AppTheme.spacingMD) {
                        Text("Waiting for truth submission...")
                            .font(AppTheme.body())
                            .foregroundColor(AppTheme.textTertiary)
                            .italic()
                            .padding(AppTheme.spacingLG)
                            .background(AppTheme.cardGradient)
                            .overlay(
                                RoundedRectangle(cornerRadius: AppTheme.radiusLG)
                                    .stroke(AppTheme.textTertiary.opacity(0.3), style: StrokeStyle(lineWidth: 1, dash: [5]))
                            )
                            .cornerRadius(AppTheme.radiusLG)
                    }
                }
            }
            .frame(maxWidth: 300, alignment: isMe ? .trailing : .leading)
            
            if !isMe { Spacer() }
        }
        .padding(.horizontal, AppTheme.spacingLG)
        .scaleEffect(animateIn ? 1.0 : 0.95)
        .opacity(animateIn ? 1.0 : 0.0)
        .onAppear {
            withAnimation(.easeOut(duration: 0.6).delay(0.1)) {
                animateIn = true
            }
        }
    }
}
