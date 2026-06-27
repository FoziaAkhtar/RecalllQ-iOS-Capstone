
import Foundation

// =====================================================
// SERVICE: MemoryStorageService
// PURPOSE: Local persistence for Memory objects
// =====================================================

final class MemoryStorageService {

    private let fileName = "memories.json"

    private var fileURL: URL {
        FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first!
            .appendingPathComponent(fileName)
    }

    // SAVE MEMORIES
    func save(_ memories: [Memory]) {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted

            let data = try encoder.encode(memories)
            try data.write(to: fileURL, options: [.atomic])

        } catch {
            print("❌ SAVE ERROR:", error.localizedDescription)
        }
    }

    // LOAD MEMORIES
    func load() -> [Memory] {
        do {
            let data = try Data(contentsOf: fileURL)
            return try JSONDecoder().decode([Memory].self, from: data)

        } catch {
            print("ℹ️ No saved memories found")
            return []
        }
    }
}
