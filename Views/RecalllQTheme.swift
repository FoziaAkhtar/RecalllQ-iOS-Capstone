
import SwiftUI

// =====================================================
// THEME: RecalllQTheme
// =====================================================
// PURPOSE:
// Centralized visual styling for RecalllQ.
//
// DESIGN:
// Bright, colourful, modern academic + AI appearance.
//
// COLOUR SYSTEM:
// 🔵 Memories / Primary
// 🟣 AI / Smart Features
// 🟠 Flashcards / Study
// 🌸 Quizzes / Secondary
// 🟢 Success / Progress
// 🔴 Errors / Alerts
// 🩵 Notes / Supporting Features
// =====================================================

struct RecalllQTheme {

    // =====================================================
    // MAIN BRAND COLORS
    // =====================================================

    /// Main RecalllQ blue
    static let primary =
        Color(
            red: 0.12,
            green: 0.39,
            blue: 0.96
        )

    /// Main text colour
    static let primaryText =
        Color.primary

    /// Secondary text colour
    static let secondaryText =
        Color.secondary

    // =====================================================
    // APP BACKGROUND
    // =====================================================

    /// Main application background
    static let background =
        Color(
            red: 0.94,
            green: 0.97,
            blue: 1.00
        )

    /// Slightly brighter page background
    static let pageBackground =
        Color(
            red: 0.975,
            green: 0.985,
            blue: 1.00
        )

    /// Card background
    static let cardBackground =
        Color.white

    // =====================================================
    // FEATURE BACKGROUNDS
    // =====================================================

    /// 🔵 Memories / Primary
    static let blueBackground =
        Color(
            red: 0.87,
            green: 0.93,
            blue: 1.00
        )

    /// 🟠 Flashcards / Study
    static let orangeBackground =
        Color(
            red: 1.00,
            green: 0.93,
            blue: 0.82
        )

    /// 🟢 Progress / Success
    static let greenBackground =
        Color(
            red: 0.86,
            green: 0.97,
            blue: 0.90
        )

    /// 🔴 Error / Delete
    static let redBackground =
        Color(
            red: 1.00,
            green: 0.90,
            blue: 0.91
        )

    /// 🟣 AI / Smart Features
    static let purpleBackground =
        Color(
            red: 0.94,
            green: 0.89,
            blue: 1.00
        )

    // =====================================================
    // ADDITIONAL FEATURE BACKGROUNDS
    // =====================================================

    /// 🩵 Notes / Information
    static let cyanBackground =
        Color(
            red: 0.85,
            green: 0.96,
            blue: 1.00
        )

    /// 🌸 Quiz / Knowledge checks
    static let pinkBackground =
        Color(
            red: 1.00,
            green: 0.90,
            blue: 0.95
        )

    /// 🟡 Highlight / Achievement
    static let yellowBackground =
        Color(
            red: 1.00,
            green: 0.96,
            blue: 0.82
        )

    // =====================================================
    // FEATURE COLORS
    // =====================================================

    /// 🟠 Flashcards / Study
    static let studyOrange =
        Color(
            red: 1.00,
            green: 0.48,
            blue: 0.08
        )

    /// 🌸 Secondary / Quiz
    static let secondary =
        Color(
            red: 0.76,
            green: 0.28,
            blue: 0.72
        )

    /// 🟢 Success
    static let success =
        Color(
            red: 0.10,
            green: 0.68,
            blue: 0.36
        )

    /// 🟡 Warning
    static let warning =
        Color(
            red: 1.00,
            green: 0.58,
            blue: 0.05
        )

    /// 🔴 Error
    static let error =
        Color(
            red: 0.90,
            green: 0.16,
            blue: 0.24
        )

    /// 🟣 AI / Smart Suggestions
    static let smartPurple =
        Color(
            red: 0.55,
            green: 0.25,
            blue: 0.92
        )

    /// 🩵 Notes / Supporting features
    static let notesCyan =
        Color(
            red: 0.04,
            green: 0.67,
            blue: 0.82
        )

    /// 🌸 Quiz accent
    static let quizPink =
        Color(
            red: 0.92,
            green: 0.30,
            blue: 0.62
        )

    /// 🟡 Achievement accent
    static let achievementYellow =
        Color(
            red: 0.95,
            green: 0.65,
            blue: 0.05
        )

    // =====================================================
    // GRADIENT COLORS
    // =====================================================

    /// Main RecalllQ gradient
    static let primaryGradient =
        LinearGradient(
            colors: [
                primary,
                smartPurple
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

    /// AI gradient
    static let aiGradient =
        LinearGradient(
            colors: [
                smartPurple,
                secondary
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

    /// Study gradient
    static let studyGradient =
        LinearGradient(
            colors: [
                studyOrange,
                warning
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

    /// Success gradient
    static let successGradient =
        LinearGradient(
            colors: [
                success,
                Color(
                    red: 0.05,
                    green: 0.55,
                    blue: 0.65
                )
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

    /// Quiz gradient
    static let quizGradient =
        LinearGradient(
            colors: [
                quizPink,
                smartPurple
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

    // =====================================================
    // BUTTON COLORS
    // =====================================================

    static let primaryButton =
        primary

    static let secondaryButton =
        smartPurple

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

    // =====================================================
    // EXTRA VISUAL EFFECTS
    // =====================================================

    /// Light glow used behind important AI elements
    static let aiGlow =
        smartPurple.opacity(0.18)

    /// Light glow used behind study elements
    static let studyGlow =
        studyOrange.opacity(0.16)

    /// Light glow used behind success elements
    static let successGlow =
        success.opacity(0.15)
}

