
//
//  QuizViewModel.swift
//  RecalllQ
//
//  Created by Fozia Akhtar
//

// ============================================================
// QUIZ VIEW MODEL
// ============================================================
//
// This ViewModel manages:
//
// • Quiz creation
// • Quiz storage
// • Quiz loading
// • Quiz deletion
// • Quiz gameplay
// • Answer selection
// • Quiz scoring
// • Quiz progress
// • AI-generated quizzes
// • Local fallback quizzes
// • User-specific quiz isolation
//
// SECURITY UPDATE
// ------------------------------------------------------------
//
// Quiz content is NO LONGER stored directly in UserDefaults.
//
// Quiz data is now stored through:
//
//      QuizStorageService
//
// Each account receives its own protected JSON file:
//
//      quizzes_<user>.json
//
// UserDefaults is still allowed for lightweight application
// settings such as the active account identifier, but it is
// NOT used to store quiz content.
//
// ============================================================

import Foundation
import Combine

// ============================================================
// MARK: - Quiz View Model
// ============================================================

@MainActor
final class QuizViewModel: ObservableObject {

    // ============================================================
    // MARK: - App State Reference
    // ============================================================

    weak var appState: AppState?

    // ============================================================
    // MARK: - Published Quiz Data
    // ============================================================

    @Published var quizzes: [Quiz] = []

    @Published var currentQuiz: Quiz?

    @Published var showResult: Bool = false

    @Published var isGeneratingAIQuiz: Bool = false

    @Published var aiQuizError: String?

    // ============================================================
    // MARK: - Current User
    // ============================================================
    //
    // This identifies which account currently owns the quiz data.
    //
    // Every account receives its own QuizStorageService.
    //
    // ============================================================

    private(set) var currentUserID: String?

    // ============================================================
    // MARK: - Services
    // ============================================================

    private let quizAPIService = QuizAPIService()

    // Secure per-user quiz storage.
    //
    // This replaces the previous UserDefaults-based storage.

    private var storage: QuizStorageService?

    // ============================================================
    // MARK: - Compatibility Properties
    // ============================================================
    //
    // These properties are retained because AppState/project code
    // may check whether this ViewModel supports these operations.
    //
    // ============================================================

    var respondsToSwitchUser: Bool {
        true
    }

    var respondsToClearCurrentUserData: Bool {
        true
    }

    var respondsToSave: Bool {
        true
    }

    // ============================================================
    // MARK: - Initialization
    // ============================================================
    //
    // We intentionally do NOT load quizzes here.
    //
    // At initialization time we may not yet know which user is
    // signed in.
    //
    // AppState will call:
    //
    //      switchUser(to:)
    //
    // after authentication.
    //
    // ============================================================

    init() {

        quizzes = []

        currentQuiz = nil
    }

    // ============================================================
    // MARK: - Switch User
    // ============================================================
    //
    // Loads ONLY the quizzes belonging to the selected account.
    //
    // This is one of the most important methods for account
    // isolation.
    //
    // ============================================================

    func switchUser(
        to userID: String
    ) {

        // ========================================================
        // CLEAR CURRENT ACCOUNT FROM MEMORY
        // ========================================================

        quizzes.removeAll()

        currentQuiz = nil

        showResult = false

        isGeneratingAIQuiz = false

        aiQuizError = nil

        // ========================================================
        // REMOVE PREVIOUS STORAGE SERVICE
        // ========================================================

        storage = nil

        // ========================================================
        // NORMALIZE USER IDENTIFIER
        // ========================================================

        let cleanUserID =
            userID
                .trimmingCharacters(
                    in: .whitespacesAndNewlines
                )
                .lowercased()

        guard !cleanUserID.isEmpty else {

            currentUserID = nil

            return
        }

        // ========================================================
        // SET NEW ACTIVE USER
        // ========================================================

        currentUserID = cleanUserID

        // ========================================================
        // CREATE USER-SPECIFIC STORAGE
        // ========================================================

        storage =
            QuizStorageService(
                userID: cleanUserID
            )

        // ========================================================
        // LOAD ONLY THIS USER'S QUIZZES
        // ========================================================

        loadQuizzes()
    }

    // ============================================================
    // MARK: - Clear Current User Data From Memory
    // ============================================================
    //
    // This clears the currently active user's quiz data from RAM.
    //
    // IMPORTANT:
    //
    // This does NOT delete the user's saved quiz file.
    //
    // It is used when switching accounts or logging out.
    //
    // ============================================================

