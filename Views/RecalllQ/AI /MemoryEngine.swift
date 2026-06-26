
import Foundation

// =====================================================
// SERVICE: MemoryEngine
// =====================================================
// PURPOSE:
// Simulates AI by converting Notes → Structured Memories
// =====================================================

final class MemoryEngine {

    // =====================================================
    // GENERATE MEMORY FROM NOTE
    // =====================================================
    func generateMemory(from title: String, content: String) -> Memory {

        let summary = createSummary(from: content)
        let tags = extractTags(from: title + " " + content)

        return Memory(
            title: title,
            content: content,
            summary: summary,
            tags: tags
        )
    }

    // =====================================================
    // SIMPLE SUMMARY LOGIC (RULE-BASED AI)
    // =====================================================
    private func createSummary(from text: String) -> String {

        let words = text.split(separator: " ")

        if words.count <= 10 {
            return text
        }

        return words.prefix(10).joined(separator: " ") + "..."
    }

    // =====================================================
    // TAG EXTRACTION (KEYWORD BASED)
    // =====================================================
    private func extractTags(from text: String) -> [String] {

        let keywords = [
            "exam", "study", "lecture", "assignment",
            "homework", "important", "definition",
            "swift", "ios", "project"
        ]

        let lowerText = text.lowercased()

        var foundTags: [String] = []

        for keyword in keywords {
            if lowerText.contains(keyword) {
                foundTags.append(keyword)
            }
        }

        return foundTags.isEmpty ? ["general"] : foundTags
    }
}
