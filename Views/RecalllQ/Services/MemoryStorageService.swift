
import Foundation

// =====================================================
// SERVICE: MemoryStorageService
// =====================================================
//
// PURPOSE:
//
// Local persistence for Memory objects.
//
// IMPORTANT:
//
// Each authenticated user gets their own memory file.
//
// Example:
//
// User A → memories_user_A.json
// User B → memories_user_B.json
//
// Guest → memories___guest__.json
//
// This prevents users from seeing each other's memories.
//
// =====================================================

final class MemoryStorageService {

    // =====================================================
    // USER ID
    // =====================================================

    private let userID: String

    // =====================================================
    // THREAD SAFETY
    // =====================================================

    private let queue: DispatchQueue

    // =====================================================
    // INIT
    // =====================================================

    init(userID: String) {

        self.userID = userID

        self.queue = DispatchQueue(
            label: "MemoryStorageQueue.\(userID)"
        )
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
                "memories_\(safeUserID).json"
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
            .lowercased()
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )
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
    // SAVE MEMORIES
    // =====================================================
    //
    // IMPORTANT:
    //
    // This save operation is SYNCHRONOUS.
    //
    // The method does not return until the memory file
    // has actually been written.
    //
    // This is especially important for:
    //
    // Guest Mode
    // User switching
    // Logout
    // Login
    // App restart
    //
    // =====================================================

    func save(_ memories: [Memory]) {

        queue.sync {

            guard let url = self.fileURL else {

                print(
                    "❌ Memory file URL not available."
                )

                return
            }

            do {

                let encoder = JSONEncoder()

                encoder.outputFormatting = [
                    .prettyPrinted
                ]

                let data = try encoder.encode(
                    memories
                )

                try data.write(
                    to: url,
                    options: [.atomic]
                )

                print(
                    "========================================"
                )

                print(
                    "💾 MEMORIES SAVED TO DISK"
                )

                print(
                    "========================================"
                )

                print(
                    "👤 User: \(self.userID)"
                )

                print(
                    "📚 Memory count: \(memories.count)"
                )

                print(
                    "📁 File: \(url.lastPathComponent)"
                )

                print(
                    "========================================"
                )

            } catch {

                print(
                    "========================================"
                )

                print(
                    "❌ MEMORY SAVE ERROR"
                )

                print(
                    "========================================"
                )

                print(
                    "👤 User: \(self.userID)"
                )

                print(
                    "Error: \(error.localizedDescription)"
                )

                print(
                    "========================================"
                )
            }
        }
    }

    // =====================================================
    // LOAD MEMORIES
    // =====================================================

    func load() -> [Memory] {

        guard let url = fileURL else {

            print(
                "❌ Memory file URL not available."
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
                "ℹ️ No saved memories found for user \(userID)"
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

            let memories = try JSONDecoder().decode(
                [Memory].self,
                from: data
            )

            print(
                "========================================"
            )

            print(
                "✅ MEMORIES LOADED"
            )

            print(
                "========================================"
            )

            print(
                "👤 User: \(userID)"
            )

            print(
                "📚 Memory count: \(memories.count)"
            )

            print(
                "📁 File: \(url.lastPathComponent)"
            )

            print(
                "========================================"
            )

            return memories

        } catch {

            print(
                "========================================"
            )

            print(
                "⚠️ MEMORY LOAD ERROR"
            )

            print(
                "========================================"
            )

            print(
                "👤 User: \(userID)"
            )

            print(
                "Error: \(error.localizedDescription)"
            )

            print(
                "========================================"
            )

            // Do NOT delete the user's file.
            //
            // Returning [] prevents the app from crashing.

            return []
        }
    }

    // =====================================================
    // DELETE USER MEMORY FILE
    // =====================================================
    //
    // Used when an account is deleted or its local data
    // needs to be completely removed.
    //
    // =====================================================

    func deleteAll() {

        guard let url = fileURL else {
            return
        }

        queue.sync {

            do {

                if FileManager.default.fileExists(
                    atPath: url.path
                ) {

                    try FileManager.default.removeItem(
                        at: url
                    )

                    print(
                        "🗑️ Deleted all memories for user \(self.userID)"
                    )
                }

            } catch {

                print(
                    "❌ Could not delete memory file:",
                    error.localizedDescription
                )
            }
        }
    }
}
