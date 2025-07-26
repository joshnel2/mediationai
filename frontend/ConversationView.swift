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
    @State private var showBothSides = false

    @State private var showSideA = true
    @State private var showSideB = false

    @EnvironmentObject var authService: MockAuthService

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
        }
        .navigationTitle(dispute.title)
        .onAppear{ seed() }
    }

    private func seed(){
        messages = [
            ChatMsg(text: dispute.statementA, sender:.a),
            ChatMsg(text: "AI: That’s an interesting perspective. Could you elaborate?", sender:.ai),
            ChatMsg(text: dispute.statementB, sender:.b),
            ChatMsg(text: "AI: I see contrasting viewpoints. Let’s explore common ground.", sender:.ai)
        ]
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
        let sender: Sender = meIsA ? .a : .b
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
            Text(title)
                .font(.caption2)
                .padding(.horizontal,10).padding(.vertical,6)
                .background(isOn ? color : Color.white.opacity(0.2))
                .foregroundColor(.white)
                .cornerRadius(12)
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