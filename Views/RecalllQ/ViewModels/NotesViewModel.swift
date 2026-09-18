
import Foundation
import Combine

// =====================================================
// VIEW MODEL: NotesViewModel
// =====================================================
//
// PURPOSE:
//
// Manages all note-related operations for RecalllQ.
//
// USER DATA ISOLATION:
//
// Each authenticated user receives a separate
// NotesStorageService and therefore a separate notes file.
//
// Example:
//
// User A
//     ↓
// notes_userA.json
//
// User B
//     ↓
// notes_userB.json
//
// Therefore users cannot load each other's notes.
//
// SECURITY:
//
// Notes are no longer stored directly in UserDefaults.
//
// NotesStorageService handles:
//
// - Per-user JSON storage
// - One-time migration from old UserDefaults
// - Atomic file writes
// - iOS file protection
//
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
    // CURRENT USER
    // =====================================================
    //
    // The account identifier is currently the normalized
    // email address for local development.
    //
    // Guest mode uses:
    //
    // __guest__
    //
    // Later, when Firebase/API authentication is connected,
    // this can become the backend user ID.
    //
    // =====================================================

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
    // STORAGE SERVICE
    // =====================================================

    private var storage: NotesStorageService?

    // =====================================================
    // APP STATE
    // =====================================================

    //
    // AppState is the central coordinator for RecalllQ.
    //
    // NotesViewModel uses AppState to start the:
    //
    // Note
    //   ↓
    // Memory
    //
    // pipeline.
    //
    // weak prevents a retain cycle because AppState owns
    // NotesViewModel.
    //
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
        //
        // We intentionally do NOT load notes here.
        //
        // At initialization time AppState may not have
        // identified the active user yet.
        //
        // Notes are loaded only after AppState calls:
        //
        // switchUser(userID:)
        //
        notes = []
        storage = nil

        print("📝 NotesViewModel initialized.")
    }

    // =====================================================
    // SWITCH USER
    // =====================================================

    //
    // IMPORTANT FOR ISSUE #69
    //
    // This method is called when:
    //
    // 1. A user signs in
    // 2. A new account is created
    // 3. A different user signs in
    // 4. A guest account is selected
    // 5. A user signs out
    //
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
        storage = nil

        print("🧹 Previous user's notes cleared from UI.")

        // -------------------------------------------------
        // STEP 2: Handle logout
        // -------------------------------------------------

        guard
            let userID = userID,
            !userID.isEmpty
        else {

            UserDefaults.standard.removeObject(
                forKey: "recalllq_account"
            )

            print("🚪 No active user.")
            print("📚 Notes cleared.")
            print("========================================")

            return
        }

        // -------------------------------------------------
        // STEP 3: Normalize user identifier
        // -------------------------------------------------

        let safeUserID = makeSafeUserID(userID)

        // -------------------------------------------------
        // STEP 4: Set active account
        // -------------------------------------------------

        UserDefaults.standard.set(
            userID,
            forKey: "recalllq_account"
        )

        UserDefaults.standard.synchronize()

        print("👤 Active account changed.")
        print("Account: \(userID)")
        print("Safe ID: \(safeUserID)")

        // -------------------------------------------------
        // STEP 5: Create storage for ONLY this user
        // -------------------------------------------------

        storage = NotesStorageService(
            userID: safeUserID
        )

        // -------------------------------------------------
        // STEP 6: Load ONLY this user's notes
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

    private func makeSafeUserID(
        _ email: String
    ) -> String {

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
            .replacingOccurrences(
                of: "/",
                with: "_"
            )
            .replacingOccurrences(
                of: "\\",
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
            storage = nil

            return
        }

        // -------------------------------------------------
        // Make sure storage service exists
        // -------------------------------------------------

        if storage == nil,
           let userID = currentUserID {

            storage = NotesStorageService(
                userID: userID
            )
        }

        // -------------------------------------------------
        // Load notes
        // -------------------------------------------------

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
        storage = nil

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

        print("========================================")
        print("📝 ADDING NEW NOTE")
        print("========================================")

        // -------------------------------------------------
        // STEP 1: Clean input
        // -------------------------------------------------

        let cleanTitle = title.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        let cleanContent = content.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard
            !cleanTitle.isEmpty ||
            !cleanContent.isEmpty
        else {

            print("❌ Cannot create empty note.")

            return
        }

        // -------------------------------------------------
        // STEP 2: Verify active user
        // -------------------------------------------------

        guard let activeUserID = currentUserID else {

            print(
                "❌ Cannot create note: no authenticated user."
            )

            return
        }

        print("👤 Active user: \(activeUserID)")

        // -------------------------------------------------
        // STEP 3: Make sure storage exists
        // -------------------------------------------------

        guard storage != nil else {

            print(
                "❌ Cannot create note: storage is unavailable."
            )

            return
        }

        // -------------------------------------------------
        // STEP 4: Create note
        // -------------------------------------------------

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

        // -------------------------------------------------
        // STEP 5: Save note
        // -------------------------------------------------

        saveNotes()

        print("✅ Note saved successfully.")
        print("Title: \(cleanTitle)")
        print("Content length: \(cleanContent.count)")
        print("Total notes: \(notes.count)")

        // =================================================
        // STEP 6: CREATE AI MEMORY
        // =================================================
        //
        // IMPORTANT:
        //
        // This is the connection:
        //
        // Note
        //   ↓
        // AppState
        //   ↓
        // Memory
        //
        // We explicitly verify AppState exists before
        // attempting to create the Memory.
        //
        // =================================================

        guard let appState = appState else {

            print("❌ MEMORY PIPELINE ERROR")
            print("❌ NotesViewModel.appState is NIL.")
            print("❌ Note was saved, but Memory could not be created.")
            print("========================================")

            return
        }

        print("🧠 Starting Note → Memory pipeline...")
        print("🧠 Sending note to AppState...")
        print("🧠 Title: \(cleanTitle)")
        print("🧠 Content length: \(cleanContent.count)")

        appState.createMemoryFromNote(
            title: cleanTitle,
            content: cleanContent
        )

        print("🧠 Memory generation request sent to AppState.")

        // =================================================
        // STEP 7: SCHEDULE REMINDER
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

        print("========================================")
        print("✅ NOTE CREATION COMPLETE")
        print("========================================")
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

        guard
            let index = notes.firstIndex(
                where: { $0.id == id }
            )
        else {

            print("❌ Note not found.")

            return
        }

        guard currentUserID != nil else {

            print(
                "❌ Cannot update note: no authenticated user."
            )

            return
        }

        guard storage != nil else {

            print(
                "❌ Cannot update note: storage is unavailable."
            )

            return
        }

        let cleanTitle = newTitle.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        let cleanContent = newContent.trimmingCharacters(
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

        if let appState = appState {

            print("🧠 Updating Memory from edited Note...")

            appState.createMemoryFromNote(
                title: cleanTitle,
                content: cleanContent
            )

        } else {

            print("❌ Could not update Memory.")
            print("❌ NotesViewModel.appState is NIL.")
        }

        print("✏️ Note updated successfully.")
    }

    // =====================================================
    // DELETE NOTE
    // =====================================================

    func deleteNote(
        id: UUID
    ) {

        guard
            let index = notes.firstIndex(
                where: { $0.id == id }
            )
        else {

            print("❌ Could not delete note.")

            return
        }

        guard currentUserID != nil else {

            print(
                "❌ Cannot delete note: no authenticated user."
            )

            return
        }

        guard storage != nil else {

            print(
                "❌ Cannot delete note: storage is unavailable."
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

        guard
            let note = lastDeletedNote
        else {

            print("ℹ️ Nothing to restore.")

            return
        }

        guard currentUserID != nil else {

            print(
                "❌ Cannot restore note: no authenticated user."
            )

            return
        }

        guard storage != nil else {

            print(
                "❌ Cannot restore note: storage is unavailable."
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

    func togglePin(
        id: UUID
    ) {

        guard
            let index = notes.firstIndex(
                where: { $0.id == id }
            )
        else {

            print("❌ Note not found.")

            return
        }

        guard currentUserID != nil else {

            print(
                "❌ Cannot change pin: no authenticated user."
            )

            return
        }

        guard storage != nil else {

            print(
                "❌ Cannot change pin: storage is unavailable."
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

        guard storage != nil else {

            print(
                "❌ Cannot delete notes: storage is unavailable."
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

                $0.title.localizedCaseInsensitiveContains(
                    query
                )
                ||
                $0.content.localizedCaseInsensitiveContains(
                    query
                )
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

        guard currentUserID != nil else {

            print(
                "⚠️ Notes not saved: no authenticated user."
            )

            return
        }

        guard
            let storage = storage
        else {

            print(
                "⚠️ Notes not saved: storage unavailable."
            )

            return
        }

        storage.save(
            notes
        )

        print(
            "💾 Saved \(notes.count) notes using protected file storage."
        )
    }

    // =====================================================
    // LOAD NOTES
    // =====================================================

    private func loadNotes() {

        guard currentUserID != nil else {

            print(
                "ℹ️ No authenticated user. Notes not loaded."
            )

            notes = []

            return
        }

        // -------------------------------------------------
        // Make sure storage exists
        // -------------------------------------------------

        guard
            let storage = storage
        else {

            if let userID = currentUserID {

                self.storage = NotesStorageService(
                    userID: userID
                )
            }

            guard
                let storage = self.storage
            else {

                print(
                    "❌ Could not create notes storage."
                )

                notes = []

                return
            }

            notes = storage.load()

            print(
                "✅ Loaded \(notes.count) notes for current user."
            )

            return
        }

        // -------------------------------------------------
        // Load notes from protected file storage.
        //
        // NotesStorageService also performs the one-time
        // migration from the previous UserDefaults
        // storage when necessary.
        // -------------------------------------------------

        notes = storage.load()

        print(
            "✅ Loaded \(notes.count) notes for current user."
        )
    }
}

