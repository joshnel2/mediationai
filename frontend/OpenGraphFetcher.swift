import Foundation
import SwiftSoup

struct LinkMetadata: Identifiable {
    let id = UUID()
    let url: URL
    let title: String
    let description: String
    let imageURL: URL?
}

enum OpenGraphFetcher {
    static func fetch(from url: URL, completion: @escaping (LinkMetadata?) -> Void) {
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data, let html = String(data: data, encoding: .utf8) else { return completion(nil) }
            DispatchQueue.global().async {
                do {
                    let doc: Document = try SwiftSoup.parse(html)
                    let title = try doc.select("meta[property=og:title]").first()?.attr("content") ?? url.host ?? "Link"
                    let desc = try doc.select("meta[property=og:description]").first()?.attr("content") ?? ""
                    let img = try doc.select("meta[property=og:image]").first()?.attr("content")
                    DispatchQueue.main.async {
                        completion(LinkMetadata(url: url, title: title, description: desc, imageURL: img.flatMap(URL.init)))
                    }
                } catch { completion(nil) }
            }
        }.resume()
    }
}