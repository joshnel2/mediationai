import SwiftUI
import Combine

// MARK: - Bubble Tail Shape
struct BubbleTail: Shape {
    var isMySide: Bool
    func path(in rect: CGRect) -> Path {
        var p = Path()
        if isMySide {
            p.move(to: CGPoint(x: rect.maxX, y: rect.minY+10))
            p.addLine(to: CGPoint(x: rect.maxX+6, y: rect.minY+16))
            p.addLine(to: CGPoint(x: rect.maxX, y: rect.minY+22))
        } else {
            p.move(to: CGPoint(x: rect.minX, y: rect.minY+10))
            p.addLine(to: CGPoint(x: rect.minX-6, y: rect.minY+16))
            p.addLine(to: CGPoint(x: rect.minX, y: rect.minY+22))
        }
        return p
    }
}

struct ConversationView: View {
    @EnvironmentObject var social: SocialAPIService
    let dispute: MockDispute

    // Simple chat model
    struct ChatMsg: Identifiable {
        enum Sender { case a, b, ai }
        let id = UUID()
        let text: String
        let sender: Sender
    }

    @State private var messages: [ChatMsg] = []
    @State private var input: String = ""
    @State private var aiThinking = false
    @State private var voted = false
    @State private var votesA:Int = 0
    @State private var votesB:Int = 0

    @State private var showSideA = true
    @State private var showSideB = false

    @EnvironmentObject var authService: MockAuthService

    // Determine if the current signed-in user is a participant in this crash-out.
    private var isParticipant: Bool {
        guard let myID = authService.currentUser?.id.uuidString else { return false }
        // A user is considered a participant if this dispute appears in their personal dispute list
        return social.disputesByUser[myID]?.contains(where: { $0.id == dispute.id }) ?? false
    }

    private var meIsA: Bool { Bool.random() } // placeholder

