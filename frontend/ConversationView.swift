import SwiftUI

struct ConversationView: View {
    @EnvironmentObject var social: SocialAPIService
    let dispute: MockDispute
    @State private var voted = false
    @State private var votedForA = false

    var body: some View {
        VStack {
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
                    Button("Vote A") { cast(true) }
                        .primaryButton()
                    Button("Vote B") { cast(false) }
                        .accentButton()
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
}

struct ConversationView_Previews: PreviewProvider {
    static var previews: some View {
        ConversationView(dispute: MockDispute(id: "1", title: "Debate", statementA: "A", statementB: "B", votesA: 3, votesB: 4))
            .environmentObject(SocialAPIService())
    }
}