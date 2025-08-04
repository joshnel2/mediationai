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
                // Clean background
                Color(UIColor.systemBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Balance display
                        balanceCard
                        
                        // Amount selection
                        amountSection
                        
                        // Payment methods
                        paymentMethodsSection
                        
                        // Summary
                        if selectedAmountValue != nil {
                            summaryCard
                        }
                        
                        // Add funds button
                        addFundsButton
                        
                        // Security info
                        securityInfo
                    }
                    .padding()
                }
                
                // Success overlay
                if showSuccessAnimation {
                    SuccessOverlay()
                        .transition(.opacity)
                }
            }
            .navigationTitle("Add Funds")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showBankConnection) {
                BankConnectionView(walletBalance: $walletBalance)
            }
        }
    }
    
    // MARK: - Balance Card
    var balanceCard: some View {
        VStack(spacing: 16) {
            VStack(spacing: 8) {
                Text("Current Balance")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("$\(walletBalance, specifier: "%.2f")")
                    .font(.system(size: 44, weight: .semibold, design: .rounded))
                    .contentTransition(.numericText())
            }
            
            HStack(spacing: 32) {
                VStack(spacing: 4) {
                    Text("$5,234")
                        .font(.headline)
                        .fontWeight(.semibold)
                    Text("Total Deposited")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Divider()
                    .frame(height: 30)
                
                VStack(spacing: 4) {
                    Text("$1,234")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                    Text("Total Winnings")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 24)
        .frame(maxWidth: .infinity)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(16)
    }
    
    // MARK: - Amount Section
    var amountSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Select Amount")
                .font(.headline)
            
            // Quick amount grid
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(quickAmounts, id: \.self) { amount in
                    QuickAmountButton(
                        amount: amount,
                        isSelected: selectedAmount == String(amount)
                    ) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedAmount = String(amount)
                            customAmount = ""
                        }
                    }
                }
            }
            
            // Custom amount
            VStack(alignment: .leading, spacing: 8) {
                Text("Or enter custom amount")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack {
                    Text("$")
                        .font(.title3)
                        .foregroundColor(.secondary)
                    
                    TextField("0", text: $customAmount)
                        .font(.title3)
                        .keyboardType(.decimalPad)
                        .onChange(of: customAmount) { _ in
                            selectedAmount = ""
                        }
                }
                .padding()
                .background(Color(UIColor.tertiarySystemBackground))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(
                            customAmount.isEmpty ? Color.clear : Color.blue,
                            lineWidth: 2
                        )
                )
            }
        }
    }
    
    // MARK: - Payment Methods Section
    var paymentMethodsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Payment Method")
                .font(.headline)
            
            VStack(spacing: 12) {
                PaymentMethodCard(
                    icon: "building.columns",
                    title: "Bank Transfer",
                    subtitle: "Free • 1-3 business days",
                    badge: "RECOMMENDED",
                    isSelected: selectedPaymentMethod == "bank"
                ) {
                    selectedPaymentMethod = "bank"
                }
                
                PaymentMethodCard(
                    icon: "creditcard",
                    title: "Debit Card",
                    subtitle: "2.5% fee • Instant",
                    badge: nil,
                    isSelected: selectedPaymentMethod == "card"
                ) {
                    selectedPaymentMethod = "card"
                }
                
                PaymentMethodCard(
                    icon: "applelogo",
                    title: "Apple Pay",
                    subtitle: "2.5% fee • Instant",
                    badge: nil,
                    isSelected: selectedPaymentMethod == "apple"
                ) {
                    selectedPaymentMethod = "apple"
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
                    .foregroundColor(.secondary)
                Spacer()
                Text("$\(selectedAmountValue ?? 0, specifier: "%.2f")")
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            
            if selectedPaymentMethod != "bank" {
                HStack {
                    Text("Processing Fee")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("$\(((selectedAmountValue ?? 0) * 0.025), specifier: "%.2f")")
                        .font(.subheadline)
                        .foregroundColor(.orange)
                }
            }
            
            Divider()
            
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("You'll receive")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Text(processingTimeText())
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text("$\(calculateFinalAmount(), specifier: "%.2f")")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.green)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
    }
    
    // MARK: - Add Funds Button
    var addFundsButton: some View {
        Button(action: handleAddFunds) {
            HStack {
                if isProcessing {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Image(systemName: paymentMethodIcon())
                    Text(paymentMethodButtonText())
                        .fontWeight(.semibold)
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                Color.blue
                    .opacity(selectedAmountValue == nil || isProcessing ? 0.5 : 1)
            )
            .cornerRadius(12)
        }
        .disabled(selectedAmountValue == nil || isProcessing)
    }
    
    // MARK: - Security Info
    var securityInfo: some View {
        HStack(spacing: 16) {
            Image(systemName: "lock.shield.fill")
                .font(.title2)
                .foregroundColor(.green)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Secure & Encrypted")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("Your payment information is protected with bank-level security")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(UIColor.tertiarySystemBackground))
        .cornerRadius(12)
    }
    
    // MARK: - Helper Functions
    func calculateFinalAmount() -> Double {
        guard let amount = selectedAmountValue else { return 0 }
        
        if selectedPaymentMethod == "bank" {
            return amount
        } else {
            return amount * 0.975 // 2.5% fee
        }
    }
    
    func processingTimeText() -> String {
        switch selectedPaymentMethod {
        case "bank":
            return "in 1-3 business days"
        default:
            return "instantly"
        }
    }
    
    func paymentMethodIcon() -> String {
        switch selectedPaymentMethod {
        case "bank":
            return "building.columns.fill"
        case "apple":
            return "applelogo"
        default:
            return "creditcard.fill"
        }
    }
    
    func paymentMethodButtonText() -> String {
        if selectedPaymentMethod == "bank" {
            return "Connect Bank & Deposit"
        } else {
            return "Add Funds"
        }
    }
    
    func handleAddFunds() {
        if selectedPaymentMethod == "bank" {
            showBankConnection = true
        } else {
            isProcessing = true
            
            Task {
                try? await Task.sleep(nanoseconds: 2_000_000_000)
                
                await MainActor.run {
                    walletBalance += calculateFinalAmount()
                    isProcessing = false
                    
                    withAnimation(.spring()) {
                        showSuccessAnimation = true
                    }
                    
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
            Text("$\(amount)")
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? .white : .primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(isSelected ? Color.blue : Color(UIColor.tertiarySystemBackground))
                )
        }
    }
}

struct PaymentMethodCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let badge: String?
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? .blue : .secondary)
                    .frame(width: 32)
                
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text(title)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                        
                        if let badge = badge {
                            Text(badge)
                                .font(.caption2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.green)
                                .cornerRadius(4)
                        }
                    }
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(isSelected ? .blue : .quaternary)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(UIColor.secondarySystemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(isSelected ? Color.blue : Color.clear, lineWidth: 2)
                    )
            )
        }
    }
}

struct SuccessOverlay: View {
    @State private var scale = 0.5
    @State private var opacity = 0.0
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 64))
                    .foregroundColor(.green)
                
                Text("Success!")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Funds added to your wallet")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(UIColor.systemBackground))
            )
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                scale = 1.0
                opacity = 1.0
            }
        }
    }
}

#Preview {
    AddFundsView(walletBalance: .constant(100.0))
}