    func clearCurrentUserData() {

        quizzes.removeAll()

        currentQuiz = nil

        showResult = false

        isGeneratingAIQuiz = false

        aiQuizError = nil

        storage = nil

        currentUserID = nil
    }

    // ============================================================
    // MARK: - Save
    // ============================================================
    //
    // Compatibility method used by AppState.
    //
    // ============================================================

    func save() {

        saveQuizzes()
    }

    // ============================================================
    // MARK: - Create Quiz
    // ============================================================
    //
    // Creates a new quiz for the currently authenticated user.
    //
    // ============================================================

    @discardableResult
    func createQuiz(
        title: String,
        questions: [QuizQuestion]
    ) -> Quiz? {

        // ========================================================
        // A QUIZ MUST BELONG TO AN ACTIVE USER
        // ========================================================

        guard currentUserID != nil else {

            return nil
        }

        // ========================================================
        // A QUIZ MUST CONTAIN AT LEAST ONE QUESTION
        // ========================================================

        guard !questions.isEmpty else {

            return nil
        }

        // ========================================================
        // CLEAN QUIZ TITLE
        // ========================================================

        let cleanTitle =
            title
                .trimmingCharacters(
                    in: .whitespacesAndNewlines
                )

        // ========================================================
        // CREATE QUIZ
        // ========================================================

        let quiz =
            Quiz(
                id: UUID(),
                title: cleanTitle,
                questions: questions,
                memoryID: nil,
                dateCreated: Date(),
                currentQuestionIndex: 0,
                isCompleted: false,
                score: 0
            )

        // ========================================================
        // ADD NEWEST QUIZ TO BEGINNING OF LIST
        // ========================================================

        quizzes.insert(
            quiz,
            at: 0
        )

        // ========================================================
        // SAVE QUIZ
        // ========================================================

        saveQuizzes()

        return quiz
    }

    // ============================================================
    // MARK: - Create Quiz From One Memory
    // ============================================================

    @discardableResult
    func createFromMemory(
        _ memory: Memory,
        title: String,
        questions: [QuizQuestion]
    ) -> Quiz? {

        // ========================================================
        // CREATE QUIZ
        // ========================================================

        guard let quiz =
            createQuiz(
                title: title,
                questions: questions
            )
        else {

            return nil
        }

        // ========================================================
        // ATTACH SOURCE MEMORY
        // ========================================================

        guard let index =
            quizzes.firstIndex(
                where: {
                    $0.id == quiz.id
                }
            )
        else {

            return quiz
        }

        quizzes[index].memoryID =
            memory.id

        // ========================================================
        // SAVE UPDATED QUIZ
        // ========================================================

        saveQuizzes()

        return quizzes[index]
    }

    // ============================================================
    // MARK: - Create Quiz From Multiple Memories
    // ============================================================

    @discardableResult
    func createFromMemories(
        _ memories: [Memory],
        title: String,
        questions: [QuizQuestion]
    ) -> Quiz? {

        // ========================================================
        // MULTIPLE MEMORIES CAN CONTRIBUTE TO THE QUIZ
        // ========================================================
        //
        // The current Quiz model supports only one optional
        // memoryID, so we create the quiz without assigning a
        // single source memory.
        //
        // ========================================================

        return createQuiz(
            title: title,
            questions: questions
        )
    }

    // ============================================================
    // MARK: - Generate AI Quiz
    // ============================================================
    //
    // Generates a quiz using QuizAPIService.
    //
    // IMPORTANT:
    //
    // QuizAPIService returns:
    //
    //      [QuizQuestion]
    //
    // It does NOT return a complete Quiz object.
    //
    // Therefore we must:
    //
    //      AI
    //       ↓
    //      [QuizQuestion]
    //       ↓
    //      createQuiz()
    //       ↓
    //      Quiz
    //       ↓
    //      User's QuizStorageService
    //
    // This also keeps user-specific quiz isolation working.
    //
    // ============================================================

