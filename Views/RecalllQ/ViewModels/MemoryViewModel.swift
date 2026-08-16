
import Foundation
import SwiftUI
import Combine

// =====================================================
// VIEWMODEL: MemoryViewModel
// =====================================================
// PURPOSE:
// - Manages memory state
// - Handles memory creation
// - Handles memory deletion
// - Handles search and category filtering
// - Generates personalized study recommendations
// - Handles memory persistence
//
// AI processing is handled by:
// MemoryEngine
//
// Storage is handled by:
// MemoryStorageService
// =====================================================

final class MemoryViewModel: ObservableObject {

    // =====================================================
    // MAIN MEMORY STATE
    // =====================================================

    @Published var memories: [Memory] = []

    // =====================================================
    // SEARCH STATE
    // =====================================================

    @Published var searchText: String = ""

    // =====================================================
    // SELECTED CATEGORY
    // =====================================================

    @Published var selectedTag: String = "all"

    // =====================================================
    // PERSONALIZED STUDY SUGGESTIONS
    // =====================================================

    @Published var suggestedMemories: [Memory] = []

    // =====================================================
    // SERVICES
    // =====================================================

    private let storage = MemoryStorageService()

    private let engine = MemoryEngine()

    // =====================================================
    // INITIALIZATION
    // =====================================================

    init() {

        loadMemories()
    }

    // =====================================================
    // ADD MEMORY
    // =====================================================

    func addMemory(
        title: String,
        content: String
    ) {

        let cleanTitle =
            title.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        let cleanContent =
            content.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        // ---------------------------------------------
        // Prevent empty memories
        // ---------------------------------------------

        guard
            !cleanTitle.isEmpty ||
            !cleanContent.isEmpty
        else {
            return
        }

        // ---------------------------------------------
        // Generate structured memory
        // ---------------------------------------------

        let memory =
            engine.generateMemory(
                from: cleanTitle,
                content: cleanContent
            )

        // ---------------------------------------------
        // Add newest memory to the top
        // ---------------------------------------------

        memories.insert(
            memory,
            at: 0
        )

        // ---------------------------------------------
        // Persist
        // ---------------------------------------------

        save()

        // ---------------------------------------------
        // Refresh personalized recommendations
        // ---------------------------------------------

        generateSuggestions()
    }

    // =====================================================
    // DELETE MEMORY
    // =====================================================

    func deleteMemory(
        id: UUID
    ) {

        memories.removeAll {
            $0.id == id
        }

        save()

        generateSuggestions()

        // ---------------------------------------------
        // Reset selected category if necessary
        // ---------------------------------------------

        if selectedTag != "all" &&
            !allTags.contains(selectedTag) {

            selectedTag = "all"
        }
    }

    // =====================================================
    // FILTERED MEMORIES
    // =====================================================
    // Supports:
    // - Title search
    // - Content search
    // - Summary search
    // - Tag search
    // - Category filtering
    // =====================================================

    var filteredMemories: [Memory] {

        var result = memories

        let query =
            searchText.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        // ---------------------------------------------
        // SEARCH
        // ---------------------------------------------

        if !query.isEmpty {

            result = result.filter { memory in

                let titleMatch =
                    memory.title
                        .localizedCaseInsensitiveContains(
                            query
                        )

                let contentMatch =
                    memory.content
                        .localizedCaseInsensitiveContains(
                            query
                        )

                let summaryMatch =
                    memory.summary
                        .localizedCaseInsensitiveContains(
                            query
                        )

                let tagMatch =
                    memory.tags.contains {
                        $0.localizedCaseInsensitiveContains(
                            query
                        )
                    }

                return
                    titleMatch ||
                    contentMatch ||
                    summaryMatch ||
                    tagMatch
            }
        }

        // ---------------------------------------------
        // CATEGORY FILTER
        // ---------------------------------------------

        if selectedTag != "all" {

            result = result.filter { memory in

                memory.tags.contains {
                    $0.caseInsensitiveCompare(
                        selectedTag
                    ) == .orderedSame
                }
            }
        }

        return result
    }

