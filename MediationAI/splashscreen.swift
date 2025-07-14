//
//  SplashScreen.swift
//  MediationAI
//
//  Created by Linda Alster on 7/14/25.
//

import SwiftUI

struct SplashScreen: View {
    @State private var isLoading = true
    @State private var logoScale: CGFloat = 0.8
    @State private var logoOpacity: Double = 0.0
    @State private var textOpacity: Double = 0.0
    @State private var badgeScale: CGFloat = 0.8
    @State private var progressOpacity: Double = 0.0
    @Binding var showSplash: Bool
    
    var body: some View {
        ZStack {
            // Dynamic gradient background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.05, green: 0.05, blue: 0.15),
                    Color(red: 0.15, green: 0.05, blue: 0.25),
                    Color(red: 0.05, green: 0.15, blue: 0.35),
                    Color(red: 0.1, green: 0.2, blue: 0.4)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .overlay(
                // Subtle animated particles effect
                ForEach(0..<20, id: \.self) { _ in
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 2, height: 2)
                        .position(
                            x: CGFloat.random(in: 0...400),
                            y: CGFloat.random(in: 0...800)
                        )
                        .opacity(0.3)
                }
            )
            
            VStack(spacing: 40) {
                Spacer()
                
                // Logo and App Name Section
                VStack(spacing: 24) {
                    // Enhanced Logo Icon
                    ZStack {
                        // Outer glow effect
                        Circle()
                            .fill(
                                RadialGradient(
                                    gradient: Gradient(colors: [
                                        Color.blue.opacity(0.3),
                                        Color.purple.opacity(0.2),
                                        Color.clear
                                    ]),
                                    center: .center,
                                    startRadius: 50,
                                    endRadius: 80
                                )
                            )
                            .frame(width: 160, height: 160)
                        
                        // Main logo background
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.white.opacity(0.25),
                                        Color.white.opacity(0.15)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 120, height: 120)
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(0.3), lineWidth: 2)
                            )
                        
                        // Scale/Balance icon
                        Image(systemName: "balance.scale")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .foregroundStyle(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.white, Color.blue.opacity(0.8)]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    }
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)
                    
                    // App Name with gradient
                    Text("MediationAI")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.white, Color.blue.opacity(0.9)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .opacity(logoOpacity)
                }
                
                Spacer()
                
                // Enhanced Marketing Message
                VStack(spacing: 20) {
                    VStack(spacing: 12) {
                        Text("Skip Arguments and Legal Fees")
                            .font(.system(size: 26, weight: .bold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .opacity(textOpacity)
                        
                        Text("with our Non-Bias AI")
                            .font(.system(size: 22, weight: .medium))
                            .foregroundStyle(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.white, Color.blue.opacity(0.8)]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .multilineTextAlignment(.center)
                            .opacity(textOpacity)
                    }
                    
                    // Enhanced Coming Soon Badge
                    HStack(spacing: 10) {
                        Image(systemName: "sparkles")
                            .foregroundColor(.yellow)
                            .font(.system(size: 16, weight: .medium))
                        
                        Text("Escrow Coming Soon")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.yellow)
                        
                        Image(systemName: "sparkles")
                            .foregroundColor(.yellow)
                            .font(.system(size: 16, weight: .medium))
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(
                        Capsule()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.yellow.opacity(0.25),
                                        Color.orange.opacity(0.15)
                                    ]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .overlay(
                                Capsule()
                                    .stroke(
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color.yellow, Color.orange]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        ),
                                        lineWidth: 1.5
                                    )
                            )
                    )
                    .scaleEffect(badgeScale)
                    .opacity(textOpacity)
                    .shadow(color: Color.yellow.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .padding(.horizontal, 32)
                
                Spacer()
                
                // Enhanced Loading Section
                VStack(spacing: 16) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.3)
                    
                    Text("Initializing AI Mediation Platform...")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                .opacity(progressOpacity)
                .padding(.bottom, 60)
            }
        }
        .onAppear {
            startAnimations()
            
            // Hide splash after 3.5 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                withAnimation(.easeInOut(duration: 0.6)) {
                    showSplash = false
                }
            }
        }
    }
    
    private func startAnimations() {
        // Logo animation - smooth entrance
        withAnimation(.easeOut(duration: 1.0)) {
            logoScale = 1.0
            logoOpacity = 1.0
        }
        
        // Text animation with staggered delay
        withAnimation(.easeOut(duration: 0.8).delay(0.4)) {
            textOpacity = 1.0
        }
        
        // Badge bounce animation
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0).delay(0.7)) {
            badgeScale = 1.0
        }
        
        // Progress indicator with final delay
        withAnimation(.easeOut(duration: 0.6).delay(1.0)) {
            progressOpacity = 1.0
        }
    }
}

struct SplashScreen_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreen(showSplash: .constant(true))
    }
}