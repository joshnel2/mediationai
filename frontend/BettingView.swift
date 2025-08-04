import SwiftUI

struct BettingView: View {
    @EnvironmentObject var authService: MockAuthService
    @EnvironmentObject var disputeService: MockDisputeService
    @State private var selectedDispute: Dispute?
    @State private var betAmount: String = ""
    @State private var selectedWinner: String = ""
    @State private var showPaymentSheet = false
    @State private var selectedPaymentMethod = "wallet"
    @State private var isPlacingBet = false
    @State private var errorMessage: String?
    @State private var successMessage: String?
    @State private var showConfetti = false
    @State private var animateOdds = false
    @State private var pulseAmount = false
    
    // Wallet state
    @State private var walletBalance: Double = 0.0
    @State private var pendingBalance: Double = 0.0
    @State private var isVerified = false
    
    // Betting pool data
    @State private var poolData: BettingPoolData?
    
    // UI State
    @State private var selectedTab = 0
    @State private var showBetSlip = false
    @State private var betSlipOffset: CGFloat = UIScreen.main.bounds.height
    
    let paymentMethods = [
        ("wallet", "💰", "Instant Wallet"),
        ("stripe", "💳", "Card"),
        ("paypal", "🅿️", "PayPal"),
        ("crypto", "₿", "Crypto")
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                // Animated gradient background
                AnimatedGradientBackground()
                
                VStack(spacing: 0) {
                    // Custom Navigation Header
                    customHeader
                    
                    // Tab Selection
                    tabSelector
                    
                    // Main Content
                    TabView(selection: $selectedTab) {
                        hotBetsView
                            .tag(0)
                        
                        myBetsView
                            .tag(1)
                        
                        leaderboardView
                            .tag(2)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                }
                
                // Floating Bet Slip
                if showBetSlip && selectedDispute != nil {
                    floatingBetSlip
                }
                
                // Confetti overlay
                if showConfetti {
                    ConfettiView()
                        .allowsHitTesting(false)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                showConfetti = false
                            }
                        }
                }
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            loadWalletData()
        }
    }
    
    // MARK: - Custom Header
    var customHeader: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("💸 Crashout Bets")
                        .font(.largeTitle)
                        .fontWeight(.black)
                        .foregroundColor(.white)
                    
                    Text("Bet on drama, win real money")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // Wallet Widget
                walletWidget
            }
            .padding()
            
            // Live Stats Ticker
            liveStatsTicker
        }
        .background(
            LinearGradient(
                colors: [Color.black, Color.black.opacity(0.8)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
    
    var walletWidget: some View {
        Button(action: { showPaymentSheet = true }) {
            VStack(alignment: .trailing, spacing: 2) {
                HStack(spacing: 4) {
                    Image(systemName: "dollarsign.circle.fill")
                        .font(.caption)
                    Text("$\(walletBalance, specifier: "%.2f")")
                        .font(.headline)
                        .fontWeight(.bold)
                }
                .foregroundColor(.green)
                
                if pendingBalance > 0 {
                    Text("$\(pendingBalance, specifier: "%.2f") pending")
                        .font(.caption2)
                        .foregroundColor(.orange)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(Color.green.opacity(0.2))
                    .overlay(
                        Capsule()
                            .strokeBorder(Color.green, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(ScaleButtonStyle())
        .sheet(isPresented: $showPaymentSheet) {
            AddFundsView(walletBalance: $walletBalance)
        }
    }
    
    var liveStatsTicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 20) {
                StatBadge(icon: "flame", value: "$50K", label: "Today's Pool", color: .orange)
                StatBadge(icon: "person.2.fill", value: "1.2K", label: "Active Bettors", color: .blue)
                StatBadge(icon: "trophy.fill", value: "$500", label: "Biggest Win", color: .yellow)
                StatBadge(icon: "chart.line.uptrend.xyaxis", value: "2.5x", label: "Avg Odds", color: .green)
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.05))
    }
    
    // MARK: - Tab Selector
    var tabSelector: some View {
        HStack(spacing: 0) {
            ForEach(0..<3) { index in
                Button(action: { 
                    withAnimation(.spring()) {
                        selectedTab = index
                    }
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: tabIcon(for: index))
                            .font(.title3)
                        Text(tabTitle(for: index))
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(selectedTab == index ? .white : .gray)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        selectedTab == index ?
                        Capsule()
                            .fill(Color.blue)
                            .matchedGeometryEffect(id: "tab", in: tabNamespace)
                        : nil
                    )
                }
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
        .background(Color.black.opacity(0.3))
    }
    
    @Namespace private var tabNamespace
    
    func tabIcon(for index: Int) -> String {
        switch index {
        case 0: return "flame.fill"
        case 1: return "ticket.fill"
        case 2: return "crown.fill"
        default: return ""
        }
    }
    
    func tabTitle(for index: Int) -> String {
        switch index {
        case 0: return "Hot Bets"
        case 1: return "My Bets"
        case 2: return "Leaderboard"
        default: return ""
        }
    }
    
    // MARK: - Hot Bets View
    var hotBetsView: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Featured Bet
                if let featured = disputeService.disputes.first(where: { $0.status == .active }) {
                    FeaturedBetCard(
                        dispute: featured,
                        poolData: poolData,
                        onBet: {
                            selectedDispute = featured
                            loadPoolData(for: featured.id)
                            withAnimation(.spring()) {
                                showBetSlip = true
                            }
                        }
                    )
                    .padding(.horizontal)
                }
                
                // Live Disputes Grid
                VStack(alignment: .leading, spacing: 12) {
                    Text("🔥 Live Crashouts")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal)
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(disputeService.disputes.filter { $0.status == .active }) { dispute in
                            LiveDisputeCard(
                                dispute: dispute,
                                poolAmount: Double.random(in: 100...5000),
                                onTap: {
                                    selectedDispute = dispute
                                    loadPoolData(for: dispute.id)
                                    withAnimation(.spring()) {
                                        showBetSlip = true
                                    }
                                }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
    }
    
    // MARK: - My Bets View
    var myBetsView: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Quick Stats
                HStack(spacing: 16) {
                    QuickStatCard(
                        title: "Active Bets",
                        value: "3",
                        subtitle: "$250 at risk",
                        color: .orange,
                        icon: "clock.fill"
                    )
                    
                    QuickStatCard(
                        title: "Today's P/L",
                        value: "+$125",
                        subtitle: "5 bets settled",
                        color: .green,
                        icon: "chart.line.uptrend.xyaxis"
                    )
                }
                .padding(.horizontal)
                
                // Active Bets
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Active Bets")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        NavigationLink(destination: BettingHistoryView()) {
                            Text("View All")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Mock active bets
                    VStack(spacing: 12) {
                        ActiveBetCard(
                            disputeTitle: "Best Fortnite Builder",
                            amount: 50,
                            odds: 2.5,
                            predictedWinner: "NinjaMaster",
                            timeRemaining: "2h 15m",
                            currentStatus: .winning
                        )
                        
                        ActiveBetCard(
                            disputeTitle: "Warzone Kill Record",
                            amount: 100,
                            odds: 1.8,
                            predictedWinner: "SniperElite",
                            timeRemaining: "45m",
                            currentStatus: .losing
                        )
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
    }
    
    // MARK: - Leaderboard View
    var leaderboardView: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Leaderboard Header
                VStack(spacing: 8) {
                    Text("👑 Top Bettors")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("This Week")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                // Top 3 Podium
                HStack(alignment: .bottom, spacing: 0) {
                    // 2nd Place
                    PodiumPlace(
                        rank: 2,
                        username: "BetKing",
                        profit: "$2,450",
                        avatar: "🥈"
                    )
                    
                    // 1st Place
                    PodiumPlace(
                        rank: 1,
                        username: "CrashGod",
                        profit: "$5,230",
                        avatar: "🥇"
                    )
                    
                    // 3rd Place
                    PodiumPlace(
                        rank: 3,
                        username: "LuckyAce",
                        profit: "$1,890",
                        avatar: "🥉"
                    )
                }
                .padding(.horizontal)
                
                // Rest of leaderboard
                VStack(spacing: 8) {
                    ForEach(4...10, id: \.self) { rank in
                        LeaderboardRow(
                            rank: rank,
                            username: "Player\(rank)",
                            profit: "$\(Int.random(in: 500...1500))",
                            winRate: "\(Int.random(in: 45...75))%"
                        )
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
    }
    
    // MARK: - Floating Bet Slip
    var floatingBetSlip: some View {
        VStack(spacing: 0) {
            // Handle
            Capsule()
                .fill(Color.gray)
                .frame(width: 40, height: 4)
                .padding(.top, 8)
                .padding(.bottom, 16)
            
            // Content
            ScrollView {
                VStack(spacing: 20) {
                    // Dispute Info
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Betting on")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text(selectedDispute?.title ?? "")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            withAnimation(.spring()) {
                                showBetSlip = false
                                selectedDispute = nil
                            }
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    // Odds Selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Pick Your Side")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        HStack(spacing: 12) {
                            OddsButton(
                                player: selectedDispute?.partyA?.username ?? "Party A",
                                odds: poolData?.partyAOdds ?? 1.5,
                                isSelected: selectedWinner == "partyA",
                                color: .blue
                            ) {
                                withAnimation(.spring()) {
                                    selectedWinner = "partyA"
                                    animateOdds = true
                                }
                            }
                            
                            Text("VS")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.gray)
                            
                            OddsButton(
                                player: selectedDispute?.partyB?.username ?? "Party B",
                                odds: poolData?.partyBOdds ?? 2.0,
                                isSelected: selectedWinner == "partyB",
                                color: .red
                            ) {
                                withAnimation(.spring()) {
                                    selectedWinner = "partyB"
                                    animateOdds = true
                                }
                            }
                        }
                    }
                    
                    // Bet Amount
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Bet Amount")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        // Amount Input with Animation
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .strokeBorder(
                                            pulseAmount ? Color.green : Color.white.opacity(0.3),
                                            lineWidth: 2
                                        )
                                )
                            
                            HStack {
                                Text("$")
                                    .font(.title2)
                                    .foregroundColor(.green)
                                
                                TextField("0", text: $betAmount)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .keyboardType(.numberPad)
                                    .foregroundColor(.white)
                                    .onChange(of: betAmount) { _ in
                                        withAnimation(.easeInOut(duration: 0.3)) {
                                            pulseAmount = true
                                        }
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                            pulseAmount = false
                                        }
                                    }
                            }
                            .padding()
                        }
                        .frame(height: 60)
                        
                        // Quick amounts
                        HStack(spacing: 8) {
                            ForEach([10, 25, 50, 100, 250], id: \.self) { amount in
                                QuickAmountChip(amount: amount) {
                                    betAmount = "\(amount)"
                                }
                            }
                        }
                    }
                    
                    // Potential Win Display
                    if let amount = Double(betAmount), amount > 0, !selectedWinner.isEmpty {
                        PotentialWinDisplay(
                            betAmount: amount,
                            odds: selectedWinner == "partyA" ? 
                                (poolData?.partyAOdds ?? 1.5) : 
                                (poolData?.partyBOdds ?? 2.0),
                            animate: animateOdds
                        )
                    }
                    
                    // Payment Method
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Pay With")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        HStack(spacing: 8) {
                            ForEach(paymentMethods, id: \.0) { method in
                                PaymentChip(
                                    id: method.0,
                                    icon: method.1,
                                    title: method.2,
                                    isSelected: selectedPaymentMethod == method.0
                                ) {
                                    selectedPaymentMethod = method.0
                                }
                            }
                        }
                    }
                    
                    // Place Bet Button
                    PlaceBetButton(
                        isLoading: isPlacingBet,
                        isDisabled: betAmount.isEmpty || selectedWinner.isEmpty
                    ) {
                        placeBet()
                    }
                    
                    // Messages
                    if let error = errorMessage {
                        ErrorBanner(message: error)
                    }
                    
                    if let success = successMessage {
                        SuccessBanner(message: success)
                    }
                }
                .padding()
            }
        }
        .frame(maxHeight: UIScreen.main.bounds.height * 0.8)
        .background(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(Color.black)
                .ignoresSafeArea()
        )
        .transition(.move(edge: .bottom))
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: showBetSlip)
    }
    
    // MARK: - Actions
    
    func loadWalletData() {
        Task {
            // Mock data
            walletBalance = 250.00
            pendingBalance = 50.00
            isVerified = false
        }
    }
    
    func loadPoolData(for disputeId: String) {
        Task {
            // Mock data
            poolData = BettingPoolData(
                totalPool: 5000,
                partyAPool: 3000,
                partyBPool: 2000,
                partyAOdds: 1.67,
                partyBOdds: 2.5,
                isActive: true
            )
        }
    }
    
    func placeBet() {
        guard let amount = Double(betAmount),
              let dispute = selectedDispute else { return }
        
        isPlacingBet = true
        errorMessage = nil
        successMessage = nil
        
        Task {
            // Simulate API call
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            
            await MainActor.run {
                successMessage = "Bet placed! Good luck 🎰"
                walletBalance -= amount
                pendingBalance += amount
                showConfetti = true
                
                // Reset after delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation {
                        showBetSlip = false
                        selectedDispute = nil
                        betAmount = ""
                        selectedWinner = ""
                    }
                }
                
                isPlacingBet = false
            }
        }
    }
}

