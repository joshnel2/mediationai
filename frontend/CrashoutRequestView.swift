import SwiftUI

struct CrashoutRequestView: View {
    let targetID: String
    @EnvironmentObject var social: SocialAPIService
    @EnvironmentObject var authService: MockAuthService
    @Environment(\.dismiss) var dismiss

    @State private var title: String = ""
    @State private var myStatement: String = ""
    @State private var sent = false

    private var targetName: String {
        social.overallLeaders.first(where: { $0.id == targetID })?.displayName ?? "Streamer"
    }

    var body: some View {
        VStack(spacing: 24) {
            Text("Challenge \(targetName)")
                .font(.title2.bold())

            TextField("Crashout topic (e.g. Who carried the match?)", text: $title)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            TextEditor(text: $myStatement)
                .frame(height: 120)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.secondary.opacity(0.3)))
                .padding(.horizontal)

            Button(action: send) {
                Text(sent ? "Sent!" : "Send Crashout Request")
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(sent ? Color.green : AppTheme.accent)
                    .foregroundColor(.white)
                    .cornerRadius(14)
            }
            .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty || myStatement.trimmingCharacters(in: .whitespaces).isEmpty || sent)
            Spacer()
        }
        .padding()
        .background(AppTheme.backgroundGradient.ignoresSafeArea())
    }

    private func send() {
        guard let fromID = authService.currentUser?.id.uuidString else { return }
        social.sendCrashoutRequest(from: fromID, to: targetID, title: title, statementA: myStatement)
        sent = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { dismiss() }
    }
}

#if DEBUG
struct CrashoutRequestView_Previews: PreviewProvider {
    static var previews: some View {
        CrashoutRequestView(targetID: "demo")
            .environmentObject(SocialAPIService())
            .environmentObject(MockAuthService())
    }
}