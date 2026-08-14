
import Foundation

// =====================================================
// MODEL: QuizQuestion
// =====================================================
// PURPOSE:
// Represents one multiple-choice question in RecalllQ.
//
// FLOW:
//
// Memory
//    ↓
// Quiz
//    ↓
// QuizQuestion
//    ↓
// Student Answer
//    ↓
// Correct / Incorrect
// =====================================================

struct QuizQuestion: Identifiable, Codable, Equatable {

    // =====================================================
    // IDENTITY
    // =====================================================

    var id: UUID = UUID()

    // =====================================================
    // SOURCE MEMORY
    // =====================================================

    var memoryID: UUID?

    // =====================================================
    // QUESTION
    // =====================================================

    var question: String

    // =====================================================
    // MULTIPLE-CHOICE OPTIONS
    // =====================================================

    var options: [String]

    // =====================================================
    // CORRECT ANSWER
    // =====================================================

    var correctAnswer: String

    // =====================================================
    // STUDENT ANSWER
    // =====================================================

    var selectedAnswer: String?

    // =====================================================
    // EXPLANATION
    // =====================================================

    var explanation: String = ""

    // =====================================================
    // DIFFICULTY
    // =====================================================

    var difficulty: Difficulty = .medium

    // =====================================================
    // ANSWER STATUS
    // =====================================================

    var isAnswered: Bool {
        selectedAnswer != nil
    }

    var isCorrect: Bool {
        guard let selectedAnswer else {
            return false
        }

        return selectedAnswer == correctAnswer
    }

    // =====================================================
    // DIFFICULTY
    // =====================================================

    enum Difficulty: String, Codable, CaseIterable {

        case easy
        case medium
        case hard

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
}
