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
        VStack(spacing: 24) {
            AsyncImage(url: URL(string: "https://i.pravatar.cc/160?u=\(userID)")) { phase in
                if let img = phase.image {
                    img.resizable().clipShape(Circle())
                } else {
                    Circle().fill(AppTheme.accent)
                }
            }
            .frame(width: 120, height: 120)
            .shadow(radius: 6)

            Text(user?.displayName ?? "Streamer")
                .font(.title).bold()
            Text("🏆 Wins: \(user?.wins ?? 0)")
                .font(.subheadline)
                .foregroundColor(AppTheme.textSecondary)
            Text("Followers: \(social.followerCounts[userID, default: 0])")
                .font(.subheadline)
            Button(action: { social.toggleFollow(id: userID) }) {
                Text(social.following.contains(userID) ? "Following" : "Follow")
                    .padding(.horizontal, 40)
                    .padding(.vertical, 12)
                    .background(social.following.contains(userID) ? AppTheme.glassPrimary : AppTheme.accent)
                    .foregroundColor(AppTheme.textPrimary)
                    .cornerRadius(30)
            }

            Button(action: { requestClash() }){
                Text("Request Clash ⚡️").padding().background(AppTheme.accent).foregroundColor(.white).cornerRadius(24)
            }

            Divider()
            Text("Recent Clashes")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(social.disputes(for: userID)) { disp in
                        NavigationLink(destination: ConversationView(dispute: disp)){
                            VStack(alignment: .leading, spacing: 6) {
                                Text(disp.title).bold()
                                Text("Score: \(disp.votesA) - \(disp.votesB)")
                                    .font(.caption)
                                    .foregroundColor(AppTheme.textSecondary)
                            }
                            .padding()
                            .background(AppTheme.cardGradient)
                            .cornerRadius(16)
                        }
                    }
                }
            }
            Spacer()
        }
        .padding()
        .background(AppTheme.backgroundGradient.ignoresSafeArea())
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