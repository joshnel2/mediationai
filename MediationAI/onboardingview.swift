//
//  OnboardingView.swift
//  MediationAI
//
//  Created by Linda Alster on 7/14/25.
//

import SwiftUI

struct OnboardingView: View {
    @State private var showAuth = false
    @State private var showMain = false
    
    var body: some View {
        if showAuth {
            ModernAuthView()
        } else if showMain {
            BalancedScaleView(onGetStarted: { showAuth = true })
        } else {
            AnimatedScaleIntroView(onContinue: { showMain = true })
        }
    }
}

struct OnboardingCarouselView: View {
    let onGetStarted: () -> Void
    @State private var currentPage = 0
    @State private var animateElements = false
    
    private let features = [
        OnboardingFeature(
            icon: "dollarsign.circle.fill",
            title: "Skip Legal Fees",
            subtitle: "Save Thousands",
            description: "Resolve disputes for just $2 total instead of expensive lawyer fees and court costs.",
            color: .green
        ),
        OnboardingFeature(
            icon: "brain.head.profile",
            title: "AI-Powered Resolution",
            subtitle: "Unbiased & Smart",
            description: "Our advanced AI analyzes both sides fairly and provides intelligent mediation recommendations.",
            color: .blue
        ),
        OnboardingFeature(
            icon: "clock.fill",
            title: "Minutes, Not Months",
            subtitle: "Fast Resolution",
            description: "Get your dispute resolved in minutes instead of waiting months for traditional legal processes.",
            color: .purple
        )
    ]
    
    var body: some View {
        ZStack {
            // Beautiful gradient background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.1, green: 0.1, blue: 0.2),
                    Color(red: 0.2, green: 0.1, blue: 0.3),
                    Color(red: 0.1, green: 0.2, blue: 0.4)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Skip button
                HStack {
                    Spacer()
                    Button("Skip") {
                        onGetStarted()
                    }
                    .font(.body)
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.top, 50)
                    .padding(.trailing, 32)
                }
                
                Spacer()
                
                // Feature carousel
                TabView(selection: $currentPage) {
                    ForEach(0..<features.count, id: \.self) { index in
                        OnboardingFeatureView(feature: features[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .frame(height: 400)
                
                // Page indicator
                HStack(spacing: 12) {
                    ForEach(0..<features.count, id: \.self) { index in
                        Circle()
                            .fill(currentPage == index ? Color.white : Color.white.opacity(0.3))
                            .frame(width: 8, height: 8)
                            .scaleEffect(currentPage == index ? 1.2 : 1.0)
                            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: currentPage)
                    }
                }
                .padding(.top, 32)
                
                Spacer()
                
                // Get started button
                VStack(spacing: 16) {
                    Button(action: onGetStarted) {
                        HStack {
                            Text("Get Started")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            Image(systemName: "arrow.right")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.blue, Color.purple]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundColor(.white)
                        .cornerRadius(16)
                        .shadow(color: Color.blue.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .scaleEffect(animateElements ? 1.0 : 0.9)
                    .opacity(animateElements ? 1.0 : 0.0)
                    
                    Text("Join thousands resolving disputes fairly")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                        .opacity(animateElements ? 1.0 : 0.0)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 50)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8).delay(0.5)) {
                animateElements = true
            }
        }
    }
}

struct OnboardingFeature {
    let icon: String
    let title: String
    let subtitle: String
    let description: String
    let color: Color
}

struct OnboardingFeatureView: View {
    let feature: OnboardingFeature
    @State private var animateIn = false
    
    var body: some View {
        VStack(spacing: 32) {
            // Icon with gradient background
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                feature.color.opacity(0.3),
                                feature.color.opacity(0.1),
                                Color.clear
                            ]),
                            center: .center,
                            startRadius: 50,
                            endRadius: 100
                        )
                    )
                    .frame(width: 160, height: 160)
                    .scaleEffect(animateIn ? 1.0 : 0.8)
                
                Image(systemName: feature.icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.white, feature.color.opacity(0.8)]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .scaleEffect(animateIn ? 1.0 : 0.8)
            }
            
            // Text content
            VStack(spacing: 16) {
                VStack(spacing: 8) {
                    Text(feature.subtitle)
                        .font(.subheadline)
                        .foregroundColor(feature.color.opacity(0.8))
                        .fontWeight(.medium)
                        .opacity(animateIn ? 1.0 : 0.0)
                    
                    Text(feature.title)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .opacity(animateIn ? 1.0 : 0.0)
                }
                
                Text(feature.description)
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 32)
                    .opacity(animateIn ? 1.0 : 0.0)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                animateIn = true
            }
        }
    }
}

// MARK: - Animated Scale Introduction View
struct AnimatedScaleIntroView: View {
    let onContinue: () -> Void
    @State private var scaleRotation: Double = 0
    @State private var leftSideWeight: CGFloat = 0.3
    @State private var rightSideWeight: CGFloat = 0.7
    @State private var showTitle = false
    @State private var showSubtitle = false
    @State private var pulseScale = false
    
