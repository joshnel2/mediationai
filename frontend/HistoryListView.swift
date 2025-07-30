import SwiftUI

struct HistoryListView: View {
    @EnvironmentObject var socialService: SocialAPIService
    @EnvironmentObject var authService: MockAuthService

    private var items: [HistoryItem] {
        socialService.historyByUser[authService.currentUser?.id.uuidString ?? "", default:[]]
    }

    var body: some View {
        if items.isEmpty {
            VStack(spacing:16){
                Image(systemName:"info.circle")
                    .font(.system(size:48))
                    .foregroundColor(AppTheme.primary)
                Text("You don't have any resolved crashouts yet")
                    .font(AppTheme.body())
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth:.infinity,maxHeight:.infinity)
            .background(AppTheme.backgroundGradient)
            .navigationTitle("History")
        } else {
            List(items) { item in
                HStack{
                    Text(item.dispute.title).bold()
                    Spacer()
                    Text(item.didWin ? "✅" : "❌")
                        .font(.title3)
                }
            }
            .listStyle(.plain)
            .navigationTitle("History")
        }
    }
}

struct HistoryListView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryListView().environmentObject(SocialAPIService()).environmentObject(MockAuthService())
    }
}