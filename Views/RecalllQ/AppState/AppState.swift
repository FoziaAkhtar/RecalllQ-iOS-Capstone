
import Foundation
import SwiftUI
import Combine

// =====================================================
// APP STATE (GLOBAL SOURCE OF TRUTH)
// =====================================================

final class AppState: ObservableObject {

    // =====================================================
    // VIEWMODELS
    // =====================================================
    @Published var memoryViewModel = MemoryViewModel()
    @Published var notesViewModel = NotesViewModel()

    // =====================================================
    // SERVICES
    // =====================================================
    let notificationService = NotificationService()

    // =====================================================
    // INIT (LISTENER SETUP)
    // connects Notes → Memories automatically
    // =====================================================
    init() {
        setupMemoryListener()
    }

    private func setupMemoryListener() {

        NotificationCenter.default.addObserver(
            forName: .newMemoryCreated,
            object: nil,
            queue: .main
        ) { [weak self] notification in

            guard let memory = notification.object as? Memory else { return }

            self?.memoryViewModel.memories.insert(memory, at: 0)
            self?.memoryViewModel.save()
            self?.memoryViewModel.generateSuggestions()
        }
    }
}
