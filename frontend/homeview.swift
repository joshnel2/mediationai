//
//  HomeView.swift
//  MediationAI
//
//  Created by Linda Alster on 7/14/25.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authService: MockAuthService
    @EnvironmentObject var disputeService: MockDisputeService
    @State private var showCreate = false
    @State private var showJoin = false
    @State private var showSettings = false
    @State private var showCommunity = false
    @State private var showContract = false
    @State private var showEscrow = false
    @State private var showNotifications = false

    @State private var selectedDispute: Dispute?
    @State private var animateCards = false
    
    var userDisputes: [Dispute] {
        disputeService.disputes.filter { 
            $0.partyA?.id == authService.currentUser?.id || $0.partyB?.id == authService.currentUser?.id 
        }
    }
    
    var body: some View {
        ZStack {
            // Background gradient
            AppTheme.backgroundGradient
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: AppTheme.spacingXL) {
                    // Header section
                    headerSection
                    
                    // Quick stats
                    statsSection
                    
                    // Quick access section
                    quickAccessSection
                    
                    // Action buttons
                    actionButtonsSection
                    
                    // Disputes section
                    disputesSection
                    
                    // Legal Disclaimer
                    VStack(spacing: AppTheme.spacingSM) {
                        HStack(spacing: AppTheme.spacingSM) {
                            Image(systemName: "info.circle")
                                .font(.caption2)
                                .foregroundColor(AppTheme.textTertiary)
                            
                            Text("This app provides mediation services, not legal advice. For legal matters, consult a qualified attorney.")
                                .font(AppTheme.caption2())
                                .foregroundColor(AppTheme.textTertiary)
                                .multilineTextAlignment(.leading)
                        }
                        
                        HStack(spacing: AppTheme.spacingSM) {
                            Image(systemName: "brain.head.profile")
                                .font(.caption2)
                                .foregroundColor(AppTheme.textTertiary)
                            
                            Text("AI responses are suggestions based on mediation principles, not legal determinations.")
                                .font(AppTheme.caption2())
                                .foregroundColor(AppTheme.textTertiary)
                                .multilineTextAlignment(.leading)
                        }
                    }
                    .padding(AppTheme.spacingMD)
                    .background(AppTheme.glassSecondary)
                    .cornerRadius(AppTheme.radiusMD)
                    .padding(.top, AppTheme.spacingLG)
                    
                    // Footer
                    Text("Decentralized Technology Solutions 2025")
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.textSecondary.opacity(0.7))
                        .padding(.top, AppTheme.spacingXL)
                    
                    Spacer(minLength: AppTheme.spacingXXL)
                }
                .padding(.horizontal, AppTheme.spacingLG)
                .padding(.top, AppTheme.spacingSM)
            }
        }
        .navigationBarHidden(true)
        .sheet(item: $selectedDispute) { dispute in
            DisputeRoomView(dispute: dispute)
        }
        .sheet(isPresented: $showCreate) {
            CreateDisputeView()
        }
        .sheet(isPresented: $showJoin) {
            JoinDisputeView()
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .sheet(isPresented: $showCommunity) {
            CommunityView()
        }
        .sheet(isPresented: $showContract) {
            ContractView()
        }
        .sheet(isPresented: $showEscrow) {
            EscrowView()
        }
        .sheet(isPresented: $showNotifications) {
            NotificationsView()
        }

        .onAppear {
            withAnimation(.easeOut(duration: 0.8).delay(0.2)) {
                animateCards = true
            }
        }
    }
    
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: AppTheme.spacingSM) {
                Text("Good morning!")
                    .font(AppTheme.title3())
                    .foregroundColor(AppTheme.textSecondary)
                
                Text(authService.currentUser?.email.components(separatedBy: "@").first?.capitalized ?? "User")
                    .font(AppTheme.largeTitle())
                    .foregroundColor(AppTheme.textPrimary)
                    .fontWeight(.bold)
            }
            
            Spacer()
            
            HStack(spacing: AppTheme.spacingMD) {
                // Community button
                Button(action: { showCommunity = true }) {
                    Image(systemName: "person.3.fill")
                        .font(.system(size: 20))
                        .foregroundColor(AppTheme.secondary)
                        .frame(width: 44, height: 44)
                        .background(AppTheme.glassPrimary)
                        .cornerRadius(AppTheme.radiusLG)
                        .shadow(color: AppTheme.shadowSM, radius: 4, x: 0, y: 2)
                }
                .scaleEffect(animateCards ? 1.0 : 0.9)
                .animation(.easeOut(duration: 0.6).delay(0.0), value: animateCards)
                
                // Notification button (modern touch)
                Button(action: { 
                    showNotifications = true
                }) {
                    Image(systemName: "bell.fill")
                        .font(.system(size: 20))
                        .foregroundColor(AppTheme.accent)
                        .frame(width: 44, height: 44)
                        .background(AppTheme.glassPrimary)
                        .cornerRadius(AppTheme.radiusLG)
                        .shadow(color: AppTheme.shadowSM, radius: 4, x: 0, y: 2)
                }
                .scaleEffect(animateCards ? 1.0 : 0.9)
                .animation(.easeOut(duration: 0.6).delay(0.1), value: animateCards)
                
                // Profile/Settings button
                Button(action: { showSettings = true }) {
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(AppTheme.mainGradient)
                        .frame(width: 44, height: 44)
                        .background(AppTheme.glassPrimary)
                        .cornerRadius(AppTheme.radiusLG)
                        .shadow(color: AppTheme.shadowSM, radius: 4, x: 0, y: 2)
                }
                .scaleEffect(animateCards ? 1.0 : 0.9)
                .animation(.easeOut(duration: 0.6).delay(0.2), value: animateCards)
            }
        }
        .padding(.top, AppTheme.spacingLG)
    }
    
    private var statsSection: some View {
        HStack(spacing: AppTheme.spacingMD) {
            StatCard(
                title: "Total Disputes",
                value: "\(userDisputes.count)",
                icon: "scale.3d",
                color: AppTheme.info
            )
            
            StatCard(
                title: "Resolved",
                value: "\(userDisputes.filter { $0.isResolved }.count)",
                icon: "checkmark.seal.fill",
                color: AppTheme.success
            )
            
            StatCard(
                title: "Active",
                value: "\(userDisputes.filter { !$0.isResolved }.count)",
                icon: "clock.fill",
                color: AppTheme.warning
            )
        }
        .scaleEffect(animateCards ? 1.0 : 0.95)
        .opacity(animateCards ? 1.0 : 0.0)
        .animation(.easeOut(duration: 0.6).delay(0.1), value: animateCards)
    }
    
    private var quickAccessSection: some View {
        VStack(spacing: AppTheme.spacingMD) {
            HStack(spacing: AppTheme.spacingMD) {
                Button(action: { showContract = true }) {
                    HStack {
                        Image(systemName: "doc.text.fill")
                            .font(.title2)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Contract")
                                .font(AppTheme.headline())
                                .fontWeight(.semibold)
                            
                            Text("AI creates fair contracts")
                                .font(AppTheme.caption())
                                .opacity(0.8)
                        }
                        
                        Spacer()
                    }
                    .foregroundColor(.white)
                    .padding(AppTheme.spacingLG)
                    .frame(maxWidth: .infinity)
                    .background(AppTheme.mainGradient)
                    .cornerRadius(AppTheme.radiusLG)
                    .shadow(color: AppTheme.primary.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                
                Button(action: { showEscrow = true }) {
                    HStack {
                        Image(systemName: "lock.shield.fill")
                            .font(.title2)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Escrow")
                                .font(AppTheme.headline())
                                .fontWeight(.semibold)
                            
                            Text("Coming soon")
                                .font(AppTheme.caption())
                                .opacity(0.8)
                            
                            Text("Learn More")
                                .font(.system(size: 11))
                                .foregroundColor(AppTheme.primary)
                                .fontWeight(.medium)
                        }
                        
                        Spacer()
                    }
                    .foregroundColor(AppTheme.textPrimary)
                    .padding(AppTheme.spacingLG)
                    .frame(maxWidth: .infinity)
                }
                .glassCard()
            }
            
            // Pricing info
            HStack {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(AppTheme.info)
                
                                    Text("FREE dispute resolution • AI-powered mediation • No hidden fees")
                    .font(AppTheme.caption())
                    .foregroundColor(AppTheme.textTertiary)
                
                Spacer()
            }
            .padding(.horizontal, AppTheme.spacingSM)
        }
        .scaleEffect(animateCards ? 1.0 : 0.95)
        .opacity(animateCards ? 1.0 : 0.0)
        .animation(.easeOut(duration: 0.6).delay(0.2), value: animateCards)
    }
    
    private var actionButtonsSection: some View {
        VStack(spacing: AppTheme.spacingMD) {
            HStack(spacing: AppTheme.spacingMD) {
                Button(action: { showCreate = true }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Create Dispute")
                                .font(AppTheme.headline())
                                .fontWeight(.semibold)
                            
                                                Text("Start new mediation")
                        .font(AppTheme.caption())
                        .opacity(0.8)
                        }
                        
                        Spacer()
                    }
                    .foregroundColor(.white)
                    .padding(AppTheme.spacingLG)
                    .frame(maxWidth: .infinity)
                    .background(AppTheme.mainGradient)
                    .cornerRadius(AppTheme.radiusLG)
                    .shadow(color: AppTheme.primary.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                
                Button(action: { showJoin = true }) {
                    HStack {
                        Image(systemName: "link.circle.fill")
                            .font(.title2)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Join Dispute")
                                .font(AppTheme.headline())
                                .fontWeight(.semibold)
                            
                            Text("Use invitation link")
                                .font(AppTheme.caption())
                                .opacity(0.8)
                        }
                        
                        Spacer()
                    }
                    .foregroundColor(AppTheme.textPrimary)
                    .padding(AppTheme.spacingLG)
                    .frame(maxWidth: .infinity)
                }
                .glassCard()
            }
        }
        .scaleEffect(animateCards ? 1.0 : 0.95)
        .opacity(animateCards ? 1.0 : 0.0)
        .animation(.easeOut(duration: 0.6).delay(0.3), value: animateCards)
    }
    
    private var disputesSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingLG) {
            HStack {
                Text("Your Disputes")
                    .font(AppTheme.title2())
                    .foregroundColor(AppTheme.textPrimary)
                    .fontWeight(.bold)
                
                Spacer()
                
                if !userDisputes.isEmpty {
                    Text("\(userDisputes.count)")
                        .font(AppTheme.caption())
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, AppTheme.spacingMD)
                        .padding(.vertical, AppTheme.spacingSM)
                        .background(AppTheme.primary)
                        .clipShape(Capsule())
                }
            }
            
            if userDisputes.isEmpty {
                EmptyDisputesView(
                    onCreateDispute: { showCreate = true },
                    onJoinDispute: { showJoin = true }
                )
            } else {
                LazyVStack(spacing: AppTheme.spacingMD) {
                    ForEach(userDisputes.indices, id: \.self) { index in
                        let dispute = userDisputes[index]
                        
                        Button {
                            selectedDispute = dispute
                        } label: {
                            ModernDisputeCard(dispute: dispute)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .scaleEffect(animateCards ? 1.0 : 0.95)
                        .opacity(animateCards ? 1.0 : 0.0)
                        .animation(.easeOut(duration: 0.6).delay(0.4 + Double(index) * 0.1), value: animateCards)
                    }
                }
            }
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: AppTheme.spacingMD) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            VStack(spacing: AppTheme.spacingSM) {
                Text(value)
                    .font(AppTheme.title2())
                    .fontWeight(.bold)
                    .foregroundColor(AppTheme.textPrimary)
                
                Text(title)
                    .font(AppTheme.caption())
                    .foregroundColor(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(AppTheme.spacingLG)
        .glassCard()
    }
}

