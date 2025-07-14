//
//  ModernAuthSteps.swift
//  MediationAI
//
//  Created by Linda Alster on 7/14/25.
//

import SwiftUI

struct PasswordStepView: View {
    @Binding var password: String
    @Binding var confirmPassword: String
    @Binding var error: String?
    let onNext: () -> Void
    let onBack: () -> Void
    @State private var animateIn = false
    @FocusState private var isPasswordFocused: Bool
    @State private var showPassword = false
    @State private var showConfirmPassword = false
    
    var body: some View {
        VStack(spacing: 32) {
            VStack(spacing: 16) {
                Text("Create a secure password")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .opacity(animateIn ? 1.0 : 0.0)
                
                Text("Your password should be at least 6 characters long to keep your account secure.")
                    .font(.body)
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .opacity(animateIn ? 1.0 : 0.0)
            }
            
            VStack(spacing: 16) {
                // Password field
                HStack {
                    Group {
                        if showPassword {
                            TextField("Enter password", text: $password)
                        } else {
                            SecureField("Enter password", text: $password)
                        }
                    }
                    .textContentType(.newPassword)
                    .font(.title3)
                    .foregroundColor(.white)
                    .focused($isPasswordFocused)
                    
                    Button(action: { showPassword.toggle() }) {
                        Image(systemName: showPassword ? "eye.slash" : "eye")
                            .foregroundColor(.white.opacity(0.6))
                            .font(.title3)
                    }
                }
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
                .scaleEffect(animateIn ? 1.0 : 0.95)
                .opacity(animateIn ? 1.0 : 0.0)
                
                // Confirm password field
                HStack {
                    Group {
                        if showConfirmPassword {
                            TextField("Confirm password", text: $confirmPassword)
                        } else {
                            SecureField("Confirm password", text: $confirmPassword)
                        }
                    }
                    .textContentType(.newPassword)
                    .font(.title3)
                    .foregroundColor(.white)
                    
                    Button(action: { showConfirmPassword.toggle() }) {
                        Image(systemName: showConfirmPassword ? "eye.slash" : "eye")
                            .foregroundColor(.white.opacity(0.6))
                            .font(.title3)
                    }
                }
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
                .scaleEffect(animateIn ? 1.0 : 0.95)
                .opacity(animateIn ? 1.0 : 0.0)
                
                // Password strength indicator
                if !password.isEmpty {
                    PasswordStrengthView(password: password)
                        .opacity(animateIn ? 1.0 : 0.0)
                }
                
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
                .disabled(password.isEmpty || confirmPassword.isEmpty)
                .opacity(password.isEmpty || confirmPassword.isEmpty ? 0.6 : 1.0)
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
                isPasswordFocused = true
            }
        }
    }
}

struct PasswordStrengthView: View {
    let password: String
    
    private var strength: Int {
        var score = 0
        if password.count >= 6 { score += 1 }
        if password.count >= 8 { score += 1 }
        if password.rangeOfCharacter(from: .uppercaseLetters) != nil { score += 1 }
        if password.rangeOfCharacter(from: .decimalDigits) != nil { score += 1 }
        return score
    }
    
    private var strengthText: String {
        switch strength {
        case 0...1: return "Weak"
        case 2: return "Fair"
        case 3: return "Good"
        case 4: return "Strong"
        default: return "Weak"
        }
    }
    
    private var strengthColor: Color {
        switch strength {
        case 0...1: return .red
        case 2: return .orange
        case 3: return .yellow
        case 4: return .green
        default: return .red
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Password Strength:")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                
                Text(strengthText)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(strengthColor)
                
                Spacer()
            }
            
            HStack(spacing: 4) {
                ForEach(0..<4, id: \.self) { index in
                    Rectangle()
                        .fill(index < strength ? strengthColor : Color.white.opacity(0.3))
                        .frame(height: 4)
                        .cornerRadius(2)
                }
            }
        }
        .padding(.horizontal, 4)
    }
}

struct LegalStepView: View {
    let onCreateAccount: () -> Void
    let onShowPrivacy: () -> Void
    let onShowTerms: () -> Void
    let onBack: () -> Void
    @State private var animateIn = false
    
