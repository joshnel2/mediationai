//
//  ContractView.swift
//  MediationAI
//
//  Created by AI Assistant on 7/14/25.
//

import SwiftUI

struct ContractView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                AppTheme.backgroundGradient
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: AppTheme.spacingXL) {
                        // Header
                        headerSection
                        
                        // How it works
                        howItWorksSection
                        
                        // Features
                        featuresSection
                        
                        // Legal standing
                        legalStandingSection
                        
                        // Footer
                        footerSection
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, AppTheme.spacingLG)
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: AppTheme.spacingLG) {
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.title2)
                        .foregroundColor(AppTheme.textSecondary)
                        .frame(width: 44, height: 44)
                        .background(AppTheme.glassPrimary)
                        .cornerRadius(AppTheme.radiusLG)
                }
                
                Spacer()
                
                Text("AI Contracts")
                    .font(AppTheme.titleFont())
                    .foregroundColor(AppTheme.textPrimary)
                    .fontWeight(.bold)
                
                Spacer()
                
                // Invisible spacer for balance
                Rectangle()
                    .frame(width: 44, height: 44)
                    .opacity(0)
            }
            
            VStack(spacing: AppTheme.spacingMD) {
                Image(systemName: "doc.text.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(AppTheme.mainGradient)
                    .shadow(color: AppTheme.primary.opacity(0.3), radius: 8, x: 0, y: 4)
                
                Text("Fair & Legal Contracts")
                    .font(AppTheme.title2())
                    .foregroundColor(AppTheme.textPrimary)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                
                Text("AI creates contracts that hold up in court and ensure fairness for all parties")
                    .font(AppTheme.body())
                    .foregroundColor(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppTheme.spacingMD)
            }
        }
        .padding(.top, AppTheme.spacingXL)
    }
    
    private var howItWorksSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingLG) {
            Text("How It Works")
                .font(AppTheme.headline())
                .foregroundColor(AppTheme.textPrimary)
                .fontWeight(.bold)
            
            VStack(spacing: AppTheme.spacingMD) {
                StepCard(
                    number: "1",
                    title: "Create Dispute",
                    description: "Check 'Create Contract' when creating your dispute",
                    icon: "plus.circle.fill"
                )
                
                StepCard(
                    number: "2",
                    title: "AI Analysis",
                    description: "Our AI analyzes the dispute and creates a fair contract framework",
                    icon: "brain.head.profile"
                )
                
                StepCard(
                    number: "3",
                    title: "Review & Sign",
                    description: "Both parties review the contract and sign digitally if desired",
                    icon: "signature"
                )
                
                StepCard(
                    number: "4",
                    title: "Legal Binding",
                    description: "Signed contracts are legally enforceable in court",
                    icon: "scale.3d"
                )
            }
        }
        .padding(AppTheme.spacingLG)
        .background(AppTheme.glassPrimary)
        .cornerRadius(AppTheme.radiusLG)
    }
    
    private var featuresSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingLG) {
            Text("Contract Features")
                .font(AppTheme.headline())
                .foregroundColor(AppTheme.textPrimary)
                .fontWeight(.bold)
            
            VStack(spacing: AppTheme.spacingMD) {
                FeatureRow(
                    icon: "checkmark.shield.fill",
                    title: "Fair Terms",
                    description: "AI ensures balanced terms for all parties"
                )
                
                FeatureRow(
                    icon: "doc.text.magnifyingglass",
                    title: "Legal Language",
                    description: "Proper legal terminology and structure"
                )
                
                FeatureRow(
                    icon: "signature",
                    title: "Digital Signatures",
                    description: "Secure electronic signing process"
                )
                
                FeatureRow(
                    icon: "lock.shield",
                    title: "Secure Storage",
                    description: "Encrypted contract storage and access"
                )
            }
        }
        .padding(AppTheme.spacingLG)
        .background(AppTheme.glassPrimary)
        .cornerRadius(AppTheme.radiusLG)
    }
    
    private var legalStandingSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingLG) {
            Text("Legal Standing")
                .font(AppTheme.headline())
                .foregroundColor(AppTheme.textPrimary)
                .fontWeight(.bold)
            
            VStack(alignment: .leading, spacing: AppTheme.spacingMD) {
                HStack(alignment: .top, spacing: AppTheme.spacingMD) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(AppTheme.success)
                        .font(.title2)
                    
                    VStack(alignment: .leading, spacing: AppTheme.spacingSM) {
                        Text("Court Enforceable")
                            .font(AppTheme.body())
                            .foregroundColor(AppTheme.textPrimary)
                            .fontWeight(.semibold)
                        
                        Text("Contracts created by our AI follow legal standards and are enforceable in court when signed by both parties.")
                            .font(AppTheme.caption())
                            .foregroundColor(AppTheme.textSecondary)
                    }
                }
                
                HStack(alignment: .top, spacing: AppTheme.spacingMD) {
                    Image(systemName: "shield.checkered")
                        .foregroundColor(AppTheme.info)
                        .font(.title2)
                    
                    VStack(alignment: .leading, spacing: AppTheme.spacingSM) {
                        Text("Legally Compliant")
                            .font(AppTheme.body())
                            .foregroundColor(AppTheme.textPrimary)
                            .fontWeight(.semibold)
                        
                        Text("All contracts comply with applicable laws and regulations for dispute resolution agreements.")
                            .font(AppTheme.caption())
                            .foregroundColor(AppTheme.textSecondary)
                    }
                }
                
                HStack(alignment: .top, spacing: AppTheme.spacingMD) {
                    Image(systemName: "balance.scale")
                        .foregroundColor(AppTheme.accent)
                        .font(.title2)
                    
                    VStack(alignment: .leading, spacing: AppTheme.spacingSM) {
                        Text("Fair & Balanced")
                            .font(AppTheme.body())
                            .foregroundColor(AppTheme.textPrimary)
                            .fontWeight(.semibold)
                        
                        Text("AI ensures contracts are fair to both parties without favoring one side over another.")
                            .font(AppTheme.caption())
                            .foregroundColor(AppTheme.textSecondary)
                    }
                }
            }
        }
        .padding(AppTheme.spacingLG)
        .background(AppTheme.glassPrimary)
        .cornerRadius(AppTheme.radiusLG)
    }
    
    private var footerSection: some View {
        VStack(spacing: AppTheme.spacingMD) {
            Text("Ready to Create a Contract?")
                .font(AppTheme.headline())
                .foregroundColor(AppTheme.textPrimary)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Text("Simply check 'Create Contract' when creating your next dispute")
                .font(AppTheme.body())
                .foregroundColor(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
            
            Text("Decentralized Technology Solutions 2025")
                .font(.system(size: 12))
                .foregroundColor(AppTheme.textSecondary.opacity(0.7))
                .padding(.top, AppTheme.spacingLG)
        }
        .padding(.horizontal, AppTheme.spacingLG)
    }
}

struct StepCard: View {
    let number: String
    let title: String
    let description: String
    let icon: String
    
    var body: some View {
        HStack(spacing: AppTheme.spacingMD) {
            ZStack {
                Circle()
                    .fill(AppTheme.mainGradient)
                    .frame(width: 40, height: 40)
                
                Text(number)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: AppTheme.spacingSM) {
                Text(title)
                    .font(AppTheme.body())
                    .foregroundColor(AppTheme.textPrimary)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(AppTheme.caption())
                    .foregroundColor(AppTheme.textSecondary)
            }
            
            Spacer()
            
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(AppTheme.primary)
        }
        .padding(AppTheme.spacingMD)
        .background(AppTheme.card)
        .cornerRadius(AppTheme.radiusMD)
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: AppTheme.spacingMD) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(AppTheme.success)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: AppTheme.spacingSM) {
                Text(title)
                    .font(AppTheme.body())
                    .foregroundColor(AppTheme.textPrimary)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(AppTheme.caption())
                    .foregroundColor(AppTheme.textSecondary)
            }
            
            Spacer()
        }
    }
}

#Preview {
    ContractView()
}