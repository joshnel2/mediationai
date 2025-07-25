import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authService: MockAuthService

    var body: some View {
        TabView {
            LeaderboardView()
                .tabItem {
                    Image(systemName: "trophy.fill")
                }

            LiveFeedView()
                .tabItem {
                    Image(systemName: "bolt.fill")
                }

            PeopleSearchView()
                .tabItem {
                    Image(systemName: "magnifyingglass")
                }

            HomeView()
                .tabItem {
                    Image(systemName: "bubble.left.and.bubble.right.fill")
                }

            ProfileView()
                .tabItem {
                    Image(systemName: "person.crop.circle")
                }
        }
        .accentColor(AppTheme.accent)
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