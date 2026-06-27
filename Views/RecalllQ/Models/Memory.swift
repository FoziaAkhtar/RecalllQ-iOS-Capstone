
import Foundation

// =====================================================
// MODEL: Memory
// =====================================================
// PURPOSE:
// AI-enhanced structured memory model
// Used for Notes → Memory transformation system
// =====================================================

struct Memory: Identifiable, Codable, Equatable {

    // =====================================================
    // IDENTITY
    // =====================================================
    var id: UUID = UUID()

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
    // AI METADATA (FUTURE-PROOFING)
    // =====================================================
    var confidence: Double = 1.0   // AI confidence score
    var importance: Int = 1        // ranking priority
    var source: String = "note"    // note | ai | system

    // =====================================================
    // TIMESTAMP
    // =====================================================
    var dateCreated: Date = Date()

    // =====================================================
    // PREVIEW TEXT
    // =====================================================
    var preview: String {

        let baseText = summary.isEmpty ? content : summary

        let cleaned = baseText
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "  ", with: " ")

        // Prefer sentence-based preview
        if let sentence = cleaned.split(separator: ".").first {
            return String(sentence).trimmingCharacters(in: .whitespacesAndNewlines)
        }

        // Fallback word limit
        let words = cleaned.split(separator: " ")
        let limit = 40

        guard words.count > limit else {
            return cleaned
        }

        return words.prefix(limit).joined(separator: " ") + "..."
    }

    // =====================================================
    // FORMATTED DATE 
    // =====================================================
    var formattedDate: String {

        let formatter = DateFormatter()
        formatter.dateStyle = .medium

        return formatter.string(from: dateCreated)
    }
}