    // =====================================================
    // ALL TAGS
    // =====================================================
    // Creates a unique sorted list of categories.
    // =====================================================

    var allTags: [String] {

        let tags =
            memories.flatMap {
                $0.tags
            }

        return Array(
            Set(tags)
        )
        .sorted {
            $0.localizedCaseInsensitiveCompare(
                $1
            ) == .orderedAscending
        }
    }

    // =====================================================
    // PERSONALIZED STUDY RECOMMENDATIONS
    // =====================================================
    // Calculates a recommendation score for every memory.
    //
    // Higher score means:
    // - More important
    // - Lower confidence
    // - Older memory that may need review
    // - Study/exam related
    //
    // The top three memories become the user's
    // personalized recommendations.
    // =====================================================

    func generateSuggestions() {

        guard !memories.isEmpty else {

            suggestedMemories = []

            return
        }

        let now = Date()

        let scoredMemories =
            memories
                .filter {
                    !$0.title.isEmpty ||
                    !$0.content.isEmpty
                }
                .map { memory -> (memory: Memory, score: Double) in

                    // =================================================
                    // IMPORTANCE SCORE
                    // =================================================
                    //
                    // Importance is 1...5.
                    // Higher importance = higher recommendation.
                    // =================================================

                    let importanceScore =
                        Double(memory.importance) * 2.0

                    // =================================================
                    // CONFIDENCE SCORE
                    // =================================================
                    //
                    // Lower confidence means the student may need
                    // more review.
                    //
                    // Example:
                    // confidence 0.55 -> strong review boost
                    // confidence 0.95 -> small review boost
                    // =================================================

                    let confidenceScore =
                        (1.0 - memory.confidence) * 6.0

                    // =================================================
                    // AGE / REVIEW SCORE
                    // =================================================
                    //
                    // Older memories receive a larger boost because
                    // they may benefit from another review.
                    // =================================================

                    let ageInDays =
                        max(
                            0,
                            Calendar.current.dateComponents(
                                [.day],
                                from: memory.dateCreated,
                                to: now
                            ).day ?? 0
                        )

                    let ageScore =
                        min(
                            Double(ageInDays) * 0.25,
                            4.0
                        )

                    // =================================================
                    // STUDY CATEGORY SCORE
                    // =================================================

                    let studyTags: Set<String> = [
                        "study",
                        "exam",
                        "assignment",
                        "programming",
                        "ios",
                        "school"
                    ]

                    let matchingTags =
                        memory.tags.filter {
                            studyTags.contains(
                                $0.lowercased()
                            )
                        }.count

                    let categoryScore =
                        Double(matchingTags) * 1.5

                    // =================================================
                    // RECENCY SCORE
                    // =================================================
                    //
                    // New memories receive a small boost so that
                    // newly learned material is not ignored.
                    // =================================================

                    let recencyScore: Double

                    if ageInDays == 0 {

                        recencyScore = 2.0

                    } else if ageInDays <= 2 {

                        recencyScore = 1.5

                    } else if ageInDays <= 7 {

                        recencyScore = 1.0

                    } else {

                        recencyScore = 0.0
                    }

                    // =================================================
                    // FINAL PERSONALIZATION SCORE
                    // =================================================

                    let totalScore =
                        importanceScore +
                        confidenceScore +
                        ageScore +
                        categoryScore +
                        recencyScore

                    return (
                        memory: memory,
                        score: totalScore
                    )
                }

        // =================================================
        // SORT BY PERSONALIZED SCORE
        // =================================================

        suggestedMemories =
            scoredMemories
                .sorted {

                    if $0.score != $1.score {

                        return $0.score > $1.score
                    }

                    // If scores are equal, prefer newer memory.
                    return $0.memory.dateCreated >
                        $1.memory.dateCreated
                }
                .prefix(3)
                .map {
                    $0.memory
                }
    }

    // =====================================================
    // LOAD MEMORIES
    // =====================================================

    func loadMemories() {

        memories =
            storage.load()

        generateSuggestions()
    }

    // =====================================================
    // SAVE MEMORIES
    // =====================================================

    func save() {

        storage.save(
            memories
        )
    }
}

