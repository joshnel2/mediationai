//
//  HomeView.swift
//  MediationAI
//
//  Created by Linda Alster on 7/14/25.
//

import SwiftUI

struct HomeView: View {
    @State private var selectedTab = 0
    @State private var showCreateDispute = false
    @State private var showNotifications = false
    @State private var unreadNotifications = 3
    
    var body: some View {
        ZStack {
            // Main content
            TabView(selection: $selectedTab) {
                DisputeFeedView()
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }
                    .tag(0)
                
                BettingView()
                    .tabItem {
                        Label("Betting", systemImage: "dollarsign.circle.fill")
                    }
                    .tag(1)
                
                DisputesListView()
                    .tabItem {
                        Label("Disputes", systemImage: "scale.3d")
                    }
                    .tag(2)
                
                ProfileView()
                    .tabItem {
                        Label("Profile", systemImage: "person.fill")
                    }
                    .tag(3)
            }
            .accentColor(.blue)
            
            // Floating action button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    
                    Button(action: { showCreateDispute = true }) {
                        Image(systemName: "plus")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(width: 56, height: 56)
                            .background(
                                LinearGradient(
                                    colors: [.blue, .blue.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .clipShape(Circle())
                            .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 90)
                }
            }
        }
        .sheet(isPresented: $showCreateDispute) {
            CreateDisputeView()
        }
        .sheet(isPresented: $showNotifications) {
            NotificationsView()
        }
    }
}

// MARK: - Dispute Feed View
struct DisputeFeedView: View {
    @State private var disputes: [DisputeItem] = mockDisputeItems
    @State private var searchText = ""
    @State private var selectedFilter = "all"
    @State private var showNotifications = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Custom navigation bar
                customNavigationBar
                
                // Content
                ScrollView {
                    VStack(spacing: 0) {
                        // Stories/Categories section
                        categoriesSection
                        
                        Divider()
                            .padding(.vertical, 8)
                        
                        // Feed
                        LazyVStack(spacing: 16) {
                            ForEach(filteredDisputes) { dispute in
                                DisputeFeedCard(dispute: dispute)
                                    .padding(.horizontal)
                            }
                        }
                        .padding(.vertical)
                    }
                }
            }
            .navigationBarHidden(true)
            .background(Color(UIColor.systemBackground))
        }
    }
    
    var customNavigationBar: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Crashout")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                
                Spacer()
                
                HStack(spacing: 20) {
                    Button(action: {}) {
                        Image(systemName: "magnifyingglass")
                            .font(.title3)
                            .foregroundColor(.primary)
                    }
                    
                    Button(action: { showNotifications = true }) {
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: "bell")
                                .font(.title3)
                                .foregroundColor(.primary)
                            
                            if unreadNotifications > 0 {
                                Circle()
                                    .fill(Color.red)
                                    .frame(width: 8, height: 8)
                            }
                        }
                    }
                }
            }
            .padding()
            
            Divider()
        }
    }
    
    var categoriesSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                CategoryPill(title: "All", isSelected: selectedFilter == "all") {
                    selectedFilter = "all"
                }
                
                CategoryPill(title: "Trending 🔥", isSelected: selectedFilter == "trending") {
                    selectedFilter = "trending"
                }
                
                CategoryPill(title: "Gaming", isSelected: selectedFilter == "gaming") {
                    selectedFilter = "gaming"
                }
                
                CategoryPill(title: "Tech", isSelected: selectedFilter == "tech") {
                    selectedFilter = "tech"
                }
                
                CategoryPill(title: "Legal", isSelected: selectedFilter == "legal") {
                    selectedFilter = "legal"
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 12)
    }
    
    var filteredDisputes: [DisputeItem] {
        if selectedFilter == "all" {
            return disputes
        } else if selectedFilter == "trending" {
            return disputes.filter { $0.isTrending }
        } else {
            return disputes.filter { $0.category.lowercased() == selectedFilter }
        }
    }
    
    @State private var unreadNotifications = 3
}

// MARK: - Category Pill
struct CategoryPill: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.blue : Color(UIColor.secondarySystemBackground))
                )
        }
    }
}

// MARK: - Dispute Feed Card
struct DisputeFeedCard: View {
    let dispute: DisputeItem
    @State private var hasVoted = false
    @State private var selectedSide = ""
    @State private var showComments = false
    @State private var isBookmarked = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                HStack(spacing: 12) {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 40, height: 40)
                        .overlay(
                            Text(dispute.creatorInitials)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                        )
                    
