
import Foundation
import Combine

// =====================================================
// VIEWMODEL: NotesViewModel
// =====================================================
// PURPOSE:
// Handles ALL business logic for Notes app.
// View should NOT contain logic — only UI.
// =====================================================

final class NotesViewModel: ObservableObject {

    // =====================================================
    // STATE
    // PURPOSE:
    // @Published ensures UI updates automatically.
    // =====================================================
    @Published var notes: [Note] = []
    @Published var searchText: String = ""

    // =====================================================
    // UNDO SUPPORT
    // PURPOSE:
    // Stores last deleted note so user can restore it.
    // =====================================================
    private var lastDeletedNote: Note?

    // =====================================================
    // STORAGE KEY
    // PURPOSE:
    // Used for saving notes in UserDefaults.
    // =====================================================
    private let storageKey = "saved_notes"

    // =====================================================
    // INIT
    // PURPOSE:
    // Loads saved notes when app starts.
    // =====================================================
    init() {
        loadNotes()
    }

    // =====================================================
    // ADD NOTE
    // PURPOSE:
    // Creates a new note and saves it permanently.
    // =====================================================
    func addNote(title: String, content: String) {

        let newNote = Note(title: title, content: content)
        notes.append(newNote)

        saveNotes()
    }

    // =====================================================
    // DELETE NOTE
    // PURPOSE:
    // Removes note and stores it for UNDO feature.
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
    // PURPOSE:
    // Restores last deleted note.
    // =====================================================
    func undoDelete() {

        guard let note = lastDeletedNote else { return }

        notes.append(note)
        lastDeletedNote = nil

        saveNotes()
    }

    // =====================================================
    // UPDATE NOTE
    // PURPOSE:
    // Allows editing existing note content.
    // =====================================================
    func updateNote(id: UUID, newTitle: String, newContent: String) {

        guard let index = notes.firstIndex(where: { $0.id == id }) else { return }

        notes[index].title = newTitle
        notes[index].content = newContent

        saveNotes()
    }

    // =====================================================
    // TOGGLE PIN
    // PURPOSE:
    // Marks/unmarks a note as important.
    // Pinned notes appear at the top.
    // =====================================================
    func togglePin(id: UUID) {

        guard let index = notes.firstIndex(where: { $0.id == id }) else { return }

        notes[index].isPinned.toggle()

        saveNotes()
    }

    // =====================================================
    // FILTER + SORT NOTES
    // PURPOSE:
    // - Filters notes based on search text
    // - Sorts pinned notes to top
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

        return result.sorted { a, b in
            if a.isPinned == b.isPinned {
                return false
            }
            return a.isPinned && !b.isPinned
        }
    }

    // =====================================================
    // SAVE NOTES
    // PURPOSE:
    // Converts notes into JSON and stores in device memory.
    // =====================================================
    private func saveNotes() {

        guard let encoded = try? JSONEncoder().encode(notes) else { return }

        UserDefaults.standard.set(encoded, forKey: storageKey)
    }

    // =====================================================
    // LOAD NOTES
    // PURPOSE:
    // Restores saved notes when app launches.
    // =====================================================
    private func loadNotes() {

        guard
            let data = UserDefaults.standard.data(forKey: storageKey),
            let decoded = try? JSONDecoder().decode([Note].self, from: data)
        else { return }

        notes = decoded
    }
}
