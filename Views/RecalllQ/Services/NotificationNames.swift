
import Foundation

// =====================================================
// NOTIFICATION NAMES (GLOBAL EVENT DEFINITIONS)
// =====================================================
// PURPOSE:
// Lightweight event system for app-wide communication
// NOTE:
// Prefer direct AppState calls in MVVM where possible
// =====================================================

extension Notification.Name {

    // =====================================================
    // MEMORY EVENTS
    // =====================================================

    /// Fired when a new Memory is created from a Note
    static let memoryCreatedFromNote = Notification.Name("memoryCreatedFromNote")
}
