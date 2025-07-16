//
//  CommunityView.swift
//  MediationAI
//
//  Created by Linda Alster on 7/14/25.
//

import SwiftUI

struct CommunityView: View {
    @EnvironmentObject var disputeService: MockDisputeService
    @State private var selectedCategory: DisputeCategory = .ecommerce
    @State private var selectedTab: CommunityTab = .publicDisputes
    @State private var searchText = ""
    @State private var animateElements = false
    
    var filteredDisputes: [Dispute] {
        disputeService.disputes
            .filter { $0.isPublic && $0.isResolved }
            .filter { selectedCategory == .other ? true : $0.category == selectedCategory }
            .filter { searchText.isEmpty ? true : $0.title.localizedCaseInsensitiveContains(searchText) }
            .sorted { $0.averageSatisfaction > $1.averageSatisfaction }
    }
    
    var body: some View {
        ZStack {
            AppTheme.backgroundGradient
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                headerSection
                
                // Tab selector
                tabSelector
                
                // Content
                ScrollView {
                    LazyVStack(spacing: AppTheme.spacingXL) {
                        switch selectedTab {
                        case .publicDisputes:
                            publicDisputesContent
                        case .insights:
                            insightsContent
                        case .leaderboard:
                            leaderboardContent
                        case .learning:
                            learningContent
                        }
                        
                        // Footer
                        Text("Decentralized Technology Solutions 2025")
                            .font(.system(size: 12))
                            .foregroundColor(AppTheme.textSecondary.opacity(0.7))
                            .padding(.top, AppTheme.spacingXL)
                        
                        Spacer(minLength: AppTheme.spacingXXL)
                    }
                    .padding(.horizontal, AppTheme.spacingLG)
                    .padding(.top, AppTheme.spacingLG)
                }
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8).delay(0.2)) {
                animateElements = true
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: AppTheme.spacingMD) {
            Text("Community")
                .font(AppTheme.largeTitle())
                .foregroundColor(AppTheme.textPrimary)
                .fontWeight(.bold)
            
            Text("Learn from real disputes and resolutions")
                .font(AppTheme.body())
                .foregroundColor(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, AppTheme.spacingLG)
        .padding(.top, AppTheme.spacingLG)
    }
    
