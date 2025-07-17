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
                        
                        // Contract types
                        contractTypesSection
                        
                        // How it works
                        howItWorksSection
                        
                        // Features
                        featuresSection
                        
                        // Legal standing
                        legalStandingSection
                        
                        // AI advantages
                        aiAdvantagesSection
                        
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
                
                Text("AI-Powered Legal Contracts")
                    .font(AppTheme.title2())
                    .foregroundColor(AppTheme.textPrimary)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                
                Text("Our AI creates legally binding contracts tailored to your specific dispute, ensuring fairness and enforceability in court")
                    .font(AppTheme.body())
                    .foregroundColor(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppTheme.spacingMD)
            }
        }
        .padding(.top, AppTheme.spacingXL)
    }
    
    private var contractTypesSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingLG) {
            Text("Contract Types We Create")
                .font(AppTheme.headline())
                .foregroundColor(AppTheme.textPrimary)
                .fontWeight(.bold)
            
            VStack(spacing: AppTheme.spacingMD) {
                ContractTypeCard(
                    icon: "dollarsign.circle.fill",
                    title: "Payment & Refund Agreements",
                    description: "Contracts for disputed payments, refunds, or money owed",
                    examples: ["Purchase refunds", "Service payment disputes", "Loan agreements", "Freelance payment issues"],
                    color: AppTheme.success
                )
                
                ContractTypeCard(
                    icon: "house.fill",
                    title: "Property & Rental Disputes",
                    description: "Agreements for property damage, rental issues, or ownership disputes",
                    examples: ["Security deposit returns", "Property damage claims", "Rental agreement violations", "Neighbor disputes"],
                    color: AppTheme.info
                )
                
                ContractTypeCard(
                    icon: "handshake.fill",
                    title: "Service & Contract Disputes",
                    description: "Resolution agreements for failed services or broken contracts",
                    examples: ["Contractor disputes", "Service quality issues", "Delivery problems", "Warranty claims"],
                    color: AppTheme.warning
                )
                
                ContractTypeCard(
                    icon: "person.2.fill",
                    title: "Personal & Family Agreements",
                    description: "Contracts for personal disputes and family matters",
                    examples: ["Shared expense disputes", "Personal loan agreements", "Family property division", "Pet custody arrangements"],
                    color: AppTheme.accent
                )
                
                ContractTypeCard(
                    icon: "briefcase.fill",
                    title: "Business & Employment",
                    description: "Professional dispute resolution contracts",
                    examples: ["Partnership dissolution", "Employment disputes", "Vendor agreements", "Intellectual property issues"],
                    color: AppTheme.primary
                )
                
                ContractTypeCard(
                    icon: "bitcoinsign.circle.fill",
                    title: "Crypto Smart Contract Mediation",
                    description: "AI-powered contracts for blockchain and cryptocurrency disputes",
                    examples: ["DeFi protocol disputes", "NFT transaction issues", "Smart contract bugs", "Crypto payment disputes", "Token distribution conflicts"],
                    color: AppTheme.warning
                )
            }
        }
        .padding(AppTheme.spacingLG)
        .background(AppTheme.glassPrimary)
        .cornerRadius(AppTheme.radiusLG)
    }
    
    private var howItWorksSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingLG) {
            Text("How AI Contract Creation Works")
                .font(AppTheme.headline())
                .foregroundColor(AppTheme.textPrimary)
                .fontWeight(.bold)
            
            VStack(spacing: AppTheme.spacingMD) {
                StepCard(
                    number: "1",
                    title: "Dispute Analysis",
                    description: "AI analyzes your dispute details, evidence, and both parties' positions",
                    icon: "brain.head.profile"
                )
                
                StepCard(
                    number: "2",
                    title: "Legal Research",
                    description: "AI researches applicable laws and precedents for your specific situation",
                    icon: "book.fill"
                )
                
                StepCard(
                    number: "3",
                    title: "Contract Generation",
                    description: "AI creates a balanced contract with fair terms for both parties",
                    icon: "doc.text.fill"
                )
                
                StepCard(
                    number: "4",
                    title: "Review & Revision",
                    description: "Both parties can review and request modifications before signing",
                    icon: "pencil.circle.fill"
                )
                
                StepCard(
                    number: "5",
                    title: "Digital Execution",
                    description: "Secure digital signatures make the contract legally binding",
                    icon: "signature"
                )
            }
        }
        .padding(AppTheme.spacingLG)
        .background(AppTheme.glassPrimary)
        .cornerRadius(AppTheme.radiusLG)
    }
    
    private var featuresSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingLG) {
            Text("Advanced Contract Features")
                .font(AppTheme.headline())
                .foregroundColor(AppTheme.textPrimary)
                .fontWeight(.bold)
            
            VStack(spacing: AppTheme.spacingMD) {
                FeatureRow(
                    icon: "scale.3d",
                    title: "Balanced Terms",
                    description: "AI ensures fair terms that protect both parties equally"
                )
                
                FeatureRow(
                    icon: "checkmark.shield.fill",
                    title: "Legal Compliance",
                    description: "All contracts comply with local and federal laws"
                )
                
                FeatureRow(
                    icon: "doc.text.magnifyingglass",
                    title: "Plain Language",
                    description: "Complex legal terms explained in simple language"
                )
                
                FeatureRow(
                    icon: "arrow.triangle.2.circlepath",
                    title: "Revision Tracking",
                    description: "Complete history of changes and negotiations"
                )
                
                FeatureRow(
                    icon: "clock.arrow.circlepath",
                    title: "Automatic Updates",
                    description: "Contracts updated for new laws and regulations"
                )
                
                FeatureRow(
                    icon: "lock.shield",
                    title: "Secure Storage",
                    description: "Encrypted storage with blockchain verification"
                )
            }
        }
        .padding(AppTheme.spacingLG)
        .background(AppTheme.glassPrimary)
        .cornerRadius(AppTheme.radiusLG)
    }
    
    private var legalStandingSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingLG) {
            Text("Legal Standing & Enforceability")
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
                        
                        Text("All AI-generated contracts are legally binding and enforceable in court when properly executed with digital signatures from both parties.")
                            .font(AppTheme.caption())
                            .foregroundColor(AppTheme.textSecondary)
                    }
                }
                
                HStack(alignment: .top, spacing: AppTheme.spacingMD) {
                    Image(systemName: "shield.checkered")
                        .foregroundColor(AppTheme.info)
                        .font(.title2)
                    
                    VStack(alignment: .leading, spacing: AppTheme.spacingSM) {
                        Text("Jurisdiction Compliant")
                            .font(AppTheme.body())
                            .foregroundColor(AppTheme.textPrimary)
                            .fontWeight(.semibold)
                        
                        Text("Contracts automatically comply with laws in your jurisdiction and include proper venue and governing law clauses.")
                            .font(AppTheme.caption())
                            .foregroundColor(AppTheme.textSecondary)
                    }
                }
                
                HStack(alignment: .top, spacing: AppTheme.spacingMD) {
                    Image(systemName: "signature")
                        .foregroundColor(AppTheme.accent)
                        .font(.title2)
                    
                    VStack(alignment: .leading, spacing: AppTheme.spacingSM) {
                        Text("Digital Signature Validity")
                            .font(AppTheme.body())
                            .foregroundColor(AppTheme.textPrimary)
                            .fontWeight(.semibold)
                        
                        Text("Digital signatures are legally equivalent to handwritten signatures under the Electronic Signatures in Global and National Commerce Act (ESIGN).")
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
    
    private var aiAdvantagesSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingLG) {
            Text("Why Choose AI-Generated Contracts?")
                .font(AppTheme.headline())
                .foregroundColor(AppTheme.textPrimary)
                .fontWeight(.bold)
            
            VStack(spacing: AppTheme.spacingMD) {
                ContractComparisonCard(
                    icon: "dollarsign.circle.fill",
                    title: "Traditional Lawyers",
                    subtitle: "$500-5000+ per contract",
                    vsTitle: "AI Contracts",
                                                vsSubtitle: "FREE during beta",
                    color: AppTheme.success
                )
                
                ContractComparisonCard(
                    icon: "clock.fill",
                    title: "Legal Firms",
                    subtitle: "Days to weeks",
                    vsTitle: "AI Generation",
                    vsSubtitle: "Minutes to hours",
                    color: AppTheme.info
                )
                
                ContractComparisonCard(
                    icon: "person.fill",
                    title: "Human Bias",
                    subtitle: "Favors paying client",
                    vsTitle: "AI Fairness",
                    vsSubtitle: "Neutral to both parties",
                    color: AppTheme.accent
                )
                
                ContractComparisonCard(
                    icon: "doc.text.fill",
                    title: "Standard Templates",
                    subtitle: "Generic language",
                    vsTitle: "Custom AI",
                    vsSubtitle: "Tailored to your case",
                    color: AppTheme.warning
                )
            }
        }
        .padding(AppTheme.spacingLG)
        .background(AppTheme.glassPrimary)
        .cornerRadius(AppTheme.radiusLG)
    }
    
    private var footerSection: some View {
        VStack(spacing: AppTheme.spacingMD) {
            Text("Ready to Create Your Contract?")
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

struct ContractTypeCard: View {
    let icon: String
    let title: String
    let description: String
    let examples: [String]
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingMD) {
            HStack(spacing: AppTheme.spacingMD) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
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
                Text("Examples:")
                    .font(AppTheme.caption())
                    .foregroundColor(AppTheme.textSecondary)
                    .fontWeight(.medium)
                
                ForEach(examples, id: \.self) { example in
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundColor(color)
                        
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
        .frame(minHeight: AppTheme.uniformCardHeight, alignment: .topLeading)
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
        .frame(minHeight: AppTheme.uniformCardHeight, alignment: .topLeading)
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

struct ContractComparisonCard: View {
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
        .frame(minHeight: AppTheme.uniformCardHeight, alignment: .topLeading)
    }
}

#Preview {
    ContractView()
}