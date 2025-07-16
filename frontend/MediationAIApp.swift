//
//  MediationAIApp.swift
//  MediationAI
//
//  Created by Linda Alster on 7/14/25.
//


import SwiftUI

@main
struct MediationAIApp: App {
    @StateObject var authService = MockAuthService()
    @StateObject var disputeService = MockDisputeService()

    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(authService)
                .environmentObject(disputeService)

        }
    }
}
