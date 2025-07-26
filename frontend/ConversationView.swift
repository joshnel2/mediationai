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

    private var meIsA: Bool { Bool.random() } // placeholder

    var body: some View {
        VStack {
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
    }

    private func send(){
        let sender: Sender = meIsA ? .a : .b
        messages.append(ChatMsg(text: input, sender: sender))
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