//
//  AuthView.swift
//  MediationAI
//
//  Created by Linda Alster on 7/14/25.
//

import SwiftUI

struct AuthView: View {
    @EnvironmentObject var authService: MockAuthService
    @State private var email = ""
    @State private var password = ""
    @State private var isSignUp = false
    @State private var error: String?
    @State private var showPrivacyPolicy = false
    @State private var showTermsOfService = false
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Logo and Title
            VStack(spacing: 16) {
                Image(systemName: "balance.scale")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundStyle(AppTheme.mainGradient)
                
                Text("MediationAI")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(AppTheme.primary)
                
                Text(isSignUp ? "Create your account" : "Sign in to continue")
                    .font(.body)
                    .foregroundColor(.gray)
            }
            
            // Form
            VStack(spacing: 16) {
                TextField("Email", text: $email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding()
                    .background(AppTheme.card)
                    .cornerRadius(12)
                    .shadow(radius: 2)
                
                SecureField("Password", text: $password)
                    .textContentType(isSignUp ? .newPassword : .password)
                    .padding()
                    .background(AppTheme.card)
                    .cornerRadius(12)
                    .shadow(radius: 2)
                
                if let error = error {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
                Button(action: handleAuth) {
                    Text(isSignUp ? "Create Account" : "Sign In")
                        .font(AppTheme.buttonFont())
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppTheme.mainGradient)
                        .foregroundColor(.white)
                        .cornerRadius(16)
                }
                .padding(.top)
            }
            .padding(.horizontal)
            
            // Legal Compliance for Sign Up
            if isSignUp {
                VStack(spacing: 12) {
                    Text("By creating an account, you agree to our")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                    
                    HStack(spacing: 4) {
                        Button("Terms of Service") {
                            showTermsOfService = true
                        }
                        .font(.caption)
                        .foregroundColor(AppTheme.primary)
                        
                        Text("and")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        Button("Privacy Policy") {
                            showPrivacyPolicy = true
                        }
                        .font(.caption)
                        .foregroundColor(AppTheme.primary)
                    }
                }
                .padding(.horizontal)
            }
            
            Spacer()
            
            // Toggle Sign In/Up
            Button(action: { isSignUp.toggle() }) {
                HStack {
                    Text(isSignUp ? "Already have an account?" : "Don't have an account?")
                        .foregroundColor(.gray)
                    Text(isSignUp ? "Sign In" : "Sign Up")
                        .foregroundColor(AppTheme.primary)
                        .fontWeight(.medium)
                }
                .font(.body)
            }
            .padding(.bottom)
        }
        .background(AppTheme.background.ignoresSafeArea())
        .sheet(isPresented: $showPrivacyPolicy) {
            PrivacyPolicyView()
        }
        .sheet(isPresented: $showTermsOfService) {
            TermsOfServiceView()
        }
    }
    
    func handleAuth() {
        error = nil
        
        guard !email.isEmpty, !password.isEmpty else {
            error = "Please fill in all fields."
            return
        }
        
        guard email.contains("@") else {
            error = "Please enter a valid email address."
            return
        }
        
        guard password.count >= 6 else {
            error = "Password must be at least 6 characters."
            return
        }
        
        if isSignUp {
            Task {
                let success = await authService.signUp(email: email, password: password)
                await MainActor.run {
                    if !success {
                        error = "Email already exists. Try signing in instead."
                    }
                }
            }
        } else {
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
}
