import SwiftUI
import Combine

struct ConversationView: View {
    @EnvironmentObject var social: SocialAPIService
    let dispute: MockDispute

    // Simple chat model
    struct ChatMsg: Identifiable { let id = UUID(); let text: String; let sender: Sender enum Sender { case a,b,ai } }

    @State private var messages: [ChatMsg] = []
    @State private var input: String = ""
    @State private var aiThinking = false
    @State private var voted = false
    @State private var votesA:Int = 0
    @State private var votesB:Int = 0

    @EnvironmentObject var authService: MockAuthService

    private var meIsA: Bool { Bool.random() } // placeholder

    var body: some View {
        VStack {
            // Vote count pill
            HStack(spacing:16){
                Text("Side A 🔥 \(votesA)")
                Text("Side B 🔥 \(votesB)")
            }
            .padding(8)
            .background(AppTheme.cardGradient)
            .cornerRadius(16)
            .padding(.top,8)

            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing:12){
                        ForEach(messages){ msg in bubble(for: msg) }
                    }
                    .padding()
                }
                .onChange(of: messages.count){ _ in withAnimation{ proxy.scrollTo(messages.last?.id,anchor:.bottom)} }
            }

            HStack{
                TextField("Type your point", text:$input)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button("Send"){ send() }
                    .disabled(input.trimmingCharacters(in:.whitespacesAndNewlines).isEmpty || aiThinking)
            }
            .padding()

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
                                AsyncImage(url: URL(string:"https://i.pravatar.cc/60?u=\(u.id)")){ phase in phase.image?.resizable() ?? Color.gray }
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
        HStack{
            if msg.sender == .a { Spacer() }
            Text(msg.text)
                .padding()
                .background(msg.sender==.ai ? Color.yellow.opacity(0.3) : (msg.sender==.a ? AppTheme.primary : AppTheme.accent))
                .foregroundColor(.white)
                .cornerRadius(16)
            if msg.sender == .b || msg.sender == .ai { Spacer() }
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