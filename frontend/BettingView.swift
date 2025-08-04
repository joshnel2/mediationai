import SwiftUI

struct BettingView: View {
    @State private var selectedTab = "active"
    @State private var showBetSlip = false
    @State private var selectedDispute: Dispute?
    @State private var betAmount = ""
    @State private var selectedSide = ""
    @State private var showAddFunds = false
    @State private var walletBalance = 2500.0
    @State private var activeBets: [Bet] = []
    @State private var searchText = ""
    
    let tabs = [
        ("active", "Active Disputes"),
        ("mybets", "My Bets"),
        ("history", "History")
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                // Clean background
                Color(UIColor.systemBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Professional header
                    headerSection
                    
                    // Search bar
                    searchBar
                    
                    // Tab selector
                    tabSelector
                    
                    // Content
                    ScrollView {
                        VStack(spacing: 16) {
                            if selectedTab == "active" {
                                activeDisputesSection
                            } else if selectedTab == "mybets" {
                                myBetsSection
                            } else {
                                historySection
                            }
                        }
                        .padding()
                    }
                }
                
                // Professional bet slip overlay
                if showBetSlip {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.spring()) {
                                showBetSlip = false
                            }
                        }
                    
                    ProfessionalBetSlip(
                        dispute: selectedDispute,
                        betAmount: $betAmount,
                        selectedSide: $selectedSide,
                        walletBalance: walletBalance,
                        isShowing: $showBetSlip,
                        onPlaceBet: placeBet
                    )
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showAddFunds) {
                AddFundsView(walletBalance: $walletBalance)
            }
        }
    }
    
    // MARK: - Header Section
    var headerSection: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Betting")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Place informed bets on dispute outcomes")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Wallet button
                Button(action: { showAddFunds = true }) {
                    HStack(spacing: 8) {
                        Image(systemName: "wallet.pass")
                            .font(.body)
                        
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("Balance")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("$\(walletBalance, specifier: "%.2f")")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(12)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding()
            
            Divider()
        }
    }
    
    // MARK: - Search Bar
    var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search disputes...", text: $searchText)
                .textFieldStyle(PlainTextFieldStyle())
            
            if !searchText.isEmpty {
                Button(action: { searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(12)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(10)
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
    
    // MARK: - Tab Selector
    var tabSelector: some View {
        HStack(spacing: 0) {
            ForEach(tabs, id: \.0) { tab in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = tab.0
                    }
                }) {
                    VStack(spacing: 8) {
                        Text(tab.1)
                            .font(.subheadline)
                            .fontWeight(selectedTab == tab.0 ? .semibold : .regular)
                            .foregroundColor(selectedTab == tab.0 ? .primary : .secondary)
                        
                        Rectangle()
                            .fill(selectedTab == tab.0 ? Color.blue : Color.clear)
                            .frame(height: 2)
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal)
        .background(Color(UIColor.systemBackground))
    }
    
    // MARK: - Active Disputes Section
    var activeDisputesSection: some View {
        VStack(spacing: 16) {
            // Stats cards
            HStack(spacing: 12) {
                StatCard(
                    title: "Total Volume",
                    value: "$125.4K",
                    change: "+12.5%",
                    icon: "chart.line.uptrend.xyaxis"
                )
                
                StatCard(
                    title: "Active Bets",
                    value: "1,234",
                    change: "+8.2%",
                    icon: "person.2"
                )
            }
            
            // Featured disputes
            ForEach(mockDisputes) { dispute in
                DisputeCard(dispute: dispute) {
                    selectedDispute = dispute
                    selectedSide = ""
                    betAmount = ""
                    withAnimation(.spring()) {
                        showBetSlip = true
                    }
                }
            }
        }
    }
    
    // MARK: - My Bets Section
    var myBetsSection: some View {
        VStack(spacing: 16) {
            if activeBets.isEmpty {
                EmptyStateView(
                    icon: "ticket",
                    title: "No Active Bets",
                    subtitle: "Start betting on disputes to see them here"
                )
                .frame(height: 300)
            } else {
                ForEach(activeBets) { bet in
                    MyBetCard(bet: bet)
                }
            }
        }
    }
    
    // MARK: - History Section
    var historySection: some View {
        VStack(spacing: 16) {
            // Summary card
            BettingSummaryCard()
            
            // History items
            ForEach(0..<5) { _ in
                HistoryItemCard()
            }
        }
    }
    
    // MARK: - Actions
    func placeBet() {
        guard let dispute = selectedDispute,
              let amount = Double(betAmount),
              !selectedSide.isEmpty else { return }
        
        // Create bet
        let newBet = Bet(
            id: UUID().uuidString,
            disputeId: dispute.id,
            disputeTitle: dispute.title,
            amount: amount,
            side: selectedSide,
            odds: selectedSide == dispute.sideA ? dispute.oddsA : dispute.oddsB,
            status: "active",
            timestamp: Date()
        )
        
        activeBets.append(newBet)
        walletBalance -= amount
        
        withAnimation(.spring()) {
            showBetSlip = false
        }
    }
}

// MARK: - Supporting Views

struct StatCard: View {
    let title: String
    let value: String
    let change: String
    let icon: String
    
    var isPositive: Bool {
        change.contains("+")
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(.blue)
                
                Spacer()
                
                Text(change)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isPositive ? .green : .red)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill((isPositive ? Color.green : Color.red).opacity(0.1))
                    )
            }
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(16)
    }
}

