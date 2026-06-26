
import Foundation

// =====================================================
// MODEL: Note
// =====================================================
// PURPOSE:
// - Represents a single note in the app
// - Supports SwiftUI List (Identifiable)
// - Supports saving/loading (Codable)
// - Includes timestamp + UI helper (preview)
// =====================================================

struct Note: Identifiable, Codable {

    // =====================================================
    // ID (CODABLE SAFE + IMMUTABLE)
    // =====================================================
    let id: UUID

    // =====================================================
    // CONTENT
    // =====================================================
    var title: String
    var content: String

    // =====================================================
    // PIN STATUS
    // =====================================================
    var isPinned: Bool

    // =====================================================
    // INIT (for new notes)
    // PURPOSE:
    // Creates a new note with optional custom values
    // =====================================================
    init(
        id: UUID = UUID(),
        title: String,
        content: String,
        isPinned: Bool = false
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.isPinned = isPinned
    }
}
