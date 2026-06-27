
import Foundation

// =====================================================
// SERVICE: MemoryStorageService
// PURPOSE: Local persistence for Memory objects
// =====================================================

final class MemoryStorageService {

    private let fileName = "memories.json"

    // =====================================================
    // THREAD SAFETY
    // =====================================================
    private let queue = DispatchQueue(label: "MemoryStorageQueue")

    // =====================================================
    // SAFE FILE URL
    // =====================================================
    private var fileURL: URL? {
        FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first?
            .appendingPathComponent(fileName)
    }

    // =====================================================
    // SAVE MEMORIES
    // =====================================================
    func save(_ memories: [Memory]) {

        queue.async {

            guard let url = self.fileURL else {
                print("❌ File URL not available")
                return
            }

            do {
                let encoder = JSONEncoder()
                encoder.outputFormatting = .prettyPrinted

                let data = try encoder.encode(memories)
                try data.write(to: url, options: [.atomic])

            } catch {
                print("❌ SAVE ERROR:", error.localizedDescription)
            }
        }
    }

    // =====================================================
    // LOAD MEMORIES
    // =====================================================
    func load() -> [Memory] {

        guard let url = fileURL else {
            print("❌ File URL not available")
            return []
        }

        // File doesn't exist yet (normal first run)
        guard FileManager.default.fileExists(atPath: url.path) else {
            print("ℹ️ No saved memories found")
            return []
        }

        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode([Memory].self, from: data)

        } catch {
            print("⚠️ LOAD ERROR (resetting file):", error.localizedDescription)

            // fallback to prevent app being stuck with corrupted file
            return []
        }
    }
}
