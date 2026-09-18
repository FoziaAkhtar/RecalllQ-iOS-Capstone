

import Foundation

// =====================================================
// SERVICE: MemoryEngine
// =====================================================
// PURPOSE:
// Converts study notes into structured intelligent
// memories for RecalllQ.
//
// FEATURES:
// - Text cleaning
// - Smart summary generation
// - Intelligent tag detection
// - Confidence scoring
// - Importance scoring
// - Local AI-style processing
//
// IMPORTANT:
// This version does NOT require an API or internet.
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

        let summary = createSummary(
            from: cleanedContent
        )

        let tags = extractTags(
            from: combinedText
        )

        let confidence = calculateConfidence(
            from: cleanedContent,
            tags: tags
        )

        let importance = calculateImportance(
            title: cleanedTitle,
            content: cleanedContent
        )

        return Memory(
            title: cleanedTitle.isEmpty
                ? "Untitled Memory"
                : cleanedTitle,

            content: cleanedContent,

            summary: summary,

            tags: tags,

            confidence: confidence,

            importance: importance,

            source: "local-ai"
        )
    }

    // =====================================================
    // TEXT CLEANING
    // =====================================================

    private func cleanText(
        _ text: String
    ) -> String {

        text
            .trimmingCharacters(
                in: .whitespacesAndNewlines
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

    private func createSummary(
        from text: String
    ) -> String {

        let cleanedText = cleanText(text)

        guard !cleanedText.isEmpty else {
            return "No summary available."
        }

        // -------------------------------------------------
        // Split text into sentences
        // -------------------------------------------------

        let sentences = cleanedText.components(
            separatedBy:
                CharacterSet(
                    charactersIn: ".!?"
                )
        )

        let validSentences = sentences
            .map {
                $0.trimmingCharacters(
                    in: .whitespacesAndNewlines
                )
            }
            .filter {
                !$0.isEmpty
            }

        // -------------------------------------------------
        // Short note
        // -------------------------------------------------

        if cleanedText.count <= 180 {
            return cleanedText
        }

        // -------------------------------------------------
        // Prefer first meaningful sentence
        // -------------------------------------------------

        if let firstSentence = validSentences.first {

            if firstSentence.count <= 180 {
                return firstSentence
            }

            return String(
                firstSentence.prefix(177)
            ) + "..."
        }

        // -------------------------------------------------
        // Fallback to first 25 words
        // -------------------------------------------------

        let words = cleanedText.split(
            separator: " "
        )

        let limit = 25

        if words.count <= limit {
            return cleanedText
        }

        return words
            .prefix(limit)
            .joined(separator: " ")
            + "..."
    }

    // =====================================================
    // SMART TAG ENGINE
    // =====================================================

    private func extractTags(
        from text: String
    ) -> [String] {

        let normalizedText = normalizeText(
            text
        )

        // -------------------------------------------------
        // TAG DEFINITIONS
        // -------------------------------------------------

        let keywordMap: [
            (tag: String, keywords: [String])
        ] = [

            // ---------------------------------------------
            // STUDY
            // ---------------------------------------------

            (
                "study",
                [
                    "study",
                    "studying",
                    "learn",
                    "learning",
                    "revision",
                    "revise",
                    "review",
                    "test",
                    "quiz",
                    "practice"
                ]
            ),

            // ---------------------------------------------
            // SCHOOL
            // ---------------------------------------------

            (
                "school",
                [
                    "school",
                    "lecture",
                    "class",
                    "teacher",
                    "lesson",
                    "student",
                    "college",
                    "university",
                    "course",
                    "professor"
                ]
            ),

            // ---------------------------------------------
            // PROGRAMMING
            // ---------------------------------------------

            (
                "programming",
                [
                    "programming",
                    "programmer",
                    "coding",
                    "code",
                    "function",
                    "variable",
                    "array",
                    "loop",
                    "algorithm",
                    "debugging",
                    "software"
                ]
            ),

            // ---------------------------------------------
            // IOS
            // ---------------------------------------------

            (
                "ios",
                [
                    "swift",
                    "swiftui",
                    "ios",
                    "xcode",
                    "apple",
                    "uikit",
                    "visionkit",
                    "iphone",
                    "ipad",
                    "macos"
                ]
            ),

            // ---------------------------------------------
            // ASSIGNMENT
            // ---------------------------------------------

            (
                "assignment",
                [
                    "assignment",
                    "homework",
                    "project",
                    "task",
                    "submission",
                    "coursework",
                    "milestone"
                ]
            ),

            // ---------------------------------------------
            // EXAM
            // ---------------------------------------------

            (
                "exam",
                [
                    "exam",
                    "midterm",
                    "final exam",
                    "test",
                    "quiz",
                    "assessment"
                ]
            ),

            // ---------------------------------------------
            // IMPORTANT
            // ---------------------------------------------

            (
                "important",
                [
                    "important",
                    "critical",
                    "urgent",
                    "must",
                    "key point",
                    "essential",
                    "high priority"
                ]
            ),

            // ---------------------------------------------
            // DEADLINE
            // ---------------------------------------------

            (
                "deadline",
                [
                    "deadline",
                    "due",
                    "due date",
                    "submission date",
                    "expires"
                ]
            ),

            // ---------------------------------------------
            // REMINDER
            // ---------------------------------------------

            (
                "reminder",
                [
                    "remind",
                    "reminder",
                    "remember",
                    "don't forget",
                    "do not forget"
                ]
            ),

            // ---------------------------------------------
            // DATABASE
            // ---------------------------------------------

            (
                "database",
                [
                    "database",
                    "sql",
                    "sqlite",
                    "firebase",
                    "mongodb",
                    "mysql",
                    "postgresql"
                ]
            ),

            // ---------------------------------------------
            // NETWORKING
            // ---------------------------------------------

            (
                "networking",
                [
                    "network",
                    "networking",
                    "ethernet",
                    "tcp",
                    "ip address",
                    "router",
                    "switch",
                    "dns",
                    "http"
                ]
            ),

            // ---------------------------------------------
            // SECURITY
            // ---------------------------------------------

            (
                "security",
                [
                    "security",
                    "malware",
                    "virus",
                    "firewall",
                    "authentication",
                    "encryption",
                    "password",
                    "phishing"
                ]
            )
        ]

        var foundTags = Set<String>()

        // -------------------------------------------------
        // Search for matching keywords
        // -------------------------------------------------

        for entry in keywordMap {

            for keyword in entry.keywords {

                if containsKeyword(
                    keyword,
                    in: normalizedText
                ) {

                    foundTags.insert(
                        entry.tag
                    )

                    break
                }
            }
        }

        // -------------------------------------------------
        // General fallback
        // -------------------------------------------------

        if foundTags.isEmpty {

            foundTags.insert(
                "general"
            )
        }

        // -------------------------------------------------
        // Return alphabetically sorted tags
        // -------------------------------------------------

        return foundTags.sorted()
    }

    // =====================================================
    // NORMALIZE TEXT
    // =====================================================

    private func normalizeText(
        _ text: String
    ) -> String {

        text
            .lowercased()
            .replacingOccurrences(
                of: "[^a-z0-9\\s]",
                with: " ",
                options: .regularExpression
            )
            .replacingOccurrences(
                of: "\\s+",
                with: " ",
                options: .regularExpression
            )
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )
    }

    // =====================================================
    // KEYWORD MATCHING
    // =====================================================

    private func containsKeyword(
        _ keyword: String,
        in text: String
    ) -> Bool {

        let normalizedKeyword =
            normalizeText(
                keyword
            )

        guard !normalizedKeyword.isEmpty else {
            return false
        }

        // -------------------------------------------------
        // Multi-word keyword
        // -------------------------------------------------

        if normalizedKeyword.contains(" ") {

            return text.contains(
                normalizedKeyword
            )
        }

        // -------------------------------------------------
        // Single-word keyword
        // -------------------------------------------------

        let words = text.split(
            separator: " "
        )

        return words.contains {
            $0 == normalizedKeyword
        }
    }

    // =====================================================
    // CONFIDENCE SCORE
    // =====================================================

    private func calculateConfidence(
        from text: String,
        tags: [String]
    ) -> Double {

        let words = text.split(
            separator: " "
        )

        let wordCount = words.count

        // -------------------------------------------------
        // Base confidence
        // -------------------------------------------------

        var confidence: Double

        switch wordCount {

        case 0:
            confidence = 0.30

        case 1...4:
            confidence = 0.55

        case 5...14:
            confidence = 0.70

        case 15...39:
            confidence = 0.85

        default:
            confidence = 0.95
        }

        // -------------------------------------------------
        // Tags improve confidence
        // -------------------------------------------------

        if !tags.isEmpty &&
            !tags.contains("general") {

            confidence += 0.02
        }

        // -------------------------------------------------
        // Keep between 0 and 1
        // -------------------------------------------------

        return min(
            max(
                confidence,
                0.0
            ),
            1.0
        )
    }

    // =====================================================
    // IMPORTANCE SCORE
    // =====================================================

    private func calculateImportance(
        title: String,
        content: String
    ) -> Int {

        let normalizedText = normalizeText(
            "\(title) \(content)"
        )

        var score = 1

        // -------------------------------------------------
        // Important concepts
        // -------------------------------------------------

        let importantKeywords = [
            "important",
            "critical",
            "urgent",
            "must",
            "essential",
            "key point",
            "high priority"
        ]

        if containsAny(
            importantKeywords,
            in: normalizedText
        ) {

            score += 1
        }

        // -------------------------------------------------
        // Exam information
        // -------------------------------------------------

        let examKeywords = [
            "exam",
            "midterm",
            "final",
            "test",
            "assessment"
        ]

        if containsAny(
            examKeywords,
            in: normalizedText
        ) {

            score += 1
        }

        // -------------------------------------------------
        // Assignment information
        // -------------------------------------------------

        let assignmentKeywords = [
            "assignment",
            "project",
            "homework",
            "submission",
            "deadline",
            "due date"
        ]

        if containsAny(
            assignmentKeywords,
            in: normalizedText
        ) {

            score += 1
        }

        // -------------------------------------------------
        // Reminder language
        // -------------------------------------------------

        let reminderKeywords = [
            "remember",
            "remind",
            "do not forget",
            "don't forget"
        ]

        if containsAny(
            reminderKeywords,
            in: normalizedText
        ) {

            score += 1
        }

        // -------------------------------------------------
        // Longer study material
        // -------------------------------------------------

        let wordCount =
            normalizedText.split(
                separator: " "
            ).count

        if wordCount >= 100 {

            score += 1
        }

        // -------------------------------------------------
        // Maximum importance = 5
        // -------------------------------------------------

        return min(
            max(
                score,
                1
            ),
            5
        )
    }

    // =====================================================
    // MATCH ANY KEYWORD
    // =====================================================

    private func containsAny(
        _ keywords: [String],
        in text: String
    ) -> Bool {

        for keyword in keywords {

            if containsKeyword(
                keyword,
                in: text
            ) {

                return true
            }
        }

        return false
    }
}

