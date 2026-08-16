
import Foundation
// =====================================================
// SERVICE: StudyRecommendationService
// =====================================================
// PURPOSE:
// Provides personalized study recommendations for RecalllQ.
//
// ANALYZES:
// - Memory importance
// - Memory confidence
// - Study-related tags
// - Exam / assignment information
// - Memory age
// - Flashcard difficulty
// - Flashcard accuracy
// - Flashcard review history
// - Spaced-repetition due dates
//
// IMPORTANT:
// This is local AI-style intelligence.
// No API or internet connection is required.
// =====================================================

final class StudyRecommendationService {

    // =====================================================
    // RECOMMENDATION MODEL
    // =====================================================

    struct Recommendation: Identifiable {

        let id: UUID

        let memory: Memory

        let score: Double

        let reason: String

        // -------------------------------------------------
        // Convenience properties
        // -------------------------------------------------

        var title: String {
            memory.title
        }

        var summary: String {
            memory.summary
        }

        var tags: [String] {
            memory.tags
        }
    }

    // =====================================================
    // PUBLIC API
    // =====================================================

    func generateRecommendations(
        from memories: [Memory],
        flashcards: [Flashcard],
        limit: Int = 5
    ) -> [Recommendation] {

        guard !memories.isEmpty else {
            return []
        }

        let recommendations = memories.map { memory in

            createRecommendation(
                for: memory,
                flashcards: flashcards
            )
        }

        return recommendations
            .sorted {
                $0.score > $1.score
            }
            .prefix(
                max(limit, 1)
            )
            .map {
                $0
            }
    }

    // =====================================================
    // CREATE RECOMMENDATION
    // =====================================================

    private func createRecommendation(
        for memory: Memory,
        flashcards: [Flashcard]
    ) -> Recommendation {

        var score = 0.0

        var reasons: [String] = []

        // =================================================
        // FIND FLASHCARDS FOR THIS MEMORY
        // =================================================

        let relatedFlashcards =
            flashcards.filter {
                $0.memoryID == memory.id
            }

        // =================================================
        // IMPORTANCE
        // =================================================

        let importanceScore =
            Double(memory.importance) * 20.0

        score += importanceScore

        if memory.importance >= 4 {

            reasons.append(
                "This is an important memory."
            )
        }

        // =================================================
        // CONFIDENCE
        // =================================================
        //
        // Lower confidence means the student may need
        // additional review.
        // =================================================

        let confidenceScore =
            (1.0 - memory.confidence) * 40.0

        score += confidenceScore

        if memory.confidence < 0.70 {

            reasons.append(
                "Your confidence in this topic is low."
            )

        } else if memory.confidence < 0.85 {

            reasons.append(
                "This topic could use another review."
            )
        }

        // =================================================
        // STUDY TAGS
        // =================================================

        let studyTags = [
            "study",
            "exam",
            "assignment",
            "school",
            "programming",
            "ios",
            "reminder"
        ]

        let matchingTags =
            memory.tags.filter {
                studyTags.contains(
                    $0.lowercased()
                )
            }

        if !matchingTags.isEmpty {

            score +=
                Double(
                    matchingTags.count
                ) * 8.0

            reasons.append(
                "This is related to your study material."
            )
        }

        // =================================================
        // EXAM PRIORITY
        // =================================================

        if memory.tags.contains(
            "exam"
        ) {

            score += 20.0

            reasons.append(
                "This topic is connected to an exam."
            )
        }

        // =================================================
        // ASSIGNMENT PRIORITY
        // =================================================

        if memory.tags.contains(
            "assignment"
        ) {

            score += 15.0

            reasons.append(
                "This topic is connected to an assignment."
            )
        }

        // =================================================
        // IMPORTANT TAG
        // =================================================

        if memory.tags.contains(
            "important"
        ) {

            score += 15.0

            reasons.append(
                "You marked this topic as important."
            )
        }

        // =================================================
        // FLASHCARD INTELLIGENCE
        // =================================================

        if !relatedFlashcards.isEmpty {

            // ---------------------------------------------
            // Average flashcard accuracy
            // ---------------------------------------------

            let totalAccuracy =
                relatedFlashcards.reduce(
                    0.0
                ) {
                    $0 + $1.accuracy
                }

            let averageAccuracy =
                totalAccuracy /
                Double(
                    relatedFlashcards.count
                )

            // ---------------------------------------------
            // LOW ACCURACY
            // ---------------------------------------------

            if averageAccuracy < 0.50 {

                score += 35.0

                reasons.append(
                    "Your accuracy on this topic is low."
                )

            } else if averageAccuracy < 0.80 {

                score += 20.0

                reasons.append(
                    "Your accuracy on this topic could improve."
                )
            }

            // ---------------------------------------------
            // DIFFICULT CARDS
            // ---------------------------------------------

            let hardCards =
                relatedFlashcards.filter {
                    $0.difficulty == .hard
                }

            if !hardCards.isEmpty {

                score +=
                    Double(
                        hardCards.count
                    ) * 15.0

                reasons.append(
                    "You have difficult flashcards in this topic."
                )
            }

            // ---------------------------------------------
            // REVIEW HISTORY
            // ---------------------------------------------

            let reviewedCards =
                relatedFlashcards.filter {
                    $0.timesReviewed > 0
                }

            if !reviewedCards.isEmpty {

                score += 5.0
            }

            // ---------------------------------------------
            // DUE FLASHCARDS
            // ---------------------------------------------

            let now = Date()

            let dueCards =
                relatedFlashcards.filter { card in

                    guard
                        let nextReview =
                            card.nextReviewDate
                    else {
                        return false
                    }

                    return nextReview <= now
                }

            if !dueCards.isEmpty {

                score +=
                    Double(
                        dueCards.count
                    ) * 30.0

                reasons.append(
                    "You have flashcards due for review."
                )
            }
        }

        // =================================================
        // AGE FACTOR
        // =================================================
        //
        // Older memories receive a small review boost.
        // =================================================

        let ageInDays =
            Calendar.current.dateComponents(
                [.day],
                from: memory.dateCreated,
                to: Date()
            ).day ?? 0

        if ageInDays >= 14 {

            score += 15.0

            reasons.append(
                "This memory has not been reviewed recently."
            )

        } else if ageInDays >= 7 {

            score += 10.0

            reasons.append(
                "This memory is due for another review."
            )

        } else if ageInDays >= 3 {

            score += 5.0
        }

        // =================================================
        // NO FLASHCARD FALLBACK
        // =================================================

        if relatedFlashcards.isEmpty {

            reasons.append(
                "Create a flashcard to practice this memory."
            )
        }

        // =================================================
        // GENERIC FALLBACK
        // =================================================

        if reasons.isEmpty {

            reasons.append(
                "This memory is a good candidate for review."
            )
        }

        // =================================================
        // REMOVE DUPLICATE REASONS
        // =================================================

        var uniqueReasons: [String] = []

        for reason in reasons {

            if !uniqueReasons.contains(reason) {

                uniqueReasons.append(reason)
            }
        }

        // =================================================
        // FINAL RECOMMENDATION
        // =================================================

        return Recommendation(

            id:
                memory.id,

            memory:
                memory,

            score:
                score,

            reason:
                uniqueReasons.joined(
                    separator: " "
                )
        )
    }
}