    private var tabSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppTheme.spacingMD) {
                ForEach(CommunityTab.allCases, id: \.self) { tab in
                    Button(action: { selectedTab = tab }) {
                        VStack(spacing: AppTheme.spacingSM) {
                            Image(systemName: tab.icon)
                                .font(.title3)
                            
                            Text(tab.rawValue)
                                .font(AppTheme.caption())
                                .fontWeight(.medium)
                        }
                        .foregroundColor(selectedTab == tab ? AppTheme.primary : AppTheme.textSecondary)
                        .padding(.horizontal, AppTheme.spacingLG)
                        .padding(.vertical, AppTheme.spacingMD)
                        .background(
                            selectedTab == tab ? AppTheme.primary.opacity(0.1) : Color.clear
                        )
                        .cornerRadius(AppTheme.radiusMD)
                    }
                }
            }
            .padding(.horizontal, AppTheme.spacingLG)
        }
        .padding(.vertical, AppTheme.spacingMD)
    }
    
    private var publicDisputesContent: some View {
        VStack(spacing: AppTheme.spacingXL) {
            // Category filter
            categoryFilter
            
            // Search bar
            searchBar
            
            // Stats overview
            statsOverview
            
            // Public disputes list
            if filteredDisputes.isEmpty {
                emptyStateView
            } else {
                disputesList
            }
        }
    }
    
    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppTheme.spacingMD) {
                ForEach([DisputeCategory.other] + DisputeCategory.allCases.filter { $0 != .other }, id: \.self) { category in
                    Button(action: { selectedCategory = category }) {
                        HStack(spacing: AppTheme.spacingSM) {
                            Image(systemName: category.icon)
                                .font(.caption)
                            
                            Text(category == .other ? "All" : category.rawValue)
                                .font(AppTheme.caption())
                                .fontWeight(.medium)
                        }
                        .padding(.horizontal, AppTheme.spacingMD)
                        .padding(.vertical, AppTheme.spacingSM)
                        .foregroundColor(selectedCategory == category ? .white : AppTheme.textSecondary)
                        .background(
                            selectedCategory == category ? category.color : AppTheme.glassSecondary
                        )
                        .cornerRadius(AppTheme.radiusSM)
                    }
                }
            }
            .padding(.horizontal, AppTheme.spacingLG)
        }
    }
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(AppTheme.textTertiary)
            
            TextField("Search disputes...", text: $searchText)
                .font(AppTheme.body())
                .foregroundColor(AppTheme.textPrimary)
        }
        .padding(AppTheme.spacingMD)
        .background(AppTheme.glassPrimary)
        .cornerRadius(AppTheme.radiusLG)
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.radiusLG)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
    }
    
    private var statsOverview: some View {
        HStack(spacing: AppTheme.spacingMD) {
            StatCard(
                title: "Public Disputes",
                value: "\(filteredDisputes.count)",
                icon: "eye.fill",
                color: AppTheme.info
            )
            
            StatCard(
                title: "Avg Satisfaction",
                value: String(format: "%.1f★", filteredDisputes.map { $0.averageSatisfaction }.reduce(0, +) / Double(max(filteredDisputes.count, 1))),
                icon: "star.fill",
                color: AppTheme.success
            )
            
            StatCard(
                title: "Resolution Time",
                value: "2.4h",
                icon: "clock.fill",
                color: AppTheme.warning
            )
        }
        .scaleEffect(animateElements ? 1.0 : 0.95)
        .opacity(animateElements ? 1.0 : 0.0)
        .animation(.easeOut(duration: 0.6).delay(0.1), value: animateElements)
    }
    
    private var disputesList: some View {
        LazyVStack(spacing: AppTheme.spacingLG) {
            ForEach(filteredDisputes.indices, id: \.self) { index in
                let dispute = filteredDisputes[index]
                
                PublicDisputeCard(dispute: dispute)
                    .scaleEffect(animateElements ? 1.0 : 0.95)
                    .opacity(animateElements ? 1.0 : 0.0)
                    .animation(.easeOut(duration: 0.6).delay(0.2 + Double(index) * 0.1), value: animateElements)
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: AppTheme.spacingLG) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 64))
                .foregroundColor(AppTheme.textTertiary)
            
            VStack(spacing: AppTheme.spacingSM) {
                Text("No public disputes found")
                    .font(AppTheme.title3())
                    .foregroundColor(AppTheme.textPrimary)
                    .fontWeight(.semibold)
                
                Text("Try adjusting your filters or check back later")
                    .font(AppTheme.body())
                    .foregroundColor(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(AppTheme.spacingXXL)
        .glassCard()
    }
    
    private var insightsContent: some View {
        VStack(spacing: AppTheme.spacingXL) {
            // Trending categories
            TrendingCategoriesCard()
            
            // Resolution success rates
            ResolutionSuccessCard()
            
            // AI vs Human comparison
            AIHumanComparisonCard()
            
            // Cost savings analytics
            CostSavingsCard()
        }
    }
    
    private var leaderboardContent: some View {
        VStack(spacing: AppTheme.spacingXL) {
            // Top rated users
            TopUsersCard()
            
            // Most helpful contributors
            HelpfulContributorsCard()
            
            // Achievement showcase
            AchievementShowcaseCard()
        }
    }
    
    private var learningContent: some View {
        VStack(spacing: AppTheme.spacingXL) {
            // Dispute prevention tips
            DisputePreventionCard()
            
            // Best practices
            BestPracticesCard()
            
            // Legal education
            LegalEducationCard()
            
            // Case studies
            CaseStudiesCard()
        }
    }
}

enum CommunityTab: String, CaseIterable {
    case publicDisputes = "Disputes"
    case insights = "Insights"
    case leaderboard = "Leaderboard"
    case learning = "Learning"
    
    var icon: String {
        switch self {
        case .publicDisputes: return "doc.text.below.ecg"
        case .insights: return "chart.line.uptrend.xyaxis"
        case .leaderboard: return "trophy.fill"
        case .learning: return "graduationcap.fill"
        }
    }
}

