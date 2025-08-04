import SwiftUI

struct AddFundsView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var walletBalance: Double
    @State private var selectedAmount = ""
    @State private var customAmount = ""
    @State private var selectedPaymentMethod = "bank"
    @State private var isProcessing = false
    @State private var showSuccessAnimation = false
    @State private var showBankConnection = false
    
    let quickAmounts = [25, 50, 100, 250, 500, 1000]
    
    var selectedAmountValue: Double? {
        if !selectedAmount.isEmpty {
            return Double(selectedAmount)
        } else if !customAmount.isEmpty {
            return Double(customAmount)
        }
        return nil
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Animated background
                AnimatedMoneyBackground()
                
                VStack(spacing: 24) {
                    // Header
                    headerSection
                    
                    ScrollView {
                        VStack(spacing: 24) {
                            // Balance Card
                            balanceCard
                            
                            // Amount Selection
                            amountSection
                            
                            // Payment Methods
                            paymentMethodsSection
                            
                            // Summary
                            if selectedAmountValue != nil {
                                summaryCard
                            }
                            
                            // Add Funds Button
                            addFundsButton
                            
                            // Security Badge
                            securityBadge
                        }
                        .padding()
                    }
                }
                
                // Floating coins animation
                if showSuccessAnimation {
                    FloatingCoinsAnimation()
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showBankConnection) {
                BankConnectionView(walletBalance: $walletBalance)
            }
        }
    }
    
    // MARK: - Header Section
    var headerSection: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
            
            Text("Add Funds")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Spacer()
            
            // Placeholder for balance
            Image(systemName: "xmark.circle.fill")
                .font(.title2)
                .opacity(0)
        }
        .padding()
    }
    
    // MARK: - Balance Card
    var balanceCard: some View {
        VStack(spacing: 12) {
            Text("Current Balance")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Text("$\(walletBalance, specifier: "%.2f")")
                .font(.system(size: 48, weight: .black, design: .rounded))
                .foregroundColor(.white)
                .contentTransition(.numericText())
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [Color.purple.opacity(0.3), Color.blue.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(
                            LinearGradient(
                                colors: [Color.purple, Color.blue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                )
        )
    }
    
    // MARK: - Amount Section
    var amountSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Select Amount")
                .font(.headline)
                .foregroundColor(.white)
            
            // Quick amounts grid
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(quickAmounts, id: \.self) { amount in
                    QuickAmountButton(
                        amount: amount,
                        isSelected: selectedAmount == String(amount),
                        action: {
                            withAnimation(.spring()) {
                                selectedAmount = String(amount)
                                customAmount = ""
                            }
                        }
                    )
                }
            }
            
            // Custom amount
            HStack {
                Text("$")
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.6))
                
                TextField("Custom amount", text: $customAmount)
                    .font(.title3)
                    .keyboardType(.decimalPad)
                    .foregroundColor(.white)
                    .onChange(of: customAmount) { _ in
                        selectedAmount = ""
                    }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(
                                customAmount.isEmpty ? Color.white.opacity(0.2) : Color.blue,
                                lineWidth: customAmount.isEmpty ? 1 : 2
                            )
                    )
            )
        }
    }
    
    // MARK: - Payment Methods Section
    var paymentMethodsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Payment Method")
                .font(.headline)
                .foregroundColor(.white)
            
            VStack(spacing: 12) {
                // Bank Transfer Option
                PaymentMethodCard(
                    icon: "building.columns.fill",
                    title: "Bank Transfer",
                    subtitle: "No fees • 1-3 days",
                    badge: "RECOMMENDED",
                    badgeColor: .green,
                    isSelected: selectedPaymentMethod == "bank",
                    gradientColors: [Color.blue, Color.cyan]
                ) {
                    withAnimation(.spring()) {
                        selectedPaymentMethod = "bank"
                    }
                }
                
                // Instant Debit Card Option
                PaymentMethodCard(
                    icon: "creditcard.fill",
                    title: "Debit Card",
                    subtitle: "2.5% fee • Instant",
                    badge: "INSTANT",
                    badgeColor: .orange,
                    isSelected: selectedPaymentMethod == "card",
                    gradientColors: [Color.purple, Color.pink]
                ) {
                    withAnimation(.spring()) {
                        selectedPaymentMethod = "card"
                    }
                }
                
                // Crypto Option
                PaymentMethodCard(
                    icon: "bitcoinsign.circle.fill",
                    title: "Cryptocurrency",
                    subtitle: "Low fees • 10-60 min",
                    badge: "CRYPTO",
                    badgeColor: .yellow,
                    isSelected: selectedPaymentMethod == "crypto",
                    gradientColors: [Color.orange, Color.yellow]
                ) {
                    withAnimation(.spring()) {
                        selectedPaymentMethod = "crypto"
                    }
                }
            }
        }
    }
    
    // MARK: - Summary Card
    var summaryCard: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Deposit Amount")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Spacer()
                Text("$\(selectedAmountValue ?? 0, specifier: "%.2f")")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }
            
            if selectedPaymentMethod == "card" {
                HStack {
                    Text("Processing Fee (2.5%)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Spacer()
                    Text("$\(((selectedAmountValue ?? 0) * 0.025), specifier: "%.2f")")
                        .font(.subheadline)
                        .foregroundColor(.orange)
                }
            }
            
            Divider()
                .background(Color.gray.opacity(0.3))
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("You'll receive")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    if selectedPaymentMethod == "bank" {
                        Text("in 1-3 business days")
                            .font(.caption2)
                            .foregroundColor(.blue)
                    } else if selectedPaymentMethod == "card" {
                        Text("instantly")
                            .font(.caption2)
                            .foregroundColor(.green)
                    }
                }
                
                Spacer()
                
                Text("$\(calculateFinalAmount(), specifier: "%.2f")")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Add Funds Button
    var addFundsButton: some View {
        Button(action: handleAddFunds) {
            HStack {
                if isProcessing {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Image(systemName: selectedPaymentMethod == "bank" ? "building.columns.fill" : "plus.circle.fill")
                    Text(selectedPaymentMethod == "bank" ? "Connect Bank & Deposit" : "Add Funds")
                        .fontWeight(.bold)
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                LinearGradient(
                    colors: selectedAmountValue == nil || isProcessing ? 
                        [Color.gray] : [Color.green, Color.blue],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(16)
            .shadow(color: .green.opacity(0.3), radius: 10, y: 5)
        }
        .disabled(selectedAmountValue == nil || isProcessing)
        .scaleEffect(isProcessing ? 0.95 : 1.0)
        .animation(.spring(), value: isProcessing)
    }
    
    // MARK: - Security Badge
    var securityBadge: some View {
        HStack(spacing: 16) {
            Image(systemName: "lock.shield.fill")
                .font(.title3)
                .foregroundColor(.green)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Bank-level Security")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text("Your payment info is encrypted and secure")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.green.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Color.green.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Helper Functions
    func calculateFinalAmount() -> Double {
        guard let amount = selectedAmountValue else { return 0 }
        
        if selectedPaymentMethod == "card" {
            return amount * 0.975 // 2.5% fee
        }
        return amount
    }
    
    func handleAddFunds() {
        if selectedPaymentMethod == "bank" {
            // Show bank connection flow
            showBankConnection = true
        } else {
            // Process other payment methods
            isProcessing = true
            
            Task {
                // Simulate API call
                try? await Task.sleep(nanoseconds: 2_000_000_000)
                
                await MainActor.run {
                    walletBalance += calculateFinalAmount()
                    isProcessing = false
                    showSuccessAnimation = true
                    
                    // Dismiss after animation
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Supporting Views

struct QuickAmountButton: View {
    let amount: Int
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text("$\(amount)")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(isSelected ? .black : .white)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.white : Color.white.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(
                                isSelected ? Color.clear : Color.white.opacity(0.3),
                                lineWidth: 1
                            )
                    )
            )
        }
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3), value: isSelected)
    }
}

struct PaymentMethodCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let badge: String?
    let badgeColor: Color
    let isSelected: Bool
    let gradientColors: [Color]
    let action: () -> Void
    
    init(icon: String, title: String, subtitle: String, badge: String? = nil, 
         badgeColor: Color = .blue, isSelected: Bool, gradientColors: [Color], action: @escaping () -> Void) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.badge = badge
        self.badgeColor = badgeColor
        self.isSelected = isSelected
        self.gradientColors = gradientColors
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Icon with gradient
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: gradientColors.map { $0.opacity(0.3) },
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(title)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        if let badge = badge {
                            Text(badge)
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(
                                    Capsule()
                                        .fill(badgeColor)
                                )
                        }
                    }
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(isSelected ? .green : .gray)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color.white.opacity(0.1) : Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(
                                isSelected ? 
                                    LinearGradient(colors: gradientColors, startPoint: .leading, endPoint: .trailing) :
                                    LinearGradient(colors: [Color.white.opacity(0.1)], startPoint: .leading, endPoint: .trailing),
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
            )
        }
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.spring(response: 0.3), value: isSelected)
    }
}