    func generateAIQuizFromMemory(
        _ memory: Memory,
        numberOfQuestions: Int = 5
    ) async {

        // ========================================================
        // MAKE SURE USER IS STILL AUTHENTICATED
        // ========================================================

        guard let userID = currentUserID else {

            aiQuizError =
                "Please sign in before generating a quiz."

            return
        }

        // ========================================================
        // PREVENT DUPLICATE GENERATION REQUESTS
        // ========================================================

        guard !isGeneratingAIQuiz else {

            return
        }

        // ========================================================
        // RESET PREVIOUS ERROR
        // ========================================================

        aiQuizError = nil

        isGeneratingAIQuiz = true

        defer {

            isGeneratingAIQuiz = false
        }

        // ========================================================
        // GENERATE QUESTIONS
        // ========================================================

        let generatedQuestions =
            await quizAPIService.generateQuiz(
                from: [memory],
                numberOfQuestions: numberOfQuestions
            )

        // ========================================================
        // MAKE SURE USER HAS NOT CHANGED
        // ========================================================

        guard currentUserID == userID else {

            return
        }

        // ========================================================
        // VALIDATE GENERATED QUESTIONS
        // ========================================================

        guard !generatedQuestions.isEmpty else {

            aiQuizError =
                "The quiz could not be generated."

            return
        }

        // ========================================================
        // CREATE COMPLETE QUIZ
        // ========================================================

        guard let generatedQuiz =
            createQuiz(
                title: "AI Quiz: \(memory.title)",
                questions: generatedQuestions
            )
        else {

            aiQuizError =
                "The quiz could not be saved."

            return
        }

        // ========================================================
        // FIND NEWLY CREATED QUIZ
        // ========================================================

        guard let index =
            quizzes.firstIndex(
                where: {
                    $0.id == generatedQuiz.id
                }
            )
        else {

            startQuiz(
                generatedQuiz
            )

            return
        }

        // ========================================================
        // ATTACH SOURCE MEMORY
        // ========================================================

        quizzes[index].memoryID =
            memory.id

        // ========================================================
        // SAVE UPDATED QUIZ
        // ========================================================

        saveQuizzes()

        // ========================================================
        // OPEN GENERATED QUIZ
        // ========================================================

        startQuiz(
            quizzes[index]
        )
    }

    // ============================================================
    // MARK: - Start Quiz
    // ============================================================

    func startQuiz(
        _ quiz: Quiz
    ) {

        currentQuiz = quiz

        showResult = false

        aiQuizError = nil
    }

    // ============================================================
    // MARK: - Current Question
    // ============================================================

    var currentQuestion: QuizQuestion? {

        guard let quiz = currentQuiz else {

            return nil
        }

        guard quiz.currentQuestionIndex >= 0 else {

            return nil
        }

        guard quiz.currentQuestionIndex <
                quiz.questions.count
        else {

            return nil
        }

        return quiz.questions[
            quiz.currentQuestionIndex
        ]
    }

    // ============================================================
    // MARK: - Select Answer
    // ============================================================

    func selectAnswer(
        _ answerIndex: Int
    ) {

        guard var quiz = currentQuiz else {

            return
        }

        guard quiz.currentQuestionIndex >= 0 else {

            return
        }

        guard quiz.currentQuestionIndex <
                quiz.questions.count
        else {

            return
        }

        guard answerIndex >= 0 else {

            return
        }

        // ========================================================
        // GET CURRENT QUESTION
        // ========================================================

        let currentQuestion =
            quiz.questions[
                quiz.currentQuestionIndex
            ]

        // ========================================================
        // QUIZ QUESTION USES "OPTIONS"
        // ========================================================

        guard answerIndex <
                currentQuestion.options.count
        else {

            return
        }

        // ========================================================
        // STORE SELECTED ANSWER
        // ========================================================

        quiz.questions[
            quiz.currentQuestionIndex
        ].selectedAnswer =
            currentQuestion.options[
                answerIndex
            ]

        // ========================================================
        // UPDATE CURRENT QUIZ
        // ========================================================

        currentQuiz = quiz

        // ========================================================
        // SAVE PROGRESS
        // ========================================================

        saveCurrentQuiz()
    }

    // ============================================================
    // MARK: - Submit Answer
    // ============================================================
    //
    // IMPORTANT:
    //
    // This method must turn on showResult after the answer is
    // submitted.
    //
    // Without:
    //
    //      showResult = true
    //
    // QuizView continues showing the Submit Answer button and
    // the user sees no visible result.
    //
    // ============================================================

