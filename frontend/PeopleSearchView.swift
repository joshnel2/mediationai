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
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(AppTheme.accentGradient)
                                        .cornerRadius(14)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }

                    HStack {
                        TextField("Search users", text: $query, onCommit: {
                            social.searchUsers(query: query)
                        })
                        .padding(12)
                        .background(AppTheme.cardGradient)
                        .cornerRadius(12)
                        Button(action: { social.searchUsers(query: query) }) {
                            Image(systemName: "magnifyingglass")
                                .padding(10)
                                .background(AppTheme.accent)
                                .clipShape(Circle())
                                .foregroundColor(.white)
                        }
                    }
                    .padding()
                    if social.searchResults.isEmpty {
                        // Show seeded users
                        List {
                            ForEach(social.overallLeaders) { user in
                                row(for: user)
                            }
                        }
                        .listStyle(PlainListStyle())
                    } else {
                        List {
                            ForEach(social.searchResults) { user in
                                row(for: user)
                            }
                        }
                        .listStyle(PlainListStyle())
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
        HStack {
            Text(user.displayName)
                .foregroundColor(AppTheme.textPrimary)
            Spacer()
            Button(action: { follow(id: user.id) }) {
                Image(systemName: "person.badge.plus")
            }
            .buttonStyle(BorderlessButtonStyle())
            .foregroundColor(AppTheme.accent)
            Button(action: { startClash(with: user.id) }) {
                Image(systemName: "bolt.fill")
            }
            .buttonStyle(BorderlessButtonStyle())
            .foregroundColor(AppTheme.primary)
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