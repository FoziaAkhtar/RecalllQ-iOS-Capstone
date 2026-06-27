
import Foundation
import SwiftUI
import Combine

// =====================================================
// VIEWMODEL: MemoryViewModel (FINAL FIXED)
// =====================================================
// PURPOSE:
// Core AI memory system (CRUD + search + suggestions)
// Sends global events to entire app
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
    // STORAGE
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

        // =====================================================
        // GLOBAL EVENT (used by other screens if needed)
        // =====================================================
        NotificationCenter.default.post(
            name: .newMemoryCreated,
            object: memory
        )
    }

    // =====================================================
    // DELETE MEMORY (SAFE UUID VERSION)
    // =====================================================
    func deleteMemory(id: UUID) {
        memories.removeAll { $0.id == id }
        save()
        generateSuggestions()
    }

    // =====================================================
    // FILTERED MEMORIES (SEARCH + TAGS)
    // =====================================================
    var filteredMemories: [Memory] {

        var result = memories

        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        if !query.isEmpty {
            result = result.filter {
                $0.title.localizedCaseInsensitiveContains(query) ||
                $0.content.localizedCaseInsensitiveContains(query)
            }
        }

        if selectedTag.lowercased() != "all" {
            result = result.filter {
                $0.tags.contains { $0.lowercased() == selectedTag.lowercased() }
            }
        }

        return result
    }

    // =====================================================
    // TAG LIST
    // =====================================================
    var allTags: [String] {
        Array(Set(memories.flatMap { $0.tags })).sorted()
    }

    // =====================================================
    // SUGGESTIONS
    // =====================================================
    func generateSuggestions() {
        suggestedMemories = Array(memories.prefix(3))
    }

    // =====================================================
    // STORAGE
    // =====================================================
    func loadMemories() {
        memories = storage.load()
        generateSuggestions()
    }

    func save() {
        storage.save(memories)
    }

    // =====================================================
    // AI SUMMARY
    // =====================================================
    private func createSummary(_ text: String) -> String {

        let words = text.split(separator: " ")

        if words.count <= 12 {
            return text
        }

        return words.prefix(12).joined(separator: " ") + "..."
    }

    // =====================================================
    // AI TAG EXTRACTION
    // =====================================================
    private func extractTags(_ text: String) -> [String] {

        let lower = text.lowercased()

        if lower.contains("swift") { return ["ios"] }
        if lower.contains("study") { return ["study"] }

        return ["general"]
    }
}
