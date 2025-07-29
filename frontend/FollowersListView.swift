import SwiftUI

struct FollowersListView: View {
    @EnvironmentObject var social: SocialAPIService
    @EnvironmentObject var authService: MockAuthService

    private var followers: [String] {
        Array(social.followersByUser[authService.currentUser?.id.uuidString ?? ""] ?? []).sorted()
    }

    var body: some View {
        List(followers, id: \.self) { id in
            if let user = social.overallLeaders.first(where: { $0.id == id }) {
                NavigationLink(destination: MiniProfileView(userID: id)) {
                    userRow(for: user)
                }
            } else {
                Text(id).foregroundColor(.primary)
            }
        }
        .listStyle(.plain)
        .navigationTitle("Followers")

    }

    private func userRow(for user: SocialAPIService.UserSummary) -> some View {
        HStack(spacing: 12) {
            AsyncImage(url: social.avatarURL(id: user.id, size: 120)) { phase in
                (phase.image ?? Image(systemName: "person.circle")).resizable()
            }
            .frame(width: 46, height: 46)
            .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(user.displayName)
                    .font(.subheadline.bold())
                    .foregroundColor(.primary)
                Text("🏆 \(user.wins) wins • \(user.xp) XP")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding(.vertical, 6)
    }
}

#if DEBUG
struct FollowersListView_Previews: PreviewProvider {
    static var previews: some View {
        FollowersListView().environmentObject(SocialAPIService()).environmentObject(MockAuthService())
    }
}
#endif