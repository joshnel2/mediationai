import SwiftUI

struct RankBadgeView: View {
    let rank: String
    var body: some View {
        Text(rank.prefix(1))
            .font(.caption.bold())
            .foregroundColor(.white)
            .frame(width: 24, height: 24)
            .background(gradient)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.white.opacity(0.4), lineWidth: 1))
    }
    private var gradient: LinearGradient {
        switch rank {
        case "Rage-Lord":
            return LinearGradient(colors: [Color.red, Color.orange], startPoint: .top, endPoint: .bottom)
        case "Chatter":
            return LinearGradient(colors: [AppTheme.secondary, AppTheme.accent], startPoint: .top, endPoint: .bottom)
        default:
            return LinearGradient(colors: [Color.gray, Color.gray.opacity(0.7)], startPoint: .top, endPoint: .bottom)
        }
    }
}