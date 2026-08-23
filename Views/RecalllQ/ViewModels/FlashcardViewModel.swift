
import Foundation
import Combine

// =====================================================
// VIEWMODEL: FlashcardViewModel
// =====================================================
//
// PURPOSE:
// Manages all RecalllQ flashcard functionality.
//
// USER DATA ISOLATION:
// Every authenticated user receives their own:
//
// - Flashcards
// - Review history
// - Difficulty
// - Accuracy
// - Spaced repetition
// - Flashcard generation state
//
// STORAGE:
//
// recallq_flashcards_<encodedUserID>
//
// IMPORTANT:
// Flashcards are NEVER loaded before an authenticated
// user has been assigned.
//
// AppState calls:
//
//     flashcardViewModel.switchUser(to: userID)
//
// after login / registration.
// =====================================================

@MainActor
final class FlashcardViewModel: ObservableObject {

    // =====================================================
    // APP STATE
    // =====================================================

    weak var appState: AppState?

    // =====================================================
    // MAIN STATE
    // =====================================================

    @Published var flashcards: [Flashcard] = []

    // =====================================================
    // SEARCH
    // =====================================================

    @Published var searchText: String = ""

    // =====================================================
    // STUDY STATE
    // =====================================================

    @Published var currentIndex: Int = 0
    @Published var isShowingAnswer: Bool = false

    // =====================================================
    // GENERATION STATE
    // =====================================================

    @Published var isGeneratingFlashcards: Bool = false

    @Published var flashcardGenerationMessage: String?

    @Published var flashcardGenerationError: String?

    // =====================================================
    // MEMORY SELECTION STATE
    // =====================================================

    @Published var selectedMemoryIDs: Set<UUID> = []

    // =====================================================
    // CURRENT USER
    // =====================================================

    private(set) var currentUserID: String?

    // =====================================================
    // APPSTATE COMPATIBILITY
    // =====================================================
    //
    // AppState checks whether this ViewModel supports
    // user switching and saving.
    //
    // These properties allow AppState to safely perform:
    //
    //     switchUser(to:)
    //     save()
    //
    // =====================================================

    var respondsToSwitchUser: Bool {
        true
    }

    var respondsToSave: Bool {
        true
    }

    // =====================================================
    // STORAGE
    // =====================================================

    private let storagePrefix = "recallq_flashcards"

    // =====================================================
    // INIT
    // =====================================================

    init() {

        // IMPORTANT:
        //
        // Do NOT load flashcards here.
        //
        // AppState must identify the authenticated user
        // first.

        flashcards = []
        searchText = ""

        currentIndex = 0
        isShowingAnswer = false

        isGeneratingFlashcards = false

        flashcardGenerationMessage = nil
        flashcardGenerationError = nil

        selectedMemoryIDs = []

        currentUserID = nil

        print("ℹ️ FlashcardViewModel initialized.")
        print("🔐 Waiting for authenticated user.")
    }

    // =====================================================
    // NORMALIZE USER ID
    // =====================================================

    private func normalizeUserID(_ userID: String) -> String {

        return userID
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
    }

    // =====================================================
    // USER-SPECIFIC STORAGE KEY
    // =====================================================

    private func storageKey(for userID: String) -> String {

        let cleanUserID = normalizeUserID(userID)

        let encodedUserID =
            cleanUserID
                .data(using: .utf8)?
                .base64EncodedString()
                .replacingOccurrences(of: "=", with: "")
                .replacingOccurrences(of: "/", with: "_")
                .replacingOccurrences(of: "+", with: "-")
                ?? cleanUserID

        return "\(storagePrefix)_\(encodedUserID)"
    }

    // =====================================================
    // SWITCH USER
    // =====================================================

    func switchUser(to userID: String) {

        let cleanUserID = normalizeUserID(userID)

        guard !cleanUserID.isEmpty else {

            print(
                "❌ FlashcardViewModel: Cannot switch to empty user ID."
            )

            clearCurrentUserData()

            currentUserID = nil

            return
        }

        // -------------------------------------------------
        // Same user
        // -------------------------------------------------

        if currentUserID == cleanUserID {

            print(
                "ℹ️ Flashcards already loaded for \(cleanUserID)."
            )

            return
        }

        // -------------------------------------------------
        // IMPORTANT:
        // Clear previous user's data from memory.
        // -------------------------------------------------

        clearCurrentUserData()

        // -------------------------------------------------
        // Assign new authenticated user.
        // -------------------------------------------------

        currentUserID = cleanUserID

        // -------------------------------------------------
        // Load ONLY this user's flashcards.
        // -------------------------------------------------

        loadFlashcards()

        print("========================================")
        print("🔐 FLASHCARD USER SWITCH")
        print("========================================")
        print("👤 Current user: \(cleanUserID)")
        print("📚 Flashcards loaded: \(flashcards.count)")
        print("========================================")
    }

