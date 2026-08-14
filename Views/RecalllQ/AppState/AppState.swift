
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
// - Provides centralized Memory creation
// - Keeps the application architecture organized
//
// DATA FLOW:
//
// NotesView
//      ↓
// NotesViewModel
//      ↓
// AppState
//      ↓
// MemoryEngine
//      ↓
// MemoryViewModel
//      ↓
// Memories
// =====================================================

final class AppState: ObservableObject {

    // =====================================================
    // SINGLE SOURCE OF TRUTH
    // =====================================================
    // These ViewModels are shared throughout the application.
    // Views access them through @EnvironmentObject.
// =====================================================

    @Published var memoryViewModel: MemoryViewModel

    @Published var notesViewModel: NotesViewModel

    // =====================================================
    // MEMORY ENGINE
    // =====================================================
    // Responsible for converting notes into structured
    // AI-style memories.
    //
    // This is local intelligence and does not require
    // an external API or internet connection.
    // =====================================================

    let memoryEngine: MemoryEngine

    // =====================================================
    // INIT
    // =====================================================
    // Creates the application's ViewModels and connects
    // them to the central AppState.
    // =====================================================

    init() {

        // =================================================
        // CREATE VIEW MODELS
        // =================================================

        let memoryVM =
            MemoryViewModel()

        let notesVM =
            NotesViewModel()

        // =================================================
        // ASSIGN VIEW MODELS
        // =================================================

        self.memoryViewModel =
            memoryVM

        self.notesViewModel =
            notesVM

        // =================================================
        // CREATE MEMORY ENGINE
        // =================================================

        self.memoryEngine =
            MemoryEngine()

        // =================================================
        // CONNECT NOTES VIEW MODEL
        // =================================================
        // This allows NotesViewModel to call:
        //
        // appState?.createMemoryFromNote(...)
        //
        // when a new note is created.
        // =================================================

        notesVM.appState =
            self
    }

    // =====================================================
    // CENTRALIZED MEMORY CREATION PIPELINE
    // =====================================================
    // Converts a note into a structured Memory object.
    //
    // PIPELINE:
    //
    // Note
    //   ↓
    // MemoryEngine
    //   ↓
    // Structured Memory
    //   ↓
    // MemoryViewModel
    //   ↓
    // Save
    //   ↓
    // Refresh Suggestions
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
        // Lets other parts of RecalllQ know that a new
        // memory was created from a note.
        // =================================================

        NotificationCenter.default.post(
            name: .memoryCreatedFromNote,
            object: memory
        )
    }
}
