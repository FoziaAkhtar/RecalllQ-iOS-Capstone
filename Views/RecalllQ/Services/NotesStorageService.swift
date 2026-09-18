import Foundation

// =====================================================
// SERVICE: NotesStorageService
// =====================================================
//
// PURPOSE:
//
// Local persistence service for Note objects.
//
// IMPORTANT:
//
// Each authenticated user receives their own notes file.
//
// Example:
//
// User A
//     ↓
// notes_<UserA>.json
//
// User B
//     ↓
// notes_<UserB>.json
//
// Therefore users cannot load each other's notes.
//
// SECURITY:
//
// - Notes are stored in the app's sandbox.
// - Notes are NOT stored permanently in UserDefaults.
// - iOS file protection is enabled.
// - Existing UserDefaults notes can be migrated once.
// - Atomic writes help prevent incomplete files.
// - No passwords or API keys are stored here.
//
// =====================================================

final class NotesStorageService {

    // =====================================================
    // USER ID
    // =====================================================

    private let userID: String

    // =====================================================
    // STORAGE PREFIX
    // =====================================================

    private let storagePrefix = "notes_"

    // =====================================================
    // LEGACY USERDEFAULTS PREFIX
    // =====================================================

    //
    // IMPORTANT:
    //
    // This matches the storage used by the previous
    // NotesViewModel.
    //
    // Existing notes will be migrated from:
    //
    // saved_notes_<userID>
    //
    // into:
    //
    // notes_<userID>.json
    //
    // =====================================================

    private let legacyStoragePrefix = "saved_notes_"

    // =====================================================
    // THREAD SAFETY
    // =====================================================

    //
    // All file writes and deletions use this queue.
    //
    // =====================================================

    private let queue: DispatchQueue

    // =====================================================
    // INIT
    // =====================================================

    init(userID: String) {

        self.userID = userID

        self.queue = DispatchQueue(
            label: "NotesStorageQueue.\(userID)"
        )

        // -------------------------------------------------
        // Perform one-time migration if necessary.
        // -------------------------------------------------

        migrateLegacyNotesIfNeeded()
    }

    // =====================================================
    // SAFE FILE URL
    // =====================================================

    private var fileURL: URL? {

        FileManager.default
            .urls(
                for: .documentDirectory,
                in: .userDomainMask
            )
            .first?
            .appendingPathComponent(
                "\(storagePrefix)\(safeUserID).json"
            )
    }

    // =====================================================
    // SAFE USER ID
    // =====================================================

    //
    // Makes sure the user ID is safe to use as a
    // filename.
    //
    // =====================================================

