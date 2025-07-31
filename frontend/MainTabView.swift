import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authService: MockAuthService

    var body: some View {
        TabView {
            NavigationView {
                LeaderboardView()
            }
            .navigationViewStyle(.stack)
            .tabItem {
                Image(systemName: "trophy.fill")
            }

            LiveFeedView()
                .tabItem {
                    Image(systemName: "bolt.fill")
                }

            TournamentView()
                .tabItem {
                    Image(systemName: "rosette")
                }

            PeopleSearchView()
                .tabItem {
                    Image(systemName: "magnifyingglass")
                }

#if DEBUG
            ComponentCatalogView()
                .tabItem { Image(systemName: "paintbrush") }
#endif

            NavigationView {
                HomeView()
            }
            .navigationViewStyle(.stack)
            .tabItem {
                Image(systemName: "bubble.left.and.bubble.right.fill")
            }

            ProfileView()
                .tabItem {
                    Image(systemName: "person.crop.circle")
                }
        }
        .accentColor(AppTheme.primary)
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