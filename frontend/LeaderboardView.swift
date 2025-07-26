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
        HStack(spacing:12){
            ZStack{
                AsyncImage(url: URL(string: "https://i.pravatar.cc/48?u=\(user.id)")) { phase in
                    if let img = phase.image {
                        img.resizable().clipShape(Circle())
                    } else {
                        Circle().fill(AppTheme.accent)
                    }
                }
                if rank<=3 {
                    Image(systemName: rank==1 ? "crown.fill":"crown")
                        .foregroundColor(rank==1 ? .yellow : .gray)
                        .offset(x:18,y:-18).scaleEffect(1.1).opacity(0.9)
                        .animation(.easeInOut.repeatForever(autoreverses:true),value:rank)
                }
            }.frame(width:48,height:48)
            VStack(alignment:.leading){
                Text(user.displayName).bold()
                ProgressView(value: Double(user.xp%1000)/1000).progressViewStyle(LinearProgressViewStyle(tint: AppTheme.primary))
            }
            Spacer()
            Text("🏆 \(user.wins)")
            Button(action:{ social.toggleFollow(id: user.id) }){
                Text(social.following.contains(user.id) ? "Following" : "Follow")
                    .font(.caption)
                    .foregroundColor(AppTheme.textPrimary)
                    .padding(6)
                    .background(AppTheme.glassPrimary)
                    .cornerRadius(12)
            }
        }
        .padding(8).background(AppTheme.cardGradient).cornerRadius(16)
        .swipeActions(edge: .trailing) {
            Button {
                if let current = social.following.first {
                    _ = social.createClashBetween(current, user.id)
                }
            } label: {
                Text("Challenge")
            }
            .tint(.purple)
        }
    }
}

struct LeaderboardView_Previews: PreviewProvider {
    static var previews: some View {
        LeaderboardView().environmentObject(SocialAPIService())
    }
}