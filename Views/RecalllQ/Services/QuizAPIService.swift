
import Foundation

// =====================================================
// SERVICE: QuizAPIService
// =====================================================
// PURPOSE:
// Generates high-quality quiz questions from RecalllQ
// Memories using the OpenAI Responses API.
//
// FEATURES:
// - Real OpenAI API integration
// - GPT-5.6
// - Multiple-choice questions
// - Easy / Medium / Hard difficulty
// - Explanations
// - JSON response parsing
// - Local fallback
//
// DEVELOPMENT NOTE:
// The API key is read from UserDefaults using:
//
// "OPENAI_API_KEY"
//
// For a production application, use a secure backend
// instead of storing an API key inside the iOS app.
// =====================================================

final class QuizAPIService {

    // =====================================================
    // CONFIGURATION
    // =====================================================

    private let apiURL = URL(
        string: "https://api.openai.com/v1/responses"
    )!

    private let apiKeyStorageKey = "OPENAI_API_KEY"

    private let model = "gpt-5.6"

    // =====================================================
    // ERRORS
    // =====================================================

    enum QuizAPIError: LocalizedError {

        case missingAPIKey
        case emptyMemory
        case emptyQuestions
        case invalidData
        case invalidResponse
        case networkError
        case apiError(String)

        var errorDescription: String? {

            switch self {

            case .missingAPIKey:
                return "No OpenAI API key has been configured."

            case .emptyMemory:
                return "The selected Memory does not contain enough information to create a quiz."

            case .emptyQuestions:
                return "No quiz questions could be generated."

            case .invalidData:
                return "The quiz data returned by the AI is invalid."

            case .invalidResponse:
                return "The AI service returned an invalid response."

            case .networkError:
                return "Unable to connect to the AI service."

            case .apiError(let message):
                return message
            }
        }
    }

    // =====================================================
    // OPENAI RESPONSE MODELS
    // =====================================================

    private struct APIResponse: Decodable {
        let output: [OutputItem]?
    }

    private struct OutputItem: Decodable {
        let type: String?
        let content: [OutputContent]?
    }

    private struct OutputContent: Decodable {
        let type: String?
        let text: String?
    }

    // =====================================================
    // AI QUIZ MODELS
    // =====================================================

    private struct AIQuizResponse: Decodable {
        let questions: [AIQuestion]
    }

    private struct AIQuestion: Decodable {

        let question: String
        let options: [String]
        let correctAnswer: String
        let explanation: String
        let difficulty: String
    }

    // =====================================================
    // INIT
    // =====================================================

    init() {

        print("========================================")
        print("🤖 QuizAPIService initialized")
        print("OpenAI Responses API enabled")
        print("Model: \(model)")
        print("========================================")
    }

    // =====================================================
    // PUBLIC: GENERATE QUIZ
    // =====================================================

