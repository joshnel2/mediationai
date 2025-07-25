import Foundation
import Combine
import SwiftUI

@MainActor
class BadgeService: ObservableObject {
    @Published var badges: [String] = []
    @Published var xp: Int = 0
    @Published var newBadgeUnlocked: String?

    private var cancellables = Set<AnyCancellable>()

    func fetchBadges(token: String) {
        guard let url = URL(string: "\(APIConfig.baseURL)/api/badges") else { return }
        var req = URLRequest(url: url)
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTaskPublisher(for: req)
            .map { $0.data }
            .decode(type: BadgeResponse.self, decoder: JSONDecoder())
            .replaceError(with: BadgeResponse(xp: 0, badges: []))
            .receive(on: DispatchQueue.main)
            .sink { [weak self] resp in
                if resp.badges.count > self?.badges.count ?? 0 {
                    self?.newBadgeUnlocked = resp.badges.last
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self?.newBadgeUnlocked = nil
                    }
                }
                self?.badges = resp.badges
                self?.xp = resp.xp
            }
            .store(in: &cancellables)
    }

    struct BadgeResponse: Codable {
        let xp: Int
        let badges: [String]
    }
}