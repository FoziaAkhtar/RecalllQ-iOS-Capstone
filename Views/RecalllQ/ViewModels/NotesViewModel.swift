
import Foundation
import Combine

// =====================================================
// VIEW MODEL: NotesViewModel
// =====================================================
// PURPOSE:
// Manages all note-related operations for RecalllQ.
//
// FEATURES:
// - Create notes
// - Edit notes
// - Delete notes
// - Undo delete
// - Pin / unpin notes
// - Search notes
// - Save notes locally
// - Load notes locally
// - Schedule study reminders
// - Cancel reminders
// - Create AI memories
//
// DATA FLOW:
//
// NotesView
//     ↓
// NotesViewModel
//     ↓
// Note
//     ↓
// Local Storage
//
// Reminder:
//
// NotesView
//     ↓
// NotesViewModel
//     ↓
// NotificationService
//     ↓
// iOS Notification
// =====================================================

final class NotesViewModel: ObservableObject {

    // =====================================================
    // STATE
    // =====================================================

    @Published var notes: [Note] = []

    @Published var searchText: String = ""

    // =====================================================
    // DELETE / UNDO
    // =====================================================

    private var lastDeletedNote: Note?

    // =====================================================
    // STORAGE
    // =====================================================

    private let storageKey = "saved_notes"

    // =====================================================
    // APP STATE
    // =====================================================

    weak var appState: AppState?

    // =====================================================
    // NOTIFICATION SERVICE
    // =====================================================

    private let notificationService = NotificationService()

    // =====================================================
    // INIT
    // =====================================================

    init() {

        loadNotes()
    }

    // =====================================================
    // ADD NOTE
    // =====================================================

    func addNote(
        title: String,
        content: String,
        reminderDate: Date? = nil
    ) {

        let cleanTitle =
            title.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        let cleanContent =
            content.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        // =================================================
        // VALIDATION
        // =================================================

        guard
            !cleanTitle.isEmpty ||
            !cleanContent.isEmpty
        else {

            print("❌ Cannot create empty note.")

            return
        }

        // =================================================
        // CREATE NOTE
        // =================================================

        let note = Note(
            title: cleanTitle,
            content: cleanContent,
            isPinned: false,
            reminderDate: reminderDate
        )

        // =================================================
        // ADD TO NOTES
        // =================================================

        notes.insert(
            note,
            at: 0
        )

        // =================================================
        // SAVE
        // =================================================

        saveNotes()

        // =================================================
        // CREATE AI MEMORY
        // =================================================

        appState?.createMemoryFromNote(
            title: cleanTitle,
            content: cleanContent
        )

        // =================================================
        // REMINDER
        // =================================================

        if let date = reminderDate {

            notificationService.requestPermission()

            notificationService.scheduleNotification(
                id: notificationID(
                    for: note
                ),
                title: "📚 RecalllQ Study Reminder",
                body:
                    cleanTitle.isEmpty
                    ? "Time to review your study notes."
                    : cleanTitle,
                date: date
            )
        }

        print("✅ Note created.")
        print("Title: \(cleanTitle)")
        print("Total notes: \(notes.count)")
    }

    // =====================================================
    // UPDATE NOTE
    // =====================================================

    func updateNote(
        id: UUID,
        newTitle: String,
        newContent: String
    ) {

        guard let index =
            notes.firstIndex(
                where: {
                    $0.id == id
                }
            )
        else {

            print("❌ Note not found.")

            return
        }

        let cleanTitle =
            newTitle.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        let cleanContent =
            newContent.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        guard
            !cleanTitle.isEmpty ||
            !cleanContent.isEmpty
        else {

            print("❌ Cannot save an empty note.")

            return
        }

        // =================================================
        // UPDATE
        // =================================================

        notes[index].title =
            cleanTitle

        notes[index].content =
            cleanContent

        notes[index].updatedAt =
            Date()

        // =================================================
        // SAVE
        // =================================================

        saveNotes()

        print("✏️ Note updated.")
    }

    // =====================================================
    // DELETE NOTE
    // =====================================================
    // Deletes one note.
    //
    // The deleted note is temporarily stored so the user
    // can use Undo.
    // =====================================================

    func deleteNote(
        id: UUID
    ) {

        guard let index =
            notes.firstIndex(
                where: {
                    $0.id == id
                }
            )
        else {

            print("❌ Could not delete note.")
            print("Note ID not found.")

            return
        }

        // =================================================
        // SAVE NOTE FOR UNDO
        // =================================================

        let deletedNote =
            notes[index]

        lastDeletedNote =
            deletedNote

        // =================================================
        // CANCEL REMINDER
        // =================================================

        notificationService.cancelNotification(
            id: notificationID(
                for: deletedNote
            )
        )

        // =================================================
        // REMOVE NOTE
        // =================================================

        notes.remove(
            at: index
        )

        // =================================================
        // SAVE UPDATED NOTES
        // =================================================

        saveNotes()

        print("🗑️ Note deleted.")
        print("Deleted: \(deletedNote.title)")
        print("Remaining notes: \(notes.count)")
    }