    var body: some View {
        VStack(spacing: 32) {
            VStack(spacing: 16) {
                Text("Almost there! 🎉")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .opacity(animateIn ? 1.0 : 0.0)
                
                Text("By creating your account, you're joining thousands of users who've resolved disputes quickly and fairly with AI.")
                    .font(.body)
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .opacity(animateIn ? 1.0 : 0.0)
            }
            
            VStack(spacing: 20) {
                // Benefits list
                VStack(spacing: 16) {
                    BenefitRow(
                        icon: "dollarsign.circle.fill",
                        title: "Save Money",
                        subtitle: "Skip expensive legal fees"
                    )
                    .opacity(animateIn ? 1.0 : 0.0)
                    
                    BenefitRow(
                        icon: "clock.fill",
                        title: "Save Time",
                        subtitle: "Get resolutions in minutes, not months"
                    )
                    .opacity(animateIn ? 1.0 : 0.0)
                    
                    BenefitRow(
                        icon: "brain.head.profile",
                        title: "AI-Powered",
                        subtitle: "Unbiased, intelligent dispute resolution"
                    )
                    .opacity(animateIn ? 1.0 : 0.0)
                }
                
                // Legal agreement
                VStack(spacing: 12) {
                    Text("By creating your account, you agree to our:")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .opacity(animateIn ? 1.0 : 0.0)
                    
                    HStack(spacing: 8) {
                        Button(action: onShowTerms) {
                            Text("Terms of Service")
                                .font(.caption)
                                .foregroundColor(.blue.opacity(0.8))
                                .underline()
                        }
                        
                        Text("and")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                        
                        Button(action: onShowPrivacy) {
                            Text("Privacy Policy")
                                .font(.caption)
                                .foregroundColor(.blue.opacity(0.8))
                                .underline()
                        }
                    }
                    .opacity(animateIn ? 1.0 : 0.0)
                }
            }
            
            VStack(spacing: 12) {
                Button(action: onCreateAccount) {
                    HStack {
                        Text("Create My Account")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Image(systemName: "checkmark")
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.green, Color.blue]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundColor(.white)
                    .cornerRadius(16)
                    .shadow(color: Color.green.opacity(0.3), radius: 8, x: 0, y: 4)
                }
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
        }
    }
}

struct BenefitRow: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.blue, Color.purple]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.body)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

struct SignInStepView: View {
    @Binding var email: String
    @Binding var password: String
    @Binding var error: String?
    let onSignIn: () -> Void
    let onBack: () -> Void
    let onForgotPassword: () -> Void
    @State private var animateIn = false
    @FocusState private var isEmailFocused: Bool
    @State private var showPassword = false
    
    var body: some View {
        VStack(spacing: 32) {
            VStack(spacing: 16) {
                Text("Welcome back! 👋")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .opacity(animateIn ? 1.0 : 0.0)
                
                Text("Sign in to your account to continue resolving disputes with AI.")
                    .font(.body)
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .opacity(animateIn ? 1.0 : 0.0)
            }
            
            VStack(spacing: 16) {
                // Email field
                TextField("Email", text: $email)
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
                
                // Password field
                HStack {
                    Group {
                        if showPassword {
                            TextField("Password", text: $password)
                        } else {
                            SecureField("Password", text: $password)
                        }
                    }
                    .textContentType(.password)
                    .font(.title3)
                    .foregroundColor(.white)
                    
                    Button(action: { showPassword.toggle() }) {
                        Image(systemName: showPassword ? "eye.slash" : "eye")
                            .foregroundColor(.white.opacity(0.6))
                            .font(.title3)
                    }
                }
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
                .scaleEffect(animateIn ? 1.0 : 0.95)
                .opacity(animateIn ? 1.0 : 0.0)
                
                // Forgot password
                HStack {
                    Spacer()
                    Button(action: onForgotPassword) {
                        Text("Forgot password?")
                            .font(.body)
                            .foregroundColor(.blue.opacity(0.8))
                    }
                }
                .opacity(animateIn ? 1.0 : 0.0)
                
                if let error = error {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red.opacity(0.8))
                        .padding(.horizontal, 4)
                }
            }
            
            VStack(spacing: 12) {
                Button(action: onSignIn) {
                    HStack {
                        Text("Sign In")
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
                .disabled(email.isEmpty || password.isEmpty)
                .opacity(email.isEmpty || password.isEmpty ? 0.6 : 1.0)
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