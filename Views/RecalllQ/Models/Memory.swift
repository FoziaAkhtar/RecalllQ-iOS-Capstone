
import Foundation

// =====================================================
// MODEL: Memory
// =====================================================
// PURPOSE:
// Represents a structured AI-style memory
// created from user notes and enhanced with AI metadata
// =====================================================

struct Memory: Identifiable, Codable, Equatable {

    // =====================================================
    // IDENTITY
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
    // METADATA
    // =====================================================
    var dateCreated: Date

    // =====================================================
    // INIT (SAFE DEFAULTS)
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
    // EQUATABLE (SAFE ID-BASED COMPARISON)
    // =====================================================
    static func == (lhs: Memory, rhs: Memory) -> Bool {
        lhs.id == rhs.id
    }

    // =====================================================
    // UI HELPER: PREVIEW TEXT
    // =====================================================
    var preview: String {

        let baseText = !summary.isEmpty ? summary : content

        let trimmed = baseText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard trimmed.count > 40 else {
            return trimmed
        }

        return String(trimmed.prefix(40)) + "..."
    }

    // =====================================================
    // UI HELPER: FORMATTED DATE (OPTIMIZED)
    // =====================================================
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()

    var formattedDate: String {
        Self.dateFormatter.string(from: dateCreated)
    }
}
