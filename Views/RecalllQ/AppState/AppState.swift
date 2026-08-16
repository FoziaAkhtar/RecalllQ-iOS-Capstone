
import Foundation
import SwiftUI
import Combine

// =====================================================
// APP STATE
// =====================================================
// PURPOSE:
// Central source of truth for RecalllQ.
//
// RESPONSIBILITIES:
// - Manages global ViewModels
// - Connects Notes to Memories
// - Connects Memories to Flashcards
// - Connects Memories to AI Quiz Generation
// - Connects Flashcards to Quiz
// - Manages Study Sessions
// - Provides personalized recommendations
// - Controls main tab navigation
// - Opens specific flashcards from Smart Suggestions
// =====================================================

@MainActor
final class AppState: ObservableObject {

    // =====================================================
    // VIEW MODELS
    // =====================================================

    @Published var memoryViewModel: MemoryViewModel

    @Published var notesViewModel: NotesViewModel

    @Published var flashcardViewModel: FlashcardViewModel

    @Published var quizViewModel: QuizViewModel

    @Published var studySessionViewModel: StudySessionViewModel

    // =====================================================
    // MAIN TAB NAVIGATION
    // =====================================================

    // 0 = Dashboard
    // 1 = Notes
    // 2 = Memories
    // 3 = Flashcards
    // 4 = Quiz

    @Published var selectedTab: Int = 0

    // =====================================================
    // MEMORY ENGINE
    // =====================================================

    let memoryEngine: MemoryEngine

    // =====================================================
    // STUDY RECOMMENDATION SERVICE
    // =====================================================

    let studyRecommendationService:
        StudyRecommendationService

    // =====================================================
    // QUIZ API SERVICE
    // =====================================================

    let quizAPIService:
        QuizAPIService

    // =====================================================
    // AI QUIZ GENERATION STATE
    // =====================================================

    @Published var isGeneratingQuiz: Bool = false

    @Published var quizGenerationError: String?

    // =====================================================
    // PERSONALIZED RECOMMENDATIONS
    // =====================================================

    @Published var studyRecommendations:
        [StudyRecommendationService.Recommendation] = []

    // =====================================================
    // COMBINE
    // =====================================================

    private var cancellables =
        Set<AnyCancellable>()

    // =====================================================
    // INIT
    // =====================================================

    init() {

        // -------------------------------------------------
        // CREATE VIEW MODELS
        // -------------------------------------------------

        let memoryVM =
            MemoryViewModel()

        let notesVM =
            NotesViewModel()

        let flashcardVM =
            FlashcardViewModel()

        let quizVM =
            QuizViewModel()

        let studySessionVM =
            StudySessionViewModel()

        // -------------------------------------------------
        // ASSIGN VIEW MODELS
        // -------------------------------------------------

        self.memoryViewModel =
            memoryVM

        self.notesViewModel =
            notesVM

        self.flashcardViewModel =
            flashcardVM

        self.quizViewModel =
            quizVM

        self.studySessionViewModel =
            studySessionVM

        // -------------------------------------------------
        // CREATE SERVICES
        // -------------------------------------------------

        self.memoryEngine =
            MemoryEngine()

        self.studyRecommendationService =
            StudyRecommendationService()

        self.quizAPIService =
            QuizAPIService()

        // =================================================
        // CONNECT NOTES TO APP STATE
        // =================================================

        notesVM.appState =
            self

        // =================================================
        // CONNECT QUIZ VIEWMODEL TO APP STATE
        // =================================================

        quizVM.appState =
            self

        // =================================================
        // FORWARD MEMORY CHANGES
        // =================================================

        memoryVM.objectWillChange
            .sink { [weak self] _ in

                self?.objectWillChange.send()

                self?.generateStudyRecommendations()
            }
            .store(
                in: &cancellables
            )

        // =================================================
        // FORWARD NOTES CHANGES
        // =================================================

        notesVM.objectWillChange
            .sink { [weak self] _ in

                self?.objectWillChange.send()
            }
            .store(
                in: &cancellables
            )

        // =================================================
        // FORWARD FLASHCARD CHANGES
        // =================================================

        flashcardVM.objectWillChange
            .sink { [weak self] _ in

                self?.objectWillChange.send()

                self?.generateStudyRecommendations()
            }
            .store(
                in: &cancellables
            )

        // =================================================
        // FORWARD QUIZ CHANGES
        // =================================================

        quizVM.objectWillChange
            .sink { [weak self] _ in

                self?.objectWillChange.send()
            }
            .store(
                in: &cancellables
            )

        // =================================================
        // FORWARD STUDY SESSION CHANGES
        // =================================================

        studySessionVM.objectWillChange
            .sink { [weak self] _ in

                self?.objectWillChange.send()
            }
            .store(
                in: &cancellables
            )

        // =================================================
        // INITIAL RECOMMENDATIONS
        // =================================================

        generateStudyRecommendations()
    }

