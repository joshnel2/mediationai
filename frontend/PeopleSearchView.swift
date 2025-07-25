import SwiftUI

struct PeopleSearchView: View {
    @EnvironmentObject var social: SocialAPIService
    @EnvironmentObject var authService: MockAuthService
    @State private var query: String = ""

    var body: some View {
        NavigationView {
            VStack {
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
                    Spacer()
                    Text("No users yet")
                        .foregroundColor(.white.opacity(0.7))
                    Spacer()
                } else {
                    List {
                        ForEach(social.searchResults) { user in
                            HStack {
                                Text(user.displayName)
                                    .foregroundColor(.white)
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
                            .listRowBackground(AppTheme.cardGradient)
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("People")
            .background(AppTheme.backgroundGradient)
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