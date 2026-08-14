
import Foundation
import Combine

// =====================================================
// VIEWMODEL: QuizViewModel
// =====================================================
// PURPOSE:
// Manages all quiz-related operations for RecalllQ.
//
// FEATURES:
// - Create quizzes
// - Create quizzes from Memories
// - Select answers
// - Move between questions
// - Calculate scores
// - Complete quizzes
// - Save quizzes locally
// - Load quizzes locally
// - Delete quizzes
// - Track quiz progress
// =====================================================

final class QuizViewModel: ObservableObject {

    // =====================================================
    // MAIN STATE
    // =====================================================

    @Published var quizzes: [Quiz] = []

    // =====================================================
    // UI STATE
    // =====================================================

    @Published var currentQuizID: UUID?

    @Published var selectedAnswer: String?

    @Published var showResult: Bool = false

    // =====================================================
    // STORAGE
    // =====================================================

    private let storageKey = "saved_quizzes"

    // =====================================================
    // INIT
    // =====================================================

    init() {
        loadQuizzes()
    }

    // =====================================================
    // CREATE QUIZ
    // =====================================================

    func createQuiz(
        title: String,
        questions: [QuizQuestion],
        memoryID: UUID? = nil
    ) {

        guard !questions.isEmpty else {
            return
        }

        let cleanTitle =
            title.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        let quiz = Quiz(
            title: cleanTitle.isEmpty
                ? "Study Quiz"
                : cleanTitle,
            questions: questions,
            memoryID: memoryID
        )

        quizzes.insert(
            quiz,
            at: 0
        )

        currentQuizID = quiz.id

        saveQuizzes()
    }

    // =====================================================
    // CREATE QUIZ FROM MEMORY
    // =====================================================
    // Creates a simple quiz using information from
    // an existing RecalllQ Memory.

    func createFromMemory(
        _ memory: Memory
    ) {

        let answer =
            memory.summary.isEmpty
            ? memory.content
            : memory.summary

        let question = QuizQuestion(
            memoryID: memory.id,
            question:
                "What is the main idea of \(memory.title)?",
            options: [
                answer,
                "This topic is unrelated to the study material.",
                "There is not enough information to understand this topic.",
                "None of the above."
            ],
            correctAnswer: answer,
            explanation:
                "The correct answer is based on the summary of this memory."
        )

        createQuiz(
            title: "\(memory.title) Quiz",
            questions: [question],
            memoryID: memory.id
        )
    }

    // =====================================================
    // CREATE QUIZZES FROM MEMORIES
    // =====================================================

    func createFromMemories(
        _ memories: [Memory]
    ) {

        for memory in memories {

            createFromMemory(
                memory
            )
        }
    }

    // =====================================================
    // START QUIZ
    // =====================================================

    func startQuiz(
        id: UUID
    ) {

        guard let index =
            quizzes.firstIndex(
                where: { $0.id == id }
            )
        else {
            return
        }

        quizzes[index].currentQuestionIndex = 0
        quizzes[index].isCompleted = false
        quizzes[index].score = 0

        for questionIndex in quizzes[index].questions.indices {

            quizzes[index]
                .questions[questionIndex]
                .selectedAnswer = nil
        }

        currentQuizID = id

        selectedAnswer = nil
        showResult = false

        saveQuizzes()
    }

    // =====================================================
    // CURRENT QUIZ
    // =====================================================

    var currentQuiz: Quiz? {

        guard let currentQuizID else {
            return nil
        }

        return quizzes.first {
            $0.id == currentQuizID
        }
    }

    // =====================================================
    // CURRENT QUESTION
    // =====================================================

    var currentQuestion: QuizQuestion? {

        currentQuiz?.currentQuestion
    }

    // =====================================================
    // SELECT ANSWER
    // =====================================================

    func selectAnswer(
        _ answer: String
    ) {

        guard
            let quizID = currentQuizID,
            let quizIndex =
                quizzes.firstIndex(
                    where: { $0.id == quizID }
                )
        else {
            return
        }

        let questionIndex =
            quizzes[quizIndex].currentQuestionIndex

        guard
            questionIndex >= 0,
            questionIndex <
                quizzes[quizIndex].questions.count
        else {
            return
        }

        quizzes[quizIndex]
            .questions[questionIndex]
            .selectedAnswer = answer

        selectedAnswer = answer

        saveQuizzes()
    }

