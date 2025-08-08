//
//  EscrowView.swift
//  MediationAI
//
//  Created by AI Assistant on 7/14/25.
//

import SwiftUI

struct EscrowView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedTier = "standard"
    @State private var disputeAmount: String = ""
    @State private var showingPayment = false
    
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
                        
                        // Pricing Calculator
                        pricingCalculatorSection
                        
                        // Pricing Tiers
                        pricingTiersSection
                        
                        // How it works
                        howItWorksSection
                        
                        // Benefits
                        benefitsSection
                        
                        // Security features
                        securitySection
                        
                        // Start Escrow Button
                        startEscrowButton
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, AppTheme.spacingLG)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(AppTheme.textSecondary)
                    }
                }
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: AppTheme.spacingMD) {
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 60))
                .foregroundColor(AppTheme.accentColor)
            
            Text("Secure Escrow Service")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(AppTheme.textPrimary)
            
            Text("Hold funds safely during dispute resolution")
                .font(.headline)
                .foregroundColor(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, AppTheme.spacingXL)
    }
    
    // MARK: - Pricing Calculator
    private var pricingCalculatorSection: some View {
        VStack(spacing: AppTheme.spacingMD) {
            Text("Calculate Your Escrow Fee")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(AppTheme.textPrimary)
            
            // Amount input
            VStack(alignment: .leading, spacing: AppTheme.spacingSM) {
                Text("Dispute Amount")
                    .font(.caption)
                    .foregroundColor(AppTheme.textSecondary)
                
                HStack {
                    Text("$")
                        .foregroundColor(AppTheme.textSecondary)
                    TextField("Enter amount", text: $disputeAmount)
                        .keyboardType(.decimalPad)
                        .foregroundColor(AppTheme.textPrimary)
                }
                .padding()
                .background(AppTheme.cardBackground)
                .cornerRadius(AppTheme.cornerRadius)
            }
            
            // Fee calculation
            if let amount = Double(disputeAmount), amount > 0 {
                VStack(spacing: AppTheme.spacingSM) {
                    HStack {
                        Text("Escrow Amount:")
                        Spacer()
                        Text("$\(amount, specifier: "%.2f")")
                    }
                    
                    HStack {
                        Text("Service Fee (\(feePercentage)%):")
                        Spacer()
                        Text("$\(calculateFee(amount), specifier: "%.2f")")
                    }
                    .foregroundColor(AppTheme.accentColor)
                    
                    Divider()
                    
                    HStack {
                        Text("Total per party:")
                        Spacer()
                        Text("$\((amount + calculateFee(amount)/2), specifier: "%.2f")")
                            .fontWeight(.bold)
                    }
                }
                .padding()
                .background(AppTheme.cardBackground.opacity(0.5))
                .cornerRadius(AppTheme.cornerRadius)
            }
        }
        .padding()
        .background(AppTheme.cardBackground)
        .cornerRadius(AppTheme.cornerRadiusLarge)
    }
    
    // MARK: - Pricing Tiers
    private var pricingTiersSection: some View {
        VStack(spacing: AppTheme.spacingMD) {
            Text("Choose Your Resolution Type")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(AppTheme.textPrimary)
            
            // Standard Tier
            PricingTierCard(
                title: "Standard Mediation",
                price: "5%",
                features: [
                    "AI-powered mediation",
                    "Secure fund holding",
                    "Digital contracts",
                    "7-day resolution",
                    "Email support"
                ],
                isSelected: selectedTier == "standard",
                color: .blue
            ) {
                selectedTier = "standard"
            }
            
            // Expedited Tier
            PricingTierCard(
                title: "Expedited Resolution",
                price: "7.5%",
                features: [
                    "Priority AI mediation",
                    "Human mediator review",
                    "48-hour resolution",
                    "Priority support",
                    "Video sessions"
                ],
                isSelected: selectedTier == "expedited",
                color: .purple,
                recommended: true
            ) {
                selectedTier = "expedited"
            }
            
            // Arbitration Tier
            PricingTierCard(
                title: "Binding Arbitration",
                price: "10%",
                features: [
                    "Licensed arbitrator",
                    "Legally binding",
                    "Court-admissible docs",
                    "14-day resolution",
                    "Full legal support"
                ],
                isSelected: selectedTier == "binding",
                color: .orange
            ) {
                selectedTier = "binding"
            }
        }
    }
    
    // MARK: - How it Works
    private var howItWorksSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingMD) {
            Text("How Escrow Works")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(AppTheme.textPrimary)
            
            ForEach(escrowSteps.indices, id: \.self) { index in
                HStack(alignment: .top, spacing: AppTheme.spacingMD) {
                    // Step number
                    Text("\(index + 1)")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 30, height: 30)
                        .background(AppTheme.accentColor)
                        .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: AppTheme.spacingXS) {
                        Text(escrowSteps[index].title)
                            .font(.headline)
                            .foregroundColor(AppTheme.textPrimary)
                        
                        Text(escrowSteps[index].description)
                            .font(.subheadline)
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    
                    Spacer()
                }
            }
        }
        .padding()
        .background(AppTheme.cardBackground)
        .cornerRadius(AppTheme.cornerRadiusLarge)
    }
    
    // MARK: - Benefits Section
    private var benefitsSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingMD) {
            Text("Why Use Our Escrow?")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(AppTheme.textPrimary)
            
            VStack(spacing: AppTheme.spacingMD) {
                BenefitRow(
                    icon: "checkmark.shield.fill",
                    title: "100% Legal",
                    description: "No gambling license required - we're a legitimate escrow service",
                    color: .green
                )
                
                BenefitRow(
                    icon: "lock.fill",
                    title: "Bank-Level Security",
                    description: "Funds held securely with Stripe's PCI-compliant infrastructure",
                    color: .blue
                )
                
                BenefitRow(
                    icon: "bolt.fill",
                    title: "Fast Resolution",
                    description: "Most disputes resolved in 48-72 hours",
                    color: .orange
                )
                
                BenefitRow(
                    icon: "dollarsign.circle.fill",
                    title: "Fair Pricing",
                    description: "Only pay when dispute is resolved - no upfront costs",
                    color: .green
                )
            }
        }
        .padding()
        .background(AppTheme.cardBackground)
        .cornerRadius(AppTheme.cornerRadiusLarge)
    }
    
    // MARK: - Security Section
    private var securitySection: some View {
        VStack(spacing: AppTheme.spacingMD) {
            Label("Bank-Grade Security", systemImage: "lock.shield.fill")
                .font(.headline)
                .foregroundColor(AppTheme.textPrimary)
            
            Text("Your funds are protected by Stripe's world-class security infrastructure, the same system trusted by millions of businesses worldwide.")
                .font(.subheadline)
                .foregroundColor(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
            
            HStack(spacing: AppTheme.spacingLG) {
                SecurityBadge(icon: "checkmark.shield", text: "PCI DSS")
                SecurityBadge(icon: "lock.fill", text: "256-bit SSL")
                SecurityBadge(icon: "eye.slash.fill", text: "Private")
            }
        }
        .padding()
        .background(
            LinearGradient(
                colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(AppTheme.cornerRadiusLarge)
    }
    
    // MARK: - Start Button
    private var startEscrowButton: some View {
        Button(action: { showingPayment = true }) {
            HStack {
                Image(systemName: "lock.shield.fill")
                Text("Start Secure Escrow")
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(AppTheme.accentColor)
            .cornerRadius(AppTheme.cornerRadius)
        }
        .sheet(isPresented: $showingPayment) {
            // Payment flow
            Text("Payment Flow - Coming Soon")
        }
    }
    
    // MARK: - Helper Properties
    private var feePercentage: Double {
        switch selectedTier {
        case "standard": return 5.0
        case "expedited": return 7.5
        case "binding": return 10.0
        default: return 5.0
        }
    }
    
    private func calculateFee(_ amount: Double) -> Double {
        return amount * (feePercentage / 100)
    }
    
    private let escrowSteps = [
        (title: "Create Dispute", description: "Both parties agree to use escrow for fair resolution"),
        (title: "Deposit Funds", description: "Each party deposits the disputed amount plus service fee"),
        (title: "Present Evidence", description: "Submit your case with documents and evidence"),
        (title: "Get Resolution", description: "AI mediator or arbitrator decides the outcome"),
        (title: "Funds Released", description: "Winner receives funds minus service fee")
    ]
}

// MARK: - Supporting Views

struct PricingTierCard: View {
    let title: String
    let price: String
    let features: [String]
    let isSelected: Bool
    let color: Color
    var recommended: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: AppTheme.spacingMD) {
                HStack {
                    VStack(alignment: .leading) {
                        if recommended {
                            Text("RECOMMENDED")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(color)
                        }
                        Text(title)
                            .font(.headline)
                            .foregroundColor(AppTheme.textPrimary)
                    }
                    
                    Spacer()
                    
                    Text(price)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(color)
                }
                
                VStack(alignment: .leading, spacing: AppTheme.spacingXS) {
                    ForEach(features, id: \.self) { feature in
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(color)
                                .font(.caption)
                            Text(feature)
                                .font(.subheadline)
                                .foregroundColor(AppTheme.textSecondary)
                        }
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                    .fill(AppTheme.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                            .stroke(isSelected ? color : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct BenefitRow: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack(alignment: .top, spacing: AppTheme.spacingMD) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: AppTheme.spacingXS) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(AppTheme.textPrimary)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(AppTheme.textSecondary)
            }
            
            Spacer()
        }
    }
}

struct SecurityBadge: View {
    let icon: String
    let text: String
    
    var body: some View {
        VStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(AppTheme.accentColor)
            Text(text)
                .font(.caption)
                .foregroundColor(AppTheme.textSecondary)
        }
    }
}

#Preview {
    EscrowView()
}