import SwiftUI

struct FollowingListView: View {
    @EnvironmentObject var social: SocialAPIService
    var body: some View {
        List(Array(social.following), id: \ .self){ id in
            if let user = social.overallLeaders.first(where: { $0.id == id }) {
                NavigationLink(destination: MiniProfileView(userID: id)){
                    Text(user.displayName)
                }
            }
        }
        .navigationTitle("Following")
    }
}

struct FollowingListView_Previews: PreviewProvider {
    static var previews: some View {
        FollowingListView().environmentObject(SocialAPIService())
    }
}