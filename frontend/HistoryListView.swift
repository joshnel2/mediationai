import SwiftUI

struct HistoryListView: View {
    @EnvironmentObject var socialService: SocialAPIService
    @EnvironmentObject var authService: MockAuthService

    private var items: [HistoryItem] {
        socialService.historyByUser[authService.currentUser?.id.uuidString ?? "", default:[]]
    }

    var body: some View {
        List(items) { item in
            HStack{
                Text(item.dispute.title).bold()
                Spacer()
                Text(item.didWin ? "✅" : "❌")
                    .font(.title3)
            }
        }
        .navigationTitle("History")
    }
}

struct HistoryListView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryListView().environmentObject(SocialAPIService()).environmentObject(MockAuthService())
    }
}