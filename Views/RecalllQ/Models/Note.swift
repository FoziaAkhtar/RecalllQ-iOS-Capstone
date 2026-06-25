
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

    // MARK: - Identity
    let id: UUID

    // MARK: - Content
    var title: String
    var content: String

    // MARK: - Metadata
    var dateCreated: Date

    // MARK: - INIT
    init(
        id: UUID = UUID(),
        title: String,
        content: String,
        dateCreated: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.dateCreated = dateCreated
    }

    // MARK: - UI HELPER (for cleaner list display)
    var preview: String {
        String(content.prefix(80))
    }
}
