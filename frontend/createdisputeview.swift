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
    @EnvironmentObject var purchaseService: InAppPurchaseService

    @State private var title = ""
    @State private var description = ""
    @State private var error: String?
    @State private var createdDispute: Dispute?
    @State private var isProcessingPayment = false

    @State private var showTermsOfService = false
    @State private var animateElements = false
    @State private var createContract = false
    @State private var requestSignature = false
    @State private var useEscrow = false
    @State private var showSignatureView = false
    @State private var creatorSignature: UIImage?
    
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
                        
                        // Footer
                        Text("Decentralized Technology Solutions 2025")
                            .font(.system(size: 12))
                            .foregroundColor(AppTheme.textSecondary.opacity(0.7))
                            .padding(.top, AppTheme.spacingXL)
                        
                        Spacer(minLength: AppTheme.spacingXXL)
                    }
                    .padding(.horizontal, AppTheme.spacingLG)
                    .padding(.top, AppTheme.spacingLG)
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(item: $createdDispute, onDismiss: { dismiss() }) { dispute in
            ShareDisputeView(dispute: dispute)
        }
        .sheet(isPresented: $showTermsOfService) {
            TermsOfServiceView()
        }
        .sheet(isPresented: $showSignatureView) {
            SignatureView(
                title: "Sign Your Contract",
                subtitle: "Please provide your digital signature to make this contract legally binding and enforceable in court."
            ) { signature in
                creatorSignature = signature
                handleCreatorSignature(signature: signature)
            }
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
            // Free service banner
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(AppTheme.success)
                
                VStack(alignment: .leading, spacing: AppTheme.spacingSM) {
                    Text("✅ Always FREE!")
                        .font(AppTheme.headline())
                        .foregroundColor(AppTheme.success)
                        .fontWeight(.bold)
                    
                    Text("Create disputes at no cost during beta testing!")
                        .font(AppTheme.caption())
                        .foregroundColor(AppTheme.textSecondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: AppTheme.spacingSM) {
                    Text("$0.00")
                        .font(AppTheme.title())
                        .foregroundColor(AppTheme.success)
                        .fontWeight(.bold)
                    
                    Text("per party")
                        .font(AppTheme.caption())
                        .foregroundColor(AppTheme.textSecondary)
                }
            }
            .padding(AppTheme.spacingLG)
            .background(AppTheme.success.opacity(0.1))
            .cornerRadius(AppTheme.radiusLG)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.radiusLG)
                    .stroke(AppTheme.success.opacity(0.3), lineWidth: 1)
            )
            
            // 2x2 grid layout for better iPhone display
            VStack(spacing: AppTheme.spacingSM) {
                HStack(spacing: AppTheme.spacingSM) {
                    FeatureBadge(icon: "checkmark.circle.fill", text: "Instant sharing")
                    FeatureBadge(icon: "shield.checkered", text: "Secure payment")
                }
                HStack(spacing: AppTheme.spacingSM) {
                    FeatureBadge(icon: "brain.head.profile", text: "AI mediation")
                    FeatureBadge(icon: "clock.fill", text: "Fast resolution")
                }
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
                    
                    // Additional Options
                    VStack(alignment: .leading, spacing: AppTheme.spacingMD) {
                        Text("Additional Options")
                            .font(AppTheme.caption())
                            .foregroundColor(AppTheme.textSecondary)
                            .fontWeight(.medium)
                        
                        VStack(spacing: AppTheme.spacingSM) {
                            HStack {
                                Button(action: { createContract.toggle() }) {
                                    Image(systemName: createContract ? "checkmark.square.fill" : "square")
                                        .font(.title2)
                                        .foregroundColor(createContract ? AppTheme.success : AppTheme.textSecondary)
                                }
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Create Contract")
                                        .font(AppTheme.caption())
                                        .foregroundColor(AppTheme.textPrimary)
                                    
                                    Text("AI will create a fair contract for this dispute")
                                        .font(.system(size: 12))
                                        .foregroundColor(AppTheme.textSecondary)
                                }
                                
                                Spacer()
                            }
                            
                            HStack {
                                Button(action: { requestSignature.toggle() }) {
                                    Image(systemName: requestSignature ? "checkmark.square.fill" : "square")
                                        .font(.title2)
                                        .foregroundColor(requestSignature ? AppTheme.success : AppTheme.textSecondary)
                                }
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Request Signatures")
                                        .font(AppTheme.caption())
                                        .foregroundColor(AppTheme.textPrimary)
                                    
                                    Text("Contract will be legally binding in court")
                                        .font(.system(size: 12))
                                        .foregroundColor(AppTheme.textSecondary)
                                }
                                
                                Spacer()
                            }
                            
                            HStack {
                                Button(action: { /* Coming soon */ }) {
                                    Image(systemName: "square")
                                        .font(.title2)
                                        .foregroundColor(AppTheme.textSecondary.opacity(0.5))
                                }
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Escrow Service")
                                        .font(AppTheme.caption())
                                        .foregroundColor(AppTheme.textSecondary.opacity(0.5))
                                    
                                    Text("Coming soon - AI mediated money holding")
                                        .font(.system(size: 12))
                                        .foregroundColor(AppTheme.textSecondary.opacity(0.5))
                                }
                                
                                Spacer()
                            }
                        }
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
                    
                    Text("Create Dispute")
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
            .disabled(title.isEmpty || description.isEmpty)
            .opacity((title.isEmpty || description.isEmpty) ? 0.6 : 1.0)
            
            HStack {
                Image(systemName: "shield.checkered")
                    .foregroundColor(AppTheme.success)
                
                Text("Free dispute resolution service")
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
        
        let dispute = disputeService.createDispute(
            title: title, 
            description: description, 
            user: user,
            requiresContract: createContract,
            requiresSignature: requestSignature,
            requiresEscrow: useEscrow
        )
        
        // If signature is required, show signature view, otherwise smooth transition to home
        if requestSignature {
            showSignatureView = true
            createdDispute = dispute
        } else {
            createdDispute = dispute
        }
    }
    
    private func handleCreatorSignature(signature: UIImage) {
        guard let user = authService.currentUser,
              let dispute = createdDispute,
              let signatureData = signature.jpegData(compressionQuality: 0.8) else {
            return
        }
        
        let digitalSignature = DigitalSignature(
            userId: user.id,
            signatureImageData: signatureData,
            userName: user.profile.displayName
        )
        
        disputeService.addCreatorSignature(to: dispute, signature: digitalSignature)
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
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, AppTheme.spacingSM)
        .padding(.vertical, AppTheme.spacingSM)
        .background(AppTheme.success.opacity(0.1))
        .cornerRadius(AppTheme.radiusSM)
    }
}