// MARK: - Supporting Views

struct AnimatedGradientBackground: View {
    @State private var animateGradient = false
    
    var body: some View {
        LinearGradient(
            colors: [
                Color.black,
                Color.blue.opacity(0.3),
                Color.purple.opacity(0.2),
                Color.black
            ],
            startPoint: animateGradient ? .topLeading : .bottomLeading,
            endPoint: animateGradient ? .bottomTrailing : .topTrailing
        )
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.linear(duration: 10).repeatForever(autoreverses: true)) {
                animateGradient.toggle()
            }
        }
    }
}

struct StatBadge: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(color)
            VStack(alignment: .leading, spacing: 0) {
                Text(value)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Text(label)
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
        }
    }
}

struct FeaturedBetCard: View {
    let dispute: Dispute
    let poolData: BettingPoolData?
    let onBet: () -> Void
    
    @State private var animate = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Label("Featured", systemImage: "star.fill")
                    .font(.caption)
                    .foregroundColor(.yellow)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(Color.yellow.opacity(0.2)))
                
                Spacer()
                
                if let pool = poolData {
                    Text("$\(Int(pool.totalPool)) Pool")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
            }
            
            // Title
            Text(dispute.title)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            // Participants
            HStack {
                PlayerBadge(
                    username: dispute.partyA?.username ?? "Party A",
                    odds: poolData?.partyAOdds ?? 1.5,
                    color: .blue
                )
                
                Spacer()
                
                Text("VS")
                    .font(.caption)
                    .fontWeight(.black)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        Circle()
                            .fill(Color.red)
                            .shadow(color: .red, radius: animate ? 20 : 10)
                    )
                    .scaleEffect(animate ? 1.1 : 1.0)
                
                Spacer()
                
                PlayerBadge(
                    username: dispute.partyB?.username ?? "Party B",
                    odds: poolData?.partyBOdds ?? 2.0,
                    color: .orange
                )
            }
            
            // Bet Button
            Button(action: onBet) {
                HStack {
                    Text("Place Bet")
                        .fontWeight(.bold)
                    Image(systemName: "arrow.right")
                }
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        colors: [Color.yellow, Color.orange],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(16)
            }
            .buttonStyle(ScaleButtonStyle())
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        colors: [Color.purple.opacity(0.3), Color.blue.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .strokeBorder(
                            LinearGradient(
                                colors: [Color.purple, Color.blue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever()) {
                animate = true
            }
        }
    }
}

