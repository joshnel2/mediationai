import SwiftUI

struct AddFundsView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var walletBalance: Double
    
    @State private var amount = ""
    @State private var selectedMethod = "stripe"
    @State private var isProcessing = false
    @State private var errorMessage: String?
    @State private var showSuccessAlert = false
    
    let paymentMethods = [
        ("stripe", "💳", "Credit/Debit Card", "Instant"),
        ("paypal", "🅿️", "PayPal", "Instant"),
        ("bank", "🏦", "Bank Transfer", "1-3 days"),
        ("crypto", "₿", "Cryptocurrency", "10-60 min")
    ]
    
    let quickAmounts = [25, 50, 100, 250, 500, 1000]
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.backgroundGradient
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: AppTheme.spacingXL) {
                        // Amount Section
                        VStack(alignment: .leading, spacing: AppTheme.spacingMD) {
                            Text("Amount to Add")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            // Amount Input
                            HStack {
                                Text("$")
                                    .font(.largeTitle)
                                    .foregroundColor(.white)
                                
                                TextField("0", text: $amount)
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .keyboardType(.decimalPad)
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                            }
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(AppTheme.cornerRadiusLG)
                            
                            // Quick Amount Buttons
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: AppTheme.spacingMD) {
                                ForEach(quickAmounts, id: \.self) { quickAmount in
                                    Button(action: {
                                        amount = "\(quickAmount)"
                                    }) {
                                        Text("$\(quickAmount)")
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.white)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 12)
                                            .background(Color.white.opacity(0.2))
                                            .cornerRadius(AppTheme.cornerRadiusMD)
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(AppTheme.cornerRadiusLG)
                        
                        // Payment Method Section
                        VStack(alignment: .leading, spacing: AppTheme.spacingMD) {
                            Text("Payment Method")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            ForEach(paymentMethods, id: \.0) { method in
                                PaymentMethodRow(
                                    id: method.0,
                                    icon: method.1,
                                    title: method.2,
                                    subtitle: method.3,
                                    isSelected: selectedMethod == method.0
                                ) {
                                    selectedMethod = method.0
                                }
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(AppTheme.cornerRadiusLG)
                        
                        // Fee Disclosure
                        VStack(spacing: AppTheme.spacingSM) {
                            HStack {
                                Text("Deposit Amount")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Spacer()
                                Text("$\(amount.isEmpty ? "0.00" : amount)")
                                    .font(.caption)
                                    .foregroundColor(.white)
                            }
                            
                            HStack {
                                Text("Processing Fee")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Spacer()
                                Text("$0.00")
                                    .font(.caption)
                                    .foregroundColor(.white)
                            }
                            
                            Divider()
                                .background(Color.gray)
                            
                            HStack {
                                Text("Total")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                Spacer()
                                Text("$\(amount.isEmpty ? "0.00" : amount)")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.green)
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(AppTheme.cornerRadiusMD)
                        
                        // Add Funds Button
                        Button(action: addFunds) {
                            HStack {
                                if isProcessing {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Image(systemName: "plus.circle.fill")
                                    Text("Add Funds")
                                        .fontWeight(.bold)
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
                        .disabled(isProcessing || amount.isEmpty || Double(amount) == 0)
                        
                        // Error Message
                        if let error = errorMessage {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                                .padding()
                        }
                        
                        // Legal Text
                        Text("By adding funds, you agree to our Terms of Service and confirm you are 18+ years old. Gambling can be addictive. Please play responsibly.")
                            .font(.caption2)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                    .padding()
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
        }
        .alert("Funds Added!", isPresented: $showSuccessAlert) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("$\(amount) has been added to your wallet.")
        }
    }
    
    func addFunds() {
        guard let depositAmount = Double(amount), depositAmount > 0 else { return }
        
        isProcessing = true
        errorMessage = nil
        
        Task {
            do {
                // Simulate API call
                try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
                
                // In real app, this would call:
                // let response = try await BettingService.shared.deposit(
                //     amount: depositAmount,
                //     paymentMethod: selectedMethod
                // )
                
                // Update wallet balance
                await MainActor.run {
                    walletBalance += depositAmount
                    showSuccessAlert = true
                }
                
            } catch {
                await MainActor.run {
                    errorMessage = "Failed to add funds. Please try again."
                }
            }
            
            await MainActor.run {
                isProcessing = false
            }
        }
    }
}

struct PaymentMethodRow: View {
    let id: String
    let icon: String
    let title: String
    let subtitle: String
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        HStack(spacing: AppTheme.spacingMD) {
            Text(icon)
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isSelected ? .blue : .gray)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMD)
                .fill(isSelected ? Color.blue.opacity(0.2) : Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMD)
                        .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
                )
        )
        .onTapGesture(perform: onTap)
    }
}

#Preview {
    AddFundsView(walletBalance: .constant(100.0))
}