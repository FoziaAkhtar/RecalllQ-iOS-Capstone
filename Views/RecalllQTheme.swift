
import SwiftUI

// =====================================================
// THEME: RecalllQTheme
// =====================================================
// PURPOSE:
// Centralized visual theme for the RecalllQ application.
//
// DESIGN:
// - Professional academic / study appearance
// - Consistent colors across the application
// - Easy to maintain and update
// - Designed for students and learning
// =====================================================

struct RecalllQTheme {

    // =====================================================
    // PRIMARY COLORS
    // =====================================================

    /// Main academic blue
    static let primary = Color(
        red: 0.12,
        green: 0.32,
        blue: 0.62
    )

    /// Secondary study purple
    static let secondary = Color(
        red: 0.38,
        green: 0.28,
        blue: 0.65
    )

    /// Learning / success green
    static let success = Color(
        red: 0.18,
        green: 0.55,
        blue: 0.38
    )

    /// Reminder / attention orange
    static let warning = Color(
        red: 0.92,
        green: 0.55,
        blue: 0.18
    )

    /// Error / destructive actions
    static let danger = Color(
        red: 0.82,
        green: 0.24,
        blue: 0.24
    )

    // =====================================================
    // BACKGROUND COLORS
    // =====================================================

    /// Main soft study background
    static let background = Color(
        red: 0.96,
        green: 0.97,
        blue: 0.99
    )

    /// Card background
    static let cardBackground = Color.white

    /// Soft blue section background
    static let blueBackground = primary.opacity(0.10)

    /// Soft purple section background
    static let purpleBackground = secondary.opacity(0.10)

    /// Soft green section background
    static let greenBackground = success.opacity(0.10)

    /// Soft orange section background
    static let orangeBackground = warning.opacity(0.10)

    // =====================================================
    // TEXT COLORS
    // =====================================================

    static let primaryText = Color.primary

    static let secondaryText = Color.secondary

    // =====================================================
    // CORNER RADIUS
    // =====================================================

    static let smallRadius: CGFloat = 8

    static let mediumRadius: CGFloat = 14

    static let largeRadius: CGFloat = 20

    // =====================================================
    // STANDARD PADDING
    // =====================================================

    static let smallPadding: CGFloat = 8

    static let mediumPadding: CGFloat = 14

    static let largePadding: CGFloat = 20

    // =====================================================
    // SHADOW
    // =====================================================

    static let shadowOpacity: Double = 0.08

    static let shadowRadius: CGFloat = 8

    static let shadowY: CGFloat = 4
}

// =====================================================
// THEME CARD MODIFIER
// =====================================================
// Reusable professional card appearance.
// =====================================================

struct RecalllQCardModifier: ViewModifier {

    func body(content: Content) -> some View {

        content
            .background(
                RoundedRectangle(
                    cornerRadius: RecalllQTheme.mediumRadius
                )
                .fill(RecalllQTheme.cardBackground)
            )
            .shadow(
                color: Color.black.opacity(
                    RecalllQTheme.shadowOpacity
                ),
                radius: RecalllQTheme.shadowRadius,
                x: 0,
                y: RecalllQTheme.shadowY
            )
    }
}

// =====================================================
// VIEW EXTENSION
// =====================================================

extension View {

    /// Applies the standard RecalllQ professional card style.
    func recalllQCard() -> some View {

        modifier(RecalllQCardModifier())
    }
}
