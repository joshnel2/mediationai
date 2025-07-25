import SwiftUI

struct LiveFeedView: View {
    @StateObject private var socialService = SocialAPIService()
    @State private var isRefreshing = false
    @State private var navigateClashID: String?
    @EnvironmentObject var viralService: ViralAPIService
    @EnvironmentObject var authService: MockAuthService
    @State private var tab = 0

    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.backgroundGradient
                    .ignoresSafeArea()
                VStack {
                    // Drama drop button
                    if !viralService.todayDramaKeyword.isEmpty {
                        DramaDropButton(keyword: viralService.todayDramaKeyword) {
                            if let token = authService.jwtToken {
                                viralService.startDrama(token: token) { id in
                                    if let id = id {
                                        // navigate to clash watch
                                        DispatchQueue.main.async {
                                            navigateClashID = id
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.top)
                    }
                    // Picker moved to toolbar
                    contentView
                }
            }
            .navigationTitle("Live")
            .toolbar {
                // Segmented control right under the nav bar title
                ToolbarItem(placement: .principal) {
                    Picker("Mode", selection: $tab) {
                        Text("Live").tag(0)
                        Text("Drama").tag(1)
                        Text("Public").tag(2)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .frame(width: 250)
                    .onChange(of: tab) { newVal in
                        switch newVal {
                        case 0: socialService.fetchLiveClashes()
                        case 1: socialService.fetchDramaFeed()
                        default: socialService.fetchPublicClashes()
                        }
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { Task { await refresh() } }) {
                        Image(systemName: "arrow.clockwise.circle")
                            .imageScale(.large)
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .onAppear {
            if tab == 0 { socialService.fetchLiveClashes() } else if tab == 1 { socialService.fetchDramaFeed() } else { socialService.fetchPublicClashes() }
        }
    }

    private var contentView: some View {
        Group {
            if socialService.isLoading && socialService.liveClashes.isEmpty {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
            } else if socialService.liveClashes.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "bolt.bubble")
                        .font(.system(size: 48))
                        .foregroundColor(.white.opacity(0.8))
                    Text("No live clashes yet\nCheck back soon!")
                        .font(.title3.weight(.semibold))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white.opacity(0.8))
                }
            } else {
                ScrollView {
                    LazyVStack(spacing: 20) {
                        ForEach(socialService.liveClashes) { clash in
                            ClashCardView(clash: clash)
                                .background(
                                    NavigationLink(destination: ClashWatchView(clash: clash)) {
                                        EmptyView()
                                    }.opacity(0)
                                )
                        }
                    }
                    .padding()
                    .refreshable {
                        await refresh()
                    }
                }
            }
        }
    }

    @MainActor
    private func refresh() async {
        isRefreshing = true
        socialService.fetchLiveClashes()
        // simple delay to end refresh animation
        try? await Task.sleep(nanoseconds: 600_000_000)
        isRefreshing = false
    }
}

struct ClashCardView: View {
    let clash: Clash

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(LinearGradient(colors: [Color.purple.opacity(0.8), Color.blue.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing))
                .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)

            VStack(spacing: 12) {
                HStack {
                    Text("🔥 \(clash.streamerA) VS \(clash.streamerB)")
                        .font(.headline)
                        .foregroundColor(.white)
                        .lineLimit(1)
                    Spacer()
                    HStack(spacing: 4) {
                        Image(systemName: "person.2.fill")
                        Text("\(clash.viewerCount)")
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.white.opacity(0.9))
                }

                HStack {
                    Text("Started: \(formattedDate(clash.startedAt))")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                    Spacer()
                    Image(systemName: "play.rectangle.fill")
                        .foregroundColor(.white.opacity(0.9))
                }
            }
            .padding()
        }
        .frame(maxWidth: .infinity, minHeight: 110)
    }

    private func formattedDate(_ iso: String) -> String {
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: iso) {
            let rel = RelativeDateTimeFormatter()
            rel.unitsStyle = .short
            return rel.localizedString(for: date, relativeTo: Date())
        }
        return "now"
    }
}

struct LiveFeedView_Previews: PreviewProvider {
    static var previews: some View {
        LiveFeedView()
    }
}