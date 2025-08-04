import SwiftUI

struct AddFundsView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var walletBalance: Double
    
    @State private var amount = ""
    @State private var selectedMethod = "stripe"
    @State private var isProcessing = false
    @State private var errorMessage: String?
    @State private var showSuccessAlert = false
    @State private var animateCoins = false
    @State private var selectedQuickAmount: Int?
    
    let paymentMethods = [
        ("stripe", "💳", "Credit/Debit Card", "Instant", Color.blue),
        ("paypal", "🅿️", "PayPal", "Instant", Color.indigo),
        ("bank", "🏦", "Bank Transfer", "1-3 days", Color.green),
        ("crypto", "₿", "Cryptocurrency", "10-60 min", Color.orange)
    ]
    
    let quickAmounts = [25, 50, 100, 250, 500, 1000]
    
    var body: some View {
        NavigationView {
            ZStack {
                // Animated background
                AnimatedMoneyBackground()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header with balance
                        headerSection
                        
                        // Amount Section with animations
                        amountSection
                        
                        // Payment Methods
                        paymentMethodsSection
                        
                        // Summary Card
                        summaryCard
                        
                        // Add Funds Button
                        addFundsButton
                        
                        // Security Badge
                        securityBadge
                    }
                    .padding()
                }
                
                // Floating coins animation
                if animateCoins {
                    FloatingCoinsAnimation()
                        .allowsHitTesting(false)
                }
            }
            .navigationBarHidden(true)
        }
        .alert("💰 Funds Added!", isPresented: $showSuccessAlert) {
            Button("Awesome!") {
                dismiss()
            }
        } message: {
            Text("$\(amount) has been added to your wallet. Ready to bet!")
        }
    }
    
    // MARK: - Header Section
    var headerSection: some View {
        VStack(spacing: 16) {
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("Current Balance")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("$\(walletBalance, specifier: "%.2f")")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
            }
            
            VStack(spacing: 8) {
                Text("Add Funds")
                    .font(.largeTitle)
                    .fontWeight(.black)
                    .foregroundColor(.white)
                
                Text("Power up your wallet")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
    }
    
    // MARK: - Amount Section
    var amountSection: some View {
        VStack(spacing: 20) {
            // Amount Display
            ZStack {
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
                
                VStack(spacing: 16) {
                    Text("Enter Amount")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    HStack(alignment: .center, spacing: 0) {
                        Text("$")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(.white.opacity(0.5))
                        
                        TextField("0", text: $amount)
                            .font(.system(size: 50, weight: .bold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .keyboardType(.numberPad)
                            .frame(maxWidth: 200)
                            .onChange(of: amount) { _ in
                                withAnimation(.spring()) {
                                    selectedQuickAmount = nil
                                }
                            }
                    }
                    
                    // USD label
                    Text("USD")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.gray)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(Color.white.opacity(0.1)))
                }
                .padding(.vertical, 30)
            }
            .frame(height: 180)
            
            // Quick Amount Grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
                ForEach(quickAmounts, id: \.self) { quickAmount in
                    QuickAmountButton(
                        amount: quickAmount,
                        isSelected: selectedQuickAmount == quickAmount
                    ) {
                        withAnimation(.spring()) {
                            amount = "\(quickAmount)"
                            selectedQuickAmount = quickAmount
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Payment Methods Section
    var paymentMethodsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Payment Method")
                .font(.headline)
                .foregroundColor(.white)
            
            VStack(spacing: 12) {
                ForEach(paymentMethods, id: \.0) { method in
                    PaymentMethodCard(
                        id: method.0,
                        icon: method.1,
                        title: method.2,
                        subtitle: method.3,
                        color: method.4,
                        isSelected: selectedMethod == method.0
                    ) {
                        withAnimation(.spring()) {
                            selectedMethod = method.0
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Summary Card
    var summaryCard: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Summary")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
            }
            
            VStack(spacing: 12) {
                SummaryRow(label: "Deposit", value: "$\(amount.isEmpty ? "0.00" : amount)", color: .white)
                SummaryRow(label: "Processing Fee", value: "$0.00", color: .gray)
                
                Divider()
                    .background(Color.gray.opacity(0.3))
                
                HStack {
                    Text("Total")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Text("$\(amount.isEmpty ? "0.00" : amount)")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                        
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
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
    }
    
    // MARK: - Add Funds Button
    var addFundsButton: some View {
        Button(action: addFunds) {
            ZStack {
                // Animated gradient background
                AnimatedButtonBackground(isDisabled: isProcessing || amount.isEmpty || Double(amount) == 0)
                
                HStack(spacing: 12) {
                    if isProcessing {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                        Text("Add Funds")
                            .font(.headline)
                            .fontWeight(.bold)
                    }
                }
                .foregroundColor(.white)
            }
            .frame(height: 60)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .green.opacity(0.3), radius: 10, y: 5)
        }
        .disabled(isProcessing || amount.isEmpty || Double(amount) == 0)
        .scaleEffect(isProcessing ? 0.95 : 1.0)
        .animation(.spring(), value: isProcessing)
    }
    
    // MARK: - Security Badge
    var securityBadge: some View {
        VStack(spacing: 12) {
            HStack(spacing: 16) {
                Image(systemName: "lock.shield.fill")
                    .font(.title2)
                    .foregroundColor(.green)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Bank-Level Security")
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
            
            Text("By adding funds, you confirm you are 18+ years old. Please gamble responsibly.")
                .font(.caption2)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
    }
    
    // MARK: - Actions
    func addFunds() {
        guard let depositAmount = Double(amount), depositAmount > 0 else { return }
        
        isProcessing = true
        errorMessage = nil
        
        // Trigger coin animation
        withAnimation {
            animateCoins = true
        }
        
        Task {
            try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
            
            await MainActor.run {
                walletBalance += depositAmount
                showSuccessAlert = true
                animateCoins = false
                isProcessing = false
            }
        }
    }
}

// MARK: - Supporting Views

struct AnimatedMoneyBackground: View {
    @State private var animate = false
    
    var body: some View {
        ZStack {
            // Base gradient
            LinearGradient(
                colors: [Color.black, Color.black.opacity(0.9)],
                startPoint: .top,
                endPoint: .bottom
            )
            
            // Animated money symbols
            ForEach(0..<15) { index in
                Text(["💵", "💰", "💸", "🪙", "💎"].randomElement()!)
                    .font(.title)
                    .opacity(0.1)
                    .offset(
                        x: CGFloat.random(in: -150...150),
                        y: animate ? -UIScreen.main.bounds.height : UIScreen.main.bounds.height
                    )
                    .animation(
                        .linear(duration: Double.random(in: 10...20))
                            .repeatForever(autoreverses: false)
                            .delay(Double.random(in: 0...5)),
                        value: animate
                    )
            }
        }
        .ignoresSafeArea()
        .onAppear {
            animate = true
        }
    }
}

struct QuickAmountButton: View {
    let amount: Int
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text("$\(amount)")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(isSelected ? .black : .white)
                
                if amount >= 500 {
                    Text("Popular")
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundColor(isSelected ? .black.opacity(0.7) : .yellow)
                }
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
            .scaleEffect(isSelected ? 1.05 : 1.0)
        }
        .buttonStyle(BounceButtonStyle())
    }
}

struct PaymentMethodCard: View {
    let id: String
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Icon with colored background
                ZStack {
                    Circle()
                        .fill(color.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Text(icon)
                        .font(.title2)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                ZStack {
                    Circle()
                        .strokeBorder(isSelected ? color : Color.gray, lineWidth: 2)
                        .frame(width: 24, height: 24)
                    
                    if isSelected {
                        Circle()
                            .fill(color)
                            .frame(width: 16, height: 16)
                            .transition(.scale)
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? color.opacity(0.1) : Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(
                                isSelected ? color : Color.white.opacity(0.1),
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct SummaryRow: View {
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
            
            Spacer()
            
            Text(value)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
    }
}

struct AnimatedButtonBackground: View {
    let isDisabled: Bool
    @State private var animateGradient = false
    
    var body: some View {
        if isDisabled {
            Color.gray
        } else {
            LinearGradient(
                colors: [
                    Color.green,
                    Color.blue,
                    Color.green
                ],
                startPoint: animateGradient ? .leading : .trailing,
                endPoint: animateGradient ? .trailing : .leading
            )
            .onAppear {
                withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                    animateGradient = true
                }
            }
        }
    }
}

struct FloatingCoinsAnimation: View {
    var body: some View {
        ZStack {
            ForEach(0..<20) { index in
                CoinView()
                    .offset(
                        x: CGFloat.random(in: -100...100),
                        y: UIScreen.main.bounds.height
                    )
                    .animation(
                        .easeOut(duration: 2)
                            .delay(Double(index) * 0.1),
                        value: true
                    )
            }
        }
    }
}

struct CoinView: View {
    @State private var animate = false
    
    var body: some View {
        Text("🪙")
            .font(.system(size: CGFloat.random(in: 20...40)))
            .rotationEffect(.degrees(animate ? 360 : 0))
            .offset(y: animate ? -UIScreen.main.bounds.height - 100 : 0)
            .opacity(animate ? 0 : 1)
            .onAppear {
                withAnimation {
                    animate = true
                }
            }
    }
}

// MARK: - Button Styles

struct BounceButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.5), value: configuration.isPressed)
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

#Preview {
    AddFundsView(walletBalance: .constant(100.0))
}