struct PlayerBadge: View {
    let username: String
    let odds: Double
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(username)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            Text("\(odds, specifier: "%.2f")x")
                .font(.title3)
                .fontWeight(.black)
                .foregroundColor(color)
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(color.opacity(0.2))
                        .overlay(
                            Capsule()
                                .strokeBorder(color, lineWidth: 1)
                        )
                )
        }
    }
}

struct LiveDisputeCard: View {
    let dispute: Dispute
    let poolAmount: Double
    let onTap: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Live indicator
            HStack {
                Circle()
                    .fill(Color.red)
                    .frame(width: 8, height: 8)
                    .overlay(
                        Circle()
                            .stroke(Color.red, lineWidth: 8)
                            .opacity(0.3)
                            .scaleEffect(2)
                            .opacity(0)
                            .repeatAnimation(duration: 1.5)
                    )
                
                Text("LIVE")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.red)
                
                Spacer()
                
                Text("$\(Int(poolAmount))")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
            }
            
            Text(dispute.title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .lineLimit(2)
            
            Spacer()
            
            HStack {
                Image(systemName: "person.2.fill")
                    .font(.caption2)
                Text("\(dispute.partyA?.username ?? "?") vs \(dispute.partyB?.username ?? "?")")
                    .font(.caption2)
            }
            .foregroundColor(.gray)
        }
        .padding()
        .frame(height: 120)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isPressed = false
                onTap()
            }
        }
    }
}

