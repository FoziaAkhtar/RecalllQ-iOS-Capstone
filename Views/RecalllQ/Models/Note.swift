
import Foundation

// =====================================================
// MODEL: Note
// =====================================================
// PURPOSE:
// Core user note model used for input + AI conversion
// =====================================================

struct Note: Identifiable, Codable, Equatable {

    // =====================================================
    // IDENTITY
    // =====================================================
    var id: UUID = UUID()

    // =====================================================
    // CORE CONTENT
    // =====================================================
    var title: String
    var content: String

    // =====================================================
    // STATE FLAGS
    // =====================================================
    var isPinned: Bool = false

    // =====================================================
    // REMINDER SUPPORT
    // =====================================================
    var reminderDate: Date?

    // =====================================================
    // METADATA (FUTURE AI USE)
    // =====================================================
    var createdAt: Date = Date()
    var updatedAt: Date = Date()

    // =====================================================
    // PREVIEW TEXT (
    // =====================================================
    var preview: String {

        let combined = "\(title) \(content)"
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "  ", with: " ")

        // Prefer sentence-based preview
        if let sentence = combined.split(separator: ".").first {
            return String(sentence).trimmingCharacters(in: .whitespacesAndNewlines)
        }

        // Fallback word-based preview
        let words = combined.split(separator: " ")
        let limit = 40

        guard words.count > limit else {
            return combined
        }

        return words.prefix(limit).joined(separator: " ") + "..."
    }

    // =====================================================
    // FORMATTED REMINDER DATE (OPTIMIZED)
    // =====================================================
    var formattedReminder: String? {

        guard let date = reminderDate else { return nil }

        return Note.dateFormatter.string(from: date)
    }

    // =====================================================
    // SHARED DATE FORMATTER (PERFORMANCE SAFE)
    // =====================================================
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
}
