import SwiftUI

struct CrashoutRequestView: View {
    let targetID: String
    @EnvironmentObject var social: SocialAPIService
    @EnvironmentObject var authService: MockAuthService
    @Environment(\.dismiss) var dismiss

    @State private var title: String = ""
    @State private var myStatement: String = ""
    @State private var sent = false

    // Quick presets to speed up topic selection (mirrors CreateDisputeView)
    private let presetTitles = [
        "Who Carried The Squad?",
        "Lag Blame Showdown",
        "Clip Ownership Drama",
        "Ping Advantage Debate"
    ]

    private var targetName: String {
        social.overallLeaders.first(where: { $0.id == targetID })?.displayName ?? "Streamer"
    }

    var body: some View {
        ZStack {
            AppTheme.backgroundGradient.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header – consistent with CreateDisputeView
                headerSection

                ScrollView {
                    VStack(spacing: AppTheme.spacingXL) {
                        // Title
                        VStack(spacing: AppTheme.spacingSM) {
                            Text("Request Crashout")
                                .font(AppTheme.title())
                                .foregroundColor(AppTheme.textPrimary)
                                .fontWeight(.bold)

                            Text("Challenge \(targetName) to a fiery debate – pick a topic and share your opening statement.")
                                .font(AppTheme.body())
                                .foregroundColor(AppTheme.textSecondary)
                                .multilineTextAlignment(.center)
                        }

                        // Preset quick chips
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(presetTitles, id: \.self) { preset in
                                    Text(preset)
                                        .font(.caption2)
                                        .padding(.vertical, 6)
                                        .padding(.horizontal, 12)
                                        .background(AppTheme.cardGradient)
                                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppTheme.accent, lineWidth: 1))
                                        .cornerRadius(16)
                                        .onTapGesture {
                                            title = preset
                                        }
                                }
                            }
                            .padding(.horizontal, AppTheme.spacingSM)
                        }

                        // Form Fields
                        VStack(alignment: .leading, spacing: AppTheme.spacingMD) {
                            Text("Topic")
                                .font(AppTheme.caption())
                                .foregroundColor(AppTheme.textSecondary)

                            TextField("Crashout topic (e.g. Who carried the match?)", text: $title)
                                .modernTextField()

                            Text("Your Opening Statement")
                                .font(AppTheme.caption())
                                .foregroundColor(AppTheme.textSecondary)

                            TextField("Share your first punchline…", text: $myStatement, axis: .vertical)
                                .modernTextField()
                                .frame(minHeight: 100)
                        }

                        // Send button
                        Button(action: send) {
                            Label(sent ? "Request Sent!" : "Send Crashout Request", systemImage: sent ? "checkmark.circle.fill" : "paperplane.fill")
                        }
                        .accentButton()
                        .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty || myStatement.trimmingCharacters(in: .whitespaces).isEmpty || sent)
                        .opacity(sent ? 0.7 : 1)
                    }
                    .padding(.horizontal, AppTheme.spacingLG)
                    .padding(.top, AppTheme.spacingLG)
                    .padding(.bottom, AppTheme.spacingXL)
                }
            }
        }
    }

    // MARK: - Header
    private var headerSection: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "xmark")
                    .font(.title3)
                    .foregroundColor(AppTheme.textPrimary)
                    .frame(width: 32, height: 32)
                    .background(AppTheme.glassPrimary)
                    .cornerRadius(AppTheme.radiusSM)
            }

            Spacer()

            Text("Request Crashout")
                .font(AppTheme.title3())
                .foregroundColor(AppTheme.textPrimary)
                .fontWeight(.semibold)

            Spacer()

            // Placeholder to balance layout
            Color.clear.frame(width: 32, height: 32)
        }
        .padding(.horizontal, AppTheme.spacingLG)
        .padding(.top, AppTheme.spacingSM)
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
#endif