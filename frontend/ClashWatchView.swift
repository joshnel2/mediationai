import SwiftUI
import Combine

class ClashWebSocketManager: ObservableObject {
    @Published var reactions: [UUID: String] = [:]
    private var webSocketTask: URLSessionWebSocketTask?

    func connect(clashId: String) {
        guard let url = URL(string: "ws://" + APIConfig.baseURL.replacingOccurrences(of: "https://", with: "") + "/ws/clash/\(clashId)") else { return }
        webSocketTask = URLSession.shared.webSocketTask(with: url)
        webSocketTask?.resume()
        listen()
    }

    private func listen() {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .success(let message):
                if case .string(let text) = message,
                   let data = text.data(using: .utf8),
                   let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   obj["type"] as? String == "reaction",
                   let dataDict = obj["data"] as? [String: String],
                   let emoji = dataDict["emoji"] {
                    DispatchQueue.main.async {
                        self?.reactions[UUID()] = emoji
                    }
                }
            case .failure:
                break
            }
            self?.listen()
        }
    }

    func sendReaction(_ emoji: String) {
        let json = ["emoji": emoji]
        if let data = try? JSONSerialization.data(withJSONObject: json),
           let text = String(data: data, encoding: .utf8) {
            webSocketTask?.send(.string(text)) { _ in }
        }
    }

    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
    }
}

struct ClashWatchView: View {
    let clash: Clash
    @StateObject private var wsManager = ClashWebSocketManager()
    @EnvironmentObject var authService: MockAuthService
    @State private var isPublic = false
    @State private var showCopied = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack {
                HStack {
                    Text("\(clash.streamerA) VS \(clash.streamerB)")
                        .font(.title.bold())
                        .foregroundColor(.white)
                        .padding(.top)

                    if authService.currentUser?.id == clash.streamerA {
                        Toggle("Public", isOn: $isPublic)
                            .toggleStyle(SwitchToggleStyle(tint: AppTheme.accent))
                            .onChange(of: isPublic) { val in
                                setPublic(val)
                            }
                    } else if clash.isPublic ?? true { // watchers copy link
                        Button(action: copyLink) {
                            Image(systemName: "link.circle")
                        }
                        .alert("Link Copied", isPresented: $showCopied) { Button("OK", role: .cancel) {} }
                    }
                }

                Spacer()

                HStack(spacing: 30) {
                    ForEach(["🔥", "😂", "💥", "👏"], id: \.self) { emoji in
                        Button(emoji) {
                            wsManager.sendReaction(emoji)
                        }
                        .font(.system(size: 40))
                    }
                }
                .padding(.bottom, 40)
            }

            // Floating reactions
            ForEach(Array(wsManager.reactions.keys), id: \.self) { key in
                if let emoji = wsManager.reactions[key] {
                    ReactionOverlay(reaction: emoji)
                        .position(x: CGFloat.random(in: 50...UIScreen.main.bounds.width - 50),
                                  y: CGFloat.random(in: 100...UIScreen.main.bounds.height - 200))
                        .onAppear {
                            // Remove after animation
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
                                wsManager.reactions.removeValue(forKey: key)
                            }
                        }
                }
            }
        }
        .onAppear {
            wsManager.connect(clashId: clash.id)
        }
        .onDisappear {
            wsManager.disconnect()
        }
    }

    private func setPublic(_ val: Bool) {
        guard let token = authService.jwtToken else { return }
        guard let url = URL(string: "\(APIConfig.baseURL)/api/clashes/\(clash.id)/public?public=\(val)") else { return }
        var req = URLRequest(url: url)
        req.httpMethod = "PATCH"
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: req).resume()
    }
    private func copyLink() {
        UIPasteboard.general.string = "https://clashup.app/clash/\(clash.id)"
        showCopied = true
    }
}

struct ClashWatchView_Previews: PreviewProvider {
    static var previews: some View {
        ClashWatchView(clash: Clash(id: "1", streamerA: "Alice", streamerB: "Bob", viewerCount: 120, startedAt: ISO8601DateFormatter().string(from: Date())))
    }
}