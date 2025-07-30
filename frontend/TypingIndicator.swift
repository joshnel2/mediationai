import SwiftUI

struct TypingIndicator: View {
    @State private var scale: CGFloat = 0.5
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3) { idx in
                Circle()
                    .fill(Color.gray)
                    .frame(width: 6, height: 6)
                    .scaleEffect(scale)
                    .animation(
                        .easeInOut(duration: 0.6)
                            .repeatForever()
                            .delay(Double(idx) * 0.2),
                        value: scale
                    )
            }
        }
        .onAppear { scale = 1 }
        .padding(10)
        .background(Color(UIColor.systemGray5))
        .clipShape(Capsule())
    }
}