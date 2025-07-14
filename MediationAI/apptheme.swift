//
//  AppTheme.swift
//  MediationAI
//
//  Created by Linda Alster on 7/14/25.
//


import SwiftUI

struct AppTheme {
    // Colors - Using system colors to prevent crashes until custom assets are added
    static let primary = Color(red: 0.42, green: 0.28, blue: 1.0) // #6C47FF
    static let secondary = Color(red: 1.0, green: 0.72, blue: 0.0) // #FFB800
    static let background = Color(red: 0.97, green: 0.97, blue: 0.98) // #F7F7FB
    static let card = Color.white
    static let accent = Color(red: 0.0, green: 0.82, blue: 1.0) // #00D2FF

    // Gradients
    static let mainGradient = LinearGradient(
        gradient: Gradient(colors: [primary, accent]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // Fonts
    static func titleFont() -> Font {
        .system(size: 32, weight: .bold, design: .rounded)
    }
    static func subtitleFont() -> Font {
        .system(size: 20, weight: .semibold, design: .rounded)
    }
    static func bodyFont() -> Font {
        .system(size: 16, weight: .regular, design: .rounded)
    }
    static func buttonFont() -> Font {
        .system(size: 18, weight: .bold, design: .rounded)
    }
    static func chatFont() -> Font {
        .system(size: 16, weight: .medium, design: .rounded)
    }
}
