import SwiftUI

struct CrashoutsListView: View {
    @EnvironmentObject var socialService: SocialAPIService
    @EnvironmentObject var authService: MockAuthService

    private var myCrashouts: [MockDispute] {
        socialService.disputes(for: authService.currentUser?.id.uuidString ?? "")
    }

    var body: some View {
        List {
            ForEach(myCrashouts) { disp in
                NavigationLink(destination: ConversationView(dispute: disp)) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(disp.title).bold()
                        Text("Score: \(disp.votesA) - \(disp.votesB)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(8)
                }
            }
        }
        .navigationTitle("My Crashouts")
    }
}

struct CrashoutsListView_Previews: PreviewProvider {
    static var previews: some View {
        CrashoutsListView()
            .environmentObject(MockAuthService())
            .environmentObject(SocialAPIService())
    }
}