import SwiftUI

struct Tournament: Identifiable {
    let id = UUID()
    let name: String
    let topic: String
    let prize: String
    var joined: Bool = false
}

struct TournamentView: View {
    @State private var tournaments: [Tournament] = [
        Tournament(name: "Weekend War", topic: "Gaming", prize: "$100 Gift Card"),
        Tournament(name: "Startup Showdown", topic: "Tech", prize: "Mentor Call"),
        Tournament(name: "Kitchen Clash", topic: "Food", prize: "Chef Masterclass")
    ]
    var body: some View {
        NavigationView {
            List {
                ForEach($tournaments) { $tour in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(tour.name).font(.headline)
                            Spacer()
                            Text(tour.prize).font(.caption).foregroundColor(AppTheme.success)
                        }
                        Text("Topic: \(tour.topic)").font(.subheadline).foregroundColor(.secondary)
                        Button(action: { tour.joined.toggle() }) {
                            Text(tour.joined ? "Joined" : "Join Crashout Tournament")
                                .font(.subheadline.weight(.semibold))
                                .frame(maxWidth: .infinity)
                                .padding(8)
                                .background(tour.joined ? AppTheme.success : AppTheme.primary)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Tournaments")
        }
    }
}

struct TournamentView_Previews: PreviewProvider {
    static var previews: some View {
        TournamentView()
    }
}