    // =====================================================
    // UNDO DELETE
    // =====================================================

    func undoDelete() {

        guard let note =
            lastDeletedNote
        else {

            print("ℹ️ Nothing to restore.")

            return
        }

        // =================================================
        // RESTORE NOTE
        // =================================================

        notes.insert(
            note,
            at: 0
        )

        // =================================================
        // CLEAR UNDO
        // =================================================

        lastDeletedNote =
            nil

        // =================================================
        // SAVE
        // =================================================

        saveNotes()

        // =================================================
        // RESTORE REMINDER
        // =================================================

        if let date =
            note.reminderDate,
           date > Date() {

            notificationService.requestPermission()

            notificationService.scheduleNotification(
                id: notificationID(
                    for: note
                ),
                title:
                    "📚 RecalllQ Study Reminder",
                body:
                    note.title.isEmpty
                    ? "Time to review your study notes."
                    : note.title,
                date: date
            )
        }

        print("↩️ Note restored.")
        print("Restored: \(note.title)")
    }

    // =====================================================
    // CLEAR UNDO
    // =====================================================

    func clearUndo() {

        lastDeletedNote = nil
    }

    // =====================================================
    // PIN / UNPIN
    // =====================================================

    func togglePin(
        id: UUID
    ) {

        guard let index =
            notes.firstIndex(
                where: {
                    $0.id == id
                }
            )
        else {

            print("❌ Note not found.")

            return
        }

        notes[index].isPinned.toggle()

        notes[index].updatedAt =
            Date()

        saveNotes()

        print(
            notes[index].isPinned
            ? "📌 Note pinned."
            : "📌 Note unpinned."
        )
    }

    // =====================================================
    // DELETE ALL NOTES
    // =====================================================
    // Useful for testing.
    // =====================================================

    func deleteAllNotes() {

        // Cancel all reminders first.

        for note in notes {

            notificationService.cancelNotification(
                id: notificationID(
                    for: note
                )
            )
        }

        // Remove all notes.

        notes.removeAll()

        // Clear undo.

        lastDeletedNote = nil

        // Save empty array.

        saveNotes()

        print("🗑️ All notes deleted.")
    }

    // =====================================================
    // FILTERED NOTES
    // =====================================================

    var filteredNotes: [Note] {

        let query =
            searchText.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        let filtered: [Note]

        if query.isEmpty {

            filtered =
                notes

        } else {

            filtered =
                notes.filter {

                    $0.title
                        .localizedCaseInsensitiveContains(
                            query
                        )
                    ||
                    $0.content
                        .localizedCaseInsensitiveContains(
                            query
                        )
                }
        }

        // =================================================
        // PINNED NOTES FIRST
        // =================================================

        return filtered.sorted {

            if $0.isPinned != $1.isPinned {

                return $0.isPinned &&
                    !$1.isPinned
            }

            // Newest updated note first.

            return $0.updatedAt >
                $1.updatedAt
        }
    }

    // =====================================================
    // TOTAL NOTES
    // =====================================================

    var totalNotes: Int {

        notes.count
    }

    // =====================================================
    // PINNED NOTES
    // =====================================================

    var pinnedNotes: Int {

        notes.filter {
            $0.isPinned
        }.count
    }

    // =====================================================
    // NOTES WITH REMINDERS
    // =====================================================

    var notesWithReminders: Int {

        notes.filter {
            $0.reminderDate != nil
        }.count
    }

    // =====================================================
    // NOTIFICATION ID
    // =====================================================

    private func notificationID(
        for note: Note
    ) -> String {

        "RecalllQ.Reminder.\(note.id.uuidString)"
    }

    // =====================================================
    // SAVE NOTES
    // =====================================================

    func saveNotes() {

        do {

            let data =
                try JSONEncoder().encode(
                    notes
                )

            UserDefaults.standard.set(
                data,
                forKey: storageKey
            )

            print(
                "💾 Saved \(notes.count) notes."
            )

        } catch {

            print(
                "❌ Could not save notes: \(error)"
            )
        }
    }

    // =====================================================
    // LOAD NOTES
    // =====================================================

    private func loadNotes() {

        guard
            let data =
                UserDefaults.standard.data(
                    forKey: storageKey
                )
        else {

            print(
                "ℹ️ No saved notes found."
            )

            return
        }

        do {

            notes =
                try JSONDecoder().decode(
                    [Note].self,
                    from: data
                )

            print(
                "✅ Loaded \(notes.count) notes."
            )

        } catch {

            print(
                "❌ Could not load notes: \(error)"
            )
        }
    }
}

