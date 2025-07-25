import SwiftUI

struct LegalHubView: View {
    var body: some View {
        NavigationView {
            List {
                NavigationLink("Terms of Service") { TermsOfServiceView() }
                NavigationLink("Privacy Policy") { PrivacyPolicyView() }
                NavigationLink("Community Rules") { CommunityView() }
                NavigationLink("Signature Info") { SignatureView() }
            }
            .navigationTitle("Legal & Policies")
            .background(AppTheme.backgroundGradient)
        }
    }
}

struct LegalHubView_Previews: PreviewProvider {
    static var previews: some View {
        LegalHubView()
    }
}