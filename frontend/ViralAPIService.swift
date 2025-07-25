import Foundation
import Combine

@MainActor
class ViralAPIService: ObservableObject {
    static let shared = ViralAPIService()

    @Published var todayDramaKeyword: String = ""
    @Published var clips: [Clip] = []

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Invite
    func redeemInvite(code: String, token: String, completion: @escaping (Bool, String?) -> Void) {
        guard let url = URL(string: "\(APIConfig.baseURL)/api/invite/redeem?code=\(code)") else { return }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: req) { data, resp, _ in
            guard let http = resp as? HTTPURLResponse, 200...299 ~= http.statusCode else {
                completion(false, nil); return
            }
            if let data = data,
               let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let badge = json["badge"] as? String {
                completion(true, badge)
            } else {
                completion(true, nil)
            }
        }.resume()
    }

    // MARK: - Drama Drop
    func fetchTodayDrama() {
        guard todayDramaKeyword.isEmpty,
              let url = URL(string: "\(APIConfig.baseURL)/api/drama/today") else { return }
        URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: DramaResponse.self, decoder: JSONDecoder())
            .replaceError(with: DramaResponse(keyword: "Surprise"))
            .receive(on: DispatchQueue.main)
            .sink { [weak self] resp in self?.todayDramaKeyword = resp.keyword }
            .store(in: &cancellables)
    }

    func startDrama(token: String, completion: @escaping (String?) -> Void) {
        guard let url = URL(string: "\(APIConfig.baseURL)/api/drama/start") else { return }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: req) { data, resp, _ in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let clashID = json["clash_id"] as? String else { completion(nil); return }
            completion(clashID)
        }.resume()
    }

    struct DramaResponse: Codable { let keyword: String }

    // MARK: - Clip Roulette
    func fetchRouletteClips() {
        guard let url = URL(string: "\(APIConfig.baseURL)/api/clips/roulette") else { return }
        URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: [Clip].self, decoder: JSONDecoder())
            .replaceError(with: [])
            .receive(on: DispatchQueue.main)
            .sink { [weak self] clips in self?.clips = clips }
            .store(in: &cancellables)
    }

    func tiktokURL(for clipID: String, completion: @escaping (String?) -> Void) {
        guard let url = URL(string: "\(APIConfig.baseURL)/api/clips/\(clipID)/tiktok") else { completion(nil); return }
        URLSession.shared.dataTask(with: url) { data, resp, _ in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let upload = json["uploadUrl"] as? String else { completion(nil); return }
            completion(upload)
        }.resume()
    }

    func registerDeviceToken(_ token: String) {
        guard let url = URL(string: "\(APIConfig.baseURL)/api/devices"), let jwt = UserDefaults.standard.string(forKey: "authToken") else { return }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("Bearer \(jwt)", forHTTPHeaderField: "Authorization")
        req.httpBody = try? JSONSerialization.data(withJSONObject: ["token": token])
        URLSession.shared.dataTask(with: req).resume()
    }
}