    // =====================================================
    // CLEAR CURRENT USER DATA
    // =====================================================

    func clearCurrentUserData() {

        flashcards.removeAll()

        currentIndex = 0

        isShowingAnswer = false

        searchText = ""

        selectedMemoryIDs.removeAll()

        isGeneratingFlashcards = false

        flashcardGenerationMessage = nil

        flashcardGenerationError = nil

        print(
            "🧹 Flashcards removed from active memory."
        )
    }

    // =====================================================
    // PUBLIC SAVE
    // =====================================================

    func save() {

        saveFlashcards()
    }

    // =====================================================
    // MARK MEMORY AS SELECTED
    // =====================================================

    func selectMemory(_ memoryID: UUID) {

        guard !hasFlashcard(for: memoryID) else {

            print(
                "⚠️ Memory already has a flashcard."
            )

            return
        }

        selectedMemoryIDs.insert(memoryID)

        print(
            "✅ Memory selected: \(memoryID)"
        )
    }

    // =====================================================
    // UNSELECT MEMORY
    // =====================================================

    func deselectMemory(_ memoryID: UUID) {

        selectedMemoryIDs.remove(memoryID)

        print(
            "❌ Memory deselected: \(memoryID)"
        )
    }

    // =====================================================
    // TOGGLE MEMORY SELECTION
    // =====================================================

    func toggleMemorySelection(_ memoryID: UUID) {

        if selectedMemoryIDs.contains(memoryID) {

            selectedMemoryIDs.remove(memoryID)

            print(
                "❌ Memory deselected: \(memoryID)"
            )

        } else {

            guard !hasFlashcard(for: memoryID) else {

                print(
                    "⚠️ Memory already has a flashcard."
                )

                return
            }

            selectedMemoryIDs.insert(memoryID)

            print(
                "✅ Memory selected: \(memoryID)"
            )
        }
    }

    // =====================================================
    // CHECK IF MEMORY IS SELECTED
    // =====================================================

    func isMemorySelected(_ memoryID: UUID) -> Bool {

        selectedMemoryIDs.contains(memoryID)
    }

    // =====================================================
    // SELECT ALL MEMORIES
    // =====================================================

    func selectAllMemories(_ memories: [Memory]) {

        let availableMemoryIDs =
            memories
                .filter { memory in
                    !hasFlashcard(for: memory.id)
                }
                .map { memory in
                    memory.id
                }

        selectedMemoryIDs =
            Set(availableMemoryIDs)

        print(
            "✅ Selected all available Memories: \(selectedMemoryIDs.count)"
        )
    }

    // =====================================================
    // DESELECT ALL MEMORIES
    // =====================================================

    func deselectAllMemories() {

        selectedMemoryIDs.removeAll()

        print(
            "❌ All memory selections cleared."
        )
    }

    // =====================================================
    // SELECTABLE MEMORY COUNT
    // =====================================================

    func selectableMemoryCount(
        from memories: [Memory]
    ) -> Int {

        memories.filter { memory in
            !hasFlashcard(for: memory.id)
        }.count
    }

    // =====================================================
    // SELECTED MEMORY COUNT
    // =====================================================

    var selectedMemoryCount: Int {

        selectedMemoryIDs.count
    }

    // =====================================================
    // SELECTED MEMORIES
    // =====================================================

    func selectedMemories(
        from memories: [Memory]
    ) -> [Memory] {

        memories.filter { memory in
            selectedMemoryIDs.contains(memory.id)
        }
    }

    // =====================================================
    // ADD FLASHCARD
    // =====================================================

