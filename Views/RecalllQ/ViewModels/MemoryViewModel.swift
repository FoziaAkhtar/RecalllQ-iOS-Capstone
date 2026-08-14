
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
// - Generates study suggestions
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
    // AI STUDY SUGGESTIONS
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
    // Creates a structured memory using MemoryEngine.
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
        // Generate AI-style memory
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
        // Refresh suggestions
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
    // GENERATE STUDY SUGGESTIONS
    // =====================================================
    // Currently selects the three newest memories.
    //
    // This provides the foundation for future intelligent
    // recommendations and spaced-repetition logic.
    // =====================================================

    func generateSuggestions() {

        suggestedMemories =
            memories
                .filter {
                    !$0.title.isEmpty ||
                    !$0.content.isEmpty
                }
                .sorted {
                    $0.dateCreated >
                    $1.dateCreated
                }
                .prefix(3)
                .map {
                    $0
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
