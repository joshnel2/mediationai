//
//  NotificationsView.swift
//  MediationAI
//
//  Created by Linda Alster on 7/14/25.
//

import SwiftUI

struct NotificationsView: View {
    @Environment(\.dismiss) var dismiss
    @State private var notifications: [NotificationItem] = []
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
                                
                                Button(action: { showingSettings = true }) {
                                    Image(systemName: "gearshape.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(AppTheme.secondary)
                                }
                            }
                            
                            if notifications.isEmpty {
                                Text("Stay updated on your disputes and resolutions")
                                    .font(.subheadline)
                                    .foregroundColor(AppTheme.textSecondary)
                            } else {
                                Text("\(notifications.count) notification\(notifications.count == 1 ? "" : "s")")
                                    .font(.subheadline)
                                    .foregroundColor(AppTheme.textSecondary)
                            }
                        }
                        .padding(.horizontal)
                        
                        // Notifications List
                        if notifications.isEmpty {
                            EmptyNotificationsView()
                        } else {
                            LazyVStack(spacing: AppTheme.spacingMD) {
                                ForEach(notifications) { notification in
                                    NotificationCard(notification: notification) {
                                        // Handle notification tap
                                        markAsRead(notification)
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
                loadNotifications()
            }
        }
        .sheet(isPresented: $showingSettings) {
            NotificationSettingsView()
        }
    }
    
    private func loadNotifications() {
        // Sample notifications - in real app, load from API
        notifications = [
            NotificationItem(
                id: "1",
                title: "Dispute Update",
                message: "Your dispute #12345 has received a new response",
                type: .disputeUpdate,
                timestamp: Date().addingTimeInterval(-3600),
                isRead: false
            ),
            NotificationItem(
                id: "2",
                title: "Resolution Available",
                message: "AI has generated a resolution for your dispute",
                type: .resolution,
                timestamp: Date().addingTimeInterval(-7200),
                isRead: false
            ),
            NotificationItem(
                id: "3",
                title: "Payment Processed",
                message: "Your escrow payment has been successfully processed",
                type: .payment,
                timestamp: Date().addingTimeInterval(-86400),
                isRead: true
            )
        ]
    }
    
    private func markAsRead(_ notification: NotificationItem) {
        if let index = notifications.firstIndex(where: { $0.id == notification.id }) {
            notifications[index].isRead = true
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