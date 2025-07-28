import Foundation

struct ModerationService {
    static let bannedWords: Set<String> = ["badword1","badword2","hate"]
    static func isClean(_ text: String) -> Bool {
        let lower = text.lowercased()
        return !bannedWords.contains(where: { lower.contains($0) })
    }
}