
import Foundation

// =====================================================
// SERVICE: MemoryEngine
// =====================================================
// PURPOSE:
// Converts notes → structured memories
//
// This service provides local AI-style intelligence for
// RecalllQ. It cleans the note, creates a summary,
// detects useful tags, calculates importance, and
// calculates a confidence score.
//
// IMPORTANT:
// This version does NOT require an API or internet
// connection.
// =====================================================

final class MemoryEngine {

    // =====================================================
    // PUBLIC API
    // =====================================================

    func generateMemory(
        from title: String,
        content: String
    ) -> Memory {

        let cleanedTitle = cleanText(title)
        let cleanedContent = cleanText(content)

        let combinedText = "\(cleanedTitle) \(cleanedContent)"

        return Memory(
            title: cleanedTitle.isEmpty
                ? "Untitled Memory"
                : cleanedTitle,

            content: cleanedContent,

            summary: createSummary(
                from: cleanedContent
            ),

            tags: extractTags(
                from: combinedText
            ),

            confidence: calculateConfidence(
                from: cleanedContent
            ),

            importance: calculateImportance(
                title: cleanedTitle,
                content: cleanedContent
            ),

            source: "local-ai"
        )
    }

    // =====================================================
    // TEXT CLEANING
    // =====================================================

    private func cleanText(_ text: String) -> String {

        return text
            .trimmingCharacters(
                in: CharacterSet.whitespacesAndNewlines
            )
            .replacingOccurrences(
                of: "\\s+",
                with: " ",
                options: .regularExpression
            )
    }

    // =====================================================
    // SUMMARY ENGINE
    // =====================================================

    private func createSummary(from text: String) -> String {

        let cleanedText = text.trimmingCharacters(
            in: CharacterSet.whitespacesAndNewlines
        )

        // Empty note
        guard !cleanedText.isEmpty else {
            return "No summary available."
        }

        // -------------------------------------------------
        // Find the first sentence
        // -------------------------------------------------

        let sentenceSeparators = CharacterSet(
            charactersIn: ".!?"
        )

        let sentences = cleanedText.components(
            separatedBy: sentenceSeparators
        )

        for sentence in sentences {

            let trimmedSentence = sentence.trimmingCharacters(
                in: CharacterSet.whitespacesAndNewlines
            )

            if !trimmedSentence.isEmpty {

                if trimmedSentence.count <= 180 {
                    return trimmedSentence
                }

                return String(
                    trimmedSentence.prefix(180)
                ) + "..."
            }
        }

        // -------------------------------------------------
        // Fallback: first 20 words
        // -------------------------------------------------

        let words = cleanedText.split(
            separator: " "
        )

        let limit = 20

        if words.count <= limit {
            return cleanedText
        }

        return words
            .prefix(limit)
            .joined(separator: " ") + "..."
    }

    // =====================================================
    // TAG ENGINE
    // =====================================================

    private func extractTags(from text: String) -> [String] {

        let normalized = text.lowercased()

        let keywordMap: [
            (tag: String, keywords: [String])
        ] = [

            (
                "study",
                [
                    "study",
                    "studying",
                    "exam",
                    "revision",
                    "revise",
                    "review",
                    "test",
                    "quiz"
                ]
            ),

            (
                "school",
                [
                    "lecture",
                    "class",
                    "teacher",
                    "lesson",
                    "student",
                    "college",
                    "university"
                ]
            ),

            (
                "assignment",
                [
                    "assignment",
                    "homework",
                    "project",
                    "task",
                    "deadline",
                    "submission"
                ]
            ),

            (
                "ios",
                [
                    "swift",
                    "swiftui",
                    "ios",
                    "xcode",
                    "apple",
                    "uikit",
                    "iphone",
                    "ipad"
                ]
            ),

            (
                "programming",
                [
                    "code",
                    "coding",
                    "programming",
                    "function",
                    "class",
                    "variable",
                    "array",
                    "loop",
                    "algorithm"
                ]
            ),

            (
                "important",
                [
                    "important",
                    "must",
                    "critical",
                    "urgent",
                    "remember",
                    "key point"
                ]
            ),

            (
                "exam",
                [
                    "exam",
                    "midterm",
                    "final exam",
                    "test"
                ]
            ),

            (
                "reminder",
                [
                    "remind",
                    "reminder",
                    "don't forget",
                    "remember to"
                ]
            )
        ]

        var foundTags = Set<String>()

        for entry in keywordMap {

            for keyword in entry.keywords {

                if normalized.contains(keyword) {

                    foundTags.insert(entry.tag)
                    break
                }
            }
        }

        if foundTags.isEmpty {
            foundTags.insert("general")
        }

        return foundTags.sorted()
    }

    // =====================================================
    // CONFIDENCE SCORE
    // =====================================================

    private func calculateConfidence(
        from text: String
    ) -> Double {

        let wordCount = text.split(
            separator: " "
        ).count

        if wordCount < 5 {
            return 0.55
        }

        if wordCount < 15 {
            return 0.70
        }

        if wordCount < 40 {
            return 0.85
        }

        return 0.95
    }

    // =====================================================
    // IMPORTANCE SCORE
    // =====================================================

    private func calculateImportance(
        title: String,
        content: String
    ) -> Int {

        let text = "\(title) \(content)"
            .lowercased()

        var score = 1

        // -------------------------------------------------
        // Important words
        // -------------------------------------------------

        let importantWords = [
            "important",
            "critical",
            "urgent",
            "must",
            "deadline",
            "exam",
            "final",
            "due"
        ]

        for word in importantWords {

            if text.contains(word) {
                score += 1
                break
            }
        }

        // -------------------------------------------------
        // Assignment/project information
        // -------------------------------------------------

        let assignmentWords = [
            "assignment",
            "project",
            "homework",
            "submission"
        ]

        for word in assignmentWords {

            if text.contains(word) {
                score += 1
                break
            }
        }

        // -------------------------------------------------
        // Reminder language
        // -------------------------------------------------

        let reminderWords = [
            "remember",
            "remind",
            "don't forget"
        ]

        for word in reminderWords {

            if text.contains(word) {
                score += 1
                break
            }
        }

        // -------------------------------------------------
        // Keep score between 1 and 5
        // -------------------------------------------------

        return min(
            max(score, 1),
            5
        )
    }
}
