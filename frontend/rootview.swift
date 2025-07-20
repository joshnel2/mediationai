//
//  RootView.swift
//  MediationAI
//
//  Created by Linda Alster on 7/14/25.
//

import SwiftUI
import LocalAuthentication

struct RootView: View {
    @EnvironmentObject var authService: MockAuthService
    @State private var showSplash = true
    
    var body: some View {
        ZStack {
            // Background gradient
            AppTheme.backgroundGradient
                .ignoresSafeArea()
            
            Group {
                if showSplash {
                    SplashScreen(showSplash: $showSplash)
                } else {
                    // Main app content
                    Group {
                        if authService.currentUser == nil {
                            OnboardingView()
                        } else {
                            HomeView()
                                .onAppear(perform: authenticate)
                        }
                    }
                    .transition(.opacity.combined(with: .scale))
                }
            }
        }
        .animation(.easeInOut(duration: 0.5), value: showSplash)
    }

    private func authenticate() {
        // Only attempt once per launch
        guard UserDefaults.standard.bool(forKey: "faceIDEnabled") else { return }
        let context = LAContext()
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Unlock MediationAI") { success, _ in
                if !success {
                    // Log or handle fallback – for beta we ignore
                }
            }
        }
    }
}
