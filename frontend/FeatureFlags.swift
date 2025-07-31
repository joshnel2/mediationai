import SwiftUI
import Combine

final class FeatureFlags: ObservableObject {
    static let shared = FeatureFlags()
    private var cancellables = Set<AnyCancellable>()
    @Published var reactionsEnabled: Bool = true
    @Published var heatMeterEnabled: Bool = true
    @Published var smartScrollEnabled: Bool = true

    private let url = URL(string: "https://mediationai.app/config.json")!

    init() {
        fetch()
    }

    func fetch() {
        URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: [String: Bool].self, decoder: JSONDecoder())
            .replaceError(with: [:])
            .receive(on: DispatchQueue.main)
            .sink { [weak self] dict in
                self?.reactionsEnabled = dict["reactionsEnabled"] ?? self?.reactionsEnabled ?? true
                self?.heatMeterEnabled = dict["heatMeterEnabled"] ?? self?.heatMeterEnabled ?? true
                self?.smartScrollEnabled = dict["smartScrollEnabled"] ?? self?.smartScrollEnabled ?? true
            }
            .store(in: &cancellables)
    }
}