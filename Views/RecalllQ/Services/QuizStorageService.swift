import Foundation

// =====================================================
// SERVICE: QuizStorageService
// =====================================================
//
// PURPOSE:
//
// Local persistence service for Quiz objects.
//
// Each authenticated user receives a separate protected
// JSON file.
//
// Example:
//
// User A
//     ↓
// quizzes_<UserA>.json
//
// User B
//     ↓
// quizzes_<UserB>.json
//
// Therefore users cannot load each other's quizzes.
//
// SECURITY:
//
// - Quiz content is NOT stored in UserDefaults.
// - Each user has separate file storage.
// - iOS file protection is enabled.
// - Atomic writes help prevent incomplete files.
// - Existing UserDefaults quizzes are migrated once.
// - Legacy data is removed only after successful migration.
// - No passwords or API keys are stored here.
//
// =====================================================

final class QuizStorageService {

    // =====================================================
    // USER ID
    // =====================================================

    private let userID: String

    // =====================================================
    // STORAGE PREFIX
    // =====================================================

    private let storagePrefix = "quizzes_"

    // =====================================================
    // LEGACY STORAGE PREFIX
    // =====================================================

    //
    // IMPORTANT:
    //
    // This matches the previous QuizViewModel storage:
    //
    // recalllq_quizzes_user_<userID>
    //
    // Existing quizzes will be migrated from that
    // UserDefaults key into the new JSON file.
    //
    // =====================================================

    private let legacyStoragePrefix = "recalllq_quizzes_user_"

    // =====================================================
    // LEGACY SHARED STORAGE KEY
    // =====================================================

    //
    // This was declared in the previous QuizViewModel.
    //
    // It was not actively used by the current implementation,
    // but we keep the reference here so the migration logic
    // remains explicit and safe.
    //
    // =====================================================

