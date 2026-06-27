
import Foundation
import SwiftUI
import Combine

// =====================================================
// VIEWMODEL: MemoryViewModel
// =====================================================
// PURPOSE:
// Handles state + persistence only
// AI logic moved to MemoryEngine
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
    // DEPENDENCIES
    // =====================================================
    private let storage = MemoryStorageService()
    private let engine = MemoryEngine()

    // =====================================================
    // INIT
    // =====================================================
    init() {
        loadMemories()
    }

    // =====================================================
    // ADD MEMORY (USES MEMORY ENGINE)
    // =====================================================
    func addMemory(title: String, content: String) {

        let memory = engine.generateMemory(
            from: title,
            content: content
        )

        memories.insert(memory, at: 0)

        save()
        generateSuggestions()
    }

    // =====================================================
    // DELETE MEMORY
    // =====================================================
    func deleteMemory(id: UUID) {

        memories.removeAll { $0.id == id }

        save()
        generateSuggestions()
    }

    // =====================================================
    // FILTERED MEMORIES
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

        if selectedTag != "all" {
            result = result.filter {
                $0.tags.contains(selectedTag)
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

        suggestedMemories = memories
            .sorted { $0.dateCreated > $1.dateCreated }
            .prefix(3)
            .map { $0 }
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
}
