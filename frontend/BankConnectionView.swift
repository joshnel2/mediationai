import SwiftUI
import WebKit

struct BankConnectionView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var walletBalance: Double
    @State private var showPlaidLink = false
    @State private var connectedBanks: [BankAccount] = []
    @State private var isLoadingBanks = true
    @State private var selectedBank: BankAccount?
    @State private var depositAmount = ""
    @State private var isProcessing = false
    @State private var showSuccessAlert = false
    @State private var selectedDepositType = "instant"
    
    let depositTypes = [
        ("instant", "⚡", "Instant", "2.5% fee", "Available immediately"),
        ("standard", "🏦", "Standard", "No fee", "1-3 business days")
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(
                    colors: [Color.black, Color.blue.opacity(0.2)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        headerSection
                        
                        // Connected Banks
                        connectedBanksSection
                        
                        // Add Bank Button
                        if connectedBanks.isEmpty {
                            addBankPrompt
                        } else {
                            addAnotherBankButton
                        }
                        
                        // Deposit Section
                        if selectedBank != nil {
                            depositSection
                        }
                        
                        // Security Info
                        securityInfo
                    }
                    .padding()
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                loadBankAccounts()
            }
            .sheet(isPresented: $showPlaidLink) {
                PlaidLinkView { publicToken in
                    handlePlaidSuccess(publicToken: publicToken)
                }
            }
            .alert("Deposit Initiated! 🎉", isPresented: $showSuccessAlert) {
                Button("Great!") {
                    dismiss()
                }
            } message: {
                Text(selectedDepositType == "instant" ? 
                     "Your funds are now available!" : 
                     "Your deposit will arrive in 1-3 business days.")
            }
        }
    }
    
    // MARK: - Header
    var headerSection: some View {
        VStack(spacing: 16) {
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "arrow.left.circle.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("Wallet Balance")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("$\(walletBalance, specifier: "%.2f")")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
            }
            
            VStack(spacing: 8) {
                Text("Bank Transfer")
                    .font(.largeTitle)
                    .fontWeight(.black)
                    .foregroundColor(.white)
                
                Text("Connect your bank for easy deposits")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
    }
    
    // MARK: - Connected Banks Section
    var connectedBanksSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            if !connectedBanks.isEmpty {
                Text("Your Banks")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            
            if isLoadingBanks {
                HStack {
                    Spacer()
                    ProgressView("Loading banks...")
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding()
            } else {
                ForEach(connectedBanks) { bank in
                    BankCard(
                        bank: bank,
                        isSelected: selectedBank?.id == bank.id
                    ) {
                        withAnimation(.spring()) {
                            selectedBank = bank
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Add Bank Prompt
    var addBankPrompt: some View {
        VStack(spacing: 20) {
            Image(systemName: "building.columns.circle")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            Text("No banks connected yet")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            Text("Connect your bank account to deposit funds with zero fees (1-3 days) or instant deposits with a small fee.")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
            Button(action: { showPlaidLink = true }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Connect Bank Account")
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        colors: [Color.blue, Color.purple],
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
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Add Another Bank Button
    var addAnotherBankButton: some View {
        Button(action: { showPlaidLink = true }) {
            HStack {
                Image(systemName: "plus.circle")
                    .font(.caption)
                Text("Add Another Bank")
                    .font(.caption)
                    .fontWeight(.semibold)
            }
            .foregroundColor(.blue)
        }
    }
    
    // MARK: - Deposit Section
    var depositSection: some View {
        VStack(spacing: 20) {
            // Deposit Type Selection
            VStack(alignment: .leading, spacing: 12) {
                Text("Deposit Type")
                    .font(.headline)
                    .foregroundColor(.white)
                
                ForEach(depositTypes, id: \.0) { type in
                    DepositTypeCard(
                        id: type.0,
                        icon: type.1,
                        title: type.2,
                        fee: type.3,
                        timing: type.4,
                        isSelected: selectedDepositType == type.0
                    ) {
                        withAnimation(.spring()) {
                            selectedDepositType = type.0
                        }
                    }
                }
            }
            
            // Amount Input
            VStack(alignment: .leading, spacing: 12) {
                Text("Amount")
                    .font(.headline)
                    .foregroundColor(.white)
                
                HStack {
                    Text("$")
                        .font(.title2)
                        .foregroundColor(.white.opacity(0.5))
                    
                    TextField("0", text: $depositAmount)
                        .font(.title2)
                        .fontWeight(.bold)
                        .keyboardType(.decimalPad)
                        .foregroundColor(.white)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(Color.white.opacity(0.3), lineWidth: 1)
                        )
                )
                
                // Quick amounts
                HStack(spacing: 8) {
                    ForEach([50, 100, 250, 500], id: \.self) { amount in
                        Button(action: {
                            depositAmount = "\(amount)"
                        }) {
                            Text("$\(amount)")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule()
                                        .fill(Color.white.opacity(0.2))
                                )
                        }
                    }
                }
            }
            
            // Fee Calculation
            if let amount = Double(depositAmount), amount > 0 {
                FeeCalculationCard(
                    amount: amount,
                    isInstant: selectedDepositType == "instant"
                )
            }
            
            // Deposit Button
            Button(action: processDeposit) {
                HStack {
                    if isProcessing {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Image(systemName: "arrow.down.circle.fill")
                        Text("Deposit Funds")
                            .fontWeight(.bold)
                    }
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        colors: isProcessing || depositAmount.isEmpty ? 
                            [Color.gray] : [Color.green, Color.blue],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(16)
            }
            .disabled(isProcessing || depositAmount.isEmpty)
        }
    }
    
    // MARK: - Security Info
    var securityInfo: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: "lock.shield.fill")
                    .font(.title3)
                    .foregroundColor(.green)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Bank-Grade Security")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text("Powered by Plaid • 256-bit encryption")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
            }
            
            HStack(spacing: 12) {
                Image(systemName: "checkmark.shield.fill")
                    .font(.title3)
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("FDIC Insured")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text("Your funds are protected up to $250,000")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
        )
    }
    
    // MARK: - Actions
    func loadBankAccounts() {
        Task {
            // Simulate API call
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            
            await MainActor.run {
                // Mock data - in real app, fetch from API
                connectedBanks = []
                isLoadingBanks = false
            }
        }
    }
    
    func handlePlaidSuccess(publicToken: String) {
        Task {
            // Exchange token and add bank
            // In real app: call API to exchange token
            
            await MainActor.run {
                // Mock adding a bank
                let newBank = BankAccount(
                    id: UUID().uuidString,
                    name: "Chase Checking",
                    last4: "4567",
                    type: "checking",
                    isDefault: connectedBanks.isEmpty
                )
                connectedBanks.append(newBank)
                selectedBank = newBank
                showPlaidLink = false
            }
        }
    }
    
    func processDeposit() {
        guard let amount = Double(depositAmount),
              let bank = selectedBank else { return }
        
        isProcessing = true
        
        Task {
            // Simulate API call
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            
            await MainActor.run {
                if selectedDepositType == "instant" {
                    // Instant deposit - update balance immediately
                    walletBalance += amount * 0.975 // 2.5% fee
                }
                
                showSuccessAlert = true
                isProcessing = false
            }
        }
    }
}

// MARK: - Supporting Views

struct BankCard: View {
    let bank: BankAccount
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // Bank Icon
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: "building.columns")
                    .font(.title3)
                    .foregroundColor(.blue)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(bank.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text("•••• \(bank.last4)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            if bank.isDefault {
                Text("Default")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundColor(.green)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(Color.green.opacity(0.2)))
            }
            
            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isSelected ? .blue : .gray)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(isSelected ? Color.blue.opacity(0.1) : Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(
                            isSelected ? Color.blue : Color.white.opacity(0.1),
                            lineWidth: isSelected ? 2 : 1
                        )
                )
        )
        .onTapGesture(perform: onTap)
    }
}

struct DepositTypeCard: View {
    let id: String
    let icon: String
    let title: String
    let fee: String
    let timing: String
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            Text(icon)
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text("• \(fee)")
                        .font(.caption)
                        .foregroundColor(id == "instant" ? .orange : .green)
                }
                
                Text(timing)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isSelected ? .blue : .gray)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isSelected ? Color.blue.opacity(0.1) : Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(
                            isSelected ? Color.blue : Color.white.opacity(0.1),
                            lineWidth: isSelected ? 2 : 1
                        )
                )
        )
        .onTapGesture(perform: onTap)
    }
}

