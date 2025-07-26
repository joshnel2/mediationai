import Foundation
import Combine
import SwiftUI

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

struct Request: Identifiable, Codable {
    let id: String
    let fromUser: String
    let toUser: String
    let dispute: MockDispute
    var createdAt: Date = Date()
}

struct HistoryItem: Identifiable, Codable {
    let id: String
    let dispute: MockDispute
    let didWin: Bool
    var recordedAt: Date = Date()
}

@MainActor
class SocialAPIService: ObservableObject {
    @Published var liveClashes: [Clash] = []
    @Published var dramaClashes: [Clash] = []
    @Published var publicClashes: [Clash] = []
    // New: feed showing clashes that involve users the current viewer follows
    @Published var followingClashes: [Clash] = []
    @Published var isLoading = false
    @Published var searchResults: [UserSummary] = []
    @Published var overallLeaders: [UserSummary] = []
    @Published var dailyLeaders: [UserSummary] = []
    @Published var hotTopics: [String] = []

    // MARK: - Social Graph
    @AppStorage("followingIDs") private var storedFollowing: Data = Data()
    @Published var following: Set<String> = [] {
        didSet { saveFollowing() }
    }
    @Published var followerCounts: [String: Int] = [:]

    private func loadFollowing() {
        if let ids = try? JSONDecoder().decode(Set<String>.self, from: storedFollowing) {
            following = ids
        }
    }
    private func saveFollowing() {
        if let data = try? JSONEncoder().encode(following) {
            storedFollowing = data
        }
    }

    // New: fake disputes per user
    @Published var disputesByUser: [String: [MockDispute]] = [:]
    @Published var requestsIn: [String: [Request]] = [:]
    @Published var requestsOut: [String: [Request]] = [:]
    @Published var historyByUser: [String: [HistoryItem]] = [:]

    func disputes(for id: String) -> [MockDispute] {
        disputesByUser[id] ?? []
    }

    func recordVote(disputeID: String, voteForA: Bool) {
        for (uid, list) in disputesByUser {
            if let idx = list.firstIndex(where: { $0.id == disputeID }) {
                var updated = list[idx]
                if voteForA { updated.votesA += 1 } else { updated.votesB += 1 }
                disputesByUser[uid]![idx] = updated

                // Update history mock XP: when votes surpass threshold decide win
                if updated.votesA >= 5 || updated.votesB >= 5 {
                    let didAWin = updated.votesA > updated.votesB
                    let winner = didAWin ? updated.statementA : updated.statementB
                    // simplistic: assume uids[0] is A, uid[1] is B (mock)
                    let users = Array(disputesByUser.keys)
                    if users.count >= 2 {
                        let userA = users[0]; let userB = users[1]
                        appendHistory(for: userA, dispute: updated, win: didAWin)
                        appendHistory(for: userB, dispute: updated, win: !didAWin)
                    }
                }
            }
        }
    }

    private func appendHistory(for user:String, dispute:MockDispute, win:Bool){
        historyByUser[user, default: []].append(HistoryItem(id: UUID().uuidString, dispute: dispute, didWin: win))
        if let idx = overallLeaders.firstIndex(where:{$0.id==user}){
            if win { overallLeaders[idx].wins += 1 } else { overallLeaders[idx].wins = max(0, overallLeaders[idx].wins-1) }
        }
    }

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Mock Seed
    init() {
        loadFollowing()
        seedMockData()
    }

