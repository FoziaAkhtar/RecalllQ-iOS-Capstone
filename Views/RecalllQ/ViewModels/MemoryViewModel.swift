
import Foundation
import SwiftUI
import Combine

// =====================================================
// VIEWMODEL: MemoryViewModel
// =====================================================
// PURPOSE:
//
// - Manages memory state
// - Handles memory creation
// - Handles memory deletion
// - Handles search and category filtering
// - Generates personalized study recommendations
// - Handles memory persistence
// - Supports USER-SPECIFIC memory isolation
//
// IMPORTANT:
//
// Each authenticated user gets their own:
//
// MemoryStorageService(userID: userID)
//
// Example:
//
// Student A
//     ↓
// MemoryStorageService(userID: "studentA@email.com")
//     ↓
// memories_<studentA>.json
//
// Student B
//     ↓
// MemoryStorageService(userID: "studentB@email.com")
//     ↓
// memories_<studentB>.json
//
// =====================================================

@MainActor
final class MemoryViewModel: ObservableObject {

    // =====================================================
    // MAIN MEMORY STATE
    // =====================================================

    @Published var memories: [Memory] = []

    // =====================================================
    // SEARCH
    // =====================================================

    @Published var searchText: String = ""

    // =====================================================
    // CATEGORY
    // =====================================================

    @Published var selectedTag: String = "all"

    // =====================================================
    // PERSONALIZED SUGGESTIONS
    // =====================================================

    @Published var suggestedMemories: [Memory] = []

    // =====================================================
    // CURRENT USER
    // =====================================================

    @Published private(set) var currentUserID: String?

    // =====================================================
    // USER-SPECIFIC STORAGE
    // =====================================================

    private var storage: MemoryStorageService?

    // =====================================================
    // LOCAL MEMORY ENGINE
    // =====================================================

    private let engine = MemoryEngine()

    // =====================================================
    // INIT
    // =====================================================

    init() {

        // IMPORTANT:
        //
        // Do NOT load any memories here.
        //
        // At this point there may not be an authenticated
        // user.
        //
        // Memories are loaded only after:
        //
        // switchUser(to: userID)
        //

        currentUserID = nil
        storage = nil

        memories = []
        suggestedMemories = []

        print("🧠 MemoryViewModel initialized with no user.")
    }

    // =====================================================
    // SWITCH USER
    // =====================================================
    //
    // This is the most important method for data isolation.
    //
    // When Student B logs in:
    //
    // 1. Student A's memories are removed from memory.
    // 2. Student A's storage reference is removed.
    // 3. Student B becomes current user.
    // 4. Student B's storage is created.
    // 5. ONLY Student B's memories are loaded.
    //
    // =====================================================

    func switchUser(to userID: String) {

        let cleanUserID = userID
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        // -------------------------------------------------
        // SECURITY CHECK
        // -------------------------------------------------

        guard !cleanUserID.isEmpty else {

            print(
                "❌ MemoryViewModel cannot switch to empty user ID."
            )

            clearCurrentUserData()

            return
        }

        // -------------------------------------------------
        // IMPORTANT:
        //
        // Always clear the previous user's data BEFORE
        // loading another user's data.
        // -------------------------------------------------

        memories = []
        suggestedMemories = []

        searchText = ""
        selectedTag = "all"

        // -------------------------------------------------
        // Remove old storage reference.
        // -------------------------------------------------

        storage = nil

        // -------------------------------------------------
        // Set new current user.
        // -------------------------------------------------

        currentUserID = cleanUserID

        // -------------------------------------------------
        // Create NEW storage for this user.
        // -------------------------------------------------

        storage = MemoryStorageService(
            userID: cleanUserID
        )

        print("========================================")
        print("🔄 MEMORY USER SWITCH")
        print("========================================")
        print("👤 New user: \(cleanUserID)")
        print("🧹 Previous memory data cleared.")
        print("📁 Creating user-specific memory storage.")
        print("========================================")

        // -------------------------------------------------
        // Load ONLY this user's memories.
        // -------------------------------------------------

        loadMemories()

        print("========================================")
        print("✅ MEMORY USER SWITCH COMPLETE")
        print("========================================")
        print("👤 User: \(cleanUserID)")
        print("📚 Memories loaded: \(memories.count)")
        print("========================================")
    }

