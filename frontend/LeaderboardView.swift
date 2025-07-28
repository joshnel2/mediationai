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

            // Leader list

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

// MARK: - Podium

private struct PodiumView: View {
    @EnvironmentObject var social: SocialAPIService
    let first: SocialAPIService.UserSummary
    let second: SocialAPIService.UserSummary
    let third: SocialAPIService.UserSummary

    var body: some View {
        HStack(alignment:.bottom,spacing:24){
            miniColumn(for: second, height:100)
            miniColumn(for: first, height:120, isChampion:true)
            miniColumn(for: third, height:100)
        }
    }

    private func miniColumn(for user:SocialAPIService.UserSummary, height:CGFloat, isChampion:Bool=false)->some View{
        VStack(spacing:6){
            NavigationLink(destination: MiniProfileView(userID: user.id)){
                AsyncImage(url: social.avatarURL(id:user.id, size:96)) { phase in
                    (phase.image ?? Image(systemName:"person.circle")).resizable()
                }
                .frame(width:height*0.6,height:height*0.6)
                .clipShape(Circle())
                .overlay(Circle().stroke(isChampion ? Color.yellow : AppTheme.accent,lineWidth: isChampion ? 4 : 2))
                .shadow(radius:isChampion ? 6 : 3)
            }
            .buttonStyle(PlainButtonStyle())
            .simultaneousGesture(TapGesture().onEnded{ HapticManager.impact(.light) })
            Text(user.displayName).font(.caption)
            Text("🏆 \(user.wins)").font(.caption2).foregroundColor(.secondary)
        }
        .frame(height:height)
    }
}

// MARK: - Leader Row

private struct LeaderRow: View {
    @EnvironmentObject var social: SocialAPIService
    let user: SocialAPIService.UserSummary
    let rank: Int
    let maxWins: Int
    @State private var isPressed = false
    var body: some View {
        NavigationLink(destination: MiniProfileView(userID: user.id)) {
            HStack(spacing:12){
                Text("#\(rank)")
                    .font(.subheadline.weight(.bold))
                    .frame(width:28)
                AsyncImage(url: social.avatarURL(id:user.id, size:60)) { phase in
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
            .padding(.vertical,10).padding(.horizontal,14)
            .background(
                RoundedRectangle(cornerRadius:14)
                    .fill(Color.white.opacity(0.03))
                    .background(
                        RoundedRectangle(cornerRadius:14).stroke(Color.white.opacity(0.06),lineWidth:1)
                    )
            )
            .shadow(color:.black.opacity(isPressed ? 0 : 0.08),radius:3,x:0,y:2)
            .scaleEffect(isPressed ? 0.97 : 1.0)
            .animation(.spring(response:0.3,dampingFraction:0.7),value:isPressed)
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