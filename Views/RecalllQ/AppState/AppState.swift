
import Foundation
import SwiftUI
import Combine

// =====================================================
// APP STATE (GLOBAL SHARED DATA LAYER)
// =====================================================
// PURPOSE:
// - Single source of truth for entire app
// - Holds shared ViewModel instances
// - Injected using @EnvironmentObject
// =====================================================

final class AppState: ObservableObject {

    // =====================================================
    // SHARED VIEWMODELS
    // =====================================================

    // Notes system (main feature)
    @Published var notesViewModel: NotesViewModel

    // Memory system (AI dashboard feature)
    @Published var memoryViewModel: MemoryViewModel

    // =====================================================
    // INIT
    // =====================================================
    init() {

        // IMPORTANT:
        // Initialize ViewModels here to avoid SwiftUI dependency issues
        self.notesViewModel = NotesViewModel()
        self.memoryViewModel = MemoryViewModel()
    }
}
