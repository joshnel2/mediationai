import SwiftUI
import PhotosUI

struct MiniProfileView: View {
    @EnvironmentObject var social: SocialAPIService
    @EnvironmentObject var authService: MockAuthService
    let userID: String
    @Environment(\.dismiss) var dismiss

    private var user: SocialAPIService.UserSummary? {
        social.overallLeaders.first { $0.id == userID }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24){
                heroHeader

                statRow

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
                AsyncImage(url: URL(string:"https://i.pravatar.cc/160?u=\(userID)")){ phase in
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
            Button(action:{ social.toggleFollow(id:userID)}){
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
    }

    private var recentSection: some View {
        VStack(alignment:.leading,spacing:12){
            Text("Recent Crashouts")
                .font(.headline)
            ScrollView(.horizontal,showsIndicators:false){
                HStack(spacing:16){
                    ForEach(social.disputes(for:userID)){ disp in
                        NavigationLink(destination: ConversationView(dispute: disp)){
                            VStack(alignment:.leading,spacing:6){
                                Text(disp.title).bold().lineLimit(1)
                                Text("Score: \(disp.votesA)-\(disp.votesB)")
                                    .font(.caption2)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            .padding()
                            .frame(width:160,height:100)
                            .background(AppTheme.cardGradient)
                            .cornerRadius(20)
                            .shadow(color:.black.opacity(0.15),radius:4,x:0,y:2)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
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
            let _ = social.createClashBetween(current, userID)
        }
    }
}

struct MiniProfileView_Previews: PreviewProvider {
    static var previews: some View {
        MiniProfileView(userID: "demo")
            .environmentObject(SocialAPIService())
    }
}