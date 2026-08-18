
import Foundation

// =====================================================
// SERVICE: QuizAPIService
// =====================================================
// PURPOSE:
// Generates high-quality quiz questions for RecalllQ
// using the OpenAI Responses API.
//
// FEATURES:
// - Real OpenAI API integration
// - GPT-5.6
// - Structured JSON output
// - Multiple-choice questions
// - Exactly 4 answer options
// - Easy / Medium / Hard difficulty
// - Educational explanations
// - Strong response validation
// - Local fallback when API is unavailable
// - Compatible with QuizViewModel
// - Compatible with QuizQuestion
//
// API KEY:
// UserDefaults key:
// "OPENAI_API_KEY"
//
// IMPORTANT:
// Storing an OpenAI API key directly in an iOS application
// is acceptable for a classroom/capstone prototype,
// but production applications should use a secure backend.
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
    // AI QUIZ RESPONSE MODELS
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
    // PUBLIC:
    // GENERATE QUIZ
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
        // VALIDATE TITLE
        // -------------------------------------------------

        guard !title.isEmpty else {

            throw QuizAPIError.emptyMemory
        }

        // -------------------------------------------------
        // VALIDATE CONTENT
        // -------------------------------------------------

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
            print("========================================")
            print("Memory: \(title)")
            print("Questions requested: \(count)")
            print("Model: \(model)")
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

            // -------------------------------------------------
            // LOCAL FALLBACK
            // -------------------------------------------------

            print("========================================")
            print("⚠️ OPENAI GENERATION FAILED")
            print("Reason: \(error.localizedDescription)")
            print("🧠 Creating local fallback quiz.")
            print("========================================")

            let fallbackQuestions = createLocalQuiz(
                memory: memory,
                sourceText: sourceText,
                numberOfQuestions: count
            )

            guard !fallbackQuestions.isEmpty else {

                throw error
            }

            return fallbackQuestions
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

        // =================================================
        // SYSTEM / INSTRUCTION PROMPT
        // =================================================

        let prompt = """
        You are the AI Quiz Generator for RecalllQ,
        an academic learning and memory assistant.

        Your job is to create a high-quality multiple-choice
        quiz using ONLY the academic information supplied
        in the Memory.

        MEMORY TITLE:
        \(memory.title)

        MEMORY CONTENT:
        \(sourceText)

        REQUIREMENTS:

        1. Create exactly \(numberOfQuestions) questions.

        2. Every question must test understanding of the
           supplied information.

        3. Every question must contain exactly 4 answer
           options.

        4. There must be exactly ONE correct answer.

        5. Incorrect answers must be plausible distractors.

        6. Do not invent facts that are not supported by
           the supplied Memory.

        7. Do not use:
           - All of the above
           - None of the above
           - This information is unrelated
           - There is not enough information

        8. Provide a short educational explanation for
           every question.

        9. Difficulty must be exactly one of:
           easy
           medium
           hard

        10. Questions should be useful for studying and
            academic exam preparation.

        11. The correctAnswer must exactly match one of
            the four options.

        12. Make the questions meaningfully different from
            one another.

        13. Avoid repeating the same question structure
            unnecessarily.

        14. Return ONLY the requested structured data.
        """

        // =================================================
        // STRUCTURED OUTPUT SCHEMA
        // =================================================
        //
        // This tells the Responses API exactly what shape
        // the AI response must have.
        // =================================================

        let questionSchema: [String: Any] = [

            "type": "object",

            "properties": [

                "question": [
                    "type": "string"
                ],

                "options": [
                    "type": "array",

                    "items": [
                        "type": "string"
                    ],

                    "minItems": 4,
                    "maxItems": 4
                ],

                "correctAnswer": [
                    "type": "string"
                ],

                "explanation": [
                    "type": "string"
                ],

                "difficulty": [
                    "type": "string",

                    "enum": [
                        "easy",
                        "medium",
                        "hard"
                    ]
                ]
            ],

            "required": [
                "question",
                "options",
                "correctAnswer",
                "explanation",
                "difficulty"
            ],

            "additionalProperties": false
        ]

        let quizSchema: [String: Any] = [

            "type": "object",

            "properties": [

                "questions": [

                    "type": "array",

                    "items": questionSchema,

                    "minItems": numberOfQuestions,
                    "maxItems": numberOfQuestions
                ]
            ],

            "required": [
                "questions"
            ],

            "additionalProperties": false
        ]

        // =================================================
        // REQUEST BODY
        // =================================================

        let textConfiguration: [String: Any] = [

            "format": [

                "type": "json_schema",

                "name": "recalliq_quiz",

                "strict": true,

                "schema": quizSchema
            ]
        ]

        let inputObject: [String: Any] = [

            "model": model,

            "input": prompt,

            "text": textConfiguration
        ]

        // =================================================
        // SERIALIZE REQUEST
        // =================================================

        let body: Data

        do {

            body = try JSONSerialization.data(
                withJSONObject: inputObject,
                options: []
            )

        } catch {

            print("❌ Could not create request JSON.")
            throw QuizAPIError.invalidData
        }

        // =================================================
        // CREATE REQUEST
        // =================================================

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

        // =================================================
        // NETWORK CALL
        // =================================================

        let data: Data
        let response: URLResponse

        do {

            (data, response) = try await URLSession.shared.data(
                for: request
            )

        } catch {

            print("❌ Network error:")
            print(error.localizedDescription)

            throw QuizAPIError.networkError
        }

        // =================================================
        // HTTP RESPONSE
        // =================================================

        guard let httpResponse = response as? HTTPURLResponse else {

            throw QuizAPIError.invalidResponse
        }

        print(
            "🌐 OpenAI HTTP status: \(httpResponse.statusCode)"
        )

        // =================================================
        // API ERROR
        // =================================================

        guard (200...299).contains(
            httpResponse.statusCode
        ) else {

            let serverMessage = String(
                data: data,
                encoding: .utf8
            ) ?? "Unknown OpenAI API error."

            print("❌ OpenAI API response:")
            print(serverMessage)

            throw QuizAPIError.apiError(
                "OpenAI API error (\(httpResponse.statusCode))."
            )
        }

        // =================================================
        // DECODE OPENAI RESPONSE
        // =================================================

        let decodedResponse: APIResponse

        do {

            decodedResponse = try JSONDecoder().decode(
                APIResponse.self,
                from: data
            )

        } catch {

            print(
                "❌ Could not decode OpenAI response."
            )

            print(error)

            let rawResponse = String(
                data: data,
                encoding: .utf8
            ) ?? ""

            print("Raw response:")
            print(rawResponse)

            throw QuizAPIError.invalidResponse
        }

        // =================================================
        // FIND OUTPUT TEXT
        // =================================================

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

        // =================================================
        // VALIDATE OUTPUT
        // =================================================

        guard let outputText,
              !outputText.trimmingCharacters(
                in: .whitespacesAndNewlines
              ).isEmpty else {

            print("❌ OpenAI returned no output text.")

            throw QuizAPIError.invalidResponse
        }

        print("✅ OpenAI returned structured quiz data.")

        // =================================================
        // CLEAN JSON
        // =================================================

        let cleanedJSON = cleanJSON(
            outputText
        )

        guard let jsonData = cleanedJSON.data(
            using: .utf8
        ) else {

            throw QuizAPIError.invalidData
        }

        // =================================================
        // DECODE QUIZ
        // =================================================

        let aiQuiz: AIQuizResponse

        do {

            aiQuiz = try JSONDecoder().decode(
                AIQuizResponse.self,
                from: jsonData
            )

        } catch {

            print("❌ AI quiz JSON decoding failed.")

            print("AI output:")
            print(outputText)

            print("Decoding error:")
            print(error)

            throw QuizAPIError.invalidData
        }

        // =================================================
        // VALIDATE QUESTION COUNT
        // =================================================

        guard !aiQuiz.questions.isEmpty else {

            throw QuizAPIError.emptyQuestions
        }

        // =================================================
        // CONVERT AI QUESTIONS
        // =================================================

        var quizQuestions: [QuizQuestion] = []

        for aiQuestion in aiQuiz.questions {

            let questionText = aiQuestion.question
                .trimmingCharacters(
                    in: .whitespacesAndNewlines
                )

            let cleanedOptions = aiQuestion.options.map {

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

            // =================================================
            // BASIC VALIDATION
            // =================================================

            guard !questionText.isEmpty else {

                print("⚠️ Skipping empty question.")
                continue
            }

            guard cleanedOptions.count == 4 else {

                print(
                    "⚠️ Skipping question with \(cleanedOptions.count) options."
                )

                continue
            }

            guard cleanedOptions.allSatisfy({
                !$0.isEmpty
            }) else {

                print(
                    "⚠️ Skipping question containing empty options."
                )

                continue
            }

            // =================================================
            // DUPLICATE OPTION VALIDATION
            // =================================================

            let normalizedOptions = cleanedOptions.map {
                $0.lowercased()
                    .trimmingCharacters(
                        in: .whitespacesAndNewlines
                    )
            }

            guard Set(normalizedOptions).count == 4 else {

                print(
                    "⚠️ Skipping question with duplicate options."
                )

                continue
            }

            // =================================================
            // CORRECT ANSWER VALIDATION
            // =================================================

            guard cleanedOptions.contains(correctAnswer) else {

                print(
                    "⚠️ Skipping question because correct answer is not an option."
                )

                continue
            }

            // =================================================
            // EXPLANATION
            // =================================================

            let finalExplanation = explanation.isEmpty
                ? "This answer is supported by the information stored in the RecalllQ Memory."
                : explanation

            // =================================================
            // DIFFICULTY
            // =================================================

            let difficulty = convertDifficulty(
                aiQuestion.difficulty
            )

            // =================================================
            // CREATE APP QUESTION
            // =================================================

            let question = QuizQuestion(

                memoryID: memory.id,

                question: questionText,

                options: cleanedOptions.shuffled(),

                correctAnswer: correctAnswer,

                explanation: finalExplanation,

                difficulty: difficulty
            )

            quizQuestions.append(
                question
            )
        }

        // =================================================
        // FINAL VALIDATION
        // =================================================

        guard !quizQuestions.isEmpty else {

            throw QuizAPIError.emptyQuestions
        }

        // =================================================
        // RETURN REQUESTED NUMBER
        // =================================================

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

        // -------------------------------------------------
        // Remove Markdown JSON fence
        // -------------------------------------------------

        if cleaned.hasPrefix("```json") {

            cleaned = String(
                cleaned.dropFirst(
                    "```json".count
                )
            )
        }

        // -------------------------------------------------
        // Remove generic Markdown fence
        // -------------------------------------------------

        if cleaned.hasPrefix("```") {

            cleaned = String(
                cleaned.dropFirst(
                    "```".count
                )
            )
        }

        // -------------------------------------------------
        // Remove closing fence
        // -------------------------------------------------

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
    //
    // Used when:
    // - No API key exists
    // - Network fails
    // - OpenAI returns an error
    // - OpenAI returns invalid data
    //
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

        // -------------------------------------------------
        // Local question templates
        // -------------------------------------------------

        let questionTemplates: [
            (String, QuizQuestion.Difficulty)
        ] = [

            (
                "What is the main idea of \(memory.title)?",
                .medium
            ),

            (
                "Which statement best represents the information in \(memory.title)?",
                .medium
            ),

            (
                "What should you remember about \(memory.title)?",
                .easy
            ),

            (
                "Which answer best summarizes \(memory.title)?",
                .medium
            ),

            (
                "What important information does \(memory.title) contain?",
                .hard
            )
        ]

        // -------------------------------------------------
        // Number of questions
        // -------------------------------------------------

        let count = min(
            max(numberOfQuestions, 1),
            questionTemplates.count
        )

        // -------------------------------------------------
        // Create questions
        // -------------------------------------------------

        for index in 0..<count {

            let template = questionTemplates[index]

            let question = QuizQuestion(

                memoryID: memory.id,

                question: template.0,

                options: makeLocalOptions(
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

    private func makeLocalOptions(
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
