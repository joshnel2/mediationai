//
//  AuthView.swift
//  MediationAI
//
//  Created by Linda Alster on 7/14/25.
//


import SwiftUI

struct AuthView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authService: MockAuthService
    @State private var isSignUp = true
    @State private var email = ""
    @State private var password = ""
    @State private var error: String?
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            Text(isSignUp ? "Create Account" : "Sign In")
                .font(AppTheme.titleFont())
                .foregroundColor(AppTheme.primary)
            
            VStack(spacing: 20) {
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding()
                    .background(AppTheme.card)
                    .cornerRadius(12)
                    .shadow(radius: 2)
                
                SecureField("Password", text: $password)
                    .padding()
                    .background(AppTheme.card)
                    .cornerRadius(12)
                    .shadow(radius: 2)
            }
            .padding(.horizontal)
            
            if let error = error {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
            }
            
            Button(action: handleAuth) {
                Text(isSignUp ? "Sign Up" : "Sign In")
                    .font(AppTheme.buttonFont())
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppTheme.mainGradient)
                    .foregroundColor(.white)
                    .cornerRadius(16)
                    .shadow(radius: 5)
            }
            .padding(.horizontal)
            
            Button(action: { isSignUp.toggle() }) {
                Text(isSignUp ? "Already have an account? Sign In" : "Don't have an account? Sign Up")
                    .font(.footnote)
                    .foregroundColor(AppTheme.primary)
            }
            
            Spacer()
            Button("Back") { dismiss() }
                .foregroundColor(.gray)
                .padding(.bottom)
        }
        .background(AppTheme.background.ignoresSafeArea())
    }
    
    func handleAuth() {
        error = nil
        if email.isEmpty || password.isEmpty {
            error = "Please fill in all fields."
            return
        }
        if isSignUp {
            if !authService.signUp(email: email, password: password) {
                error = "Email already in use."
            }
        } else {
            if !authService.signIn(email: email, password: password) {
                error = "Invalid credentials."
            }
        }
    }
}
