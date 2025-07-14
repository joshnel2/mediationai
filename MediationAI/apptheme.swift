//
//  AppTheme.swift
//  MediationAI
//
//  Created by Linda Alster on 7/14/25.
//

import SwiftUI

struct AppTheme {
    // MARK: - Colors
    
    // Primary brand colors
    static let primary = Color(red: 0.2, green: 0.3, blue: 0.9)
    static let secondary = Color(red: 0.5, green: 0.3, blue: 0.8)
    static let accent = Color(red: 0.0, green: 0.7, blue: 0.9)
    
    // Background colors
    static let background = Color(red: 0.05, green: 0.05, blue: 0.08)
    static let surfaceBackground = Color(red: 0.08, green: 0.08, blue: 0.12)
    static let cardBackground = Color(red: 0.12, green: 0.12, blue: 0.18)
    
    // Glass-morphism backgrounds
    static let glassPrimary = Color.white.opacity(0.1)
    static let glassSecondary = Color.white.opacity(0.05)
    
    // Text colors
    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.8)
    static let textTertiary = Color.white.opacity(0.6)
    
    // Status colors
    static let success = Color(red: 0.2, green: 0.8, blue: 0.4)
    static let warning = Color(red: 1.0, green: 0.7, blue: 0.0)
    static let error = Color(red: 1.0, green: 0.3, blue: 0.3)
    static let info = Color(red: 0.2, green: 0.6, blue: 1.0)
    
    // MARK: - Gradients
    
    static let mainGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 0.2, green: 0.3, blue: 0.9),
            Color(red: 0.5, green: 0.3, blue: 0.8)
        ]),
        startPoint: .leading,
        endPoint: .trailing
    )
    
    static let backgroundGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 0.05, green: 0.05, blue: 0.08),
            Color(red: 0.08, green: 0.08, blue: 0.12),
            Color(red: 0.05, green: 0.05, blue: 0.08)
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let cardGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color.white.opacity(0.1),
            Color.white.opacity(0.05)
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let successGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 0.2, green: 0.8, blue: 0.4),
            Color(red: 0.1, green: 0.6, blue: 0.8)
        ]),
        startPoint: .leading,
        endPoint: .trailing
    )
    
    static let warningGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 1.0, green: 0.7, blue: 0.0),
            Color(red: 1.0, green: 0.5, blue: 0.0)
        ]),
        startPoint: .leading,
        endPoint: .trailing
    )
    
    // MARK: - Typography
    
    static func largeTitle() -> Font {
        .system(size: 34, weight: .bold, design: .rounded)
    }
    
    static func title() -> Font {
        .system(size: 28, weight: .bold, design: .rounded)
    }
    
    static func title2() -> Font {
        .system(size: 22, weight: .semibold, design: .rounded)
    }
    
    static func title3() -> Font {
        .system(size: 20, weight: .semibold, design: .rounded)
    }
    
    static func headline() -> Font {
        .system(size: 17, weight: .semibold, design: .rounded)
    }
    
    static func body() -> Font {
        .system(size: 17, weight: .regular, design: .rounded)
    }
    
    static func bodyMedium() -> Font {
        .system(size: 17, weight: .medium, design: .rounded)
    }
    
    static func callout() -> Font {
        .system(size: 16, weight: .regular, design: .rounded)
    }
    
    static func subheadline() -> Font {
        .system(size: 15, weight: .medium, design: .rounded)
    }
    
    static func footnote() -> Font {
        .system(size: 13, weight: .regular, design: .rounded)
    }
    
    static func caption() -> Font {
        .system(size: 12, weight: .medium, design: .rounded)
    }
    
    static func caption2() -> Font {
        .system(size: 11, weight: .regular, design: .rounded)
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
    
    static let shadowSM = Color.black.opacity(0.1)
    static let shadowMD = Color.black.opacity(0.15)
    static let shadowLG = Color.black.opacity(0.2)
    static let shadowXL = Color.black.opacity(0.25)
    
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
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
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
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
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
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
    }
}
