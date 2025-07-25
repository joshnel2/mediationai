import Foundation
import Combine

struct Clash: Identifiable, Codable {
    let id: String
    let streamerA: String
    let streamerB: String
    let viewerCount: Int
    let startedAt: String
    let votes: Int?
    let isPublic: Bool?

    enum CodingKeys: String, CodingKey {
        case id = "clash_id"
        case streamerA, streamerB, viewerCount, startedAt
        case votes
        case isPublic
    }
}

@MainActor
class SocialAPIService: ObservableObject {
    @Published var liveClashes: [Clash] = []
    @Published var isLoading = false
    @Published var searchResults: [UserSummary] = []
    @Published var overallLeaders: [UserSummary] = []
    @Published var dailyLeaders: [UserSummary] = []
    @Published var hotTopics: [String] = []

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Mock Seed
    init() {
        seedMockData()
    }

    private func seedMockData() {
        // Only seed if arrays are empty (first launch / offline)
        guard overallLeaders.isEmpty else { return }

        let sampleNames = ["PixelPirate", "ValkyMindz", "ChatChamp", "LootLord", "GGWizard", "StreamQueen", "NoScopeSam", "ClipTitan"]

        overallLeaders = sampleNames.map { UserSummary(id: UUID().uuidString, displayName: $0, xp: Int.random(in: 1500...5000)) }

        dailyLeaders = overallLeaders.shuffled().prefix(5).map { leader in
            UserSummary(id: leader.id, displayName: leader.displayName, xp: Int.random(in: 100...500))
        }

        liveClashes = (0..<6).map { _ in
            Clash(id: UUID().uuidString, streamerA: sampleNames.randomElement()!, streamerB: sampleNames.randomElement()!, viewerCount: Int.random(in: 100...4000), startedAt: ISO8601DateFormatter().string(from: Date().addingTimeInterval(-Double.random(in: 300...7200))), votes: nil, isPublic: true)
        }

        hotTopics = ["AI Art", "GTA6", "EldenRing", "Valorant", "F1"]
    }

    func fetchLiveClashes() {
        guard let url = URL(string: "\(APIConfig.baseURL)/api/clashes/live") else { return }
        isLoading = true

        URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: [Clash].self, decoder: JSONDecoder())
            .replaceError(with: [])
            .receive(on: DispatchQueue.main)
            .sink { [weak self] clashes in
                self?.liveClashes = clashes
                self?.isLoading = false
            }
            .store(in: &cancellables)
    }

    func fetchDramaFeed() {
        guard let url = URL(string: "\(APIConfig.baseURL)/api/clashes/drama") else { return }
        isLoading = true
        URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: [Clash].self, decoder: JSONDecoder())
            .replaceError(with: [])
            .receive(on: DispatchQueue.main)
            .sink { [weak self] clashes in
                self?.liveClashes = clashes
                self?.isLoading = false
            }
            .store(in: &cancellables)
    }

    func fetchHotTopics() {
        guard let url = URL(string: "\(APIConfig.baseURL)/api/hot-topics") else { return }
        URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: [String].self, decoder: JSONDecoder())
            .replaceError(with: [])
            .receive(on: DispatchQueue.main)
            .sink { [weak self] topics in self?.hotTopics = topics }
            .store(in: &cancellables)
    }

    func fetchPublicClashes() {
        guard let url = URL(string: "\(APIConfig.baseURL)/api/clashes/public") else { return }
        isLoading = true
        URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: [Clash].self, decoder: JSONDecoder())
            .replaceError(with: [])
            .receive(on: DispatchQueue.main)
            .sink { [weak self] c in
                self?.liveClashes = c
                self?.isLoading = false
            }
            .store(in: &cancellables)
    }

    struct UserSummary: Identifiable, Codable {
        let id: String
        let displayName: String
        let xp: Int
    }

    func searchUsers(query: String) {
        guard let url = URL(string: "\(APIConfig.baseURL)/api/users/search?q=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")") else { return }
        URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: [UserSummary].self, decoder: JSONDecoder())
            .replaceError(with: [])
            .receive(on: DispatchQueue.main)
            .sink { [weak self] users in self?.searchResults = users }
            .store(in: &cancellables)
    }

    func fetchLeaderboard() {
        guard let url1 = URL(string: "\(APIConfig.baseURL)/api/leaderboard/overall"),
              let url2 = URL(string: "\(APIConfig.baseURL)/api/leaderboard/daily") else { return }
        URLSession.shared.dataTaskPublisher(for: url1)
            .map { $0.data }
            .decode(type: [UserSummary].self, decoder: JSONDecoder())
            .replaceError(with: [])
            .receive(on: DispatchQueue.main)
            .sink { [weak self] arr in self?.overallLeaders = arr }
            .store(in: &cancellables)

        URLSession.shared.dataTaskPublisher(for: url2)
            .map { $0.data }
            .decode(type: [UserSummary].self, decoder: JSONDecoder())
            .replaceError(with: [])
            .receive(on: DispatchQueue.main)
            .sink { [weak self] arr in self?.dailyLeaders = arr }
            .store(in: &cancellables)
    }

    func followUser(id: String) {
        guard let url = URL(string: "\(APIConfig.baseURL)/api/follow/\(id)"), let token = UserDefaults.standard.string(forKey: "authToken") else { return }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: req).resume()
    }

    func createClash(with id: String) {
        guard let url = URL(string: "\(APIConfig.baseURL)/api/clashes?streamer_a_id=ME&streamer_b_id=\(id)"), let token = UserDefaults.standard.string(forKey: "authToken") else { return }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: req).resume()
    }
}