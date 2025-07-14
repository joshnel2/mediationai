//
//  RootView.swift
//  MediationAI
//
//  Created by Linda Alster on 7/14/25.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject var authService: MockAuthService
    @State private var showSplash = true
    
    var body: some View {
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
                    }
                }
                .background(AppTheme.background.ignoresSafeArea())
                .transition(.opacity.combined(with: .scale))
            }
        }
        .animation(.easeInOut(duration: 0.5), value: showSplash)
    }
}
