import SwiftUI

struct AppIcon: View {
    var size: CGFloat = 60
    
    var body: some View {
        ZStack {
            // Background circle with gradient
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.2, green: 0.4, blue: 0.8),
                            Color(red: 0.1, green: 0.3, blue: 0.7)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size, height: size)
                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
            
            // Scales of justice symbol
            VStack(spacing: 2) {
                // Balance beam
                Rectangle()
                    .fill(Color.white)
                    .frame(width: size * 0.5, height: size * 0.04)
                
                // Center post
                Rectangle()
                    .fill(Color.white)
                    .frame(width: size * 0.04, height: size * 0.3)
                
                // Base
                Rectangle()
                    .fill(Color.white)
                    .frame(width: size * 0.3, height: size * 0.04)
            }
            
            // Left scale
            HStack {
                VStack {
                    // Chain
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: 1, height: size * 0.1)
                    
                    // Scale pan
                    Ellipse()
                        .stroke(Color.white, lineWidth: 1.5)
                        .frame(width: size * 0.15, height: size * 0.08)
                }
                .offset(x: -size * 0.2, y: -size * 0.05)
                
                Spacer()
                
                // Right scale
                VStack {
                    // Chain
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: 1, height: size * 0.1)
                    
                    // Scale pan
                    Ellipse()
                        .stroke(Color.white, lineWidth: 1.5)
                        .frame(width: size * 0.15, height: size * 0.08)
                }
                .offset(x: size * 0.2, y: -size * 0.05)
            }
            .frame(width: size * 0.6)
            
            // AI indicator - small circuit pattern
            VStack {
                HStack(spacing: 1) {
                    Circle()
                        .fill(Color.yellow)
                        .frame(width: 2, height: 2)
                    Rectangle()
                        .fill(Color.yellow)
                        .frame(width: 4, height: 0.5)
                    Circle()
                        .fill(Color.yellow)
                        .frame(width: 2, height: 2)
                }
                .opacity(0.8)
            }
            .offset(x: size * 0.15, y: size * 0.2)
        }
    }
}

struct AppIconLarge: View {
    var body: some View {
        AppIcon(size: 1024)
    }
}

#Preview {
    VStack(spacing: 20) {
        AppIcon(size: 60)
        AppIcon(size: 120)
        AppIcon(size: 200)
    }
    .padding()
}