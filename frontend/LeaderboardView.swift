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
                    HStack {
                        Text("#\(idx+1)")
                            .fontWeight(.bold)
                            .foregroundColor(AppTheme.accent)
                        Text(user.displayName)
                        Spacer()
                        Text("\(segment==0 ? user.xp : user.xp) XP")
                    }
                    .listRowBackground(AppTheme.cardGradient)
                    .foregroundColor(.white)
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
}

struct LeaderboardView_Previews: PreviewProvider {
    static var previews: some View {
        LeaderboardView().environmentObject(SocialAPIService())
    }
}