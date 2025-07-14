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
    
    let dispute: Dispute
    
    var myTruth: Truth? {
        dispute.truths.first(where: { $0.userId == authService.currentUser?.id })
    }
    var otherTruth: Truth? {
        dispute.truths.first(where: { $0.userId != authService.currentUser?.id })
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 24) {
                        // Party A
                        if let partyA = dispute.partyA {
                            TruthBubble(
                                user: partyA,
                                truth: dispute.truths.first(where: { $0.userId == partyA.id }),
                                isMe: partyA.id == authService.currentUser?.id
                            )
                        }
                        // Party B
                        if let partyB = dispute.partyB {
                            TruthBubble(
                                user: partyB,
                                truth: dispute.truths.first(where: { $0.userId == partyB.id }),
                                isMe: partyB.id == authService.currentUser?.id
                            )
                        }
                        if dispute.isResolved, let resolution = dispute.resolution {
                            ResolutionCardView(resolution: resolution)
                        }
                    }
                    .padding()
                }
                .background(AppTheme.background)
                
                if !dispute.isResolved && myTruth == nil {
                    VStack(spacing: 8) {
                        TextField("Describe your truth...", text: $message, axis: .vertical)
                            .padding()
                            .background(AppTheme.card)
                            .cornerRadius(12)
                            .shadow(radius: 2)
                            .frame(minHeight: 60)
                        
                        HStack {
                            Button(action: { isPickerPresented = true }) {
                                Image(systemName: "paperclip")
                                    .font(.title2)
                                    .padding(8)
                                    .background(AppTheme.secondary.opacity(0.2))
                                    .clipShape(Circle())
                            }
                            .sheet(isPresented: $isPickerPresented) {
                                AttachmentPicker(attachments: $attachments)
                            }
                            
                            Spacer()
                            Button(action: handleSend) {
                                Text("Submit Truth")
                                    .font(AppTheme.buttonFont())
                                    .padding(.horizontal)
                                    .padding(.vertical, 8)
                                    .background(AppTheme.mainGradient)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                            }
                        }
                        .padding(.horizontal, 4)
                        
                        if let error = error {
                            Text(error)
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                    }
                    .padding()
                    .background(AppTheme.background)
                }
                
                if !dispute.isResolved && myTruth != nil && otherTruth != nil {
                    Button(action: handleResolve) {
                        if isResolving {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                                .frame(maxWidth: .infinity)
                                .padding()
                        } else {
                            Text("Resolve Dispute (AI)")
                                .font(AppTheme.buttonFont())
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(AppTheme.mainGradient)
                                .foregroundColor(.white)
                                .cornerRadius(16)
                        }
                    }
                    .padding()
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
            attachments: attachments
        )
        disputeService.addTruth(to: dispute, truth: truth)
        message = ""
        attachments = []
    }
    
    func handleResolve() {
        isResolving = true
        let grok = MockGrokAPI()
        grok.resolveDispute(truths: dispute.truths) { result in
            disputeService.resolveDispute(dispute, resolution: result)
            resolutionText = result
            isResolving = false
            showResolution = true
        }
    }
}
