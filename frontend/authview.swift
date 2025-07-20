//
//  AuthView.swift
//  MediationAI
//
//  Created by Linda Alster on 7/14/25.
//

import SwiftUI
#if canImport(FirebaseAuth)
import FirebaseAuth
#endif

struct AuthView: View {
    @EnvironmentObject var authService: MockAuthService
    @State private var phone = ""
    @State private var code = ""
    @State private var displayName = ""
    enum Step { case enterPhone, enterCode }
    @State private var step: Step = .enterPhone
    @State private var error: String?
    @State private var showPrivacyPolicy = false
    @State private var showTermsOfService = false
    @State private var verificationID: String?
    
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
                
                Text(step == .enterPhone ? "Enter your phone" : "Verify your code")
                    .font(.body)
                    .foregroundColor(.gray)
            }
            
            // Form
            VStack(spacing: 16) {
                if step == .enterPhone {
                    TextField("Phone (+1...)", text: $phone)
                        .keyboardType(.phonePad)
                        .padding()
                        .background(AppTheme.card)
                        .cornerRadius(12)
                        .shadow(radius: 2)
                } else {
                    TextField("6-digit Code", text: $code)
                        .keyboardType(.numberPad)
                        .padding()
                        .background(AppTheme.card)
                        .cornerRadius(12)
                        .shadow(radius: 2)
                    TextField("Your Name", text: $displayName)
                        .padding()
                        .background(AppTheme.card)
                        .cornerRadius(12)
                        .shadow(radius: 2)
                }
                
                if let error = error {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
                Button(action: handleAuth) {
                    Text(step == .enterPhone ? "Send Code" : "Continue")
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
            
            // Legal footer stays the same but always visible
            VStack(spacing: 12) {
                Text("By joining, you agree to our")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                HStack(spacing: 4) {
                    Button("Terms of Service") { showTermsOfService = true }
                        .font(.caption)
                        .foregroundColor(AppTheme.primary)
                    Text("and").font(.caption).foregroundColor(.gray)
                    Button("Privacy Policy") { showPrivacyPolicy = true }
                        .font(.caption)
                        .foregroundColor(AppTheme.primary)
                }
            }
            
            Spacer(minLength: 20)
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
        switch step {
        case .enterPhone:
            guard !phone.isEmpty else { error = "Enter phone"; return }
#if canImport(FirebaseAuth)
            PhoneAuthProvider.provider()
                .verifyPhoneNumber(phone, uiDelegate: nil) { verID, err in
                    if let err = err {
                        error = err.localizedDescription
                        return
                    }
                    verificationID = verID
                    step = .enterCode
                }
#else
            error = "FirebaseAuth SDK not available"
#endif
        case .enterCode:
            guard !code.isEmpty, !displayName.isEmpty else { error = "Fill all fields"; return }
            guard let verID = verificationID else { error = "Missing verification ID"; return }
#if canImport(FirebaseAuth)
            let credential = PhoneAuthProvider.provider().credential(withVerificationID: verID, verificationCode: code)
            Auth.auth().signIn(with: credential) { result, err in
                if let err = err { error = err.localizedDescription; return }
                result?.user.getIDToken(completion: { token, _ in
                    guard let token = token else { error = "Token error"; return }
                    Task {
                        let ok = await authService.firebaseSignUp(idToken: token, displayName: displayName)
                        await MainActor.run { if !ok { error = "Signup failed" } }
                    }
                })
            }
#else
            error = "FirebaseAuth SDK not available"
#endif
        }
    }
}
