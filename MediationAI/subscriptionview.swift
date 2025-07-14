//
//  SubscriptionView.swift
//  MediationAI
//
//  Created by Linda Alster on 7/14/25.
//

import SwiftUI

struct SubscriptionView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authService: MockAuthService
    @StateObject private var purchaseService = InAppPurchaseService()
    @State private var selectedTier: SubscriptionTier = .premium
    @State private var isProcessing = false
    @State private var showFeatures = false
    @State private var animateElements = false
    
    var body: some View {
        ZStack {
            AppTheme.backgroundGradient
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                headerSection
                
                // Content
                ScrollView {
                    VStack(spacing: AppTheme.spacingXL) {
                        // Hero section
                        heroSection
                        
                        // Current subscription
                        if let user = authService.currentUser {
                            currentSubscriptionCard(user: user)
                        }
                        
                        // Subscription tiers
                        subscriptionTiers
                        
                        // Features comparison
                        featuresComparison
                        
                        // Social proof
                        socialProofSection
                        
                        // FAQ
                        faqSection
                        
                        Spacer(minLength: AppTheme.spacingXXL)
                    }
                    .padding(.horizontal, AppTheme.spacingLG)
                    .padding(.top, AppTheme.spacingLG)
                }
                
                // Subscribe button
                if authService.currentUser?.subscription != selectedTier {
                    subscribeButton
                }
            }
        }
        .navigationBarHidden(true)
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
            
            Text("Subscription Plans")
                .font(AppTheme.title3())
                .foregroundColor(AppTheme.textPrimary)
                .fontWeight(.semibold)
            
            Spacer()
            
            Color.clear
                .frame(width: 32, height: 32)
        }
        .padding(.horizontal, AppTheme.spacingLG)
        .padding(.top, AppTheme.spacingSM)
    }
    
    private var heroSection: some View {
        VStack(spacing: AppTheme.spacingLG) {
            Image(systemName: "crown.fill")
                .font(.system(size: 64))
                .foregroundStyle(AppTheme.mainGradient)
                .scaleEffect(animateElements ? 1.0 : 0.8)
                .opacity(animateElements ? 1.0 : 0.0)
                .animation(.easeOut(duration: 0.8), value: animateElements)
            
            VStack(spacing: AppTheme.spacingMD) {
                Text("Unlock Premium Mediation")
                    .font(AppTheme.title())
                    .foregroundColor(AppTheme.textPrimary)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text("Get faster resolutions, expert support, and unlimited disputes with our premium plans.")
                    .font(AppTheme.body())
                    .foregroundColor(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            .opacity(animateElements ? 1.0 : 0.0)
            .animation(.easeOut(duration: 0.8).delay(0.1), value: animateElements)
        }
    }
    
    private func currentSubscriptionCard(user: User) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingLG) {
            HStack {
                VStack(alignment: .leading, spacing: AppTheme.spacingSM) {
                    Text("Current Plan")
                        .font(AppTheme.caption())
                        .foregroundColor(AppTheme.textSecondary)
                        .fontWeight(.medium)
                    
                    HStack {
                        Text(user.subscription.rawValue)
                            .font(AppTheme.headline())
                            .foregroundColor(AppTheme.textPrimary)
                            .fontWeight(.bold)
                        
                        if user.subscription != .basic {
                            Text("👑")
                                .font(.title3)
                        }
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: AppTheme.spacingSM) {
                    Text("$\(user.subscription.monthlyPrice, specifier: "%.2f")")
                        .font(AppTheme.title2())
                        .foregroundColor(AppTheme.success)
                        .fontWeight(.bold)
                    
                    Text("per month")
                        .font(AppTheme.caption2())
                        .foregroundColor(AppTheme.textSecondary)
                }
            }
            
            if user.subscription == .basic {
                VStack(alignment: .leading, spacing: AppTheme.spacingSM) {
                    Text("Upgrade Benefits")
                        .font(AppTheme.caption())
                        .foregroundColor(AppTheme.textPrimary)
                        .fontWeight(.semibold)
                    
                    VStack(alignment: .leading, spacing: AppTheme.spacingSM) {
                        BenefitRow(icon: "infinity", text: "Unlimited disputes")
                        BenefitRow(icon: "bolt.fill", text: "Priority processing")
                        BenefitRow(icon: "person.badge.plus", text: "Expert support")
                        BenefitRow(icon: "chart.line.uptrend.xyaxis", text: "Advanced analytics")
                    }
                }
            }
        }
        .padding(AppTheme.spacingLG)
        .glassCard()
        .scaleEffect(animateElements ? 1.0 : 0.95)
        .opacity(animateElements ? 1.0 : 0.0)
        .animation(.easeOut(duration: 0.6).delay(0.2), value: animateElements)
    }
    
    private var subscriptionTiers: some View {
        VStack(spacing: AppTheme.spacingLG) {
            Text("Choose Your Plan")
                .font(AppTheme.title2())
                .foregroundColor(AppTheme.textPrimary)
                .fontWeight(.bold)
            
            LazyVStack(spacing: AppTheme.spacingMD) {
                ForEach(SubscriptionTier.allCases, id: \.self) { tier in
                    SubscriptionTierCard(
                        tier: tier,
                        isSelected: selectedTier == tier,
                        onSelect: { selectedTier = tier }
                    )
                    .scaleEffect(animateElements ? 1.0 : 0.95)
                    .opacity(animateElements ? 1.0 : 0.0)
                    .animation(.easeOut(duration: 0.6).delay(0.3 + Double(SubscriptionTier.allCases.firstIndex(of: tier) ?? 0) * 0.1), value: animateElements)
                }
            }
        }
    }
    
    private var featuresComparison: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingLG) {
            Text("Feature Comparison")
                .font(AppTheme.title2())
                .foregroundColor(AppTheme.textPrimary)
                .fontWeight(.bold)
            
            VStack(spacing: AppTheme.spacingMD) {
                FeatureComparisonRow(
                    feature: "Disputes per month",
                    basic: "Pay per use",
                    premium: "Unlimited",
                    expert: "Unlimited",
                    enterprise: "Unlimited"
                )
                
                FeatureComparisonRow(
                    feature: "Resolution time",
                    basic: "24-48 hours",
                    premium: "6-12 hours",
                    expert: "2-4 hours",
                    enterprise: "1 hour"
                )
                
                FeatureComparisonRow(
                    feature: "AI models",
                    basic: "Basic",
                    premium: "Advanced",
                    expert: "Legal Expert",
                    enterprise: "All + Custom"
                )
                
                FeatureComparisonRow(
                    feature: "Human experts",
                    basic: "❌",
                    premium: "❌",
                    expert: "✅",
                    enterprise: "✅ + Priority"
                )
                
                FeatureComparisonRow(
                    feature: "Evidence analysis",
                    basic: "Basic",
                    premium: "✅",
                    expert: "✅ Advanced",
                    enterprise: "✅ + Legal Review"
                )
                
                FeatureComparisonRow(
                    feature: "API access",
                    basic: "❌",
                    premium: "❌",
                    expert: "❌",
                    enterprise: "✅"
                )
            }
        }
        .padding(AppTheme.spacingLG)
        .glassCard()
        .scaleEffect(animateElements ? 1.0 : 0.95)
        .opacity(animateElements ? 1.0 : 0.0)
        .animation(.easeOut(duration: 0.6).delay(0.5), value: animateElements)
    }
    
    private var socialProofSection: some View {
        VStack(spacing: AppTheme.spacingLG) {
            Text("Join 50,000+ Happy Users")
                .font(AppTheme.title2())
                .foregroundColor(AppTheme.textPrimary)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            VStack(spacing: AppTheme.spacingMD) {
                TestimonialCard(
                    quote: "Saved me $5,000 in legal fees. The AI resolution was spot-on!",
                    author: "Sarah K.",
                    role: "Small Business Owner",
                    rating: 5
                )
                
                TestimonialCard(
                    quote: "Expert tier is worth every penny. Got human review for my complex case.",
                    author: "Michael R.",
                    role: "Freelancer",
                    rating: 5
                )
            }
        }
        .scaleEffect(animateElements ? 1.0 : 0.95)
        .opacity(animateElements ? 1.0 : 0.0)
        .animation(.easeOut(duration: 0.6).delay(0.6), value: animateElements)
    }
    
    private var faqSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingLG) {
            Text("Frequently Asked Questions")
                .font(AppTheme.title2())
                .foregroundColor(AppTheme.textPrimary)
                .fontWeight(.bold)
            
            VStack(spacing: AppTheme.spacingMD) {
                FAQItem(
                    question: "Can I cancel anytime?",
                    answer: "Yes, you can cancel your subscription at any time. You'll keep your benefits until the end of your billing period."
                )
                
                FAQItem(
                    question: "What happens to my disputes if I downgrade?",
                    answer: "All your existing disputes remain accessible. New disputes will be subject to your current plan's limits."
                )
                
                FAQItem(
                    question: "Do you offer refunds?",
                    answer: "We offer a 7-day money-back guarantee for new subscriptions if you're not satisfied."
                )
            }
        }
        .padding(AppTheme.spacingLG)
        .glassCard()
        .scaleEffect(animateElements ? 1.0 : 0.95)
        .opacity(animateElements ? 1.0 : 0.0)
        .animation(.easeOut(duration: 0.6).delay(0.7), value: animateElements)
    }
    
    private var subscribeButton: some View {
        VStack(spacing: AppTheme.spacingMD) {
            Button(action: handleSubscribe) {
                HStack {
                    if isProcessing {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.9)
                    } else {
                        Image(systemName: "crown.fill")
                            .font(.title3)
                    }
                    
                    Text(isProcessing ? "Processing..." : "Upgrade to \(selectedTier.rawValue)")
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
            .disabled(isProcessing)
            .opacity(isProcessing ? 0.7 : 1.0)
            
            HStack {
                Image(systemName: "shield.checkered")
                    .foregroundColor(AppTheme.success)
                
                Text("Secure payment • Cancel anytime • 7-day guarantee")
                    .font(AppTheme.caption2())
                    .foregroundColor(AppTheme.textTertiary)
                
                Spacer()
            }
        }
        .padding(AppTheme.spacingLG)
        .background(AppTheme.cardBackground)
    }
    
    private func handleSubscribe() {
        isProcessing = true
        
        Task {
            await Task.sleep(nanoseconds: 2_000_000_000) // Simulate processing
            
            await MainActor.run {
                isProcessing = false
                authService.currentUser?.subscription = selectedTier
                dismiss()
            }
        }
    }
}

