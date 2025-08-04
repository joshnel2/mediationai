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
    
    // Wallet state
    @State private var walletBalance: Double = 0.0
    @State private var pendingBalance: Double = 0.0
    @State private var isVerified = false
    
    // Betting pool data
    @State private var poolData: BettingPoolData?
    
    let paymentMethods = [
        ("wallet", "💰", "Wallet Balance"),
        ("stripe", "💳", "Credit/Debit Card"),
        ("paypal", "🅿️", "PayPal"),
        ("crypto", "₿", "Cryptocurrency")
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.backgroundGradient
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: AppTheme.spacingXL) {
                        // Wallet Section
                        walletSection
                        
                        // Active Disputes Section
                        activeDisputesSection
                        
                        // Betting Form
                        if selectedDispute != nil {
                            bettingFormSection
                        }
                        
                        // My Bets Section
                        myBetsSection
                    }
                    .padding()
                }
            }
            .navigationTitle("💸 Bet on Crashouts")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showPaymentSheet = true }) {
                        Label("Add Funds", systemImage: "plus.circle.fill")
                    }
                }
            }
        }
        .sheet(isPresented: $showPaymentSheet) {
            AddFundsView(walletBalance: $walletBalance)
        }
        .onAppear {
            loadWalletData()
        }
    }
    
    var walletSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingMD) {
            Text("Your Wallet")
                .font(.headline)
                .foregroundColor(.white)
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Available")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("$\(walletBalance, specifier: "%.2f")")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("In Bets")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("$\(pendingBalance, specifier: "%.2f")")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                }
            }
            
            if !isVerified {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.yellow)
                    Text("Verify your account to increase limits")
                        .font(.caption)
                        .foregroundColor(.white)
                    Spacer()
                    Button("Verify") {
                        // Navigate to verification
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
                .padding(.vertical, AppTheme.spacingSM)
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(AppTheme.cornerRadiusLG)
    }
    
    var activeDisputesSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingMD) {
            HStack {
                Text("Active Crashouts")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button("View All") {
                    // Navigate to all disputes
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppTheme.spacingMD) {
                    ForEach(disputeService.disputes.filter { $0.status == .active }) { dispute in
                        DisputeBettingCard(
                            dispute: dispute,
                            isSelected: selectedDispute?.id == dispute.id,
                            poolData: poolData
                        ) {
                            selectedDispute = dispute
                            loadPoolData(for: dispute.id)
                        }
                    }
                }
            }
        }
    }
    
    var bettingFormSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingMD) {
            Text("Place Your Bet")
                .font(.headline)
                .foregroundColor(.white)
            
            // Bet Amount
            VStack(alignment: .leading) {
                Text("Amount")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                HStack {
                    Text("$")
                        .foregroundColor(.white)
                    TextField("0.00", text: $betAmount)
                        .keyboardType(.decimalPad)
                        .foregroundColor(.white)
                        .font(.title2)
                    
                    // Quick amount buttons
                    HStack(spacing: 8) {
                        ForEach([10, 25, 50, 100], id: \.self) { amount in
                            Button("$\(amount)") {
                                betAmount = "\(amount)"
                            }
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(AppTheme.cornerRadiusSM)
                        }
                    }
                }
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(AppTheme.cornerRadiusMD)
            }
            
            // Pick Winner
            VStack(alignment: .leading) {
                Text("Pick Winner")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                HStack(spacing: AppTheme.spacingMD) {
                    ForEach(["partyA", "partyB"], id: \.self) { party in
                        BetOptionCard(
                            party: party,
                            user: party == "partyA" ? selectedDispute?.partyA : selectedDispute?.partyB,
                            odds: party == "partyA" ? poolData?.partyAOdds ?? 1.0 : poolData?.partyBOdds ?? 1.0,
                            isSelected: selectedWinner == party
                        ) {
                            selectedWinner = party
                        }
                    }
                }
            }
            
            // Payment Method
            VStack(alignment: .leading) {
                Text("Payment Method")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: AppTheme.spacingMD) {
                        ForEach(paymentMethods, id: \.0) { method in
                            PaymentMethodButton(
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
            }
            
            // Potential Payout
            if let amount = Double(betAmount), amount > 0, !selectedWinner.isEmpty {
                let odds = selectedWinner == "partyA" ? (poolData?.partyAOdds ?? 1.0) : (poolData?.partyBOdds ?? 1.0)
                let payout = amount * odds * 0.95 // 5% platform fee
                
                HStack {
                    Text("Potential Payout")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Spacer()
                    Text("$\(payout, specifier: "%.2f")")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
                .padding()
                .background(Color.green.opacity(0.1))
                .cornerRadius(AppTheme.cornerRadiusMD)
            }
            
            // Place Bet Button
            Button(action: placeBet) {
                HStack {
                    if isPlacingBet {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Place Bet")
                            .fontWeight(.bold)
                        Image(systemName: "arrow.right.circle.fill")
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        colors: [Color.green, Color.blue],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(AppTheme.cornerRadiusMD)
            }
            .disabled(isPlacingBet || betAmount.isEmpty || selectedWinner.isEmpty)
            
            // Error/Success Messages
            if let error = errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding()
            }
            
            if let success = successMessage {
                Text(success)
                    .font(.caption)
                    .foregroundColor(.green)
                    .padding()
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(AppTheme.cornerRadiusLG)
    }
    
    var myBetsSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingMD) {
            HStack {
                Text("My Active Bets")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                NavigationLink(destination: BettingHistoryView()) {
                    Text("View History")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
            
            // Active bets list would go here
            Text("No active bets")
                .font(.caption)
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity)
                .padding()
        }
    }
    
    // MARK: - Actions
    
    func loadWalletData() {
        // API call to load wallet data
        Task {
            do {
                // let wallet = try await BettingService.shared.getWallet()
                // walletBalance = wallet.balance
                // pendingBalance = wallet.pendingBalance
                // isVerified = wallet.isVerified
                
                // Mock data for now
                walletBalance = 250.00
                pendingBalance = 50.00
                isVerified = false
            } catch {
                errorMessage = "Failed to load wallet data"
            }
        }
    }
    
    func loadPoolData(for disputeId: String) {
        // API call to load betting pool data
        Task {
            do {
                // let pool = try await BettingService.shared.getPool(disputeId: disputeId)
                // poolData = pool
                
                // Mock data for now
                poolData = BettingPoolData(
                    totalPool: 5000,
                    partyAPool: 3000,
                    partyBPool: 2000,
                    partyAOdds: 1.67,
                    partyBOdds: 2.5,
                    isActive: true
                )
            } catch {
                errorMessage = "Failed to load pool data"
            }
        }
    }
    
    func placeBet() {
        guard let amount = Double(betAmount),
              let dispute = selectedDispute else { return }
        
        isPlacingBet = true
        errorMessage = nil
        successMessage = nil
        
        Task {
            do {
                // let response = try await BettingService.shared.placeBet(
                //     disputeId: dispute.id,
                //     amount: amount,
                //     predictedWinner: selectedWinner,
                //     paymentMethod: selectedPaymentMethod
                // )
                
                // if response.paymentRequired {
                //     // Handle external payment
                // } else {
                //     successMessage = "Bet placed successfully!"
                //     walletBalance -= amount
                //     pendingBalance += amount
                // }
                
                // Mock success for now
                successMessage = "Bet placed successfully! Odds: \(selectedWinner == "partyA" ? poolData?.partyAOdds ?? 1.0 : poolData?.partyBOdds ?? 1.0)x"
                walletBalance -= amount
                pendingBalance += amount
                
                // Reset form
                betAmount = ""
                selectedWinner = ""
                selectedDispute = nil
                
            } catch {
                errorMessage = error.localizedDescription
            }
            
            isPlacingBet = false
        }
    }
}

// MARK: - Supporting Views

struct DisputeBettingCard: View {
    let dispute: Dispute
    let isSelected: Bool
    let poolData: BettingPoolData?
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingSM) {
            Text(dispute.title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .lineLimit(2)
            
            HStack {
                Image(systemName: "person.2.fill")
                    .font(.caption)
                Text("\(dispute.partyA?.username ?? "Unknown") vs \(dispute.partyB?.username ?? "Unknown")")
                    .font(.caption)
            }
            .foregroundColor(.gray)
            
            if let pool = poolData {
                Text("Pool: $\(Int(pool.totalPool))")
                    .font(.caption)
                    .foregroundColor(.green)
            }
        }
        .frame(width: 200)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMD)
                .fill(isSelected ? Color.blue.opacity(0.3) : Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMD)
                        .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
                )
        )
        .onTapGesture(perform: onTap)
    }
}

struct BetOptionCard: View {
    let party: String
    let user: User?
    let odds: Double
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        VStack(spacing: AppTheme.spacingSM) {
            Image(systemName: "person.circle.fill")
                .font(.largeTitle)
                .foregroundColor(.white)
            
            Text(user?.username ?? party)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            Text("\(odds, specifier: "%.2f")x")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.green)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMD)
                .fill(isSelected ? Color.blue.opacity(0.3) : Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMD)
                        .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
                )
        )
        .onTapGesture(perform: onTap)
    }
}

struct PaymentMethodButton: View {
    let id: String
    let icon: String
    let title: String
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        VStack(spacing: 4) {
            Text(icon)
                .font(.title2)
            Text(title)
                .font(.caption)
                .foregroundColor(.white)
        }
        .frame(width: 100)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMD)
                .fill(isSelected ? Color.blue.opacity(0.3) : Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMD)
                        .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
                )
        )
        .onTapGesture(perform: onTap)
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