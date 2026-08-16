
import SwiftUI

// =====================================================
// THEME: RecalllQTheme
// =====================================================
// PURPOSE:
// Centralized visual styling for RecalllQ.
//
// Used by:
// - DashboardView
// - NotesView
// - MemoriesView
// - QuizView
// - FlashcardsView
// - StudySessionView
// - SettingsView
// - Other RecalllQ screens
//
// DESIGN:
// Bright, modern, lively academic / AI appearance.
// =====================================================

struct RecalllQTheme {

    // =====================================================
    // MAIN COLORS
    // =====================================================

    static let primary =
        Color(
            red: 0.15,
            green: 0.42,
            blue: 0.95
        )

    static let primaryText =
        Color.primary

    static let secondaryText =
        Color.secondary

    // =====================================================
    // APP BACKGROUND
    // =====================================================
    // Light blue/lavender background gives RecalllQ
    // a more lively AI-learning appearance.

    static let background =
        Color(
            red: 0.94,
            green: 0.97,
            blue: 1.00
        )

    // =====================================================
    // PAGE BACKGROUND
    // =====================================================

    static let pageBackground =
        Color(
            red: 0.97,
            green: 0.98,
            blue: 1.00
        )

    // =====================================================
    // CARD BACKGROUND
    // =====================================================

    static let cardBackground =
        Color.white

    // =====================================================
    // FEATURE BACKGROUNDS
    // =====================================================

    static let blueBackground =
        Color(
            red: 0.88,
            green: 0.94,
            blue: 1.00
        )

    static let orangeBackground =
        Color(
            red: 1.00,
            green: 0.94,
            blue: 0.84
        )

    static let greenBackground =
        Color(
            red: 0.88,
            green: 0.97,
            blue: 0.91
        )

    static let redBackground =
        Color(
            red: 1.00,
            green: 0.91,
            blue: 0.91
        )

    static let purpleBackground =
        Color(
            red: 0.94,
            green: 0.90,
            blue: 1.00
        )

    // =====================================================
    // FEATURE COLORS
    // =====================================================

    static let studyOrange =
        Color(
            red: 1.00,
            green: 0.55,
            blue: 0.12
        )

    static let secondary =
        Color(
            red: 0.55,
            green: 0.32,
            blue: 0.90
        )

    static let success =
        Color(
            red: 0.15,
            green: 0.70,
            blue: 0.38
        )

    static let warning =
        Color(
            red: 1.00,
            green: 0.62,
            blue: 0.10
        )

    static let error =
        Color(
            red: 0.90,
            green: 0.20,
            blue: 0.25
        )

    static let smartPurple =
        Color(
            red: 0.60,
            green: 0.35,
            blue: 0.95
        )

    // =====================================================
    // BUTTON COLORS
    // =====================================================

    static let primaryButton =
        Color(
            red: 0.15,
            green: 0.42,
            blue: 0.95
        )

    static let secondaryButton =
        Color(
            red: 0.55,
            green: 0.32,
            blue: 0.90
        )

    // =====================================================
    // PADDING
    // =====================================================

    static let smallPadding: CGFloat =
        8

    static let mediumPadding: CGFloat =
        14

    static let largePadding: CGFloat =
        20

    // =====================================================
    // CORNER RADIUS
    // =====================================================

    static let smallRadius: CGFloat =
        8

    static let mediumRadius: CGFloat =
        14

    static let largeRadius: CGFloat =
        20

    static let buttonRadius: CGFloat =
        14

    // =====================================================
    // SHADOW
    // =====================================================

    static let shadowOpacity: Double =
        0.08

    static let shadowRadius: CGFloat =
        8

    static let shadowY: CGFloat =
        4
}
