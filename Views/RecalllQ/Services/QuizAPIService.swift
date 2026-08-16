
import Foundation

// =====================================================
// SERVICE: QuizAPIService
// =====================================================
// PURPOSE:
// Generates quiz questions from RecalllQ Memories.
//
// IMPORTANT:
// This version works LOCALLY.
// No API key is required.
//
// Later, this service can be replaced with a secure
// backend AI service without changing QuizView.
// =====================================================

final class QuizAPIService {

    // =====================================================
    // ERRORS
    // =====================================================

    enum QuizAPIError: LocalizedError {

        case emptyMemory
        case emptyQuestions
        case invalidData

        var errorDescription: String? {

            switch self {

            case .emptyMemory:
                return "The selected Memory does not contain enough information to create a quiz."

            case .emptyQuestions:
                return "No quiz questions could be generated."

            case .invalidData:
                return "The quiz data is invalid."
            }
        }
    }

    // =====================================================
    // INIT
    // =====================================================

    init() {

        print("✅ QuizAPIService initialized")
        print("ℹ️ Local quiz generation mode enabled.")
    }

    // =====================================================
    // GENERATE QUIZ
    // =====================================================
    // This function keeps the same interface your
    // QuizView and QuizViewModel are already using.
    //
    // No API call is made.
    // =====================================================

    func generateQuiz(
        from memory: Memory,
        numberOfQuestions: Int = 5
    ) async throws -> [QuizQuestion] {

        // -------------------------------------------------
        // CLEAN MEMORY CONTENT
        // -------------------------------------------------

        let title =
            memory.title.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        let content =
            memory.content.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        let summary =
            memory.summary.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        // -------------------------------------------------
        // VALIDATE MEMORY
        // -------------------------------------------------

        guard !title.isEmpty else {

            throw QuizAPIError.emptyMemory
        }

        guard !content.isEmpty || !summary.isEmpty else {

            throw QuizAPIError.emptyMemory
        }

        // -------------------------------------------------
        // NUMBER OF QUESTIONS
        // -------------------------------------------------

        let count =
            max(
                1,
                min(
                    numberOfQuestions,
                    10
                )
            )

        // -------------------------------------------------
        // BUILD SOURCE TEXT
        // -------------------------------------------------

        let sourceText =
            !summary.isEmpty
            ? summary
            : content

        // -------------------------------------------------
        // GENERATE QUESTIONS
        // -------------------------------------------------

        var questions: [QuizQuestion] = []

        // Question 1
        questions.append(
            makeMainIdeaQuestion(
                memory: memory,
                answer: sourceText
            )
        )

        // Question 2
        if questions.count < count {

            questions.append(
                makeTitleQuestion(
                    memory: memory
                )
            )
        }

        // Question 3
        if questions.count < count {

            questions.append(
                makeContentQuestion(
                    memory: memory,
                    answer: sourceText
                )
            )
        }

        // Question 4
        if questions.count < count {

            questions.append(
                makeTagQuestion(
                    memory: memory
                )
            )
        }

        // Question 5
        if questions.count < count {

            questions.append(
                makeReviewQuestion(
                    memory: memory,
                    answer: sourceText
                )
            )
        }

        // -------------------------------------------------
        // LIMIT QUESTIONS
        // -------------------------------------------------

        let finalQuestions =
            Array(
                questions.prefix(count)
            )

        guard !finalQuestions.isEmpty else {

            throw QuizAPIError.emptyQuestions
        }

        print("========================================")
        print("✅ LOCAL QUIZ GENERATED")
        print("Memory: \(memory.title)")
        print("Questions: \(finalQuestions.count)")
        print("========================================")

        return finalQuestions
    }

    // =====================================================
    // QUESTION 1
    // =====================================================

    private func makeMainIdeaQuestion(
        memory: Memory,
        answer: String
    ) -> QuizQuestion {

        let correctAnswer =
            answer.isEmpty
            ? memory.content
            : answer

        let options = makeOptions(
            correctAnswer: correctAnswer
        )

        return QuizQuestion(

            memoryID:
                memory.id,

            question:
                "What is the main idea of \(memory.title)?",

            options:
                options,

            correctAnswer:
                correctAnswer,

            explanation:
                "This answer comes from the summary or content stored in your RecalllQ Memory."
        )
    }

    // =====================================================
    // QUESTION 2
    // =====================================================

    private func makeTitleQuestion(
        memory: Memory
    ) -> QuizQuestion {

        let correctAnswer =
            memory.title

        let options = [
            correctAnswer,
            "An unrelated topic",
            "A completely different subject",
            "None of these"
        ]
        .shuffled()

        return QuizQuestion(

            memoryID:
                memory.id,

            question:
                "Which topic does this Memory focus on?",

            options:
                options,

            correctAnswer:
                correctAnswer,

            explanation:
                "The Memory title identifies the main topic being studied."
        )
    }

    // =====================================================
    // QUESTION 3
    // =====================================================

    private func makeContentQuestion(
        memory: Memory,
        answer: String
    ) -> QuizQuestion {

        let correctAnswer =
            answer

        let options =
            makeOptions(
                correctAnswer:
                    correctAnswer
            )

        return QuizQuestion(

            memoryID:
                memory.id,

            question:
                "Which statement best represents the information stored in this Memory?",

            options:
                options,

            correctAnswer:
                correctAnswer,

            explanation:
                "The correct answer is based on the information contained in the selected Memory."
        )
    }

    // =====================================================
    // QUESTION 4
    // =====================================================

    private func makeTagQuestion(
        memory: Memory
    ) -> QuizQuestion {

        let correctAnswer: String

        if memory.tags.isEmpty {

            correctAnswer =
                "The Memory contains study information."

        } else {

            correctAnswer =
                memory.tags.joined(
                    separator: ", "
                )
        }

        let options = [
            correctAnswer,
            "Sports and entertainment",
            "Unrelated personal information",
            "None of the above"
        ]
        .shuffled()

        return QuizQuestion(

            memoryID:
                memory.id,

            question:
                "Which tags are associated with this Memory?",

            options:
                options,

            correctAnswer:
                correctAnswer,

            explanation:
                "These tags were assigned to the Memory by RecalllQ."
        )
    }

    // =====================================================
    // QUESTION 5
    // =====================================================

    private func makeReviewQuestion(
        memory: Memory,
        answer: String
    ) -> QuizQuestion {

        let correctAnswer =
            answer

        let options =
            makeOptions(
                correctAnswer:
                    correctAnswer
            )

        return QuizQuestion(

            memoryID:
                memory.id,

            question:
                "What should you remember from \(memory.title)?",

            options:
                options,

            correctAnswer:
                correctAnswer,

            explanation:
                "Reviewing the Memory summary or content helps reinforce learning."
        )
    }

    // =====================================================
    // CREATE OPTIONS
    // =====================================================

    private func makeOptions(
        correctAnswer: String
    ) -> [String] {

        let incorrectAnswers = [

            "This information is unrelated to the topic.",

            "There is not enough information to answer this question.",

            "This describes a completely different subject."
        ]

        return (
            [correctAnswer] +
            incorrectAnswers
        )
        .shuffled()
    }
}
