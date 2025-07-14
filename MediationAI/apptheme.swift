//
//  AppTheme.swift
//  meidationaiapp
//
//  Created by Linda Alster on 7/14/25.
//


import SwiftUI

struct AppTheme {
    // Colors
    static let primary = Color("Primary") // Add to Assets: #6C47FF
    static let secondary = Color("Secondary") // Add to Assets: #FFB800
    static let background = Color("Background") // Add to Assets: #F7F7FB
    static let card = Color.white
    static let accent = Color("Accent") // Add to Assets: #00D2FF

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
