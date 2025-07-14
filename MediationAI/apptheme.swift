//
//  AppTheme.swift
//  MediationAI
//
//  Created by Linda Alster on 7/14/25.
//

import SwiftUI

struct AppTheme {
    // MARK: - Colors (Twitter/Grok Professional Theme)
    
    // Primary brand colors - Professional blue like Twitter/Grok
    static let primary = Color(red: 0.11, green: 0.63, blue: 0.95) // Twitter Blue #1DA1F2
    static let secondary = Color(red: 0.05, green: 0.46, blue: 0.86) // Darker blue
    static let accent = Color(red: 0.20, green: 0.70, blue: 1.0) // Bright blue accent
    
    // Background colors - True blacks and whites
    static let background = Color(red: 0.0, green: 0.0, blue: 0.0) // Pure black
    static let surfaceBackground = Color(red: 0.05, green: 0.05, blue: 0.05) // Very dark gray
    static let cardBackground = Color(red: 0.08, green: 0.08, blue: 0.08) // Dark card background
    
    // Glass-morphism backgrounds
    static let glassPrimary = Color.white.opacity(0.08)
    static let glassSecondary = Color.white.opacity(0.04)
    
    // Text colors
    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.75)
    static let textTertiary = Color.white.opacity(0.55)
    
    // Status colors - Professional and minimal
    static let success = Color(red: 0.0, green: 0.78, blue: 0.0) // Clean green
    static let warning = Color(red: 0.95, green: 0.95, blue: 0.95) // White for warnings
    static let error = Color(red: 0.95, green: 0.24, blue: 0.24) // Clean red
    static let info = Color(red: 0.11, green: 0.63, blue: 0.95) // Same as primary blue
    
    // MARK: - Gradients
    
    static let mainGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 0.11, green: 0.63, blue: 0.95), // Twitter Blue
            Color(red: 0.05, green: 0.46, blue: 0.86)  // Darker Blue
        ]),
        startPoint: .leading,
        endPoint: .trailing
    )
    
    static let backgroundGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color.black,
            Color(red: 0.02, green: 0.02, blue: 0.02),
            Color.black
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let cardGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color.white.opacity(0.08),
            Color.white.opacity(0.04)
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let successGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 0.0, green: 0.78, blue: 0.0),
            Color(red: 0.0, green: 0.65, blue: 0.0)
        ]),
        startPoint: .leading,
        endPoint: .trailing
    )
    
    static let warningGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color.white,
            Color.white.opacity(0.9)
        ]),
        startPoint: .leading,
        endPoint: .trailing
    )
    
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
            .padding(.vertical, AppTheme.spacingMD)
            .background(AppTheme.mainGradient)
            .cornerRadius(AppTheme.radiusLG)
            .shadow(color: AppTheme.primary.opacity(0.3), radius: 8, x: 0, y: 4)
    }
    
    func secondaryButton() -> some View {
        self
            .font(AppTheme.headline())
            .foregroundColor(AppTheme.textPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppTheme.spacingMD)
            .background(AppTheme.cardGradient)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.radiusLG)
                    .stroke(Color.white.opacity(0.15), lineWidth: 1)
            )
            .cornerRadius(AppTheme.radiusLG)
    }
    
    func modernTextField() -> some View {
        self
            .font(AppTheme.body())
            .foregroundColor(AppTheme.textPrimary)
            .padding(.vertical, AppTheme.spacingMD)
            .padding(.horizontal, AppTheme.spacingLG)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.radiusLG)
                    .fill(AppTheme.glassPrimary)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.radiusLG)
                            .stroke(Color.white.opacity(0.15), lineWidth: 1)
                    )
            )
    }
}
