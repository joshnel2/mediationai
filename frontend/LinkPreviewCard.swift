import SwiftUI

struct LinkPreviewCard: View {
    let url: URL
    @State private var metadata: LinkMetadata?
    var body: some View {
        Group {
            if let meta = metadata {
                VStack(alignment: .leading, spacing: 6) {
                    if let img = meta.imageURL {
                        AsyncImage(url: img) { phase in
                            (phase.image ?? Image(systemName: "photo")).resizable()
                        }
                        .aspectRatio(16/9, contentMode: .fill)
                        .frame(maxWidth: .infinity)
                        .clipped()
                    }
                    Text(meta.title)
                        .font(.subheadline.bold())
                    if !meta.description.isEmpty {
                        Text(meta.description)
                            .font(.caption)
                            .lineLimit(2)
                            .foregroundColor(.secondary)
                    }
                    Text(meta.url.host ?? meta.url.absoluteString)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .padding(8)
                .background(AppTheme.cardGradient)
                .cornerRadius(12)
            } else {
                VStack(alignment: .leading, spacing: 6) {
                    Rectangle()
                        .fill(AppTheme.glassSecondary)
                        .frame(height: 90)
                        .shimmer()
                    Rectangle()
                        .fill(AppTheme.glassSecondary)
                        .frame(height: 14)
                        .shimmer()
                    Rectangle()
                        .fill(AppTheme.glassSecondary)
                        .frame(height: 10)
                        .shimmer()
                }
                .cornerRadius(12)
            }
        }
        .onAppear { fetch() }
    }
    private func fetch() {
        guard metadata == nil else { return }
        OpenGraphFetcher.fetch(from: url) { meta in
            self.metadata = meta
        }
    }
}