struct SubscriptionTierCard: View {
    let tier: SubscriptionTier
    let isSelected: Bool
    let onSelect: () -> Void
    
    private var isPopular: Bool {
        tier == .premium
    }
    
    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: AppTheme.spacingLG) {
                // Header
                VStack(spacing: AppTheme.spacingSM) {
                    HStack {
                        Text(tier.rawValue)
                            .font(AppTheme.title3())
                            .foregroundColor(AppTheme.textPrimary)
                            .fontWeight(.bold)
                        
                        if isPopular {
                            Text("POPULAR")
                                .font(AppTheme.caption2())
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal, AppTheme.spacingSM)
                                .padding(.vertical, 2)
                                .background(AppTheme.warning)
                                .cornerRadius(AppTheme.radiusXS)
                        }
                        
                        Spacer()
                    }
                    
                    HStack {
                        if tier.monthlyPrice == 0 {
                            Text("Free")
                                .font(AppTheme.title())
                                .foregroundColor(AppTheme.success)
                                .fontWeight(.bold)
                        } else {
                            Text("$\(tier.monthlyPrice, specifier: "%.2f")")
                                .font(AppTheme.title())
                                .foregroundColor(AppTheme.success)
                                .fontWeight(.bold)
                            
                            Text("per month")
                                .font(AppTheme.caption())
                                .foregroundColor(AppTheme.textSecondary)
                        }
                        
                        Spacer()
                    }
                }
                
                // Features
                VStack(alignment: .leading, spacing: AppTheme.spacingSM) {
                    ForEach(tier.features, id: \.self) { feature in
                        HStack(spacing: AppTheme.spacingSM) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(AppTheme.success)
                                .font(.caption)
                            
                            Text(feature)
                                .font(AppTheme.caption())
                                .foregroundColor(AppTheme.textSecondary)
                            
                            Spacer()
                        }
                    }
                }
                
                // Max dispute value
                HStack {
                    Text("Max dispute value:")
                        .font(AppTheme.caption2())
                        .foregroundColor(AppTheme.textTertiary)
                    
                    Spacer()
                    
                    Text("$\(Int(tier.maxDisputeValue))")
                        .font(AppTheme.caption2())
                        .fontWeight(.semibold)
                        .foregroundColor(AppTheme.info)
                }
            }
            .padding(AppTheme.spacingLG)
            .background(
                isSelected ? AppTheme.primary.opacity(0.1) : AppTheme.cardGradient
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.radiusLG)
                    .stroke(
                        isSelected ? AppTheme.primary : Color.white.opacity(0.1),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .cornerRadius(AppTheme.radiusLG)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct FeatureComparisonRow: View {
    let feature: String
    let basic: String
    let premium: String
    let expert: String
    let enterprise: String
    
    var body: some View {
        VStack(spacing: AppTheme.spacingSM) {
            HStack {
                Text(feature)
                    .font(AppTheme.caption())
                    .fontWeight(.semibold)
                    .foregroundColor(AppTheme.textPrimary)
                
                Spacer()
            }
            
            HStack(spacing: AppTheme.spacingSM) {
                FeatureCell(text: basic, tier: .basic)
                FeatureCell(text: premium, tier: .premium)
                FeatureCell(text: expert, tier: .expert)
                FeatureCell(text: enterprise, tier: .enterprise)
            }
        }
        .padding(.vertical, AppTheme.spacingSM)
    }
}

struct FeatureCell: View {
    let text: String
    let tier: SubscriptionTier
    
    var body: some View {
        Text(text)
            .font(AppTheme.caption2())
            .foregroundColor(AppTheme.textSecondary)
            .padding(.horizontal, AppTheme.spacingSM)
            .padding(.vertical, AppTheme.spacingSM)
            .frame(maxWidth: .infinity)
            .background(tier.monthlyPrice == 0 ? AppTheme.glassSecondary : tier == .premium ? AppTheme.warning.opacity(0.1) : AppTheme.primary.opacity(0.05))
            .cornerRadius(AppTheme.radiusXS)
    }
}

struct BenefitRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: AppTheme.spacingSM) {
            Image(systemName: icon)
                .foregroundColor(AppTheme.success)
                .font(.caption)
            