struct FeeCalculationCard: View {
    let amount: Double
    let isInstant: Bool
    
    var fee: Double {
        isInstant ? amount * 0.025 : 0
    }
    
    var total: Double {
        isInstant ? amount - fee : amount
    }
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Deposit Amount")
                    .font(.caption)
                    .foregroundColor(.gray)
                Spacer()
                Text("$\(amount, specifier: "%.2f")")
                    .font(.caption)
                    .foregroundColor(.white)
            }
            
            if isInstant {
                HStack {
                    Text("Processing Fee (2.5%)")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Spacer()
                    Text("-$\(fee, specifier: "%.2f")")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }
            
            Divider()
                .background(Color.gray.opacity(0.3))
            
            HStack {
                Text("You'll Receive")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                Spacer()
                Text("$\(total, specifier: "%.2f")")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
        )
    }
}

// MARK: - Plaid Link View (WebView wrapper)
struct PlaidLinkView: UIViewRepresentable {
    let onSuccess: (String) -> Void
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        
        // In real app, you would:
        // 1. Get link token from your API
        // 2. Initialize Plaid Link with the token
        // 3. Handle success/exit callbacks
        
        // For demo, load Plaid Link URL
        if let url = URL(string: "https://cdn.plaid.com/link/v2/stable/link.html") {
            webView.load(URLRequest(url: url))
        }
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        let parent: PlaidLinkView
        
        init(_ parent: PlaidLinkView) {
            self.parent = parent
        }
        
        // Handle Plaid Link callbacks
    }
}

// MARK: - Data Models
struct BankAccount: Identifiable {
    let id: String
    let name: String
    let last4: String
    let type: String
    let isDefault: Bool
}

// MARK: - Button Style
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

#Preview {
    BankConnectionView(walletBalance: .constant(100.0))
}