    var body: some View {
        ZStack {
            AppTheme.backgroundGradient
                .ignoresSafeArea()
            
            VStack(spacing: AppTheme.spacingXXL) {
                Spacer()
                
                // Animated Scale
                VStack(spacing: AppTheme.spacingXL) {
                    // Title
                    if showTitle {
                        Text("Disputes Are Unbalanced")
                            .font(AppTheme.largeTitle())
                            .fontWeight(.bold)
                            .foregroundColor(AppTheme.textPrimary)
                            .multilineTextAlignment(.center)
                            .scaleEffect(pulseScale ? 1.05 : 1.0)
                            .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: pulseScale)
                    }
                    
                    // Scale Animation
                    ScaleView(
                        leftWeight: leftSideWeight,
                        rightWeight: rightSideWeight,
                        rotation: scaleRotation
                    )
                    .frame(height: 200)
                    
                    // Subtitle
                    if showSubtitle {
                        Text("Traditional legal systems favor those with more resources")
                            .font(AppTheme.title3())
                            .foregroundColor(AppTheme.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, AppTheme.spacingXL)
                    }
                }
                
                Spacer()
                
                // Continue button
                Button(action: onContinue) {
                    HStack {
                        Text("See How We Balance Things")
                            .font(AppTheme.headline())
                            .fontWeight(.semibold)
                        
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.title2)
                    }
                }
                .accentButton()
                .padding(.horizontal, AppTheme.spacingXL)
                .padding(.bottom, AppTheme.spacingXXL)
            }
        }
        .onAppear {
            startAnimation()
        }
    }
    
    private func startAnimation() {
        // Start with imbalanced scale
        withAnimation(.easeInOut(duration: 1.0)) {
            scaleRotation = -15
        }
        
        // Show title
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeOut(duration: 0.8)) {
                showTitle = true
            }
        }
        
        // Show subtitle
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.easeOut(duration: 0.8)) {
                showSubtitle = true
            }
        }
        
        // Start pulsing
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            pulseScale = true
        }
        
        // Animate scale imbalance
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                scaleRotation = scaleRotation == -15 ? 15 : -15
            }
        }
    }
}

// MARK: - Balanced Scale View
struct BalancedScaleView: View {
    let onGetStarted: () -> Void
    @State private var animateElements = false
    @State private var scaleRotation: Double = -15
    @State private var showFeatures = false
    
    var body: some View {
        ZStack {
            AppTheme.backgroundGradient
                .ignoresSafeArea()
            
            VStack(spacing: AppTheme.spacingLG) {
                Spacer()
                
                // Balanced Scale Section
                VStack(spacing: AppTheme.spacingMD) {
                    // Title with fade effect
                    Text("MediationAI Brings Balance")
                        .font(AppTheme.largeTitle())
                        .fontWeight(.bold)
                        .foregroundColor(AppTheme.textPrimary)
                        .multilineTextAlignment(.center)
                        .scaleEffect(animateElements ? 1.0 : 0.8)
                        .opacity(animateElements ? 0.9 : 0.0)
                        .animation(.easeInOut(duration: 1.2), value: animateElements)
                    
                    // Balanced Scale
                    ScaleView(
                        leftWeight: 0.5,
                        rightWeight: 0.5,
                        rotation: scaleRotation
                    )
                    .frame(height: 160)
                    
                    // Subtitle with fade effect
                    Text("Fair, Fast, and Affordable Dispute Resolution")
                        .font(AppTheme.title3())
                        .foregroundColor(AppTheme.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, AppTheme.spacingXL)
                        .scaleEffect(animateElements ? 1.0 : 0.8)
                        .opacity(animateElements ? 0.8 : 0.0)
                        .animation(.easeInOut(duration: 1.4), value: animateElements)
                }
                
                // Features Section with fade effects
                if showFeatures {
                    VStack(spacing: AppTheme.spacingMD) {
                        ComparisonCard(
                            icon: "dollarsign.circle.fill",
                            title: "Traditional Lawyers",
                            subtitle: "Thousands",
                            vsTitle: "MediationAI",
                            vsSubtitle: "$1 per party",
                            color: AppTheme.success
                        )
                        .opacity(showFeatures ? 0.9 : 0.0)
                        .animation(.easeInOut(duration: 0.8).delay(0.2), value: showFeatures)
                        
                        ComparisonCard(
                            icon: "clock.fill",
                            title: "Court System",
                            subtitle: "Years",
                            vsTitle: "Our AI",
                            vsSubtitle: "Minutes",
                            color: AppTheme.info
                        )
                        .opacity(showFeatures ? 0.9 : 0.0)
                        .animation(.easeInOut(duration: 0.8).delay(0.4), value: showFeatures)
                        
                        ComparisonCard(
                            icon: "shield.checkered",
                            title: "Biased",
                            subtitle: "Favors resources",
                            vsTitle: "Unbiased",
                            vsSubtitle: "Fair AI",
                            color: AppTheme.accent
                        )
                        .opacity(showFeatures ? 0.9 : 0.0)
                        .animation(.easeInOut(duration: 0.8).delay(0.6), value: showFeatures)
                    }
                    .padding(.horizontal, AppTheme.spacingLG)
                }
                
                Spacer(minLength: AppTheme.spacingLG)
                
                // Get Started Button - Raised position
                Button(action: onGetStarted) {
                    HStack {
                        Text("Get Started")
                            .font(AppTheme.headline())
                            .fontWeight(.semibold)
                        
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.title2)
                    }
                }
                .primaryButton()
                .padding(.horizontal, AppTheme.spacingXL)
                .padding(.bottom, AppTheme.spacingLG)
                .pulseEffect()
                .opacity(showFeatures ? 1.0 : 0.0)
                .animation(.easeInOut(duration: 1.0).delay(1.0), value: showFeatures)
            }
        }
        .onAppear {
            startBalanceAnimation()
        }
    }
    
    private func startBalanceAnimation() {
        // Balance the scale
        withAnimation(.easeInOut(duration: 1.5)) {
            scaleRotation = 0
            animateElements = true
        }
        
        // Show features after scale balances
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.easeOut(duration: 0.8)) {
                showFeatures = true
            }
        }
    }
}