            Text(text)
                .font(AppTheme.caption2())
                .foregroundColor(AppTheme.textSecondary)
            
            Spacer()
        }
    }
}

struct TestimonialCard: View {
    let quote: String
    let author: String
    let role: String
    let rating: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingMD) {
            HStack {
                ForEach(0..<rating, id: \.self) { _ in
                    Image(systemName: "star.fill")
                        .foregroundColor(AppTheme.warning)
                        .font(.caption)
                }
                
                Spacer()
            }
            
            Text("\"\(quote)\"")
                .font(AppTheme.body())
                .foregroundColor(AppTheme.textPrimary)
                .italic()
                .lineSpacing(3)
            
            HStack {
                Text(author)
                    .font(AppTheme.caption())
                    .fontWeight(.semibold)
                    .foregroundColor(AppTheme.textPrimary)
                
                Text("•")
                    .foregroundColor(AppTheme.textTertiary)
                
                Text(role)
                    .font(AppTheme.caption())
                    .foregroundColor(AppTheme.textSecondary)
                
                Spacer()
            }
        }
        .padding(AppTheme.spacingLG)
        .glassCard()
    }
}

struct FAQItem: View {
    let question: String
    let answer: String
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingMD) {
            Button(action: { isExpanded.toggle() }) {
                HStack {
                    Text(question)
                        .font(AppTheme.body())
                        .fontWeight(.medium)
                        .foregroundColor(AppTheme.textPrimary)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(AppTheme.textSecondary)
                        .font(.caption)
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            if isExpanded {
                Text(answer)
                    .font(AppTheme.caption())
                    .foregroundColor(AppTheme.textSecondary)
                    .lineSpacing(3)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(.vertical, AppTheme.spacingSM)
        .animation(.easeInOut(duration: 0.3), value: isExpanded)
    }
}