struct OddsButton: View {
    let player: String
    let odds: Double
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(player)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                Text("\(odds, specifier: "%.2f")x")
                    .font(.title2)
                    .fontWeight(.black)
                    .foregroundColor(isSelected ? .white : color)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? color : Color.white.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(color, lineWidth: isSelected ? 0 : 2)
                    )
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct QuickAmountChip: View {
    let amount: Int
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text("$\(amount)")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(Color.white.opacity(0.2))
                        .overlay(
                            Capsule()
                                .strokeBorder(Color.white.opacity(0.3), lineWidth: 1)
                        )
                )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct PotentialWinDisplay: View {
    let betAmount: Double
    let odds: Double
    let animate: Bool
    
    var potentialWin: Double {
        betAmount * odds * 0.95 // 5% platform fee
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Potential Win")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                HStack(spacing: 4) {
                    Text("$\(potentialWin, specifier: "%.2f")")
                        .font(.title2)
                        .fontWeight(.black)
                        .foregroundColor(.green)
                        .scaleEffect(animate ? 1.2 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: animate)
                    
                    Text("(\(odds, specifier: "%.2f")x)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            Image(systemName: "dollarsign.circle.fill")
                .font(.largeTitle)
                .foregroundColor(.green)
                .rotationEffect(.degrees(animate ? 360 : 0))
                .animation(.easeInOut(duration: 0.5), value: animate)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.green.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(Color.green.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct PaymentChip: View {
    let id: String
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(icon)
                    .font(.title3)
                Text(title)
                    .font(.caption2)
                    .fontWeight(.semibold)
            }
            .foregroundColor(isSelected ? .black : .white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.white : Color.white.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(Color.white.opacity(0.3), lineWidth: isSelected ? 0 : 1)
                    )
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct PlaceBetButton: View {
    let isLoading: Bool
    let isDisabled: Bool
    let action: () -> Void
    
    @State private var animate = false
    
    var body: some View {
        Button(action: action) {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: isDisabled ? 
                        [Color.gray, Color.gray.opacity(0.8)] :
                        [Color.green, Color.blue],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                
                // Animated shimmer effect
                if !isDisabled && !isLoading {
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0),
                            Color.white.opacity(0.3),
                            Color.white.opacity(0)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: 100)
                    .offset(x: animate ? 200 : -200)
                    .mask(
                        RoundedRectangle(cornerRadius: 16)
                    )
                }
                
                // Content
                HStack {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Place Bet")
                            .fontWeight(.bold)
                        Image(systemName: "arrow.right.circle.fill")
                    }
                }
                .foregroundColor(.white)
            }
            .frame(height: 56)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .disabled(isDisabled || isLoading)
        .buttonStyle(ScaleButtonStyle())
        .onAppear {
            withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                animate = true
            }
        }
    }
}

