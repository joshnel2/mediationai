//
//  JoinDisputeView.swift
//  MediationAI
//
//  Created by Linda Alster on 7/14/25.
//

import SwiftUI

struct JoinDisputeView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authService: MockAuthService
    @EnvironmentObject var disputeService: MockDisputeService

    @State private var linkOrCode = ""
    @State private var error: String?
    @State private var joinedDispute: Dispute?

    @State private var selectedInputType: InputType = .link
    @State private var showTermsOfService = false
    @State private var showSignatureView = false
    @State private var joinerSignature: UIImage?
    @State private var disputeToJoin: Dispute?
    
    enum InputType: String, CaseIterable {
        case link = "Link"
        case code = "Code"
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                AppTheme.backgroundGradient
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        Text("Join a Dispute")
                            .font(AppTheme.titleFont())
                            .foregroundColor(AppTheme.primary)
                        
                        VStack(alignment: .leading, spacing: AppTheme.spacingMD) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(AppTheme.success)
                                Text("✅ Always FREE")
                                    .font(AppTheme.headline())
                                    .foregroundColor(AppTheme.textPrimary)
                                    .fontWeight(.semibold)
                            }
                            Text("FREE to join - no payment required")
                                .font(AppTheme.caption())
                                .foregroundColor(AppTheme.textSecondary)
                        }
                        .modernCard()
                        
                        // Input type selector
                        Picker("Input Type", selection: $selectedInputType) {
                            ForEach(InputType.allCases, id: \.self) { type in
                                Text(type.rawValue).tag(type)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.horizontal)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            if selectedInputType == .link {
                                TextField("Paste dispute link here...", text: $linkOrCode)
                                    .padding()
                                    .background(AppTheme.card)
                                    .cornerRadius(12)
                                    .shadow(radius: 2)
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled()
                            } else {
                                TextField("Enter 6-digit code", text: $linkOrCode)
                                    .textCase(.uppercase)
                                    .padding()
                                    .background(AppTheme.card)
                                    .cornerRadius(12)
                                    .shadow(radius: 2)
                                    .textInputAutocapitalization(.characters)
                            }
                            
                            Text(selectedInputType == .link ? 
                                 "Example: https://mediationai.app/join/..." : 
                                 "6-character code provided by the dispute creator")
                                .font(.caption2)
                                .foregroundColor(.gray)
                                .padding(.horizontal, 4)
                        }
                        
                        if let error = error {
                            Text(error)
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                        

                        
                        Button(action: handleJoinWithPayment) {
                            HStack {
                                Image(systemName: "link.circle.fill")
                                    .font(.headline)
                                Text("Join Dispute")
                                    .font(AppTheme.headline())
                                    .fontWeight(.semibold)
                            }
                        }
                        .primaryButton()
                        
                        // Free service notice
                        VStack(spacing: 8) {
                            Text("Free dispute resolution service")
                                .font(.caption2)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                            
                            HStack(spacing: 4) {
                                Text("By proceeding, you agree to our")
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                                
                                Button("Terms of Service") {
                                    showTermsOfService = true
                                }
                                .font(.caption2)
                                .foregroundColor(AppTheme.primary)
                            }
                        }
                        .padding(.horizontal)
                
                        // Footer
                        Text("Decentralized Technology Solutions 2025")
                            .font(.system(size: 12))
                            .foregroundColor(AppTheme.textSecondary.opacity(0.7))
                            .padding(.top, AppTheme.spacingXL)
                        
                        Spacer()
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                // Configure navigation bar appearance
                let appearance = UINavigationBarAppearance()
                appearance.configureWithTransparentBackground()
                appearance.backgroundColor = UIColor.clear
                UINavigationBar.appearance().standardAppearance = appearance
                UINavigationBar.appearance().scrollEdgeAppearance = appearance
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .sheet(isPresented: $showTermsOfService) {
                TermsOfServiceView()
            }
            .sheet(isPresented: $showSignatureView) {
                SignatureView(
                    title: "Sign Contract Agreement",
                    subtitle: "Please provide your digital signature to join this dispute and make the contract legally binding."
                ) { signature in
                    joinerSignature = signature
                    handleJoinerSignature(signature: signature)
                }
            }
        }
    }
    
    private func handleJoinWithPayment() {
        error = nil
        guard var user = authService.currentUser else { return }
        if linkOrCode.isEmpty {
            error = "Please enter a \(selectedInputType.rawValue.lowercased())."
            return
        }
        
        // Beta version - all disputes are free, no payment processing needed
        Task {
            await MainActor.run {
                    var dispute: Dispute?
                    
                    if selectedInputType == .link {
                        dispute = disputeService.joinDispute(shareLink: linkOrCode, user: user)
                    } else {
                        dispute = disputeService.joinDisputeWithCode(shareCode: linkOrCode.uppercased(), user: user)
                    }
                    
                    if let joinedDispute = dispute {
                        // Re-enable auto-login so the user is signed in automatically next launch
                        authService.enableAutoLogin()

                        // Check if signature is required
                        if joinedDispute.requiresSignature {
                            disputeToJoin = joinedDispute
                            showSignatureView = true
                        } else {
                            self.joinedDispute = joinedDispute
                            dismiss()
                        }
                    } else {
                        error = "Invalid or expired \(selectedInputType.rawValue.lowercased())."
                    }
            }
        }
    }
    
    private func handleJoinerSignature(signature: UIImage) {
        guard let user = authService.currentUser,
              let dispute = disputeToJoin,
              let signatureData = signature.jpegData(compressionQuality: 0.8) else {
            return
        }
        
        let digitalSignature = DigitalSignature(
            userId: user.id,
            signatureImageData: signatureData,
            userName: user.profile.displayName
        )
        
        disputeService.addJoinerSignature(to: dispute, signature: digitalSignature)
        
        // Complete the join process
        joinedDispute = dispute
        dismiss()
    }
}
