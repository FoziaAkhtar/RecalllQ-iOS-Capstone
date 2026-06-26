
import Foundation
import Combine

// =====================================================
// VIEWMODEL: MemoryViewModel (FINAL CLEAN VERSION)
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

        if selectedTag.lowercased() == "all" {
            return searched
        }

        return searched.filter { memory in
            memory.tags.contains {
                $0.lowercased() == selectedTag.lowercased()
            }
        }
    }

    // =====================================================
    // SEARCH
    // =====================================================
    func searchMemories(_ query: String) -> [Memory] {

        let trimmed = query
            .lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmed.isEmpty else {
            return memories
        }

        return memories.filter {
            $0.title.lowercased().contains(trimmed) ||
            $0.content.lowercased().contains(trimmed) ||
            $0.summary.lowercased().contains(trimmed)
        }
    }

    // =====================================================
    // TAGS
    // =====================================================
    var allTags: [String] {
        let tags = memories.flatMap { $0.tags }
        return Array(Set(tags)).sorted()
    }

    // =====================================================
    // AI SUGGESTIONS
    // =====================================================
    func generateSuggestions() {

        guard !memories.isEmpty else {
            suggestedMemories = []
            return
        }

        let allTags = memories.flatMap { $0.tags }

        let frequency = Dictionary(grouping: allTags, by: { $0 })
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
    // SUMMARY
    // =====================================================
    private func createSummary(_ text: String) -> String {

        let words = text.split(separator: " ")
        let limit = 12

        if words.count <= limit {
            return text
        }

        return words.prefix(limit).joined(separator: " ") + "..."
    }

    // =====================================================
    // TAG EXTRACTION
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
