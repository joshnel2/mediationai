//
//  CreateDisputeView.swift
//  MediationAI
//
//  Created by Linda Alster on 7/14/25.
//

import SwiftUI

struct CreateDisputeView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authService: MockAuthService
    @EnvironmentObject var disputeService: MockDisputeService
    @StateObject private var purchaseService = InAppPurchaseService()
    @State private var title = ""
    @State private var description = ""
    @State private var error: String?
    @State private var createdDispute: Dispute?
    @State private var isProcessingPayment = false
    @State private var showTermsOfService = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Text("Create a Dispute")
                    .font(AppTheme.titleFont())
                    .foregroundColor(AppTheme.primary)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("💰 Cost: $1.00")
                        .font(.headline)
                        .foregroundColor(AppTheme.primary)
                    Text("One-time payment to create and share your dispute")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding()
                .background(AppTheme.card)
                .cornerRadius(12)
                .shadow(radius: 2)
                
                TextField("Dispute Title", text: $title)
                    .padding()
                    .background(AppTheme.card)
                    .cornerRadius(12)
                    .shadow(radius: 2)
                
                TextField("Describe the situation...", text: $description, axis: .vertical)
                    .padding()
                    .background(AppTheme.card)
                    .cornerRadius(12)
                    .shadow(radius: 2)
                    .frame(minHeight: 100, maxHeight: 150)
                
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
                
                Button(action: handleCreateWithPayment) {
                    HStack {
                        if isProcessingPayment || purchaseService.isLoading {
                            ProgressView()
                                .scaleEffect(0.8)
                                .foregroundColor(.white)
                        }
                        Text(isProcessingPayment ? "Processing Payment..." : "Pay $1 & Create Dispute")
                            .font(AppTheme.buttonFont())
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppTheme.mainGradient)
                    .foregroundColor(.white)
                    .cornerRadius(16)
                }
                .disabled(isProcessingPayment || purchaseService.isLoading)
                .padding(.top)
                
                // Payment compliance notice
                VStack(spacing: 8) {
                    Text("Payment processed securely through Apple")
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
            .sheet(item: $createdDispute) { dispute in
                ShareDisputeView(dispute: dispute)
            }
            .sheet(isPresented: $showTermsOfService) {
                TermsOfServiceView()
            }
        }
    }
    
    func handleCreateWithPayment() {
        error = nil
        guard let user = authService.currentUser else { return }
        if title.isEmpty || description.isEmpty {
            error = "Please fill in all fields."
            return
        }
        
        isProcessingPayment = true
        
        Task {
            // Use mock purchase for development
            let paymentSuccess = await purchaseService.mockPurchase()
            
            await MainActor.run {
                isProcessingPayment = false
                
                if paymentSuccess {
                    let dispute = disputeService.createDispute(title: title, description: description, user: user)
                    createdDispute = dispute
                } else {
                    error = "Payment failed. Please try again."
                }
            }
        }
    }
}
