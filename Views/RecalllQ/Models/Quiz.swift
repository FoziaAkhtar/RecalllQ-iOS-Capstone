
import Foundation

// =====================================================
// MODEL: Quiz
// =====================================================
// PURPOSE:
// Represents a complete quiz in RecalllQ.
//
// FLOW:
//
// Memory
//    ↓
// Quiz
//    ↓
// QuizQuestion[]
//    ↓
// Student Study Session
//    ↓
// Score + Progress
// =====================================================

struct Quiz: Identifiable, Codable, Equatable {

    // =====================================================
    // IDENTITY
    // =====================================================

    var id: UUID = UUID()

    // =====================================================
    // QUIZ INFORMATION
    // =====================================================

    var title: String

    var questions: [QuizQuestion]

    // =====================================================
    // SOURCE MEMORY
    // =====================================================

    var memoryID: UUID?

    // =====================================================
    // DATE
    // =====================================================

    var dateCreated: Date = Date()

    // =====================================================
    // STUDY STATE
    // =====================================================

    var currentQuestionIndex: Int = 0

    var isCompleted: Bool = false

    // =====================================================
    // SCORE
    // =====================================================

    var score: Int = 0

    // =====================================================
    // CALCULATED PROPERTIES
    // =====================================================

    var totalQuestions: Int {
        questions.count
    }

    var answeredQuestions: Int {
        questions.filter {
            $0.isAnswered
        }.count
    }

    var correctAnswers: Int {
        questions.filter {
            $0.isCorrect
        }.count
    }

    var progress: Double {

        guard totalQuestions > 0 else {
            return 0
        }

        return Double(answeredQuestions)
            / Double(totalQuestions)
    }

    var percentage: Double {

        guard totalQuestions > 0 else {
            return 0
        }

        return Double(correctAnswers)
            / Double(totalQuestions) * 100
    }

    // =====================================================
    // CURRENT QUESTION
    // =====================================================

    var currentQuestion: QuizQuestion? {

        guard
            currentQuestionIndex >= 0,
            currentQuestionIndex < questions.count
        else {
            return nil
        }

        return questions[currentQuestionIndex]
    }
}