struct PublicDisputeCard: View {
    let dispute: Dispute
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingLG) {
            // Header with category and satisfaction
            HStack {
                HStack(spacing: AppTheme.spacingSM) {
                    Image(systemName: dispute.category.icon)
                        .foregroundColor(dispute.category.color)
                    
                    Text(dispute.category.rawValue)
                        .font(AppTheme.caption())
                        .fontWeight(.medium)
                        .foregroundColor(dispute.category.color)
                }
                .padding(.horizontal, AppTheme.spacingMD)
                .padding(.vertical, AppTheme.spacingSM)
                .background(dispute.category.color.opacity(0.1))
                .cornerRadius(AppTheme.radiusSM)
                
                Spacer()
                
                HStack(spacing: AppTheme.spacingSM) {
                    Image(systemName: "star.fill")
                        .foregroundColor(AppTheme.warning)
                        .font(.caption)
                    
                    Text(String(format: "%.1f", dispute.averageSatisfaction))
                        .font(AppTheme.caption())
                        .fontWeight(.medium)
                        .foregroundColor(AppTheme.textSecondary)
                }
            }
            
            // Title and description
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
            }
            
            // Resolution summary
            if let resolution = dispute.resolution {
                VStack(alignment: .leading, spacing: AppTheme.spacingSM) {
                    HStack {
                        Image(systemName: "brain.head.profile")
                            .foregroundColor(AppTheme.success)
                        
                        Text("AI Resolution")
                            .font(AppTheme.caption())
                            .fontWeight(.semibold)
                            .foregroundColor(AppTheme.success)
                        
                        Spacer()
                        
                        Text("\(Int(resolution.confidence * 100))% confidence")
                            .font(AppTheme.caption2())
                            .foregroundColor(AppTheme.textTertiary)
                    }
                    
                    Text(resolution.summary)
                        .font(AppTheme.caption())
                        .foregroundColor(AppTheme.textSecondary)
                        .lineLimit(2)
                        .padding(.top, AppTheme.spacingSM)
                }
                .padding(AppTheme.spacingMD)
                .background(AppTheme.success.opacity(0.05))
                .cornerRadius(AppTheme.radiusSM)
            }
            
            // Footer with stats
            HStack {
                Label("$\(Int(dispute.disputeValue))", systemImage: "dollarsign.circle")
                    .font(AppTheme.caption2())
                    .foregroundColor(AppTheme.textTertiary)
                
                Spacer()
                
                if let timeToResolution = dispute.timeToResolution {
                    Label("\(Int(timeToResolution / 3600))h resolution", systemImage: "clock")
                        .font(AppTheme.caption2())
                        .foregroundColor(AppTheme.textTertiary)
                }
            }
        }
        .padding(AppTheme.spacingLG)
        .glassCard()
    }
}

// Supporting cards for different tabs
struct TrendingCategoriesCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingLG) {
            Text("📈 Trending Categories")
                .font(AppTheme.headline())
                .foregroundColor(AppTheme.textPrimary)
                .fontWeight(.semibold)
            
            VStack(spacing: AppTheme.spacingMD) {
                TrendingCategoryRow(category: .ecommerce, growth: "+23%", disputes: 124)
                TrendingCategoryRow(category: .rental, growth: "+18%", disputes: 89)
                TrendingCategoryRow(category: .services, growth: "+12%", disputes: 67)
            }
        }
        .padding(AppTheme.spacingLG)
        .glassCard()
    }
}

struct TrendingCategoryRow: View {
    let category: DisputeCategory
    let growth: String
    let disputes: Int
    
    var body: some View {
        HStack {
            HStack(spacing: AppTheme.spacingSM) {
                Image(systemName: category.icon)
                    .foregroundColor(category.color)
                
                Text(category.rawValue)
                    .font(AppTheme.body())
                    .foregroundColor(AppTheme.textPrimary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text(growth)
                    .font(AppTheme.caption())
                    .fontWeight(.semibold)
                    .foregroundColor(AppTheme.success)
                
                Text("\(disputes) disputes")
                    .font(AppTheme.caption2())
                    .foregroundColor(AppTheme.textTertiary)
            }
        }
    }
}

struct ResolutionSuccessCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingLG) {
            Text("🎯 Resolution Success")
                .font(AppTheme.headline())
                .foregroundColor(AppTheme.textPrimary)
                .fontWeight(.semibold)
            
