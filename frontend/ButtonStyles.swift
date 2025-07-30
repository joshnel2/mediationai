import SwiftUI

// MARK: - Global Button Styles
// Centralized styling for primary and secondary buttons so we don’t repeat
// dozens of modifiers across views.

/// Filled gradient call-to-action that uses the brand palette in `AppTheme`.
struct PrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppTheme.headline())
            .foregroundColor(.white)
            .padding(.vertical, AppTheme.spacingLG)
            .frame(maxWidth: .infinity)
            .background(
                Group {
                    if isEnabled {
                        AppTheme.accentGradient
                    } else {
                        Color.gray.opacity(0.4)
                    }
                }
            )
            .cornerRadius(AppTheme.radiusLG)
            .shadow(color: isEnabled ? AppTheme.primary.opacity(configuration.isPressed ? 0.2 : 0.35) : .clear,
                    radius: configuration.isPressed ? 2 : 8,
                    x: 0, y: configuration.isPressed ? 1 : 4)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .opacity(configuration.isPressed ? 0.96 : 1)
            .animation(.spring(response: 0.35, dampingFraction: 0.65), value: configuration.isPressed)
    }
}

/// Outlined action for secondary interactions.
struct SecondaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppTheme.headline())
            .foregroundColor(isEnabled ? AppTheme.primary : AppTheme.textTertiary)
            .padding(.vertical, AppTheme.spacingLG)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.radiusLG)
                    .stroke(isEnabled ? AppTheme.primary : AppTheme.textTertiary, lineWidth: 2)
            )
            .background(Color.clear)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.spring(response: 0.35, dampingFraction: 0.65), value: configuration.isPressed)
    }
}

// MARK: - Sugar Helpers
extension View {
    /// Apply the filled gradient `PrimaryButtonStyle`.
    func primaryButtonStyle() -> some View {
        self.buttonStyle(PrimaryButtonStyle())
    }

    /// Apply the outlined `SecondaryButtonStyle`.
    func secondaryButtonStyle() -> some View {
        self.buttonStyle(SecondaryButtonStyle())
    }
}