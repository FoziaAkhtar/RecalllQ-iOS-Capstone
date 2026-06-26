
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

        // FIX: Note initializer MUST support isPinned (if added in model)
        let newNote = Note(title: title, content: content)

        notes.append(newNote)
        saveNotes()
    }

    // =====================================================
    // DELETE NOTE
    // =====================================================
    func deleteNote(id: UUID) {

        // FIX: safer + avoids double lookup issues
        guard let index = notes.firstIndex(where: { $0.id == id }) else { return }

        lastDeletedNote = notes[index]
        notes.remove(at: index)

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

        // FILTER
        if searchText.isEmpty {
            result = notes
        } else {
            result = notes.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.content.localizedCaseInsensitiveContains(searchText)
            }
        }

        // SORT FIX (IMPORTANT BUG FIX)
        return result.sorted { a, b in

            // pinned always first
            if a.isPinned != b.isPinned {
                return a.isPinned && !b.isPinned
            }

            // stable fallback sorting
            return a.title < b.title
        }
    }

    // =====================================================
    // SAVE NOTES
    // =====================================================
    private func saveNotes() {

        guard let encoded = try? JSONEncoder().encode(notes) else { return }

        UserDefaults.standard.set(encoded, forKey: storageKey)
    }

    // =====================================================
    // LOAD NOTES
    // =====================================================
    private func loadNotes() {

        guard
            let data = UserDefaults.standard.data(forKey: storageKey),
            let decoded = try? JSONDecoder().decode([Note].self, from: data)
        else { return }

        notes = decoded
    }
}