// MARK: - Animations

struct AnimatedMoneyBackground: View {
    @State private var animationPhase = 0.0
    
    var body: some View {
        ZStack {
            // Base gradient
            LinearGradient(
                colors: [Color.black, Color.green.opacity(0.1), Color.black],
                startPoint: .top,
                endPoint: .bottom
            )
            
            // Animated money symbols
            GeometryReader { geometry in
                ForEach(0..<20) { index in
                    Text("$")
                        .font(.system(size: 30))
                        .foregroundColor(.green.opacity(0.1))
                        .rotationEffect(.degrees(Double.random(in: -45...45)))
                        .position(
                            x: CGFloat.random(in: 0...geometry.size.width),
                            y: CGFloat.random(in: 0...geometry.size.height)
                        )
                        .offset(y: animationPhase)
                        .opacity(0.3 - (animationPhase / 1000))
                }
            }
        }
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.linear(duration: 10).repeatForever(autoreverses: false)) {
                animationPhase = 1000
            }
        }
    }
}

struct FloatingCoinsAnimation: View {
    @State private var coins: [CoinAnimation] = []
    
    var body: some View {
        ZStack {
            ForEach(coins) { coin in
                Text("💰")
                    .font(.system(size: coin.size))
                    .position(coin.position)
                    .opacity(coin.opacity)
            }
        }
        .onAppear {
            for i in 0..<15 {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.1) {
                    withAnimation(.easeOut(duration: 2)) {
                        let coin = CoinAnimation(
                            position: CGPoint(
                                x: CGFloat.random(in: 100...300),
                                y: UIScreen.main.bounds.height - 100
                            ),
                            size: CGFloat.random(in: 30...50),
                            opacity: 1
                        )
                        coins.append(coin)
                        
                        // Animate up and fade
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            if let index = coins.firstIndex(where: { $0.id == coin.id }) {
                                withAnimation(.easeOut(duration: 2)) {
                                    coins[index].position.y -= 300
                                    coins[index].opacity = 0
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

struct CoinAnimation: Identifiable {
    let id = UUID()
    var position: CGPoint
    var size: CGFloat
    var opacity: Double
}

#Preview {
    AddFundsView(walletBalance: .constant(100.0))
}