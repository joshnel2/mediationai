import SwiftUI

struct FollowingListView: View {
    @EnvironmentObject var social: SocialAPIService
    @EnvironmentObject var authService: MockAuthService

    private var list: [SocialAPIService.UserSummary] {
        social.overallLeaders.filter { social.following.contains($0.id) }
    }

    var body: some View {
        List(list, id: \.id) { user in
            NavigationLink(destination: MiniProfileView(userID: user.id)) {
                userRow(for: user)
            }
        }
        .listStyle(.plain)
        .navigationTitle("Following")
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
struct FollowingListView_Previews: PreviewProvider {
    static var previews: some View {
        FollowingListView()
            .environmentObject(SocialAPIService())
            .environmentObject(MockAuthService())
    }
}
#endif