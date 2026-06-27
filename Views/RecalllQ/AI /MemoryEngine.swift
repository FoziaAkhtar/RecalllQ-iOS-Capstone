
import Foundation

// =====================================================
// SERVICE: MemoryEngine
// =====================================================
// PURPOSE:
// Converts raw notes into structured AI-like memories
// Includes summary + intelligent tag extraction
// =====================================================

final class MemoryEngine {

    // =====================================================
    // PUBLIC API
    // =====================================================
    func generateMemory(from title: String, content: String) -> Memory {

        let combinedText = "\(title) \(content)"

        return Memory(
            title: title,
            content: content,
            summary: createSummary(from: content),
            tags: extractTags(from: combinedText)
        )
    }

    // =====================================================
    // SUMMARY ENGINE (CLEAN + CONSISTENT)
    // =====================================================
    private func createSummary(from text: String) -> String {

        let words = text.split(separator: " ")
        let limit = 12

        guard words.count > limit else {
            return text
        }

        return words.prefix(limit).joined(separator: " ") + "..."
    }

    // =====================================================
    // TAG ENGINE (AI-LIKE DETECTION)
    // =====================================================
    private func extractTags(from text: String) -> [String] {

        let normalized = text.lowercased()

        let keywordMap: [(tag: String, keywords: [String])] = [
            ("study", ["study", "exam", "revision"]),
            ("school", ["lecture", "class", "teacher"]),
            ("assignment", ["assignment", "homework", "project"]),
            ("ios", ["swift", "ios", "xcode"]),
            ("important", ["important", "must", "critical"])
        ]

        var foundTags: Set<String> = []

        for entry in keywordMap {

            if entry.keywords.contains(where: { normalized.contains($0) }) {
                foundTags.insert(entry.tag)
            }
        }

        return foundTags.isEmpty ? ["general"] : Array(foundTags)
    }
}
