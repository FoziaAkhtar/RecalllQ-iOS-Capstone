
import Foundation

// =====================================================
// SERVICE: MemoryEngine
// =====================================================
// PURPOSE:
// Converts notes → structured AI-like memories
// Adds improved summary + smarter tag detection
// =====================================================

final class MemoryEngine {

    // =====================================================
    // PUBLIC API
    // =====================================================
    func generateMemory(from title: String, content: String) -> Memory {

        let cleanedTitle = cleanText(title)
        let cleanedContent = cleanText(content)

        let combinedText = "\(cleanedTitle) \(cleanedContent)"

        return Memory(
            title: cleanedTitle,
            content: cleanedContent,
            summary: createSummary(from: cleanedContent),
            tags: extractTags(from: combinedText)
        )
    }

    // =====================================================
    // TEXT CLEANING (IMPORTANT FOR CONSISTENCY)
    // =====================================================
    private func cleanText(_ text: String) -> String {

        text
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "  ", with: " ")
    }

    // =====================================================
    // SUMMARY ENGINE (IMPROVED QUALITY)
    // =====================================================
    private func createSummary(from text: String) -> String {

        let sentences = text.split(separator: ".")
        let firstSentence = sentences.first?.trimmingCharacters(in: .whitespacesAndNewlines)

        if let sentence = firstSentence, sentence.count > 0 {
            return String(sentence)
        }

        // fallback: word-based summary
        let words = text.split(separator: " ")
        let limit = 12

        guard words.count > limit else {
            return text
        }

        return words.prefix(limit).joined(separator: " ") + "..."
    }

    // =====================================================
    // TAG ENGINE (IMPROVED AI LOGIC)
    // =====================================================
    private func extractTags(from text: String) -> [String] {

        let normalized = text.lowercased()

        let keywordMap: [(tag: String, keywords: [String])] = [
            ("study", ["study", "studying", "exam", "revision", "revise"]),
            ("school", ["lecture", "class", "teacher", "lesson"]),
            ("assignment", ["assignment", "homework", "project", "task"]),
            ("ios", ["swift", "ios", "xcode", "apple"]),
            ("important", ["important", "must", "critical", "urgent"])
        ]

        var foundTags: Set<String> = []

        for entry in keywordMap {

            for keyword in entry.keywords {
                if normalized.contains(keyword) {
                    foundTags.insert(entry.tag)
                    break
                }
            }
        }

        return foundTags.isEmpty ? ["general"] : Array(foundTags)
    }
}