struct ActiveBetCard: View {
    let disputeTitle: String
    let amount: Double
    let odds: Double
    let predictedWinner: String
    let timeRemaining: String
    let currentStatus: BetStatus
    
    enum BetStatus {
        case winning, losing, neutral
        
        var color: Color {
            switch self {
            case .winning: return .green
            case .losing: return .red
            case .neutral: return .gray
            }
        }
        
        var icon: String {
            switch self {
            case .winning: return "arrow.up.circle.fill"
            case .losing: return "arrow.down.circle.fill"
            case .neutral: return "minus.circle.fill"
            }
        }
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(disputeTitle)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                HStack(spacing: 12) {
                    Label("$\(Int(amount))", systemImage: "dollarsign.circle")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Label("\(odds, specifier: "%.2f")x", systemImage: "chart.line.uptrend.xyaxis")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Label(timeRemaining, systemImage: "clock")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }
            
            Spacer()
            
            Image(systemName: currentStatus.icon)
                .font(.title2)
                .foregroundColor(currentStatus.color)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(currentStatus.color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct QuickStatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Spacer()
            }
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(subtitle)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(color.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct PodiumPlace: View {
    let rank: Int
    let username: String
    let profit: String
    let avatar: String
    
    var height: CGFloat {
        switch rank {
        case 1: return 150
        case 2: return 120
        case 3: return 90
        default: return 90
        }
    }
    
    var body: some View {
        VStack(spacing: 8) {
            VStack(spacing: 4) {
                Text(avatar)
                    .font(.system(size: rank == 1 ? 40 : 30))
                
                Text(username)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text(profit)
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
            }
            
            VStack {
                Text("\(rank)")
                    .font(.title2)
                    .fontWeight(.black)
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .background(
                LinearGradient(
                    colors: rank == 1 ? 
                        [Color.yellow, Color.orange] :
                        [Color.gray, Color.gray.opacity(0.8)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .cornerRadius(8, corners: [.topLeft, .topRight])
        }
        .frame(maxWidth: .infinity)
    }
}

struct LeaderboardRow: View {
    let rank: Int
    let username: String
    let profit: String
    let winRate: String
    
    var body: some View {
        HStack {
            Text("#\(rank)")
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(.gray)
                .frame(width: 40, alignment: .leading)
            
            Text(username)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(profit)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
                
                Text(winRate)
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
        )
    }
}

struct ErrorBanner: View {
    let message: String
    
    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.red)
            Text(message)
                .font(.caption)
                .foregroundColor(.white)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.red.opacity(0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Color.red.opacity(0.5), lineWidth: 1)
                )
        )
    }
}

struct SuccessBanner: View {
    let message: String
    
    var body: some View {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
            Text(message)
                .font(.caption)
                .foregroundColor(.white)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.green.opacity(0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Color.green.opacity(0.5), lineWidth: 1)
                )
        )
    }
}

// MARK: - Button Styles

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - View Extensions

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
    
    func repeatAnimation(duration: Double) -> some View {
        self.onAppear {
            withAnimation(.easeInOut(duration: duration).repeatForever()) {
                // Animation will be handled by the view
            }
        }
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

// MARK: - Data Models

struct BettingPoolData {
    let totalPool: Double
    let partyAPool: Double
    let partyBPool: Double
    let partyAOdds: Double
    let partyBOdds: Double
    let isActive: Bool
}

#Preview {
    BettingView()
        .environmentObject(MockAuthService())
        .environmentObject(MockDisputeService())
}