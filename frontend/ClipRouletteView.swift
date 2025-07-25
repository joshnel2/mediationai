import SwiftUI
import AVKit

struct ClipRouletteView: View {
    @EnvironmentObject var viral: ViralAPIService
    @State private var currentIndex = 0
    @State private var player = AVPlayer()
    @GestureState private var dragOffset: CGFloat = 0

    var body: some View {
        ZStack {
            if viral.clips.isEmpty {
                ProgressView().onAppear { viral.fetchRouletteClips() }
            } else {
                TabView(selection: $currentIndex) {
                    ForEach(viral.clips.indices, id: \..self) { idx in
                        ClipPlayerView(urlString: viral.clips[idx].url, caption: viral.clips[idx].caption)
                            .tag(idx)
                            .onLongPressGesture(minimumDuration: 0.5) {
                                share(clip: viral.clips[idx])
                            }
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
        }
        .onAppear { viral.fetchRouletteClips() }
    }

    private func share(clip: Clip) {
        viral.tiktokURL(for: clip.id) { url in
            guard let urlStr = url, let shareURL = URL(string: urlStr) else { return }
            let act = UIActivityViewController(activityItems: [shareURL], applicationActivities: nil)
            UIApplication.shared.windows.first?.rootViewController?.present(act, animated: true)
        }
    }
}

struct ClipPlayerView: View {
    let urlString: String
    let caption: String?
    @State private var player: AVPlayer = .init()

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            VideoPlayer(player: player)
                .onAppear {
                    if let url = URL(string: urlString) {
                        player.replaceCurrentItem(with: AVPlayerItem(url: url))
                        player.play()
                        player.isMuted = true
                        player.actionAtItemEnd = .none
                        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: .main) { _ in
                            player.seek(to: .zero); player.play()
                        }
                    }
                }
            if let caption = caption {
                Text(caption)
                    .font(.headline)
                    .padding()
                    .background(Color.black.opacity(0.5))
                    .foregroundColor(.white)
            }
        }
        .ignoresSafeArea()
    }
}