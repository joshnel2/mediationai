import Foundation
import Combine

struct Clash: Identifiable, Codable {
    let id: String
    let streamerA: String
    let streamerB: String
    let viewerCount: Int
    let startedAt: String

    enum CodingKeys: String, CodingKey {
        case id = "clash_id"
        case streamerA, streamerB, viewerCount, startedAt
    }
}

@MainActor
class SocialAPIService: ObservableObject {
    @Published var liveClashes: [Clash] = []
    @Published var isLoading = false
    @Published var searchResults: [UserSummary] = []
    @Published var overallLeaders: [UserSummary] = []
    @Published var dailyLeaders: [UserSummary] = []

    private var cancellables = Set<AnyCancellable>()

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