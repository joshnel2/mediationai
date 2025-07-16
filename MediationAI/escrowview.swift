//
//  EscrowView.swift
//  MediationAI
//
//  Created by AI Assistant on 7/14/25.
//

import SwiftUI

struct EscrowView: View {
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
                        
                        // What is Escrow
                        whatIsEscrowSection
                        
                        // How it works
                        howItWorksSection
                        
                        // Benefits
                        benefitsSection
                        
                        // Use cases
                        useCasesSection
                        
                        // Security features
                        securitySection
                        
                        // Coming soon
                        comingSoonSection
                        
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
                
                Text("AI Escrow")
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
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(AppTheme.mainGradient)
                    .shadow(color: AppTheme.primary.opacity(0.3), radius: 8, x: 0, y: 4)
                
                Text("Secure AI-Mediated Escrow")
                    .font(AppTheme.title2())
                    .foregroundColor(AppTheme.textPrimary)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                
                Text("Revolutionary escrow service where AI holds and manages funds until dispute resolution is complete")
                    .font(AppTheme.body())
                    .foregroundColor(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppTheme.spacingMD)
                
                HStack {
                    Image(systemName: "clock.fill")
                        .font(.caption)
                        .foregroundColor(AppTheme.warning)
                    
                    Text("Coming Soon")
                        .font(AppTheme.caption())
                        .foregroundColor(AppTheme.warning)
                        .fontWeight(.bold)
                }
                .padding(.horizontal, AppTheme.spacingMD)
                .padding(.vertical, AppTheme.spacingSM)
                .background(AppTheme.warning.opacity(0.1))
                .cornerRadius(AppTheme.radiusSM)
            }
        }
        .padding(.top, AppTheme.spacingXL)
    }
    
    private var whatIsEscrowSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingLG) {
            Text("What is AI Escrow?")
                .font(AppTheme.headline())
                .foregroundColor(AppTheme.textPrimary)
                .fontWeight(.bold)
            
            VStack(alignment: .leading, spacing: AppTheme.spacingMD) {
                Text("AI Escrow is an innovative financial protection service that uses artificial intelligence to securely hold and manage funds during dispute resolution. Unlike traditional escrow services that rely on human intermediaries, our AI system provides:")
                    .font(AppTheme.body())
                    .foregroundColor(AppTheme.textSecondary)
                
                VStack(spacing: AppTheme.spacingMD) {
                    EscrowFeatureRow(
                        icon: "brain.head.profile",
                        title: "Intelligent Fund Management",
                        description: "AI monitors dispute progress and automatically releases funds based on resolution outcomes"
                    )
                    
                    EscrowFeatureRow(
                        icon: "shield.checkerboard",
                        title: "Unbiased Mediation",
                        description: "No human bias in fund management - decisions based purely on contract terms and AI analysis"
                    )
                    
                    EscrowFeatureRow(
                        icon: "clock.arrow.circlepath",
                        title: "Instant Processing",
                        description: "Automated fund release within minutes of dispute resolution, not days or weeks"
                    )
                    
                    EscrowFeatureRow(
                        icon: "dollarsign.circle",
                        title: "Lower Costs",
                        description: "Fraction of traditional escrow fees with transparent, AI-driven pricing"
                    )
                }
            }
        }
        .padding(AppTheme.spacingLG)
        .background(AppTheme.glassPrimary)
        .cornerRadius(AppTheme.radiusLG)
    }
    
    private var howItWorksSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingLG) {
            Text("How AI Escrow Works")
                .font(AppTheme.headline())
                .foregroundColor(AppTheme.textPrimary)
                .fontWeight(.bold)
            
            VStack(spacing: AppTheme.spacingMD) {
                EscrowStepCard(
                    number: "1",
                    title: "Fund Deposit",
                    description: "Parties deposit disputed funds into AI-secured escrow account with smart contract protection",
                    icon: "arrow.down.circle.fill"
                )
                
                EscrowStepCard(
                    number: "2",
                    title: "Dispute Creation",
                    description: "Dispute is created with escrow terms automatically integrated into the resolution contract",
                    icon: "doc.text.fill"
                )
                
                EscrowStepCard(
                    number: "3",
                    title: "AI Monitoring",
                    description: "AI continuously monitors dispute progress, evidence submission, and resolution timeline",
                    icon: "eye.fill"
                )
                
                EscrowStepCard(
                    number: "4",
                    title: "Resolution Analysis",
                    description: "AI analyzes final resolution and determines fund distribution based on contract terms",
                    icon: "scale.3d"
                )
                
                EscrowStepCard(
                    number: "5",
                    title: "Automatic Release",
                    description: "Funds automatically released to appropriate parties based on AI resolution decision",
                    icon: "checkmark.circle.fill"
                )
            }
        }
        .padding(AppTheme.spacingLG)
        .background(AppTheme.glassPrimary)
        .cornerRadius(AppTheme.radiusLG)
    }
    
    private var benefitsSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingLG) {
            Text("Benefits of AI Escrow")
                .font(AppTheme.headline())
                .foregroundColor(AppTheme.textPrimary)
                .fontWeight(.bold)
            
            VStack(spacing: AppTheme.spacingMD) {
                EscrowComparisonCard(
                    icon: "person.fill",
                    title: "Traditional Escrow",
                    subtitle: "Human intermediary",
                    vsTitle: "AI Escrow",
                    vsSubtitle: "Automated intelligence",
                    color: AppTheme.success
                )
                
                EscrowComparisonCard(
                    icon: "clock.fill",
                    title: "Days to Release",
                    subtitle: "Manual processing",
                    vsTitle: "Minutes to Release",
                    vsSubtitle: "Instant automation",
                    color: AppTheme.info
                )
                
                EscrowComparisonCard(
                    icon: "dollarsign.circle.fill",
                    title: "High Fees",
                    subtitle: "3-5% of amount",
                    vsTitle: "Low Fees",
                    vsSubtitle: "0.5-1% of amount",
                    color: AppTheme.warning
                )
                
                EscrowComparisonCard(
                    icon: "shield.fill",
                    title: "Risk of Bias",
                    subtitle: "Human judgment",
                    vsTitle: "Objective Analysis",
                    vsSubtitle: "AI-driven decisions",
                    color: AppTheme.accent
                )
            }
        }
        .padding(AppTheme.spacingLG)
        .background(AppTheme.glassPrimary)
        .cornerRadius(AppTheme.radiusLG)
    }
    
    private var useCasesSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingLG) {
            Text("Perfect Use Cases")
                .font(AppTheme.headline())
                .foregroundColor(AppTheme.textPrimary)
                .fontWeight(.bold)
            
            VStack(spacing: AppTheme.spacingMD) {
                UseCaseCard(
                    icon: "house.fill",
                    title: "Real Estate Transactions",
                    description: "Security deposits, down payments, and closing costs held safely until resolution",
                    examples: ["Security deposit disputes", "Property damage claims", "Lease violations", "Sale contingencies"]
                )
                
                UseCaseCard(
                    icon: "cart.fill",
                    title: "E-Commerce Disputes",
                    description: "Purchase amounts held until delivery confirmation or return processing",
                    examples: ["Product not received", "Item not as described", "Return/refund disputes", "Service quality issues"]
                )
                
                UseCaseCard(
                    icon: "briefcase.fill",
                    title: "Business Contracts",
                    description: "Contract payments held until milestone completion or service delivery",
                    examples: ["Freelance projects", "Service contracts", "Partnership agreements", "Vendor payments"]
                )
                
                UseCaseCard(
                    icon: "person.2.fill",
                    title: "Personal Agreements",
                    description: "Money held for personal transactions and shared expenses",
                    examples: ["Loan repayments", "Shared purchases", "Event expenses", "Group investments"]
                )
                
                UseCaseCard(
                    icon: "bitcoinsign.circle.fill",
                    title: "Crypto Smart Contract Mediation",
                    description: "AI-powered mediation for blockchain disputes and smart contract issues",
                    examples: ["DeFi protocol disputes", "NFT transaction issues", "Smart contract bugs", "Crypto payment disputes"]
                )
            }
        }
        .padding(AppTheme.spacingLG)
        .background(AppTheme.glassPrimary)
        .cornerRadius(AppTheme.radiusLG)
    }
    
    private var securitySection: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingLG) {
            Text("Enterprise-Grade Security")
                .font(AppTheme.headline())
                .foregroundColor(AppTheme.textPrimary)
                .fontWeight(.bold)
            
            VStack(spacing: AppTheme.spacingMD) {
                SecurityFeatureRow(
                    icon: "lock.shield.fill",
                    title: "Bank-Level Encryption",
                    description: "AES-256 encryption with multi-layer security protocols"
                )
                
                SecurityFeatureRow(
                    icon: "building.columns.fill",
                    title: "FDIC Insured Accounts",
                    description: "Funds held in FDIC-insured accounts for maximum protection"
                )
                
                SecurityFeatureRow(
                    icon: "checkmark.seal.fill",
                    title: "Smart Contract Auditing",
                    description: "Blockchain-based smart contracts audited by security experts"
                )
                
                SecurityFeatureRow(
                    icon: "eye.slash.fill",
                    title: "Zero-Knowledge Architecture",
                    description: "AI processes transactions without accessing sensitive data"
                )
                
                SecurityFeatureRow(
                    icon: "arrow.triangle.2.circlepath",
                    title: "Real-Time Monitoring",
                    description: "24/7 fraud detection and anomaly monitoring systems"
                )
            }
        }
        .padding(AppTheme.spacingLG)
        .background(AppTheme.glassPrimary)
        .cornerRadius(AppTheme.radiusLG)
    }
    
    private var comingSoonSection: some View {
        VStack(spacing: AppTheme.spacingLG) {
            VStack(spacing: AppTheme.spacingMD) {
                Image(systemName: "hourglass.tophalf.filled")
                    .font(.system(size: 40))
                    .foregroundColor(AppTheme.warning)
                
                Text("Coming Soon")
                    .font(AppTheme.title2())
                    .foregroundColor(AppTheme.textPrimary)
                    .fontWeight(.bold)
                
                Text("We're putting the finishing touches on our revolutionary AI Escrow service. Expected launch in Q2 2025.")
                    .font(AppTheme.body())
                    .foregroundColor(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppTheme.spacingMD)
            }
            
            VStack(spacing: AppTheme.spacingMD) {
                Text("Get Notified")
                    .font(AppTheme.headline())
                    .foregroundColor(AppTheme.textPrimary)
                    .fontWeight(.semibold)
                
                Text("Be the first to know when AI Escrow goes live. We'll send you an exclusive early access invitation.")
                    .font(AppTheme.body())
                    .foregroundColor(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppTheme.spacingMD)
                
                Button(action: { 
                    // Show success message or register for notifications
                    print("Notification signup tapped - feature to be implemented")
                }) {
                    HStack {
                        Image(systemName: "bell.fill")
                            .font(.headline)
                        Text("Notify Me When Available")
                            .font(AppTheme.headline())
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, AppTheme.spacingXL)
                    .padding(.vertical, AppTheme.spacingLG)
                    .background(AppTheme.mainGradient)
                    .cornerRadius(AppTheme.radiusLG)
                    .shadow(color: AppTheme.primary.opacity(0.3), radius: 8, x: 0, y: 4)
                }
            }
        }
        .padding(AppTheme.spacingLG)
        .background(AppTheme.glassPrimary)
        .cornerRadius(AppTheme.radiusLG)
    }
    
    private var footerSection: some View {
        VStack(spacing: AppTheme.spacingMD) {
            Text("Revolutionary Financial Protection")
                .font(AppTheme.headline())
                .foregroundColor(AppTheme.textPrimary)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Text("AI Escrow will transform how we handle financial disputes, making transactions safer, faster, and more transparent for everyone.")
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

struct EscrowFeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: AppTheme.spacingMD) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(AppTheme.primary)
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

struct EscrowStepCard: View {
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

struct UseCaseCard: View {
    let icon: String
    let title: String
    let description: String
    let examples: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingMD) {
            HStack(spacing: AppTheme.spacingMD) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(AppTheme.accent)
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
            }
            
            VStack(alignment: .leading, spacing: AppTheme.spacingSM) {
                Text("Common scenarios:")
                    .font(AppTheme.caption())
                    .foregroundColor(AppTheme.textSecondary)
                    .fontWeight(.medium)
                
                ForEach(examples, id: \.self) { example in
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundColor(AppTheme.success)
                        
                        Text(example)
                            .font(AppTheme.caption())
                            .foregroundColor(AppTheme.textSecondary)
                    }
                }
            }
        }
        .padding(AppTheme.spacingMD)
        .background(AppTheme.card)
        .cornerRadius(AppTheme.radiusMD)
    }
}