    // =====================================================
    // CREATE MEMORY FROM NOTE
    // =====================================================

    func createMemoryFromNote(
        title: String,
        content: String
    ) {

        let memory =
            memoryEngine.generateMemory(
                from: title,
                content: content
            )

        memoryViewModel.memories.insert(
            memory,
            at: 0
        )

        memoryViewModel.save()

        memoryViewModel.generateSuggestions()

        generateStudyRecommendations()

        NotificationCenter.default.post(
            name: .memoryCreatedFromNote,
            object: memory
        )
    }

    // =====================================================
    // CREATE FLASHCARD FROM MEMORY
    // =====================================================

    func createFlashcardFromMemory(
        _ memory: Memory
    ) {

        flashcardViewModel.createFromMemory(
            memory
        )

        generateStudyRecommendations()
    }

    // =====================================================
    // CREATE FLASHCARDS FROM ALL MEMORIES
    // =====================================================

    func createFlashcardsFromMemories() {

        flashcardViewModel.createFromMemories(
            memoryViewModel.memories
        )

        generateStudyRecommendations()
    }

    // =====================================================
    // COMPATIBILITY METHOD
    // =====================================================

    func createFlashcardsFromAllMemories() {

        createFlashcardsFromMemories()
    }

    // =====================================================
    // OPEN MEMORY IN FLASHCARDS
    // =====================================================

    func openMemoryInFlashcards(
        _ memory: Memory
    ) {

        print("========================================")
        print("🎯 OPENING SMART SUGGESTION")
        print("Memory: \(memory.title)")
        print("========================================")

        // -------------------------------------------------
        // FIND EXISTING FLASHCARD
        // -------------------------------------------------

        if let existingFlashcard =
            flashcardViewModel.flashcardForMemory(
                memory.id
            ) {

            print(
                "✅ Existing flashcard found."
            )

            flashcardViewModel.searchText = ""

            flashcardViewModel.selectFlashcard(
                id: existingFlashcard.id
            )

        } else {

            // -------------------------------------------------
            // CREATE FLASHCARD
            // -------------------------------------------------

            print(
                "ℹ️ No flashcard found."
            )

            print(
                "🧠 Creating flashcard automatically..."
            )

            flashcardViewModel.createFromMemory(
                memory
            )

            // -------------------------------------------------
            // FIND NEW FLASHCARD
            // -------------------------------------------------

            if let newFlashcard =
                flashcardViewModel.flashcardForMemory(
                    memory.id
                ) {

                flashcardViewModel.searchText = ""

                flashcardViewModel.selectFlashcard(
                    id: newFlashcard.id
                )

                print(
                    "✅ New flashcard created and selected."
                )

            } else {

                print(
                    "❌ Could not create flashcard."
                )

                return
            }
        }

        // -------------------------------------------------
        // SWITCH TO FLASHCARDS TAB
        // -------------------------------------------------

        selectedTab = 3

        print(
            "➡️ Switched to Flashcards tab."
        )

        print("========================================")
    }