            HStack(spacing: AppTheme.spacingLG) {
                VStack {
                    Text("94.2%")
                        .font(AppTheme.title())
                        .fontWeight(.bold)
                        .foregroundColor(AppTheme.success)
                    
                    Text("Success Rate")
                        .font(AppTheme.caption())
                        .foregroundColor(AppTheme.textSecondary)
                }
                
                Spacer()
                
                VStack {
                    Text("2.4h")
                        .font(AppTheme.title())
                        .fontWeight(.bold)
                        .foregroundColor(AppTheme.info)
                    
                    Text("Avg Time")
                        .font(AppTheme.caption())
                        .foregroundColor(AppTheme.textSecondary)
                }
                
                Spacer()
                
                VStack {
                    Text("4.7★")
                        .font(AppTheme.title())
                        .fontWeight(.bold)
                        .foregroundColor(AppTheme.warning)
                    
                    Text("Satisfaction")
                        .font(AppTheme.caption())
                        .foregroundColor(AppTheme.textSecondary)
                }
            }
        }
        .padding(AppTheme.spacingLG)
        .glassCard()
    }
}

struct AIHumanComparisonCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingLG) {
            Text("🤖 AI vs Human Experts")
                .font(AppTheme.headline())
                .foregroundColor(AppTheme.textPrimary)
                .fontWeight(.semibold)
            
            VStack(spacing: AppTheme.spacingMD) {
                ComparisonRow(title: "Resolution Time", aiValue: "2.4h", humanValue: "18.6h", aiWins: true)
                ComparisonRow(title: "Cost", aiValue: "$1-2", humanValue: "$500+", aiWins: true)
                ComparisonRow(title: "Satisfaction", aiValue: "4.7★", humanValue: "4.9★", aiWins: false)
                ComparisonRow(title: "Accuracy", aiValue: "94%", humanValue: "98%", aiWins: false)
            }
        }
        .padding(AppTheme.spacingLG)
        .glassCard()
    }
}

struct ComparisonRow: View {
    let title: String
    let aiValue: String
    let humanValue: String
    let aiWins: Bool
    
    var body: some View {
        HStack {
            Text(title)
                .font(AppTheme.body())
                .foregroundColor(AppTheme.textPrimary)
            
            Spacer()
            
            Text(aiValue)
                .font(AppTheme.caption())
                .fontWeight(aiWins ? .bold : .regular)
                .foregroundColor(aiWins ? AppTheme.success : AppTheme.textSecondary)
            
            Text("vs")
                .font(AppTheme.caption2())
                .foregroundColor(AppTheme.textTertiary)
            
            Text(humanValue)
                .font(AppTheme.caption())
                .fontWeight(!aiWins ? .bold : .regular)
                .foregroundColor(!aiWins ? AppTheme.success : AppTheme.textSecondary)
        }
    }
}

struct CostSavingsCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingLG) {
            Text("💰 Community Savings")
                .font(AppTheme.headline())
                .foregroundColor(AppTheme.textPrimary)
                .fontWeight(.semibold)
            
            HStack {
                VStack(alignment: .leading) {
                    Text("$2,847,392")
                        .font(AppTheme.title())
                        .fontWeight(.bold)
                        .foregroundColor(AppTheme.success)
                    
                    Text("Total saved vs legal fees")
                        .font(AppTheme.caption())
                        .foregroundColor(AppTheme.textSecondary)
                }
                
                Spacer()
                
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 48))
                    .foregroundColor(AppTheme.success.opacity(0.3))
            }
            
            Text("Our community has saved an average of $4,820 per dispute compared to traditional legal resolution.")
                .font(AppTheme.caption())
                .foregroundColor(AppTheme.textSecondary)
                .lineSpacing(3)
        }
        .padding(AppTheme.spacingLG)
        .glassCard()
    }
}

struct TopUsersCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingLG) {
            Text("🏆 Top Mediators")
                .font(AppTheme.headline())
                .foregroundColor(AppTheme.textPrimary)
                .fontWeight(.semibold)
            