    func addFlashcard(
        question: String,
        answer: String,
        memoryID: UUID? = nil
    ) {

        guard currentUserID != nil else {

            flashcardGenerationError =
                "Please sign in before creating flashcards."

            print(
                "❌ Cannot create flashcard: no authenticated user."
            )

            return
        }

        let cleanQuestion =
            question.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        let cleanAnswer =
            answer.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        guard !cleanQuestion.isEmpty else {

            flashcardGenerationError =
                "Flashcard question cannot be empty."

            print(
                "❌ Flashcard question is empty."
            )

            return
        }

        guard !cleanAnswer.isEmpty else {

            flashcardGenerationError =
                "Flashcard answer cannot be empty."

            print(
                "❌ Flashcard answer is empty."
            )

            return
        }

        // Prevent duplicate flashcard for memory.

        if let memoryID = memoryID {

            let exists =
                flashcards.contains {
                    $0.memoryID == memoryID
                }

            if exists {

                print(
                    "⚠️ Flashcard already exists for this Memory."
                )

                return
            }
        }

        let flashcard =
            Flashcard(
                memoryID: memoryID,
                question: cleanQuestion,
                answer: cleanAnswer
            )

        flashcards.insert(
            flashcard,
            at: 0
        )

        saveFlashcards()

        currentIndex = 0
        isShowingAnswer = false

        print("========================================")
        print("✅ FLASHCARD CREATED")
        print("👤 User: \(currentUserID ?? "unknown")")
        print("Question: \(cleanQuestion)")
        print("========================================")
    }

    // =====================================================
    // CREATE FLASHCARD FROM ONE MEMORY
    // =====================================================

    @discardableResult
    func createFromMemory(
        _ memory: Memory
    ) -> Bool {

        print("========================================")
        print("🧠 CREATING FLASHCARD FROM MEMORY")
        print("Memory: \(memory.title)")
        print("========================================")

        if hasFlashcard(for: memory.id) {

            print(
                "⚠️ Flashcard already exists for: \(memory.title)"
            )

            return false
        }

        let question =
            "What is the main idea of \(memory.title)?"

        let cleanSummary =
            memory.summary.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        let cleanContent =
            memory.content.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        let answer: String

        if !cleanSummary.isEmpty {

            answer = cleanSummary

        } else if !cleanContent.isEmpty {

            answer = cleanContent

        } else {

            answer =
                "Review the Memory titled \(memory.title)."
        }

        let beforeCount =
            flashcards.count

        addFlashcard(
            question: question,
            answer: answer,
            memoryID: memory.id
        )

        return flashcards.count > beforeCount
    }

    // =====================================================
    // CREATE FLASHCARDS FROM SELECTED MEMORIES
    // =====================================================

    @discardableResult
    func createFromSelectedMemories(
        _ memories: [Memory]
    ) -> Int {

        print("========================================")
        print("🧠 GENERATE FROM SELECTED MEMORIES")
        print("Selected: \(selectedMemoryIDs.count)")
        print("========================================")

        guard !isGeneratingFlashcards else {

            print(
                "⚠️ Flashcard generation is already running."
            )

            return 0
        }

        let memoriesToGenerate =
            selectedMemories(
                from: memories
            )

        guard !memoriesToGenerate.isEmpty else {

            flashcardGenerationError =
                "Please select at least one Memory."

            flashcardGenerationMessage = nil

            return 0
        }

        isGeneratingFlashcards = true

        flashcardGenerationError = nil

        flashcardGenerationMessage =
            "Generating flashcards..."

        var createdCount = 0
        var skippedCount = 0

        for memory in memoriesToGenerate {

            if hasFlashcard(for: memory.id) {

                skippedCount += 1

                continue
            }

            if createFromMemory(memory) {

                createdCount += 1
            }
        }

        selectedMemoryIDs.removeAll()

        currentIndex = 0

        isShowingAnswer = false

        isGeneratingFlashcards = false

        if createdCount > 0 {

            if skippedCount > 0 {

                flashcardGenerationMessage =
                    "\(createdCount) flashcard\(createdCount == 1 ? "" : "s") generated. \(skippedCount) already existed."

            } else {

                flashcardGenerationMessage =
                    "\(createdCount) flashcard\(createdCount == 1 ? "" : "s") generated successfully!"
            }

            flashcardGenerationError = nil

        } else {

            flashcardGenerationMessage =
                "The selected Memories already have flashcards."

            flashcardGenerationError = nil
        }

        saveFlashcards()

        print("========================================")
        print("✅ SELECTED FLASHCARD GENERATION COMPLETE")
        print("Created: \(createdCount)")
        print("Skipped: \(skippedCount)")
        print("Total flashcards: \(flashcards.count)")
        print("========================================")

        return createdCount
    }

