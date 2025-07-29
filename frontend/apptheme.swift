//
//  AppTheme.swift
//  MediationAI
//
//  Created by Linda Alster on 7/14/25.
//

import SwiftUI

struct AppTheme {
    // MARK: - Colors (Neon Streamer Theme)
    // Electric neon palette aimed at streaming culture (Twitch / Kick vibe)
    // Trendy Twitch + Twitter inspired palette
    // Primary & secondary now use blue tones (Twitter branding)
    static let primary = Color(red: 0.11, green: 0.63, blue: 0.95) // Twitter Blue #1DA1F2
    static let secondary = Color(red: 0.37, green: 0.75, blue: 0.97) // Lighter Twitter Blue
    // Accent now matches Twitter Blue instead of pink
    static let accent = Color(red: 0.11, green: 0.63, blue: 0.95) // Twitter Blue #1DA1F2
    
    // Background colors - Deep sophisticated gradients
    static let background = Color(red: 0.05, green: 0.05, blue: 0.08) // Near-black
    static let surfaceBackground = Color(red: 0.08, green: 0.08, blue: 0.12)
    static let cardBackground = Color(red: 0.12, green: 0.12, blue: 0.18)
    
    // Glass-morphism backgrounds with subtle color tints
    static let glassPrimary = Color.white.opacity(0.12)
    static let glassSecondary = Color.white.opacity(0.06)
    static let glassAccent = Color(red: 0.11, green: 0.63, blue: 0.95).opacity(0.08)
    
    // Text colors - High contrast for readability
    static let textPrimary = Color.black
    static let textSecondary = Color.black.opacity(0.85)
    static let textTertiary = Color.black.opacity(0.60)
    
    // Status colors - Modern and vibrant
    static let success = Color(red: 0.0, green: 0.85, blue: 0.40) // Vibrant green #00D966
    static let warning = Color(red: 1.0, green: 0.70, blue: 0.0) // Warm orange #FFB300
    static let error = Color(red: 1.0, green: 0.25, blue: 0.25) // Bright red #FF4040
    static let info = Color(red: 0.0, green: 0.75, blue: 1.0) // Bright blue #00BFFF
    
    // MARK: - Gradients (Enhanced for Wow Factor)
    
    static let mainGradient = LinearGradient(
        gradient: Gradient(colors: [
            primary,
            secondary
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let backgroundGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 0.94, green: 0.95, blue: 1.00),   // Soft off-white
            Color(red: 0.90, green: 0.92, blue: 1.00),   // Pastel lavender
            Color(red: 0.96, green: 0.94, blue: 1.00)    // Nearly white
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    // Card backgrounds now have a subtle twitter-blue tint so white text stays readable
    static let cardGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 0.80, green: 0.90, blue: 1.00), // light blue
            Color(red: 0.65, green: 0.82, blue: 1.00)  // slightly darker blue
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let successGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 0.0, green: 0.85, blue: 0.40),
            Color(red: 0.0, green: 0.95, blue: 0.50)
        ]),
        startPoint: .leading,
        endPoint: .trailing
    )
    
    static let warningGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 1.0, green: 0.70, blue: 0.0),
            Color(red: 1.0, green: 0.80, blue: 0.2)
        ]),
        startPoint: .leading,
        endPoint: .trailing
    )
    
    static let accentGradient = LinearGradient(
        gradient: Gradient(colors: [primary, secondary]),
        startPoint: .leading,
        endPoint: .trailing
    )
    
    // MARK: - Neon Glow Effect
    struct Glow: ViewModifier {
        var color: Color = primary
        func body(content: Content) -> some View {
            content
                .shadow(color: color.opacity(0.9), radius: 10)
                .shadow(color: color.opacity(0.7), radius: 20)
        }
    }
    
    // MARK: - Typography
    
    static func largeTitle() -> Font {
        .system(size: 34, weight: .bold, design: .default)
    }
    
    static func title() -> Font {
        .system(size: 28, weight: .bold, design: .default)
    }
    
    static func title2() -> Font {
        .system(size: 22, weight: .semibold, design: .default)
    }
    
    static func title3() -> Font {
        .system(size: 20, weight: .semibold, design: .default)
    }
    
    static func headline() -> Font {
        .system(size: 17, weight: .semibold, design: .default)
    }
    
    static func body() -> Font {
        .system(size: 17, weight: .regular, design: .default)
    }
    
    static func bodyMedium() -> Font {
        .system(size: 17, weight: .medium, design: .default)
    }
    
    static func callout() -> Font {
        .system(size: 16, weight: .regular, design: .default)
    }
    
    static func subheadline() -> Font {
        .system(size: 15, weight: .medium, design: .default)
    }
    
    static func footnote() -> Font {
        .system(size: 13, weight: .regular, design: .default)
    }
    
    static func caption() -> Font {
        .system(size: 12, weight: .medium, design: .default)
    }
    
    static func caption2() -> Font {
        .system(size: 11, weight: .regular, design: .default)
    }
    
    // MARK: - Legacy support (keeping for backward compatibility)
    
    static let card = cardBackground
    
    static func titleFont() -> Font { title() }
    static func subtitleFont() -> Font { title2() }
    static func bodyFont() -> Font { body() }
    static func buttonFont() -> Font { headline() }
    static func chatFont() -> Font { body() }
    
    // MARK: - Spacing
    
    static let spacingXS: CGFloat = 4
    static let spacingSM: CGFloat = 8
    static let spacingMD: CGFloat = 16
    static let spacingLG: CGFloat = 24
    static let spacingXL: CGFloat = 32
    static let spacingXXL: CGFloat = 48
    
    // MARK: - Uniform Card Height (for consistent box sizes)
    
    /// Minimum height applied to informational cards so they render at the same visual size even when content length varies.
    static let uniformCardHeight: CGFloat = 300
    
    // MARK: - Corner Radius
    
    static let radiusXS: CGFloat = 6
    static let radiusSM: CGFloat = 8
    static let radiusMD: CGFloat = 12
    static let radiusLG: CGFloat = 16
    static let radiusXL: CGFloat = 20
    static let radiusXXL: CGFloat = 24
    
    // MARK: - Shadows
    
    static let shadowSM = Color.black.opacity(0.2)
    static let shadowMD = Color.black.opacity(0.3)
    static let shadowLG = Color.black.opacity(0.4)
    static let shadowXL = Color.black.opacity(0.5)
    
    // MARK: - Glass Card Modifier
    
    static func glassCard(radius: CGFloat = radiusLG) -> some ViewModifier {
        GlassCardModifier(cornerRadius: radius)
    }
}

