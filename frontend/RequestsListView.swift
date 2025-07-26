import SwiftUI

struct RequestsListView: View {
    enum Mode { case incoming, outgoing }
    @EnvironmentObject var socialService: SocialAPIService
    @EnvironmentObject var authService: MockAuthService
    let mode: Mode

    private var requests: [Request] {
        let uid = authService.currentUser?.id.uuidString ?? ""
        switch mode {
        case .incoming: return socialService.requestsIn[uid] ?? []
        case .outgoing: return socialService.requestsOut[uid] ?? []
        }
    }

    var body: some View {
        List {
            ForEach(requests) { req in
                VStack(alignment:.leading, spacing:4){
                    Text(req.dispute.title).bold()
                    Text("From: \(req.fromUser) → To: \(req.toUser)").font(.caption)
                }
                .swipeActions(edge: .trailing) {
                    if mode == .incoming {
                        Button {
                            accept(req)
                        } label: { Text("Accept") }
                        .tint(.green)
                        Button(role:.destructive) { reject(req) } label: { Text("Reject") }
                    } else {
                        Button(role:.destructive) { cancel(req) } label: { Text("Cancel") }
                    }
                }
            }
        }
        .navigationTitle(mode == .incoming ? "Incoming" : "Outgoing")
    }

    private func accept(_ req: Request){
        let uid = authService.currentUser?.id.uuidString ?? ""
        socialService.requestsIn[uid]?.removeAll(where: { $0.id == req.id })
        // add dispute to both users
        socialService.disputesByUser[req.fromUser, default: []].append(req.dispute)
        socialService.disputesByUser[req.toUser, default: []].append(req.dispute)
    }
    private func reject(_ req: Request){
        let uid = authService.currentUser?.id.uuidString ?? ""
        socialService.requestsIn[uid]?.removeAll(where: { $0.id == req.id })
    }
    private func cancel(_ req: Request){
        let uid = authService.currentUser?.id.uuidString ?? ""
        socialService.requestsOut[uid]?.removeAll(where: { $0.id == req.id })
    }
}