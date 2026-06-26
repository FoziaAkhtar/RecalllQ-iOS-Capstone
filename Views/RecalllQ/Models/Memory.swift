
import Foundation

// =====================================================
// MODEL: Memory
// =====================================================
// PURPOSE:
// Represents a structured "AI-style memory"
// created from a note (title + content).
// =====================================================

struct Memory: Identifiable, Codable {

    // =====================================================
    // ID
    // =====================================================
    var id: UUID

    // =====================================================
    // ORIGINAL NOTE DATA
    // =====================================================
    var title: String
    var content: String

    // =====================================================
    // AI-GENERATED SUMMARY
    // =====================================================
    var summary: String

    // =====================================================
    // TAGS (for categorization)
    // =====================================================
    var tags: [String]

    // =====================================================
    // INIT (SAFE FOR CREATION)
    // =====================================================
    init(id: UUID = UUID(), title: String, content: String, summary: String, tags: [String]) {
        self.id = id
        self.title = title
        self.content = content
        self.summary = summary
        self.tags = tags
    }
}