struct SecurityFeatureRow: View {
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

struct EscrowComparisonCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let vsTitle: String
    let vsSubtitle: String
    let color: Color
    
    var body: some View {
        HStack(spacing: AppTheme.spacingLG) {
            // Traditional side
            VStack(spacing: AppTheme.spacingSM) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(AppTheme.textSecondary)
                
                Text(title)
                    .font(AppTheme.caption())
                    .foregroundColor(AppTheme.textSecondary)
                    .fontWeight(.medium)
                
                Text(subtitle)
                    .font(AppTheme.caption2())
                    .foregroundColor(AppTheme.textTertiary)
            }
            .frame(maxWidth: .infinity)
            
            // VS divider
            VStack {
                Text("VS")
                    .font(AppTheme.caption())
                    .foregroundColor(AppTheme.textSecondary)
                    .fontWeight(.bold)
                    .padding(.horizontal, AppTheme.spacingSM)
                    .padding(.vertical, AppTheme.spacingXS)
                    .background(AppTheme.glassSecondary)
                    .cornerRadius(AppTheme.radiusXS)
            }
            
            // AI side
            VStack(spacing: AppTheme.spacingSM) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(vsTitle)
                    .font(AppTheme.caption())
                    .foregroundColor(AppTheme.textPrimary)
                    .fontWeight(.medium)
                
                Text(vsSubtitle)
                    .font(AppTheme.caption2())
                    .foregroundColor(color)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(AppTheme.spacingMD)
        .background(AppTheme.card)
        .cornerRadius(AppTheme.radiusMD)
    }
}

#Preview {
    EscrowView()
}