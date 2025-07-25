import SwiftUI

struct VoteView: View {
    @EnvironmentObject var social: SocialAPIService
    let dispute: MockDispute
    @State private var voted: Bool = false
    @State private var pickedA = false

    var body: some View {
        VStack(spacing: 32) {
            Text(dispute.title)
                .font(.title).bold()
                .multilineTextAlignment(.center)
            Spacer()
            VStack(spacing: 20) {
                Button(action: { castVote(forA: true) }) {
                    Label(dispute.statementA, systemImage: "person.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity, minHeight: 80)
                        .background(AppTheme.primary)
                        .foregroundColor(.white)
                        .cornerRadius(20)
                }
                Button(action: { castVote(forA: false) }) {
                    Label(dispute.statementB, systemImage: "person.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity, minHeight: 80)
                        .background(AppTheme.accent)
                        .foregroundColor(.white)
                        .cornerRadius(20)
                }
            }
            .disabled(voted)
            if voted {
                Text("Thanks for voting! Current score \(dispute.votesA) - \(dispute.votesB)")
                    .font(.subheadline)
                    .padding(.top)
            }
            Spacer()
        }
        .padding()
    }

    private func castVote(forA: Bool) {
        guard !voted else { return }
        social.recordVote(disputeID: dispute.id, voteForA: forA)
        pickedA = forA
        voted = true
    }
}

struct VoteView_Previews: PreviewProvider {
    static var previews: some View {
        VoteView(dispute: MockDispute(id: "1", title: "Who Wins?", statementA: "A", statementB: "B", votesA: 5, votesB: 3))
            .environmentObject(SocialAPIService())
    }
}