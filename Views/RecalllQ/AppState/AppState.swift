
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
// - Connects NotesViewModel to AppState
// - Connects MemoryViewModel to AppState
// - Connects FlashcardViewModel to AppState
// - Creates memories from notes
// - Keeps RecalllQ architecture organized
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
// Memory
//   ↓
// FlashcardViewModel
//   ↓
// Flashcards
// =====================================================

final class AppState: ObservableObject {

    // =====================================================
    // MEMORY VIEW MODEL
    // =====================================================

    @Published var memoryViewModel: MemoryViewModel

    // =====================================================
    // NOTES VIEW MODEL
    // =====================================================

    @Published var notesViewModel: NotesViewModel

    // =====================================================
    // FLASHCARD VIEW MODEL
    // =====================================================

    @Published var flashcardViewModel: FlashcardViewModel

    // =====================================================
    // MEMORY ENGINE
    // =====================================================
    // Converts notes into structured memories.

    let memoryEngine: MemoryEngine

    // =====================================================
    // INIT
    // =====================================================

    init() {

        // =================================================
        // CREATE VIEW MODELS
        // =================================================

        let memoryVM =
            MemoryViewModel()

        let notesVM =
            NotesViewModel()

        let flashcardVM =
            FlashcardViewModel()

        // =================================================
        // ASSIGN VIEW MODELS
        // =================================================

        self.memoryViewModel =
            memoryVM

        self.notesViewModel =
            notesVM

        self.flashcardViewModel =
            flashcardVM

        // =================================================
        // CREATE MEMORY ENGINE
        // =================================================

        self.memoryEngine =
            MemoryEngine()

        // =================================================
        // CONNECT NOTES VIEW MODEL
        // =================================================

        notesVM.appState =
            self
    }

    // =====================================================
    // CREATE MEMORY FROM NOTE
    // =====================================================
    // Pipeline:
    //
    // Note
    //   ↓
    // MemoryEngine
    //   ↓
    // MemoryViewModel
    //   ↓
    // FlashcardViewModel
    //
    // A flashcard is NOT automatically created here yet.
    // The user can choose when to create flashcards.
    // =====================================================

    func createMemoryFromNote(
        title: String,
        content: String
    ) {

        // =================================================
        // GENERATE MEMORY
        // =================================================

        let memory =
            memoryEngine.generateMemory(
                from: title,
                content: content
            )

        // =================================================
        // ADD MEMORY
        // =================================================

        memoryViewModel.memories.insert(
            memory,
            at: 0
        )

        // =================================================
        // SAVE MEMORY
        // =================================================

        memoryViewModel.save()

        // =================================================
        // REFRESH MEMORY SUGGESTIONS
        // =================================================

        memoryViewModel.generateSuggestions()

        // =================================================
        // GLOBAL MEMORY EVENT
        // =================================================

        NotificationCenter.default.post(
            name: .memoryCreatedFromNote,
            object: memory
        )
    }

    // =====================================================
    // CREATE FLASHCARD FROM MEMORY
    // =====================================================
    // Convenience method for future buttons.
    //
    // Example:
    //
    // Create Flashcard
    //       ↓
    // AppState
    //       ↓
    // FlashcardViewModel
    // =====================================================

    func createFlashcardFromMemory(
        _ memory: Memory
    ) {

        flashcardViewModel
            .createFromMemory(memory)
    }

    // =====================================================
    // CREATE FLASHCARDS FROM ALL MEMORIES
    // =====================================================
    // Useful for a future:
    //
    // "Generate Flashcards"
    //
    // button.

    func createFlashcardsFromAllMemories() {

        flashcardViewModel
            .createFromMemories(
                memoryViewModel.memories
            )
    }
}
