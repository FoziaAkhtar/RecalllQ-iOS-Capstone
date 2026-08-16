
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
// - Connects Flashcards to Quiz
// - Manages Study Sessions
// - Provides personalized recommendations
// - Controls main tab navigation
// - Opens specific flashcards from Smart Suggestions
// =====================================================

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
    //
    // This allows Dashboard Smart Suggestions to switch
    // automatically to the Flashcards tab.
    // =====================================================

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
        // Create ViewModels
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
        // Assign ViewModels
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
        // Create Services
        // -------------------------------------------------

        self.memoryEngine =
            MemoryEngine()

        self.studyRecommendationService =
            StudyRecommendationService()

        // =================================================
        // CONNECT NOTES TO APP STATE
        // =================================================

        notesVM.appState =
            self

        // =================================================
        // FORWARD MEMORY VIEWMODEL CHANGES
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
        // FORWARD NOTES VIEWMODEL CHANGES
        // =================================================

        notesVM.objectWillChange
            .sink { [weak self] _ in

                self?.objectWillChange.send()
            }
            .store(
                in: &cancellables
            )

        // =================================================
        // FORWARD FLASHCARD VIEWMODEL CHANGES
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
        // FORWARD QUIZ VIEWMODEL CHANGES
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
    // THIS IS THE IMPORTANT NEW FUNCTION.
    //
    // Flow:
    //
    // Smart Suggestion
    //       ↓
    // Memory
    //       ↓
    // Find Flashcard
    //       ↓
    // If missing → create Flashcard
    //       ↓
    // Select Flashcard
    //       ↓
    // Switch to Flashcards tab
    //
    // =====================================================

    func openMemoryInFlashcards(
        _ memory: Memory
    ) {

        print("========================================")
        print("🎯 OPENING SMART SUGGESTION")
        print("Memory: \(memory.title)")
        print("========================================")

        // -------------------------------------------------
        // Find existing flashcard
        // -------------------------------------------------

        if let existingFlashcard =
            flashcardViewModel.flashcardForMemory(
                memory.id
            ) {

            print("✅ Existing flashcard found.")

            flashcardViewModel.searchText = ""

            flashcardViewModel.selectFlashcard(
                id: existingFlashcard.id
            )

        } else {

            // -------------------------------------------------
            // No flashcard exists.
            // Automatically create one.
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
            // Find the newly-created flashcard
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
        // Switch to Flashcards tab
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
                flashcards.map {
                    flashcard in

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

        if let quiz =
            quizViewModel.quizzes.first {

            quizViewModel.startQuiz(
                id:
                    quiz.id
            )
        }
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
}
