
import Foundation
import Combine

// =====================================================
// VIEWMODEL: QuizViewModel
// =====================================================
// PURPOSE:
// Controls the RecalllQ quiz system.
//
// FEATURES:
// - Create quizzes
// - Create quizzes from Memories
// - Start quizzes
// - Select answers
// - Submit answers
// - Track score
// - Move between questions
// - Complete quiz
// - Restart quiz
// - Delete quizzes
// - Save quizzes locally
// - Load quizzes locally
// =====================================================

final class QuizViewModel: ObservableObject {

    // =====================================================
    // QUIZ STORAGE
    // =====================================================

    @Published var quizzes: [Quiz] = []

    // =====================================================
    // CURRENT QUIZ
    // =====================================================

    @Published var currentQuiz: Quiz?

    // =====================================================
    // UI STATE
    // =====================================================

    @Published var showResult: Bool = false

    // =====================================================
    // STORAGE KEY
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

        let quiz = Quiz(
            title: title,
            questions: questions,
            memoryID: memoryID
        )

        quizzes.insert(
            quiz,
            at: 0
        )

        saveQuizzes()
    }

    // =====================================================
    // CREATE QUIZ FROM MEMORY
    // =====================================================

    func createFromMemory(
        _ memory: Memory
    ) {

        let correctAnswer =
            memory.summary.isEmpty
            ? memory.content
            : memory.summary

        let question = QuizQuestion(
            memoryID: memory.id,
            question:
                "What is the main idea of \(memory.title)?",
            options: [
                correctAnswer,
                "This information is unrelated.",
                "There is not enough information.",
                "None of the above."
            ].shuffled(),
            correctAnswer: correctAnswer,
            explanation:
                "The correct answer is based on the Memory created by RecalllQ."
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
    // START QUIZ BY ID
    // =====================================================

    func startQuiz(
        id: UUID
    ) {

        guard let existingQuiz =
                quizzes.first(
                    where: {
                        $0.id == id
                    }
                )
        else {
            return
        }

        var quiz = existingQuiz

        // Reset quiz

        quiz.currentQuestionIndex = 0
        quiz.isCompleted = false
        quiz.score = 0

        // Clear previous answers

        for index in quiz.questions.indices {

            quiz.questions[index].selectedAnswer = nil
        }

        currentQuiz = quiz

        showResult = false

        saveCurrentQuiz()
    }

    // =====================================================
    // START FIRST AVAILABLE QUIZ
    // =====================================================

    func startQuiz() {

        guard let firstQuiz = quizzes.first else {

            currentQuiz = nil
            showResult = false

            return
        }

        startQuiz(
            id: firstQuiz.id
        )
    }

    // =====================================================
    // CURRENT QUESTION
    // =====================================================

    var currentQuestion: QuizQuestion? {

        guard let quiz = currentQuiz else {
            return nil
        }

        guard
            quiz.currentQuestionIndex >= 0,
            quiz.currentQuestionIndex < quiz.questions.count
        else {
            return nil
        }

        return quiz.questions[
            quiz.currentQuestionIndex
        ]
    }

    // =====================================================
    // CURRENT INDEX
    // =====================================================

    var currentIndex: Int {

        currentQuiz?.currentQuestionIndex ?? 0
    }

    // =====================================================
    // QUESTIONS
    // =====================================================

    var questions: [QuizQuestion] {

        currentQuiz?.questions ?? []
    }

    // =====================================================
    // CORRECT ANSWERS
    // =====================================================

    var correctAnswers: Int {

        currentQuiz?.correctAnswers ?? 0
    }

    // =====================================================
    // SCORE PERCENTAGE
    // =====================================================

    var scorePercentage: Double {

        currentQuiz?.percentage ?? 0
    }

    // =====================================================
    // QUIZ COMPLETE
    // =====================================================

    var isQuizComplete: Bool {

        currentQuiz?.isCompleted ?? false
    }

    // =====================================================
    // SELECT ANSWER
    // =====================================================

    func selectAnswer(
        _ answer: String
    ) {

        guard !showResult else {
            return
        }

        guard var quiz = currentQuiz else {
            return
        }

        let index =
            quiz.currentQuestionIndex

        guard
            index >= 0,
            index < quiz.questions.count
        else {
            return
        }

        quiz.questions[index].selectedAnswer =
            answer

        currentQuiz = quiz

        saveCurrentQuiz()
    }

    // =====================================================
    // SUBMIT ANSWER
    // =====================================================

    func submitAnswer() {

        guard var quiz = currentQuiz else {
            return
        }

        let index =
            quiz.currentQuestionIndex

        guard
            index >= 0,
            index < quiz.questions.count
        else {
            return
        }

        guard
            quiz.questions[index].selectedAnswer != nil
        else {
            return
        }

        // Calculate score from all answered questions

        quiz.score =
            quiz.questions.filter {
                $0.isCorrect
            }.count

        currentQuiz = quiz

        showResult = true

        saveCurrentQuiz()
    }

    // =====================================================
    // NEXT QUESTION
    // =====================================================

    func nextQuestion() {

        guard var quiz = currentQuiz else {
            return
        }

        let currentIndex =
            quiz.currentQuestionIndex

        // =================================================
        // FINISH QUIZ
        // =================================================

        if currentIndex >=
            quiz.questions.count - 1 {

            quiz.score =
                quiz.questions.filter {
                    $0.isCorrect
                }.count

            quiz.isCompleted = true

            currentQuiz = quiz

            showResult = false

            saveCurrentQuiz()

            return
        }

        // =================================================
        // MOVE TO NEXT QUESTION
        // =================================================

        quiz.currentQuestionIndex += 1

        currentQuiz = quiz

        showResult = false

        saveCurrentQuiz()
    }

    // =====================================================
    // RESET CURRENT QUIZ
    // =====================================================

    func resetCurrentQuiz() {

        guard let quiz = currentQuiz else {
            return
        }

        startQuiz(
            id: quiz.id
        )
    }

    // =====================================================
    // RESTART QUIZ
    // =====================================================

    func restartQuiz() {

        resetCurrentQuiz()
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

        if currentQuiz?.id == id {

            currentQuiz = nil
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
    // OVERALL SCORE
    // =====================================================

    var overallPercentage: Double {

        let completed =
            quizzes.filter {
                $0.isCompleted &&
                $0.totalQuestions > 0
            }

        guard !completed.isEmpty else {
            return 0
        }

        let totalQuestions =
            completed.reduce(0) {
                $0 + $1.totalQuestions
            }

        let totalCorrect =
            completed.reduce(0) {
                $0 + $1.correctAnswers
            }

        guard totalQuestions > 0 else {
            return 0
        }

        return Double(totalCorrect)
            / Double(totalQuestions)
            * 100
    }

    // =====================================================
    // SAVE CURRENT QUIZ
    // =====================================================

    private func saveCurrentQuiz() {

        guard let currentQuiz else {
            return
        }

        if let index =
            quizzes.firstIndex(
                where: {
                    $0.id == currentQuiz.id
                }
            ) {

            quizzes[index] = currentQuiz

        } else {

            quizzes.insert(
                currentQuiz,
                at: 0
            )
        }

        saveQuizzes()
    }

    // =====================================================
    // SAVE QUIZZES
    // =====================================================

    private func saveQuizzes() {

        do {

            let data =
                try JSONEncoder().encode(
                    quizzes
                )

            UserDefaults.standard.set(
                data,
                forKey: storageKey
            )

        } catch {

            print(
                "❌ Could not save quizzes: \(error)"
            )
        }
    }

    // =====================================================
    // LOAD QUIZZES
    // =====================================================

    private func loadQuizzes() {

        guard let data =
                UserDefaults.standard.data(
                    forKey: storageKey
                )
        else {

            print(
                "ℹ️ No saved quizzes found."
            )

            return
        }

        do {

            quizzes =
                try JSONDecoder().decode(
                    [Quiz].self,
                    from: data
                )

        } catch {

            print(
                "❌ Could not load quizzes: \(error)"
            )
        }
    }
}
