//
//  ModernAuthView.swift
//  MediationAI
//
//  Created by Linda Alster on 7/14/25.
//

import SwiftUI

struct ModernAuthView: View {
    @EnvironmentObject var authService: MockAuthService
    @State private var currentStep: AuthStep = .welcome
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isSignUp = true
    @State private var error: String?
    @State private var showPrivacyPolicy = false
    @State private var showTermsOfService = false
    @State private var animateElements = false
    
    enum AuthStep {
        case welcome
        case email
        case password
        case legal
        case signIn
    }
    
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
            
            // Content
            VStack(spacing: 0) {
                // Progress indicator for sign-up
                if isSignUp && currentStep != .welcome && currentStep != .signIn {
                    ProgressBar(currentStep: currentStep)
                        .padding(.top, 60)
                        .padding(.horizontal, 32)
                }
                
                Spacer()
                
                // Main content area
                VStack(spacing: 32) {
                    switch currentStep {
                    case .welcome:
                        WelcomeStepView(
                            onSignUp: { 
                                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                    isSignUp = true
                                    currentStep = .email
                                    // Clear form data when switching modes
                                    email = ""
                                    password = ""
                                    confirmPassword = ""
                                    error = nil
                                }
                            },
                            onSignIn: {
                                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                    isSignUp = false
                                    currentStep = .signIn
                                    // Clear form data when switching modes
                                    email = ""
                                    password = ""
                                    confirmPassword = ""
                                    error = nil
                                }
                            }
                        )
                        
                    case .email:
                        EmailStepView(
                            email: $email,
                            error: $error,
                            onNext: { 
                                if isValidEmail(email) {
                                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                        currentStep = .password
                                    }
                                } else {
                                    error = "Please enter a valid email address"
                                }
                            },
                            onBack: {
                                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                    currentStep = .welcome
                                    // Clear form data when going back to welcome
                                    email = ""
                                    password = ""
                                    confirmPassword = ""
                                    error = nil
                                }
                            }
                        )
                        
                    case .password:
                        PasswordStepView(
                            password: $password,
                            confirmPassword: $confirmPassword,
                            error: $error,
                            onNext: {
                                if password.count >= 6 {
                                    if password == confirmPassword {
                                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                            currentStep = .legal
                                        }
                                    } else {
                                        error = "Passwords don't match"
                                    }
                                } else {
                                    error = "Password must be at least 6 characters"
                                }
                            },
                            onBack: {
                                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                    currentStep = .email
                                }
                            }
                        )
                        
                    case .legal:
                        LegalStepView(
                            onCreateAccount: { handleSignUp() },
                            onShowPrivacy: { showPrivacyPolicy = true },
                            onShowTerms: { showTermsOfService = true },
                            onBack: {
                                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                    currentStep = .password
                                }
                            }
                        )
                        
                    case .signIn:
                        SignInStepView(
                            email: $email,
                            password: $password,
                            error: $error,
                            onSignIn: { handleSignIn() },
                            onBack: {
                                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                    currentStep = .welcome
                                    // Clear form data when going back to welcome
                                    email = ""
                                    password = ""
                                    confirmPassword = ""
                                    error = nil
                                }
                            },
                            onForgotPassword: { /* Handle forgot password */ }
                        )
                    }
                }
                .padding(.horizontal, 32)
                
                Spacer()
                Spacer()
            }
        }
        .sheet(isPresented: $showPrivacyPolicy) {
            PrivacyPolicyView()
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
    
    private func isValidEmail(_ email: String) -> Bool {
        email.contains("@") && email.contains(".") && email.count > 5
    }
    
    private func handleSignUp() {
        error = nil
        Task {
            let success = await authService.signUp(email: email, password: password)
            await MainActor.run {
                if !success {
                    error = "Email already exists. Try signing in instead."
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        currentStep = .email
                    }
                }
            }
        }
    }
    
    private func handleSignIn() {
        error = nil
        Task {
            let success = await authService.signIn(email: email, password: password)
            await MainActor.run {
                if !success {
                    error = "Invalid email or password."
                }
            }
        }
    }
}

struct ProgressBar: View {
    let currentStep: ModernAuthView.AuthStep
    