                    VStack(alignment: .leading, spacing: 2) {
                        HStack {
                            Text(dispute.creatorName)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            
                            if dispute.isVerified {
                                Image(systemName: "checkmark.seal.fill")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                        }
                        
                        Text(dispute.timeAgo)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Menu {
                    Button(action: {}) {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                    Button(action: {}) {
                        Label("Report", systemImage: "flag")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            
            // Content
            VStack(alignment: .leading, spacing: 12) {
                Text(dispute.title)
                    .font(.body)
                    .fixedSize(horizontal: false, vertical: true)
                
                if let description = dispute.description {
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(3)
                }
                
                // Media preview if available
                if dispute.hasMedia {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(UIColor.secondarySystemBackground))
                        .aspectRatio(16/9, contentMode: .fit)
                        .overlay(
                            Image(systemName: "play.circle.fill")
                                .font(.largeTitle)
                                .foregroundColor(.white)
                                .shadow(radius: 10)
                        )
                }
                
                // Voting section
                if !hasVoted {
                    VStack(spacing: 12) {
                        Text("What's your take?")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 12) {
                            VoteButton(
                                title: dispute.optionA,
                                percentage: dispute.percentageA,
                                color: .blue,
                                isSelected: selectedSide == "A"
                            ) {
                                withAnimation(.spring()) {
                                    selectedSide = "A"
                                    hasVoted = true
                                }
                            }
                            
                            VoteButton(
                                title: dispute.optionB,
                                percentage: dispute.percentageB,
                                color: .purple,
                                isSelected: selectedSide == "B"
                            ) {
                                withAnimation(.spring()) {
                                    selectedSide = "B"
                                    hasVoted = true
                                }
                            }
                        }
                    }
                } else {
                    // Results view
                    VotingResultsView(
                        optionA: dispute.optionA,
                        optionB: dispute.optionB,
                        percentageA: dispute.percentageA,
                        percentageB: dispute.percentageB,
                        selectedSide: selectedSide,
                        totalVotes: dispute.totalVotes
                    )
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 12)
            
            // Engagement bar
            HStack(spacing: 24) {
                Button(action: {}) {
                    HStack(spacing: 4) {
                        Image(systemName: hasVoted ? "hand.thumbsup.fill" : "hand.thumbsup")
                            .foregroundColor(hasVoted ? .blue : .primary)
                        Text("\(dispute.likes)")
                            .font(.subheadline)
                            .foregroundColor(.primary)
                    }
                }
                
                Button(action: { showComments = true }) {
                    HStack(spacing: 4) {
                        Image(systemName: "bubble.left")
                        Text("\(dispute.comments)")
                            .font(.subheadline)
                    }
                    .foregroundColor(.primary)
                }
                
                Button(action: {}) {
                    Image(systemName: "paperplane")
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                Button(action: { isBookmarked.toggle() }) {
                    Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                        .foregroundColor(isBookmarked ? .blue : .primary)
                }
            }
            .font(.body)
            .padding(.horizontal)
            .padding(.vertical, 12)
            
            Divider()
        }
        .background(Color(UIColor.systemBackground))
    }
}

// MARK: - Vote Button
struct VoteButton: View {
    let title: String
    let percentage: Int
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : .primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                
                if isSelected {
                    Text("\(percentage)%")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? color : Color(UIColor.secondarySystemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(color.opacity(0.3), lineWidth: isSelected ? 0 : 1)
                    )
            )
        }
    }
}

// MARK: - Voting Results View
struct VotingResultsView: View {
    let optionA: String
    let optionB: String
    let percentageA: Int
    let percentageB: Int
    let selectedSide: String
    let totalVotes: Int
    
    var body: some View {
        VStack(spacing: 12) {
            // Option A
            ResultBar(
                title: optionA,
                percentage: percentageA,
                color: .blue,
                isWinning: percentageA > percentageB,
                isSelected: selectedSide == "A"
            )
            
            // Option B
            ResultBar(
                title: optionB,
                percentage: percentageB,
                color: .purple,
                isWinning: percentageB > percentageA,
                isSelected: selectedSide == "B"
            )
            
            Text("\(totalVotes) votes")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Result Bar
struct ResultBar: View {
    let title: String
    let percentage: Int
    let color: Color
    let isWinning: Bool
    let isSelected: Bool
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(UIColor.secondarySystemBackground))
                
                // Fill
                RoundedRectangle(cornerRadius: 8)
                    .fill(color.opacity(0.3))
                    .frame(width: geometry.size.width * CGFloat(percentage) / 100)
                
                // Content
                HStack {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(isSelected ? .semibold : .regular)
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        if isWinning {
                            Image(systemName: "crown.fill")
                                .font(.caption)
                                .foregroundColor(.yellow)
                        }
                        
                        Text("\(percentage)%")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                }
                .padding(.horizontal, 12)
                
                // Selected indicator
                if isSelected {
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(color, lineWidth: 2)
                }
            }
        }
        .frame(height: 44)
    }
}

