
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
// - Save flashcards locally
// - Load flashcards
// - Delete flashcards
// - Search flashcards
// - Track reviews
// - Track correct answers
// - Track difficulty
// - Prepare for spaced repetition
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

        guard
            !cleanQuestion.isEmpty,
            !cleanAnswer.isEmpty
        else {
            return
        }

        let flashcard = Flashcard(
            memoryID: memoryID,
            question: cleanQuestion,
            answer: cleanAnswer
        )

        flashcards.insert(
            flashcard,
            at: 0
        )

        saveFlashcards()
    }

    // =====================================================
    // CREATE FLASHCARDS FROM MEMORY
    // =====================================================
    // Creates a simple question/answer card from
    // an existing RecalllQ Memory.

    func createFromMemory(
        _ memory: Memory
    ) {

        let question =
            "What is the main idea of \(memory.title)?"

        let answer =
            memory.summary.isEmpty
            ? memory.content
            : memory.summary

        addFlashcard(
            question: question,
            answer: answer,
            memoryID: memory.id
        )
    }

    // =====================================================
    // CREATE FLASHCARDS FROM ALL MEMORIES
    // =====================================================

    func createFromMemories(
        _ memories: [Memory]
    ) {

        for memory in memories {

            createFromMemory(
                memory
            )
        }
    }

    // =====================================================
    // DELETE FLASHCARD
    // =====================================================

    func deleteFlashcard(
        id: UUID
    ) {

        flashcards.removeAll {
            $0.id == id
        }

        saveFlashcards()

        resetStudy()
    }

    // =====================================================
    // MARK CARD AS EASY
    // =====================================================

    func markEasy() {

        reviewCurrentCard(
            difficulty: .easy,
            correct: true
        )
    }

    // =====================================================
    // MARK CARD AS MEDIUM
    // =====================================================

    func markMedium() {

        reviewCurrentCard(
            difficulty: .medium,
            correct: true
        )
    }

    // =====================================================
    // MARK CARD AS HARD
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

        guard
            !filteredFlashcards.isEmpty,
            currentIndex < filteredFlashcards.count
        else {
            return
        }

        let currentCard =
            filteredFlashcards[currentIndex]

        guard let index =
            flashcards.firstIndex(
                where: {
                    $0.id == currentCard.id
                }
            )
        else {
            return
        }

        // =================================================
        // UPDATE REVIEW DATA
        // =================================================

        flashcards[index].difficulty =
            difficulty

        flashcards[index].timesReviewed += 1

        if correct {
            flashcards[index].timesCorrect += 1
        }

        flashcards[index].lastReviewed =
            Date()

        // =================================================
        // CALCULATE NEXT REVIEW
        // =================================================

        flashcards[index].nextReviewDate =
            calculateNextReviewDate(
                difficulty: difficulty
            )

        // =================================================
        // SAVE
        // =================================================

        saveFlashcards()

        // =================================================
        // MOVE TO NEXT CARD
        // =================================================

        nextCard()
    }

    // =====================================================
    // NEXT CARD
    // =====================================================

    func nextCard() {

        guard !filteredFlashcards.isEmpty else {
            return
        }

        if currentIndex <
            filteredFlashcards.count - 1 {

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

        guard !filteredFlashcards.isEmpty else {
            return
        }

        if currentIndex > 0 {

            currentIndex -= 1

        } else {

            currentIndex =
                filteredFlashcards.count - 1
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

    var filteredFlashcards: [Flashcard] {

        let query =
            searchText.trimmingCharacters(
                in: .whitespacesAndNewlines
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

    var currentFlashcard: Flashcard? {

        guard
            !filteredFlashcards.isEmpty,
            currentIndex < filteredFlashcards.count
        else {
            return nil
        }

        return filteredFlashcards[currentIndex]
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
    // Simple first version.
    //
    // Easy   → 7 days
    // Medium → 3 days
    // Hard   → 1 day
    //
    // We can make this smarter later.

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

        guard let data =
            try? JSONEncoder().encode(
                flashcards
            )
        else {

            print(
                "❌ Could not save flashcards."
            )

            return
        }

        UserDefaults.standard.set(
            data,
            forKey: storageKey
        )
    }

    // =====================================================
    // LOAD FLASHCARDS
    // =====================================================

    private func loadFlashcards() {

        guard
            let data =
                UserDefaults.standard.data(
                    forKey: storageKey
                ),

            let decoded =
                try? JSONDecoder().decode(
                    [Flashcard].self,
                    from: data
                )

        else {

            print(
                "ℹ️ No saved flashcards found."
            )

            return
        }

        flashcards = decoded
    }
}
