
import Foundation
import Combine

// =====================================================
// VIEWMODEL: NotesViewModel
// =====================================================
// PURPOSE:
// - Handles all note logic (MVVM)
// - No UI framework dependency (clean architecture)
// - Safe for testing + future SwiftData upgrade
//
// RESPONSIBILITIES:
// ✔ Add notes
// ✔ Delete notes (by ID)
// ✔ Search notes
// ✔ Save/load notes
// =====================================================

final class NotesViewModel: ObservableObject {

    // =====================================================
    // STATE (UI automatically updates when changed)
    // =====================================================
    @Published var notes: [Note] = []
    @Published var searchText: String = ""

    // =====================================================
    // STORAGE KEY
    // =====================================================
    private let storageKey = "saved_notes"

    // =====================================================
    // INIT (LOAD SAVED DATA)
    // =====================================================
    init() {
        loadNotes()
    }

    // =====================================================
    // ADD NOTE
    // =====================================================
    func addNote(title: String, content: String) {
        let newNote = Note(title: title, content: content)
        notes.append(newNote)
        saveNotes()
    }

    // =====================================================
    // DELETE NOTE (CLEAN VERSION - NO SWIFTUI REQUIRED)
    // =====================================================
    func deleteNote(id: UUID) {
        notes.removeAll { $0.id == id }
        saveNotes()
    }

    // =====================================================
    // FILTERED NOTES (SEARCH LOGIC)
    // =====================================================
    var filteredNotes: [Note] {
        guard !searchText.isEmpty else { return notes }

        return notes.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.content.localizedCaseInsensitiveContains(searchText)
        }
    }

    // =====================================================
    // SAVE NOTES (UserDefaults)
    // =====================================================
    private func saveNotes() {
        guard let encoded = try? JSONEncoder().encode(notes) else { return }
        UserDefaults.standard.set(encoded, forKey: storageKey)
    }

    // =====================================================
    // LOAD NOTES (UserDefaults)
    // =====================================================
    private func loadNotes() {
        guard
            let data = UserDefaults.standard.data(forKey: storageKey),
            let decoded = try? JSONDecoder().decode([Note].self, from: data)
        else { return }

        notes = decoded
    }
}