    // =====================================================
    // OPEN FLASHCARD DIRECTLY
    // =====================================================

    func openFlashcard(
        _ flashcard: Flashcard
    ) {

        flashcardViewModel.searchText = ""

        flashcardViewModel.selectFlashcard(
            id: flashcard.id
        )

        selectedTab = 3
    }

    // =====================================================
    // GENERATE PERSONALIZED RECOMMENDATIONS
    // =====================================================

    func generateStudyRecommendations() {

        studyRecommendations =
            studyRecommendationService
                .generateRecommendations(
                    from:
                        memoryViewModel.memories,

                    flashcards:
                        flashcardViewModel.flashcards,

                    limit:
                        5
                )
    }

    // =====================================================
    // TOP RECOMMENDATION
    // =====================================================

    var topStudyRecommendation:
        StudyRecommendationService.Recommendation? {

        studyRecommendations.first
    }

    // =====================================================
    // START STUDY SESSION
    // =====================================================

    func startStudySession() {

        studySessionViewModel.startSession()
    }

    // =====================================================
    // END STUDY SESSION
    // =====================================================

    func endStudySession() {

        studySessionViewModel.endSession()
    }

    // =====================================================
    // CANCEL STUDY SESSION
    // =====================================================

    func cancelStudySession() {

        studySessionViewModel.cancelSession()
    }

    // =====================================================
    // RECORD FLASHCARD REVIEW
    // =====================================================

    func recordFlashcardReviewed() {

        studySessionViewModel.recordFlashcardReviewed()
    }

    // =====================================================
    // RECORD MEMORY STUDIED
    // =====================================================

    func recordMemoryStudied() {

        studySessionViewModel.recordMemoryStudied()
    }

    // =====================================================
    // RECORD QUIZ COMPLETION
    // =====================================================

    func recordQuizCompleted() {

        studySessionViewModel.recordQuizCompleted()
    }

    // =====================================================
    // START QUIZ FROM FLASHCARDS
    // =====================================================

    func startQuiz() {

        let flashcards =
            flashcardViewModel.flashcards

        guard !flashcards.isEmpty else {

            print(
                "❌ Cannot start quiz: no flashcards."
            )

            return
        }

        let questions:
            [QuizQuestion] =
                flashcards.map { flashcard in

                    let correctAnswer =
                        flashcard.answer

                    let incorrectAnswers = [

                        "None of the above.",

                        "This information is unrelated.",

                        "There is not enough information."
                    ]

                    let options =
                        (
                            [correctAnswer] +
                            incorrectAnswers
                        )
                        .shuffled()

                    return QuizQuestion(

                        memoryID:
                            flashcard.memoryID,

                        question:
                            flashcard.question,

                        options:
                            options,

                        correctAnswer:
                            correctAnswer,

                        explanation:
                            "The correct answer is based on your RecalllQ flashcard."
                    )
                }

        quizViewModel.createQuiz(
            title:
                "RecalllQ Study Quiz",

            questions:
                questions
        )

        // -------------------------------------------------
        // START NEW QUIZ
        // -------------------------------------------------

        if let quiz =
            quizViewModel.quizzes.first {

            quizViewModel.startQuiz(
                id:
                    quiz.id
            )

            selectedTab = 4
        }
    }

    // =====================================================
    // AI QUIZ FROM MEMORY
    // =====================================================

