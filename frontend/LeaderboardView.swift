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
            Spacer(minLength: 0).frame(height: 8) // top breathing space
            #if canImport(ConfettiSwiftUI)
            ConfettiCannon(counter: $confetti, num: 20, confettiSize: 8)
            #endif

            // Segmented selector
            Picker("Leaderboard", selection: $segment) {
                Text("Overall").tag(0)
                Text("Today").tag(1)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)

            // Podium for top 3 (now tappable)
            if !currentList.isEmpty {
                HStack(alignment:.bottom,spacing:24){
                    ForEach(0..<min(3,currentList.count),id:\.self){ idx in
                        let user = currentList[idx]
                        NavigationLink(destination: MiniProfileView(userID: user.id)) {
                            VStack(spacing:6){
                                AsyncImage(url: URL(string:"https://i.pravatar.cc/96?u=\(user.id)")) { phase in
                                    if let img = phase.image { img.resizable() } else { Color.gray }
                                }
                                .frame(width:72,height:72)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(AppTheme.accent,lineWidth:3))
                                Text(user.displayName)
                                    .font(.caption)
                                    .foregroundColor(.primary)
                                Text("🏆 \(user.wins)")
                                    .font(.caption2).foregroundColor(.yellow)
                            }
                            .scaleEffect(idx==0 ? 1.2 : 1.0)
                            .opacity(idx==0 ? 1 : 0.95)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.vertical,12)
            }

            // List body
            List {
                ForEach(currentList.indices, id: \.self) { idx in
                    let user = currentList[idx]
                    LeaderRow(user: user, rank: idx+1, maxWins: maxWins)
                        .environmentObject(social)
                        .onAppear{ if idx==0 { confetti+=1 } }
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top:8, leading:0, bottom:8, trailing:0))
                }
            }
            .listStyle(.plain)
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

    private var maxWins: Int { currentList.map{$0.wins}.max() ?? 1 }

    // no longer needed
}

private struct LeaderRow: View {
    @EnvironmentObject var social: SocialAPIService
    let user: SocialAPIService.UserSummary
    let rank: Int
    let maxWins: Int
    var body: some View {
        NavigationLink(destination: MiniProfileView(userID: user.id)) {
            HStack(spacing:12){
                Text("#\(rank)")
                    .font(.subheadline.weight(.bold))
                    .frame(width:28)
                AsyncImage(url: URL(string: "https://i.pravatar.cc/60?u=\(user.id)")) { phase in
                    (phase.image ?? Image(systemName:"person.circle")).resizable()
                }
                .frame(width:40,height:40) .clipShape(Circle())

                VStack(alignment:.leading,spacing:2){
                    Text(user.displayName)
                        .font(.subheadline.weight(.semibold))
                    Text("\(user.wins) wins • \(user.xp) XP")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Button(action:{ social.toggleFollow(id: user.id) }){
                    Image(systemName: social.following.contains(user.id) ? "checkmark.circle.fill" : "plus.circle")
                        .foregroundColor(AppTheme.primary)
                }
            }
            .padding(.horizontal)
        }
        .buttonStyle(PlainButtonStyle())
    }
    private var rankGradient: LinearGradient {
        switch rank {
        case 1:
            return LinearGradient(colors:[Color.yellow,Color.orange],startPoint:.topLeading,endPoint:.bottomTrailing)
        case 2:
            return LinearGradient(colors:[Color.gray.opacity(0.8),Color.gray],startPoint:.topLeading,endPoint:.bottomTrailing)
        case 3:
            return LinearGradient(colors:[Color.brown,Color.orange.opacity(0.7)],startPoint:.topLeading,endPoint:.bottomTrailing)
        default:
            return AppTheme.cardGradient
        }
    }

    // Not used since rows are flat
}

struct LeaderboardView_Previews: PreviewProvider {
    static var previews: some View {
        LeaderboardView().environmentObject(SocialAPIService())
    }
}