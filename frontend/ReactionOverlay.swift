import SwiftUI

struct ReactionOverlay: View {
    let reaction: String
    @State private var fly = false
    let animationDuration = 2.4

    var body: some View {
        Text(reaction)
            .font(.system(size: 44))
            .shadow(color: .white.opacity(0.8), radius: 4)
            .scaleEffect(fly ? 2.0 : 0.6)
            .rotationEffect(.degrees(fly ? Double.random(in:-20...20) : 0))
            .offset(y: fly ? -200 : 0)
            .opacity(fly ? 0 : 1)
            .onAppear {
                withAnimation(.easeOut(duration: animationDuration)) { fly = true }
            }
    }
}

struct ReactionOverlay_Previews: PreviewProvider {
    static var previews: some View {
        ReactionOverlay(reaction: "🔥")
    }
}