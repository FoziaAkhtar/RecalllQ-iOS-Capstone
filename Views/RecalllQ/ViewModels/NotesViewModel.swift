
import Foundation
import Combine

// =====================================================
// VIEW MODEL: NotesViewModel
// =====================================================
// PURPOSE:
// Manages all note-related operations for RecalllQ.
//
// USER DATA ISOLATION:
// Each authenticated user receives a separate storage key.
//
// Example:
//
// User A → saved_notes_userA
// User B → saved_notes_userB
//
// Therefore users cannot load each other's notes.
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

    // Base key only.
    //
    // The actual key is created using the current user's
    // unique identifier.
    private let storageKeyPrefix = "saved_notes_"

    // =====================================================
    // CURRENT USER
    // =====================================================

    // The account email is currently being used as the
    // unique identifier for local development.
    //
    // Later, when Firebase/API authentication is connected,
    // this can become the backend user ID.

    private var currentUserID: String? {

        guard
            let email = UserDefaults.standard.string(
                forKey: "recalllq_account"
            ),
            !email.isEmpty
        else {
            return nil
        }

        return makeSafeUserID(email)
    }

    // =====================================================
    // USER-SPECIFIC STORAGE KEY
    // =====================================================

    private var storageKey: String? {

        guard let userID = currentUserID else {
            return nil
        }

        return storageKeyPrefix + userID
    }

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

        // IMPORTANT:
        // We intentionally do NOT load a generic shared
        // "saved_notes" key.
        //
        // Notes are always loaded for the authenticated user.

        loadNotes()
    }

    // =====================================================
    // SWITCH USER
    // =====================================================
    // IMPORTANT FOR ISSUE #69
    //
    // This method is called when:
    //
    // 1. A user signs in
    // 2. A new account is created
    // 3. A different user signs in
    // 4. A user signs out
    //
    // It clears the previous user's notes from memory
    // before loading the new user's notes.
    // =====================================================

    func switchUser(userID: String?) {

        print("========================================")
        print("🔄 SWITCHING NOTES USER")
        print("========================================")

        // -------------------------------------------------
        // STEP 1: Clear previous user's UI data
        // -------------------------------------------------

        notes = []
        searchText = ""
        lastDeletedNote = nil

        print("🧹 Previous user's notes cleared from UI.")

        // -------------------------------------------------
        // STEP 2: Handle logout
        // -------------------------------------------------

        guard let userID = userID, !userID.isEmpty else {

            UserDefaults.standard.removeObject(
                forKey: "recalllq_account"
            )

            print("🚪 No active user.")
            print("📚 Notes cleared.")

            print("========================================")

            return
        }

        // -------------------------------------------------
        // STEP 3: Set the active account
        // -------------------------------------------------

        UserDefaults.standard.set(
            userID,
            forKey: "recalllq_account"
        )

        UserDefaults.standard.synchronize()

        print("👤 Active account changed.")
        print("Account: \(userID)")

        // -------------------------------------------------
        // STEP 4: Load ONLY the new user's notes
        // -------------------------------------------------

        loadNotes()

        print(
            "📚 Loaded \(notes.count) notes for new user."
        )

        print("========================================")
    }

    // =====================================================
    // CREATE USER-SAFE ID
    // =====================================================

    private func makeSafeUserID(_ email: String) -> String {

        email
            .lowercased()
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )
            .replacingOccurrences(
                of: "@",
                with: "_"
            )
            .replacingOccurrences(
                of: ".",
                with: "_"
            )
            .replacingOccurrences(
                of: " ",
                with: "_"
            )
    }

    // =====================================================
    // LOAD DATA FOR CURRENT USER
    // =====================================================

    func loadCurrentUserData() {

        print("========================================")
        print("👤 LOADING USER NOTES")
        print("========================================")

        guard currentUserID != nil else {

            print("ℹ️ No authenticated user found.")

            notes = []
            searchText = ""
            lastDeletedNote = nil

            return
        }

        loadNotes()

        print(
            "📚 Loaded \(notes.count) notes for current user."
        )

        print("========================================")
    }

    // =====================================================
    // CLEAR CURRENT USER DATA FROM MEMORY
    // =====================================================

    func clearCurrentUserData() {

        notes = []
        searchText = ""
        lastDeletedNote = nil

        print(
            "🧹 Current user's notes cleared from memory."
        )
    }

    // =====================================================
    // ADD NOTE
    // =====================================================

    func addNote(
        title: String,
        content: String,
        reminderDate: Date? = nil
    ) {

        let cleanTitle = title.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        let cleanContent = content.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !cleanTitle.isEmpty || !cleanContent.isEmpty else {

            print("❌ Cannot create empty note.")

            return
        }

        // IMPORTANT:
        // Do not allow notes to be created without
        // an authenticated account.

        guard currentUserID != nil else {

            print(
                "❌ Cannot create note: no authenticated user."
            )

            return
        }

        let note = Note(
            title: cleanTitle,
            content: cleanContent,
            isPinned: false,
            reminderDate: reminderDate
        )

        notes.insert(
            note,
            at: 0
        )

        saveNotes()

        // =================================================
        // CREATE AI MEMORY
        // =================================================

        appState?.createMemoryFromNote(
            title: cleanTitle,
            content: cleanContent
        )

        // =================================================
        // SCHEDULE REMINDER
        // =================================================

        if let date = reminderDate,
           date > Date() {

            notificationService.requestPermission()

            notificationService.scheduleNotification(
                id: notificationID(
                    for: note
                ),
                title: "📚 RecalllQ Study Reminder",
                body: cleanTitle.isEmpty
                    ? "Time to review your study notes."
                    : cleanTitle,
                date: date
            )
        }

        print("✅ Note created.")
        print("Title: \(cleanTitle)")
        print("User: \(currentUserID ?? "Unknown")")
        print("Total notes: \(notes.count)")
    }

    // =====================================================
    // UPDATE NOTE
    // =====================================================

    func updateNote(
        id: UUID,
        newTitle: String,
        newContent: String,
        reminderDate: Date?
    ) {

        guard let index = notes.firstIndex(
            where: { $0.id == id }
        ) else {

            print("❌ Note not found.")

            return
        }

        guard currentUserID != nil else {

            print(
                "❌ Cannot update note: no authenticated user."
            )

            return
        }

        let cleanTitle = newTitle.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        let cleanContent = newContent.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !cleanTitle.isEmpty || !cleanContent.isEmpty else {

            print("❌ Cannot save an empty note.")

            return
        }

        // =================================================
        // CANCEL OLD REMINDER
        // =================================================

        notificationService.cancelNotification(
            id: notificationID(
                for: notes[index]
            )
        )

        // =================================================
        // UPDATE NOTE
        // =================================================

        notes[index].title = cleanTitle
        notes[index].content = cleanContent
        notes[index].reminderDate = reminderDate
        notes[index].updatedAt = Date()

        // =================================================
        // SAVE
        // =================================================

        saveNotes()

        // =================================================
        // SCHEDULE NEW REMINDER
        // =================================================

        if let date = reminderDate,
           date > Date() {

            notificationService.requestPermission()

            notificationService.scheduleNotification(
                id: notificationID(
                    for: notes[index]
                ),
                title: "📚 RecalllQ Study Reminder",
                body: cleanTitle.isEmpty
                    ? "Time to review your study notes."
                    : cleanTitle,
                date: date
            )
        }

        // =================================================
        // UPDATE AI MEMORY
        // =================================================

        appState?.createMemoryFromNote(
            title: cleanTitle,
            content: cleanContent
        )

        print("✏️ Note updated successfully.")
    }

    // =====================================================
    // DELETE NOTE
    // =====================================================

    func deleteNote(id: UUID) {

        guard let index = notes.firstIndex(
            where: { $0.id == id }
        ) else {

            print("❌ Could not delete note.")

            return
        }

        guard currentUserID != nil else {

            print(
                "❌ Cannot delete note: no authenticated user."
            )

            return
        }

        let deletedNote = notes[index]

        lastDeletedNote = deletedNote

        notificationService.cancelNotification(
            id: notificationID(
                for: deletedNote
            )
        )

        notes.remove(
            at: index
        )

        saveNotes()

        print("🗑️ Note deleted.")
        print("Deleted: \(deletedNote.title)")
        print("Remaining notes: \(notes.count)")
    }

    // =====================================================
    // UNDO DELETE
    // =====================================================

    func undoDelete() {

        guard let note = lastDeletedNote else {

            print("ℹ️ Nothing to restore.")

            return
        }

        guard currentUserID != nil else {

            print(
                "❌ Cannot restore note: no authenticated user."
            )

            return
        }

        notes.insert(
            note,
            at: 0
        )

        lastDeletedNote = nil

        saveNotes()

        if let date = note.reminderDate,
           date > Date() {

            notificationService.requestPermission()

            notificationService.scheduleNotification(
                id: notificationID(
                    for: note
                ),
                title: "📚 RecalllQ Study Reminder",
                body: note.title.isEmpty
                    ? "Time to review your study notes."
                    : note.title,
                date: date
            )
        }

        print("↩️ Note restored.")
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

    func togglePin(id: UUID) {

        guard let index = notes.firstIndex(
            where: { $0.id == id }
        ) else {

            print("❌ Note not found.")

            return
        }

        guard currentUserID != nil else {

            print(
                "❌ Cannot change pin: no authenticated user."
            )

            return
        }

        notes[index].isPinned.toggle()
        notes[index].updatedAt = Date()

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

    func deleteAllNotes() {

        guard currentUserID != nil else {

            print(
                "❌ Cannot delete notes: no authenticated user."
            )

            return
        }

        for note in notes {

            notificationService.cancelNotification(
                id: notificationID(
                    for: note
                )
            )
        }

        notes.removeAll()

        lastDeletedNote = nil

        saveNotes()

        print("🗑️ All notes deleted.")
    }

    // =====================================================
    // FILTERED NOTES
    // =====================================================

    var filteredNotes: [Note] {

        let query = searchText.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        let filtered: [Note]

        if query.isEmpty {

            filtered = notes

        } else {

            filtered = notes.filter {

                $0.title.localizedCaseInsensitiveContains(query)
                ||
                $0.content.localizedCaseInsensitiveContains(query)
            }
        }

        return filtered.sorted {

            if $0.isPinned != $1.isPinned {

                return $0.isPinned && !$1.isPinned
            }

            return $0.updatedAt > $1.updatedAt
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

        guard let storageKey = storageKey else {

            print(
                "⚠️ Notes not saved: no authenticated user."
            )

            return
        }

        do {

            let data = try JSONEncoder().encode(
                notes
            )

            UserDefaults.standard.set(
                data,
                forKey: storageKey
            )

            print(
                "💾 Saved \(notes.count) notes."
            )

            print(
                "🔐 Storage key: \(storageKey)"
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

        guard let storageKey = storageKey else {

            print(
                "ℹ️ No authenticated user. Notes not loaded."
            )

            notes = []

            return
        }

        guard let data =
                UserDefaults.standard.data(
                    forKey: storageKey
                )
        else {

            // IMPORTANT:
            // A missing key means this is likely a new user.
            //
            // We DO NOT load another user's notes.
            // We simply start with an empty collection.

            print(
                "🆕 No saved notes found for current user."
            )

            notes = []

            return
        }

        do {

            notes = try JSONDecoder().decode(
                [Note].self,
                from: data
            )

            print(
                "✅ Loaded \(notes.count) notes for current user."
            )

        } catch {

            print(
                "❌ Could not load notes: \(error)"
            )

            notes = []
        }
    }
}
