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

    // Swipeable view selection: 0 = A, 1 = B, 2 = AI Resolution
    @State private var selectedTab = 0

    // Live summary of the debate
    @State private var argumentSummary: String = "No summary yet"
    @State private var activeReactions: [String] = []

    @EnvironmentObject var authService: MockAuthService

    // Determine if the current signed-in user is a participant in this crash-out.
    private var isParticipant: Bool {
        guard let myID = authService.currentUser?.id.uuidString else { return false }
        // A user is considered a participant if this dispute appears in their personal dispute list
        return social.disputesByUser[myID]?.contains(where: { $0.id == dispute.id }) ?? false
    }

    private var meIsA: Bool { Bool.random() } // placeholder

    // Attempt to infer participant names from the title formatted like "Alice vs Bob"
    private var sideAName: String {
        dispute.title.components(separatedBy: " vs ").first ?? "Side A"
    }
    private var sideBName: String {
        dispute.title.components(separatedBy: " vs ").last ?? "Side B"
    }

    var body: some View {
        ZStack{
            // Flying reactions
            ForEach(activeReactions.indices, id: \.self){ idx in
                ReactionOverlay(reaction: activeReactions[idx])
            }
        VStack {
            // Topic title & scoreboard + live summary
            VStack(spacing:8){
                Text(dispute.title)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                    .frame(maxWidth:.infinity)

                if !argumentSummary.isEmpty {
                    Text(argumentSummary)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.horizontal,8).padding(.vertical,4)
                        .background(Color.white.opacity(0.15))
                        .clipShape(Capsule())
                }

                HStack(alignment:.center){
                    VStack(spacing:2){
                        Text("🔥 \(votesA)")
                            .font(.title3.bold())
                            .foregroundColor(AppTheme.primary)
                        Text(sideAName)
                            .font(.caption2)
                            .lineLimit(1)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    VStack(spacing:2){
                        Text("🔥 \(votesB)")
                            .font(.title3.bold())
                            .foregroundColor(AppTheme.accent)
                        Text(sideBName)
                            .font(.caption2)
                            .lineLimit(1)
                            .foregroundColor(.secondary)
                    }
                }

                // Progress bar with glow
                GeometryReader { geo in
                    ZStack(alignment:.leading){
                        RoundedRectangle(cornerRadius:4)
                            .fill(Color.white.opacity(0.15))
                        let total = max(1, votesA + votesB)
                        let percentA = CGFloat(votesA) / CGFloat(total)
                        RoundedRectangle(cornerRadius:4)
                            .fill(AppTheme.primary)
                            .frame(width: geo.size.width * percentA)
                            .shadow(color: AppTheme.primary.opacity(0.6), radius:6)
                    }
                }
                .frame(height:8)

                // Tab chooser
                HStack(spacing:0){
                    tabLabel(title:sideAName, index:0, color:AppTheme.primary)
                    tabLabel(title:sideBName, index:1, color:AppTheme.accent)
                    tabLabel(title:"Result", index:2, color:Color.yellow)
                }
            }
            .padding(8)
            .background(AppTheme.cardGradient)
            .cornerRadius(16)
            .padding(.top,8)

            // Swipeable pages
            TabView(selection:$selectedTab){
                chatPage(for:.a)
                    .tag(0)
                chatPage(for:.b)
                    .tag(1)
                resolutionPage
                    .tag(2)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode:.never))

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
                VStack(spacing:12){
                    // Watch toggle
                    Button(action:{ social.toggleWatch(disputeID: dispute.id) }){
                        HStack(spacing:4){
                            Image(systemName: social.watchedDisputeIDs.contains(dispute.id) ? "bell.fill" : "bell")
                            Text( social.watchedDisputeIDs.contains(dispute.id) ? "Following" : "Follow" )
                        }
                        .font(.caption2.weight(.semibold))
                        .padding(.horizontal,12).padding(.vertical,6)
                        .background(Color.white.opacity(0.15))
                        .foregroundColor(.white)
                        .cornerRadius(14)
                    }

                    // Reaction bar
                    HStack(spacing:24){
                        reactionButton("🔥")
                        reactionButton("😂")
                        reactionButton("👍")
                    }
                }
                .padding(.vertical, 12)
            }
        }
        // End of ZStack content
        }
        .navigationTitle(dispute.title)
        .onAppear{ seed(); updateSummary() }
    }

    // MARK: - Live Summary Helper
    private func updateSummary(){
        let plain = messages.map { $0.text }
        SummarizationService.generateSummary(for: plain) { sum in
            DispatchQueue.main.async { argumentSummary = sum }
        }
    }

    // Reaction helper
    private func reactionButton(_ emoji:String)->some View{
        Text(emoji).font(.title)
            .onTapGesture {
                activeReactions.append(emoji)
                // remove after animation duration
                DispatchQueue.main.asyncAfter(deadline: .now()+2.4){ activeReactions.removeFirst() }
            }
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
                                AsyncImage(url: social.avatarURL(id:u.id, size:60)) { phase in
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
        // Moderation check
        guard ModerationService.isClean(input) else { input = ""; return }

        messages.append(ChatMsg(text: input, sender: sender))
        if sender == .a { votesA += 1 } else { votesB += 1 }
        voted = true
        input = ""
        aiRespond()
        updateSummary()
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

    // Pages
    private func chatPage(for side:ChatMsg.Sender) -> some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing:12){
                    ForEach(messages.filter{ $0.sender == side || $0.sender == .ai }){ msg in bubble(for: msg) }
                }
                .padding()
            }
            .onChange(of: messages.count){ _ in withAnimation{ proxy.scrollTo(messages.last?.id,anchor:.bottom)} }
        }
    }

    private var resolutionPage: some View {
        ScrollView{
            VStack(alignment:.leading,spacing:20){
                Text("AI Resolution")
                    .font(.headline)
                Text(resolutionText)

                Button(action:{ showShare = true }){
                    Label("Share Result", systemImage: "square.and.arrow.up")
                        .font(.subheadline.bold())
                        .frame(maxWidth:.infinity)
                        .padding()
                        .background(AppTheme.accent)
                        .foregroundColor(.white)
                        .cornerRadius(16)
                }
            }
            .padding()
        }
        .sheet(isPresented: $showShare){
            ActivityViewController(activityItems: [shareMessage])
        }
    }

    @State private var showShare = false

    private var shareMessage: String {
        "Crashout debate: \(sideAName) vs \(sideBName) — Verdict: \(resolutionText) #Crashout"
    }

    private var resolutionText: String {
        if votesA == votesB {
            return "After weighing the evidence, the debate is currently tied. Both sides presented compelling but inconclusive arguments. I recommend additional data or a deciding round."
        }
        let winner = votesA > votesB ? "Side A" : "Side B"
        return "Considering the presented facts, logical coherence, and audience votes, **\(winner)** made the stronger case. Key determining factors included statistical backing, situational awareness, and adaptability under pressure."
    }

    // Tab label helper
    private func tabLabel(title:String,index:Int,color:Color)->some View{
        Text(title)
            .font(.subheadline.weight(.semibold))
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            .foregroundColor(selectedTab==index ? Color.white : Color.white.opacity(0.6))
            .padding(.vertical,6)
            .frame(maxWidth:.infinity)
            .background(
                ZStack{
                    if selectedTab==index {
                        RoundedRectangle(cornerRadius:12).fill(color.opacity(0.8)).shadow(radius:4)
                    }
                }
            )
            .onTapGesture { withAnimation(.easeInOut){ selectedTab = index } }
    }

    // old shouldShow no longer needed

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