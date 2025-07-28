import Foundation

struct SummarizationService {
    /// Very lightweight mock. In production, call an LLM endpoint with previous messages as context and ask for one-sentence summary.
    static func generateSummary(for messages: [String], completion: @escaping (String) -> Void) {
        // Simulate async call
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
            let combined = messages.joined(separator: " ")
            let words = combined.split(separator: " ")
            let prefix = words.prefix(20).joined(separator: " ")
            let summary = prefix.isEmpty ? "No summary yet" : "TL;DR – \(prefix)..."
            completion(summary)
        }
    }
}