    private var progress: CGFloat {
        switch currentStep {
        case .welcome: return 0.0
        case .email: return 0.33
        case .password: return 0.66
        case .legal: return 1.0
        case .signIn: return 0.0
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Step \(Int(progress * 3) + 1) of 3")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                Spacer()
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.white.opacity(0.2))
                        .frame(height: 4)
                        .cornerRadius(2)
                    
                    Rectangle()
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [Color.blue, Color.purple]),
                            startPoint: .leading,
                            endPoint: .trailing
                        ))
                        .frame(width: geometry.size.width * progress, height: 4)
                        .cornerRadius(2)
                        .animation(.spring(response: 0.8, dampingFraction: 0.8), value: progress)
                }
            }
            .frame(height: 4)
        }
    }
}

struct WelcomeStepView: View {
    let onSignUp: () -> Void
    let onSignIn: () -> Void
    @State private var animateText = false
    @State private var animateButtons = false
    
    var body: some View {
        VStack(spacing: 40) {
            VStack(spacing: 24) {
                // App logo with animation
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    Color.blue.opacity(0.3),
                                    Color.purple.opacity(0.2),
                                    Color.clear
                                ]),
                                center: .center,
                                startRadius: 40,
                                endRadius: 80
                            )
                        )
                        .frame(width: 120, height: 120)
                        .scaleEffect(animateText ? 1.0 : 0.8)
                    
                    Image(systemName: "balance.scale")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        .foregroundStyle(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.white, Color.blue.opacity(0.8)]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .scaleEffect(animateText ? 1.0 : 0.8)
                }
                
                VStack(spacing: 16) {
                    Text("Welcome to")
                        .font(.title2)
                        .foregroundColor(.white.opacity(0.8))
                        .opacity(animateText ? 1.0 : 0.0)
                    
                    Text("MediationAI")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.white, Color.blue.opacity(0.9)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .opacity(animateText ? 1.0 : 0.0)
                    
                    Text("Skip arguments and legal fees with AI-powered dispute resolution")
                        .font(.title3)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .opacity(animateText ? 1.0 : 0.0)
                }
            }
            
            VStack(spacing: 16) {
                Button(action: onSignUp) {
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
                .scaleEffect(animateButtons ? 1.0 : 0.9)
                .opacity(animateButtons ? 1.0 : 0.0)
                
                Button(action: onSignIn) {
                    Text("I already have an account")
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.white.opacity(0.8))
                }
                .scaleEffect(animateButtons ? 1.0 : 0.9)
                .opacity(animateButtons ? 1.0 : 0.0)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                animateText = true
            }
            withAnimation(.easeOut(duration: 0.8).delay(0.3)) {
                animateButtons = true
            }
        }
    }
}

struct EmailStepView: View {
    @Binding var email: String
    @Binding var error: String?
    let onNext: () -> Void
    let onBack: () -> Void
    @State private var animateIn = false
    @FocusState private var isEmailFocused: Bool
    
    var body: some View {
        VStack(spacing: 32) {
            VStack(spacing: 16) {
                Text("What's your email?")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .opacity(animateIn ? 1.0 : 0.0)
                
                Text("We'll use this to create your account and send you important updates about your disputes.")
                    .font(.body)
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .opacity(animateIn ? 1.0 : 0.0)
            }
            
            VStack(spacing: 16) {
                TextField("Enter your email", text: $email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
                    .font(.title3)
                    .padding(.vertical, 20)
                    .padding(.horizontal, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                    )
                    .foregroundColor(.white)
                    .focused($isEmailFocused)
                    .scaleEffect(animateIn ? 1.0 : 0.95)
                    .opacity(animateIn ? 1.0 : 0.0)
                
                if let error = error {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red.opacity(0.8))
                        .padding(.horizontal, 4)
                }
            }
            
            VStack(spacing: 12) {
                Button(action: onNext) {
                    HStack {
                        Text("Continue")
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
                .disabled(email.isEmpty)
                .opacity(email.isEmpty ? 0.6 : 1.0)
                .scaleEffect(animateIn ? 1.0 : 0.95)
                .opacity(animateIn ? 1.0 : 0.0)
                
                Button(action: onBack) {
                    HStack {
                        Image(systemName: "chevron.left")
                            .font(.body)
                        Text("Back")
                            .font(.body)
                    }
                    .foregroundColor(.white.opacity(0.8))
                }
                .scaleEffect(animateIn ? 1.0 : 0.95)
                .opacity(animateIn ? 1.0 : 0.0)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                animateIn = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                isEmailFocused = true
            }
        }
    }
}

// I'll continue with the other step views in the next part...
struct ModernAuthView_Previews: PreviewProvider {
    static var previews: some View {
        ModernAuthView()
            .environmentObject(MockAuthService())
    }
}