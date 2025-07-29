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
    @EnvironmentObject var socialService: SocialAPIService
    @EnvironmentObject var viralService: ViralAPIService
    @EnvironmentObject var badgeService: BadgeService
    @State private var showCreate = false
    @State private var showJoin = false
    @State private var showSettings = false
    @State private var showCommunity = false
    // Contract & escrow features removed for Gen-Z simplification
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
                    
                    heroBanner

                    // Quick stats
                    statsSection

                    // Trending clashes
                    trendingSection
                    
                    // Action buttons
                    actionButtonsSection
                    
                    // Disputes section
                    disputesSection
                    
                    // Removed professional legal disclaimers & footer for simpler kid-friendly UI
                    
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
                Text(timeGreeting())
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
            NavigationLink(destination: CrashoutsListView().environmentObject(socialService).environmentObject(authService)) {
                StatCard(
                    title: "Total Crashouts",
                    value: "\(userDisputes.count)",
                    icon: "scale.3d",
                    color: AppTheme.info
                )
            }
            .buttonStyle(PlainButtonStyle())
            
            NavigationLink(destination: HistoryListView().environmentObject(socialService).environmentObject(authService)) {
                StatCard(
                    title: "Resolved",
                    value: "\(userDisputes.filter { $0.isResolved }.count)",
                    icon: "checkmark.seal.fill",
                    color: AppTheme.success
                )
            }
            .buttonStyle(PlainButtonStyle())
            
            NavigationLink(destination: ActiveCrashoutsListView().environmentObject(socialService).environmentObject(authService)) {
                StatCard(
                    title: "Active",
                    value: "\(userDisputes.filter { !$0.isResolved }.count)",
                    icon: "clock.fill",
                    color: AppTheme.warning
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
        .scaleEffect(animateCards ? 1.0 : 0.95)
        .opacity(animateCards ? 1.0 : 0.0)
        .animation(.easeOut(duration: 0.6).delay(0.1), value: animateCards)
    }

    // Helper to compute greeting based on current hour
    private func timeGreeting() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:
            return "Good morning!"
        case 12..<17:
            return "Good afternoon!"
        case 17..<22:
            return "Good evening!"
        default:
            return "Hello!"
        }
    }

    // MARK: - Hero Banner
    private var heroBanner: some View {
        Button(action: { showCreate = true }) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Crashout")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                    Text("Debate and let AI decide")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.9))
                }
                Spacer()
                Image(systemName: "bolt.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.white)
                    .rotationEffect(.degrees(10))
            }
            .padding(32)
            .frame(maxWidth: .infinity)
            .background(LinearGradient(colors: [AppTheme.accent, AppTheme.primary], startPoint: .topLeading, endPoint: .bottomTrailing))
            .cornerRadius(32)
            .shadow(color: AppTheme.primary.opacity(0.3), radius: 12, x: 0, y: 6)
        }
        .scaleEffect(animateCards ? 1 : 0.95)
        .opacity(animateCards ? 1 : 0)
        .animation(.easeOut(duration: 0.6), value: animateCards)
    }
    
    private var trendingSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingMD) {
            Text("Trending Crashouts 👀")
                .font(AppTheme.title2())
                .foregroundColor(AppTheme.textPrimary)
                .fontWeight(.bold)

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 16) {
                    ForEach(socialService.liveClashes) { clash in
                        TrendingClashCard(clash: clash)
                            .environmentObject(socialService)
                    }
                }
                .padding(.horizontal, 4)
            }
        }
        .padding(.top, AppTheme.spacingMD)
    }

    // small horizontal card
    private struct TrendingClashCard: View {
        let clash: Clash
        @EnvironmentObject var social: SocialAPIService

        var body: some View {
            NavigationLink(destination: destinationView) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("\(clash.streamerA) vs \(clash.streamerB)")
                        .font(.subheadline).bold()
                        .foregroundColor(.white)
                        .lineLimit(1)
                    Text("👀 \(clash.viewerCount) viewers")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.9))
                }
                .padding()
                .frame(width: 200, height: 100)
                .background(LinearGradient(colors: [AppTheme.primary, AppTheme.accent], startPoint: .topLeading, endPoint: .bottomTrailing))
                .cornerRadius(18)
                .shadow(radius: 4)
            }
            .buttonStyle(PlainButtonStyle())
        }

        // Decide where to navigate (conversation or watch) depending on data availability
        private var destinationView: some View {
            let allDisputes = social.disputesByUser.values.flatMap { $0 }
            if let dispute = allDisputes.first(where: { $0.id == clash.id }) {
                return AnyView(ConversationView(dispute: dispute).environmentObject(social))
            } else {
                let placeholder = MockDispute(id: clash.id, title: "\(clash.streamerA) vs \(clash.streamerB)", statementA: "", statementB: "", votesA: clash.votes ?? 0, votesB: 0)
                return AnyView(ConversationView(dispute: placeholder).environmentObject(social))
            }
        }
    }
    
    private var actionButtonsSection: some View {
        VStack(spacing: AppTheme.spacingMD) {
            HStack(spacing: AppTheme.spacingMD) {
                Button(action: { showCreate = true }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Crashout")
                                .font(AppTheme.headline())
                                .fontWeight(.semibold)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                            
                                                Text("Go live with friends")
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
                            Text("Join Crashout")
                                .font(AppTheme.headline())
                                .fontWeight(.semibold)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                            
                            Text("Watch & chat live")
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
    
    // Crashouts section
    private var disputesSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingLG) {
            HStack {
                Text("Your Crashouts")
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
                    .lineLimit(2)
                    .minimumScaleFactor(0.75)
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
                    Text("No crashouts yet")
                        .font(AppTheme.title2())
                        .foregroundColor(AppTheme.textPrimary)
                        .fontWeight(.semibold)
                    
                    Text("Create your first crashout or join one using an invitation link to get started with AI-powered resolution.")
                        .font(AppTheme.body())
                        .foregroundColor(AppTheme.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
            }
            
            VStack(spacing: AppTheme.spacingMD) {
                Button("Start Your First Crashout", action: onCreateDispute)
                    .primaryButton()
                
                Button("Join a Crashout", action: onJoinDispute)
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
        case .inProgress: return AppTheme.success
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
                Group {
                    if dispute.status == .inviteSent {
                        Button(action: {
                            #if canImport(UIKit)
                            UIPasteboard.general.string = dispute.shareLink
                            #endif
                        }) {
                            HStack(spacing: AppTheme.spacingSM) {
                                Image(systemName: "link")
                                    .font(.caption)
                                    .foregroundColor(statusColor)
                                Text("Copy Invite Link")
                                    .font(AppTheme.caption())
                                    .fontWeight(.medium)
                                    .foregroundColor(statusColor)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    } else {
                        HStack(spacing: AppTheme.spacingSM) {
                            Image(systemName: statusIcon)
                                .font(.caption)
                                .foregroundColor(statusColor)
                            
                            Text(dispute.status.rawValue)
                                .font(AppTheme.caption())
                                .fontWeight(.medium)
                                .foregroundColor(statusColor)
                        }
                    }
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
