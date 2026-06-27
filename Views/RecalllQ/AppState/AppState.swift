
import Foundation
import SwiftUI
import Combine

final class AppState: ObservableObject {

    // =====================================================
    // SINGLE SOURCE OF TRUTH
    // =====================================================
    @Published var memoryViewModel = MemoryViewModel()
    @Published var notesViewModel = NotesViewModel()

    // =====================================================
    // MEMORY ENGINE (AI LOGIC LAYER)
    // =====================================================
    let memoryEngine = MemoryEngine()

    // =====================================================
    // INIT
    // =====================================================
    init() {
        // No NotificationCenter needed anymore
    }

    // =====================================================
    // CENTRALIZED MEMORY CREATION PIPELINE
    // =====================================================
    func createMemoryFromNote(title: String, content: String) {

        let memory = memoryEngine.generateMemory(
            from: title,
            content: content
        )

        memoryViewModel.memories.insert(memory, at: 0)

        memoryViewModel.save()
        memoryViewModel.generateSuggestions()
    }
}
