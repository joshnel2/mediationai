import SwiftUI

struct LiveFeedView: View {
    @StateObject private var socialService = SocialAPIService()
    @State private var isRefreshing = false

    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.backgroundGradient
                    .ignoresSafeArea()

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
            .navigationTitle("Live")
            .toolbar {
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
            socialService.fetchLiveClashes()
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