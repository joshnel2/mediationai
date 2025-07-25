import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authService: MockAuthService

    var body: some View {
        TabView {
            LiveFeedView()
                .tabItem {
                    Image(systemName: "bolt.bubble.fill")
                    Text("Live")
                }

            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }

            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Settings")
                }
            ClipRouletteView()
                .tabItem {
                    Image(systemName: "play.rectangle")
                    Text("Clips")
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
    }
}