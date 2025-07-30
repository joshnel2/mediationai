import SwiftUI

/// A modern chat bubble supporting avatars, colour-coding and alignment.
struct MessageBubble: View {
    let text: String
    let isMine: Bool    // true = current user / Side-A
    let showAvatar: Bool
    let avatarURL: URL?
    let isAI: Bool

    private var bubbleColor: LinearGradient {
        if isAI {
            return LinearGradient(colors: [Color(UIColor.systemGray5), Color(UIColor.systemGray4)], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
        if isMine {
            return LinearGradient(colors: [AppTheme.primary.opacity(0.9), AppTheme.primary.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
        return LinearGradient(colors: [Color(UIColor.systemGray6), Color(UIColor.systemGray5)], startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    private var textColor: Color { isMine ? .white : .black }

    var body: some View {
        HStack(alignment: .bottom, spacing: 6) {
            if !isMine { avatarView }

            Text(text)
                .font(.body)
                .foregroundColor(textColor)
                .padding(12)
                .background(bubbleColor)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.white.opacity(0.04), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                .frame(maxWidth: .infinity, alignment: isMine ? .trailing : .leading)

            if isMine { avatarView }
        }
        .padding(.horizontal, 2)
        .padding(.vertical, 2)
    }

    @ViewBuilder
    private var avatarView: some View {
        if showAvatar, let url = avatarURL {
            AsyncImage(url: url) { phase in
                (phase.image ?? Image(systemName: "person.circle.fill")).resizable()
            }
            .frame(width: 24, height: 24)
            .clipShape(Circle())
            .shadow(radius: 1)
        } else {
            Spacer().frame(width: 24)
        }
    }
}