    func generateQuiz(
        from memory: Memory,
        numberOfQuestions: Int = 5
    ) async throws -> [QuizQuestion] {

        // -------------------------------------------------
        // CLEAN MEMORY
        // -------------------------------------------------

        let title = memory.title
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        let content = memory.content
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        let summary = memory.summary
            .trimmingCharacters(
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
        // QUESTION COUNT
        // -------------------------------------------------

        let count = max(
            1,
            min(numberOfQuestions, 10)
        )

        // -------------------------------------------------
        // SOURCE TEXT
        // -------------------------------------------------

        let sourceText = !summary.isEmpty
            ? summary
            : content

        // -------------------------------------------------
        // LOAD API KEY
        // -------------------------------------------------

        let apiKey = UserDefaults.standard.string(
            forKey: apiKeyStorageKey
        )?
        .trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        // =================================================
        // NO API KEY
        // =================================================

        guard let apiKey, !apiKey.isEmpty else {

            print("========================================")
            print("ℹ️ No OpenAI API key found.")
            print("🧠 Using local quiz generation.")
            print("========================================")

            return createLocalQuiz(
                memory: memory,
                sourceText: sourceText,
                numberOfQuestions: count
            )
        }

        // =================================================
        // OPENAI GENERATION
        // =================================================

        do {

            print("========================================")
            print("🤖 OPENAI QUIZ GENERATION")
            print("Memory: \(title)")
            print("Questions: \(count)")
            print("========================================")

            let questions = try await generateUsingOpenAI(
                memory: memory,
                sourceText: sourceText,
                numberOfQuestions: count,
                apiKey: apiKey
            )

            guard !questions.isEmpty else {
                throw QuizAPIError.emptyQuestions
            }

            print("========================================")
            print("✅ OPENAI QUIZ GENERATED")
            print("Questions: \(questions.count)")
            print("========================================")

            return questions

        } catch {

            print("========================================")
            print("⚠️ OPENAI API FAILED")
            print("Reason: \(error.localizedDescription)")
            print("🧠 Using local fallback.")
            print("========================================")

            return createLocalQuiz(
                memory: memory,
                sourceText: sourceText,
                numberOfQuestions: count
            )
        }
    }

    // =====================================================
    // OPENAI GENERATION
    // =====================================================

    private func generateUsingOpenAI(
        memory: Memory,
        sourceText: String,
        numberOfQuestions: Int,
        apiKey: String
    ) async throws -> [QuizQuestion] {

        // -------------------------------------------------
        // PROMPT
        // -------------------------------------------------

        let prompt = """
        You are the AI Quiz Generator for RecalllQ,
        an academic learning and memory assistant.

        Create exactly \(numberOfQuestions) high-quality
        multiple-choice questions using ONLY the
        information provided below.

        MEMORY TITLE:
        \(memory.title)

        MEMORY CONTENT:
        \(sourceText)

        REQUIREMENTS:

        1. Create exactly \(numberOfQuestions) questions.

        2. Each question must test understanding of
           the supplied academic information.

        3. Each question must contain exactly
           4 answer options.

        4. There must be exactly ONE correct answer.

        5. Incorrect options must be plausible
           distractors.

        6. Do NOT use:
           - None of the above
           - All of the above
           - This information is unrelated
           - There is not enough information

        7. Provide a short educational explanation.

        8. Difficulty must be exactly one of:
           easy
           medium
           hard

        9. Do not invent facts.

        10. Questions should be useful for studying
            and exam preparation.

        Return ONLY JSON using this exact structure:

        {
          "questions": [
            {
              "question": "Question text",
              "options": [
                "Option A",
                "Option B",
                "Option C",
                "Option D"
              ],
              "correctAnswer": "Exact correct option",
              "explanation": "Short educational explanation",
              "difficulty": "medium"
            }
          ]
        }
        """

        // -------------------------------------------------
        // REQUEST BODY
        // -------------------------------------------------

        let inputObject: [String: Any] = [
            "model": model,
            "input": prompt
        ]

        let body = try JSONSerialization.data(
            withJSONObject: inputObject,
            options: []
        )

        // -------------------------------------------------
        // REQUEST
        // -------------------------------------------------

        var request = URLRequest(
            url: apiURL
        )

        request.httpMethod = "POST"

        request.setValue(
            "application/json",
            forHTTPHeaderField: "Content-Type"
        )

        request.setValue(
            "Bearer \(apiKey)",
            forHTTPHeaderField: "Authorization"
        )

        request.httpBody = body

        request.timeoutInterval = 60

        // -------------------------------------------------
        // NETWORK CALL
        // -------------------------------------------------

        let data: Data
        let response: URLResponse

        do {

            (data, response) = try await URLSession.shared.data(
                for: request
            )

        } catch {

            print(
                "❌ Network error: \(error.localizedDescription)"
            )

            throw QuizAPIError.networkError
        }

        // -------------------------------------------------
        // HTTP RESPONSE
        // -------------------------------------------------

        guard let httpResponse = response as? HTTPURLResponse else {

            throw QuizAPIError.invalidResponse
        }

        print(
            "🌐 OpenAI HTTP status: \(httpResponse.statusCode)"
        )

        // -------------------------------------------------
        // API ERROR
        // -------------------------------------------------

        guard (200...299).contains(
            httpResponse.statusCode
        ) else {

            let message = String(
                data: data,
                encoding: .utf8
            ) ?? "Unknown OpenAI API error."

            print(
                "❌ OpenAI response:"
            )

            print(message)

            throw QuizAPIError.apiError(
                "OpenAI API error (\(httpResponse.statusCode))."
            )
        }

        // -------------------------------------------------
        // DECODE RESPONSE
        // -------------------------------------------------

        let decodedResponse: APIResponse

        do {

            decodedResponse = try JSONDecoder().decode(
                APIResponse.self,
                from: data
            )

        } catch {

            print(
                "❌ Could not decode OpenAI response:"
            )

            print(error)

            throw QuizAPIError.invalidResponse
        }

        // -------------------------------------------------
        // FIND OUTPUT TEXT
        // -------------------------------------------------

        var outputText: String?

        for item in decodedResponse.output ?? [] {

            guard let content = item.content else {
                continue
            }

            for contentItem in content {

                if contentItem.type == "output_text",
                   let text = contentItem.text {

                    outputText = text
                    break
                }
            }

            if outputText != nil {
                break
            }
        }

        guard let outputText else {

            print(
                "❌ No output text found."
            )

            throw QuizAPIError.invalidResponse
        }

        print("✅ OpenAI returned quiz data.")

        // -------------------------------------------------
        // CLEAN JSON
        // -------------------------------------------------

        let cleanedJSON = cleanJSON(
            outputText
        )

        guard let jsonData = cleanedJSON.data(
            using: .utf8
        ) else {

            throw QuizAPIError.invalidData
        }

        // -------------------------------------------------
        // DECODE QUIZ JSON
        // -------------------------------------------------

        let aiQuiz: AIQuizResponse

        do {

            aiQuiz = try JSONDecoder().decode(
                AIQuizResponse.self,
                from: jsonData
            )

        } catch {

            print("❌ AI JSON decoding failed.")

            print("AI output:")
            print(outputText)

            throw QuizAPIError.invalidData
        }

        // -------------------------------------------------
        // CONVERT AI QUESTIONS
        // -------------------------------------------------

        var quizQuestions: [QuizQuestion] = []

        for aiQuestion in aiQuiz.questions {

            let questionText = aiQuestion.question
                .trimmingCharacters(
                    in: .whitespacesAndNewlines
                )

            let options = aiQuestion.options.map {
                $0.trimmingCharacters(
                    in: .whitespacesAndNewlines
                )
            }

            let correctAnswer = aiQuestion.correctAnswer
                .trimmingCharacters(
                    in: .whitespacesAndNewlines
                )

            let explanation = aiQuestion.explanation
                .trimmingCharacters(
                    in: .whitespacesAndNewlines
                )

            // -------------------------------------------------
            // VALIDATION
            // -------------------------------------------------

            guard !questionText.isEmpty else {
                continue
            }

            guard options.count == 4 else {
                continue
            }

            guard options.allSatisfy({
                !$0.isEmpty
            }) else {
                continue
            }

            guard options.contains(correctAnswer) else {
                continue
            }

            // -------------------------------------------------
            // DIFFICULTY
            // -------------------------------------------------

            let difficulty = convertDifficulty(
                aiQuestion.difficulty
            )

            // -------------------------------------------------
            // CREATE APP QUESTION
            // -------------------------------------------------

            let question = QuizQuestion(
                memoryID: memory.id,
                question: questionText,
                options: options.shuffled(),
                correctAnswer: correctAnswer,
                explanation: explanation,
                difficulty: difficulty
            )

            quizQuestions.append(
                question
            )
        }

        // -------------------------------------------------
        // VALIDATE QUESTIONS
        // -------------------------------------------------

        guard !quizQuestions.isEmpty else {

            throw QuizAPIError.emptyQuestions
        }

        // -------------------------------------------------
        // RETURN REQUESTED NUMBER
        // -------------------------------------------------

        return Array(
            quizQuestions.prefix(
                numberOfQuestions
            )
        )
    }

    // =====================================================
    // CLEAN JSON
    // =====================================================

    private func cleanJSON(
        _ text: String
    ) -> String {

        var cleaned = text
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        // Remove ```json

        if cleaned.hasPrefix("```json") {

            cleaned = String(
                cleaned.dropFirst(
                    "```json".count
                )
            )
        }

        // Remove ```

        if cleaned.hasPrefix("```") {

            cleaned = String(
                cleaned.dropFirst(
                    "```".count
                )
            )
        }

        if cleaned.hasSuffix("```") {

            cleaned = String(
                cleaned.dropLast(
                    "```".count
                )
            )
        }

        return cleaned
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )
    }

