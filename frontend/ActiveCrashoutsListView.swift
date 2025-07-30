import SwiftUI

struct ActiveCrashoutsListView: View {
    @EnvironmentObject var social: SocialAPIService
    @EnvironmentObject var authService: MockAuthService

    private var active: [MockDispute] {
        let all = social.disputes(for: authService.currentUser?.id.uuidString ?? "")
        let resolvedIDs = Set(social.historyByUser[authService.currentUser?.id.uuidString ?? "", default:[]].map{ $0.dispute.id })
        return all.filter{ !resolvedIDs.contains($0.id) }
    }

    var body: some View {
        if active.isEmpty {
            VStack(spacing:16){
                Image(systemName:"info.circle")
                    .font(.system(size:48))
                    .foregroundColor(AppTheme.primary)
                Text("You don't have any active crashouts yet")
                    .font(AppTheme.body())
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth:.infinity,maxHeight:.infinity)
            .background(AppTheme.backgroundGradient)
            .navigationTitle("Active Crashouts")
        } else {
            List(active) { disp in
                NavigationLink(destination: ConversationView(dispute: disp)) {
                    VStack(alignment:.leading,spacing:4){
                        Text(disp.title).bold()
                        Text("Score: \(disp.votesA)-\(disp.votesB)").font(.caption).foregroundColor(.secondary)
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("Active Crashouts")
        }
    }
}

#if DEBUG
struct ActiveCrashoutsListView_Previews: PreviewProvider {
    static var previews: some View {
        ActiveCrashoutsListView().environmentObject(SocialAPIService()).environmentObject(MockAuthService())
    }
}
#endif