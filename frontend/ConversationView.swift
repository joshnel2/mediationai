import SwiftUI
#if canImport(ConfettiSwiftUI)
import ConfettiSwiftUI
#endif

struct ConversationView: View {
    @EnvironmentObject var social: SocialAPIService
    let dispute: MockDispute
    @State private var voted = false
    @State private var votedForA = false
    @State private var confetti = 0

    var body: some View {
        VStack {
            #if canImport(ConfettiSwiftUI)
            ConfettiCannon(counter: $confetti, emojis: ["🔥","🎉"], confettiSize: 20, repetitions: 1)
            #endif
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Bubble(text: dispute.statementA, isMe: true)
                    Bubble(text: "🤖 AI: Interesting point!", isAI: true)
                    Bubble(text: dispute.statementB, isMe: false)
                }
                .padding()
            }
            if !voted {
                HStack {
                    GradientPill(title: "Vote A", gradient: [AppTheme.primary, .purple]) { cast(true) }
                    GradientPill(title: "Vote B", gradient: [AppTheme.accent, .pink]) { cast(false) }
                }
                .padding()
            } else {
                Text("Current score \(dispute.votesA) - \(dispute.votesB)")
                    .padding()
            }
        }
        .navigationTitle(dispute.title)
        .background(AppTheme.backgroundGradient.ignoresSafeArea())
    }

    private func cast(_ forA: Bool) {
        social.recordVote(disputeID: dispute.id, voteForA: forA)
        votedForA = forA
        voted = true
        confetti += 1
        #if canImport(UIKit)
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        #endif
    }

    private struct Bubble: View {
        let text: String
        var isMe: Bool = false
        var isAI: Bool = false
        var body: some View {
            HStack {
                if isMe { Spacer() }
                Text(text)
                    .padding()
                    .background(isAI ? Color.yellow.opacity(0.3) : (isMe ? AppTheme.primary : AppTheme.accent))
                    .foregroundColor(.white)
                    .cornerRadius(16)
                if !isMe { Spacer() }
            }
        }
    }

    private struct GradientPill: View {
        let title: String
        let gradient: [Color]
        let action: ()->Void
        var body: some View {
            Button(action: action){
                Text(title).bold().frame(maxWidth: .infinity).padding()
            }
            .background(LinearGradient(colors: gradient, startPoint: .leading, endPoint: .trailing))
            .foregroundColor(.white)
            .cornerRadius(28)
        }
    }
}

struct ConversationView_Previews: PreviewProvider {
    static var previews: some View {
        ConversationView(dispute: MockDispute(id: "1", title: "Debate", statementA: "A", statementB: "B", votesA: 3, votesB: 4))
            .environmentObject(SocialAPIService())
    }
}