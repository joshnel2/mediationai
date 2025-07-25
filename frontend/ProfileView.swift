import SwiftUI
import UIKit

// MARK: - Simple Gen-Z Profile Screen

struct ProfileView: View {
    @EnvironmentObject var authService: MockAuthService
    @EnvironmentObject var socialService: SocialAPIService

    // In a real build this would persist, here it is kept in-memory only
    @State private var avatar: Image? = nil
    @State private var showSettings = false

    private var displayName: String {
        if let name = authService.currentUser?.displayName, !name.isEmpty {
            return name
        }
        return authService.currentUser?.email.components(separatedBy: "@").first ?? "Streamer"
    }

    private var clashesCount: Int {
        socialService.liveClashes.count
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 28) {
                    avatarSection

                    Text(displayName)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(AppTheme.textPrimary)

                    followerStats

                    VStack(spacing: 16) {
                        Button(action: {/* TODO: hook into CreateDisputeView */}) {
                            Label("Create Clash", systemImage: "bolt.fill")
                                .font(.headline)
                                .padding()
                                .frame(maxWidth: .infinity)
                        }
                        .primaryButton()

                        Button(action: shareInvite) {
                            Label("Share Invite", systemImage: "link")
                                .font(.headline)
                                .padding()
                                .frame(maxWidth: .infinity)
                        }
                        .accentButton()
                    }
                    .padding(.top)

                    Spacer(minLength: 60)
                }
                .padding()
                .frame(maxWidth: .infinity)
            }
            .background(AppTheme.backgroundGradient.ignoresSafeArea())
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { showSettings = true } label: {
                        Image(systemName: "gearshape.fill")
                    }
                }
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
    }

    // MARK: - Subviews
    private var avatarSection: some View {
        ZStack {
            if let avatar = avatar {
                avatar
                    .resizable()
                    .scaledToFill()
            } else {
                Circle()
                    .fill(AppTheme.accent)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.white)
                    )
            }
        }
        .frame(width: 140, height: 140)
        .clipShape(Circle())
        .shadow(radius: 8)
        .onTapGesture {
            // Image picker would go here in a full build.
        }
    }

    private var followerStats: some View {
        HStack(spacing: 40) {
            VStack {
                Text("1.2k")
                    .font(.title2).bold()
                    .foregroundColor(AppTheme.textPrimary)
                Text("followers")
                    .font(.caption)
                    .foregroundColor(AppTheme.textSecondary)
            }
            VStack {
                Text("\(clashesCount)")
                    .font(.title2).bold()
                    .foregroundColor(AppTheme.textPrimary)
                Text("clashes")
                    .font(.caption)
                    .foregroundColor(AppTheme.textSecondary)
            }
        }
    }

    // MARK: - Helpers
    private func shareInvite() {
        #if canImport(UIKit)
        let text = "Join me on ClashAI ⚡️ – it’s fire!"
        let av = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        UIApplication.shared.windows.first?.rootViewController?.present(av, animated: true)
        #endif
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(MockAuthService())
            .environmentObject(SocialAPIService())
    }
}