import Foundation

enum MessageCache {
    private static let directory: URL = {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("MessageCache", isDirectory: true)
    }()

    private static func file(for id: String) -> URL {
        directory.appendingPathComponent("\(id).json")
    }

    static func load(disputeId: String) -> [String] {
        do {
            let url = file(for: disputeId)
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode([String].self, from: data)
        } catch { return [] }
    }

    static func save(disputeId: String, messages: [String]) {
        do {
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            let trimmed = Array(messages.suffix(100))
            let data = try JSONEncoder().encode(trimmed)
            try data.write(to: file(for: disputeId), options: .atomic)
        } catch { /* ignore */ }
    }
}