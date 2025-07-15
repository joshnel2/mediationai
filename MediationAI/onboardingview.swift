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