import SwiftUI

struct PeopleSearchView: View {
    @EnvironmentObject var social: SocialAPIService
    @EnvironmentObject var authService: MockAuthService
    @State private var query: String = ""

    private let grid = [GridItem(.adaptive(minimum: 140), spacing: 16)]

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Hero Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.white.opacity(0.8))
                    TextField("Search creators", text: $query, onCommit: { social.searchUsers(query: query) })
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 28)
                        .fill(LinearGradient(colors: [AppTheme.primary, AppTheme.accent], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .shadow(color:.black.opacity(0.25),radius:6,x:0,y:4)
                )
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

                // Results Grid
                ScrollView {
                    if social.searchResults.isEmpty {
                        HStack{
                            Text("Suggested creators")
                                .font(.headline)
                                .foregroundColor(AppTheme.textPrimary)
                            Spacer()
                        }
                        .padding(.horizontal)
                    }
                    LazyVGrid(columns: grid, spacing: 20) {
                        ForEach(results) { user in
                            userCard(for: user)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("People")
            .background(AppTheme.backgroundGradient.ignoresSafeArea())
            .onAppear { social.fetchHotTopics() }
        }
    }

    private var results: [SocialAPIService.UserSummary] {
        social.searchResults.isEmpty ? social.overallLeaders : social.searchResults
    }

    // Card style for grid
    private func userCard(for user: SocialAPIService.UserSummary) -> some View {
        NavigationLink(destination: MiniProfileView(userID: user.id)) {
            VStack(spacing: 12) {
                AsyncImage(url: URL(string: "https://i.pravatar.cc/120?u=\(user.id)")) { phase in
                    if let img = phase.image {
                        img.resizable().scaledToFill()
                    } else { Color.gray }
                }
                .frame(width:100,height:100)
                .clipShape(Circle())
                .shadow(radius:4)

                Text(user.displayName)
                    .font(.subheadline).bold()
                    .foregroundColor(AppTheme.textPrimary)

                Text("🏆 \(user.wins) Crashouts")
                    .font(.caption2)
                    .foregroundColor(AppTheme.textSecondary)

                Button(action: { follow(id: user.id) }) {
                    Text(social.following.contains(user.id) ? "Following" : "+ Follow")
                        .font(.caption2)
                        .padding(.vertical,6)
                        .padding(.horizontal,16)
                        .background(social.following.contains(user.id) ? Color.white.opacity(0.25) : AppTheme.accentGradient)
                        .foregroundColor(.white)
                        .cornerRadius(18)
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(AppTheme.cardGradient)
            .cornerRadius(24)
            .shadow(color:.black.opacity(0.1),radius:4,x:0,y:2)
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