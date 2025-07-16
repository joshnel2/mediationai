//
//  SettingsView.swift
//  MediationAI
//
//  Created by Linda Alster on 7/14/25.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject private var authService: MockAuthService
    @State private var showPrivacyPolicy = false
    @State private var showTermsOfService = false
    @State private var showSupport = false
    @State private var showDeleteAccountAlert = false
    @State private var showNewPrivacyPolicy = false
    @State private var showNewTermsOfService = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: AppTheme.spacingXL) {
                    // Profile Section
                    VStack(alignment: .leading, spacing: AppTheme.spacingMD) {
                        HStack(spacing: 16) {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 40))
                                .foregroundColor(AppTheme.primary)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(authService.currentUser?.email ?? "User")
                                    .font(.headline)
                                    .foregroundColor(AppTheme.textPrimary)
                                
                                Text("MediationAI Member")
                                    .font(.caption)
                                    .foregroundColor(AppTheme.textSecondary)
                            }
                            
                            Spacer()
                        }
                        .padding(.vertical, 8)
                    }
                    .modernCard()
                    
                    // Security Section
                    VStack(alignment: .leading, spacing: AppTheme.spacingMD) {
                        Text("Security")
                            .font(AppTheme.headline())
                            .foregroundColor(AppTheme.textPrimary)
                            .fontWeight(.semibold)
                        
                        VStack(spacing: 0) {
                            SettingsToggleRow(
                                icon: "faceid",
                                title: "Face ID",
                                subtitle: "Use Face ID to unlock the app",
                                isOn: $authService.isFaceIDEnabled,
                                action: { 
                                    if authService.isFaceIDEnabled {
                                        authService.enableFaceID()
                                    } else {
                                        authService.disableFaceID()
                                    }
                                }
                            )
                            
                            SettingsToggleRow(
                                icon: "key.fill",
                                title: "Auto Login",
                                subtitle: "Stay signed in automatically",
                                isOn: $authService.isAutoLoginEnabled,
                                action: { 
                                    if authService.isAutoLoginEnabled {
                                        authService.enableAutoLogin()
                                    } else {
                                        authService.disableAutoLogin()
                                    }
                                }
                            )
                        }
                        .modernCard()
                    }
                    
                    // Support Section
                    VStack(alignment: .leading, spacing: AppTheme.spacingMD) {
                        Text("Support")
                            .font(AppTheme.headline())
                            .foregroundColor(AppTheme.textPrimary)
                            .fontWeight(.semibold)
                        
                        VStack(spacing: 0) {
                            SettingsRow(
                                icon: "questionmark.circle",
                                title: "Help & Support",
                                subtitle: "Get help with your account",
                                action: { showSupport = true }
                            )
                            
                            SettingsRow(
                                icon: "envelope",
                                title: "Contact Us",
                                subtitle: "support@mediationai.app",
                                action: { openEmail() }
                            )
                            
                            SettingsRow(
                                icon: "star",
                                title: "Rate the App",
                                subtitle: "Share your experience",
                                action: { rateApp() }
                            )
                        }
                        .modernCard()
                    }
                    
                    // Legal Section
                    VStack(alignment: .leading, spacing: AppTheme.spacingMD) {
                        Text("Legal")
                            .font(AppTheme.headline())
                            .foregroundColor(AppTheme.textPrimary)
                            .fontWeight(.semibold)
                        
                        VStack(spacing: 0) {
                            SettingsRow(
                                icon: "shield.checkerboard",
                                title: "Privacy Policy",
                                subtitle: "How we protect your data",
                                action: { showPrivacyPolicy = true }
                            )
                            
                            SettingsRow(
                                icon: "doc.text",
                                title: "Terms of Service",
                                subtitle: "Service agreement",
                                action: { showTermsOfService = true }
                            )
                            
                            SettingsRow(
                                icon: "scale.3d",
                                title: "Legal Disclaimer",
                                subtitle: "AI mediation limitations",
                                action: { showLegalDisclaimer() }
                            )
                        }
                        .modernCard()
                    }
                    
                    // App Information
                    VStack(alignment: .leading, spacing: AppTheme.spacingMD) {
                        Text("App Information")
                            .font(AppTheme.headline())
                            .foregroundColor(AppTheme.textPrimary)
                            .fontWeight(.semibold)
                        
                        VStack(spacing: 0) {
                            SettingsRow(
                                icon: "info.circle",
                                title: "Version",
                                subtitle: "1.0.0 (Build 1)",
                                action: { }
                            )
                            
                            SettingsRow(
                                icon: "globe",
                                title: "Website",
                                subtitle: "mediationai.app",
                                action: { openWebsite() }
                            )
                            
                            SettingsRow(
                                icon: "hand.raised",
                                title: "Acknowledgments",
                                subtitle: "Open source libraries",
                                action: { showAcknowledgments() }
                            )
                        }
                        .modernCard()
                    }
                    
                    // Account Actions
                    VStack(alignment: .leading, spacing: AppTheme.spacingMD) {
                        Text("Account")
                            .font(AppTheme.headline())
                            .foregroundColor(AppTheme.textPrimary)
                            .fontWeight(.semibold)
                        
                        VStack(spacing: 0) {
                            SettingsRow(
                                icon: "icloud.and.arrow.up",
                                title: "Export Data",
                                subtitle: "Download your dispute history",
                                action: { exportData() }
                            )
                            
                            SettingsRow(
                                icon: "doc.text",
                                title: "Privacy Policy",
                                subtitle: "How we handle your data",
                                action: { showNewPrivacyPolicy = true }
                            )
                            
                            SettingsRow(
                                icon: "doc.text",
                                title: "Terms of Service",
                                subtitle: "Legal terms and conditions",
                                action: { showNewTermsOfService = true }
                            )
                            
                            SettingsRow(
                                icon: "trash",
                                title: "Delete Account",
                                subtitle: "Permanently remove your account",
                                destructive: true,
                                action: { showDeleteAccountAlert = true }
                            )
                        }
                        .modernCard()
                    }
                    
                    // Sign Out
                    Button(action: signOut) {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .foregroundColor(AppTheme.error)
                            Text("Sign Out")
                                .foregroundColor(AppTheme.error)
                                .font(AppTheme.headline())
                                .fontWeight(.semibold)
                        }
                    }
                    .secondaryButton()
                    
                    // Footer
                    Text("Decentralized Technology Solutions 2025")
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.textSecondary.opacity(0.7))
                        .padding(.top, AppTheme.spacingXL)
                    
                    Spacer(minLength: AppTheme.spacingXXL)
                }
                .padding(AppTheme.spacingLG)
            }
            .background(AppTheme.backgroundGradient.ignoresSafeArea())
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Home") { dismissView() }
            }
        }
        .sheet(isPresented: $showPrivacyPolicy) {
            PrivacyPolicyView()
        }
        .sheet(isPresented: $showTermsOfService) {
            TermsOfServiceView()
        }
        .sheet(isPresented: $showSupport) {
            SupportView()
        }
        .sheet(isPresented: $showNewPrivacyPolicy) {
            PrivacyPolicyView()
        }
        .sheet(isPresented: $showNewTermsOfService) {
            TermsOfServiceView()
        }
        .alert("Delete Account", isPresented: $showDeleteAccountAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteAccount()
            }
        } message: {
            Text("This will permanently delete your account and all associated data. This action cannot be undone.")
        }
    }
    
    private func dismissView() {
        dismiss()
    }
    
    private func signOut() {
        authService.signOut()
        dismissView()
    }
    
    private func deleteAccount() {
        // In a real app, this would call an API to delete the account
        authService.signOut()
        dismissView()
    }
    
    private func openEmail() {
        if let emailURL = URL(string: "mailto:support@mediationai.app") {
            UIApplication.shared.open(emailURL)
        }
    }
    
    private func rateApp() {
        // Open App Store rating
        if let appStoreURL = URL(string: "https://apps.apple.com/app/id123456789?action=write-review") {
            UIApplication.shared.open(appStoreURL)
        }
    }
    
    private func openWebsite() {
        if let websiteURL = URL(string: "https://mediationai.app") {
            UIApplication.shared.open(websiteURL)
        }
    }
    
    private func showLegalDisclaimer() {
        // Show alert with legal disclaimer
    }
    
    private func showAcknowledgments() {
        // Show acknowledgments view
    }
    
    private func exportData() {
        // Export user data functionality
    }
}

struct SettingsToggleRow: View {
    let icon: String
    let title: String
    let subtitle: String
    @Binding var isOn: Bool
    let action: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(AppTheme.primary)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(AppTheme.textPrimary)
                
                if !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(AppTheme.textSecondary)
                }
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .onChange(of: isOn) { _ in
                    action()
                }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(Color.clear)
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let destructive: Bool
    let action: () -> Void
    
    init(icon: String, title: String, subtitle: String, destructive: Bool = false, action: @escaping () -> Void) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.destructive = destructive
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(destructive ? .red : AppTheme.primary)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(destructive ? .red : AppTheme.textPrimary)
                    
                    if !subtitle.isEmpty {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundColor(AppTheme.textSecondary)
                    }
                }
                
                Spacer()
                
                if !destructive {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(MockAuthService())
    }
}