import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authService: MockAuthService

    var body: some View {
        TabView {
            LeaderboardView()
                .tabItem {
                    Image(systemName: "trophy.fill")
                    Text("Top")
                }

            LiveFeedView()
                .tabItem {
                    Image(systemName: "bolt.fill")
                    Text("Drama")
                }

            PeopleSearchView()
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Search")
                }

            HomeView()
                .tabItem {
                    Image(systemName: "bubble.left.and.bubble.right.fill")
                    Text("Clashes")
                }

            ProfileView()
                .tabItem {
                    Image(systemName: "person.crop.circle")
                }
        }
        .accentColor(.green)
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
            .environmentObject(MockAuthService())
            .environmentObject(MockDisputeService())
            .environmentObject(SocialAPIService())
    }
}