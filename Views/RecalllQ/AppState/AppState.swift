
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
    // CURRENT USER
    // =====================================================

    // The currently authenticated user's email.
    //
    // The normalized email is used as the local
    // unique user identifier.

    @Published private(set) var currentUserEmail: String?

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

        // =================================================
        // CREATE VIEW MODELS
        // =================================================

        let memoryVM = MemoryViewModel()
        let notesVM = NotesViewModel()
        let flashcardVM = FlashcardViewModel()
        let quizVM = QuizViewModel()
        let studySessionVM = StudySessionViewModel()

        // =================================================
        // ASSIGN VIEW MODELS
        // =================================================

        self.memoryViewModel = memoryVM
        self.notesViewModel = notesVM
        self.flashcardViewModel = flashcardVM
        self.quizViewModel = quizVM
        self.studySessionViewModel = studySessionVM

        // =================================================
        // CREATE SERVICES
        // =================================================

        self.memoryEngine = MemoryEngine()
        self.aiService = AIService()
        self.studyRecommendationService =
            StudyRecommendationService()
        self.quizAPIService = QuizAPIService()

        // =================================================
        // CONNECT NOTES TO APP STATE
        // =================================================

        notesVM.appState = self

        // =================================================
        // CONNECT QUIZ VIEW MODEL TO APP STATE
        // =================================================

        quizVM.appState = self

        // =================================================
        // FORWARD MEMORY CHANGES
        // =================================================

        memoryVM.objectWillChange
            .sink { [weak self] _ in

                self?.objectWillChange.send()

                self?.generateStudyRecommendations()
            }
            .store(in: &cancellables)

        // =================================================
        // FORWARD NOTES CHANGES
        // =================================================

        notesVM.objectWillChange
            .sink { [weak self] _ in

                self?.objectWillChange.send()
            }
            .store(in: &cancellables)

        // =================================================
        // FORWARD FLASHCARD CHANGES
        // =================================================

        flashcardVM.objectWillChange
            .sink { [weak self] _ in

                self?.objectWillChange.send()

                self?.generateStudyRecommendations()
            }
            .store(in: &cancellables)

        // =================================================
        // FORWARD QUIZ CHANGES
        // =================================================

        quizVM.objectWillChange
            .sink { [weak self] _ in

                self?.objectWillChange.send()
            }
            .store(in: &cancellables)

        // =================================================
        // FORWARD STUDY SESSION CHANGES
        // =================================================

        studySessionVM.objectWillChange
            .sink { [weak self] _ in

                self?.objectWillChange.send()
            }
            .store(in: &cancellables)

        // =================================================
        // INITIAL RECOMMENDATIONS
        // =================================================

        generateStudyRecommendations()
    }

    // =====================================================
    // LOGIN
    // =====================================================

    func login(email: String) {

        // =================================================
        // CLEAN EMAIL
        // =================================================

        let cleanEmail = email
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )
            .lowercased()

        guard !cleanEmail.isEmpty else {

            print("❌ Cannot login without an email.")

            return
        }

        // =================================================
        // IMPORTANT SECURITY STEP
        // =================================================
        //
        // Remove the previous user's data from the active
        // ViewModels before loading the new account.
        //
        // =================================================

        clearAllUserData()

        // =================================================
        // SET CURRENT USER
        // =================================================

        currentUserEmail = cleanEmail

        // =================================================
        // SAVE CURRENT ACCOUNT
        // =================================================

        UserDefaults.standard.set(
            cleanEmail,
            forKey: "recalllq_account"
        )

        // =================================================
        // LOAD USER-SPECIFIC NOTES
        // =================================================

        notesViewModel.switchUser(
            userID: cleanEmail
        )

        // =================================================
        // LOAD USER-SPECIFIC MEMORIES
        // =================================================

        memoryViewModel.switchUser(
            to: cleanEmail
        )

        // =================================================
        // LOAD USER-SPECIFIC FLASHCARDS
        // =================================================

        flashcardViewModel.switchUser(
            to: cleanEmail
        )

        // =================================================
        // LOAD USER-SPECIFIC QUIZZES
        // =================================================

        quizViewModel.switchUser(
            to: cleanEmail
        )

        // =================================================
        // LOAD USER-SPECIFIC STUDY SESSION DATA
        // =================================================

        studySessionViewModel.switchUser(
            to: cleanEmail
        )

        // =================================================
        // AUTHENTICATE
        // =================================================

        isAuthenticated = true

        selectedTab = 0

        // =================================================
        // UPDATE RECOMMENDATIONS
        // =================================================

        generateStudyRecommendations()

        // =================================================
        // LOG
        // =================================================

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

        // =================================================
        // NOTES
        // =================================================

        notesViewModel.clearCurrentUserData()

        // =================================================
        // MEMORIES
        // =================================================

        memoryViewModel.clearCurrentUserData()

        // =================================================
        // FLASHCARDS
        // =================================================

        flashcardViewModel.clearCurrentUserData()

        // =================================================
        // QUIZZES
        // =================================================

        quizViewModel.clearCurrentUserData()

        // =================================================
        // STUDY SESSIONS
        // =================================================

        studySessionViewModel.clearCurrentUserData()

        // =================================================
        // RECOMMENDATIONS
        // =================================================

        studyRecommendations = []

        // =================================================
        // AI STATES
        // =================================================

        isGeneratingMemory = false
        memoryGenerationError = nil

        isGeneratingQuiz = false
        quizGenerationError = nil

        // =================================================
        // LOG
        // =================================================

        print(
            "🧹 All previous user data cleared from memory."
        )
    }

    // =====================================================
    // LOGOUT
    // =====================================================

    func logout() {

        // =================================================
        // SAVE CURRENT USER'S DATA
        // =================================================

        if isAuthenticated {

            notesViewModel.saveNotes()

            memoryViewModel.save()

            flashcardViewModel.save()

            quizViewModel.save()

            studySessionViewModel.save()
        }

        // =================================================
        // CLEAR ALL USER DATA FROM MEMORY
        // =================================================

        clearAllUserData()

        // =================================================
        // CLEAR AUTHENTICATION
        // =================================================

        isAuthenticated = false

        currentUserEmail = nil

        // =================================================
        // REMOVE ACTIVE ACCOUNT
        // =================================================

        UserDefaults.standard.removeObject(
            forKey: "recalllq_account"
        )

        // =================================================
        // RESET NAVIGATION
        // =================================================

        selectedTab = 0

        // =================================================
        // LOG
        // =================================================

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

        // =================================================
        // CLEAN INPUT
        // =================================================

        let cleanedTitle =
            title.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        let cleanedContent =
            content.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        // =================================================
        // VALIDATE TITLE
        // =================================================

        guard !cleanedTitle.isEmpty else {

            print(
                "❌ Cannot create Memory: empty title."
            )

            memoryGenerationError =
                "Please enter a title for your note."

            return
        }

        // =================================================
        // VALIDATE CONTENT
        // =================================================

        guard !cleanedContent.isEmpty else {

            print(
                "❌ Cannot create Memory: empty content."
            )

            memoryGenerationError =
                "Please enter some content for your note."

            return
        }

        // =================================================
        // REQUIRE AUTHENTICATED USER
        // =================================================

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

        // =================================================
        // MAKE SURE MEMORY VIEW MODEL IS USING CURRENT USER
        // =================================================

        if memoryViewModel.currentUserID != userID {

            memoryViewModel.switchUser(
                to: userID
            )
        }

        // =================================================
        // RESET STATE
        // =================================================

        isGeneratingMemory = true
        memoryGenerationError = nil

        // =================================================
        // AI MEMORY GENERATION
        // =================================================

        Task { @MainActor in

            do {

                print("========================================")
                print("🤖 RECALLlQ AI MEMORY PIPELINE")
                print("========================================")
                print("👤 User: \(userID)")
                print("Title: \(cleanedTitle)")
                print("Attempting AI memory generation...")
                print("========================================")

                // =============================================
                // CALL AI SERVICE
                // =============================================

                let aiResponse =
                    try await aiService.generateMemory(
                        title: cleanedTitle,
                        content: cleanedContent
                    )

                // =============================================
                // CREATE MEMORY
                // =============================================

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

                // =============================================
                // VERIFY USER DID NOT CHANGE
                // =============================================

                guard currentUserEmail == userID,
                      isAuthenticated else {

                    print(
                        "⚠️ User changed while AI memory was generating."
                    )

                    isGeneratingMemory = false

                    return
                }

                // =============================================
                // SAVE MEMORY
                // =============================================

                memoryViewModel.memories.insert(
                    memory,
                    at: 0
                )

                memoryViewModel.save()

                // =============================================
                // UPDATE SUGGESTIONS
                // =============================================

                memoryViewModel.generateSuggestions()

                // =============================================
                // UPDATE RECOMMENDATIONS
                // =============================================

                generateStudyRecommendations()

                // =============================================
                // NOTIFY APP
                // =============================================

                NotificationCenter.default.post(
                    name: .memoryCreatedFromNote,
                    object: memory
                )

                // =============================================
                // CLEAR STATE
                // =============================================

                isGeneratingMemory = false
                memoryGenerationError = nil

                // =============================================
                // SUCCESS LOG
                // =============================================

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

                // =============================================
                // AI FAILED
                // =============================================

                print("========================================")
                print("⚠️ AI MEMORY GENERATION FAILED")
                print("========================================")

                print(
                    "Using local MemoryEngine fallback."
                )

                print(
                    "Reason:",
                    error.localizedDescription
                )

                print("========================================")

                // =============================================
                // VERIFY USER DID NOT CHANGE
                // =============================================

                guard currentUserEmail == userID,
                      isAuthenticated else {

                    print(
                        "⚠️ User changed while AI request was running."
                    )

                    isGeneratingMemory = false

                    return
                }

                // =============================================
                // LOCAL FALLBACK
                // =============================================

                let memory =
                    memoryEngine.generateMemory(
                        from: cleanedTitle,
                        content: cleanedContent
                    )

                // =============================================
                // SAVE LOCAL MEMORY
                // =============================================

                memoryViewModel.memories.insert(
                    memory,
                    at: 0
                )

                memoryViewModel.save()

                // =============================================
                // UPDATE SUGGESTIONS
                // =============================================

                memoryViewModel.generateSuggestions()

                // =============================================
                // UPDATE RECOMMENDATIONS
                // =============================================

                generateStudyRecommendations()

                // =============================================
                // NOTIFY APP
                // =============================================

                NotificationCenter.default.post(
                    name: .memoryCreatedFromNote,
                    object: memory
                )

                // =============================================
                // UPDATE STATE
                // =============================================

                isGeneratingMemory = false
                memoryGenerationError = nil

                // =============================================
                // SUCCESSFUL FALLBACK LOG
                // =============================================

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
        // CREATE QUIZ
        // =================================================

        quizViewModel.createQuiz(
            title: "RecalllQ Study Quiz",
            questions: questions
        )

        // =================================================
        // START QUIZ
        // =================================================

        if let quiz =
            quizViewModel.quizzes.first {

            quizViewModel.startQuiz(
                id: quiz.id
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

        guard !isGeneratingQuiz else {

            print(
                "⚠️ A quiz is already being generated."
            )

            return
        }

        guard isAuthenticated,
              let userID = currentUserEmail else {

            print(
                "❌ Cannot generate quiz: no authenticated user."
            )

            quizGenerationError =
                "Please sign in before generating a quiz."

            return
        }

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

        Task { @MainActor in

            do {

                let questions =
                    try await quizAPIService.generateQuiz(
                        from: memory,
                        numberOfQuestions: questionCount
                    )

                // =============================================
                // VERIFY USER IS STILL LOGGED IN
                // =============================================

                guard isAuthenticated,
                      currentUserEmail == userID else {

                    print(
                        "⚠️ User changed while quiz was generating."
                    )

                    isGeneratingQuiz = false

                    return
                }

                guard !questions.isEmpty else {

                    throw QuizAPIService
                        .QuizAPIError
                        .emptyQuestions
                }

                // =============================================
                // CREATE QUIZ
                // =============================================

                quizViewModel.createQuiz(
                    title: "\(memory.title) AI Quiz",
                    questions: questions,
                    memoryID: memory.id
                )

                // =============================================
                // FIND CREATED QUIZ
                // =============================================

                guard let quiz =
                    quizViewModel.quizzes.first else {

                    throw QuizAPIService
                        .QuizAPIError
                        .invalidData
                }

                // =============================================
                // START QUIZ
                // =============================================

                quizViewModel.startQuiz(
                    id: quiz.id
                )

                selectedTab = 4

                isGeneratingQuiz = false
                quizGenerationError = nil

            } catch {

                print("========================================")
                print("❌ AI QUIZ GENERATION FAILED")
                print("========================================")

                print(
                    "Reason:",
                    error.localizedDescription
                )

                print("========================================")

                isGeneratingQuiz = false

                quizGenerationError =
                    error.localizedDescription
            }
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

    func createQuizFromMemory(
        _ memory: Memory
    ) {

        quizViewModel.createFromMemory(
            memory
        )

        if let quiz =
            quizViewModel.quizzes.first {

            quizViewModel.startQuiz(
                id: quiz.id
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
