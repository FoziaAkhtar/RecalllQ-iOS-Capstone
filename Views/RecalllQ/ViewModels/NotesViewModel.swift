
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
// - Pin notes
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
    // STORAGE
    // =====================================================

    private var lastDeletedNote: Note?

    private let storageKey = "saved_notes"

    // =====================================================
    // DEPENDENCY
    // =====================================================

    weak var appState: AppState?

    // =====================================================
    // NOTIFICATION SERVICE
    // =====================================================

    private let notificationService =
        NotificationService()

    // =====================================================
    // INIT
    // =====================================================

    init() {

        loadNotes()
    }

    // =====================================================
    // ADD NOTE
    // =====================================================
    // Creates a new note and optionally schedules
    // a study reminder.
    // =====================================================

    func addNote(
        title: String,
        content: String,
        reminderDate: Date? = nil
    ) {

        // =================================================
        // CREATE NOTE
        // =================================================

        let note = Note(
            title: title,
            content: content,
            isPinned: false,
            reminderDate: reminderDate
        )

        // =================================================
        // ADD TO LIST
        // =================================================

        notes.insert(
            note,
            at: 0
        )

        // =================================================
        // SAVE NOTE
        // =================================================

        saveNotes()

        // =================================================
        // CREATE MEMORY THROUGH APPSTATE
        // =================================================

        appState?.createMemoryFromNote(
            title: title,
            content: content
        )

        // =================================================
        // REQUEST NOTIFICATION PERMISSION
        // =================================================

        if reminderDate != nil {

            notificationService.requestPermission()
        }

        // =================================================
        // SCHEDULE REMINDER
        // =================================================

        if let date = reminderDate {

            notificationService.scheduleNotification(
                id: notificationID(
                    for: note
                ),
                title: "📚 RecalllQ Study Reminder",
                body: title.isEmpty
                    ? "Time to review your study notes."
                    : title,
                date: date
            )
        }
    }

    // =====================================================
    // UPDATE NOTE
    // =====================================================
    // Updates existing note information.
    // Reminder information is preserved.
    // =====================================================

    func updateNote(
        id: UUID,
        newTitle: String,
        newContent: String
    ) {

        guard let index =
            notes.firstIndex(
                where: { $0.id == id }
            )
        else {
            return
        }

        // =================================================
        // UPDATE CONTENT
        // =================================================

        notes[index].title =
            newTitle

        notes[index].content =
            newContent

        notes[index].updatedAt =
            Date()

        // =================================================
        // SAVE
        // =================================================

        saveNotes()
    }

    // =====================================================
    // DELETE NOTE
    // =====================================================
    // Deletes the note and cancels its reminder.
    // =====================================================

    func deleteNote(
        id: UUID
    ) {

        guard let index =
            notes.firstIndex(
                where: { $0.id == id }
            )
        else {
            return
        }

        // =================================================
        // SAVE FOR UNDO
        // =================================================

        lastDeletedNote =
            notes[index]

        // =================================================
        // CANCEL REMINDER
        // =================================================

        notificationService.cancelNotification(
            id: notificationID(
                for: notes[index]
            )
        )

        // =================================================
        // REMOVE NOTE
        // =================================================

        notes.remove(
            at: index
        )

        // =================================================
        // SAVE
        // =================================================

        saveNotes()
    }

    // =====================================================
    // UNDO DELETE
    // =====================================================
    // Restores the last deleted note.
    // =====================================================

    func undoDelete() {

        guard let note =
            lastDeletedNote
        else {
            return
        }

        // =================================================
        // RESTORE NOTE
        // =================================================

        notes.insert(
            note,
            at: 0
        )

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

            notificationService.scheduleNotification(
                id: notificationID(
                    for: note
                ),
                title: "📚 RecalllQ Study Reminder",
                body: note.title,
                date: date
            )
        }
    }

    // =====================================================
    // PIN TOGGLE
    // =====================================================

    func togglePin(
        id: UUID
    ) {

        guard let index =
            notes.firstIndex(
                where: { $0.id == id }
            )
        else {
            return
        }

        notes[index]
            .isPinned
            .toggle()

        notes[index]
            .updatedAt =
            Date()

        saveNotes()
    }

    // =====================================================
    // FILTERED NOTES
    // =====================================================

    var filteredNotes: [Note] {

        let filtered =
            searchText.isEmpty
            ? notes
            : notes.filter {

                $0.title
                    .localizedCaseInsensitiveContains(
                        searchText
                    )
                ||
                $0.content
                    .localizedCaseInsensitiveContains(
                        searchText
                    )
            }

        return filtered.sorted {

            if $0.isPinned != $1.isPinned {

                return $0.isPinned &&
                    !$1.isPinned
            }

            return $0.title < $1.title
        }
    }

    // =====================================================
    // NOTIFICATION ID
    // =====================================================
    // Gives every note its own notification identifier.
    // =====================================================

    private func notificationID(
        for note: Note
    ) -> String {

        return "RecalllQ.Reminder.\(note.id.uuidString)"
    }

    // =====================================================
    // SAVE
    // =====================================================

    private func saveNotes() {

        guard let encoded =
            try? JSONEncoder().encode(
                notes
            )
        else {
            print(
                "❌ Could not save notes."
            )
            return
        }

        UserDefaults.standard.set(
            encoded,
            forKey: storageKey
        )
    }

    // =====================================================
    // LOAD
    // =====================================================

    private func loadNotes() {

        guard
            let data =
                UserDefaults.standard.data(
                    forKey: storageKey
                ),

            let decoded =
                try? JSONDecoder().decode(
                    [Note].self,
                    from: data
                )

        else {

            print(
                "ℹ️ No saved notes found."
            )

            return
        }

        notes =
            decoded
    }
}
