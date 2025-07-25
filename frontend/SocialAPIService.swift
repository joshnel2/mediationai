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
}