struct DisputeCard: View {
    let dispute: Dispute
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 16) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(dispute.category)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.blue)
                        
                        Text(dispute.title)
                            .font(.headline)
                            .foregroundColor(.primary)
                            .lineLimit(2)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Label(dispute.status, systemImage: "circle.fill")
                            .font(.caption)
                            .foregroundColor(dispute.status == "Active" ? .green : .orange)
                        
                        Text(dispute.timeRemaining)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Betting options
                HStack(spacing: 12) {
                    BettingOptionView(
                        side: dispute.sideA,
                        percentage: dispute.percentageA,
                        odds: dispute.oddsA,
                        isLeading: dispute.percentageA > 50
                    )
                    
                    Text("VS")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    
                    BettingOptionView(
                        side: dispute.sideB,
                        percentage: dispute.percentageB,
                        odds: dispute.oddsB,
                        isLeading: dispute.percentageB > 50
                    )
                }
                
                // Stats bar
                HStack(spacing: 16) {
                    HStack(spacing: 4) {
                        Image(systemName: "person.2")
                            .font(.caption)
                        Text("\(dispute.totalBets)")
                            .font(.caption)
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "dollarsign.circle")
                            .font(.caption)
                        Text("$\(dispute.totalPool, specifier: "%.0f")")
                            .font(.caption)
                    }
                    
                    Spacer()
                    
                    Text("Bet Now")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                }
                .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct BettingOptionView: View {
    let side: String
    let percentage: Int
    let odds: Double
    let isLeading: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            Text(side)
                .font(.subheadline)
                .fontWeight(.medium)
                .lineLimit(1)
            
            Text("\(percentage)%")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(isLeading ? .green : .primary)
            
            Text("\(odds, specifier: "%.2f")x")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isLeading ? Color.green.opacity(0.1) : Color(UIColor.tertiarySystemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(isLeading ? Color.green.opacity(0.3) : Color.clear, lineWidth: 1)
                )
        )
    }
}

struct ProfessionalBetSlip: View {
    let dispute: Dispute?
    @Binding var betAmount: String
    @Binding var selectedSide: String
    let walletBalance: Double
    @Binding var isShowing: Bool
    let onPlaceBet: () -> Void
    
    var potentialPayout: Double {
        guard let amount = Double(betAmount),
              let dispute = dispute else { return 0 }
        let odds = selectedSide == dispute.sideA ? dispute.oddsA : dispute.oddsB
        return amount * odds
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Handle
            Capsule()
                .fill(Color(UIColor.tertiaryLabel))
                .frame(width: 40, height: 4)
                .padding(.top, 8)
                .padding(.bottom, 20)
            
            // Content
            ScrollView {
                VStack(spacing: 24) {
                    // Dispute info
                    if let dispute = dispute {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Place Your Bet")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text(dispute.title)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Divider()
                        }
                        
                        // Side selection
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Select Side")
                                .font(.headline)
                            
                            HStack(spacing: 12) {
                                SideSelectionButton(
                                    side: dispute.sideA,
                                    odds: dispute.oddsA,
                                    isSelected: selectedSide == dispute.sideA
                                ) {
                                    selectedSide = dispute.sideA
                                }
                                
                                SideSelectionButton(
                                    side: dispute.sideB,
                                    odds: dispute.oddsB,
                                    isSelected: selectedSide == dispute.sideB
                                ) {
                                    selectedSide = dispute.sideB
                                }
                            }
                        }
                        
                        // Amount input
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Bet Amount")
                                .font(.headline)
                            
                            HStack {
                                Text("$")
                                    .font(.title3)
                                    .foregroundColor(.secondary)
                                
                                TextField("0", text: $betAmount)
                                    .font(.title3)
                                    .keyboardType(.decimalPad)
                            }
                            .padding()
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(12)
                            
                            // Quick amounts
                            HStack(spacing: 8) {
                                ForEach([10, 25, 50, 100], id: \.self) { amount in
                                    Button(action: {
                                        betAmount = "\(amount)"
                                    }) {
                                        Text("$\(amount)")
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .foregroundColor(betAmount == "\(amount)" ? .white : .primary)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 8)
                                            .background(
                                                Capsule()
                                                    .fill(betAmount == "\(amount)" ? Color.blue : Color(UIColor.secondarySystemBackground))
                                            )
                                    }
                                }
                            }
                        }
                        