    private let legacySharedStorageKey = "saved_quizzes"

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
            label: "QuizStorageQueue.\(userID)"
        )

        // -------------------------------------------------
        // Perform one-time migration if necessary.
        // -------------------------------------------------

        migrateLegacyQuizzesIfNeeded()
    }

    // =====================================================
    // FILE URL
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
    // Makes sure the user identifier is safe to use as
    // a filename.
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
    // SAVE QUIZZES
    // =====================================================

    //
    // Saves ONLY the current user's quizzes.
    //
    // =====================================================

    func save(
        _ quizzes: [Quiz]
    ) {

        queue.async {

            guard let url = self.fileURL else {

                print(
                    "❌ Quiz file URL not available."
                )

                return
            }

            do {

                // -------------------------------------------------
                // Encode quizzes as JSON.
                // -------------------------------------------------

                let encoder = JSONEncoder()

                encoder.outputFormatting = [
                    .prettyPrinted,
                    .sortedKeys
                ]

                encoder.dateEncodingStrategy = .iso8601

                let data = try encoder.encode(
                    quizzes
                )

                // -------------------------------------------------
                // Save atomically with complete file protection.
                // -------------------------------------------------

                try data.write(
                    to: url,
                    options: [
                        .atomic,
                        .completeFileProtection
                    ]
                )

                print("========================================")
                print("💾 QUIZZES SAVED")
                print("========================================")
                print("👤 User: \(self.userID)")
                print("❓ Quizzes: \(quizzes.count)")
                print("📁 File: \(url.lastPathComponent)")
                print("🔐 File protection: Complete")
                print("========================================")

            } catch {

                print("========================================")
                print("❌ QUIZ SAVE ERROR")
                print("========================================")
                print(
                    "Error: \(error.localizedDescription)"
                )
                print("========================================")
            }
        }
    }

    // =====================================================
    // LOAD QUIZZES
    // =====================================================

    //
    // Loads ONLY the current user's quizzes.
    //
    // =====================================================

    func load() -> [Quiz] {

        guard let url = fileURL else {

            print(
                "❌ Quiz file URL not available."
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
                "ℹ️ No saved quizzes found for user \(userID)."
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

            let decoder = JSONDecoder()

            decoder.dateDecodingStrategy = .iso8601

            let quizzes = try decoder.decode(
                [Quiz].self,
                from: data
            )

            print("========================================")
            print("✅ QUIZZES LOADED")
            print("========================================")
            print("👤 User: \(userID)")
            print("❓ Quizzes: \(quizzes.count)")
            print("📁 File: \(url.lastPathComponent)")
            print("========================================")

            return quizzes

        } catch {

            print("========================================")
            print("⚠️ QUIZ LOAD ERROR")
            print("========================================")
            print(
                "Error: \(error.localizedDescription)"
            )
            print("========================================")

            // -------------------------------------------------
            // IMPORTANT:
            //
            // Never automatically delete a user's quiz file
            // if decoding fails.
            //
            // Returning an empty array prevents a crash while
            // preserving the original file for investigation.
            //
            // -------------------------------------------------

            return []
        }
    }

    // =====================================================
    // MIGRATE LEGACY QUIZZES
    // =====================================================

    //
    // PURPOSE:
    //
    // Existing RecalllQ users may already have quizzes
    // stored using the previous UserDefaults implementation.
    //
    // This method moves those quizzes into the new protected
    // JSON file.
    //
    // IMPORTANT:
    //
    // Migration occurs ONLY when the new file does not
    // already exist.
    //
    // =====================================================

    private func migrateLegacyQuizzesIfNeeded() {

        guard let url = fileURL else {

            print(
                "⚠️ Cannot migrate quizzes: file URL unavailable."
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

        // =================================================
        // LOOK FOR CURRENT PER-USER LEGACY STORAGE
        // =================================================

        if let legacyData =
            UserDefaults.standard.data(
                forKey: legacyStorageKey
            ) {

            migrate(
                data: legacyData,
                fromKey: legacyStorageKey,
                to: url
            )

            return
        }

        // =================================================
        // LEGACY SHARED STORAGE
        // =================================================

        //
        // The current QuizViewModel did not use this key,
        // but if an older version of RecalllQ ever stored
        // quizzes here, we deliberately DO NOT automatically
        // assign those quizzes to a user.
        //
        // A shared quiz collection cannot safely be attributed
        // to a specific account.
        //
        // Therefore we leave it untouched.
        //
        // =================================================

        if UserDefaults.standard.data(
            forKey: legacySharedStorageKey
        ) != nil {

            print("========================================")
            print("⚠️ SHARED LEGACY QUIZ DATA FOUND")
            print("========================================")
            print(
                "Shared legacy quizzes were found."
            )
            print(
                "They were NOT automatically assigned to this user."
            )
            print(
                "The shared data remains untouched."
            )
            print("========================================")
        }
    }

    // =====================================================
    // MIGRATE DATA
    // =====================================================

    //
    // Performs a synchronous migration so the old
    // UserDefaults data is removed ONLY after the new
    // protected file has been successfully written.
    //
    // =====================================================

    private func migrate(
        data: Data,
        fromKey key: String,
        to url: URL
    ) {

        do {

            // -------------------------------------------------
            // Decode existing quizzes.
            // -------------------------------------------------

            let decoder = JSONDecoder()

            decoder.dateDecodingStrategy = .iso8601

            let quizzes = try decoder.decode(
                [Quiz].self,
                from: data
            )

            // -------------------------------------------------
            // Encode using the new storage format.
            // -------------------------------------------------

            let encoder = JSONEncoder()

            encoder.outputFormatting = [
                .prettyPrinted,
                .sortedKeys
            ]

            encoder.dateEncodingStrategy = .iso8601

            let newData = try encoder.encode(
                quizzes
            )

            // -------------------------------------------------
            // Write protected file synchronously.
            // -------------------------------------------------

            queue.sync {

                do {

                    try newData.write(
                        to: url,
                        options: [
                            .atomic,
                            .completeFileProtection
                        ]
                    )

                } catch {

                    print("========================================")
                    print("❌ QUIZ MIGRATION WRITE FAILED")
                    print("========================================")
                    print(
                        "Error: \(error.localizedDescription)"
                    )
                    print(
                        "🛡️ Legacy data was preserved."
                    )
                    print("========================================")
                }
            }

            // -------------------------------------------------
            // Confirm that the new file exists before
            // removing the old UserDefaults data.
            // -------------------------------------------------

            guard FileManager.default.fileExists(
                atPath: url.path
            ) else {

                print(
                    "⚠️ New quiz file was not created."
                )

                print(
                    "🛡️ Legacy quiz data was preserved."
                )

                return
            }

            // -------------------------------------------------
            // Remove the old copy ONLY after successful
            // migration.
            // -------------------------------------------------

            UserDefaults.standard.removeObject(
                forKey: key
            )

            print("========================================")
            print("🔄 QUIZ MIGRATION COMPLETE")
            print("========================================")
            print("👤 User: \(userID)")
            print("❓ Quizzes migrated: \(quizzes.count)")
            print("📁 New file: \(url.lastPathComponent)")
            print("🗑️ Legacy UserDefaults copy removed.")
            print("🔐 File protection: Complete")
            print("========================================")

        } catch {

            // -------------------------------------------------
            // IMPORTANT:
            //
            // If migration fails, DO NOT delete the old
            // UserDefaults data.
            //
            // This protects the user's existing quizzes.
            //
            // -------------------------------------------------

            print("========================================")
            print("⚠️ QUIZ MIGRATION FAILED")
            print("========================================")
            print(
                "Error: \(error.localizedDescription)"
            )
            print(
                "🛡️ Existing quiz data was preserved."
            )
            print("========================================")
        }
    }

    // =====================================================
    // DELETE ALL QUIZZES
    // =====================================================

    //
    // Deletes ONLY the currently authenticated user's
    // quiz file.
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
                    print("🗑️ QUIZ FILE DELETED")
                    print("========================================")
                    print("👤 User: \(self.userID)")
                    print("📁 File: \(url.lastPathComponent)")
                    print("========================================")
                }

                // -------------------------------------------------
                // Also remove any remaining per-user legacy copy.
                // -------------------------------------------------

                UserDefaults.standard.removeObject(
                    forKey: self.legacyStorageKey
                )

            } catch {

                print("========================================")
                print("❌ QUIZ DELETE ERROR")
                print("========================================")
                print(
                    "Error: \(error.localizedDescription)"
                )
                print("========================================")
            }
        }
    }
}
