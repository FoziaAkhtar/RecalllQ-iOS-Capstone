
import Foundation
import Combine

// =====================================================
// QUIZ API SERVICE
// =====================================================
// Responsible for generating AI-powered quizzes.
//
// SECURITY:
// - API keys are stored in the iOS Keychain.
// - API keys are NEVER read from UserDefaults.
// - Local quiz generation remains available as a fallback.
//
// NOTE:
// This implementation is appropriate for a capstone/demo
// application where the user supplies their own API key.
// For a production application using a shared API key,
// requests should be routed through a secure backend.
// =====================================================

@MainActor
final class QuizAPIService: ObservableObject {

// =====================================================
// MARK: - Configuration
// =====================================================

private let apiKeyStorageKey = "OPENAI_API_KEY"

// =====================================================
// IMPORTANT
// =====================================================
// Keep the existing model used by the project.
// =====================================================

private let model = "gpt-5.6"

private let endpoint = URL(
    string: "https://api.openai.com/v1/responses"
)!

// =====================================================
// MARK: - Published State
// =====================================================

@Published private(set) var isGenerating = false
@Published private(set) var lastError: String?

// =====================================================
// MARK: - Generate Quiz
// =====================================================

func generateQuiz(
    from memories: [Memory],
    numberOfQuestions: Int = 5
) async -> [QuizQuestion] {

    lastError = nil
    isGenerating = true

    defer {
        isGenerating = false
    }

    // =====================================================
    // VALIDATE INPUT
    // =====================================================

    guard !memories.isEmpty else {
        lastError = "No memories are available to generate a quiz."
        return []
    }

    let questionCount = max(
        1,
        min(numberOfQuestions, 10)
    )

    // =====================================================
    // LOAD API KEY FROM KEYCHAIN
    // =====================================================

    let apiKey = KeychainService.shared
        .read(forKey: apiKeyStorageKey)?
        .trimmingCharacters(in: .whitespacesAndNewlines)

    // =====================================================
    // LOCAL FALLBACK
    // =====================================================
    // If the user has not configured an API key,
    // RecalllQ continues to work using local generation.
    // =====================================================

    guard let apiKey, !apiKey.isEmpty else {
        return createLocalQuiz(
            from: memories,
            numberOfQuestions: questionCount
        )
    }

    // =====================================================
    // BUILD MEMORY CONTEXT
    // =====================================================

    let memoryContext = memories
        .map { memory in
            """
            Memory ID: \(memory.id.uuidString)
            Title: \(memory.title)
            Summary: \(memory.summary)
            Tags: \(memory.tags.joined(separator: ", "))
            """
        }
        .joined(separator: "\n\n")

    // =====================================================
    // BUILD PROMPT
    // =====================================================

    let prompt = """
    Create an academic quiz from the following student memories.

    Requirements:
    - Create exactly \(questionCount) questions.
    - Questions must test understanding rather than simple memorization.
    - Use only information contained in the supplied memories.
    - Each question must have exactly four answer choices.
    - There must be exactly one correct answer.
    - Include a short explanation for the correct answer.
    - Return valid JSON matching the requested schema.

    STUDENT MEMORIES:

    \(memoryContext)
    """

    // =====================================================
    // RESPONSE JSON SCHEMA
    // =====================================================

    let schema: [String: Any] = [
        "type": "object",
        "properties": [
            "questions": [
                "type": "array",
                "items": [
                    "type": "object",
                    "properties": [
                        "question": [
                            "type": "string"
                        ],
                        "choices": [
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
                        ]
                    ],
                    "required": [
                        "question",
                        "choices",
                        "correctAnswer",
                        "explanation"
                    ],
                    "additionalProperties": false
                ]
            ]
        ],
        "required": [
            "questions"
        ],
        "additionalProperties": false
    ]

    // =====================================================
    // REQUEST BODY
    // =====================================================

    let requestBody: [String: Any] = [
        "model": model,
        "input": [
            [
                "role": "system",
                "content": [
                    [
                        "type": "input_text",
                        "text": """
                        You are RecalllQ, an academic memory assistant.

                        Generate accurate educational quiz questions
                        from the student's supplied memories.

                        Never invent facts that are not supported
                        by the supplied memories.
                        """
                    ]
                ]
            ],
            [
                "role": "user",
                "content": [
                    [
                        "type": "input_text",
                        "text": prompt
                    ]
                ]
            ]
        ],
        "text": [
            "format": [
                "type": "json_schema",
                "name": "recalliq_quiz",
                "strict": true,
                "schema": schema
            ]
        ]
    ]

    // =====================================================
    // SERIALIZE REQUEST
    // =====================================================

    guard JSONSerialization.isValidJSONObject(requestBody) else {
        lastError = "Unable to prepare the quiz request."

        return createLocalQuiz(
            from: memories,
            numberOfQuestions: questionCount
        )
    }

    do {

        let body = try JSONSerialization.data(
            withJSONObject: requestBody,
            options: []
        )

        // =====================================================
        // CREATE REQUEST
        // =====================================================

        var request = URLRequest(url: endpoint)

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

        // =====================================================
        // SEND REQUEST
        // =====================================================

        let (data, response) = try await URLSession.shared.data(
            for: request
        )

        // =====================================================
        // CHECK HTTP RESPONSE
        // =====================================================

        guard let httpResponse = response as? HTTPURLResponse else {

            lastError = "Invalid response from the AI service."

            return createLocalQuiz(
                from: memories,
                numberOfQuestions: questionCount
            )
        }

        guard (200...299).contains(httpResponse.statusCode) else {

            let serverMessage = String(
                data: data,
                encoding: .utf8
            )

            lastError =
                "AI quiz generation failed (\(httpResponse.statusCode))."

            if let serverMessage,
               !serverMessage.isEmpty {

                print(
                    """
                    =====================================================
                    AI QUIZ API ERROR
                    =====================================================
                    \(serverMessage)
                    =====================================================
                    """
                )
            }

            return createLocalQuiz(
                from: memories,
                numberOfQuestions: questionCount
            )
        }

        // =====================================================
        // EXTRACT RESPONSE TEXT
        // =====================================================

        guard let responseText = extractResponseText(
            from: data
        ) else {

            lastError =
                "The AI service returned an unexpected response."

            return createLocalQuiz(
                from: memories,
                numberOfQuestions: questionCount
            )
        }

        // =====================================================
        // DECODE QUIZ JSON
        // =====================================================

        guard let quizData = responseText.data(
            using: .utf8
        ) else {

            lastError = "Unable to decode the AI quiz response."

            return createLocalQuiz(
                from: memories,
                numberOfQuestions: questionCount
            )
        }

        let decoder = JSONDecoder()

        let decodedResponse = try decoder.decode(
            QuizAPIResponse.self,
            from: quizData
        )

        // =====================================================
        // VALIDATE GENERATED QUESTIONS
        // =====================================================

        let validatedQuestions = decodedResponse.questions
            .filter { question in
                !question.question.trimmingCharacters(
                    in: .whitespacesAndNewlines
                ).isEmpty
                &&
                question.choices.count == 4
                &&
                !question.correctAnswer.trimmingCharacters(
                    in: .whitespacesAndNewlines
                ).isEmpty
            }

        guard !validatedQuestions.isEmpty else {

            lastError =
                "The AI returned no valid quiz questions."

            return createLocalQuiz(
                from: memories,
                numberOfQuestions: questionCount
            )
        }

        // =====================================================
        // CONVERT API QUESTIONS TO APP QUESTIONS
        // =====================================================

        return validatedQuestions.map { question in

            QuizQuestion(
                question: question.question,
                options: question.choices,
                correctAnswer: question.correctAnswer,
                explanation: question.explanation
            )
        }

    } catch {

        // =====================================================
        // API ERROR
        // =====================================================

        lastError =
            "AI quiz generation failed. Using local quiz generation."

        print(
            """
            =====================================================
            QUIZ API ERROR
            =====================================================
            \(error.localizedDescription)
            =====================================================
            """
        )

        // =====================================================
        // LOCAL FALLBACK
        // =====================================================

        return createLocalQuiz(
            from: memories,
            numberOfQuestions: questionCount
        )
    }
}

// =====================================================
// MARK: - Extract Response Text
// =====================================================

private func extractResponseText(
    from data: Data
) -> String? {

    do {

        guard let json = try JSONSerialization.jsonObject(
            with: data,
            options: []
        ) as? [String: Any] else {
            return nil
        }

        // =====================================================
        // RESPONSES API OUTPUT
        // =====================================================

        if let output = json["output"] as? [[String: Any]] {

            for item in output {

                guard let content = item["content"]
                        as? [[String: Any]]
                else {
                    continue
                }

                for contentItem in content {

                    if let text = contentItem["text"] as? String {
                        return text
                    }
                }
            }
        }

        // =====================================================
        // FALLBACK FOR SIMPLE TEXT RESPONSE
        // =====================================================

        if let outputText = json["output_text"] as? String {
            return outputText
        }

    } catch {

        print(
            """
            =====================================================
            RESPONSE PARSING ERROR
            =====================================================
            \(error.localizedDescription)
            =====================================================
            """
        )
    }

    return nil
}

// =====================================================
// MARK: - Local Quiz Generation
// =====================================================
// This keeps RecalllQ functional even when:
// - No API key exists
// - Internet is unavailable
// - The API request fails
// - The API returns invalid data
// =====================================================

private func createLocalQuiz(
    from memories: [Memory],
    numberOfQuestions: Int
) -> [QuizQuestion] {

    guard !memories.isEmpty else {
        return []
    }

    let selectedMemories = Array(
        memories.shuffled().prefix(numberOfQuestions)
    )

    return selectedMemories.map { memory in

        let correctAnswer =
            memory.summary.isEmpty
            ? memory.title
            : memory.summary

        var options: [String] = []

        options.append(correctAnswer)

        let otherAnswers = memories
            .filter { $0.id != memory.id }
            .map {
                $0.summary.isEmpty
                ? $0.title
                : $0.summary
            }
            .filter {
                !$0.trimmingCharacters(
                    in: .whitespacesAndNewlines
                ).isEmpty
            }
            .shuffled()

        for answer in otherAnswers {

            if options.count >= 4 {
                break
            }

            if !options.contains(answer) {
                options.append(answer)
            }
        }

        while options.count < 4 {

            options.append(
                "Review the related study material."
            )
        }

        options.shuffle()

        return QuizQuestion(
            question:
                "Which statement best matches the memory titled \"\(memory.title)\"?",
            options: options,
            correctAnswer: correctAnswer,
            explanation:
                "This answer is based on the stored memory in RecalllQ."
        )
    }
}

}

// =====================================================
// MARK: - API Response Models
// =====================================================

private struct QuizAPIResponse: Codable {

let questions: [QuizAPIQuestion]

}

private struct QuizAPIQuestion: Codable {

let question: String
let choices: [String]
let correctAnswer: String
let explanation: String


}