struct EmptyDisputesView: View {
    let onCreateDispute: () -> Void
    let onJoinDispute: () -> Void
    
    var body: some View {
        VStack(spacing: AppTheme.spacingXL) {
            VStack(spacing: AppTheme.spacingLG) {
                Image(systemName: "scale.3d")
                    .font(.system(size: 64))
                    .foregroundStyle(AppTheme.mainGradient)
                
                VStack(spacing: AppTheme.spacingSM) {
                    Text("No disputes yet")
                        .font(AppTheme.title2())
                        .foregroundColor(AppTheme.textPrimary)
                        .fontWeight(.semibold)
                    
                    Text("Create your first dispute or join one using an invitation link to get started with AI-powered mediation.")
                        .font(AppTheme.body())
                        .foregroundColor(AppTheme.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
            }
            
            VStack(spacing: AppTheme.spacingMD) {
                Button("Create Your First Dispute", action: onCreateDispute)
                    .primaryButton()
                
                Button("Join a Dispute", action: onJoinDispute)
                    .secondaryButton()
            }
        }
        .padding(AppTheme.spacingXL)
        .glassCard()
    }
}

struct ModernDisputeCard: View {
    let dispute: Dispute
    
    private var statusColor: Color {
        switch dispute.status {
        case .inviteSent: return AppTheme.warning
        case .inProgress: return AppTheme.info
        case .aiAnalyzing: return AppTheme.secondary
        case .expertReview: return AppTheme.accent
        case .resolved: return AppTheme.success
        case .appealed: return AppTheme.error
        case .archived: return AppTheme.textTertiary
        }
    }
    
    private var statusIcon: String {
        switch dispute.status {
        case .inviteSent: return "paperplane.fill"
        case .inProgress: return "clock.fill"
        case .aiAnalyzing: return "brain.head.profile"
        case .expertReview: return "person.badge.shield.checkmark"
        case .resolved: return "checkmark.seal.fill"
        case .appealed: return "exclamationmark.triangle.fill"
        case .archived: return "archivebox.fill"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingLG) {
            // Header with status
            HStack {
                HStack(spacing: AppTheme.spacingSM) {
                    Image(systemName: statusIcon)
                        .font(.caption)
                        .foregroundColor(statusColor)
                    
                    Text(dispute.status.rawValue)
                        .font(AppTheme.caption())
                        .fontWeight(.medium)
                        .foregroundColor(statusColor)
                }
                .padding(.horizontal, AppTheme.spacingMD)
                .padding(.vertical, AppTheme.spacingSM)
                .background(statusColor.opacity(0.1))
                .cornerRadius(AppTheme.radiusSM)
                
                Spacer()
                
                Text(dispute.createdAt.formatted(date: .abbreviated, time: .omitted))
                    .font(AppTheme.caption2())
                    .foregroundColor(AppTheme.textTertiary)
            }
            
            // Content
            VStack(alignment: .leading, spacing: AppTheme.spacingMD) {
                Text(dispute.title)
                    .font(AppTheme.title3())
                    .foregroundColor(AppTheme.textPrimary)
                    .fontWeight(.semibold)
                    .lineLimit(2)
                
                Text(dispute.description)
                    .font(AppTheme.body())
                    .foregroundColor(AppTheme.textSecondary)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
            }
            
            // Footer
            HStack {
                HStack(spacing: AppTheme.spacingSM) {
                    Image(systemName: "person.2.fill")
                        .font(.caption2)
                        .foregroundColor(AppTheme.textTertiary)
                    
                    Text(dispute.partyB != nil ? "Both parties joined" : "Waiting for other party")
                        .font(AppTheme.caption2())
                        .foregroundColor(AppTheme.textTertiary)
                }
                
                Spacer()
                
                if dispute.isResolved {
                    HStack(spacing: AppTheme.spacingSM) {
                        Image(systemName: "brain.head.profile")
                            .font(.caption2)
                            .foregroundColor(AppTheme.success)
                        
                        Text("AI Resolved")
                            .font(AppTheme.caption2())
                            .foregroundColor(AppTheme.success)
                            .fontWeight(.medium)
                    }
                }
            }
        }
        .padding(AppTheme.spacingLG)
        .glassCard()
    }
}
