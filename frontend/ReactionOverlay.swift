import SwiftUI

struct ReactionOverlay: View {
    let reaction: String
    @State private var animate = false
    let animationDuration = 2.0

    var body: some View {
        Text(reaction)
            .font(.system(size: 40))
            .scaleEffect(animate ? 1.8 : 0.8)
            .opacity(animate ? 0 : 1)
            .onAppear {
                withAnimation(.easeOut(duration: animationDuration)) {
                    animate = true
                }
            }
    }
}

struct ReactionOverlay_Previews: PreviewProvider {
    static var previews: some View {
        ReactionOverlay(reaction: "🔥")
    }
}