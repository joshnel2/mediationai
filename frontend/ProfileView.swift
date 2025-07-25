import SwiftUI
import UIKit
import PhotosUI

// MARK: - Simple Gen-Z Profile Screen

struct ProfileView: View {
    @EnvironmentObject var authService: MockAuthService
    @EnvironmentObject var socialService: SocialAPIService

    @AppStorage("displayName") private var storedName: String = ""
    @State private var editingName = false

    @State private var avatarItem: PhotosPickerItem? = nil
    @State private var avatarUIImage: UIImage? = nil
    @State private var showPicker = false
    private var avatarImg: Image? { avatarUIImage.map { Image(uiImage: $0) } }

    @State private var showSettings = false

    private var displayName: String {
        storedName.isEmpty ? (authService.currentUser?.email.components(separatedBy: "@").first ?? "Streamer") : storedName
    }

    private var clashesCount: Int {
        socialService.liveClashes.count
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 28) {
                    avatarSection

                    nameSection

                    followerStats

                    chipsSection

                    myDisputesSection

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
            if let img = avatarImg {
                img.resizable().scaledToFill()
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
        .photosPicker(isPresented: $showPicker, selection: $avatarItem, matching: .images)
        .onChange(of: avatarItem) { newItem in
            guard let item = newItem else { return }
            Task {
                if let data = try? await item.loadTransferable(type: Data.self), let uiImg = UIImage(data: data) {
                    avatarUIImage = uiImg
                }
            }
        }
    }

    private var nameSection: some View {
        HStack {
            if editingName {
                TextField("Username", text: $storedName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 200)
                Button("Done") { editingName = false }
            } else {
                Text(displayName)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(AppTheme.textPrimary)
                Button(action: { editingName = true }) {
                    Image(systemName: "pencil")
                }
            }
        }
    }

    private var followerStats: some View { EmptyView() }

    private var chipsSection: some View {
        HStack(spacing:24){
            NavigationLink(destination: FollowingListView()){
                Text("Following \(socialService.following.count)")
                    .font(.caption).padding(8).background(AppTheme.cardGradient).cornerRadius(12)
            }
            Text("Followers \(socialService.followerCounts[authService.currentUser?.id.uuidString ?? "", default:0])")
                .font(.caption).padding(8).background(AppTheme.cardGradient).cornerRadius(12)
            Spacer()
        }
    }

    private var myDisputesSection: some View {
        VStack(alignment:.leading){
            Text("My Disputes").font(.headline)
            ForEach(socialService.disputes(for: authService.currentUser?.id.uuidString ?? "")) { disp in
                NavigationLink(destination: ConversationView(dispute: disp)){
                    VStack(alignment:.leading){
                        Text(disp.title).bold()
                        Text("Score: \(disp.votesA)-\(disp.votesB)").font(.caption)
                    }
                }
                .padding(8).background(AppTheme.cardGradient).cornerRadius(12)
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