    // =====================================================
    // CREATE FLASHCARDS FROM ALL MEMORIES
    // =====================================================

    @discardableResult
    func createFromMemories(
        _ memories: [Memory]
    ) -> Int {

        print("========================================")
        print("🧠 GENERATE FLASHCARDS")
        print("Memories available: \(memories.count)")
        print("Existing flashcards: \(flashcards.count)")
        print("========================================")

        guard !isGeneratingFlashcards else {

            print(
                "⚠️ Flashcard generation is already running."
            )

            return 0
        }

        guard !memories.isEmpty else {

            isGeneratingFlashcards = false

            flashcardGenerationError =
                "No Memories available. Create a Memory first."

            flashcardGenerationMessage = nil

            return 0
        }

        isGeneratingFlashcards = true

        flashcardGenerationError = nil

        flashcardGenerationMessage =
            "Generating flashcards..."

        var createdCount = 0
        var skippedCount = 0

        for memory in memories {

            if hasFlashcard(for: memory.id) {

                skippedCount += 1

                continue
            }

            if createFromMemory(memory) {

                createdCount += 1
            }
        }

        selectedMemoryIDs.removeAll()

        currentIndex = 0

        isShowingAnswer = false

        isGeneratingFlashcards = false

        if createdCount > 0 {

            if skippedCount > 0 {

                flashcardGenerationMessage =
                    "\(createdCount) flashcard\(createdCount == 1 ? "" : "s") generated. \(skippedCount) already existed."

            } else {

                flashcardGenerationMessage =
                    "\(createdCount) flashcard\(createdCount == 1 ? "" : "s") generated successfully!"
            }

            flashcardGenerationError = nil

        } else {

            flashcardGenerationMessage =
                "All available Memories already have flashcards."

            flashcardGenerationError = nil
        }

        saveFlashcards()

        print("========================================")
        print("✅ FLASHCARD GENERATION COMPLETE")
        print("Created: \(createdCount)")
        print("Skipped: \(skippedCount)")
        print("Total flashcards: \(flashcards.count)")
        print("========================================")

        return createdCount
    }

    // =====================================================
    // CREATE FROM ALL MEMORIES
    // =====================================================

    @discardableResult
    func createFromAllMemories(
        _ memories: [Memory]
    ) -> Int {

        createFromMemories(memories)
    }

    // =====================================================
    // CLEAR GENERATION MESSAGE
    // =====================================================

    func clearGenerationMessage() {

        flashcardGenerationMessage = nil

        flashcardGenerationError = nil
    }

    // =====================================================
    // SELECT FLASHCARD
    // =====================================================

    func selectFlashcard(id: UUID) {

        let cards =
            filteredFlashcards

        guard let index =
                cards.firstIndex(
                    where: { $0.id == id }
                )
        else {

            print(
                "❌ Flashcard not found."
            )

            return
        }

        currentIndex = index

        isShowingAnswer = false
    }

    // =====================================================
    // FIND FLASHCARD FOR MEMORY
    // =====================================================

    func flashcardForMemory(
        _ memoryID: UUID
    ) -> Flashcard? {

        flashcards.first {
            $0.memoryID == memoryID
        }
    }

    // =====================================================
    // CHECK IF MEMORY HAS FLASHCARD
    // =====================================================

    func hasFlashcard(
        for memoryID: UUID
    ) -> Bool {

        flashcards.contains {
            $0.memoryID == memoryID
        }
    }

    // =====================================================
    // DELETE FLASHCARD
    // =====================================================

    func deleteFlashcard(id: UUID) {

        guard let index =
                flashcards.firstIndex(
                    where: { $0.id == id }
                )
        else {
            return
        }

        flashcards.remove(at: index)

        let count =
            filteredFlashcards.count

        if count == 0 {

            currentIndex = 0

        } else if currentIndex >= count {

            currentIndex = count - 1
        }

        isShowingAnswer = false

        saveFlashcards()

        print(
            "🗑️ Flashcard deleted."
        )
    }

    // =====================================================
    // RESET ALL FLASHCARDS
    // =====================================================

