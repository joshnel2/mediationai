import SwiftUI
import PhotosUI

struct MiniProfileView: View {
    @EnvironmentObject var social: SocialAPIService
    @EnvironmentObject var authService: MockAuthService
    let userID: String
    @Environment(\.dismiss) var dismiss

    @State private var navDispute: MockDispute?

    private var user: SocialAPIService.UserSummary? {
        social.overallLeaders.first { $0.id == userID }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24){
                heroHeader

                statRow

                funFactsSection

                actionButtons

                // AI summary chip
                HStack{
                    Image(systemName:"brain.head.profile").foregroundColor(.yellow)
                    Text(social.summary(for:userID))
                        .font(.caption)
                        .foregroundColor(AppTheme.textSecondary)
                }
                .padding(.vertical,10).padding(.horizontal,16)
                .background(AppTheme.cardGradient)
                .cornerRadius(20)

                activityTimeline

                recentSection
            }
            .padding()
        }
        .background(AppTheme.backgroundGradient.ignoresSafeArea())
        .navigationTitle(user?.displayName ?? "Profile")
    }

    // MARK: - Components
    private var heroHeader: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 32)
                .fill(LinearGradient(colors:[AppTheme.primary,AppTheme.accent],startPoint:.topLeading,endPoint:.bottomTrailing))
                .frame(height:180)
                .shadow(color:.black.opacity(0.25),radius:8,x:0,y:4)

            VStack(spacing:12){
                AsyncImage(url: social.avatarURL(id:userID, size:160)){ phase in
                    if let img = phase.image { img.resizable().scaledToFill() } else { Color.gray }
                }
                .frame(width:120,height:120)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white,lineWidth:3))
                .shadow(radius:6)

                Text(user?.displayName ?? "Streamer")
                    .font(.title3).bold().foregroundColor(.white)
            }
            .offset(y:70)
        }
        .padding(.top,40)
        .padding(.bottom,60)
    }

    private var statRow: some View {
        HStack(spacing:16){
            statChip(icon:"trophy.fill", label:"Crashouts", value:user?.wins ?? 0, gradient:[Color.yellow,Color.orange])
            statChip(icon:"person.2.fill", label:"Followers", value:social.followerCounts[userID, default:0], gradient:[Color.purple,Color.blue])
        }
    }

    // MARK: - Fun facts for Gen-Z flair
    private var funFactsSection: some View {
        HStack(spacing:12){
            funChip(title:"Streak", subtitle:"🔥 \(winStreak)")
            funChip(title:"Fav Emoji", subtitle:favoriteEmoji)
            funChip(title:"Hype", subtitle:"\(hypeScore)%")
        }
    }

    private func funChip(title:String, subtitle:String)->some View{
        VStack(spacing:4){
            Text(subtitle).font(.headline)
            Text(title).font(.caption2).foregroundColor(.secondary)
        }
        .padding(.vertical,10).padding(.horizontal,12)
        .background(AppTheme.cardGradient)
        .cornerRadius(14)
    }

    private var favoriteEmoji: String {
        let emojis = ["🔥","😂","👏","💯","😤","🤯"]
        guard let first = emojis.randomElement() else { return "🔥" }
        // deterministic using hashValue
        let idx = abs(userID.hashValue) % emojis.count
        return emojis[idx]
    }

    private var hypeScore: Int {
        min(100, max(20, (user?.xp ?? 0) / 80))
    }

    private var winStreak: Int {
        let hist = social.historyByUser[userID] ?? []
        var count = 0
        for item in hist.reversed(){
            if item.didWin { count += 1 } else { break }
        }
        return count
    }

    // MARK: - Recent Crashouts Section (shared history)
    private var recentSection: some View {
        VStack(alignment:.leading,spacing:12){
            Text("Recent Crashouts").font(.headline)
            ScrollView(.horizontal,showsIndicators:false){
                HStack(spacing:16){
                    ForEach(filteredDisputes){ disp in
                        NavigationLink(destination: ConversationView(dispute: disp)){
                            VStack(alignment:.leading,spacing:6){
                                Text(disp.title).bold().lineLimit(1)
                                Text("Score: \(disp.votesA)-\(disp.votesB)").font(.caption2).foregroundColor(.secondary)
                            }
                            .padding()
                            .frame(width:160,height:100)
                            .background(AppTheme.cardGradient)
                            .cornerRadius(20)
                            .shadow(color:.black.opacity(0.15),radius:4,x:0,y:2)
                        }.buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
    }

    private func statChip(icon:String,label:String,value:Int,gradient:[Color])->some View{
        VStack(spacing:4){
            HStack(spacing:4){
                Image(systemName:icon).foregroundColor(.white)
                Text("\(value)").bold().foregroundColor(.white)
            }
            Text(label).font(.caption2).foregroundColor(.white.opacity(0.9))
        }
        .padding(.vertical,12).padding(.horizontal,16)
        .background(LinearGradient(colors:gradient,startPoint:.topLeading,endPoint:.bottomTrailing))
        .cornerRadius(20)
        .shadow(color:.black.opacity(0.2),radius:4,x:0,y:2)
    }

    private var actionButtons: some View {
        HStack(spacing:16){
            Button(action:{ social.toggleFollow(id:userID, followerID: authService.currentUser?.id.uuidString ?? "")}){
                Text(social.following.contains(userID) ? "Following" : "+ Follow")
                    .font(.subheadline).bold()
                    .frame(maxWidth:.infinity)
                    .padding(.vertical,14)
                    .background(AppTheme.primary)
                    .foregroundColor(.white)
                    .cornerRadius(24)
            }

            Button(action:{ requestClash()}){
                Text("Crashout ⚡️")
                    .font(.subheadline).bold()
                    .frame(maxWidth:.infinity)
                    .padding(.vertical,14)
                    .background(AppTheme.accent)
                    .foregroundColor(.white)
                    .cornerRadius(24)
            }
        }
        .background(
            NavigationLink(destination: navDestination, isActive: Binding(
                get: { navDispute != nil },
                set: { if !$0 { navDispute = nil } }
            )) { EmptyView() }
            .hidden()
        )
    }

    private var navDestination: some View {
        if let d = navDispute {
            return AnyView(ConversationView(dispute: d))
        }
        return AnyView(EmptyView())
    }

    // Activity timeline
    private var activityTimeline: some View {
        let events = social.activities(for: userID)
        return VStack(alignment:.leading,spacing:12){
            Text("Activity")
                .font(.headline)
            ForEach(events){ ev in
                HStack(alignment:.top,spacing:8){
                    Circle().fill(AppTheme.primary).frame(width:6,height:6).padding(.top,6)
                    VStack(alignment:.leading,spacing:2){
                        Text(ev.message).font(.caption)
                        Text(ev.date, style: .relative).font(.caption2).foregroundColor(.secondary)
                    }
                }
            }
        }
    }

    private func requestClash(){
        if let current = authService.currentUser?.id.uuidString {
            let disp = social.createClashBetween(current, userID)
            navDispute = disp
        }
    }

    // Helper computed property
    private var filteredDisputes: [MockDispute] {
        // If viewing your own profile, show all of your disputes
        guard let myID = authService.currentUser?.id.uuidString, myID != userID else {
            return social.disputes(for: userID)
        }
        // Otherwise, show only clashes that include both you and the profile owner
        let mine = Set(social.disputes(for: myID).map { $0.id })
        return social.disputes(for: userID).filter { mine.contains($0.id) }
    }
}

struct MiniProfileView_Previews: PreviewProvider {
    static var previews: some View {
        MiniProfileView(userID: "demo")
            .environmentObject(SocialAPIService())
    }
}