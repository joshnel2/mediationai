//
//  RootView.swift
//  meidationaiapp
//
//  Created by Linda Alster on 7/14/25.
//


import SwiftUI

struct RootView: View {
    @EnvironmentObject var authService: MockAuthService
    
    var body: some View {
        Group {
            if authService.currentUser == nil {
                OnboardingView()
            } else {
                HomeView()
            }
        }
        .background(AppTheme.background.ignoresSafeArea())
    }
}