struct GlassCardModifier: ViewModifier {
    let cornerRadius: CGFloat
    
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(AppTheme.cardGradient)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(Color.white.opacity(0.08), lineWidth: 1)
                    )
            )
            .shadow(color: AppTheme.shadowMD, radius: 8, x: 0, y: 4)
    }
}

// MARK: - View Extensions

extension View {
    func glassCard(radius: CGFloat = AppTheme.radiusLG) -> some View {
        modifier(GlassCardModifier(cornerRadius: radius))
    }
    
    func primaryButton() -> some View {
        self
            .font(AppTheme.headline())
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppTheme.spacingLG)
            .background(AppTheme.mainGradient)
            .cornerRadius(AppTheme.radiusLG)
            .shadow(color: AppTheme.primary.opacity(0.4), radius: 12, x: 0, y: 6)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.radiusLG)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
    }
    
    func secondaryButton() -> some View {
        self
            .font(AppTheme.headline())
            .foregroundColor(AppTheme.textPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppTheme.spacingLG)
            .background(AppTheme.cardGradient)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.radiusLG)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
            .cornerRadius(AppTheme.radiusLG)
            .shadow(color: AppTheme.shadowMD, radius: 6, x: 0, y: 3)
    }
    
    func accentButton() -> some View {
        self
            .font(AppTheme.headline())
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppTheme.spacingLG)
            .background(AppTheme.accentGradient)
            .cornerRadius(AppTheme.radiusLG)
            .shadow(color: AppTheme.accent.opacity(0.4), radius: 12, x: 0, y: 6)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.radiusLG)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
    }
    
    func modernTextField() -> some View {
        self
            .font(AppTheme.body())
            .foregroundColor(AppTheme.textPrimary)
            .padding(.vertical, AppTheme.spacingLG)
            .padding(.horizontal, AppTheme.spacingLG)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.radiusLG)
                    .fill(AppTheme.glassPrimary)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.radiusLG)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
            .shadow(color: AppTheme.shadowSM, radius: 4, x: 0, y: 2)
    }
    
    func heroCard() -> some View {
        self
            .padding(AppTheme.spacingXL)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.radiusXL)
                    .fill(AppTheme.cardGradient)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.radiusXL)
                            .stroke(Color.white.opacity(0.15), lineWidth: 1)
                    )
            )
            .shadow(color: AppTheme.shadowLG, radius: 16, x: 0, y: 8)
    }
    
    func pulseEffect() -> some View {
        self
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.radiusLG)
                    .stroke(AppTheme.accent.opacity(0.3), lineWidth: 2)
                    .scaleEffect(1.1)
                    .opacity(0.7)
                    .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: UUID())
            )
    }
    
    func modernCard() -> some View {
        self
            .padding(AppTheme.spacingLG)
            .background(AppTheme.cardGradient)
            .cornerRadius(AppTheme.radiusLG)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.radiusLG)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
            .shadow(color: AppTheme.shadowMD, radius: 8, x: 0, y: 4)
    }
    
    func twitterStyle() -> some View {
        self
            .padding(AppTheme.spacingLG)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.radiusXL)
                    .fill(AppTheme.glassPrimary)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.radiusXL)
                            .stroke(Color.white.opacity(0.08), lineWidth: 1)
                    )
            )
            .shadow(color: AppTheme.shadowSM, radius: 4, x: 0, y: 2)
    }

    func neonGlow(color: Color = AppTheme.primary) -> some View {
        modifier(AppTheme.Glow(color: color))
    }
}
