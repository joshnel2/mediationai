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
    @State private var isResolving = false
    @State private var showResolution = false
    @State private var resolutionText: String?
    @State private var showAIProcessing = false
    
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
        NavigationView {
            VStack(spacing: 0) {
                // Status banner
                if waitingForOtherParty {
                    VStack(spacing: 8) {
                        HStack {
                            Image(systemName: "clock")
                                .foregroundColor(.orange)
                            Text("Waiting for other party to join")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(8)
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                }
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Dispute details
                        VStack(alignment: .leading, spacing: 8) {
                            Text(dispute.title)
                                .font(AppTheme.titleFont())
                                .foregroundColor(AppTheme.primary)
                            
                            Text(dispute.description)
                                .font(AppTheme.bodyFont())
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.leading)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(AppTheme.card)
                        .cornerRadius(16)
                        .shadow(radius: 2)
                        .padding(.horizontal)
                        
                        // Party A Truth
                        if let partyA = dispute.partyA {
                            TruthBubble(
                                user: partyA,
                                truth: dispute.truths.first(where: { $0.userId == partyA.id }),
                                isMe: partyA.id == authService.currentUser?.id
                            )
                        }
                        
                        // Party B Truth
                        if let partyB = dispute.partyB {
                            TruthBubble(
                                user: partyB,
                                truth: dispute.truths.first(where: { $0.userId == partyB.id }),
                                isMe: partyB.id == authService.currentUser?.id
                            )
                        }
                        
                        // AI Processing indicator
                        if showAIProcessing {
                            VStack(spacing: 12) {
                                ProgressView()
                                    .scaleEffect(1.2)
                                Text("🤖 Grok AI is analyzing both submissions...")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                            }
                            .padding()
                            .background(AppTheme.card)
                            .cornerRadius(16)
                            .shadow(radius: 2)
                            .padding(.horizontal)
                        }
                        
                        // Resolution
                        if dispute.isResolved, let resolution = dispute.resolution {
                            ResolutionCardView(resolution: resolution)
                        }
                    }
                    .padding(.vertical)
                }
                .background(AppTheme.background)
                
                // Input area for submitting truth
                if canSubmitTruth {
                    VStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("📝 Submit Your Truth")
                                .font(.headline)
                                .foregroundColor(AppTheme.primary)
                            
                            Text("Share your side of the story with evidence. Once both parties submit, Grok AI will provide a resolution.")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        TextField("Describe your truth...", text: $message, axis: .vertical)
                            .padding()
                            .background(AppTheme.card)
                            .cornerRadius(12)
                            .shadow(radius: 2)
                            .frame(minHeight: 60)
                        
                        HStack {
                            Button(action: { isPickerPresented = true }) {
                                Label("Attach", systemImage: "paperclip")
                                    .font(.caption)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(AppTheme.secondary.opacity(0.2))
                                    .cornerRadius(8)
                            }
                            .sheet(isPresented: $isPickerPresented) {
                                AttachmentPicker(attachments: $attachments)
                            }
                            
                            if !attachments.isEmpty {
                                Text("\(attachments.count) file(s)")
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            Button(action: handleSend) {
                                Text("Submit Truth")
                                    .font(AppTheme.buttonFont())
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 10)
                                    .background(AppTheme.mainGradient)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                            }
                        }
                        
                        if let error = error {
                            Text(error)
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                    }
                    .padding()
                    .background(AppTheme.background)
                }
                
                // Waiting message if truth already submitted
                if !dispute.isResolved && myTruth != nil && otherTruth == nil {
                    VStack(spacing: 8) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("Your truth has been submitted")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                        
                        Text("Waiting for the other party to submit their truth...")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(AppTheme.background)
                }
            }
            .navigationTitle(dispute.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
            .background(AppTheme.background.ignoresSafeArea())
            .sheet(isPresented: $showResolution) {
                if let resolutionText = resolutionText {
                    ResolutionView(resolution: resolutionText)
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
    }
    
    func handleSend() {
        error = nil
        guard let user = authService.currentUser else { return }
        if message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            error = "Please enter your truth."
            return
        }
        
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