    var body: some View {
        VStack {
            // Top controls
            HStack(spacing:16){
                Text("Side A 🔥 \(votesA)")
                Text("Side B 🔥 \(votesB)")
                Spacer()
                if !voted {
                    ToggleChip(title: "A", isOn: $showSideA, color: AppTheme.primary)
                    ToggleChip(title: "B", isOn: $showSideB, color: AppTheme.accent)
                }
            }
            .padding(8)
            .background(AppTheme.cardGradient)
            .cornerRadius(16)
            .padding(.top,8)

            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing:12){
                        ForEach(messages.filter{ shouldShow($0) }){ msg in bubble(for: msg) }
                    }
                    .padding()
                }
                .onChange(of: messages.count){ _ in withAnimation{ proxy.scrollTo(messages.last?.id,anchor:.bottom)} }
            }

            // Modern glass input bar
            // Input section – visible only to participants
            if isParticipant {
                HStack(spacing:8){
                    TextField("Type your point", text:$input)
                        .foregroundColor(.primary)
                    Button(action: send){
                        Image(systemName:"paperplane.fill")
                            .rotationEffect(.degrees(45))
                            .padding(10)
                            .background(AppTheme.primary)
                            .clipShape(Circle())
                            .foregroundColor(.white)
                    }
                    .disabled(input.trimmingCharacters(in:.whitespacesAndNewlines).isEmpty || aiThinking)
                }
                .padding(.vertical,10)
                .padding(.horizontal,16)
                .background(BlurView(style:.systemUltraThinMaterial))
                .clipShape(Capsule())
                .padding(.horizontal)

                if voted {
                    opponentSection
                }
            } else {
                // Viewer message when not a participant
                Text("You are watching this crashout. Only the participants can add messages.")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .padding(.vertical, 12)
            }
        }
        .navigationTitle(dispute.title)
        .onAppear{ seed() }
    }

    private func seed(){
        // Build an extended mock conversation so spectators see depth
        let sideAExtras = [
            "I predicted their rotations every round—check my pings on minimap.",
            "My utility usage forced their duelists to waste cooldowns early.",
            "I won the mental game; their IGL admitted it post-match.",
            "When you look at ADR I’m 30% ahead—impact speaks louder than K/D."
        ].shuffled().prefix(3)

        let sideBExtras = [
            "Your ‘prediction’ was luck; I counter-flanked and caught you twice.",
            "Utility is pointless if you burn it with no follow-up—basic economics.",
            "We adapted mid-game and you went 3-10 afterwards—momentum lost.",
            "ADR ignores entry damage vs finishing—context matters."
        ].shuffled().prefix(3)

        messages = [
            ChatMsg(text: dispute.statementA, sender:.a),
            ChatMsg(text: "AI: Interesting opening. Could you provide concrete evidence?", sender:.ai),
            ChatMsg(text: dispute.statementB, sender:.b),
        ]

        // Interleave extra arguments with AI probing
        for i in 0..<3 {
            messages.append(ChatMsg(text: Array(sideAExtras)[i], sender:.a))
            messages.append(ChatMsg(text: "AI: Noted. Counter-argument?", sender:.ai))
            messages.append(ChatMsg(text: Array(sideBExtras)[i], sender:.b))
            messages.append(ChatMsg(text: "AI: Let’s keep dissecting the core claim.", sender:.ai))
        }

        messages.append(ChatMsg(text: "AI: We’ve surfaced both micro- and macro-level concerns. Shall we move to closing statements?", sender:.ai))
        votesA = dispute.votesA
        votesB = dispute.votesB
    }

    // Opponent suggestions
    private var opponentSection: some View {
        VStack(alignment:.leading,spacing:8){
            Text("Challenge someone on the other side")
                .font(.caption)
            let opponents = social.opponentSuggestions(exclude: authService.currentUser?.id.uuidString ?? "")
            ScrollView(.horizontal,showsIndicators:false){
                HStack(spacing:12){
                    ForEach(opponents){ u in
                        Button(action:{ social.createClashBetween(authService.currentUser?.id.uuidString ?? "", u.id) }){
                            VStack{
                                AsyncImage(url: URL(string: "https://i.pravatar.cc/60?u=\(u.id)")) { phase in
                                    if let img = phase.image {
                                        img.resizable()
                                    } else {
                                        Color.gray
                                    }
                                }
                                    .frame(width:50,height:50).clipShape(Circle())
                                Text(u.displayName).font(.caption2)
                            }
                        }.buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
        .padding(.horizontal)
    }

    private func send(){
        let sender: ChatMsg.Sender = meIsA ? .a : .b
        messages.append(ChatMsg(text: input, sender: sender))
        if sender == .a { votesA += 1 } else { votesB += 1 }
        voted = true
        showSideA = true; showSideB = true
        input = ""
        aiRespond()
    }

    private func aiRespond(){
        aiThinking = true
        DispatchQueue.main.asyncAfter(deadline:.now()+1.0){
            messages.append(ChatMsg(text:"AI: Thanks for sharing. I’d like the other party to clarify their stance on that.", sender:.ai))
            aiThinking = false
        }
    }

    @ViewBuilder
    private func bubble(for msg:ChatMsg)-> some View {
        HStack(alignment:.bottom,spacing:4){
            if msg.sender == .b { Spacer() }
            VStack(alignment: msg.sender == .a ? .trailing : .leading){
                Text(msg.text)
                    .padding(12)
                    .background(bubbleGradient(for: msg))
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius:20))
                    .overlay(BubbleTail(isMySide: msg.sender == .b).fill(bubbleGradient(for: msg)))
            }
            if msg.sender == .a { Spacer() }
        }
        .transition(.move(edge: msg.sender == .a ? .trailing : .leading).combined(with:.opacity))
        .id(msg.id)
    }

    private func bubbleGradient(for msg:ChatMsg)->LinearGradient{
        if msg.sender == .ai { return LinearGradient(colors:[Color.yellow.opacity(0.5),Color.orange.opacity(0.6)],startPoint:.top,endPoint:.bottom) }
        return msg.sender == .a ? AppTheme.accentGradient : LinearGradient(colors:[AppTheme.primary,AppTheme.secondary], startPoint:.topLeading,endPoint:.bottomTrailing)
    }

    // Simple blur view helper
    struct BlurView: UIViewRepresentable {
        var style: UIBlurEffect.Style = .systemThinMaterial
        func makeUIView(context: Context) -> UIVisualEffectView { UIVisualEffectView(effect: UIBlurEffect(style: style)) }
        func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
    }

    private func shouldShow(_ msg:ChatMsg)->Bool {
        if voted { return true }
        switch msg.sender {
        case .ai: return true
        case .a: return showSideA
        case .b: return showSideB
        }
    }

    private struct ToggleChip: View {
        let title: String
        @Binding var isOn: Bool
        let color: Color
        var body: some View {
            HStack(spacing:4){
                Image(systemName: isOn ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(.white)
                    .font(.caption2)
                Text(title)
            }
            .font(.caption2)
            .padding(.horizontal,10).padding(.vertical,6)
            .background(isOn ? color : Color.white.opacity(0.15))
            .overlay(RoundedRectangle(cornerRadius:12).stroke(Color.white.opacity(0.6), lineWidth:1))
            .foregroundColor(.white)
            .cornerRadius(12)
            .opacity(isOn ? 1.0 : 0.7)
            .onTapGesture { withAnimation{ isOn.toggle() } }
        }
    }
}

#if DEBUG
struct ConversationView_Previews: PreviewProvider {
    static var previews: some View {
        ConversationView(dispute: MockDispute(id: "1", title: "Test", statementA: "A", statementB: "B", votesA: 0, votesB: 0))
            .environmentObject(SocialAPIService())
    }
}
#endif