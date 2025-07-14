//
//  OnboardingView.swift
//  MediationAI
//
//  Created by Linda Alster on 7/14/25.
//


import SwiftUI

struct OnboardingView: View {
    @State private var showAuth = false
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            Image(systemName: "scalemass")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundStyle(AppTheme.mainGradient)
                .padding()
                .background(AppTheme.card)
                .clipShape(Circle())
                .shadow(radius: 10)
            
            Text("Welcome to MediationAI")
                .font(AppTheme.titleFont())
                .foregroundColor(AppTheme.primary)
                .multilineTextAlignment(.center)
            
            Text("AI-powered dispute resolution for everyone. Fair, fast, and easy.")
                .font(AppTheme.subtitleFont())
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Spacer()
            
            Button(action: { showAuth = true }) {
                Text("Get Started")
                    .font(AppTheme.buttonFont())
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppTheme.mainGradient)
                    .foregroundColor(.white)
                    .cornerRadius(16)
                    .shadow(radius: 5)
            }
            .padding(.horizontal)
            .fullScreenCover(isPresented: $showAuth) {
                AuthView()
            }
            
            Spacer()
        }
        .padding()
        .background(AppTheme.background.ignoresSafeArea())
    }
}