    func submitAnswer() {

        guard var quiz = currentQuiz else {

            return
        }

        guard quiz.currentQuestionIndex >= 0 else {

            return
        }

        guard quiz.currentQuestionIndex <
                quiz.questions.count
        else {

            return
        }

        // ========================================================
        // MAKE SURE ANSWER HAS BEEN SELECTED
        // ========================================================

        guard quiz.questions[
            quiz.currentQuestionIndex
        ].selectedAnswer != nil
        else {

            return
        }

        // ========================================================
        // UPDATE QUIZ SCORE
        // ========================================================

        quiz.updateScore()

        // ========================================================
        // UPDATE CURRENT QUIZ
        // ========================================================

        currentQuiz = quiz

        // ========================================================
        // SHOW ANSWER RESULT
        // ========================================================
        //
        // This is the important fix.
        //
        // QuizView uses this property to switch from:
        //
        //      Submit Answer
        //
        // to:
        //
        //      Correct / Not Quite
        //      Correct Answer
        //      Explanation
        //      Next Question
        //
        // ========================================================

        showResult = true

        // ========================================================
        // SAVE PROGRESS
        // ========================================================

        saveCurrentQuiz()
    }

    // ============================================================
    // MARK: - Next Question
    // ============================================================

    func nextQuestion() {

        guard var quiz = currentQuiz else {

            return
        }

        // ========================================================
        // IF THERE ARE NO QUESTIONS, STOP
        // ========================================================

        guard !quiz.questions.isEmpty else {

            return
        }

        // ========================================================
        // DETERMINE WHETHER THIS IS THE FINAL QUESTION
        // ========================================================

        if quiz.currentQuestionIndex >=
            quiz.questions.count - 1 {

            // ====================================================
            // QUIZ IS COMPLETE
            // ====================================================

            quiz.complete()

            currentQuiz = quiz

            showResult = true

            saveCurrentQuiz()

            return
        }

        // ========================================================
        // MOVE TO NEXT QUESTION
        // ========================================================

        quiz.currentQuestionIndex += 1

        currentQuiz = quiz

        showResult = false

        saveCurrentQuiz()
    }

    // ============================================================
    // MARK: - Reset Quiz
    // ============================================================

    func resetQuiz() {

        guard var quiz = currentQuiz else {

            return
        }

        // ========================================================
        // RESET QUIZ
        // ========================================================

        quiz.reset()

        // ========================================================
        // UPDATE CURRENT QUIZ
        // ========================================================

        currentQuiz = quiz

        showResult = false

        // ========================================================
        // SAVE RESET STATE
        // ========================================================

        saveCurrentQuiz()
    }

    // ============================================================
    // MARK: - Restart Quiz
    // ============================================================

    func restartQuiz() {

        resetQuiz()
    }

    // ============================================================
    // MARK: - Exit Quiz
    // ============================================================

    func exitQuiz() {

        currentQuiz = nil

        showResult = false
    }

    // ============================================================
    // MARK: - Delete Quiz
    // ============================================================

    func deleteQuiz(
        _ quiz: Quiz
    ) {

        quizzes.removeAll {
            existingQuiz in

            existingQuiz.id == quiz.id
        }

        // ========================================================
        // CLOSE IF CURRENT QUIZ WAS DELETED
        // ========================================================

        if currentQuiz?.id == quiz.id {

            currentQuiz = nil

            showResult = false
        }

        // ========================================================
        // SAVE UPDATED COLLECTION
        // ========================================================

        saveQuizzes()
    }

    // ============================================================
    // MARK: - Delete All Quizzes
    // ============================================================

    func deleteAll() {

        quizzes.removeAll()

        currentQuiz = nil

        showResult = false

        // ========================================================
        // SAVE EMPTY COLLECTION
        // ========================================================

        saveQuizzes()
    }

    // ============================================================
    // MARK: - Quiz Statistics
    // ============================================================

    var totalQuizzes: Int {

        quizzes.count
    }

    var completedQuizzes: Int {

        quizzes.filter {
            $0.isCompleted
        }.count
    }

    var incompleteQuizzes: Int {

        quizzes.filter {
            !$0.isCompleted
        }.count
    }

    // ============================================================
    // MARK: - Overall Percentage
    // ============================================================

