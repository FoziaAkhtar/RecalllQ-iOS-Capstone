
import Foundation
import Combine

// =====================================================
// VIEWMODEL: QuizViewModel
// =====================================================
// PURPOSE:
// Controls the complete RecalllQ quiz system.
//
// FEATURES:
// - Create quizzes
// - Create quizzes from Memories
// - Generate AI quizzes
// - OpenAI / QuizAPIService integration
// - Local fallback quizzes
// - Start quizzes
// - Select answers
// - Submit answers
// - Track score
// - Move between questions
// - Complete quizzes
// - Restart quizzes
// - Delete quizzes
// - Save quizzes locally
// - Load quizzes locally
// - Study Session integration
// - Quiz statistics
// =====================================================

@MainActor
final class QuizViewModel: ObservableObject {

    // =====================================================
    // APP STATE
    // =====================================================

    weak var appState: AppState?

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
    // AI QUIZ STATE
    // =====================================================

    @Published var isGeneratingAIQuiz: Bool = false

    @Published var aiQuizError: String?

    // =====================================================
    // AI QUIZ SERVICE
    // =====================================================

    private let quizAPIService = QuizAPIService()

    // =====================================================
    // STORAGE KEY
    // =====================================================

    private let storageKey = "saved_quizzes"

    // =====================================================
    // INIT
    // =====================================================

    init() {
        loadQuizzes()

        print("========================================")
        print("🧠 QuizViewModel initialized")
        print("📚 Saved quizzes: \(quizzes.count)")
        print("========================================")
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
            print("❌ Cannot create quiz: no questions.")
            return
        }

        let cleanedTitle = title
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        let finalTitle = cleanedTitle.isEmpty
            ? "Untitled Quiz"
            : cleanedTitle

        let quiz = Quiz(
            title: finalTitle,
            questions: questions,
            memoryID: memoryID
        )

        quizzes.insert(
            quiz,
            at: 0
        )

        saveQuizzes()

