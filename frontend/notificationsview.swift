//
//  NotificationsView.swift
//  MediationAI
//
//  Created by Linda Alster on 7/14/25.
//

import SwiftUI

struct NotificationsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var notificationService: NotificationService
    @State private var showingSettings = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                AppTheme.backgroundGradient
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: AppTheme.spacingLG) {
                        // Header
                        VStack(alignment: .leading, spacing: AppTheme.spacingMD) {
                            HStack {
                                Text("Notifications")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundColor(AppTheme.primary)
                                
                                Spacer()
                                
                                HStack(spacing: 12) {
                                    if !notificationService.notifications.isEmpty {
                                        Button(action: {
                                            notificationService.clearAllNotifications()
                                        }) {
                                            Image(systemName: "trash.fill")
                                                .font(.system(size: 18))
                                                .foregroundColor(AppTheme.warning)
                                        }
                                    }
                                    
                                    Button(action: { showingSettings = true }) {
                                        Image(systemName: "gearshape.fill")
                                            .font(.system(size: 20))
                                            .foregroundColor(AppTheme.secondary)
                                    }
                                }
                            }
                            
                            if notificationService.notifications.isEmpty {
                                Text("Stay updated on your disputes and resolutions")
                                    .font(.subheadline)
                                    .foregroundColor(AppTheme.textSecondary)
                            } else {
                                Text("\(notificationService.notifications.count) notification\(notificationService.notifications.count == 1 ? "" : "s")")
                                    .font(.subheadline)
                                    .foregroundColor(AppTheme.textSecondary)
                            }
                        }
                        .padding(.horizontal)
                        
                        // Notifications List
                        if notificationService.notifications.isEmpty {
                            EmptyNotificationsView()
                        } else {
                            LazyVStack(spacing: AppTheme.spacingMD) {
                                ForEach(notificationService.notifications) { notification in
                                    NotificationCard(notification: notification) {
                                        // Handle notification tap
                                        notificationService.markAsRead(notification.id)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                notificationService.updateBadgeCount()
            }
        }
        .sheet(isPresented: $showingSettings) {
            NotificationSettingsView()
        }
    }
    

}

struct NotificationCard: View {
    let notification: NotificationItem
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: AppTheme.spacingMD) {
                // Icon
                Image(systemName: notification.type.icon)
                    .font(.system(size: 24))
                    .foregroundColor(notification.type.color)
                    .frame(width: 44, height: 44)
                    .background(notification.type.color.opacity(0.1))
                    .cornerRadius(AppTheme.radiusLG)
                
                // Content
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(notification.title)
                            .font(.headline)
                            .foregroundColor(AppTheme.textPrimary)
                            .fontWeight(notification.isRead ? .medium : .semibold)
                        
                        Spacer()
                        
                        if !notification.isRead {
                            Circle()
                                .fill(AppTheme.accent)
                                .frame(width: 8, height: 8)
                        }
                    }
                    
                    Text(notification.message)
                        .font(.subheadline)
                        .foregroundColor(AppTheme.textSecondary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                    
                    Text(notification.timestamp.timeAgoDisplay())
                        .font(.caption)
                        .foregroundColor(AppTheme.textTertiary)
                }
                
                Spacer()
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: AppTheme.radiusLG)
                    .fill(AppTheme.cardGradient)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.radiusLG)
                            .stroke(AppTheme.glassPrimary, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct EmptyNotificationsView: View {
    var body: some View {
        VStack(spacing: AppTheme.spacingXL) {
            Image(systemName: "bell.slash")
                .font(.system(size: 60))
                .foregroundColor(AppTheme.textTertiary)
                .padding(.top, 60)
            
            VStack(spacing: AppTheme.spacingMD) {
                Text("No Notifications")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(AppTheme.textPrimary)
                
                Text("You're all caught up! Notifications about your disputes and resolutions will appear here.")
                    .font(.body)
                    .foregroundColor(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct NotificationSettingsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var notificationService: NotificationService
    @State private var pushNotifications = true
    @State private var emailNotifications = true
    @State private var disputeUpdates = true
    @State private var resolutionAlerts = true
    @State private var paymentNotifications = true
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.backgroundGradient
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: AppTheme.spacingXL) {
                        // Permission Status
                        VStack(alignment: .leading, spacing: AppTheme.spacingMD) {
                            Text("Permission Status")
                                .font(AppTheme.headline())
                                .foregroundColor(AppTheme.textPrimary)
                                .fontWeight(.semibold)
                            
                            VStack(spacing: AppTheme.spacingMD) {
                                HStack {
                                    Image(systemName: notificationService.isAuthorized ? "checkmark.circle.fill" : "xmark.circle.fill")
                                        .foregroundColor(notificationService.isAuthorized ? AppTheme.success : AppTheme.warning)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Push Notifications")
                                            .font(.headline)
                                            .foregroundColor(AppTheme.textPrimary)
                                        
                                        Text(notificationService.isAuthorized ? "Enabled" : "Disabled - Tap to enable")
                                            .font(.caption)
                                            .foregroundColor(AppTheme.textSecondary)
                                    }
                                    
                                    Spacer()
                                    
                                    if !notificationService.isAuthorized {
                                        Button("Enable") {
                                            Task {
                                                await notificationService.requestPermission()
                                            }
                                        }
                                        .foregroundColor(AppTheme.primary)
                                        .font(.caption)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(AppTheme.primary.opacity(0.1))
                                        .cornerRadius(8)
                                    }
                                }
                                .padding()
                            }
                            .modernCard()
                        }
                        
                        // General Settings
                        VStack(alignment: .leading, spacing: AppTheme.spacingMD) {
                            Text("General")
                                .font(AppTheme.headline())
                                .foregroundColor(AppTheme.textPrimary)
                                .fontWeight(.semibold)
                            
                            VStack(spacing: 0) {
                                ToggleRow(
                                    icon: "bell.fill",
                                    title: "Push Notifications",
                                    subtitle: "Receive notifications on your device",
                                    isOn: $pushNotifications
                                )
                                
                                ToggleRow(
                                    icon: "envelope.fill",
                                    title: "Email Notifications",
                                    subtitle: "Receive notifications via email",
                                    isOn: $emailNotifications
                                )
                            }
                            .modernCard()
                        }
                        
                        // Dispute Settings
                        VStack(alignment: .leading, spacing: AppTheme.spacingMD) {
                            Text("Dispute Updates")
                                .font(AppTheme.headline())
                                .foregroundColor(AppTheme.textPrimary)
                                .fontWeight(.semibold)
                            
                            VStack(spacing: 0) {
                                ToggleRow(
                                    icon: "doc.text.fill",
                                    title: "Dispute Updates",
                                    subtitle: "New messages and status changes",
                                    isOn: $disputeUpdates
                                )
                                
                                ToggleRow(
                                    icon: "checkmark.seal.fill",
                                    title: "Resolution Alerts",
                                    subtitle: "AI-generated resolutions and recommendations",
                                    isOn: $resolutionAlerts
                                )
                                
                                ToggleRow(
                                    icon: "creditcard.fill",
                                    title: "Payment Notifications",
                                    subtitle: "Escrow and payment updates",
                                    isOn: $paymentNotifications
                                )
                            }
                            .modernCard()
                        }
                        
                        // Testing & Debug
                        VStack(alignment: .leading, spacing: AppTheme.spacingMD) {
                            Text("Testing")
                                .font(AppTheme.headline())
                                .foregroundColor(AppTheme.textPrimary)
                                .fontWeight(.semibold)
                            
                            VStack(spacing: AppTheme.spacingMD) {
                                Button(action: {
                                    // Send test notification
                                    notificationService.scheduleLocalNotification(
                                        id: UUID().uuidString,
                                        title: "Test Notification",
                                        body: "This is a test notification from MediationAI",
                                        timeInterval: 2
                                    )
                                }) {
                                    HStack {
                                        Image(systemName: "bell.badge.fill")
                                            .foregroundColor(AppTheme.primary)
                                        
                                        VStack(alignment: .leading) {
                                            Text("Send Test Notification")
                                                .font(.headline)
                                                .foregroundColor(AppTheme.textPrimary)
                                            
                                            Text("Test push notification functionality")
                                                .font(.caption)
                                                .foregroundColor(AppTheme.textSecondary)
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "arrow.right")
                                            .foregroundColor(AppTheme.textTertiary)
                                    }
                                    .padding()
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                Button(action: {
                                    notificationService.clearAllNotifications()
                                }) {
                                    HStack {
                                        Image(systemName: "trash.fill")
                                            .foregroundColor(AppTheme.warning)
                                        
                                        VStack(alignment: .leading) {
                                            Text("Clear All Notifications")
                                                .font(.headline)
                                                .foregroundColor(AppTheme.textPrimary)
                                            
                                            Text("Remove all stored notifications")
                                                .font(.caption)
                                                .foregroundColor(AppTheme.textSecondary)
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "arrow.right")
                                            .foregroundColor(AppTheme.textTertiary)
                                    }
                                    .padding()
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            .modernCard()
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Notification Settings")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(AppTheme.primary)
                }
            }
        }
    }
}

struct ToggleRow: View {
    let icon: String
    let title: String
    let subtitle: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack(spacing: AppTheme.spacingMD) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(AppTheme.secondary)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(AppTheme.textPrimary)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(AppTheme.textSecondary)
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .toggleStyle(SwitchToggleStyle(tint: AppTheme.primary))
        }
        .padding()
        .background(Color.clear)
    }
}

// MARK: - Models

struct NotificationItem: Identifiable {
    let id: String
    let title: String
    let message: String
    let type: NotificationType
    let timestamp: Date
    var isRead: Bool
}

enum NotificationType {
    case disputeUpdate
    case resolution
    case payment
    case system
    
    var icon: String {
        switch self {
        case .disputeUpdate: return "doc.text.fill"
        case .resolution: return "checkmark.seal.fill"
        case .payment: return "creditcard.fill"
        case .system: return "gear.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .disputeUpdate: return AppTheme.secondary
        case .resolution: return AppTheme.success
        case .payment: return AppTheme.accent
        case .system: return AppTheme.info
        }
    }
}

// MARK: - Extensions

extension Date {
    func timeAgoDisplay() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}