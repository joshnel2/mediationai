import SwiftUI
#if canImport(ConfettiSwiftUI)
import ConfettiSwiftUI
#endif

struct LeaderboardView: View {
    @EnvironmentObject var social: SocialAPIService
    @State private var segment = 0
    @State private var confetti = 0

    var body: some View {
        VStack {
            #if canImport(ConfettiSwiftUI)
            ConfettiCannon(counter: $confetti, num: 20, confettiSize: 8)
            #endif
            Picker("Leaderboard", selection: $segment) {
                Text("Overall").tag(0)
                Text("Today").tag(1)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            List {
                ForEach(currentList.indices, id: \.self) { idx in
                    let user = currentList[idx]
                    LeaderRow(user: user, rank: idx+1)
                        .environmentObject(social)
                        .onAppear{ if idx==0 { confetti+=1 } }
                }
            }
            .listStyle(PlainListStyle())
        }
        .navigationTitle("Leaderboard")
        .background(AppTheme.backgroundGradient)
        .onAppear { social.fetchLeaderboard() }
    }

    // Sort by dispute wins so that the top performers are decided by victories, not experience points
    private var currentList: [SocialAPIService.UserSummary] {
        let list = segment == 0 ? social.overallLeaders : social.dailyLeaders
        return list.sorted { $0.wins > $1.wins }
    }

    // no longer needed
}

struct LeaderRow: View {
    @EnvironmentObject var social: SocialAPIService
    let user: SocialAPIService.UserSummary
    let rank: Int
    var body: some View {
        NavigationLink(destination: MiniProfileView(userID: user.id)) {
            HStack(spacing:16){
                ZStack{
                    AsyncImage(url: URL(string: "https://i.pravatar.cc/64?u=\(user.id)")) { phase in
                        if let img = phase.image {
                            img.resizable().clipShape(Circle())
                        } else { Circle().fill(AppTheme.accent) }
                    }
                    if rank<=3 {
                        Image(systemName: rank==1 ? "crown.fill":"crown")
                            .foregroundColor(rank==1 ? .yellow : .gray)
                            .offset(x:22,y:-22)
                    }
                }
                .frame(width:64,height:64)
                .shadow(radius:4)

                VStack(alignment:.leading,spacing:4){
                    Text(user.displayName)
                        .font(.headline)
                    Text("🏆 \(user.wins) Crashouts")
                        .font(.caption)
                        .foregroundColor(AppTheme.textSecondary)
                }
                Spacer()
                Button(action:{ social.toggleFollow(id: user.id) }){
                    Text(social.following.contains(user.id) ? "Following" : "+ Follow")
                        .font(.caption2)
                        .padding(.vertical,6)
                        .padding(.horizontal,10)
                        .background(AppTheme.primary.opacity(0.85))
                        .foregroundColor(.white)
                        .cornerRadius(16)
                }
            }
            .padding(10)
            .background(AppTheme.cardGradient)
            .cornerRadius(20)
            .shadow(color:.black.opacity(0.12),radius:4,x:0,y:2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct LeaderboardView_Previews: PreviewProvider {
    static var previews: some View {
        LeaderboardView().environmentObject(SocialAPIService())
    }
}