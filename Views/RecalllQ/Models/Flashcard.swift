
import Foundation

// =====================================================
// MODEL: Flashcard
// =====================================================
// PURPOSE:
// Represents a study flashcard generated from a RecalllQ
// Memory.
//
// FLOW:
//
// Memory
//    ↓
// Flashcard
//    ↓
// Study
//    ↓
// Difficulty
//    ↓
// Future Spaced Repetition
// =====================================================

struct Flashcard: Identifiable, Codable, Equatable {

    // =====================================================
    // IDENTITY
    // =====================================================

    var id: UUID = UUID()

    // =====================================================
    // SOURCE MEMORY
    // =====================================================
    // Keeps track of which Memory created this flashcard.

    var memoryID: UUID?

    // =====================================================
    // CARD CONTENT
    // =====================================================

    var question: String

    var answer: String

    // =====================================================
    // STUDY INFORMATION
    // =====================================================

    var difficulty: Difficulty = .medium

    var timesReviewed: Int = 0

    var timesCorrect: Int = 0

    // =====================================================
    // DATE INFORMATION
    // =====================================================

    var dateCreated: Date = Date()

    var lastReviewed: Date?

    // =====================================================
    // FUTURE SPACED REPETITION
    // =====================================================

    var nextReviewDate: Date?

    // =====================================================
    // DIFFICULTY
    // =====================================================

    enum Difficulty: String, Codable, CaseIterable {

        case easy
        case medium
        case hard

        // ---------------------------------------------
        // DISPLAY NAME
        // ---------------------------------------------

        var displayName: String {

            switch self {

            case .easy:
                return "Easy"

            case .medium:
                return "Medium"

            case .hard:
                return "Hard"
            }
        }
    }

    // =====================================================
    // ACCURACY
    // =====================================================

    var accuracy: Double {

        guard timesReviewed > 0 else {
            return 0
        }

        return Double(timesCorrect)
            / Double(timesReviewed)
    }
}