    var overallPercentage: Double {

        let completed =
            quizzes.filter {
                $0.isCompleted
            }

        guard !completed.isEmpty else {

            return 0
        }

        let percentages =
            completed.map {
                $0.percentage
            }

        guard !percentages.isEmpty else {

            return 0
        }

        return percentages.reduce(
            0,
            +
        ) /
        Double(
            percentages.count
        )
    }

    // ============================================================
    // MARK: - Current Quiz Score Percentage
    // ============================================================
    //
    // This property is used by QuizView.
    //
    // It returns the percentage of the currently active quiz.
    //
    // If there is no active quiz, it safely returns 0.
    //
    // ============================================================

    var scorePercentage: Double {

        guard let quiz = currentQuiz else {

            return 0
        }

        return quiz.percentage
    }

    // ============================================================
    // MARK: - Current Quiz Correct Answers
    // ============================================================
    //
    // Returns the number of questions answered correctly in the
    // currently active quiz.
    //
    // QuizView uses this value on the final quiz completion screen.
    //
    // The calculation is based directly on QuizQuestion.isCorrect,
    // so there is no separate score-tracking system to maintain.
    //
    // ============================================================

    var correctAnswers: Int {

        // ========================================================
        // MAKE SURE A QUIZ IS ACTIVE
        // ========================================================

        guard let quiz = currentQuiz else {

            return 0
        }

        // ========================================================
        // COUNT CORRECT ANSWERS
        // ========================================================

        return quiz.questions.filter {
            $0.isCorrect
        }.count
    }

    // ============================================================
    // MARK: - Average Score
    // ============================================================

    var averageScore: Double {

        let completed =
            quizzes.filter {
                $0.isCompleted
            }

        guard !completed.isEmpty else {

            return 0
        }

        let totalScore =
            completed.reduce(0) {
                $0 + $1.score
            }

        return Double(totalScore) /
            Double(
                completed.count
            )
    }

    // ============================================================
    // MARK: - Best Score
    // ============================================================

    var bestScore: Int {

        quizzes
            .filter {
                $0.isCompleted
            }
            .map {
                $0.score
            }
            .max() ?? 0
    }

    // ============================================================
    // MARK: - Save Current Quiz
    // ============================================================
    //
    // Updates the saved version of the currently active quiz.
    //
    // ============================================================

    private func saveCurrentQuiz() {

        guard let currentQuiz else {

            return
        }

        // ========================================================
        // FIND QUIZ IN USER COLLECTION
        // ========================================================

        if let index =
            quizzes.firstIndex(
                where: {
                    $0.id == currentQuiz.id
                }
            ) {

            // ====================================================
            // UPDATE STORED QUIZ
            // ====================================================

            quizzes[index] =
                currentQuiz
        }

        // ========================================================
        // PERSIST CHANGES
        // ========================================================

        saveQuizzes()
    }

    // ============================================================
    // MARK: - Save Quizzes
    // ============================================================
    //
    // Saves quizzes through QuizStorageService.
    //
    // IMPORTANT:
    //
    // There is NO UserDefaults storage here anymore.
    //
    // ============================================================

    private func saveQuizzes() {

        // ========================================================
        // QUIZ MUST BELONG TO ACTIVE USER
        // ========================================================

        guard currentUserID != nil else {

            return
        }

        // ========================================================
        // STORAGE MUST EXIST
        // ========================================================

        guard let storage else {

            return
        }

        // ========================================================
        // SAVE ONLY THIS USER'S QUIZZES
        // ========================================================

        storage.save(
            quizzes
        )
    }

    // ============================================================
    // MARK: - Load Quizzes
    // ============================================================
    //
    // Loads quizzes from the current user's QuizStorageService.
    //
    // ============================================================

    private func loadQuizzes() {

        // ========================================================
        // USER MUST BE ACTIVE
        // ========================================================

        guard let currentUserID else {

            quizzes = []

            return
        }

        // ========================================================
        // MAKE SURE STORAGE EXISTS
        // ========================================================

        if storage == nil {

            storage =
                QuizStorageService(
                    userID: currentUserID
                )
        }

        // ========================================================
        // LOAD ONLY THIS USER'S QUIZZES
        // ========================================================

        quizzes =
            storage?.load() ?? []

        // ========================================================
        // RESET ACTIVE QUIZ STATE
        // ========================================================

        currentQuiz = nil

        showResult = false

        aiQuizError = nil
    }
}

