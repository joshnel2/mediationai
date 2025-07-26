import SwiftUI

struct PeopleSearchView: View {
    @EnvironmentObject var social: SocialAPIService
    @EnvironmentObject var authService: MockAuthService
    @State private var query: String = ""

    var body: some View {
        NavigationView {
            VStack {
                VStack(alignment: .leading, spacing: 8) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(social.hotTopics, id: \.self) { topic in
                                Button(action: { query = topic; social.searchUsers(query: topic) }) {
                                    Text(topic)
                                        .font(.caption)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(AppTheme.cardGradient)
                                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(AppTheme.accent, lineWidth: 1))
                                        .cornerRadius(14)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }

                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        TextField("Search users", text: $query)
                            .onSubmit { social.searchUsers(query: query) }
                    }
                    .padding(12)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
                    .padding(.horizontal)
                    if social.searchResults.isEmpty {
                        // Show seeded users
                        List {
                            ForEach(social.overallLeaders) { user in
                                row(for: user)
                            }
                        }
                        .listStyle(PlainListStyle())
                        .listRowSeparator(.hidden)
                    } else {
                        List {
                            ForEach(social.searchResults) { user in
                                row(for: user)
                            }
                        }
                        .listStyle(PlainListStyle())
                        .listRowSeparator(.hidden)
                    }
                }
            }
            .navigationTitle("People")
            .background(AppTheme.backgroundGradient)
            .onAppear { social.fetchHotTopics() }
        }
    }

    // DRY user row
    private func row(for user: SocialAPIService.UserSummary) -> some View {
        NavigationLink(destination: MiniProfileView(userID: user.id)) {
            HStack(spacing:16) {
                AsyncImage(url: URL(string: "https://i.pravatar.cc/80?u=\(user.id)")) { phase in
                    if let img = phase.image {
                        img.resizable().clipShape(Circle())
                    } else {
                        Circle().fill(AppTheme.accent)
                    }
                }
                .frame(width:60,height:60)

                VStack(alignment: .leading, spacing: 4) {
                    Text(user.displayName)
                        .font(.headline)
                        .foregroundColor(AppTheme.textPrimary)
                    Text("🏆 \(user.wins) wins")
                        .font(.caption)
                        .foregroundColor(AppTheme.textSecondary)
                }
                Spacer()
                Button(action: { follow(id: user.id); }) {
                    Text(social.following.contains(user.id) ? "Following" : "Follow")
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 14)
                        .background(social.following.contains(user.id) ? AppTheme.primary : AppTheme.accent)
                        .cornerRadius(20)
                }
            }
            .padding(12)
            .background(AppTheme.cardGradient)
            .cornerRadius(18)
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
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