    // =====================================================
    // CONVERT DIFFICULTY
    // =====================================================

    private func convertDifficulty(
        _ value: String
    ) -> QuizQuestion.Difficulty {

        switch value
            .lowercased()
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            ) {

        case "easy":
            return .easy

        case "hard":
            return .hard

        default:
            return .medium
        }
    }

    // =====================================================
    // LOCAL FALLBACK
    // =====================================================

    private func createLocalQuiz(
        memory: Memory,
        sourceText: String,
        numberOfQuestions: Int
    ) -> [QuizQuestion] {

        var questions: [QuizQuestion] = []

        let correctAnswer = sourceText
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        guard !correctAnswer.isEmpty else {
            return []
        }

        let questionTemplates = [

            (
                "What is the main idea of \(memory.title)?",
                QuizQuestion.Difficulty.medium
            ),

            (
                "Which statement best represents the information in \(memory.title)?",
                QuizQuestion.Difficulty.medium
            ),

            (
                "What should you remember about \(memory.title)?",
                QuizQuestion.Difficulty.easy
            ),

            (
                "Which answer best summarizes \(memory.title)?",
                QuizQuestion.Difficulty.medium
            ),

            (
                "What important information does \(memory.title) contain?",
                QuizQuestion.Difficulty.hard
            )
        ]

        let count = min(
            numberOfQuestions,
            questionTemplates.count
        )

        for index in 0..<count {

            let template = questionTemplates[index]

            let question = QuizQuestion(

                memoryID: memory.id,

                question: template.0,

                options: makeOptions(
                    correctAnswer: correctAnswer
                ),

                correctAnswer: correctAnswer,

                explanation:
                    "The answer is based on the information stored in this RecalllQ Memory.",

                difficulty: template.1
            )

            questions.append(
                question
            )
        }

        print(
            "🧠 Local fallback generated \(questions.count) questions."
        )

        return questions
    }

    // =====================================================
    // LOCAL OPTIONS
    // =====================================================

    private func makeOptions(
        correctAnswer: String
    ) -> [String] {

        let incorrectAnswers = [

            "This information does not relate to the selected study topic.",

            "The Memory does not provide information supporting this answer.",

            "This describes a different academic topic."
        ]

        return (
            [correctAnswer] +
            incorrectAnswers
        ).shuffled()
    }
}
