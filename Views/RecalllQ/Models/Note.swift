
import Foundation

// =====================================================
// MODEL: Note
// =====================================================
// PURPOSE:
// - Represents a single note in the app
// - Supports SwiftUI List (Identifiable)
// - Supports saving/loading (Codable)
// - Includes reminder + UI helpers
// =====================================================

struct Note: Identifiable, Codable, Equatable {

    // =====================================================
    // IDENTITY
    // =====================================================
    var id: UUID

    // =====================================================
    // CORE CONTENT
    // =====================================================
    var title: String
    var content: String

    // =====================================================
    // STATE FLAGS
    // =====================================================
    var isPinned: Bool

    // =====================================================
    // REMINDER SUPPORT
    // Optional = user may not set reminder
    // =====================================================
    var reminderDate: Date?

    // =====================================================
    // INIT
    // =====================================================
    init(
        id: UUID = UUID(),
        title: String,
        content: String,
        isPinned: Bool = false,
        reminderDate: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.isPinned = isPinned
        self.reminderDate = reminderDate
    }

    // =====================================================
    // EQUATABLE (SAFE ID-BASED COMPARISON)
    // =====================================================
    static func == (lhs: Note, rhs: Note) -> Bool {
        lhs.id == rhs.id
    }

    // =====================================================
    // UI HELPER: PREVIEW TEXT
    // =====================================================
    var preview: String {
        let base = content.trimmingCharacters(in: .whitespacesAndNewlines)

        guard base.count > 40 else {
            return base
        }

        return String(base.prefix(40)) + "..."
    }

    // =====================================================
    // UI HELPER: FORMATTED REMINDER DATE
    // =====================================================
    var formattedReminder: String? {
        guard let date = reminderDate else { return nil }

        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short

        return formatter.string(from: date)
    }
}
