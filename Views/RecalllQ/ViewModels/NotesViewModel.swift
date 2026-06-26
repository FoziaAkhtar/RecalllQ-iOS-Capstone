
import Foundation
import Combine

// =====================================================
// VIEWMODEL: NotesViewModel
// =====================================================
// PURPOSE:
// - Handles all note logic (MVVM)
// - No UI framework dependency
// - Save/load using UserDefaults
// =====================================================


final class NotesViewModel: ObservableObject {

    // =====================================================
    // STATE
    // =====================================================
    @Published var notes: [Note] = []
    @Published var searchText: String = ""

    // =====================================================
    // UNDO SUPPORT
    // =====================================================
    private var lastDeletedNote: Note?

    // =====================================================
    // STORAGE KEY
    // =====================================================
    private let storageKey = "saved_notes"

    // =====================================================
    // INIT
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
    // DELETE NOTE (WITH UNDO SUPPORT)
    // =====================================================
    func deleteNote(id: UUID) {

        if let note = notes.first(where: { $0.id == id }) {
            lastDeletedNote = note
        }

        notes.removeAll { $0.id == id }

        saveNotes()
    }

    // =====================================================
    // UNDO DELETE
    // =====================================================
    func undoDelete() {

        guard let note = lastDeletedNote else { return }

        notes.append(note)
        lastDeletedNote = nil

        saveNotes()
    }

    // =====================================================
    // UPDATE NOTE
    // =====================================================
    func updateNote(id: UUID, newTitle: String, newContent: String) {

        guard let index = notes.firstIndex(where: { $0.id == id }) else { return }

        notes[index].title = newTitle
        notes[index].content = newContent

        saveNotes()
    }

    // =====================================================
    // TOGGLE PIN
    // =====================================================
    func togglePin(id: UUID) {

        guard let index = notes.firstIndex(where: { $0.id == id }) else { return }

        notes[index].isPinned.toggle()

        saveNotes()
    }

    // =====================================================
    // FILTER + SORT NOTES
    // =====================================================
    var filteredNotes: [Note] {

        let result: [Note]

        if searchText.isEmpty {
            result = notes
        } else {
            result = notes.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.content.localizedCaseInsensitiveContains(searchText)
            }
        }

        // pinned notes on top
        return result.sorted { a, b in
            if a.isPinned == b.isPinned {
                return false
            }
            return a.isPinned && !b.isPinned
        }
    }

    // =====================================================
    // SAVE
    // =====================================================
    private func saveNotes() {

        guard let encoded = try? JSONEncoder().encode(notes) else { return }

        UserDefaults.standard.set(encoded, forKey: storageKey)
    }

    // =====================================================
    // LOAD
    // =====================================================
    private func loadNotes() {

        guard
            let data = UserDefaults.standard.data(forKey: storageKey),
            let decoded = try? JSONDecoder().decode([Note].self, from: data)
        else { return }

        notes = decoded
    }
}
