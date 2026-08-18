
import Foundation
import Combine

// =====================================================
// VIEWMODEL: FlashcardViewModel
// =====================================================
// PURPOSE:
// Manages all RecalllQ flashcard functionality.
//
// FEATURES:
// - Create flashcards from Memories
// - Create flashcards from all Memories
// - Create flashcards from selected Memories
// - Select / deselect Memories
// - Select all Memories
// - Deselect all Memories
// - Prevent duplicate flashcards
// - Save / load flashcards
// - Delete flashcards
// - Search
// - Review tracking
// - Difficulty tracking
// - Spaced repetition
// - Previous / Next navigation
// - Smart Suggestion integration
// - Study Session integration
// - Generation status
// - Error / success messages
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
    // Stores the IDs of Memories selected by the user
    // for flashcard generation.
    // =====================================================

    @Published var selectedMemoryIDs: Set<UUID> = []

    // =====================================================
    // STORAGE
    // =====================================================

    private let storageKey = "saved_flashcards"

    // =====================================================
    // INIT
    // =====================================================

    init() {
        loadFlashcards()

        currentIndex = 0
        isShowingAnswer = false
        isGeneratingFlashcards = false
        selectedMemoryIDs = []
    }

    // =====================================================
    // MARK MEMORY AS SELECTED
    // =====================================================

    func selectMemory(_ memoryID: UUID) {

        selectedMemoryIDs.insert(memoryID)

        print("✅ Memory selected: \(memoryID)")
    }

    // =====================================================
    // UNSELECT MEMORY
    // =====================================================

    func deselectMemory(_ memoryID: UUID) {

        selectedMemoryIDs.remove(memoryID)

        print("❌ Memory deselected: \(memoryID)")
    }

    // =====================================================
    // TOGGLE MEMORY SELECTION
    // =====================================================

    func toggleMemorySelection(_ memoryID: UUID) {

        if selectedMemoryIDs.contains(memoryID) {

            selectedMemoryIDs.remove(memoryID)

            print("❌ Memory deselected: \(memoryID)")

        } else {

            selectedMemoryIDs.insert(memoryID)

            print("✅ Memory selected: \(memoryID)")
        }
    }

    // =====================================================
    // CHECK IF MEMORY IS SELECTED
    // =====================================================

    func isMemorySelected(_ memoryID: UUID) -> Bool {

        return selectedMemoryIDs.contains(memoryID)
    }

    // =====================================================
    // SELECT ALL MEMORIES
    // =====================================================

    func selectAllMemories(_ memories: [Memory]) {

        selectedMemoryIDs = Set(
            memories.map { $0.id }
        )

        print(
            "✅ Selected all \(selectedMemoryIDs.count) memories."
        )
    }

    // =====================================================
    // DESELECT ALL MEMORIES
    // =====================================================

    func deselectAllMemories() {

        selectedMemoryIDs.removeAll()

        print("❌ All memory selections cleared.")
    }

    // =====================================================
    // SELECTABLE MEMORY COUNT
    // =====================================================
    // Counts Memories that do not already have a flashcard.
    // =====================================================

    func selectableMemoryCount(
        from memories: [Memory]
    ) -> Int {

        return memories.filter { memory in

            !hasFlashcard(
                for: memory.id
            )

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

        return memories.filter { memory in

            selectedMemoryIDs.contains(
                memory.id
            )
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

        // -------------------------------------------------
        // Prevent duplicate memory flashcard
        // -------------------------------------------------

        if let memoryID = memoryID {

            let exists =
                flashcards.contains {

                    $0.memoryID == memoryID
                }

            if exists {

                print(
                    "⚠️ Flashcard already exists for this memory."
                )

                return
            }
        }

        // -------------------------------------------------
        // Create flashcard
        // -------------------------------------------------

        let flashcard =
            Flashcard(
                memoryID: memoryID,
                question: cleanQuestion,
                answer: cleanAnswer
            )

        // -------------------------------------------------
        // Add
        // -------------------------------------------------

        flashcards.insert(
            flashcard,
            at: 0
        )

        // -------------------------------------------------
        // Save
        // -------------------------------------------------

        saveFlashcards()

        // -------------------------------------------------
        // Reset study position
        // -------------------------------------------------

        currentIndex = 0
        isShowingAnswer = false

        print("========================================")
        print("✅ FLASHCARD CREATED")
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

        // -------------------------------------------------
        // Prevent duplicate
        // -------------------------------------------------

        if flashcards.contains(
            where: {
                $0.memoryID == memory.id
            }
        ) {

            print(
                "⚠️ Flashcard already exists for: \(memory.title)"
            )

            return false
        }

        // -------------------------------------------------
        // Create question
        // -------------------------------------------------

        let question =
            "What is the main idea of \(memory.title)?"

        // -------------------------------------------------
        // Clean summary
        // -------------------------------------------------

        let cleanSummary =
            memory.summary.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        // -------------------------------------------------
        // Clean content
        // -------------------------------------------------

        let cleanContent =
            memory.content.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        // -------------------------------------------------
        // Choose best answer
        // -------------------------------------------------

        let answer: String

        if !cleanSummary.isEmpty {

            answer = cleanSummary

        } else if !cleanContent.isEmpty {

            answer = cleanContent

        } else {

            answer =
                "Review the memory titled \(memory.title)."
        }

        // -------------------------------------------------
        // Add flashcard
        // -------------------------------------------------

        let beforeCount = flashcards.count

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

        // -------------------------------------------------
        // Find selected memories
        // -------------------------------------------------

        let memoriesToGenerate =
            memories.filter { memory in

                selectedMemoryIDs.contains(
                    memory.id
                )
            }

        guard !memoriesToGenerate.isEmpty else {

            flashcardGenerationError =
                "Please select at least one Memory."

            flashcardGenerationMessage = nil

            return 0
        }

        // -------------------------------------------------
        // Start generation
        // -------------------------------------------------

        isGeneratingFlashcards = true

        flashcardGenerationError = nil

        flashcardGenerationMessage =
            "Generating flashcards..."

        var createdCount = 0

        var skippedCount = 0

        // -------------------------------------------------
        // Generate selected flashcards
        // -------------------------------------------------

        for memory in memoriesToGenerate {

            if hasFlashcard(
                for: memory.id
            ) {

                skippedCount += 1

                print(
                    "⏭️ Skipping existing flashcard: \(memory.title)"
                )

                continue
            }

            if createFromMemory(memory) {

                createdCount += 1

                print(
                    "✅ Generated flashcard \(createdCount): \(memory.title)"
                )
            }
        }

        // -------------------------------------------------
        // Reset selection
        // -------------------------------------------------

        selectedMemoryIDs.removeAll()

        // -------------------------------------------------
        // Reset study position
        // -------------------------------------------------

        currentIndex = 0

        isShowingAnswer = false

        // -------------------------------------------------
        // Finish generation
        // -------------------------------------------------

        isGeneratingFlashcards = false

        // -------------------------------------------------
        // Message
        // -------------------------------------------------

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

        // -------------------------------------------------
        // Save
        // -------------------------------------------------

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

        // -------------------------------------------------
        // Prevent duplicate generation requests
        // -------------------------------------------------

        guard !isGeneratingFlashcards else {

            print(
                "⚠️ Flashcard generation is already running."
            )

            return 0
        }

        // -------------------------------------------------
        // Validate memories
        // -------------------------------------------------

        guard !memories.isEmpty else {

            isGeneratingFlashcards = false

            flashcardGenerationError =
                "No memories available. Create a memory first."

            flashcardGenerationMessage = nil

            print(
                "❌ No memories available."
            )

            return 0
        }

        // -------------------------------------------------
        // Start generation
        // -------------------------------------------------

        isGeneratingFlashcards = true

        flashcardGenerationError = nil

        flashcardGenerationMessage =
            "Generating flashcards..."

        var createdCount = 0

        var skippedCount = 0

        // -------------------------------------------------
        // Generate one flashcard per memory
        // -------------------------------------------------

        for memory in memories {

            let alreadyExists =
                flashcards.contains {

                    $0.memoryID == memory.id
                }

            if alreadyExists {

                skippedCount += 1

                print(
                    "⏭️ Skipping existing flashcard: \(memory.title)"
                )

                continue
            }

            if createFromMemory(memory) {

                createdCount += 1

                print(
                    "✅ Generated flashcard \(createdCount): \(memory.title)"
                )
            }
        }

        // -------------------------------------------------
        // Reset selection
        // -------------------------------------------------

        selectedMemoryIDs.removeAll()

        // -------------------------------------------------
        // Reset study position
        // -------------------------------------------------

        currentIndex = 0

        isShowingAnswer = false

        // -------------------------------------------------
        // Finish generation
        // -------------------------------------------------

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
                "All available memories already have flashcards."

            flashcardGenerationError = nil
        }

        // -------------------------------------------------
        // Save again
        // -------------------------------------------------

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

        return createFromMemories(
            memories
        )
    }

    // =====================================================
    // CLEAR GENERATION MESSAGE
    // =====================================================

    func clearGenerationMessage() {

        flashcardGenerationMessage = nil

        flashcardGenerationError = nil
    }

    // =====================================================
    // SMART SUGGESTION
    // SELECT FLASHCARD
    // =====================================================

    func selectFlashcard(
        id: UUID
    ) {

        let cards =
            filteredFlashcards

        guard
            let index =
                cards.firstIndex(
                    where: {
                        $0.id == id
                    }
                )
        else {

            print(
                "❌ Flashcard not found."
            )

            return
        }

        currentIndex = index

        isShowingAnswer = false

        print(
            "🎯 Smart Suggestion opened Card \(index + 1)"
        )
    }

    // =====================================================
    // FIND FLASHCARD FOR MEMORY
    // =====================================================

    func flashcardForMemory(
        _ memoryID: UUID
    ) -> Flashcard? {

        return flashcards.first {

            $0.memoryID == memoryID
        }
    }

    // =====================================================
    // CHECK IF MEMORY HAS FLASHCARD
    // =====================================================

    func hasFlashcard(
        for memoryID: UUID
    ) -> Bool {

        return flashcards.contains {

            $0.memoryID == memoryID
        }
    }

    // =====================================================
    // DELETE FLASHCARD
    // =====================================================

    func deleteFlashcard(
        id: UUID
    ) {

        guard
            let index =
                flashcards.firstIndex(
                    where: {
                        $0.id == id
                    }
                )
        else {
            return
        }

        flashcards.remove(
            at: index
        )

        let count =
            filteredFlashcards.count

        if count == 0 {

            currentIndex = 0

        } else if currentIndex >= count {

            currentIndex =
                count - 1
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

        flashcards.removeAll()

        currentIndex = 0

        isShowingAnswer = false

        searchText = ""

        selectedMemoryIDs.removeAll()

        flashcardGenerationMessage = nil

        flashcardGenerationError = nil

        UserDefaults.standard.removeObject(
            forKey: storageKey
        )

        print(
            "✅ All flashcards reset."
        )
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

        guard
            !cards.isEmpty,
            currentIndex >= 0,
            currentIndex < cards.count
        else {

            currentIndex = 0

            return
        }

        let currentCard =
            cards[currentIndex]

        guard
            let originalIndex =
                flashcards.firstIndex(
                    where: {
                        $0.id == currentCard.id
                    }
                )
        else {

            return
        }

        // -------------------------------------------------
        // Update difficulty
        // -------------------------------------------------

        flashcards[originalIndex].difficulty =
            difficulty

        // -------------------------------------------------
        // Update review count
        // -------------------------------------------------

        flashcards[originalIndex].timesReviewed += 1

        // -------------------------------------------------
        // Update correct count
        // -------------------------------------------------

        if correct {

            flashcards[originalIndex].timesCorrect += 1
        }

        // -------------------------------------------------
        // Update dates
        // -------------------------------------------------

        flashcards[originalIndex].lastReviewed =
            Date()

        flashcards[originalIndex].nextReviewDate =
            calculateNextReviewDate(
                difficulty: difficulty
            )

        // -------------------------------------------------
        // Save
        // -------------------------------------------------

        saveFlashcards()

        // -------------------------------------------------
        // Study session integration
        // -------------------------------------------------

        appState?.recordFlashcardReviewed()

        print(
            "📚 Study Session updated: flashcard reviewed."
        )

        // -------------------------------------------------
        // Move to next
        // -------------------------------------------------

        moveToNextCard()
    }

    // =====================================================
    // NEXT CARD
    // =====================================================

    func nextCard() {

        moveToNextCard()
    }

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

            currentIndex =
                count - 1
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

        return flashcards.filter {

            $0.question.localizedCaseInsensitiveContains(
                query
            )
            ||
            $0.answer.localizedCaseInsensitiveContains(
                query
            )
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

        guard
            currentIndex >= 0,
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
    // MASTERED
    // =====================================================

    var masteredFlashcards: Int {

        flashcards.filter {

            $0.timesReviewed >= 3 &&
            $0.accuracy >= 0.8

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

        return Double(totalCorrect)
            / Double(totalReviews)
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

        do {

            let data =
                try JSONEncoder().encode(
                    flashcards
                )

            UserDefaults.standard.set(
                data,
                forKey: storageKey
            )

            print(
                "💾 Flashcards saved: \(flashcards.count)"
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

        guard
            let data =
                UserDefaults.standard.data(
                    forKey: storageKey
                )
        else {

            flashcards = []

            return
        }

        do {

            flashcards =
                try JSONDecoder().decode(
                    [Flashcard].self,
                    from: data
                )

            print(
                "📚 Loaded \(flashcards.count) flashcards."
            )

        } catch {

            print(
                "❌ Could not load flashcards: \(error)"
            )

            flashcards = []
        }
    }
}