        print("========================================")
        print("✅ QUIZ CREATED")
        print("Title: \(finalTitle)")
        print("Questions: \(questions.count)")
        print("========================================")
    }

    // =====================================================
    // CREATE QUIZ FROM MEMORY
    // =====================================================

    func createFromMemory(
        _ memory: Memory
    ) {

        let answer = memory.summary
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        let finalAnswer = answer.isEmpty
            ? memory.content.trimmingCharacters(
                in: .whitespacesAndNewlines
            )
            : answer

        guard !finalAnswer.isEmpty else {
            print(
                "❌ Cannot create quiz: memory has no usable information."
            )
            return
        }

        let question = QuizQuestion(
            memoryID: memory.id,

            question:
                "What is the main idea of \(memory.title)?",

            options: makeLocalOptions(
                correctAnswer: finalAnswer
            ),

            correctAnswer: finalAnswer,

            explanation:
                "The correct answer is based on the information stored in this RecalllQ Memory."
        )

        createQuiz(
            title: "\(memory.title) Quiz",
            questions: [question],
            memoryID: memory.id
        )
    }

    // =====================================================
    // CREATE QUIZZES FROM MULTIPLE MEMORIES
    // =====================================================

    func createFromMemories(
        _ memories: [Memory]
    ) {

        guard !memories.isEmpty else {
            print(
                "❌ No memories available for quizzes."
            )
            return
        }

        for memory in memories {
            createFromMemory(memory)
        }

        print(
            "✅ Created quizzes from \(memories.count) memories."
        )
    }

    // =====================================================
    // GENERATE AI QUIZ FROM MEMORY
    // =====================================================

    func generateAIQuizFromMemory(
        _ memory: Memory,
        numberOfQuestions: Int = 5
    ) async {

        guard !isGeneratingAIQuiz else {
            print(
                "⚠️ AI quiz generation is already running."
            )
            return
        }

        guard numberOfQuestions > 0 else {
            aiQuizError =
                "Please generate at least one question."
            return
        }

        let title = memory.title
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        let content = memory.content
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        let summary = memory.summary
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        // -------------------------------------------------
        // VALIDATE TITLE
        // -------------------------------------------------

        guard !title.isEmpty else {
            aiQuizError =
                "This memory does not have a title."
            return
        }

        // -------------------------------------------------
        // VALIDATE CONTENT
        // -------------------------------------------------

        guard !content.isEmpty || !summary.isEmpty else {
            aiQuizError =
                "This memory does not contain enough information to create a quiz."
            return
        }

        isGeneratingAIQuiz = true
        aiQuizError = nil

        defer {
            isGeneratingAIQuiz = false
        }

        print("========================================")
        print("🤖 AI QUIZ GENERATION")
        print("========================================")
        print("Memory: \(title)")
        print("Questions requested: \(numberOfQuestions)")
        print("========================================")

        do {

            // =================================================
            // GENERATE USING QUIZ API SERVICE
            // =================================================

            let generatedQuestions =
                try await quizAPIService.generateQuiz(
                    from: memory,
                    numberOfQuestions: numberOfQuestions
                )

            guard !generatedQuestions.isEmpty else {
                throw QuizAPIService.QuizAPIError.emptyQuestions
            }

            // =================================================
            // CREATE QUIZ
            // =================================================

            createQuiz(
                title: "\(title) AI Quiz",
                questions: generatedQuestions,
                memoryID: memory.id
            )

            aiQuizError = nil

            print("========================================")
            print("✅ AI QUIZ CREATED")
            print("Questions: \(generatedQuestions.count)")
            print("========================================")

        } catch {

            // =================================================
            // LOCAL FALLBACK
            // =================================================

            print("========================================")
            print("⚠️ AI QUIZ GENERATION FAILED")
            print("Reason: \(error.localizedDescription)")
            print("🧠 Creating local fallback quiz...")
            print("========================================")

            createLocalFallbackQuiz(
                from: memory,
                numberOfQuestions: numberOfQuestions
            )
        }
    }

    // =====================================================
    // GENERATE AI QUIZ FROM MULTIPLE MEMORIES
    // =====================================================

    func generateAIQuizFromMemories(
        _ memories: [Memory],
        numberOfQuestions: Int = 5
    ) async {

        guard !memories.isEmpty else {
            aiQuizError =
                "No memories are available for the quiz."
            return
        }

        guard !isGeneratingAIQuiz else {
            print(
                "⚠️ AI quiz generation is already running."
            )
            return
        }

        guard numberOfQuestions > 0 else {
            aiQuizError =
                "Please generate at least one question."
            return
        }

        // -------------------------------------------------
        // CURRENT QUIZ SERVICE GENERATES FROM ONE MEMORY.
        //
        // We use the first valid memory so the AI receives
        // a focused and reliable source.
        // -------------------------------------------------

        guard let memory = memories.first else {
            aiQuizError =
                "No valid memory was found."
            return
        }

        await generateAIQuizFromMemory(
            memory,
            numberOfQuestions: numberOfQuestions
        )
    }

    // =====================================================
    // LOCAL FALLBACK QUIZ
    // =====================================================

    private func createLocalFallbackQuiz(
        from memory: Memory,
        numberOfQuestions: Int
    ) {

        var questions: [QuizQuestion] = []

        let summary = memory.summary
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        let content = memory.content
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        let finalAnswer = summary.isEmpty
            ? content
            : summary

        guard !finalAnswer.isEmpty else {

            aiQuizError =
                "This memory does not contain enough information to create a quiz."

            return
        }

        let questionTemplates = [

            (
                "What is the main idea of \(memory.title)?",
                QuizQuestion.Difficulty.medium
            ),

            (
                "What is the most important information about \(memory.title)?",
                QuizQuestion.Difficulty.medium
            ),

            (
                "Which statement best describes \(memory.title)?",
                QuizQuestion.Difficulty.easy
            ),

            (
                "What should you remember about \(memory.title)?",
                QuizQuestion.Difficulty.easy
            ),

            (
                "What does the memory explain about \(memory.title)?",
                QuizQuestion.Difficulty.hard
            )
        ]

        let count = min(
            max(numberOfQuestions, 1),
            questionTemplates.count
        )

        for index in 0..<count {

            let template =
                questionTemplates[index]

            let question = QuizQuestion(

                memoryID:
                    memory.id,

                question:
                    template.0,

                options:
                    makeLocalOptions(
                        correctAnswer:
                            finalAnswer
                    ),

                correctAnswer:
                    finalAnswer,

                explanation:
                    "This answer is based on the information stored in your RecalllQ Memory.",

                difficulty:
                    template.1
            )

            questions.append(
                question
            )
        }

        guard !questions.isEmpty else {

            aiQuizError =
                "Could not create quiz questions."

            return
        }

        createQuiz(
            title:
                "\(memory.title) Study Quiz",

            questions:
                questions,

            memoryID:
                memory.id
        )

        aiQuizError = nil

        print(
            "✅ Local fallback quiz created with \(questions.count) questions."
        )
    }

    // =====================================================
    // LOCAL OPTIONS
    // =====================================================

    private func makeLocalOptions(
        correctAnswer: String
    ) -> [String] {

        let incorrectAnswers = [

            "This information describes a different academic topic.",

            "This statement does not match the information in the memory.",

            "This interpretation is not supported by the memory."
        ]

        return (
            [correctAnswer] +
            incorrectAnswers
        ).shuffled()
    }

    // =====================================================
    // CLEAR AI ERROR
    // =====================================================

    func clearAIQuizError() {
        aiQuizError = nil
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

            print(
                "❌ Quiz not found."
            )

            return
        }

        var quiz =
            existingQuiz

        // -------------------------------------------------
        // RESET QUIZ STATE
        // -------------------------------------------------

        quiz.currentQuestionIndex = 0
        quiz.isCompleted = false
        quiz.score = 0

        for index in quiz.questions.indices {

            quiz.questions[index].selectedAnswer =
                nil
        }

        currentQuiz =
            quiz

        showResult =
            false

        saveCurrentQuiz()

        print(
            "▶️ Started quiz: \(quiz.title)"
        )
    }

    // =====================================================
    // START FIRST AVAILABLE QUIZ
    // =====================================================

    func startQuiz() {

        guard let firstQuiz =
                quizzes.first
        else {

            currentQuiz =
                nil

            showResult =
                false

            print(
                "❌ No quizzes available."
            )

            return
        }

        startQuiz(
            id:
                firstQuiz.id
        )
    }

    // =====================================================
    // CURRENT QUESTION
    // =====================================================

    var currentQuestion: QuizQuestion? {

        guard let quiz =
                currentQuiz
        else {
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
    // QUESTION NUMBER
    // =====================================================

    var currentQuestionNumber: Int {

        guard currentQuiz != nil else {
            return 0
        }

        return currentIndex + 1
    }

    // =====================================================
    // TOTAL QUESTIONS
    // =====================================================

    var totalQuestions: Int {
        currentQuiz?.totalQuestions ?? 0
    }

    // =====================================================
    // QUESTIONS
    // =====================================================

    var questions: [QuizQuestion] {
        currentQuiz?.questions ?? []
    }

    // =====================================================
    // ANSWERED QUESTIONS
    // =====================================================

    var answeredQuestions: Int {
        currentQuiz?.answeredQuestions ?? 0
    }

    // =====================================================
    // CORRECT ANSWERS
    // =====================================================

    var correctAnswers: Int {
        currentQuiz?.correctAnswers ?? 0
    }

    // =====================================================
    // INCORRECT ANSWERS
    // =====================================================

    var incorrectAnswers: Int {
        currentQuiz?.incorrectAnswers ?? 0
    }

    // =====================================================
    // SCORE
    // =====================================================

    var score: Int {
        currentQuiz?.score ?? 0
    }

    // =====================================================
    // SCORE PERCENTAGE
    // =====================================================

    var scorePercentage: Double {
        currentQuiz?.percentage ?? 0
    }

    // =====================================================
    // QUIZ PROGRESS
    // =====================================================

    var progress: Double {
        currentQuiz?.progress ?? 0
    }

    // =====================================================
    // QUIZ COMPLETE
    // =====================================================

    var isQuizComplete: Bool {
        currentQuiz?.isCompleted ?? false
    }

    // =====================================================
    // LAST QUESTION
    // =====================================================

    var isLastQuestion: Bool {
        currentQuiz?.isLastQuestion ?? false
    }

    // =====================================================
    // CURRENT QUESTION ANSWERED
    // =====================================================

    var hasAnsweredCurrentQuestion: Bool {
        currentQuiz?.hasAnsweredCurrentQuestion ?? false
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

        guard !isQuizComplete else {
            return
        }

        guard var quiz =
                currentQuiz
        else {
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

        let cleanedAnswer =
            answer.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        guard !cleanedAnswer.isEmpty else {
            return
        }

        quiz.questions[index].selectedAnswer =
            cleanedAnswer

        currentQuiz =
            quiz

        saveCurrentQuiz()
    }

    // =====================================================
    // SUBMIT ANSWER
    // =====================================================

    func submitAnswer() {

        guard !isQuizComplete else {
            return
        }

        guard !showResult else {
            return
        }

        guard var quiz =
                currentQuiz
        else {
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

            print(
                "⚠️ Please select an answer first."
            )

            return
        }

        quiz.updateScore()

        currentQuiz =
            quiz

        showResult =
            true

        saveCurrentQuiz()

        print(
            "📝 Answer submitted."
        )

        print(
            "Current score: \(quiz.score)/\(quiz.totalQuestions)"
        )
    }

    // =====================================================
    // NEXT QUESTION
    // =====================================================

    func nextQuestion() {

        guard var quiz =
                currentQuiz
        else {
            return
        }

        guard !quiz.isCompleted else {
            return
        }

        guard
            quiz.currentQuestionIndex >= 0,
            quiz.currentQuestionIndex < quiz.questions.count
        else {
            return
        }

        let currentIndex =
            quiz.currentQuestionIndex

        guard
            quiz.questions[currentIndex].isAnswered
        else {

            print(
                "⚠️ Please answer the current question first."
            )

            return
        }

        // =================================================
        // FINISH QUIZ
        // =================================================

        if currentIndex >=
            quiz.questions.count - 1 {

            quiz.updateScore()

            quiz.isCompleted =
                true

            currentQuiz =
                quiz

            showResult =
                true

            saveCurrentQuiz()

            appState?.recordQuizCompleted()

            print("========================================")
            print("🎉 QUIZ COMPLETED")
            print("Quiz: \(quiz.title)")
            print(
                "Score: \(quiz.score)/\(quiz.totalQuestions)"
            )
            print(
                "Percentage: \(Int(quiz.percentage))%"
            )
            print("========================================")

            return
        }

        // =================================================
        // MOVE TO NEXT QUESTION
        // =================================================

        quiz.currentQuestionIndex += 1

        currentQuiz =
            quiz

        showResult =
            false

        saveCurrentQuiz()

        print(
            "➡️ Moving to question \(quiz.currentQuestionIndex + 1)"
        )
    }

    // =====================================================
    // RESET CURRENT QUIZ
    // =====================================================

    func resetCurrentQuiz() {

        guard let quiz =
                currentQuiz
        else {
            return
        }

        startQuiz(
            id:
                quiz.id
        )
    }

    // =====================================================
    // RESTART QUIZ
    // =====================================================

    func restartQuiz() {
        resetCurrentQuiz()
    }

    // =====================================================
    // EXIT CURRENT QUIZ
    // =====================================================

    func exitQuiz() {

        currentQuiz =
            nil

        showResult =
            false

        print(
            "⏹️ Quiz session ended."
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

        if currentQuiz?.id == id {

            currentQuiz =
                nil

            showResult =
                false
        }

        saveQuizzes()

        print(
            "🗑️ Quiz deleted."
        )
    }

    // =====================================================
    // DELETE ALL QUIZZES
    // =====================================================

    func deleteAllQuizzes() {

        quizzes.removeAll()

        currentQuiz =
            nil

        showResult =
            false

        saveQuizzes()

        print(
            "🗑️ All quizzes deleted."
        )
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
    // UNCOMPLETED QUIZZES
    // =====================================================

    var incompleteQuizzes: Int {

        quizzes.filter {
            !$0.isCompleted
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

        return
            Double(totalCorrect)
            / Double(totalQuestions)
            * 100
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

        let percentages =
            completed.map {
                $0.percentage
            }

        let total =
            percentages.reduce(0, +)

        return
            total /
            Double(percentages.count)
    }

    // =====================================================
    // BEST SCORE
    // =====================================================

    var bestScore: Double {

        quizzes
            .filter {
                $0.isCompleted &&
                $0.totalQuestions > 0
            }
            .map {
                $0.percentage
            }
            .max() ?? 0
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

            quizzes[index] =
                currentQuiz

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

            let encoder =
                JSONEncoder()

            encoder.dateEncodingStrategy =
                .iso8601

            let data =
                try encoder.encode(
                    quizzes
                )

            UserDefaults.standard.set(
                data,
                forKey:
                    storageKey
            )

            print(
                "💾 Saved \(quizzes.count) quizzes."
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
                    forKey:
                        storageKey
                )
        else {

            quizzes = []

            print(
                "ℹ️ No saved quizzes found."
            )

            return
        }

        do {

            let decoder =
                JSONDecoder()

            decoder.dateDecodingStrategy =
                .iso8601

            quizzes =
                try decoder.decode(
                    [Quiz].self,
                    from:
                        data
                )

            print(
                "✅ Loaded \(quizzes.count) quizzes."
            )

        } catch {

            print(
                "❌ Could not load quizzes: \(error)"
            )

            quizzes = []
        }
    }
}

