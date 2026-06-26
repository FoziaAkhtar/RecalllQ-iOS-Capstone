
import Foundation
import SwiftUI
import Combine
// =====================================================
// VIEWMODEL: MemoryViewModel
// =====================================================
// PURPOSE:
// Handles Memory data for UI (MVVM)
// =====================================================

final class MemoryViewModel: ObservableObject {

    // =====================================================
    // STATE
    // =====================================================
    @Published var memories: [Memory] = []

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

        memories.append(memory)
    }

    // =====================================================
    // SUMMARY (RULE BASED)
    // =====================================================
    private func createSummary(_ text: String) -> String {
        let words = text.split(separator: " ")
        return words.prefix(10).joined(separator: " ") + "..."
    }

    // =====================================================
    // TAGS (SIMPLE LOGIC)
    // =====================================================
    private func extractTags(_ text: String) -> [String] {

        let keywords = ["study", "exam", "swift", "ios", "lecture"]

        let lower = text.lowercased()

        let found = keywords.filter { lower.contains($0) }

        return found.isEmpty ? ["general"] : found
    }
}
