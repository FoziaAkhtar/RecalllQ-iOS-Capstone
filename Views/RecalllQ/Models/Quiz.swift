
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
// Flashcard
//    ↓
// QuizQuestion
//    ↓
// Quiz
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
    // TOTAL QUESTIONS
    // =====================================================

    var totalQuestions: Int {
        questions.count
    }

    // =====================================================
    // ANSWERED QUESTIONS
    // =====================================================

    var answeredQuestions: Int {
        questions.filter {
            $0.isAnswered
        }.count
    }

    // =====================================================
    // CORRECT ANSWERS
    // =====================================================

    var correctAnswers: Int {
        questions.filter {
            $0.isCorrect
        }.count
    }

    // =====================================================
    // INCORRECT ANSWERS
    // =====================================================

    var incorrectAnswers: Int {
        answeredQuestions - correctAnswers
    }

    // =====================================================
    // PROGRESS
    // =====================================================

    var progress: Double {

        guard totalQuestions > 0 else {
            return 0
        }

        return Double(answeredQuestions)
            / Double(totalQuestions)
    }

    // =====================================================
    // PERCENTAGE
    // =====================================================

    var percentage: Double {

        guard totalQuestions > 0 else {
            return 0
        }

        return Double(correctAnswers)
            / Double(totalQuestions)
            * 100
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

    // =====================================================
    // IS LAST QUESTION
    // =====================================================

    var isLastQuestion: Bool {

        guard !questions.isEmpty else {
            return false
        }

        return currentQuestionIndex >=
            questions.count - 1
    }

    // =====================================================
    // HAS ANSWERED CURRENT QUESTION
    // =====================================================

    var hasAnsweredCurrentQuestion: Bool {

        currentQuestion?.isAnswered ?? false
    }

    // =====================================================
    // RESET QUIZ
    // =====================================================
    // Clears all selected answers and resets progress.

    mutating func reset() {

        currentQuestionIndex = 0

        isCompleted = false

        score = 0

        for index in questions.indices {

            questions[index].selectedAnswer = nil
        }
    }

    // =====================================================
    // UPDATE SCORE
    // =====================================================

    mutating func updateScore() {

        score = correctAnswers
    }

    // =====================================================
    // COMPLETE QUIZ
    // =====================================================

    mutating func complete() {

        score = correctAnswers

        isCompleted = true
    }
}