    func resetAllFlashcards() {

        guard let userID = currentUserID,
              !userID.isEmpty
        else {

            print(
                "❌ Cannot reset flashcards: no authenticated user."
            )

            return
        }

        flashcards.removeAll()

        currentIndex = 0

        isShowingAnswer = false

        searchText = ""

        selectedMemoryIDs.removeAll()

        flashcardGenerationMessage = nil

        flashcardGenerationError = nil

        let key =
            storageKey(for: userID)

        UserDefaults.standard.removeObject(
            forKey: key
        )

        print("========================================")
        print("🗑️ FLASHCARDS RESET")
        print("========================================")
        print("👤 User: \(userID)")
        print("========================================")
    }

    // =====================================================
    // MARK EASY
    // =====================================================

    func markEasy() {

        reviewCurrentCard(
            difficulty: .easy,
            correct: true
        )
    }

    // =====================================================
    // MARK MEDIUM
    // =====================================================

    func markMedium() {

        reviewCurrentCard(
            difficulty: .medium,
            correct: true
        )
    }

    // =====================================================
    // MARK HARD
    // =====================================================

    func markHard() {

        reviewCurrentCard(
            difficulty: .hard,
            correct: false
        )
    }

    // =====================================================
    // REVIEW CURRENT CARD
    // =====================================================

    private func reviewCurrentCard(
        difficulty: Flashcard.Difficulty,
        correct: Bool
    ) {

        let cards =
            filteredFlashcards

        guard !cards.isEmpty,
              currentIndex >= 0,
              currentIndex < cards.count
        else {

            currentIndex = 0

            return
        }

        let currentCard =
            cards[currentIndex]

        guard let originalIndex =
                flashcards.firstIndex(
                    where: {
                        $0.id == currentCard.id
                    }
                )
        else {

            return
        }

        flashcards[originalIndex].difficulty =
            difficulty

        flashcards[originalIndex].timesReviewed += 1

        if correct {

            flashcards[originalIndex].timesCorrect += 1
        }

        flashcards[originalIndex].lastReviewed =
            Date()

        flashcards[originalIndex].nextReviewDate =
            calculateNextReviewDate(
                difficulty: difficulty
            )

        saveFlashcards()

        // Update active study session.

        appState?.recordFlashcardReviewed()

        moveToNextCard()
    }

    // =====================================================
    // NEXT CARD
    // =====================================================

    func nextCard() {

        moveToNextCard()
    }

    // =====================================================
    // MOVE TO NEXT CARD
    // =====================================================

    private func moveToNextCard() {

        let count =
            filteredFlashcards.count

        guard count > 0 else {

            currentIndex = 0

            isShowingAnswer = false

            return
        }

        if currentIndex + 1 < count {

            currentIndex += 1

        } else {

            currentIndex = 0
        }

        isShowingAnswer = false
    }

    // =====================================================
    // PREVIOUS CARD
    // =====================================================

    func previousCard() {

        let count =
            filteredFlashcards.count

        guard count > 0 else {

            currentIndex = 0

            isShowingAnswer = false

            return
        }

        if currentIndex > 0 {

            currentIndex -= 1

        } else {

            currentIndex = count - 1
        }

        isShowingAnswer = false
    }

    // =====================================================
    // SHOW ANSWER
    // =====================================================

    func showAnswer() {

        isShowingAnswer = true
    }

    // =====================================================
    // HIDE ANSWER
    // =====================================================

    func hideAnswer() {

        isShowingAnswer = false
    }

    // =====================================================
    // TOGGLE ANSWER
    // =====================================================

    func toggleAnswer() {

        isShowingAnswer.toggle()
    }

    // =====================================================
    // RESET STUDY
    // =====================================================

    func resetStudy() {

        currentIndex = 0

        isShowingAnswer = false
    }

    // =====================================================
    // FILTERED FLASHCARDS
    // =====================================================

    var filteredFlashcards: [Flashcard] {

        let query =
            searchText.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        guard !query.isEmpty else {

            return flashcards
        }

        return flashcards.filter { card in

            card.question.localizedCaseInsensitiveContains(query)
            ||
            card.answer.localizedCaseInsensitiveContains(query)
        }
    }

    // =====================================================
    // CURRENT FLASHCARD
    // =====================================================

