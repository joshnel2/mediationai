import SwiftUI

struct CrashoutsListView: View {
    @EnvironmentObject var socialService: SocialAPIService
    @EnvironmentObject var authService: MockAuthService

    private var myCrashouts: [MockDispute] {
        socialService.disputes(for: authService.currentUser?.id.uuidString ?? "")
    }

    var body: some View {
        if myCrashouts.isEmpty {
            VStack(spacing:16){
                Image(systemName:"info.circle")
                    .font(.system(size:48))
                    .foregroundColor(AppTheme.primary)
                Text("You don't have any crashouts yet")
                    .font(AppTheme.body())
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth:.infinity,maxHeight:.infinity)
            .background(AppTheme.backgroundGradient)
        } else {
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
            .listStyle(.plain)
            .navigationTitle("My Crashouts")
        }
    }
}

struct CrashoutsListView_Previews: PreviewProvider {
    static var previews: some View {
        CrashoutsListView()
            .environmentObject(MockAuthService())
            .environmentObject(SocialAPIService())
    }
}