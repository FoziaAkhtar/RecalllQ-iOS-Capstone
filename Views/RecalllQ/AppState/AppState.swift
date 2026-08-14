
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
// - Keeps SwiftUI UI synchronized with ViewModels
//
// DATA FLOW:
//
// Notes
//   ↓
// NotesViewModel
//   ↓
// AppState
//   ↓
// MemoryEngine
//   ↓
// MemoryViewModel
//   ↓
// Memories
//   ↓
// FlashcardViewModel
//   ↓
// Flashcards
//   ↓
// QuizViewModel
//   ↓
// Quiz
// =====================================================

final class AppState: ObservableObject {

    // =====================================================
    // VIEW MODELS
    // =====================================================

    @Published var memoryViewModel: MemoryViewModel

    @Published var notesViewModel: NotesViewModel

    @Published var flashcardViewModel: FlashcardViewModel

    @Published var quizViewModel: QuizViewModel

    // =====================================================
    // MEMORY ENGINE
    // =====================================================

    let memoryEngine: MemoryEngine

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

        self.memoryViewModel = memoryVM
        self.notesViewModel = notesVM
        self.flashcardViewModel = flashcardVM
        self.quizViewModel = quizVM

        self.memoryEngine = MemoryEngine()

        // =================================================
        // CONNECT NOTES TO APP STATE
        // =================================================

        notesVM.appState = self

        // =================================================
        // IMPORTANT:
        // FORWARD VIEWMODEL CHANGES TO APPSTATE
        // =================================================
        //
        // SwiftUI observes AppState.
        //
        // FlashcardViewModel also publishes changes.
        //
        // This forwards those changes so views using
        // AppState refresh immediately.
        // =================================================

        memoryVM.objectWillChange
            .sink { [weak self] _ in

                self?.objectWillChange.send()

            }
            .store(
                in: &cancellables
            )

        notesVM.objectWillChange
            .sink { [weak self] _ in

                self?.objectWillChange.send()

            }
            .store(
                in: &cancellables
            )

        flashcardVM.objectWillChange
            .sink { [weak self] _ in

                self?.objectWillChange.send()

            }
            .store(
                in: &cancellables
            )

        quizVM.objectWillChange
            .sink { [weak self] _ in

                self?.objectWillChange.send()

            }
            .store(
                in: &cancellables
            )
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

        NotificationCenter.default.post(
            name: .memoryCreatedFromNote,
            object: memory
        )
    }

    // =====================================================
    // CREATE FLASHCARD FROM ONE MEMORY
    // =====================================================

    func createFlashcardFromMemory(
        _ memory: Memory
    ) {

        flashcardViewModel.createFromMemory(
            memory
        )
    }

    // =====================================================
    // CREATE FLASHCARDS FROM ALL MEMORIES
    // =====================================================

    func createFlashcardsFromMemories() {

        flashcardViewModel.createFromMemories(
            memoryViewModel.memories
        )
    }

    // =====================================================
    // COMPATIBILITY METHOD
    // =====================================================

    func createFlashcardsFromAllMemories() {

        createFlashcardsFromMemories()
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
        // CREATE QUIZ QUESTIONS
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
                    ).shuffled()

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
        // START NEWLY CREATED QUIZ
        // =================================================

        if let quiz =
            quizViewModel.quizzes.first {

            quizViewModel.startQuiz(
                id: quiz.id
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
                id: quiz.id
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