            VStack(spacing: AppTheme.spacingMD) {
                TopUserRow(rank: 1, name: "Sarah M.", badge: "👑", score: 987, winRate: 96)
                TopUserRow(rank: 2, name: "Alex K.", badge: "💎", score: 943, winRate: 94)
                TopUserRow(rank: 3, name: "Jordan L.", badge: "🥇", score: 892, winRate: 91)
            }
        }
        .padding(AppTheme.spacingLG)
        .glassCard()
    }
}

struct TopUserRow: View {
    let rank: Int
    let name: String
    let badge: String
    let score: Int
    let winRate: Int
    
    var body: some View {
        HStack {
            Text("#\(rank)")
                .font(AppTheme.caption())
                .fontWeight(.bold)
                .foregroundColor(AppTheme.textTertiary)
                .frame(width: 30, alignment: .leading)
            
            Text(badge)
                .font(.title3)
            
            VStack(alignment: .leading) {
                Text(name)
                    .font(AppTheme.body())
                    .fontWeight(.medium)
                    .foregroundColor(AppTheme.textPrimary)
                
                Text("\(winRate)% win rate")
                    .font(AppTheme.caption2())
                    .foregroundColor(AppTheme.textSecondary)
            }
            
            Spacer()
            
            Text("\(score)")
                .font(AppTheme.headline())
                .fontWeight(.bold)
                .foregroundColor(AppTheme.primary)
        }
    }
}

struct HelpfulContributorsCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingLG) {
            Text("🌟 Most Helpful")
                .font(AppTheme.headline())
                .foregroundColor(AppTheme.textPrimary)
                .fontWeight(.semibold)
            
            Text("Users who consistently provide fair and helpful resolutions")
                .font(AppTheme.caption())
                .foregroundColor(AppTheme.textSecondary)
        }
        .padding(AppTheme.spacingLG)
        .glassCard()
    }
}

struct AchievementShowcaseCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingLG) {
            Text("🎖️ Recent Achievements")
                .font(AppTheme.headline())
                .foregroundColor(AppTheme.textPrimary)
                .fontWeight(.semibold)
            
            Text("Latest accomplishments from our community")
                .font(AppTheme.caption())
                .foregroundColor(AppTheme.textSecondary)
        }
        .padding(AppTheme.spacingLG)
        .glassCard()
    }
}

struct DisputePreventionCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingLG) {
            Text("🛡️ Dispute Prevention")
                .font(AppTheme.headline())
                .foregroundColor(AppTheme.textPrimary)
                .fontWeight(.semibold)
            
            Text("Learn how to avoid common disputes before they happen")
                .font(AppTheme.caption())
                .foregroundColor(AppTheme.textSecondary)
        }
        .padding(AppTheme.spacingLG)
        .glassCard()
    }
}

struct BestPracticesCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingLG) {
            Text("✅ Best Practices")
                .font(AppTheme.headline())
                .foregroundColor(AppTheme.textPrimary)
                .fontWeight(.semibold)
            
            Text("Tips for better dispute resolution outcomes")
                .font(AppTheme.caption())
                .foregroundColor(AppTheme.textSecondary)
        }
        .padding(AppTheme.spacingLG)
        .glassCard()
    }
}

struct LegalEducationCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingLG) {
            Text("⚖️ Legal Education")
                .font(AppTheme.headline())
                .foregroundColor(AppTheme.textPrimary)
                .fontWeight(.semibold)
            
            Text("Understanding your rights and legal basics")
                .font(AppTheme.caption())
                .foregroundColor(AppTheme.textSecondary)
        }
        .padding(AppTheme.spacingLG)
        .glassCard()
    }
}

struct CaseStudiesCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingLG) {
            Text("📚 Case Studies")
                .font(AppTheme.headline())
                .foregroundColor(AppTheme.textPrimary)
                .fontWeight(.semibold)
            
            Text("Real examples of successful dispute resolutions")
                .font(AppTheme.caption())
                .foregroundColor(AppTheme.textSecondary)
        }
        .padding(AppTheme.spacingLG)
        .glassCard()
    }
}