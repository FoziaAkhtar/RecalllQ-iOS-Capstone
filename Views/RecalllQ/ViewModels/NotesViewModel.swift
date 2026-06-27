
import Foundation
import Combine

final class NotesViewModel: ObservableObject {

    // =====================================================
    // STATE
    // =====================================================
    @Published var notes: [Note] = []
    @Published var searchText: String = ""

    // =====================================================
    // STORAGE
    // =====================================================
    private var lastDeletedNote: Note?
    private let storageKey = "saved_notes"

    // =====================================================
    // DEPENDENCY 
    // =====================================================
    weak var appState: AppState?

    // =====================================================
    // INIT
    // =====================================================
    init() {
        loadNotes()
    }

    // =====================================================
    // ADD NOTE
    // =====================================================
    func addNote(title: String, content: String, reminderDate: Date? = nil) {

        let note = Note(
            title: title,
            content: content,
            isPinned: false,
            reminderDate: reminderDate
        )

        notes.insert(note, at: 0)
        saveNotes()

        // =====================================================
        // CREATE MEMORY VIA APPSTATE
        // =====================================================
        appState?.createMemoryFromNote(
            title: title,
            content: content
        )

        // =====================================================
        // REMINDER NOTIFICATION
        // =====================================================
        if let date = reminderDate {
            NotificationService().scheduleNotification(
                title: title,
                body: content,
                date: date
            )
        }
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
    // DELETE NOTE
    // =====================================================
    func deleteNote(id: UUID) {

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

        notes.insert(note, at: 0)
        lastDeletedNote = nil

        saveNotes()
    }

    // =====================================================
    // PIN TOGGLE
    // =====================================================
    func togglePin(id: UUID) {

        guard let index = notes.firstIndex(where: { $0.id == id }) else { return }

        notes[index].isPinned.toggle()
        saveNotes()
    }

    // =====================================================
    // FILTERED NOTES
    // =====================================================
    var filteredNotes: [Note] {

        let filtered = searchText.isEmpty
        ? notes
        : notes.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.content.localizedCaseInsensitiveContains(searchText)
        }

        return filtered.sorted {
            if $0.isPinned != $1.isPinned {
                return $0.isPinned && !$1.isPinned
            }
            return $0.title < $1.title
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
