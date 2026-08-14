
import Foundation

// =====================================================
// MODEL: QuizQuestion
// =====================================================
// PURPOSE:
// Represents one multiple-choice question in RecalllQ.
//
// FLOW:
//
// Flashcard / Memory
//        ↓
//   QuizQuestion
//        ↓
// Student selects answer
//        ↓
// Submit answer
//        ↓
// Correct / Incorrect
// =====================================================

struct QuizQuestion: Identifiable, Codable, Equatable {

    // =====================================================
    // IDENTITY
    // =====================================================

    var id: UUID

    // =====================================================
    // SOURCE MEMORY
    // =====================================================

    var memoryID: UUID?

    // =====================================================
    // QUESTION
    // =====================================================

    var question: String

    // =====================================================
    // ANSWER OPTIONS
    // =====================================================

    var options: [String]

    // =====================================================
    // CORRECT ANSWER
    // =====================================================

    var correctAnswer: String

    // =====================================================
    // SELECTED ANSWER
    // =====================================================

    var selectedAnswer: String?

    // =====================================================
    // EXPLANATION
    // =====================================================

    var explanation: String

    // =====================================================
    // DIFFICULTY
    // =====================================================

    var difficulty: Difficulty

    // =====================================================
    // INITIALIZER
    // =====================================================

    init(
        id: UUID = UUID(),
        memoryID: UUID? = nil,
        question: String,
        options: [String],
        correctAnswer: String,
        selectedAnswer: String? = nil,
        explanation: String = "",
        difficulty: Difficulty = .medium
    ) {

        self.id = id
        self.memoryID = memoryID
        self.question = question
        self.options = options
        self.correctAnswer = correctAnswer
        self.selectedAnswer = selectedAnswer
        self.explanation = explanation
        self.difficulty = difficulty
    }

    // =====================================================
    // ANSWER STATUS
    // =====================================================

    var isAnswered: Bool {
        selectedAnswer != nil
    }

    // =====================================================
    // CORRECT / INCORRECT
    // =====================================================

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

        // =================================================
        // DISPLAY NAME
        // =================================================

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

