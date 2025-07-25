import SwiftUI

struct InviteBanner: View {
    @EnvironmentObject var viral: ViralAPIService
    @EnvironmentObject var badgeService: BadgeService
    @State private var code: String = ""
    @State private var showSuccess = false
    @EnvironmentObject var authService: MockAuthService

    var body: some View {
        VStack(spacing: 12) {
            Text("Have an invite code?")
                .font(AppTheme.headline())
                .neonGlow()
            HStack {
                TextField("ABC123", text: $code)
                    .textInputAutocapitalization(.characters)
                    .disableAutocorrection(true)
                    .padding()
                    .background(AppTheme.cardGradient)
                    .cornerRadius(12)
                Button(action: redeem) {
                    Image(systemName: "bolt.fill")
                        .padding(14)
                        .background(AppTheme.accent)
                        .clipShape(Circle())
                        .foregroundColor(.white)
                        .neonGlow(color: AppTheme.accent)
                }
            }
        }
        .padding()
        .background(AppTheme.cardGradient)
        .cornerRadius(16)
        .shadow(radius: 8)
        .alert("Legend badge unlocked!", isPresented: $showSuccess) {
            Button("Awesome", role: .cancel) {}
        }
    }

    private func redeem() {
        guard let token = authService.jwtToken else { return }
        viral.redeemInvite(code: code, token: token) { ok, badge in
            if ok { showSuccess = true; badgeService.fetchBadges(token: token) }
        }
    }
}

struct InviteBanner_Previews: PreviewProvider {
    static var previews: some View {
        InviteBanner()
            .environmentObject(ViralAPIService.shared)
            .environmentObject(BadgeService())
            .environmentObject(MockAuthService())
    }
}