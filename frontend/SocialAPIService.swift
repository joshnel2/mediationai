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

// MARK: - Mock Dispute Model
struct MockDispute: Identifiable, Codable {
    let id: String
    let title: String
    let statementA: String
    let statementB: String
    var votesA: Int
    var votesB: Int
}

@MainActor
class SocialAPIService: ObservableObject {
    @Published var liveClashes: [Clash] = []
    @Published var isLoading = false
    @Published var searchResults: [UserSummary] = []
    @Published var overallLeaders: [UserSummary] = []
    @Published var dailyLeaders: [UserSummary] = []
    @Published var hotTopics: [String] = []

    // New: fake disputes per user
    @Published var disputesByUser: [String: [MockDispute]] = [:]

    func disputes(for id: String) -> [MockDispute] {
        disputesByUser[id] ?? []
    }

    func recordVote(disputeID: String, voteForA: Bool) {
        for (uid, list) in disputesByUser {
            if let idx = list.firstIndex(where: { $0.id == disputeID }) {
                var updated = list[idx]
                if voteForA { updated.votesA += 1 } else { updated.votesB += 1 }
                disputesByUser[uid]![idx] = updated
            }
        }
    }

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

        // Show users immediately in People tab
        searchResults = overallLeaders

        // Seed disputes for each user
        let sampleDisputeTitles = ["Who Streams Better?", "Lag Blame Game", "Clip Ownership"]
        for leader in overallLeaders {
            var arr: [MockDispute] = []
            for _ in 0..<Int.random(in: 1...3) {
                arr.append(MockDispute(id: UUID().uuidString,
                                       title: sampleDisputeTitles.randomElement()!,
                                       statementA: "Streamer A claims victory.",
                                       statementB: "Streamer B disagrees.",
                                       votesA: Int.random(in: 10...200),
                                       votesB: Int.random(in: 10...200)))
            }
            disputesByUser[leader.id] = arr
        }
    }

    func fetchLiveClashes() {
        if APIConfig.enableMockData {
            liveClashes.shuffle()
            return
        }
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
        if APIConfig.enableMockData {
            liveClashes.shuffle()
            return
        }
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
        if APIConfig.enableMockData {
            liveClashes.shuffle()
            return
        }
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
        if APIConfig.enableMockData {
            searchResults = overallLeaders.filter { $0.displayName.lowercased().contains(query.lowercased()) || query.isEmpty }
            return
        }
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