    // =====================================================
    // CLEAR CURRENT USER DATA
    // =====================================================
    //
    // IMPORTANT:
    //
    // This clears the ViewModel only.
    //
    // It does NOT delete the user's saved memories.
    //
    // Therefore:
    //
    // Student A logs out
    // ↓
    // Student A data removed from memory
    //
    // Student A logs in again
    // ↓
    // Student A's saved memories return.
    //
    // =====================================================

    func clearCurrentUserData() {

        memories = []
        suggestedMemories = []

        searchText = ""
        selectedTag = "all"

        currentUserID = nil
        storage = nil

        print("========================================")
        print("🧹 MEMORY DATA CLEARED FROM MEMORY")
        print("========================================")
    }

    // =====================================================
    // ADD MEMORY
    // =====================================================

    func addMemory(
        title: String,
        content: String
    ) {

        // -------------------------------------------------
        // REQUIRE USER
        // -------------------------------------------------

        guard let userID = currentUserID else {

            print(
                "❌ Cannot add memory: no authenticated user."
            )

            return
        }

        // -------------------------------------------------
        // REQUIRE STORAGE
        // -------------------------------------------------

        guard storage != nil else {

            print(
                "❌ Cannot add memory: user storage is unavailable."
            )

            return
        }

        // -------------------------------------------------
        // CLEAN INPUT
        // -------------------------------------------------

        let cleanTitle = title
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        let cleanContent = content
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        // -------------------------------------------------
        // VALIDATION
        // -------------------------------------------------

        guard !cleanTitle.isEmpty ||
                !cleanContent.isEmpty else {

            print(
                "❌ Cannot add empty memory."
            )

            return
        }

        // -------------------------------------------------
        // CREATE MEMORY
        // -------------------------------------------------

        let memory = engine.generateMemory(
            from: cleanTitle,
            content: cleanContent
        )

        // -------------------------------------------------
        // ADD TO CURRENT USER'S MEMORY ARRAY
        // -------------------------------------------------

        memories.insert(
            memory,
            at: 0
        )

        // -------------------------------------------------
        // SAVE TO CURRENT USER'S STORAGE
        // -------------------------------------------------

        save()

        // -------------------------------------------------
        // UPDATE SUGGESTIONS
        // -------------------------------------------------

        generateSuggestions()

        print("========================================")
        print("🧠 MEMORY CREATED")
        print("========================================")
        print("👤 User: \(userID)")
        print("📝 Title: \(memory.title)")
        print("========================================")
    }

    // =====================================================
    // DELETE MEMORY
    // =====================================================

    func deleteMemory(id: UUID) {

        guard currentUserID != nil else {

            print(
                "❌ Cannot delete memory: no authenticated user."
            )

            return
        }

        memories.removeAll {
            $0.id == id
        }

        save()

        generateSuggestions()

        if selectedTag != "all" &&
            !allTags.contains(selectedTag) {

            selectedTag = "all"
        }
    }

    // =====================================================
    // FILTERED MEMORIES
    // =====================================================

    var filteredMemories: [Memory] {

        var result = memories

        let query = searchText
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        // -------------------------------------------------
        // SEARCH
        // -------------------------------------------------

        if !query.isEmpty {

            result = result.filter { memory in

                let titleMatch =
                    memory.title
                        .localizedCaseInsensitiveContains(
                            query
                        )

                let contentMatch =
                    memory.content
                        .localizedCaseInsensitiveContains(
                            query
                        )

                let summaryMatch =
                    memory.summary
                        .localizedCaseInsensitiveContains(
                            query
                        )

                let tagMatch =
                    memory.tags.contains {
                        $0.localizedCaseInsensitiveContains(
                            query
                        )
                    }

                return
                    titleMatch ||
                    contentMatch ||
                    summaryMatch ||
                    tagMatch
            }
        }

        // -------------------------------------------------
        // CATEGORY FILTER
        // -------------------------------------------------

        if selectedTag != "all" {

            result = result.filter { memory in

                memory.tags.contains {

                    $0.caseInsensitiveCompare(
                        selectedTag
                    ) == .orderedSame
                }
            }
        }

        return result
    }

    // =====================================================
    // ALL TAGS
    // =====================================================

    var allTags: [String] {

        let tags = memories.flatMap {
            $0.tags
        }

        return Array(Set(tags))
            .sorted {
                $0.localizedCaseInsensitiveCompare(
                    $1
                ) == .orderedAscending
            }
    }

    // =====================================================
    // PERSONALIZED STUDY SUGGESTIONS
    // =====================================================