    // =====================================================
    // SUBMIT ANSWER
    // =====================================================

    func submitAnswer() {

        guard
            let quizID = currentQuizID,
            let quizIndex =
                quizzes.firstIndex(
                    where: { $0.id == quizID }
                )
        else {
            return
        }

        let questionIndex =
            quizzes[quizIndex].currentQuestionIndex

        guard
            questionIndex >= 0,
            questionIndex <
                quizzes[quizIndex].questions.count
        else {
            return
        }

        let question =
            quizzes[quizIndex]
                .questions[questionIndex]

        if question.isCorrect {

            quizzes[quizIndex].score += 1
        }

        showResult = true

        saveQuizzes()
    }

    // =====================================================
    // NEXT QUESTION
    // =====================================================

    func nextQuestion() {

        guard
            let quizID = currentQuizID,
            let quizIndex =
                quizzes.firstIndex(
                    where: { $0.id == quizID }
                )
        else {
            return
        }

        if quizzes[quizIndex].currentQuestionIndex <
            quizzes[quizIndex].questions.count - 1 {

            quizzes[quizIndex]
                .currentQuestionIndex += 1

            selectedAnswer =
                quizzes[quizIndex]
                    .currentQuestion?
                    .selectedAnswer

            showResult = false

        } else {

            completeQuiz()
        }

        saveQuizzes()
    }

    // =====================================================
    // PREVIOUS QUESTION
    // =====================================================

    func previousQuestion() {

        guard
            let quizID = currentQuizID,
            let quizIndex =
                quizzes.firstIndex(
                    where: { $0.id == quizID }
                )
        else {
            return
        }

        if quizzes[quizIndex].currentQuestionIndex > 0 {

            quizzes[quizIndex]
                .currentQuestionIndex -= 1

            selectedAnswer =
                quizzes[quizIndex]
                    .currentQuestion?
                    .selectedAnswer

            showResult = false
        }

        saveQuizzes()
    }

    // =====================================================
    // COMPLETE QUIZ
    // =====================================================

    func completeQuiz() {

        guard
            let quizID = currentQuizID,
            let quizIndex =
                quizzes.firstIndex(
                    where: { $0.id == quizID }
                )
        else {
            return
        }

        quizzes[quizIndex].isCompleted = true

        showResult = true

        saveQuizzes()
    }

    // =====================================================
    // RESET CURRENT QUIZ
    // =====================================================

    func resetCurrentQuiz() {

        guard let quizID = currentQuizID else {
            return
        }

        startQuiz(
            id: quizID
        )
    }

    // =====================================================
    // DELETE QUIZ
    // =====================================================

    func deleteQuiz(
        id: UUID
    ) {

        quizzes.removeAll {
            $0.id == id
        }

        if currentQuizID == id {
            currentQuizID = nil
            selectedAnswer = nil
            showResult = false
        }

        saveQuizzes()
    }

    // =====================================================
    // TOTAL QUIZZES
    // =====================================================

    var totalQuizzes: Int {
        quizzes.count
    }

    // =====================================================
    // COMPLETED QUIZZES
    // =====================================================

    var completedQuizzes: Int {

        quizzes.filter {
            $0.isCompleted
        }.count
    }

    // =====================================================
    // AVERAGE SCORE
    // =====================================================

    var averageScore: Double {

        let completed =
            quizzes.filter {
                $0.isCompleted &&
                $0.totalQuestions > 0
            }

        guard !completed.isEmpty else {
            return 0
        }

        let total =
            completed.reduce(0.0) {
                $0 + $1.percentage
            }

        return total /
            Double(completed.count)
    }

    // =====================================================
    // SAVE
    // =====================================================

    private func saveQuizzes() {

        guard let data =
            try? JSONEncoder().encode(
                quizzes
            )
        else {

            print(
                "❌ Could not save quizzes."
            )

            return
        }

        UserDefaults.standard.set(
            data,
            forKey: storageKey
        )
    }

    // =====================================================
    // LOAD
    // =====================================================

    private func loadQuizzes() {

        guard
            let data =
                UserDefaults.standard.data(
                    forKey: storageKey
                ),

            let decoded =
                try? JSONDecoder().decode(
                    [Quiz].self,
                    from: data
                )
        else {

            print(
                "ℹ️ No saved quizzes found."
            )

            return
        }

        quizzes = decoded
    }
}
