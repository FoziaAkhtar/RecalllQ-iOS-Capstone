
import Foundation
import SwiftUI
import Combine

// =====================================================
// VIEWMODEL: MemoryViewModel (FINAL CLEAN VERSION)
// =====================================================
// PURPOSE:
// Core AI memory system (CRUD + search + AI suggestions)
// Works with AppState + Storage + Dashboard
// =====================================================

final class MemoryViewModel: ObservableObject {

    // =====================================================
    // MAIN STATE
    // =====================================================
    @Published var memories: [Memory] = []

    // =====================================================
    // UI STATE
    // =====================================================
    @Published var searchText: String = ""
    @Published var selectedTag: String = "all"

    // =====================================================
    // AI STATE
    // =====================================================
    @Published var suggestedMemories: [Memory] = []

    // =====================================================
    // STORAGE LAYER
    // =====================================================
    private let storage = MemoryStorageService()

    // =====================================================
    // INIT
    // =====================================================
    init() {
        loadMemories()
    }

    // =====================================================
    // ADD MEMORY
    // =====================================================
    func addMemory(title: String, content: String) {

        let memory = Memory(
            title: title,
            content: content,
            summary: createSummary(content),
            tags: extractTags(content)
        )

        memories.insert(memory, at: 0)

        save()
        generateSuggestions()
    }

    // =====================================================
    // DELETE MEMORY
    // =====================================================
    func deleteMemory(at offsets: IndexSet) {

        memories.remove(atOffsets: offsets)

        save()
        generateSuggestions()
    }

    // =====================================================
    // FILTERED MEMORIES
    // =====================================================
    var filteredMemories: [Memory] {

        let searched = searchMemories(searchText)

        guard selectedTag.lowercased() != "all" else {
            return searched
        }

        return searched.filter { memory in
            memory.tags.contains { tag in
                tag.lowercased() == selectedTag.lowercased()
            }
        }
    }

    // =====================================================
    // SMART SEARCH (IMPROVED RANKING SYSTEM)
    // =====================================================
    func searchMemories(_ query: String) -> [Memory] {

        let trimmed = query
            .lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmed.isEmpty else {
            return memories
        }

        let scored = memories.map { memory -> (Memory, Int) in

            var score = 0

            let title = memory.title.lowercased()
            let content = memory.content.lowercased()
            let summary = memory.summary.lowercased()

            // Title match = highest priority
            if title.contains(trimmed) {
                score += 5
            }

            // Summary match
            if summary.contains(trimmed) {
                score += 3
            }

            // Content match
            if content.contains(trimmed) {
                score += 1
            }

            return (memory, score)
        }

        let filtered = scored.filter { $0.1 > 0 }

        let sorted = filtered.sorted { $0.1 > $1.1 }

        return sorted.map { $0.0 }
    }

    // =====================================================
    // ALL TAGS
    // =====================================================
    var allTags: [String] {
        let tags = memories.flatMap { $0.tags }
        return Array(Set(tags)).sorted()
    }

    // =====================================================
    // AI SUGGESTIONS ENGINE
    // =====================================================
    func generateSuggestions() {

        guard !memories.isEmpty else {
            suggestedMemories = []
            return
        }

        let allTagsFlat = memories.flatMap { $0.tags }

        let frequency = Dictionary(grouping: allTagsFlat, by: { $0 })
            .mapValues { $0.count }

        let topTags = frequency
            .sorted { $0.value > $1.value }
            .map { $0.key }
            .prefix(2)

        let topTagsSet = Set(topTags.map { $0.lowercased() })

        let tagBased = memories.filter { memory in
            !Set(memory.tags.map { $0.lowercased() })
                .isDisjoint(with: topTagsSet)
        }

        let recent = Array(memories.prefix(3))

        let combined = tagBased + recent

        let unique = Dictionary(grouping: combined, by: { $0.id })
            .compactMap { $0.value.first }

        suggestedMemories = Array(unique.prefix(5))
    }

    // =====================================================
    // LOAD
    // =====================================================
    func loadMemories() {
        memories = storage.load()
        generateSuggestions()
    }

    // =====================================================
    // SAVE
    // =====================================================
    func save() {
        storage.save(memories)
    }

    // =====================================================
    // AI SUMMARY
    // =====================================================
    private func createSummary(_ text: String) -> String {

        let words = text.split(separator: " ")
        let limit = 12

        guard words.count > limit else {
            return text
        }

        return words.prefix(limit).joined(separator: " ") + "..."
    }

    // =====================================================
    // AI TAGS
    // =====================================================
    private func extractTags(_ text: String) -> [String] {

        let keywords = [
            "study",
            "exam",
            "swift",
            "ios",
            "lecture",
            "assignment",
            "homework"
        ]

        let lower = text.lowercased()

        let found = keywords.filter { lower.contains($0) }

        return found.isEmpty ? ["general"] : found
    }
}
