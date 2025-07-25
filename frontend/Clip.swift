import Foundation

struct Clip: Identifiable, Codable {
    let id: String
    let url: String
    let caption: String?

    enum CodingKeys: String, CodingKey {
        case id = "clip_id"
        case url, caption
    }
}