    func generateAIQuiz(
        from memory: Memory,
        numberOfQuestions: Int = 5
    ) {

        // -------------------------------------------------
        // PREVENT DUPLICATE REQUESTS
        // -------------------------------------------------

        guard !isGeneratingQuiz else {

            print(
                "⚠️ A quiz is already being generated."
            )

            return
        }

        // -------------------------------------------------
        // VALIDATE QUESTION COUNT
        // -------------------------------------------------

        let questionCount =
            max(
                1,
                min(
                    numberOfQuestions,
                    10
                )
            )

        // -------------------------------------------------
        // UPDATE UI STATE
        // -------------------------------------------------

        isGeneratingQuiz = true

        quizGenerationError = nil

        print("========================================")
        print("🤖 AI QUIZ GENERATION STARTED")
        print("Memory: \(memory.title)")
        print(
            "Questions requested: \(questionCount)"
        )
        print("========================================")

        // -------------------------------------------------
        // START ASYNC API REQUEST
        // -------------------------------------------------

        Task {

            do {

                let questions =
                    try await quizAPIService.generateQuiz(
                        from:
                            memory,

                        numberOfQuestions:
                            questionCount
                    )

                // -------------------------------------------------
                // VALIDATE RESULT
                // -------------------------------------------------

                guard !questions.isEmpty else {

                    throw QuizAPIService.QuizAPIError.emptyQuestions
                }

                // -------------------------------------------------
                // CREATE QUIZ
                // -------------------------------------------------

                quizViewModel.createQuiz(
                    title:
                        "\(memory.title) AI Quiz",

                    questions:
                        questions,

                    memoryID:
                        memory.id
                )

                // -------------------------------------------------
                // FIND NEWLY CREATED QUIZ
                // -------------------------------------------------

                guard
                    let quiz =
                        quizViewModel.quizzes.first
                else {

                    throw QuizAPIService.QuizAPIError.invalidData
                }

                // -------------------------------------------------
                // START QUIZ
                // -------------------------------------------------

                quizViewModel.startQuiz(
                    id:
                        quiz.id
                )

                // -------------------------------------------------
                // OPEN QUIZ TAB
                // -------------------------------------------------

                selectedTab = 4

                // -------------------------------------------------
                // CLEAR LOADING STATE
                // -------------------------------------------------

                isGeneratingQuiz = false

                quizGenerationError = nil

                print("========================================")
                print("✅ AI QUIZ GENERATED SUCCESSFULLY")
                print("Quiz: \(quiz.title)")
                print(
                    "Questions: \(questions.count)"
                )
                print("========================================")

            } catch {

                // -------------------------------------------------
                // ERROR
                // -------------------------------------------------

                isGeneratingQuiz = false

                quizGenerationError =
                    error.localizedDescription

                print("========================================")
                print("❌ AI QUIZ GENERATION FAILED")
                print(
                    "Error: \(error.localizedDescription)"
                )
                print("========================================")
            }
        }
    }

    // =====================================================
    // AI QUIZ FROM FIRST MEMORY
    // =====================================================

    func generateAIQuizFromFirstMemory() {

        guard
            let memory =
                memoryViewModel.memories.first
        else {

            quizGenerationError =
                "Create a memory first before generating an AI quiz."

            print(
                "❌ No memories available."
            )

            return
        }

        generateAIQuiz(
            from:
                memory,
            numberOfQuestions:
                5
        )
    }

    // =====================================================
    // CREATE QUIZ FROM ONE MEMORY
    // =====================================================

    func createQuizFromMemory(
        _ memory: Memory
    ) {

        quizViewModel.createFromMemory(
            memory
        )

        if let quiz =
            quizViewModel.quizzes.first {

            quizViewModel.startQuiz(
                id:
                    quiz.id
            )

            selectedTab = 4
        }
    }

    // =====================================================
    // CREATE QUIZZES FROM ALL MEMORIES
    // =====================================================

    func createQuizzesFromMemories() {

        quizViewModel.createFromMemories(
            memoryViewModel.memories
        )
    }

    // =====================================================
    // GENERATE AI QUIZ FROM MEMORIES
    // =====================================================

    func generateAIQuizFromMemories() {

        guard
            let memory =
                memoryViewModel.memories.first
        else {

            quizGenerationError =
                "Create a memory first before generating an AI quiz."

            print(
                "❌ No memories available for AI quiz."
            )

            return
        }

        generateAIQuiz(
            from:
                memory,
            numberOfQuestions:
                5
        )
    }
}
