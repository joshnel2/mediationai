import SwiftUI

struct LeaderboardView: View {
    @EnvironmentObject var social: SocialAPIService
    @State private var segment = 0

    var body: some View {
        VStack {
            Picker("Leaderboard", selection: $segment) {
                Text("Overall").tag(0)
                Text("Today").tag(1)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            List {
                ForEach(currentList.indices, id: \.self) { idx in
                    let user = currentList[idx]
                    NavigationLink(destination: MiniProfileView(userID: user.id)) {
                        HStack {
                            Text("#\(idx+1)")
                                .fontWeight(.bold)
                                .foregroundColor(AppTheme.accent)
                            RankBadgeView(rank: rank(for: user.xp))
                            Text(user.displayName)
                            Spacer()
                            Text("\(user.xp) XP")
                        }
                    }
                    .listRowBackground(AppTheme.cardGradient)
                    .foregroundColor(AppTheme.textPrimary)
                }
            }
            .listStyle(PlainListStyle())
        }
        .navigationTitle("Leaderboard")
        .background(AppTheme.backgroundGradient)
        .onAppear { social.fetchLeaderboard() }
    }

    private var currentList: [SocialAPIService.UserSummary] {
        segment == 0 ? social.overallLeaders : social.dailyLeaders
    }

    private func rank(for xp: Int) -> String {
        switch xp {
        case 0..<500: return "N"
        case 500..<2000: return "C"
        default: return "R"
        }
    }
}

struct LeaderboardView_Previews: PreviewProvider {
    static var previews: some View {
        LeaderboardView().environmentObject(SocialAPIService())
    }
}