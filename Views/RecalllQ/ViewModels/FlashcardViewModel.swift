
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
// - Delete flashcards
// - Search
// - Review tracking
// - Difficulty tracking
// - Spaced repetition
// - Previous / Next navigation
// - Smart Suggestion integration
// =====================================================

final class FlashcardViewModel: ObservableObject {

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
    // STORAGE
    // =====================================================

    private let storageKey =
        "saved_flashcards"

    // =====================================================
    // INIT
    // =====================================================

    init() {

        loadFlashcards()

        currentIndex = 0

        isShowingAnswer = false
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

        guard
            !cleanQuestion.isEmpty,
            !cleanAnswer.isEmpty
        else {

            print(
                "❌ Flashcard was not created."
            )

            return
        }

        // -------------------------------------------------
        // Prevent duplicate memory card
        // -------------------------------------------------

        if let memoryID = memoryID {

            let exists =
                flashcards.contains {

                    $0.memoryID == memoryID
                }

            if exists {

                print(
                    "⚠️ Flashcard already exists."
                )

                return
            }
        }

        // -------------------------------------------------
        // Create flashcard
        // -------------------------------------------------

        let flashcard =
            Flashcard(
                memoryID:
                    memoryID,

                question:
                    cleanQuestion,

                answer:
                    cleanAnswer
            )

        // -------------------------------------------------
        // Add
        // -------------------------------------------------

        flashcards.append(
            flashcard
        )

        // -------------------------------------------------
        // Save
        // -------------------------------------------------

        saveFlashcards()

        // -------------------------------------------------
        // Reset study position
        // -------------------------------------------------

        if flashcards.count == 1 {

            currentIndex = 0

            isShowingAnswer = false
        }

        print(
            "✅ Flashcard created."
        )
    }

    // =====================================================
    // CREATE FROM MEMORY
    // =====================================================

    func createFromMemory(
        _ memory: Memory
    ) {

        // -------------------------------------------------
        // Prevent duplicate
        // -------------------------------------------------

        if flashcards.contains(
            where: {
                $0.memoryID == memory.id
            }
        ) {

            print(
                "⚠️ Flashcard already exists."
            )

            return
        }

        let question =
            "What is the main idea of \(memory.title)?"

        let cleanSummary =
            memory.summary.trimmingCharacters(
                in:
                    .whitespacesAndNewlines
            )

        let cleanContent =
            memory.content.trimmingCharacters(
                in:
                    .whitespacesAndNewlines
            )

        let answer =
            cleanSummary.isEmpty
            ? cleanContent
            : cleanSummary

        addFlashcard(
            question:
                question,

            answer:
                answer,

            memoryID:
                memory.id
        )
    }

    // =====================================================
    // CREATE FROM ALL MEMORIES
    // =====================================================

    func createFromMemories(
        _ memories: [Memory]
    ) {

        guard !memories.isEmpty else {

            print(
                "❌ No Memories available."
            )

            return
        }

        var createdCount = 0

        for memory in memories {

            let exists =
                flashcards.contains {

                    $0.memoryID == memory.id
                }

            if exists {
                continue
            }

            let before =
                flashcards.count

            createFromMemory(
                memory
            )

            if flashcards.count >
                before {

                createdCount += 1
            }
        }

        currentIndex = 0

        isShowingAnswer = false

        print(
            "✅ Created \(createdCount) flashcards."
        )
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

        currentIndex =
            index

        isShowingAnswer =
            false

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

        isShowingAnswer =
            false

        saveFlashcards()
    }

    // =====================================================
    // RESET ALL FLASHCARDS
    // =====================================================

    func resetAllFlashcards() {

        flashcards.removeAll()

        currentIndex = 0

        isShowingAnswer = false

        searchText = ""

        UserDefaults.standard.removeObject(
            forKey:
                storageKey
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
            difficulty:
                .easy,

            correct:
                true
        )
    }

    // =====================================================
    // MARK MEDIUM
    // =====================================================

    func markMedium() {

        reviewCurrentCard(
            difficulty:
                .medium,

            correct:
                true
        )
    }

    // =====================================================
    // MARK HARD
    // =====================================================

    func markHard() {

        reviewCurrentCard(
            difficulty:
                .hard,

            correct:
                false
        )
    }

    // =====================================================
    // REVIEW CURRENT CARD
    // =====================================================

    private func reviewCurrentCard(
        difficulty:
            Flashcard.Difficulty,

        correct:
            Bool
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
                        $0.id ==
                            currentCard.id
                    }
                )
        else {
            return
        }

        flashcards[originalIndex]
            .difficulty =
                difficulty

        flashcards[originalIndex]
            .timesReviewed += 1

        if correct {

            flashcards[originalIndex]
                .timesCorrect += 1
        }

        flashcards[originalIndex]
            .lastReviewed =
                Date()

        flashcards[originalIndex]
            .nextReviewDate =
                calculateNextReviewDate(
                    difficulty:
                        difficulty
                )

        saveFlashcards()

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
    // RESET STUDY
    // =====================================================

    func resetStudy() {

        currentIndex = 0

        isShowingAnswer = false
    }

    // =====================================================
    // FILTERED FLASHCARDS
    // =====================================================

    var filteredFlashcards:
        [Flashcard] {

        let query =
            searchText.trimmingCharacters(
                in:
                    .whitespacesAndNewlines
            )

        guard !query.isEmpty else {

            return flashcards
        }

        return flashcards.filter {

            $0.question
                .localizedCaseInsensitiveContains(
                    query
                )
            ||
            $0.answer
                .localizedCaseInsensitiveContains(
                    query
                )
        }
    }

    // =====================================================
    // CURRENT FLASHCARD
    // =====================================================

    var currentFlashcard:
        Flashcard? {

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
        difficulty:
            Flashcard.Difficulty
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
            byAdding:
                .day,

            value:
                days,

            to:
                Date()
        ) ?? Date()
    }

    // =====================================================
    // SAVE
    // =====================================================

    private func saveFlashcards() {

        do {

            let data =
                try JSONEncoder()
                    .encode(
                        flashcards
                    )

            UserDefaults.standard.set(
                data,

                forKey:
                    storageKey
            )

        } catch {

            print(
                "❌ Could not save flashcards: \(error)"
            )
        }
    }

    // =====================================================
    // LOAD
    // =====================================================

    private func loadFlashcards() {

        guard
            let data =
                UserDefaults.standard.data(
                    forKey:
                        storageKey
                )
        else {

            flashcards = []

            return
        }

        do {

            flashcards =
                try JSONDecoder()
                    .decode(
                        [Flashcard].self,

                        from:
                            data
                    )

        } catch {

            print(
                "❌ Could not load flashcards: \(error)"
            )

            flashcards = []
        }
    }
}
