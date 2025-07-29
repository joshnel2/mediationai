//
//  MediationAIApp.swift
//  MediationAI
//
//  Created by Linda Alster on 7/14/25.
//


import SwiftUI

@main
struct MediationAIApp: App {
    @UIApplicationDelegateAdaptor(PushDelegate.self) var pushDelegate
    @StateObject var authService = MockAuthService()
    @StateObject var disputeService = MockDisputeService()
    @StateObject var purchaseService = InAppPurchaseService()
    @StateObject var badgeService = BadgeService()
    @StateObject var viralService = ViralAPIService.shared
    @StateObject var socialService = SocialAPIService()

    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(authService)
                .environmentObject(disputeService)
                .environmentObject(purchaseService)
                .environmentObject(badgeService)
                .environmentObject(viralService)
                .environmentObject(socialService)
                .preferredColorScheme(.light)
        }
    }
}
