//
//  NotificationService.swift
//  MediationAI
//
//  Created by AI Assistant on 1/27/25.
//

import SwiftUI
import UserNotifications
import UIKit

@MainActor
class NotificationService: NSObject, ObservableObject {
    @Published var isAuthorized = false
    @Published var authorizationStatus: UNAuthorizationStatus = .notDetermined
    @Published var deviceToken: String?
    @Published var notifications: [NotificationItem] = []
    
    private let center = UNUserNotificationCenter.current()
    
    override init() {
        super.init()
        center.delegate = self
        checkAuthorizationStatus()
        loadStoredNotifications()
    }
    
    // MARK: - Authorization
    
    func requestPermission() async {
        do {
            let granted = try await center.requestAuthorization(
                options: [.alert, .badge, .sound, .provisional]
            )
            
            await MainActor.run {
                self.isAuthorized = granted
                if granted {
                    UIApplication.shared.registerForRemoteNotifications()
                }
                checkAuthorizationStatus()
            }
        } catch {
            print("Error requesting notification permission: \(error)")
        }
    }
    
    func checkAuthorizationStatus() {
        center.getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.authorizationStatus = settings.authorizationStatus
                self.isAuthorized = settings.authorizationStatus == .authorized || 
                                   settings.authorizationStatus == .provisional
            }
        }
    }
    
    // MARK: - Device Token Management
    
    func setDeviceToken(_ tokenData: Data) {
        let token = tokenData.map { String(format: "%02.2hhx", $0) }.joined()
        self.deviceToken = token
        
        // Store token locally
        UserDefaults.standard.set(token, forKey: "device_token")
        
        // Send to backend
        Task {
            await registerDeviceToken(token)
        }
    }
    
    private func registerDeviceToken(_ token: String) async {
        guard let url = URL(string: "\(APIConfig.baseURL)/api/users/device-token") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add auth token if available
        if let authToken = UserDefaults.standard.string(forKey: "auth_token") {
            request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        }
        
        let payload = [
            "device_token": token,
            "platform": "ios"
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload)
            let (_, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                print("Device token registration status: \(httpResponse.statusCode)")
            }
        } catch {
            print("Error registering device token: \(error)")
        }
    }
    
    // MARK: - Local Notifications
    
    func scheduleLocalNotification(
        id: String,
        title: String,
        body: String,
        timeInterval: TimeInterval = 5,
        userInfo: [String: Any] = [:]
    ) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.userInfo = userInfo
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        
        center.add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
    
    // MARK: - Notification Management
    
    func addNotification(_ notification: NotificationItem) {
        notifications.insert(notification, at: 0)
        saveNotifications()
    }
    
    func markAsRead(_ notificationId: String) {
        if let index = notifications.firstIndex(where: { $0.id == notificationId }) {
            notifications[index].isRead = true
            saveNotifications()
        }
    }
    
    func markAllAsRead() {
        for index in notifications.indices {
            notifications[index].isRead = true
        }
        saveNotifications()
    }
    
    func removeNotification(_ notificationId: String) {
        notifications.removeAll { $0.id == notificationId }
        saveNotifications()
    }
    
    func clearAllNotifications() {
        notifications.removeAll()
        saveNotifications()
        
        // Also clear from notification center
        center.removeAllDeliveredNotifications()
    }
    
    // MARK: - Persistence
    
    private func saveNotifications() {
        if let data = try? JSONEncoder().encode(notifications) {
            UserDefaults.standard.set(data, forKey: "stored_notifications")
        }
    }
    
    private func loadStoredNotifications() {
        guard let data = UserDefaults.standard.data(forKey: "stored_notifications"),
              let notifications = try? JSONDecoder().decode([NotificationItem].self, from: data) else {
            return
        }
        self.notifications = notifications
    }
    
    // MARK: - Badge Management
    
    func updateBadgeCount() {
        let unreadCount = notifications.filter { !$0.isRead }.count
        UIApplication.shared.applicationIconBadgeNumber = unreadCount
    }
    
    func clearBadge() {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension NotificationService: UNUserNotificationCenterDelegate {
    
    // Handle notification when app is in foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Create notification item from received notification
        let userInfo = notification.request.content.userInfo
        let notificationItem = NotificationItem(
            id: notification.request.identifier,
            title: notification.request.content.title,
            message: notification.request.content.body,
            type: NotificationType.from(userInfo: userInfo),
            timestamp: Date(),
            isRead: false
        )
        
        addNotification(notificationItem)
        updateBadgeCount()
        
        // Show notification even when app is in foreground
        completionHandler([.banner, .sound, .badge])
    }
    
    // Handle notification tap
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        
        // Handle notification tap based on type
        if let disputeId = userInfo["dispute_id"] as? String {
            // Navigate to dispute
            NotificationCenter.default.post(
                name: NSNotification.Name("NavigateToDispute"),
                object: nil,
                userInfo: ["dispute_id": disputeId]
            )
        }
        
        // Mark as read
        markAsRead(response.notification.request.identifier)
        updateBadgeCount()
        
        completionHandler()
    }
}

// MARK: - NotificationType Extension

extension NotificationType {
    static func from(userInfo: [AnyHashable: Any]) -> NotificationType {
        guard let typeString = userInfo["type"] as? String else {
            return .system
        }
        
        switch typeString {
        case "dispute_update":
            return .disputeUpdate
        case "resolution":
            return .resolution
        case "payment":
            return .payment
        default:
            return .system
        }
    }
}

// MARK: - NotificationItem Codable

extension NotificationItem: Codable {
    enum CodingKeys: String, CodingKey {
        case id, title, message, type, timestamp, isRead
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        message = try container.decode(String.self, forKey: .message)
        type = try container.decode(NotificationType.self, forKey: .type)
        timestamp = try container.decode(Date.self, forKey: .timestamp)
        isRead = try container.decode(Bool.self, forKey: .isRead)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(message, forKey: .message)
        try container.encode(type, forKey: .type)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(isRead, forKey: .isRead)
    }
}

extension NotificationType: Codable {}