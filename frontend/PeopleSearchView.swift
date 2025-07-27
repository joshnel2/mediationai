import SwiftUI

struct PeopleSearchView: View {
    @EnvironmentObject var social: SocialAPIService
    @EnvironmentObject var authService: MockAuthService
    @State private var query: String = ""

    // Not using grid anymore; vertical list

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Hero Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField("Search Users", text: $query, onCommit: { social.searchUsers(query: query) })
                        .foregroundColor(.primary)
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.white.opacity(0.05))
                        .background(
                            RoundedRectangle(cornerRadius:24).stroke(Color.white.opacity(0.08), lineWidth:1)
                        )
                )
                .shadow(color:.black.opacity(0.15),radius:4,x:0,y:2)
                .padding(.horizontal)

                // Trending chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(social.hotTopics, id: \.self) { topic in
                            Button(action: { query = topic; social.searchUsers(query: topic) }) {
                                Text("#" + topic)
                                    .font(.caption)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(AppTheme.cardGradient)
                                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(AppTheme.accent,lineWidth:1))
                                    .cornerRadius(20)
                            }
                        }
                    }
                    .padding(.horizontal)
                }

                // Results List
                ScrollView{
                    LazyVStack(spacing:16){
                        ForEach(results){ user in userRow(for:user) }
                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle("")
            .background(AppTheme.backgroundGradient.ignoresSafeArea())
            .onAppear { social.fetchHotTopics() }
        }
    }

    private var results: [SocialAPIService.UserSummary] {
        social.searchResults.isEmpty ? social.overallLeaders : social.searchResults
    }

    // Twitter-like row
    private func userRow(for user: SocialAPIService.UserSummary) -> some View {
        NavigationLink(destination: MiniProfileView(userID: user.id)) {
            HStack(spacing:12){
                AsyncImage(url: URL(string: "https://i.pravatar.cc/120?u=\(user.id)") ) { phase in
                    (phase.image ?? Image(systemName:"person.circle")).resizable()
                }
                .frame(width:46,height:46).clipShape(Circle())

                VStack(alignment:.leading,spacing:2){
                    Text(user.displayName).font(.subheadline.bold())
                    Text("\(user.wins) wins • {user.xp} XP").font(.caption).foregroundColor(.secondary)
                }

                Spacer()

                Button(action:{ follow(id:user.id) }){
                    Image(systemName: social.following.contains(user.id) ? "checkmark.circle.fill" : "plus.circle")
                        .font(.title3)
                        .foregroundColor(AppTheme.accent)
                }
            }
            .padding(.vertical,8)
        }
        .buttonStyle(PlainButtonStyle())
    }

    private func follow(id: String) {
        social.followUser(id: id)
    }
    private func startClash(with id: String) {
        social.createClash(with: id)
    }
}

struct PeopleSearchView_Previews: PreviewProvider {
    static var previews: some View {
        PeopleSearchView()
            .environmentObject(SocialAPIService())
            .environmentObject(MockAuthService())
    }
}