// MARK: - Scale View Component
struct ScaleView: View {
    let leftWeight: CGFloat
    let rightWeight: CGFloat
    let rotation: Double
    
    var body: some View {
        ZStack {
            // Base/Stand
            Rectangle()
                .fill(AppTheme.cardGradient)
                .frame(width: 8, height: 60)
                .cornerRadius(4)
            
            // Scale beam
            Rectangle()
                .fill(AppTheme.glassPrimary)
                .frame(width: 200, height: 4)
                .cornerRadius(2)
                .rotationEffect(.degrees(rotation))
                .overlay(
                    // Center pivot
                    Circle()
                        .fill(AppTheme.primary)
                        .frame(width: 12, height: 12)
                )
            
            // Left scale pan
            VStack {
                // Chain
                Rectangle()
                    .fill(AppTheme.textTertiary)
                    .frame(width: 2, height: 20)
                
                // Pan
                RoundedRectangle(cornerRadius: 8)
                    .fill(AppTheme.cardGradient)
                    .frame(width: 60, height: 8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(AppTheme.textTertiary, lineWidth: 1)
                    )
                    .overlay(
                        // Weight representation
                        HStack(spacing: 2) {
                            ForEach(0..<Int(leftWeight * 10), id: \.self) { _ in
                                Circle()
                                    .fill(AppTheme.error)
                                    .frame(width: 4, height: 4)
                            }
                        }
                    )
            }
            .offset(x: -100, y: CGFloat(rotation) * 1.5)
            
            // Right scale pan
            VStack {
                // Chain
                Rectangle()
                    .fill(AppTheme.textTertiary)
                    .frame(width: 2, height: 20)
                
                // Pan
                RoundedRectangle(cornerRadius: 8)
                    .fill(AppTheme.cardGradient)
                    .frame(width: 60, height: 8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(AppTheme.textTertiary, lineWidth: 1)
                    )
                    .overlay(
                        // Weight representation
                        HStack(spacing: 2) {
                            ForEach(0..<Int(rightWeight * 10), id: \.self) { _ in
                                Circle()
                                    .fill(AppTheme.primary)
                                    .frame(width: 4, height: 4)
                            }
                        }
                    )
            }
            .offset(x: 100, y: CGFloat(-rotation) * 1.5)
        }
    }
}

// MARK: - Comparison Card
struct ComparisonCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let vsTitle: String
    let vsSubtitle: String
    let color: Color
    
    var body: some View {
        HStack(spacing: AppTheme.spacingLG) {
            // Traditional side
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(AppTheme.error)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(AppTheme.caption())
                        .foregroundColor(AppTheme.textSecondary)
                    
                    Text(subtitle)
                        .font(AppTheme.footnote())
                        .foregroundColor(AppTheme.error)
                        .fontWeight(.medium)
                }
            }
            .frame(maxWidth: .infinity)
            
            // VS
            Text("VS")
                .font(AppTheme.caption())
                .foregroundColor(AppTheme.textTertiary)
                .fontWeight(.bold)
            
            // Our solution side
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(color)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(vsTitle)
                        .font(AppTheme.caption())
                        .foregroundColor(AppTheme.textSecondary)
                    
                    Text(vsSubtitle)
                        .font(AppTheme.footnote())
                        .foregroundColor(color)
                        .fontWeight(.medium)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .twitterStyle()
    }
}