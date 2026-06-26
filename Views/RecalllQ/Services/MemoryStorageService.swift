
import Foundation

// =====================================================
// SERVICE: MemoryStorageService
// =====================================================
// PURPOSE:
// Handles local persistence of Memory objects
// using JSON encoding/decoding in Documents directory
// =====================================================

final class MemoryStorageService {

    // =====================================================
    // FILE CONFIGURATION
    // =====================================================
    private let fileName = "memories.json"

    // =====================================================
    // SAFE FILE URL (Documents Directory)
    // =====================================================
    private var fileURL: URL {
        FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first!
            .appendingPathComponent(fileName)
    }

    // =====================================================
    // SAVE MEMORIES TO DEVICE STORAGE
    // =====================================================
    func save(_ memories: [Memory]) {

        do {
            let encoder = JSONEncoder()

            // Better formatting for debugging (optional but useful)
            encoder.outputFormatting = .prettyPrinted

            // Encode Memory array into JSON
            let data = try encoder.encode(memories)

            // Write file safely (atomic prevents corruption)
            try data.write(to: fileURL, options: [.atomic])

        } catch {
            print("❌ MemoryStorageService SAVE ERROR:", error.localizedDescription)
        }
    }

    // =====================================================
    // LOAD MEMORIES FROM DEVICE STORAGE
    // =====================================================
    func load() -> [Memory] {

        do {
            let data = try Data(contentsOf: fileURL)

            let decoder = JSONDecoder()

            // Decode JSON back into Memory array
            return try decoder.decode([Memory].self, from: data)

        } catch {
            // Normal case: first app launch OR missing file
            print("⚠️ MemoryStorageService LOAD: No saved data found")
            return []
        }
    }

    // =====================================================
    // CLEAR ALL SAVED DATA (RESET FEATURE)
    // =====================================================
    func clear() {

        do {
            if FileManager.default.fileExists(atPath: fileURL.path) {
                try FileManager.default.removeItem(at: fileURL)
            }
        } catch {
            print("❌ MemoryStorageService CLEAR ERROR:", error.localizedDescription)
        }
    }
}