    func generateSuggestions() {

        guard !memories.isEmpty else {

            suggestedMemories = []

            return
        }

        let now = Date()

        let scoredMemories =
            memories
                .filter {
                    !$0.title.isEmpty ||
                    !$0.content.isEmpty
                }
                .map {
                    memory -> (
                        memory: Memory,
                        score: Double
                    ) in

                    // =====================================
                    // IMPORTANCE
                    // =====================================

                    let importanceScore =
                        Double(memory.importance) * 2.0

                    // =====================================
                    // CONFIDENCE
                    // =====================================

                    let confidenceScore =
                        (1.0 - memory.confidence) * 6.0

                    // =====================================
                    // AGE
                    // =====================================

                    let ageInDays =
                        max(
                            0,
                            Calendar.current.dateComponents(
                                [.day],
                                from: memory.dateCreated,
                                to: now
                            ).day ?? 0
                        )

                    let ageScore =
                        min(
                            Double(ageInDays) * 0.25,
                            4.0
                        )

                    // =====================================
                    // STUDY TAGS
                    // =====================================

                    let studyTags: Set<String> = [
                        "study",
                        "exam",
                        "assignment",
                        "programming",
                        "ios",
                        "school"
                    ]

                    let matchingTags =
                        memory.tags.filter {
                            studyTags.contains(
                                $0.lowercased()
                            )
                        }.count

                    let categoryScore =
                        Double(matchingTags) * 1.5

                    // =====================================
                    // RECENCY
                    // =====================================

                    let recencyScore: Double

                    if ageInDays == 0 {

                        recencyScore = 2.0

                    } else if ageInDays <= 2 {

                        recencyScore = 1.5

                    } else if ageInDays <= 7 {

                        recencyScore = 1.0

                    } else {

                        recencyScore = 0.0
                    }

                    // =====================================
                    // TOTAL
                    // =====================================

                    let totalScore =
                        importanceScore +
                        confidenceScore +
                        ageScore +
                        categoryScore +
                        recencyScore

                    return (
                        memory: memory,
                        score: totalScore
                    )
                }

        // -------------------------------------------------
        // SORT
        // -------------------------------------------------

        suggestedMemories =
            scoredMemories
                .sorted {

                    if $0.score != $1.score {

                        return $0.score > $1.score
                    }

                    return
                        $0.memory.dateCreated >
                        $1.memory.dateCreated
                }
                .prefix(3)
                .map {
                    $0.memory
                }
    }

    // =====================================================
    // LOAD MEMORIES
    // =====================================================

    func loadMemories() {

        // -------------------------------------------------
        // REQUIRE CURRENT USER
        // -------------------------------------------------

        guard let userID = currentUserID else {

            print(
                "🔒 No authenticated user. Memories remain empty."
            )

            memories = []
            suggestedMemories = []

            return
        }

        // -------------------------------------------------
        // REQUIRE STORAGE
        // -------------------------------------------------

        guard let storage = storage else {

            print(
                "❌ Storage missing for user \(userID)."
            )

            memories = []
            suggestedMemories = []

            return
        }

        // -------------------------------------------------
        // LOAD USER-SPECIFIC FILE
        // -------------------------------------------------

        let loadedMemories = storage.load()

        memories = loadedMemories

        print("========================================")
        print("📚 MEMORIES LOADED")
        print("========================================")
        print("👤 User: \(userID)")
        print("📚 Memory count: \(memories.count)")
        print("========================================")

        generateSuggestions()
    }

    // =====================================================
    // SAVE MEMORIES
    // =====================================================

    func save() {

        // -------------------------------------------------
        // REQUIRE USER
        // -------------------------------------------------

        guard let userID = currentUserID else {

            print(
                "❌ Cannot save memories: no authenticated user."
            )

            return
        }

        // -------------------------------------------------
        // REQUIRE STORAGE
        // -------------------------------------------------

        guard let storage = storage else {

            print(
                "❌ Cannot save memories: storage unavailable for \(userID)."
            )

            return
        }

        // -------------------------------------------------
        // SAVE ONLY THIS USER'S MEMORIES
        // -------------------------------------------------

        storage.save(memories)

        print("========================================")
        print("💾 MEMORIES SAVED")
        print("========================================")
        print("👤 User: \(userID)")
        print("📚 Memory count: \(memories.count)")
        print("========================================")
    }
}

// =====================================================
// PREVIEW
// =====================================================

#Preview {
    Text("MemoryViewModel")
}