    private func seedMockData() {
        // Only seed if arrays are empty (first launch / offline)
        guard overallLeaders.isEmpty else { return }

        let sampleNames = ["PixelPirate", "ValkyMindz", "ChatChamp", "LootLord", "GGWizard", "StreamQueen", "NoScopeSam", "ClipTitan"]

        overallLeaders = sampleNames.map { UserSummary(id: UUID().uuidString, displayName: $0, xp: Int.random(in: 1500...5000), wins: Int.random(in: 5...30)) }

        dailyLeaders = overallLeaders.shuffled().prefix(5).map { leader in
            UserSummary(id: leader.id, displayName: leader.displayName, xp: Int.random(in: 100...500), wins: Int.random(in: 0...3))
        }

        liveClashes = (0..<6).map { _ in
            Clash(id: UUID().uuidString,
                  streamerA: sampleNames.randomElement()!,
                  streamerB: sampleNames.randomElement()!,
                  viewerCount: Int.random(in: 100...4000),
                  startedAt: ISO8601DateFormatter().string(from: Date().addingTimeInterval(-Double.random(in: 300...7200))),
                  votes: Int.random(in: 50...2000),
                  isPublic: true)
        }

        // Controversial drama topics people love to debate
        let controversies: [(String,String)] = [
            ("Israel", "Palestine"),
            ("PS5", "Xbox Series X"),
            ("Bitcoin", "Fiat"),
            ("Pineapple Pizza", "Classic Pizza"),
            ("Cats", "Dogs"),
            ("Marvel", "DC")
        ]
        dramaClashes = controversies.map { pair in
            Clash(id: UUID().uuidString,
                  streamerA: pair.0,
                  streamerB: pair.1,
                  viewerCount: Int.random(in: 50...1000),
                  startedAt: ISO8601DateFormatter().string(from: Date()),
                  votes: Int.random(in: 50...1000),
                  isPublic: true)
        }

        publicClashes = (0..<20).map { _ in
            Clash(id: UUID().uuidString, streamerA: sampleNames.randomElement()!, streamerB: sampleNames.randomElement()!, viewerCount: Int.random(in: 20...400), startedAt: ISO8601DateFormatter().string(from: Date()), votes: nil, isPublic: true)
        }

        hotTopics = ["AI Art", "GTA6", "EldenRing", "Valorant", "F1"]

        // Show users immediately in People tab
        searchResults = overallLeaders

        // Seed disputes & follow counts
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

            followerCounts[leader.id] = Int.random(in: 200...5000)
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
            dramaClashes.shuffle()
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

    // MARK: - Following Feed
    /// Builds a local feed of clashes that feature streamers the viewer follows.
    /// For the mock-data path this is generated client-side. In production you would hit a backend endpoint.
    func fetchFollowingClashes() {
        if APIConfig.enableMockData {
            let followedIDs = following
            // Map ids to display names for quick lookup
            let idToName = Dictionary(uniqueKeysWithValues: overallLeaders.map { ($0.id, $0.displayName) })
            let followedNames = Set(followedIDs.compactMap { idToName[$0] })

            // Combine all known clash arrays then dedupe by id
            let combined = (liveClashes + dramaClashes + publicClashes)
            let filtered = combined.filter { followedNames.contains($0.streamerA) || followedNames.contains($0.streamerB) }
            let deduped = Dictionary(grouping: filtered, by: { $0.id }).compactMap { $0.value.first }
            followingClashes = deduped.sorted { ($0.votes ?? 0) > ($1.votes ?? 0) }
            return
        }

        // Production path – call server
        guard let url = URL(string: "\(APIConfig.baseURL)/api/clashes/following"),
              let token = UserDefaults.standard.string(forKey: "authToken") else { return }
        var req = URLRequest(url: url)
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        isLoading = true
        URLSession.shared.dataTaskPublisher(for: req)
            .map { $0.data }
            .decode(type: [Clash].self, decoder: JSONDecoder())
            .replaceError(with: [])
            .receive(on: DispatchQueue.main)
            .sink { [weak self] c in
                self?.followingClashes = c
                self?.isLoading = false
            }
            .store(in: &cancellables)
    }

    struct UserSummary: Identifiable, Codable {
        let id: String
        let displayName: String
        let xp: Int
        let wins: Int
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
        if APIConfig.enableMockData { return }
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

    // MARK: - Follow Logic
    func toggleFollow(id: String) {
        if following.contains(id) {
            following.remove(id)
            followerCounts[id, default: 0] = max(0, followerCounts[id, default: 0] - 1)
        } else {
            following.insert(id)
            followerCounts[id, default: 0] += 1
        }
    }

    func followUser(id: String) {
        if APIConfig.enableMockData {
            toggleFollow(id: id)
            return
        }
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

    // create a new dispute between two users and return it
    func createClashBetween(_ a: String, _ b: String) -> MockDispute {
        let disp = MockDispute(id: UUID().uuidString, title: "\(userName(a)) vs \(userName(b))", statementA: "I was better!", statementB: "No, I won!", votesA: 0, votesB: 0)
        disputesByUser[a, default: []].append(disp)
        disputesByUser[b, default: []].append(disp)
        liveClashes.append(Clash(id: disp.id, streamerA: userName(a), streamerB: userName(b), viewerCount: 0, startedAt: ISO8601DateFormatter().string(from:Date()), votes: 0, isPublic: true))
        return disp
    }

    private func userName(_ id: String) -> String {
        overallLeaders.first { $0.id == id }?.displayName ?? "Anon"
    }
}