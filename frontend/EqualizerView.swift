import SwiftUI

struct EqualizerView: View {
    @State private var barHeights: [CGFloat] = (0..<5).map { _ in .random(in: 10...60) }
    let color: Color
    var body: some View {
        HStack(spacing: 4) {
            ForEach(barHeights.indices, id: \.self) { idx in
                RoundedRectangle(cornerRadius: 2)
                    .fill(color)
                    .frame(width: 4, height: barHeights[idx])
            }
        }
        .onAppear(perform: animate)
    }
    private func animate() {
        withAnimation(.easeInOut(duration: 0.4).repeatForever()) {
            barHeights = barHeights.map { _ in .random(in: 10...60) }
        }
    }
}