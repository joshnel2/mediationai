import SwiftUI

struct BettingHistoryView: View {
    @State private var selectedFilter = "all"
    @State private var bets: [BetHistory] = []
    @State private var isLoading = true
    
    let filters = [
        ("all", "All Bets"),
        ("active", "Active"),
        ("won", "Won"),
        ("lost", "Lost"),
        ("refunded", "Refunded")
    ]
    
    var filteredBets: [BetHistory] {
        switch selectedFilter {
        case "active":
            return bets.filter { $0.status == .active }
        case "won":
            return bets.filter { $0.status == .won }
        case "lost":
            return bets.filter { $0.status == .lost }
        case "refunded":
            return bets.filter { $0.status == .refunded }
        default:
            return bets
        }
    }
    
    var totalWinnings: Double {
        bets.filter { $0.status == .won }.reduce(0) { $0 + ($1.payout ?? 0) }
    }
    
    var totalLosses: Double {
        bets.filter { $0.status == .lost }.reduce(0) { $0 + $1.amount }
    }
    
    var body: some View {
        ZStack {
            AppTheme.backgroundGradient
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Stats Header
                statsHeader
                
                // Filter Tabs
                filterTabs
                
                // Bets List
                if isLoading {
                    Spacer()
                    ProgressView("Loading bets...")
                        .foregroundColor(.white)
                    Spacer()
                } else if filteredBets.isEmpty {
                    Spacer()
                    VStack(spacing: AppTheme.spacingMD) {
                        Image(systemName: "tray")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        Text("No \(selectedFilter == "all" ? "" : selectedFilter) bets")
                            .foregroundColor(.gray)
                    }
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: AppTheme.spacingMD) {
                            ForEach(filteredBets) { bet in
                                BetHistoryCard(bet: bet)
                            }
                        }
                        .padding()
                    }
                }
            }
        }
        .navigationTitle("Betting History")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadBets()
        }
    }
    
    var statsHeader: some View {
        HStack(spacing: AppTheme.spacingLG) {
            VStack {
                Text("Total Won")
                    .font(.caption)
                    .foregroundColor(.gray)
                Text("$\(totalWinnings, specifier: "%.2f")")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
            }
            
            Divider()
                .frame(height: 40)
                .background(Color.gray)
            
            VStack {
                Text("Total Lost")
                    .font(.caption)
                    .foregroundColor(.gray)
                Text("$\(totalLosses, specifier: "%.2f")")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.red)
            }
            
            Divider()
                .frame(height: 40)
                .background(Color.gray)
            
            VStack {
                Text("Net P/L")
                    .font(.caption)
                    .foregroundColor(.gray)
                let net = totalWinnings - totalLosses
                Text("$\(abs(net), specifier: "%.2f")")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(net >= 0 ? .green : .red)
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(AppTheme.cornerRadiusMD)
        .padding()
    }
    
    var filterTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppTheme.spacingMD) {
                ForEach(filters, id: \.0) { filter in
                    Button(action: {
                        selectedFilter = filter.0
                    }) {
                        Text(filter.1)
                            .font(.subheadline)
                            .fontWeight(selectedFilter == filter.0 ? .semibold : .regular)
                            .foregroundColor(selectedFilter == filter.0 ? .white : .gray)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                selectedFilter == filter.0 ?
                                Color.blue : Color.white.opacity(0.1)
                            )
                            .cornerRadius(AppTheme.cornerRadiusSM)
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.bottom)
    }
    
    func loadBets() {
        // Simulate API call
        Task {
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            
            // Mock data
            await MainActor.run {
                bets = [
                    BetHistory(
                        id: "1",
                        disputeTitle: "Best Fortnite Player Debate",
                        amount: 50,
                        odds: 2.5,
                        predictedWinner: "partyA",
                        actualWinner: "partyA",
                        status: .won,
                        payout: 125,
                        placedAt: Date().addingTimeInterval(-86400 * 2)
                    ),
                    BetHistory(
                        id: "2",
                        disputeTitle: "Warzone Kill Record",
                        amount: 25,
                        odds: 1.8,
                        predictedWinner: "partyB",
                        actualWinner: "partyA",
                        status: .lost,
                        payout: nil,
                        placedAt: Date().addingTimeInterval(-86400 * 5)
                    ),
                    BetHistory(
                        id: "3",
                        disputeTitle: "Apex Legends Ranked Grind",
                        amount: 100,
                        odds: 3.2,
                        predictedWinner: "partyA",
                        actualWinner: nil,
                        status: .active,
                        payout: nil,
                        placedAt: Date().addingTimeInterval(-3600 * 2)
                    )
                ]
                isLoading = false
            }
        }
    }
}

struct BetHistoryCard: View {
    let bet: BetHistory
    
    var statusColor: Color {
        switch bet.status {
        case .active: return .orange
        case .won: return .green
        case .lost: return .red
        case .refunded: return .gray
        }
    }
    
    var statusIcon: String {
        switch bet.status {
        case .active: return "clock.fill"
        case .won: return "checkmark.circle.fill"
        case .lost: return "xmark.circle.fill"
        case .refunded: return "arrow.uturn.backward.circle.fill"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingMD) {
            // Header
            HStack {
                VStack(alignment: .leading) {
                    Text(bet.disputeTitle)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text(bet.placedAt.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: statusIcon)
                        .font(.caption)
                    Text(bet.status.rawValue.capitalized)
                        .font(.caption)
                        .fontWeight(.semibold)
                }
                .foregroundColor(statusColor)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(statusColor.opacity(0.2))
                .cornerRadius(AppTheme.cornerRadiusSM)
            }
            
            Divider()
                .background(Color.gray.opacity(0.3))
            
            // Bet Details
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Bet Amount")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("$\(bet.amount, specifier: "%.2f")")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                VStack(alignment: .center, spacing: 4) {
                    Text("Odds")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("\(bet.odds, specifier: "%.2f")x")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(bet.status == .won ? "Payout" : "Potential")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("$\(bet.payout ?? (bet.amount * bet.odds), specifier: "%.2f")")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(bet.status == .won ? .green : .white)
                }
            }
            
            // Prediction
            if bet.status != .refunded {
                HStack {
                    Text("Your Pick:")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(bet.predictedWinner == "partyA" ? "Party A" : "Party B")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    if let winner = bet.actualWinner {
                        Text("•")
                            .foregroundColor(.gray)
                        Text("Winner:")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text(winner == "partyA" ? "Party A" : "Party B")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(winner == bet.predictedWinner ? .green : .red)
                    }
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(AppTheme.cornerRadiusMD)
    }
}

// MARK: - Data Models

struct BetHistory: Identifiable {
    let id: String
    let disputeTitle: String
    let amount: Double
    let odds: Double
    let predictedWinner: String
    let actualWinner: String?
    let status: BetStatus
    let payout: Double?
    let placedAt: Date
    
    enum BetStatus: String {
        case active, won, lost, refunded
    }
}

#Preview {
    NavigationView {
        BettingHistoryView()
    }
}