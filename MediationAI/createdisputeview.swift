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
    @State private var animateElements = false
    
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
                    VStack(spacing: AppTheme.spacingXL) {
                        // Main title and intro
                        titleSection
                        
                        // Pricing card
                        pricingCard
                        
                        // Form section
                        formSection
                        
                        // Payment button
                        paymentSection
                        
                        // Compliance notice
                        complianceSection
                        
                        Spacer(minLength: AppTheme.spacingXXL)
                    }
                    .padding(.horizontal, AppTheme.spacingLG)
                    .padding(.top, AppTheme.spacingLG)
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(item: $createdDispute) { dispute in
            ShareDisputeView(dispute: dispute)
        }
        .sheet(isPresented: $showTermsOfService) {
            TermsOfServiceView()
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8).delay(0.2)) {
                animateElements = true
            }
        }
    }
    
    private var headerSection: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "xmark")
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundColor(AppTheme.textPrimary)
                    .frame(width: 32, height: 32)
                    .background(AppTheme.glassPrimary)
                    .cornerRadius(AppTheme.radiusSM)
            }
            
            Spacer()
            
            Text("Create Dispute")
                .font(AppTheme.title3())
                .foregroundColor(AppTheme.textPrimary)
                .fontWeight(.semibold)
            
            Spacer()
            
            // Placeholder for balance
            Color.clear
                .frame(width: 32, height: 32)
        }
        .padding(.horizontal, AppTheme.spacingLG)
        .padding(.top, AppTheme.spacingSM)
    }
    
    private var titleSection: some View {
        VStack(spacing: AppTheme.spacingLG) {
            Image(systemName: "plus.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(AppTheme.mainGradient)
                .scaleEffect(animateElements ? 1.0 : 0.8)
                .opacity(animateElements ? 1.0 : 0.0)
                .animation(.easeOut(duration: 0.8), value: animateElements)
            
            VStack(spacing: AppTheme.spacingMD) {
                Text("Start a New Dispute")
                    .font(AppTheme.title())
                    .foregroundColor(AppTheme.textPrimary)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .opacity(animateElements ? 1.0 : 0.0)
                    .animation(.easeOut(duration: 0.8).delay(0.1), value: animateElements)
                
                Text("Get AI-powered mediation for your conflict. Fair, fast, and affordable resolution in minutes.")
                    .font(AppTheme.body())
                    .foregroundColor(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .opacity(animateElements ? 1.0 : 0.0)
                    .animation(.easeOut(duration: 0.8).delay(0.2), value: animateElements)
            }
        }
    }
    
    private var pricingCard: some View {
        VStack(spacing: AppTheme.spacingLG) {
            HStack {
                VStack(alignment: .leading, spacing: AppTheme.spacingSM) {
                    Text("💰 Creation Fee")
                        .font(AppTheme.headline())
                        .foregroundColor(AppTheme.textPrimary)
                        .fontWeight(.semibold)
                    
                    Text("One-time payment to create and share your dispute")
                        .font(AppTheme.caption())
                        .foregroundColor(AppTheme.textSecondary)
                }
                
                Spacer()
                
                Text("$1.00")
                    .font(AppTheme.title())
                    .foregroundColor(AppTheme.success)
                    .fontWeight(.bold)
            }
            
            HStack(spacing: AppTheme.spacingMD) {
                FeatureBadge(icon: "checkmark.circle.fill", text: "Instant sharing")
                FeatureBadge(icon: "shield.checkered", text: "Secure payment")
                FeatureBadge(icon: "brain.head.profile", text: "AI mediation")
            }
        }
        .padding(AppTheme.spacingLG)
        .glassCard()
        .scaleEffect(animateElements ? 1.0 : 0.95)
        .opacity(animateElements ? 1.0 : 0.0)
        .animation(.easeOut(duration: 0.6).delay(0.3), value: animateElements)
    }
    
    private var formSection: some View {
        VStack(spacing: AppTheme.spacingLG) {
            VStack(alignment: .leading, spacing: AppTheme.spacingMD) {
                Text("Dispute Details")
                    .font(AppTheme.headline())
                    .foregroundColor(AppTheme.textPrimary)
                    .fontWeight(.semibold)
                
                VStack(spacing: AppTheme.spacingLG) {
                    VStack(alignment: .leading, spacing: AppTheme.spacingSM) {
                        Text("Title")
                            .font(AppTheme.caption())
                            .foregroundColor(AppTheme.textSecondary)
                            .fontWeight(.medium)
                        
                        TextField("Enter a clear, concise title", text: $title)
                            .modernTextField()
                    }
                    
                    VStack(alignment: .leading, spacing: AppTheme.spacingSM) {
                        Text("Description")
                            .font(AppTheme.caption())
                            .foregroundColor(AppTheme.textSecondary)
                            .fontWeight(.medium)
                        
                        TextField("Describe the situation in detail...", text: $description, axis: .vertical)
                            .modernTextField()
                            .frame(minHeight: 100)
                    }
                }
            }
            
            if let error = error {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(AppTheme.error)
                    
                    Text(error)
                        .font(AppTheme.caption())
                        .foregroundColor(AppTheme.error)
                    
                    Spacer()
                }
                .padding(AppTheme.spacingMD)
                .background(AppTheme.error.opacity(0.1))
                .cornerRadius(AppTheme.radiusSM)
            }
            
            if let purchaseError = purchaseService.purchaseError {
                HStack {
                    Image(systemName: "creditcard.trianglebadge.exclamationmark")
                        .foregroundColor(AppTheme.error)
                    
                    Text(purchaseError)
                        .font(AppTheme.caption())
                        .foregroundColor(AppTheme.error)
                    
                    Spacer()
                }
                .padding(AppTheme.spacingMD)
                .background(AppTheme.error.opacity(0.1))
                .cornerRadius(AppTheme.radiusSM)
            }
        }
        .padding(AppTheme.spacingLG)
        .glassCard()
        .scaleEffect(animateElements ? 1.0 : 0.95)
        .opacity(animateElements ? 1.0 : 0.0)
        .animation(.easeOut(duration: 0.6).delay(0.4), value: animateElements)
    }
    
    private var paymentSection: some View {
        VStack(spacing: AppTheme.spacingMD) {
            Button(action: handleCreateWithPayment) {
                HStack {
                    if isProcessingPayment || purchaseService.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.9)
                    } else {
                        Image(systemName: "creditcard.fill")
                            .font(.title3)
                    }
                    
                    Text(isProcessingPayment ? "Processing Payment..." : "Pay $1 & Create Dispute")
                        .font(AppTheme.headline())
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppTheme.spacingLG)
                .foregroundColor(.white)
                .background(AppTheme.mainGradient)
                .cornerRadius(AppTheme.radiusLG)
                .shadow(color: AppTheme.primary.opacity(0.3), radius: 8, x: 0, y: 4)
            }
            .disabled(isProcessingPayment || purchaseService.isLoading || title.isEmpty || description.isEmpty)
            .opacity((isProcessingPayment || purchaseService.isLoading || title.isEmpty || description.isEmpty) ? 0.6 : 1.0)
            
            HStack {
                Image(systemName: "shield.checkered")
                    .foregroundColor(AppTheme.success)
                
                Text("Payment processed securely through Apple")
                    .font(AppTheme.caption2())
                    .foregroundColor(AppTheme.textTertiary)
                
                Spacer()
            }
        }
        .scaleEffect(animateElements ? 1.0 : 0.95)
        .opacity(animateElements ? 1.0 : 0.0)
        .animation(.easeOut(duration: 0.6).delay(0.5), value: animateElements)
    }
    
    private var complianceSection: some View {
        VStack(spacing: AppTheme.spacingMD) {
            HStack {
                Text("By proceeding, you agree to our")
                    .font(AppTheme.caption2())
                    .foregroundColor(AppTheme.textTertiary)
                
                Button("Terms of Service") {
                    showTermsOfService = true
                }
                .font(AppTheme.caption2())
                .foregroundColor(AppTheme.primary)
                
                Spacer()
            }
        }
        .opacity(animateElements ? 1.0 : 0.0)
        .animation(.easeOut(duration: 0.6).delay(0.6), value: animateElements)
    }
    
    private func handleCreateWithPayment() {
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

struct FeatureBadge: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: AppTheme.spacingSM) {
            Image(systemName: icon)
                .font(.caption2)
                .foregroundColor(AppTheme.success)
            
            Text(text)
                .font(AppTheme.caption2())
                .foregroundColor(AppTheme.textSecondary)
        }
        .padding(.horizontal, AppTheme.spacingMD)
        .padding(.vertical, AppTheme.spacingSM)
        .background(AppTheme.success.opacity(0.1))
        .cornerRadius(AppTheme.radiusSM)
    }
}
