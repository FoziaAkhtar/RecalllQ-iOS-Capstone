
import SwiftUI

// =====================================================
// THEME: RecalllQTheme
// =====================================================
// PURPOSE:
// Centralized colour and style system for RecalllQ.
//
// DESIGN:
// 🔵 Blue   = Learning / Technology / Trust
// 🟠 Orange = Motivation / Focus / Reminders
// 🟣 Purple = Smart AI / OCR / Intelligence
// 🟢 Green  = Success / Progress
// ⚪ White  = Clean Learning Environment
//
// Used across:
// - Dashboard
// - Notes
// - Memories
// - Reminders
// - Buttons
// - Cards
// =====================================================

struct RecalllQTheme {

    // =====================================================
    // PRIMARY LEARNING COLOUR
    // =====================================================

    static let primary = Color(
        red: 0.10,
        green: 0.40,
        blue: 0.85
    )

    // =====================================================
    // SECONDARY / MOTIVATION COLOUR
    // =====================================================

    static let secondary = Color(
        red: 1.00,
        green: 0.55,
        blue: 0.10
    )

    // =====================================================
    // SUCCESS COLOUR
    // =====================================================

    static let success = Color(
        red: 0.15,
        green: 0.65,
        blue: 0.35
    )

    // =====================================================
    // WARNING / FOCUS COLOUR
    // =====================================================

    static let warning = Color(
        red: 1.00,
        green: 0.60,
        blue: 0.10
    )

    // =====================================================
    // SMART AI / PURPLE
    // =====================================================

    static let smartPurple = Color(
        red: 0.45,
        green: 0.30,
        blue: 0.80
    )

    // =====================================================
    // TEXT
    // =====================================================

    static let primaryText = Color.primary

    static let secondaryText = Color.secondary

    // =====================================================
    // BACKGROUNDS
    // =====================================================

    static let pageBackground =
        Color(.systemGroupedBackground)

    static let cardBackground =
        Color(.systemBackground)

    static let blueBackground =
        primary.opacity(0.08)

    static let orangeBackground =
        secondary.opacity(0.10)

    static let greenBackground =
        success.opacity(0.10)

    static let purpleBackground =
        smartPurple.opacity(0.10)

    // =====================================================
    // BUTTON COLOURS
    // =====================================================

    static let primaryButton =
        primary

    static let secondaryButton =
        secondary

    static let successButton =
        success

    static let smartButton =
        smartPurple

    // =====================================================
    // STUDY CATEGORY COLOURS
    // =====================================================

    static let studyBlue = Color(
        red: 0.12,
        green: 0.45,
        blue: 0.90
    )

    static let studyOrange = Color(
        red: 1.00,
        green: 0.50,
        blue: 0.08
    )

    static let studyPurple = Color(
        red: 0.45,
        green: 0.30,
        blue: 0.80
    )

    static let studyGreen = Color(
        red: 0.15,
        green: 0.65,
        blue: 0.35
    )

    // =====================================================
    // SPACING
    // =====================================================

    static let smallPadding: CGFloat = 8

    static let mediumPadding: CGFloat = 14

    static let largePadding: CGFloat = 18

    // =====================================================
    // CORNER RADIUS
    // =====================================================

    static let smallRadius: CGFloat = 8

    static let mediumRadius: CGFloat = 12

    static let largeRadius: CGFloat = 18

    // Button radius
    static let buttonRadius: CGFloat = 14

    // =====================================================
    // SHADOW
    // =====================================================

    static let shadowOpacity: Double = 0.08

    static let shadowRadius: CGFloat = 6

    static let shadowY: CGFloat = 3
}
