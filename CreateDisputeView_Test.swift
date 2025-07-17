import SwiftUI

struct CreateDisputeViewTest: View {
    @Environment(\.dismiss) var dismiss
    @State private var title = ""
    @State private var description = ""
    
    var body: some View {
        VStack {
            Text("Create Dispute Test")
            TextField("Title", text: $title)
            TextField("Description", text: $description)
            Button("Dismiss") {
                dismiss()
            }
        }
    }
}

#Preview {
    CreateDisputeViewTest()
}