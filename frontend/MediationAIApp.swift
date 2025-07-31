//
//  MediationAIApp.swift
//  MediationAI
//
//  Created by Linda Alster on 7/14/25.
//


import SwiftUI

@main
struct MediationAIApp: App {
    init() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.titleTextAttributes = [.foregroundColor: UIColor.label]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.label]
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
    @UIApplicationDelegateAdaptor(PushDelegate.self) var pushDelegate
    @StateObject var authService = MockAuthService()
    @StateObject var disputeService = MockDisputeService()
    @StateObject var purchaseService = InAppPurchaseService()
    @StateObject var badgeService = BadgeService()
    @StateObject var viralService = ViralAPIService.shared
    @StateObject var socialService = SocialAPIService()
    @StateObject var featureFlags = FeatureFlags.shared

    // Persistent appearance mode: "system", "light", "dark"
    @AppStorage("appearanceMode") private var appearanceMode: String = "system"

    private var preferredScheme: ColorScheme? {
        switch appearanceMode {
        case "light": return .light
        case "dark": return .dark
        default: return nil // system setting
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(authService)
                .environmentObject(disputeService)
                .environmentObject(purchaseService)
                .environmentObject(badgeService)
                .environmentObject(viralService)
                .environmentObject(socialService)
                .environmentObject(featureFlags)
                .preferredColorScheme(preferredScheme)
        }
    }
}
