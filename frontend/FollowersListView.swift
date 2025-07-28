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
                    HStack {
                        AsyncImage(url: social.avatarURL(id: id, size: 80)) { phase in
                            (phase.image ?? Image(systemName: "person.circle")).resizable()
                        }
                        .frame(width: 32, height: 32)
                        .clipShape(Circle())
                        Text(user.displayName)
                    }
                }
            } else {
                Text(id)
            }
        }
        .navigationTitle("Followers")
    }
}

#if DEBUG
struct FollowersListView_Previews: PreviewProvider {
    static var previews: some View {
        FollowersListView().environmentObject(SocialAPIService()).environmentObject(MockAuthService())
    }
}
#endif