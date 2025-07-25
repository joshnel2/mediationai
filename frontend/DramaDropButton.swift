import SwiftUI

struct DramaDropButton: View {
    let keyword: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "sparkles")
                    .font(.title)
                    .foregroundColor(.white)
                Text("Today's Drama Drop: \(keyword)")
                    .font(AppTheme.headline())
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(AppTheme.accentGradient)
            .cornerRadius(18)
            .neonGlow(color: AppTheme.accent)
        }
    }
}

struct DramaDropButton_Previews: PreviewProvider {
    static var previews: some View {
        DramaDropButton(keyword: "MrBeast giveaway") {}
    }
}