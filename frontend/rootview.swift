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
    @EnvironmentObject var disputeService: MockDisputeService
    @EnvironmentObject var notificationService: NotificationService
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
                                .onAppear {
                                    authenticate()
                                    setupNotificationIntegration()
                                }
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
    
    private func setupNotificationIntegration() {
        // Connect notification service to dispute service
        if let realDisputeService = disputeService as? RealDisputeService {
            realDisputeService.setNotificationService(notificationService)
        }
        
        // Listen for navigation notifications
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("NavigateToDispute"),
            object: nil,
            queue: .main
        ) { notification in
            if let disputeId = notification.userInfo?["dispute_id"] as? String {
                // Handle navigation to specific dispute
                print("Navigate to dispute: \(disputeId)")
                // You can implement navigation logic here
            }
        }
    }
}
