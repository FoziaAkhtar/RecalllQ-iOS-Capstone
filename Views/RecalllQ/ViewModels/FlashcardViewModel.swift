
import Foundation
import Combine

// =====================================================
// VIEWMODEL: FlashcardViewModel
// =====================================================
// PURPOSE:
// Manages RecalllQ flashcards.
//
// FEATURES:
// - Create flashcards from Memories
// - Prevent duplicate flashcards
// - Save / load flashcards
// - Delete individual flashcards
// - RESET ALL FLASHCARDS
// - Search flashcards
// - Track reviews
// - Track correct answers
// - Track difficulty
// - Spaced repetition
// - Safe Previous / Next navigation
// - Stable card numbering
// =====================================================

final class FlashcardViewModel: ObservableObject {

    // =====================================================
    // MAIN STATE
    // =====================================================

    @Published var flashcards: [Flashcard] = []

    // =====================================================
    // UI STATE
    // =====================================================

    @Published var searchText: String = ""

    // =====================================================
    // STUDY STATE
    // =====================================================

    @Published var currentIndex: Int = 0

    @Published var isShowingAnswer: Bool = false

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
    }

    // =====================================================
    // CREATE FLASHCARD
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

        // -------------------------------------------------
        // Validate
        // -------------------------------------------------

        guard
            !cleanQuestion.isEmpty,
            !cleanAnswer.isEmpty
        else {

            print("❌ Flashcard was not created.")
            print("Question or answer is empty.")

            return
        }

        // -------------------------------------------------
        // Prevent duplicate cards from same Memory
        // -------------------------------------------------

        if let memoryID = memoryID {

            let alreadyExists =
                flashcards.contains {
                    $0.memoryID == memoryID
                }

            if alreadyExists {

                print(
                    "⚠️ Flashcard already exists for this Memory."
                )

                return
            }
        }

        // -------------------------------------------------
        // Create flashcard
        // -------------------------------------------------

        let flashcard = Flashcard(
            memoryID: memoryID,
            question: cleanQuestion,
            answer: cleanAnswer
        )

        // -------------------------------------------------
        // Add to end
        //
        // This keeps numbering stable:
        //
        // 1
        // 2
        // 3
        // 4
        // -------------------------------------------------

        flashcards.append(flashcard)

        // -------------------------------------------------
        // Save
        // -------------------------------------------------

        saveFlashcards()

        print("========================================")
        print("✅ FLASHCARD CREATED")
        print("Question: \(cleanQuestion)")
        print("Total cards: \(flashcards.count)")
        print("========================================")
    }

    // =====================================================
    // CREATE FROM ONE MEMORY
    // =====================================================

    func createFromMemory(
        _ memory: Memory
    ) {

        print("🧠 Creating flashcard from:")
        print("Memory: \(memory.title)")

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

        let answer =
            cleanSummary.isEmpty
            ? cleanContent
            : cleanSummary

        addFlashcard(
            question: question,
            answer: answer,
            memoryID: memory.id
        )
    }

    // =====================================================
    // CREATE FROM ALL MEMORIES
    // =====================================================

    func createFromMemories(
        _ memories: [Memory]
    ) {

        print("========================================")
        print("🚀 GENERATE FLASHCARDS")
        print("Memories received: \(memories.count)")
        print("Existing cards: \(flashcards.count)")
        print("========================================")

        guard !memories.isEmpty else {

            print("❌ No Memories available.")
            print("Create a Memory first.")

            return
        }

        var createdCount = 0
        var skippedCount = 0

        // -------------------------------------------------
        // Create one flashcard per Memory
        // -------------------------------------------------

        for memory in memories {

            let alreadyExists =
                flashcards.contains {
                    $0.memoryID == memory.id
                }

            if alreadyExists {

                skippedCount += 1

                print(
                    "⏭️ Skipped existing card: \(memory.title)"
                )

                continue
            }

            let oldCount =
                flashcards.count

            createFromMemory(memory)

            if flashcards.count > oldCount {

                createdCount += 1
            }
        }

        // -------------------------------------------------
        // Always start study at Card 1 after generation
        // -------------------------------------------------

        currentIndex = 0
        isShowingAnswer = false

        print("========================================")
        print("✅ GENERATION COMPLETE")
        print("New cards: \(createdCount)")
        print("Duplicates skipped: \(skippedCount)")
        print("Total cards: \(flashcards.count)")
        print("Starting Card: 1")
        print("========================================")
    }

    // =====================================================
    // DELETE ONE FLASHCARD
    // =====================================================

    func deleteFlashcard(
        id: UUID
    ) {

        guard let deletedIndex =
            flashcards.firstIndex(
                where: {
                    $0.id == id
                }
            )
        else {

            return
        }

        flashcards.remove(
            at: deletedIndex
        )

        // -------------------------------------------------
        // Keep current index safe
        // -------------------------------------------------

        let count =
            filteredFlashcards.count

        if count == 0 {

            currentIndex = 0

        } else if currentIndex >= count {

            currentIndex = count - 1
        }

        isShowingAnswer = false

        saveFlashcards()

        print("🗑️ Flashcard deleted.")
    }

    // =====================================================
    // RESET ALL FLASHCARDS
    // =====================================================

    func resetAllFlashcards() {

        print("========================================")
        print("🗑️ RESET ALL FLASHCARDS")
        print("Cards before reset: \(flashcards.count)")
        print("========================================")

        // Remove all cards

        flashcards.removeAll()

        // Reset study position

        currentIndex = 0

        // Hide answer

        isShowingAnswer = false

        // Clear search

        searchText = ""

        // Delete saved data

        UserDefaults.standard.removeObject(
            forKey: storageKey
        )

        // Force synchronization

        UserDefaults.standard.synchronize()

        print("========================================")
        print("✅ ALL FLASHCARDS RESET")
        print("Cards remaining: \(flashcards.count)")
        print("Current card index: \(currentIndex)")
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

        guard !cards.isEmpty else {

            return
        }

        // -------------------------------------------------
        // Never allow an invalid index
        // -------------------------------------------------

        guard
            currentIndex >= 0,
            currentIndex < cards.count
        else {

            currentIndex = 0

            return
        }

        // -------------------------------------------------
        // Get current card
        // -------------------------------------------------

        let currentCard =
            cards[currentIndex]

        // -------------------------------------------------
        // Find original card
        // -------------------------------------------------

        guard let originalIndex =
            flashcards.firstIndex(
                where: {
                    $0.id == currentCard.id
                }
            )
        else {

            return
        }

        // -------------------------------------------------
        // Update review information
        // -------------------------------------------------

        flashcards[originalIndex].difficulty =
            difficulty

        flashcards[originalIndex].timesReviewed += 1

        if correct {

            flashcards[originalIndex].timesCorrect += 1
        }

        flashcards[originalIndex].lastReviewed =
            Date()

        // -------------------------------------------------
        // Calculate next review
        // -------------------------------------------------

        flashcards[originalIndex].nextReviewDate =
            calculateNextReviewDate(
                difficulty: difficulty
            )

        // -------------------------------------------------
        // Save
        // -------------------------------------------------

        saveFlashcards()

        // -------------------------------------------------
        // Move EXACTLY one card
        // -------------------------------------------------

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

        // -------------------------------------------------
        // IMPORTANT:
        // Only increase by ONE.
        // -------------------------------------------------

        if currentIndex + 1 < count {

            currentIndex =
                currentIndex + 1

        } else {

            // Last card → return to Card 1

            currentIndex = 0
        }

        isShowingAnswer = false

        print(
            "➡️ NEXT: Card \(currentIndex + 1) of \(count)"
        )
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

        // -------------------------------------------------
        // Move EXACTLY one card backward
        // -------------------------------------------------

        if currentIndex > 0 {

            currentIndex =
                currentIndex - 1

        } else {

            // Card 1 → last card

            currentIndex =
                count - 1
        }

        isShowingAnswer = false

        print(
            "⬅️ PREVIOUS: Card \(currentIndex + 1) of \(count)"
        )
    }

    // =====================================================
    // SHOW ANSWER
    // =====================================================

    func showAnswer() {

        isShowingAnswer = true
    }

    // =====================================================
    // RESET STUDY
    // =====================================================

    func resetStudy() {

        currentIndex = 0

        isShowingAnswer = false
    }

    // =====================================================
    // SEARCH
    // =====================================================

    var filteredFlashcards: [Flashcard] {

        let query =
            searchText.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        // No search

        guard !query.isEmpty else {

            return flashcards
        }

        // Search question and answer

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

        // -------------------------------------------------
        // IMPORTANT:
        // DO NOT modify currentIndex here.
        //
        // This prevents SwiftUI from changing the index
        // unexpectedly during a redraw.
        // -------------------------------------------------

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

        guard
            currentIndex >= 0,
            currentIndex < count
        else {

            return 1
        }

        return currentIndex + 1
    }

    // =====================================================
    // TOTAL FLASHCARDS
    // =====================================================

    var totalFlashcards: Int {

        flashcards.count
    }

    // =====================================================
    // REVIEWED FLASHCARDS
    // =====================================================

    var reviewedFlashcards: Int {

        flashcards.filter {

            $0.timesReviewed > 0

        }.count
    }

    // =====================================================
    // MASTERED FLASHCARDS
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
                "💾 Saved \(flashcards.count) flashcards."
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

            print(
                "ℹ️ No saved flashcards found."
            )

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
                "✅ Loaded \(flashcards.count) flashcards."
            )

        } catch {

            print(
                "❌ Could not load flashcards: \(error)"
            )

            flashcards = []
        }
    }
}

