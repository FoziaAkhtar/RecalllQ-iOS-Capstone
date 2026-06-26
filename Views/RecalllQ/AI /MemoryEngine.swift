
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

        let summary = createSummary(from: content)
        let tags = extractTags(from: combinedText)

        return Memory(
            title: title,
            content: content,
            summary: summary,
            tags: tags
        )
    }

    // =====================================================
    // SUMMARY ENGINE (CONSISTENT AI STYLE)
    // =====================================================
    private func createSummary(from text: String) -> String {

        let words = text.split(separator: " ")
        let limit = 12

        guard words.count > limit else {
            return words.joined(separator: " ").description
        }

        return words.prefix(limit).joined(separator: " ") + "..."
    }

    // =====================================================
    // TAG ENGINE (DETERMINISTIC + CLEAN OUTPUT)
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

        var foundTags: [String] = []

        for entry in keywordMap {

            for keyword in entry.keywords {

                if normalized.contains(keyword) {

                    // Avoid duplicates
                    if !foundTags.contains(entry.tag) {
                        foundTags.append(entry.tag)
                    }
                }
            }
        }

        return foundTags.isEmpty ? ["general"] : foundTags
    }
}