    var currentFlashcard: Flashcard? {

        let cards =
            filteredFlashcards

        guard !cards.isEmpty else {

            return nil
        }

        guard currentIndex >= 0,
              currentIndex < cards.count
        else {

            return cards[0]
        }

        return cards[currentIndex]
    }

    // =====================================================
    // CURRENT CARD NUMBER
    // =====================================================

    var currentCardNumber: Int {

        let count =
            filteredFlashcards.count

        guard count > 0 else {

            return 0
        }

        return min(
            currentIndex + 1,
            count
        )
    }

    // =====================================================
    // TOTAL FLASHCARDS
    // =====================================================

    var totalFlashcards: Int {

        flashcards.count
    }

    // =====================================================
    // REVIEWED
    // =====================================================

    var reviewedFlashcards: Int {

        flashcards.filter {
            $0.timesReviewed > 0
        }.count
    }

    // =====================================================
    // NOT REVIEWED
    // =====================================================

    var unreviewedFlashcards: Int {

        flashcards.filter {
            $0.timesReviewed == 0
        }.count
    }

    // =====================================================
    // MASTERED
    // =====================================================

    var masteredFlashcards: Int {

        flashcards.filter {
            $0.timesReviewed >= 3 &&
            $0.accuracy >= 0.8
        }.count
    }

    // =====================================================
    // NEEDS REVIEW
    // =====================================================

    var flashcardsDueForReview: Int {

        let now = Date()

        return flashcards.filter { card in

            guard let nextReviewDate =
                    card.nextReviewDate
            else {

                return false
            }

            return nextReviewDate <= now
        }.count
    }

    // =====================================================
    // OVERALL ACCURACY
    // =====================================================

    var overallAccuracy: Double {

        let reviewed =
            flashcards.filter {
                $0.timesReviewed > 0
            }

        guard !reviewed.isEmpty else {

            return 0
        }

        let totalReviews =
            reviewed.reduce(0) {
                $0 + $1.timesReviewed
            }

        let totalCorrect =
            reviewed.reduce(0) {
                $0 + $1.timesCorrect
            }

        guard totalReviews > 0 else {

            return 0
        }

        return Double(totalCorrect) /
            Double(totalReviews)
    }

    // =====================================================
    // OVERALL ACCURACY PERCENTAGE
    // =====================================================

    var overallAccuracyPercentage: Int {

        Int(overallAccuracy * 100)
    }

    // =====================================================
    // SPACED REPETITION
    // =====================================================

    private func calculateNextReviewDate(
        difficulty: Flashcard.Difficulty
    ) -> Date {

        let days: Int

        switch difficulty {

        case .easy:
            days = 7

        case .medium:
            days = 3

        case .hard:
            days = 1
        }

        return Calendar.current.date(
            byAdding: .day,
            value: days,
            to: Date()
        ) ?? Date()
    }

    // =====================================================
    // SAVE FLASHCARDS
    // =====================================================

    private func saveFlashcards() {

        guard let userID = currentUserID,
              !userID.isEmpty
        else {

            print(
                "⚠️ Flashcards were not saved because no user is active."
            )

            return
        }

        let key =
            storageKey(for: userID)

        do {

            let data =
                try JSONEncoder().encode(
                    flashcards
                )

            UserDefaults.standard.set(
                data,
                forKey: key
            )

            print(
                "💾 Saved \(flashcards.count) flashcards for \(userID)."
            )

        } catch {

            print(
                "❌ Could not save flashcards: \(error)"
            )
        }
    }

    // =====================================================
    // LOAD FLASHCARDS
    // =====================================================

    private func loadFlashcards() {

        guard let userID = currentUserID,
              !userID.isEmpty
        else {

            flashcards = []

            return
        }

        let key =
            storageKey(for: userID)

        guard let data =
                UserDefaults.standard.data(
                    forKey: key
                )
        else {

            flashcards = []

            print(
                "ℹ️ No saved flashcards for \(userID)."
            )

            return
        }

        do {

            flashcards =
                try JSONDecoder().decode(
                    [Flashcard].self,
                    from: data
                )

            currentIndex = 0

            isShowingAnswer = false

            print(
                "✅ Loaded \(flashcards.count) flashcards for \(userID)."
            )

        } catch {

            print(
                "❌ Could not load flashcards: \(error)"
            )

            flashcards = []
        }
    }
}
