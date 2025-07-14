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
    @StateObject private var purchaseService = InAppPurchaseService()
    @State private var linkOrCode = ""
    @State private var error: String?
    @State private var joinedDispute: Dispute?
    @State private var isProcessingPayment = false
    @State private var selectedInputType: InputType = .link
    
    enum InputType: String, CaseIterable {
        case link = "Link"
        case code = "Code"
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Text("Join a Dispute")
                    .font(AppTheme.titleFont())
                    .foregroundColor(AppTheme.primary)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("💰 Cost: $1.00")
                        .font(.headline)
                        .foregroundColor(AppTheme.primary)
                    Text("One-time payment to join and participate in the dispute")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding()
                .background(AppTheme.card)
                .cornerRadius(12)
                .shadow(radius: 2)
                
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
                
                if let purchaseError = purchaseService.purchaseError {
                    Text(purchaseError)
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
                Button(action: handleJoinWithPayment) {
                    HStack {
                        if isProcessingPayment || purchaseService.isLoading {
                            ProgressView()
                                .scaleEffect(0.8)
                                .foregroundColor(.white)
                        }
                        Text(isProcessingPayment ? "Processing Payment..." : "Pay $1 & Join Dispute")
                            .font(AppTheme.buttonFont())
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppTheme.mainGradient)
                    .foregroundColor(.white)
                    .cornerRadius(16)
                }
                .disabled(isProcessingPayment || purchaseService.isLoading)
                
                Spacer()
            }
            .padding()
            .background(AppTheme.background.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
    
    func handleJoinWithPayment() {
        error = nil
        guard let user = authService.currentUser else { return }
        if linkOrCode.isEmpty {
            error = "Please enter a \(selectedInputType.rawValue.lowercased())."
            return
        }
        
        isProcessingPayment = true
        
        Task {
            // Use mock purchase for development
            let paymentSuccess = await purchaseService.mockPurchase()
            
            await MainActor.run {
                isProcessingPayment = false
                
                if paymentSuccess {
                    var dispute: Dispute?
                    
                    if selectedInputType == .link {
                        dispute = disputeService.joinDispute(shareLink: linkOrCode, user: user)
                    } else {
                        dispute = disputeService.joinDisputeWithCode(shareCode: linkOrCode.uppercased(), user: user)
                    }
                    
                    if let joinedDispute = dispute {
                        self.joinedDispute = joinedDispute
                        dismiss()
                    } else {
                        error = "Invalid or expired \(selectedInputType.rawValue.lowercased())."
                    }
                } else {
                    error = "Payment failed. Please try again."
                }
            }
        }
    }
}
