//
//  MediationAIApp.swift
//  MediationAI
//
//  Created by Linda Alster on 7/14/25.
//

import SwiftUI
import UserNotifications

@main
struct MediationAIApp: App {
    @StateObject var authService = MockAuthService()
    @StateObject var disputeService = MockDisputeService()
    @StateObject var purchaseService = InAppPurchaseService()
    @StateObject var notificationService = NotificationService()
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(authService)
                .environmentObject(disputeService)
                .environmentObject(purchaseService)
                .environmentObject(notificationService)
                .onAppear {
                    // Request notification permission on app launch
                    Task {
                        await notificationService.requestPermission()
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                    // Update badge count when app becomes active
                    notificationService.updateBadgeCount()
                }
        }
    }
}

// MARK: - App Delegate for Push Notifications

class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Configure notification categories
        configureNotificationCategories()
        return true
    }
    
    // Handle successful device token registration
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        print("Successfully registered for remote notifications")
        
        // Get the notification service from the scene
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootView = window.rootViewController?.view,
           let notificationService = findNotificationService(in: rootView) {
            notificationService.setDeviceToken(deviceToken)
        }
    }
    
    // Handle failed device token registration
    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("Failed to register for remote notifications: \(error)")
    }
    
    // Handle remote notification received when app is in background
    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        print("Received remote notification: \(userInfo)")
        
        // Create notification item from received data
        if let title = userInfo["aps"] as? [String: Any],
           let alert = title["alert"] as? [String: Any],
           let titleText = alert["title"] as? String,
           let body = alert["body"] as? String {
            
            let notificationItem = NotificationItem(
                id: UUID().uuidString,
                title: titleText,
                message: body,
                type: NotificationType.from(userInfo: userInfo),
                timestamp: Date(),
                isRead: false
            )
            
            // Add to notification service if available
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first,
               let rootView = window.rootViewController?.view,
               let notificationService = findNotificationService(in: rootView) {
                notificationService.addNotification(notificationItem)
                notificationService.updateBadgeCount()
            }
        }
        
        completionHandler(.newData)
    }
    
    private func configureNotificationCategories() {
        // Define notification actions
        let replyAction = UNTextInputNotificationAction(
            identifier: "REPLY_ACTION",
            title: "Reply",
            options: [],
            textInputButtonTitle: "Send",
            textInputPlaceholder: "Type your response..."
        )
        
        let viewAction = UNNotificationAction(
            identifier: "VIEW_ACTION",
            title: "View Dispute",
            options: [.foreground]
        )
        
        let dismissAction = UNNotificationAction(
            identifier: "DISMISS_ACTION",
            title: "Dismiss",
            options: []
        )
        
        // Create categories
        let disputeCategory = UNNotificationCategory(
            identifier: "DISPUTE_UPDATE",
            actions: [replyAction, viewAction, dismissAction],
            intentIdentifiers: [],
            options: []
        )
        
        let resolutionCategory = UNNotificationCategory(
            identifier: "RESOLUTION",
            actions: [viewAction, dismissAction],
            intentIdentifiers: [],
            options: []
        )
        
        // Register categories
        UNUserNotificationCenter.current().setNotificationCategories([
            disputeCategory,
            resolutionCategory
        ])
    }
    
    private func findNotificationService(in view: UIView) -> NotificationService? {
        // This is a simplified approach - in a real app you might use a different method
        // to access the notification service from the app delegate
        return nil
    }
}
