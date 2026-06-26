
import Foundation

// =====================================================
// MODEL: Memory
// =====================================================
// PURPOSE:
// Represents a structured AI-style memory
// created from a note (title + content).
// =====================================================

struct Memory: Identifiable, Codable, Equatable {

    // =====================================================
    // ID (SwiftUI IDENTIFIABLE REQUIREMENT)
    // =====================================================
    var id: UUID

    // =====================================================
    // CORE DATA
    // =====================================================
    var title: String
    var content: String

    // =====================================================
    // AI GENERATED DATA
    // =====================================================
    var summary: String
    var tags: [String]

    // =====================================================
    // METADATA (USED FOR ANALYTICS / DASHBOARD)
    // =====================================================
    var dateCreated: Date

    // =====================================================
    // INIT (SAFE DEFAULTS INCLUDED)
    // =====================================================
    init(
        id: UUID = UUID(),
        title: String,
        content: String,
        summary: String = "",
        tags: [String] = [],
        dateCreated: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.summary = summary
        self.tags = tags
        self.dateCreated = dateCreated
    }

    // =====================================================
    // UI HELPER: SHORT PREVIEW (VERY USEFUL FOR LISTS)
    // =====================================================
    var preview: String {
        if !summary.isEmpty {
            return summary
        }
        return String(content.prefix(40)) + "..."
    }

    // =====================================================
    // UI HELPER: FORMATTED DATE (FOR DASHBOARD)
    // =====================================================
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: dateCreated)
    }
}
