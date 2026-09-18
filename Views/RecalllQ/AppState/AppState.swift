import Foundation
import SwiftUI
import Combine

// =====================================================
// APP STATE
// =====================================================
//
// PURPOSE:
//
// Central source of truth for RecalllQ.
//
// RESPONSIBILITIES:
//
// - Manages global ViewModels
// - Connects Notes to Memories
// - Connects Memories to Flashcards
// - Connects Memories to AI Quiz Generation
// - Connects Flashcards to Quiz
// - Manages Study Sessions
// - Provides personalized recommendations
// - Controls main tab navigation
// - Opens specific flashcards from Smart Suggestions
// - Handles AI Memory API integration
// - Handles AI Quiz generation
// - Provides local AI fallback
// - Controls authentication state
// - Keeps each user's data separate
//
// IMPORTANT:
//
// Each authenticated user must have their own:
//
// - Notes
// - Memories
// - Flashcards
// - Quizzes
// - Study sessions
// - Progress
//
// Guest Mode also receives its own isolated local
// storage namespace and does not require personal
// information.
//
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
    // AUTHENTICATION STATE
    // =====================================================

    @Published var isAuthenticated: Bool = false

    // =====================================================
    // GUEST MODE
    // =====================================================

    @Published private(set) var isGuestUser: Bool = false

    // =====================================================
    // GUEST USER IDENTIFIER
    // =====================================================

    private let guestUserID = "__guest__"

    // =====================================================
    // CURRENT USER
    // =====================================================

    @Published private(set) var currentUserEmail: String?

    // =====================================================
    // MAIN TAB NAVIGATION
    // =====================================================
    //
    // 0 = Dashboard
    // 1 = Notes
    // 2 = Memories
    // 3 = Flashcards
    // 4 = Quiz
    //
    // =====================================================

    @Published var selectedTab: Int = 0

    // =====================================================
    // MEMORY ENGINE
    // =====================================================

    let memoryEngine: MemoryEngine

    // =====================================================
    // AI SERVICE
    // =====================================================

    let aiService: AIService

    // =====================================================
    // STUDY RECOMMENDATION SERVICE
    // =====================================================

    let studyRecommendationService: StudyRecommendationService

    // =====================================================
    // QUIZ API SERVICE
    // =====================================================

    let quizAPIService: QuizAPIService

    // =====================================================
    // AI QUIZ GENERATION STATE
    // =====================================================

    @Published var isGeneratingQuiz: Bool = false
    @Published var quizGenerationError: String?

    // =====================================================
    // AI MEMORY GENERATION STATE
    // =====================================================

    @Published var isGeneratingMemory: Bool = false
    @Published var memoryGenerationError: String?

    // =====================================================
    // PERSONALIZED RECOMMENDATIONS
    // =====================================================

    @Published var studyRecommendations:
        [StudyRecommendationService.Recommendation] = []

    // =====================================================
    // COMBINE
    // =====================================================

    private var cancellables = Set<AnyCancellable>()

    // =====================================================
    // INIT
    // =====================================================

    init() {

        let memoryVM = MemoryViewModel()
        let notesVM = NotesViewModel()
        let flashcardVM = FlashcardViewModel()
        let quizVM = QuizViewModel()
        let studySessionVM = StudySessionViewModel()

        self.memoryViewModel = memoryVM
        self.notesViewModel = notesVM
        self.flashcardViewModel = flashcardVM
        self.quizViewModel = quizVM
        self.studySessionViewModel = studySessionVM

        self.memoryEngine = MemoryEngine()

        self.aiService = AIService()

        self.studyRecommendationService =
            StudyRecommendationService()

        self.quizAPIService = QuizAPIService()

        // =================================================
        // CONNECT APP STATE
        // =================================================

        notesVM.appState = self

        // =================================================
        // CONNECT FLASHCARD VIEW MODEL
        // =================================================
        //
        // FlashcardViewModel uses AppState for:
        //
        // - Study session integration
        // - Progress tracking
        // - Flashcard review events
        //
        // =================================================

        flashcardVM.appState = self

        quizVM.appState = self

        // =================================================
        // MEMORY OBSERVER
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
        // NOTES OBSERVER
        // =================================================

        notesVM.objectWillChange
            .sink { [weak self] _ in

                self?.objectWillChange.send()
            }
            .store(
                in: &cancellables
            )

        // =================================================
        // FLASHCARD OBSERVER
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
        // QUIZ OBSERVER
        // =================================================

        quizVM.objectWillChange
            .sink { [weak self] _ in

                self?.objectWillChange.send()
            }
            .store(
                in: &cancellables
            )

        // =================================================
        // STUDY SESSION OBSERVER
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
    // CONTINUE AS GUEST
    // =====================================================

    func continueAsGuest() {

        clearAllUserData()

        isGuestUser = true
        isAuthenticated = true
        currentUserEmail = guestUserID

        UserDefaults.standard.set(
            guestUserID,
            forKey: "recalllq_account"
        )

        notesViewModel.switchUser(
            userID: guestUserID
        )

        memoryViewModel.switchUser(
            to: guestUserID
        )

        flashcardViewModel.switchUser(
            to: guestUserID
        )

        quizViewModel.switchUser(
            to: guestUserID
        )

        studySessionViewModel.switchUser(
            to: guestUserID
        )

        selectedTab = 0

        generateStudyRecommendations()

        print("========================================")
        print("👤 RECALLIQ GUEST MODE")
        print("========================================")
        print("🔓 No account credentials required.")
        print("🆔 Guest ID: \(guestUserID)")
        print("📝 Guest notes loaded.")
        print("🧠 Guest memories loaded.")
        print("🗂 Guest flashcards loaded.")
        print("❓ Guest quizzes loaded.")
        print("📊 Guest study data loaded.")
        print("🔐 Guest storage is isolated.")
        print("➡️ MainTabView is now active.")
        print("========================================")
    }

    // =====================================================
    // SWITCH TO GUEST MODE
    // =====================================================

    func switchToGuest() {

        if isAuthenticated {

            notesViewModel.saveNotes()
            memoryViewModel.save()
            flashcardViewModel.save()
            quizViewModel.save()
            studySessionViewModel.save()
        }

        clearAllUserData()

        isGuestUser = true
        isAuthenticated = true
        currentUserEmail = guestUserID

        UserDefaults.standard.set(
            guestUserID,
            forKey: "recalllq_account"
        )

        notesViewModel.switchUser(
            userID: guestUserID
        )

        memoryViewModel.switchUser(
            to: guestUserID
        )

        flashcardViewModel.switchUser(
            to: guestUserID
        )

        quizViewModel.switchUser(
            to: guestUserID
        )

        studySessionViewModel.switchUser(
            to: guestUserID
        )

        selectedTab = 0

        generateStudyRecommendations()

        print("========================================")
        print("🔄 SWITCHING TO RECALLIQ GUEST MODE")
        print("========================================")
        print("💾 Current user data saved.")
        print("🧹 Previous user data cleared from memory.")
        print("👤 Guest ID: \(guestUserID)")
        print("📝 Guest notes loaded.")
        print("🧠 Guest memories loaded.")
        print("🗂 Guest flashcards loaded.")
        print("❓ Guest quizzes loaded.")
        print("📊 Guest study data loaded.")
        print("🔐 User data remains isolated.")
        print("➡️ Guest Dashboard is now active.")
        print("========================================")
    }

    // =====================================================
    // SAVE CURRENT USER DATA
    // =====================================================

    private func saveCurrentUserData() {

        guard isAuthenticated else {
            return
        }

        notesViewModel.saveNotes()
        memoryViewModel.save()
        flashcardViewModel.save()
        quizViewModel.save()
        studySessionViewModel.save()

        print(
            "💾 Current user learning data saved before account switch."
        )
    }

    // =====================================================
    // LOGIN
    // =====================================================

    func login(
        email: String
    ) {

        let cleanEmail =
            email
                .trimmingCharacters(
                    in: .whitespacesAndNewlines
                )
                .lowercased()

        guard !cleanEmail.isEmpty else {

            print(
                "❌ Cannot login without an email."
            )

            return
        }

        if isAuthenticated {
            saveCurrentUserData()
        }

        isGuestUser = false

        clearAllUserData()

        currentUserEmail = cleanEmail

        UserDefaults.standard.set(
            cleanEmail,
            forKey: "recalllq_account"
        )

        notesViewModel.switchUser(
            userID: cleanEmail
        )

        memoryViewModel.switchUser(
            to: cleanEmail
        )

        flashcardViewModel.switchUser(
            to: cleanEmail
        )

        quizViewModel.switchUser(
            to: cleanEmail
        )

        studySessionViewModel.switchUser(
            to: cleanEmail
        )

        isAuthenticated = true

        selectedTab = 0

        generateStudyRecommendations()

        print("========================================")
        print("✅ USER AUTHENTICATED")
        print("========================================")
        print("👤 Current user: \(cleanEmail)")
        print("📝 User-specific notes loaded.")
        print("🧠 User-specific memories loaded.")
        print("🗂 User-specific flashcards loaded.")
        print("❓ User-specific quizzes loaded.")
        print("📊 User-specific study data loaded.")
        print("🔐 Account storage: \(cleanEmail)")
        print("➡️ MainTabView is now active.")
        print("========================================")
    }

    // =====================================================
    // CLEAR ALL USER DATA
    // =====================================================

    private func clearAllUserData() {

        notesViewModel.clearCurrentUserData()

        memoryViewModel.clearCurrentUserData()

        flashcardViewModel.clearCurrentUserData()

        quizViewModel.clearCurrentUserData()

        studySessionViewModel.clearCurrentUserData()

        studyRecommendations = []

        isGeneratingMemory = false

        memoryGenerationError = nil

        isGeneratingQuiz = false

        quizGenerationError = nil

        print(
            "🧹 All previous user data cleared from memory."
        )
    }

    // =====================================================
    // LOGOUT
    // =====================================================

    func logout() {

        if isAuthenticated {
            saveCurrentUserData()
        }

        clearAllUserData()

        isAuthenticated = false
        isGuestUser = false
        currentUserEmail = nil

        UserDefaults.standard.removeObject(
            forKey: "recalllq_account"
        )

        selectedTab = 0

        print("========================================")
        print("👋 USER LOGGED OUT")
        print("========================================")
        print("🧹 User data removed from active memory.")
        print("💾 Saved user files remain intact.")
        print("🔐 Active account cleared.")
        print("➡️ Returning to WelcomeView.")
        print("========================================")
    }

    // =====================================================
    // CREATE MEMORY FROM NOTE
    // =====================================================

    func createMemoryFromNote(
        title: String,
        content: String
    ) {

        let cleanedTitle =
            title.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        let cleanedContent =
            content.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        guard !cleanedTitle.isEmpty else {

            print(
                "❌ Cannot create Memory: empty title."
            )

            memoryGenerationError =
                "Please enter a title for your note."

            return
        }

        guard !cleanedContent.isEmpty else {

            print(
                "❌ Cannot create Memory: empty content."
            )

            memoryGenerationError =
                "Please enter some content for your note."

            return
        }

        guard isAuthenticated,
              let userID = currentUserEmail,
              !userID.isEmpty else {

            print(
                "❌ Cannot create Memory: no authenticated user."
            )

            memoryGenerationError =
                "Please sign in before creating learning content."

            return
        }

        if memoryViewModel.currentUserID != userID {

            memoryViewModel.switchUser(
                to: userID
            )
        }

        isGeneratingMemory = true
        memoryGenerationError = nil

        Task { @MainActor in

            do {

                print("========================================")
                print("🤖 RECALLIQ AI MEMORY PIPELINE")
                print("========================================")
                print("👤 User: \(userID)")
                print("Title: \(cleanedTitle)")
                print("Attempting AI memory generation...")
                print("========================================")

                let aiResponse =
                    try await aiService.generateMemory(
                        title: cleanedTitle,
                        content: cleanedContent
                    )

                let memory =
                    Memory(
                        title: cleanedTitle,
                        content: cleanedContent,
                        summary: aiResponse.summary,
                        tags: aiResponse.tags,
                        confidence: aiResponse.confidence,
                        importance: aiResponse.importance,
                        source: "ai"
                    )

                guard currentUserEmail == userID,
                      isAuthenticated else {

                    print(
                        "⚠️ User changed while AI memory was generating."
                    )

                    isGeneratingMemory = false

                    return
                }

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

                isGeneratingMemory = false

                memoryGenerationError = nil

                print("========================================")
                print("✅ AI MEMORY CREATED")
                print("========================================")
                print("👤 User:", userID)
                print("Memory:", memory.title)
                print("Source:", memory.source)
                print("Summary:", memory.summary)
                print("Tags:", memory.tags)
                print("Confidence:", memory.confidence)
                print("Importance:", memory.importance)
                print("========================================")

            } catch {

                print("========================================")
                print("⚠️ AI MEMORY GENERATION FAILED")
                print("========================================")
                print("Using local MemoryEngine fallback.")
                print("Reason:", error.localizedDescription)
                print("========================================")

                guard currentUserEmail == userID,
                      isAuthenticated else {

                    print(
                        "⚠️ User changed while AI request was running."
                    )

                    isGeneratingMemory = false

                    return
                }

                let memory =
                    memoryEngine.generateMemory(
                        from: cleanedTitle,
                        content: cleanedContent
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

                isGeneratingMemory = false

                memoryGenerationError = nil

                print("========================================")
                print("✅ LOCAL MEMORY CREATED")
                print("========================================")
                print("👤 User:", userID)
                print("Memory:", memory.title)
                print("Source:", memory.source)
                print("Summary:", memory.summary)
                print("Tags:", memory.tags)
                print("Confidence:", memory.confidence)
                print("Importance:", memory.importance)
                print("========================================")
            }
        }
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

        if let existingFlashcard =
            flashcardViewModel.flashcardForMemory(
                memory.id
            ) {

            flashcardViewModel.searchText = ""

            flashcardViewModel.selectFlashcard(
                id: existingFlashcard.id
            )

        } else {

            flashcardViewModel.createFromMemory(
                memory
            )

            if let newFlashcard =
                flashcardViewModel.flashcardForMemory(
                    memory.id
                ) {

                flashcardViewModel.searchText = ""

                flashcardViewModel.selectFlashcard(
                    id: newFlashcard.id
                )

            } else {

                print(
                    "❌ Could not create flashcard."
                )

                return
            }
        }

        selectedTab = 3
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

        guard isAuthenticated else {

            studyRecommendations = []

            return
        }

        studyRecommendations =
            studyRecommendationService.generateRecommendations(
                from: memoryViewModel.memories,
                flashcards: flashcardViewModel.flashcards,
                limit: 5
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

    //
    // Flashcards
    //      ↓
    // QuizQuestion
    //      ↓
    // createQuiz()
    //      ↓
    // Quiz
    //      ↓
    // startQuiz()
    //
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

        // =================================================
        // CREATE QUESTIONS
        // =================================================

        let questions: [QuizQuestion] =
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

        // =================================================
        // CREATE COMPLETE QUIZ
        // =================================================

        guard let quiz =
            quizViewModel.createQuiz(
                title: "RecalllQ Study Quiz",
                questions: questions
            )
        else {

            print(
                "❌ Quiz could not be created."
            )

            return
        }

        // =================================================
        // START NEWLY CREATED QUIZ
        // =================================================

        quizViewModel.startQuiz(
            quiz
        )

        // =================================================
        // OPEN QUIZ TAB
        // =================================================

        selectedTab = 4

        print("========================================")
        print("📝 RECALLIQ STUDY QUIZ STARTED")
        print("========================================")
        print("Quiz:", quiz.title)
        print("Questions:", quiz.questions.count)
        print("➡️ Quiz tab opened.")
        print("========================================")
    }

    // =====================================================
    // AI QUIZ FROM MEMORY
    // =====================================================

    //
    // QuizViewModel is responsible for:
    //
    // AI
    // ↓
    // [QuizQuestion]
    // ↓
    // Quiz
    // ↓
    // QuizStorageService
    //
    // AppState only handles authentication state
    // and navigation.
    //
    // =====================================================

    func generateAIQuiz(
        from memory: Memory,
        numberOfQuestions: Int = 5
    ) {

        guard !isGeneratingQuiz else {

            print(
                "⚠️ A quiz is already being generated."
            )

            return
        }

        guard isAuthenticated,
              currentUserEmail != nil else {

            print(
                "❌ Cannot generate quiz: no authenticated user."
            )

            quizGenerationError =
                "Please sign in before generating a quiz."

            return
        }

        // =================================================
        // LIMIT QUESTION COUNT
        // =================================================

        let questionCount =
            max(
                1,
                min(
                    numberOfQuestions,
                    10
                )
            )

        isGeneratingQuiz = true
        quizGenerationError = nil

        let userIDAtStart =
            currentUserEmail

        Task { @MainActor in

            // =============================================
            // VERIFY USER BEFORE GENERATION
            // =============================================

            guard isAuthenticated,
                  currentUserEmail == userIDAtStart else {

                print(
                    "⚠️ User changed before quiz generation started."
                )

                isGeneratingQuiz = false

                return
            }

            // =============================================
            // GENERATE AI QUIZ
            // =============================================

            await quizViewModel.generateAIQuizFromMemory(
                memory,
                numberOfQuestions: questionCount
            )

            // =============================================
            // VERIFY USER AFTER GENERATION
            // =============================================

            guard isAuthenticated,
                  currentUserEmail == userIDAtStart else {

                print(
                    "⚠️ User changed while quiz was generating."
                )

                isGeneratingQuiz = false

                return
            }

            // =============================================
            // CHECK AI QUIZ ERROR
            // =============================================

            if let error =
                quizViewModel.aiQuizError {

                quizGenerationError =
                    error

                print(
                    "⚠️ QuizViewModel reported: \(error)"
                )

                isGeneratingQuiz = false

                return
            }

            // =============================================
            // GET GENERATED QUIZ
            // =============================================

            guard let quiz =
                quizViewModel.currentQuiz else {

                print(
                    "⚠️ No generated quiz is currently open."
                )

                quizGenerationError =
                    "The quiz could not be created."

                isGeneratingQuiz = false

                return
            }

            // =============================================
            // OPEN QUIZ TAB
            // =============================================

            selectedTab = 4

            // =============================================
            // RESET GENERATION STATE
            // =============================================

            isGeneratingQuiz = false
            quizGenerationError = nil

            // =============================================
            // LOG
            // =============================================

            print("========================================")
            print("✅ AI QUIZ READY")
            print("========================================")

            print(
                "👤 User:",
                userIDAtStart ?? "unknown"
            )

            print(
                "Quiz:",
                quiz.title
            )

            print(
                "Questions:",
                quiz.questions.count
            )

            print(
                "➡️ Quiz tab opened."
            )

            print("========================================")
        }
    }

    // =====================================================
    // AI QUIZ FROM FIRST MEMORY
    // =====================================================

    func generateAIQuizFromFirstMemory() {

        guard let memory =
            memoryViewModel.memories.first else {

            quizGenerationError =
                "Create a memory first before generating an AI quiz."

            return
        }

        generateAIQuiz(
            from: memory,
            numberOfQuestions: 5
        )
    }

    // =====================================================
    // CREATE QUIZ FROM ONE MEMORY
    // =====================================================

    //
    // PURPOSE:
    //
    // Creates a local quiz from one Memory.
    //
    // QuizViewModel requires:
    //
    //     Memory
    //     title
    //     questions
    //
    // =====================================================

    func createQuizFromMemory(
        _ memory: Memory
    ) {

        // =================================================
        // DETERMINE CORRECT ANSWER
        // =================================================

        let cleanedSummary =
            memory.summary
                .trimmingCharacters(
                    in: .whitespacesAndNewlines
                )

        let cleanedContent =
            memory.content
                .trimmingCharacters(
                    in: .whitespacesAndNewlines
                )

        let correctAnswer =
            cleanedSummary.isEmpty
            ? cleanedContent
            : cleanedSummary

        // =================================================
        // VALIDATE ANSWER
        // =================================================

        guard !correctAnswer.isEmpty else {

            print(
                "❌ Cannot create quiz: memory has no content."
            )

            quizGenerationError =
                "This memory does not contain enough information to create a quiz."

            return
        }

        // =================================================
        // CREATE INCORRECT ANSWERS
        // =================================================

        let incorrectAnswers = [
            "This information is unrelated.",
            "There is not enough information.",
            "None of the above."
        ]

        // =================================================
        // CREATE OPTIONS
        // =================================================

        let options =
            (
                [correctAnswer] +
                incorrectAnswers
            )
            .shuffled()

        // =================================================
        // CREATE QUESTION
        // =================================================

        let question =
            QuizQuestion(
                memoryID:
                    memory.id,
                question:
                    "What is the main idea of \(memory.title)?",
                options:
                    options,
                correctAnswer:
                    correctAnswer,
                explanation:
                    "The correct answer is based on the selected RecalllQ memory."
            )

        // =================================================
        // CREATE QUIZ
        // =================================================

        guard let quiz =
            quizViewModel.createFromMemory(
                memory,
                title: "Quiz: \(memory.title)",
                questions: [question]
            )
        else {

            print(
                "❌ Quiz could not be created from memory."
            )

            quizGenerationError =
                "The quiz could not be created."

            return
        }

        // =================================================
        // START QUIZ
        // =================================================

        quizViewModel.startQuiz(
            quiz
        )

        // =================================================
        // OPEN QUIZ TAB
        // =================================================

        selectedTab = 4

        // =================================================
        // LOG
        // =================================================

        print("========================================")
        print("🧠 MEMORY QUIZ CREATED")
        print("========================================")

        print(
            "Memory:",
            memory.title
        )

        print(
            "Quiz:",
            quiz.title
        )

        print(
            "Questions:",
            quiz.questions.count
        )

        print(
            "➡️ Quiz tab opened."
        )

        print("========================================")
    }

    // =====================================================
    // CREATE QUIZZES FROM ALL MEMORIES
    // =====================================================

    //
    // PURPOSE:
    //
    // Creates one quiz containing one question for
    // each available memory.
    //
    // =====================================================

    func createQuizzesFromMemories() {

        let memories =
            memoryViewModel.memories

        // =================================================
        // VALIDATE MEMORIES
        // =================================================

        guard !memories.isEmpty else {

            print(
                "❌ Cannot create quiz: no memories available."
            )

            quizGenerationError =
                "Create a memory first before creating a quiz."

            return
        }

        // =================================================
        // CREATE QUESTIONS
        // =================================================

        let questions: [QuizQuestion] =
            memories.compactMap { memory in

                let cleanedSummary =
                    memory.summary
                        .trimmingCharacters(
                            in: .whitespacesAndNewlines
                        )

                let cleanedContent =
                    memory.content
                        .trimmingCharacters(
                            in: .whitespacesAndNewlines
                        )

                let correctAnswer =
                    cleanedSummary.isEmpty
                    ? cleanedContent
                    : cleanedSummary

                guard !correctAnswer.isEmpty else {
                    return nil
                }

                let incorrectAnswers = [
                    "This information is unrelated.",
                    "There is not enough information.",
                    "None of the above."
                ]

                let options =
                    (
                        [correctAnswer] +
                        incorrectAnswers
                    )
                    .shuffled()

                return QuizQuestion(
                    memoryID:
                        memory.id,
                    question:
                        "What is the main idea of \(memory.title)?",
                    options:
                        options,
                    correctAnswer:
                        correctAnswer,
                    explanation:
                        "The correct answer is based on the saved RecalllQ memory."
                )
            }

        // =================================================
        // VALIDATE QUESTIONS
        // =================================================

        guard !questions.isEmpty else {

            print(
                "❌ Cannot create quiz: no valid questions."
            )

            quizGenerationError =
                "Your memories do not contain enough information to create a quiz."

            return
        }

        // =================================================
        // CREATE COMPLETE QUIZ
        // =================================================

        guard let quiz =
            quizViewModel.createFromMemories(
                memories,
                title: "RecalllQ Memory Quiz",
                questions: questions
            )
        else {

            print(
                "❌ Quiz could not be created."
            )

            quizGenerationError =
                "The quiz could not be created."

            return
        }

        // =================================================
        // START QUIZ
        // =================================================

        quizViewModel.startQuiz(
            quiz
        )

        // =================================================
        // OPEN QUIZ TAB
        // =================================================

        selectedTab = 4

        // =================================================
        // LOG
        // =================================================

        print("========================================")
        print("🧠 MEMORY QUIZ STARTED")
        print("========================================")

        print(
            "Quiz:",
            quiz.title
        )

        print(
            "Questions:",
            quiz.questions.count
        )

        print(
            "➡️ Quiz tab opened."
        )

        print("========================================")
    }

    // =====================================================
    // GENERATE AI QUIZ FROM MEMORIES
    // =====================================================

    func generateAIQuizFromMemories() {

        guard let memory =
            memoryViewModel.memories.first else {

            quizGenerationError =
                "Create a memory first before generating an AI quiz."

            return
        }

        generateAIQuiz(
            from: memory,
            numberOfQuestions: 5
        )
    }
}