    private var safeUserID: String {

        userID
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )
            .lowercased()
            .replacingOccurrences(
                of: "/",
                with: "_"
            )
            .replacingOccurrences(
                of: "\\",
                with: "_"
            )
            .replacingOccurrences(
                of: " ",
                with: "_"
            )
            .replacingOccurrences(
                of: "@",
                with: "_"
            )
            .replacingOccurrences(
                of: ".",
                with: "_"
            )
    }

    // =====================================================
    // LEGACY USERDEFAULTS KEY
    // =====================================================

    private var legacyStorageKey: String {

        legacyStoragePrefix + safeUserID
    }

    // =====================================================
    // SAVE NOTES
    // =====================================================

    //
    // Saves ONLY the current user's notes.
    //
    // =====================================================

    func save(_ notes: [Note]) {

        queue.async {

            guard let url = self.fileURL else {

                print(
                    "❌ Notes file URL not available."
                )

                return
            }

            do {

                // -------------------------------------------------
                // Encode notes as JSON.
                // -------------------------------------------------

                let encoder = JSONEncoder()

                encoder.outputFormatting = [
                    .prettyPrinted,
                    .sortedKeys
                ]

                let data = try encoder.encode(notes)

                // -------------------------------------------------
                // Save atomically.
                // -------------------------------------------------

                try data.write(
                    to: url,
                    options: [
                        .atomic,
                        .completeFileProtection
                    ]
                )

                print("========================================")
                print("💾 NOTES SAVED")
                print("========================================")
                print("👤 User: \(self.userID)")
                print("📚 Notes: \(notes.count)")
                print("📁 File: \(url.lastPathComponent)")
                print("🔐 File protection: Complete")
                print("========================================")

            } catch {

                print("========================================")
                print("❌ NOTES SAVE ERROR")
                print("========================================")
                print(
                    "Error: \(error.localizedDescription)"
                )
                print("========================================")
            }
        }
    }

    // =====================================================
    // LOAD NOTES
    // =====================================================

    //
    // Loads ONLY the current user's notes.
    //
    // IMPORTANT:
    //
    // This method does not look for another user's file.
    //
    // =====================================================

    func load() -> [Note] {

        guard let url = fileURL else {

            print(
                "❌ Notes file URL not available."
            )

            return []
        }

        // =================================================
        // FILE DOES NOT EXIST
        // =================================================

        guard FileManager.default.fileExists(
            atPath: url.path
        ) else {

            print(
                "ℹ️ No saved notes found for user \(userID)."
            )

            return []
        }

        // =================================================
        // LOAD FILE
        // =================================================

        do {

            let data = try Data(
                contentsOf: url
            )

            let notes = try JSONDecoder().decode(
                [Note].self,
                from: data
            )

            print("========================================")
            print("✅ NOTES LOADED")
            print("========================================")
            print("👤 User: \(userID)")
            print("📚 Notes: \(notes.count)")
            print("📁 File: \(url.lastPathComponent)")
            print("========================================")

            return notes

        } catch {

            print("========================================")
            print("⚠️ NOTES LOAD ERROR")
            print("========================================")
            print(
                "Error: \(error.localizedDescription)"
            )
            print("========================================")

            // -------------------------------------------------
            // IMPORTANT:
            //
            // Never delete the user's file automatically.
            //
            // Returning [] prevents the application from
            // crashing while preserving the user's data.
            // -------------------------------------------------

            return []
        }
    }

    // =====================================================
    // MIGRATE LEGACY USERDEFAULTS NOTES
    // =====================================================

    //
    // PURPOSE:
    //
    // Existing RecalllQ users may already have notes saved
    // using the previous UserDefaults implementation.
    //
    // This method moves those notes into the new protected
    // JSON file.
    //
    // IMPORTANT:
    //
    // Migration happens ONLY when the new file does not
    // already exist.
    //
    // This prevents an existing file from being overwritten.
    //
    // =====================================================

    private func migrateLegacyNotesIfNeeded() {

        guard let url = fileURL else {

            print(
                "⚠️ Cannot migrate notes: file URL unavailable."
            )

            return
        }

        // -------------------------------------------------
        // If the new file already exists, migration is not
        // necessary.
        // -------------------------------------------------

        guard !FileManager.default.fileExists(
            atPath: url.path
        ) else {

            return
        }

        // -------------------------------------------------
        // Look for the previous UserDefaults storage.
        // -------------------------------------------------

        guard let legacyData =
                UserDefaults.standard.data(
                    forKey: legacyStorageKey
                )
        else {

            // -------------------------------------------------
            // No old notes exist.
            // -------------------------------------------------

            return
        }

        do {

            // -------------------------------------------------
            // Decode the old notes.
            // -------------------------------------------------

            let notes = try JSONDecoder().decode(
                [Note].self,
                from: legacyData
            )

            // -------------------------------------------------
            // Encode using the new storage format.
            // -------------------------------------------------

            let encoder = JSONEncoder()

            encoder.outputFormatting = [
                .prettyPrinted,
                .sortedKeys
            ]

            let newData = try encoder.encode(
                notes
            )

            // -------------------------------------------------
            // Write to protected file storage.
            // -------------------------------------------------

            try newData.write(
                to: url,
                options: [
                    .atomic,
                    .completeFileProtection
                ]
            )

            // -------------------------------------------------
            // Remove the old UserDefaults copy ONLY after
            // the new file has been written successfully.
            // -------------------------------------------------

            UserDefaults.standard.removeObject(
                forKey: legacyStorageKey
            )

            print("========================================")
            print("🔄 NOTES MIGRATION COMPLETE")
            print("========================================")
            print("👤 User: \(userID)")
            print("📚 Notes migrated: \(notes.count)")
            print("📁 New file: \(url.lastPathComponent)")
            print("🗑️ Legacy UserDefaults copy removed.")
            print("🔐 File protection: Complete")
            print("========================================")

        } catch {

            // -------------------------------------------------
            // IMPORTANT:
            //
            // If migration fails, DO NOT delete the legacy
            // UserDefaults data.
            //
            // This protects the user's existing notes.
            // -------------------------------------------------

            print("========================================")
            print("⚠️ NOTES MIGRATION FAILED")
            print("========================================")
            print(
                "Error: \(error.localizedDescription)"
            )
            print("🛡️ Existing notes were preserved.")
            print("========================================")
        }
    }

    // =====================================================
    // DELETE ALL NOTES
    // =====================================================

    //
    // Deletes ONLY the currently authenticated user's
    // notes file.
    //
    // =====================================================

    func deleteAll() {

        guard let url = fileURL else {

            return
        }

        queue.async {

            do {

                if FileManager.default.fileExists(
                    atPath: url.path
                ) {

                    try FileManager.default.removeItem(
                        at: url
                    )

                    print("========================================")
                    print("🗑️ NOTES FILE DELETED")
                    print("========================================")
                    print("👤 User: \(self.userID)")
                    print("📁 File: \(url.lastPathComponent)")
                    print("========================================")
                }

                // -------------------------------------------------
                // Also remove any legacy copy if one still exists.
                // -------------------------------------------------

                UserDefaults.standard.removeObject(
                    forKey: self.legacyStorageKey
                )

            } catch {

                print("========================================")
                print("❌ NOTES DELETE ERROR")
                print("========================================")
                print(
                    "Error: \(error.localizedDescription)"
                )
                print("========================================")
            }
        }
    }
}
