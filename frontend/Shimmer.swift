import SwiftUI

// MARK: - Shimmer Effect
// Simple shimmering placeholder used to create polished skeleton screens.
// Usage: AnyView().shimmer()
struct Shimmer: ViewModifier {
    @State private var phase: CGFloat = -1
    var baseColor: Color = Color.white.opacity(0.3)
    var highlightColor: Color = Color.white
    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geo in
                    Rectangle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [baseColor.opacity(0), highlightColor.opacity(0.6), baseColor.opacity(0)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .rotationEffect(.degrees(25))
                        .frame(width: geo.size.width * 1.5, height: geo.size.height * 2)
                        .offset(x: geo.size.width * phase)
                }
                .mask(content)
            )
            .onAppear {
                withAnimation(.linear(duration: 1.4).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
    }
}

extension View {
    /// Apply shimmering loading placeholder.
    func shimmer() -> some View {
        self.modifier(Shimmer())
    }
}