                        // Summary
                        VStack(spacing: 16) {
                            HStack {
                                Text("Potential Payout")
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text("$\(potentialPayout, specifier: "%.2f")")
                                    .fontWeight(.semibold)
                            }
                            
                            HStack {
                                Text("Wallet Balance")
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text("$\(walletBalance, specifier: "%.2f")")
                                    .fontWeight(.semibold)
                                    .foregroundColor(Double(betAmount) ?? 0 > walletBalance ? .red : .primary)
                            }
                        }
                        .padding()
                        .background(Color(UIColor.tertiarySystemBackground))
                        .cornerRadius(12)
                        
                        // Place bet button
                        Button(action: onPlaceBet) {
                            Text("Place Bet")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    Color.blue
                                        .opacity(isValidBet() ? 1 : 0.5)
                                )
                                .cornerRadius(12)
                        }
                        .disabled(!isValidBet())
                    }
                }
                .padding()
            }
        }
        .frame(maxHeight: UIScreen.main.bounds.height * 0.8)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(20, corners: [.topLeft, .topRight])
        .shadow(radius: 20)
        .offset(y: isShowing ? 0 : UIScreen.main.bounds.height)
    }
    
    func isValidBet() -> Bool {
        guard let amount = Double(betAmount),
              amount > 0,
              amount <= walletBalance,
              !selectedSide.isEmpty else { return false }
        return true
    }
}

struct SideSelectionButton: View {
    let side: String
    let odds: Double
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(side)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                
                Text("\(odds, specifier: "%.2f")x")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.blue : Color(UIColor.secondarySystemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(isSelected ? Color.blue : Color.clear, lineWidth: 2)
                    )
            )
            .foregroundColor(isSelected ? .white : .primary)
        }
    }
}

struct MyBetCard: View {
    let bet: Bet
    
    var statusColor: Color {
        switch bet.status {
        case "active": return .blue
        case "won": return .green
        case "lost": return .red
        default: return .gray
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(bet.disputeTitle)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Text("Bet on: \(bet.side)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(bet.status.capitalized)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(statusColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(statusColor.opacity(0.1))
                        )
                    
                    Text(bet.timestamp, style: .time)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            Divider()
            
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Amount")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("$\(bet.amount, specifier: "%.2f")")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                
                Spacer()
                
                VStack(alignment: .center, spacing: 2) {
                    Text("Odds")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(bet.odds, specifier: "%.2f")x")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Potential")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("$\(bet.amount * bet.odds, specifier: "%.2f")")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.green)
                }
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
    }
}

struct BettingSummaryCard: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("Your Betting Summary")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 20) {
                SummaryStatView(
                    title: "Total Wagered",
                    value: "$1,234",
                    icon: "banknote",
                    color: .blue
                )
                
                Divider()
                    .frame(height: 40)
                
                SummaryStatView(
                    title: "Net Profit",
                    value: "+$456",
                    icon: "chart.line.uptrend.xyaxis",
                    color: .green
                )
                
                Divider()
                    .frame(height: 40)
                
                SummaryStatView(
                    title: "Win Rate",
                    value: "67%",
                    icon: "percent",
                    color: .orange
                )
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(16)
    }
}

struct SummaryStatView: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            
            Text(value)
                .font(.headline)
                .fontWeight(.semibold)
            
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct HistoryItemCard: View {
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Parking Dispute #234")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("Won • $50 → $125")
                    .font(.caption)
                    .foregroundColor(.green)
            }
            
            Spacer()
            
            Text("2 days ago")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
    }
}

struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text(title)
                .font(.headline)
            
            Text(subtitle)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
}

// MARK: - Data Models

struct Dispute: Identifiable {
    let id = UUID().uuidString
    let title: String
    let category: String
    let status: String
    let timeRemaining: String
    let sideA: String
    let sideB: String
    let percentageA: Int
    let percentageB: Int
    let oddsA: Double
    let oddsB: Double
    let totalBets: Int
    let totalPool: Double
}

struct Bet: Identifiable {
    let id: String
    let disputeId: String
    let disputeTitle: String
    let amount: Double
    let side: String
    let odds: Double
    let status: String
    let timestamp: Date
}

// Mock data
let mockDisputes = [
    Dispute(
        title: "Tesla Autopilot caused the accident",
        category: "Automotive",
        status: "Active",
        timeRemaining: "2h 15m",
        sideA: "Driver Error",
        sideB: "Autopilot Fault",
        percentageA: 65,
        percentageB: 35,
        oddsA: 1.54,
        oddsB: 2.86,
        totalBets: 234,
        totalPool: 5670
    ),
    Dispute(
        title: "Landlord illegally withheld security deposit",
        category: "Real Estate",
        status: "Active",
        timeRemaining: "5h 30m",
        sideA: "Tenant Right",
        sideB: "Landlord Right",
        percentageA: 72,
        percentageB: 28,
        oddsA: 1.39,
        oddsB: 3.57,
        totalBets: 156,
        totalPool: 3420
    )
]

// Corner radius extension
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

#Preview {
    BettingView()
}