// MARK: - Disputes List View (placeholder)
struct DisputesListView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(0..<10) { _ in
                        DisputeListItem()
                            .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("My Disputes")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct DisputeListItem: View {
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Sample Dispute Title")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("Active • 2 hours ago")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Profile View (placeholder)
struct ProfileView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile header
                    VStack(spacing: 16) {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 100, height: 100)
                            .overlay(
                                Text("JD")
                                    .font(.largeTitle)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                            )
                        
                        VStack(spacing: 4) {
                            Text("John Doe")
                                .font(.title3)
                                .fontWeight(.semibold)
                            
                            Text("@johndoe")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        // Stats
                        HStack(spacing: 40) {
                            ProfileStat(value: "152", label: "Disputes")
                            ProfileStat(value: "89%", label: "Win Rate")
                            ProfileStat(value: "$2.5K", label: "Earnings")
                        }
                    }
                    .padding()
                    
                    // Menu items
                    VStack(spacing: 0) {
                        ProfileMenuItem(icon: "person", title: "Edit Profile")
                        ProfileMenuItem(icon: "bell", title: "Notifications")
                        ProfileMenuItem(icon: "shield", title: "Privacy")
                        ProfileMenuItem(icon: "questionmark.circle", title: "Help")
                        ProfileMenuItem(icon: "arrow.right.square", title: "Sign Out", isDestructive: true)
                    }
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct ProfileStat: View {
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title3)
                .fontWeight(.semibold)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct ProfileMenuItem: View {
    let icon: String
    let title: String
    var isDestructive = false
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.body)
                .foregroundColor(isDestructive ? .red : .blue)
                .frame(width: 24)
            
            Text(title)
                .font(.body)
                .foregroundColor(isDestructive ? .red : .primary)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(UIColor.systemBackground))
    }
}

// MARK: - Notifications View
struct NotificationsView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List {
                ForEach(0..<5) { _ in
                    NotificationRow()
                }
            }
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct NotificationRow: View {
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color.blue.opacity(0.2))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: "bell.fill")
                        .font(.body)
                        .foregroundColor(.blue)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text("New bet on your dispute")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("2 hours ago")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Data Models
struct DisputeItem: Identifiable {
    let id = UUID()
    let creatorName: String
    let creatorInitials: String
    let isVerified: Bool
    let timeAgo: String
    let title: String
    let description: String?
    let category: String
    let optionA: String
    let optionB: String
    let percentageA: Int
    let percentageB: Int
    let totalVotes: Int
    let likes: Int
    let comments: Int
    let hasMedia: Bool
    let isTrending: Bool
}

// Mock data
let mockDisputeItems = [
    DisputeItem(
        creatorName: "TechGuru",
        creatorInitials: "TG",
        isVerified: true,
        timeAgo: "2h ago",
        title: "Is AI going to replace most programming jobs in the next 5 years?",
        description: "With recent advances in AI coding assistants, this debate is more relevant than ever.",
        category: "tech",
        optionA: "Yes, significant replacement",
        optionB: "No, augmentation only",
        percentageA: 42,
        percentageB: 58,
        totalVotes: 1234,
        likes: 89,
        comments: 45,
        hasMedia: false,
        isTrending: true
    ),
    DisputeItem(
        creatorName: "GameMaster",
        creatorInitials: "GM",
        isVerified: false,
        timeAgo: "5h ago",
        title: "Best battle royale game of 2024?",
        description: nil,
        category: "gaming",
        optionA: "Fortnite OG",
        optionB: "Warzone 3.0",
        percentageA: 65,
        percentageB: 35,
        totalVotes: 567,
        likes: 234,
        comments: 123,
        hasMedia: true,
        isTrending: true
    )
]

#Preview {
    HomeView()
}
