//
//  SplashScreen.swift
//  MediationAI
//
//  Created by Linda Alster on 7/14/25.
//

import SwiftUI

struct SplashScreen: View {
    @State private var showLogo = false
    @State private var logoScale: CGFloat = 0.8
    @State private var logoOpacity: Double = 0.0
    @State private var textOpacity: Double = 0.0
    @State private var badgeScale: CGFloat = 0.8
    @State private var progressOpacity: Double = 0.0
    @Binding var showSplash: Bool
    
    var body: some View {
        ZStack {
            // Dynamic gradient background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.08, green: 0.02, blue: 0.15),
                    Color(red: 0.03, green: 0.03, blue: 0.10)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
 
            VStack {
                Spacer()
                Image(systemName: "bolt.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(AppTheme.accent)
                    .neonGlow(color: AppTheme.accent)
                    .scaleEffect(showLogo ? 1 : 0.5)
                    .opacity(showLogo ? 1 : 0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.7), value: showLogo)
                Text("ClashAI")
                    .font(.system(size: 44, weight: .heavy))
                    .foregroundColor(.white)
                    .neonGlow()
                    .opacity(showLogo ? 1 : 0)
                    .animation(.easeIn.delay(0.1), value: showLogo)
                Spacer()
            }
        }
        .onAppear {
            withAnimation { showLogo = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                withAnimation(.easeOut) {
                    showSplash = false
                }
            }
        }
    }
}

struct SplashScreen_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreen(showSplash: .constant(true))
    }
}