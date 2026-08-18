
import Foundation

// =====================================================
// SERVICE: AIService
// =====================================================
// PURPOSE:
//
// Connects RecalllQ iOS to the secure RecalllQ backend.
//
// FLOW:
//
// RecalllQ iOS
//      ↓
// AIService
//      ↓
// FastAPI Backend
//      ↓
// OpenAI
//      ↓
// Structured JSON
//      ↓
// RecalllQ Memory
//
// IMPORTANT:
//
// The OpenAI API key is NOT stored in this file.
// The key remains on the backend inside .env.
// =====================================================

final class AIService {

    // =====================================================
    // AI MEMORY RESPONSE
    // =====================================================

    struct AIMemoryResponse: Codable {

        let summary: String
        let tags: [String]
        let confidence: Double
        let importance: Int
    }

    // =====================================================
    // REQUEST MODEL
    // =====================================================

    private struct MemoryRequest: Codable {

        let title: String
        let content: String
    }

    // =====================================================
    // AI SERVICE ERROR
    // =====================================================

    enum AIServiceError: LocalizedError {

        case invalidURL
        case invalidResponse
        case requestFailed
        case invalidData
        case serviceUnavailable
        case serverError(Int)
        case emptyResponse

        var errorDescription: String? {

            switch self {

            case .invalidURL:
                return "The AI service URL is invalid."

            case .invalidResponse:
                return "The AI service returned an invalid response."

            case .requestFailed:
                return "The AI request could not be completed."

            case .invalidData:
                return "The AI service returned invalid data."

            case .serviceUnavailable:
                return "The AI service is currently unavailable."

            case .serverError(let statusCode):
                return "The AI server returned an error (\(statusCode))."

            case .emptyResponse:
                return "The AI service returned an empty response."
            }
        }
    }

    // =====================================================
    // BACKEND URL
    // =====================================================
    //
    // For the iOS Simulator running on the same Mac:
    //
    // 127.0.0.1 points to your Mac.
    //
    // FastAPI endpoint:
    //
    // http://127.0.0.1:8000/api/memory
    //
    // =====================================================

    private let apiURL =
        "http://127.0.0.1:8000/api/memory"

    // =====================================================
    // URL SESSION
    // =====================================================

    private let session: URLSession

    // =====================================================
    // INIT
    // =====================================================

    init(
        session: URLSession = .shared
    ) {

        self.session = session

        print("========================================")
        print("✅ AIService initialized")
        print("🤖 RecalllQ backend connection configured")
        print("🌐 http://127.0.0.1:8000/api/memory")
        print("========================================")
    }

    // =====================================================
    // GENERATE AI MEMORY
    // =====================================================
    //
    // Sends a student's note to the RecalllQ backend.
    //
    // Backend returns:
    //
    // {
    //     "summary": "...",
    //     "tags": ["swift", "ios"],
    //     "confidence": 0.92,
    //     "importance": 4
    // }
    //
    // =====================================================

    func generateMemory(
        title: String,
        content: String
    ) async throws -> AIMemoryResponse {

        // =================================================
        // CLEAN INPUT
        // =================================================

        let cleanedTitle =
            title.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        let cleanedContent =
            content.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        // =================================================
        // VALIDATE TITLE
        // =================================================

        guard !cleanedTitle.isEmpty else {

            print("❌ AIService: Empty title")

            throw AIServiceError.requestFailed
        }

        // =================================================
        // VALIDATE CONTENT
        // =================================================

        guard !cleanedContent.isEmpty else {

            print("❌ AIService: Empty content")

            throw AIServiceError.requestFailed
        }

        // =================================================
        // CREATE URL
        // =================================================

        guard let url = URL(string: apiURL) else {

            print("❌ AIService: Invalid backend URL")

            throw AIServiceError.invalidURL
        }

        // =================================================
        // CREATE REQUEST
        // =================================================

        var request =
            URLRequest(
                url: url
            )

        request.httpMethod = "POST"

        request.setValue(
            "application/json",
            forHTTPHeaderField: "Content-Type"
        )

        request.setValue(
            "application/json",
            forHTTPHeaderField: "Accept"
        )

        // =================================================
        // REQUEST BODY
        // =================================================

        let requestBody =
            MemoryRequest(
                title: cleanedTitle,
                content: cleanedContent
            )

        // =================================================
        // ENCODE REQUEST
        // =================================================

        do {

            request.httpBody =
                try JSONEncoder().encode(
                    requestBody
                )

        } catch {

            print(
                "❌ AIService encoding error:",
                error.localizedDescription
            )

            throw AIServiceError.requestFailed
        }

        // =================================================
        // DEBUG LOG
        // =================================================

        print("========================================")
        print("🤖 RECALLlQ AI MEMORY REQUEST")
        print("========================================")
        print("Title:")
        print(cleanedTitle)
        print("----------------------------------------")
        print("Backend:")
        print(apiURL)
        print("----------------------------------------")
        print("Sending study material...")
        print("========================================")

        // =================================================
        // SEND REQUEST
        // =================================================

        do {

            let (
                data,
                response
            ) = try await session.data(
                for: request
            )

            // =================================================
            // VALIDATE HTTP RESPONSE
            // =================================================

            guard let httpResponse =
                    response as? HTTPURLResponse
            else {

                print(
                    "❌ AIService: Invalid HTTP response"
                )

                throw AIServiceError.invalidResponse
            }

            print(
                "📡 Backend HTTP status:",
                httpResponse.statusCode
            )

            // =================================================
            // CHECK STATUS CODE
            // =================================================

            guard
                (200...299).contains(
                    httpResponse.statusCode
                )
            else {

                print(
                    "❌ AIService HTTP error:",
                    httpResponse.statusCode
                )

                // -----------------------------------------
                // Print backend response for debugging
                // -----------------------------------------

                if let serverMessage =
                    String(
                        data: data,
                        encoding: .utf8
                    ) {

                    print(
                        "Backend response:",
                        serverMessage
                    )
                }

                throw AIServiceError.serverError(
                    httpResponse.statusCode
                )
            }

            // =================================================
            // CHECK RESPONSE DATA
            // =================================================

            guard !data.isEmpty else {

                print(
                    "❌ AIService: Empty server response"
                )

                throw AIServiceError.emptyResponse
            }

            // =================================================
            // DEBUG RESPONSE
            // =================================================

            if let responseText =
                String(
                    data: data,
                    encoding: .utf8
                ) {

                print("----------------------------------------")
                print("📥 AI BACKEND RESPONSE")
                print(responseText)
                print("----------------------------------------")
            }

            // =================================================
            // DECODE AI RESPONSE
            // =================================================

            do {

                let result =
                    try JSONDecoder().decode(
                        AIMemoryResponse.self,
                        from: data
                    )

                // =================================================
                // VALIDATE CONFIDENCE
                // =================================================

                let validatedConfidence =
                    min(
                        max(
                            result.confidence,
                            0.0
                        ),
                        1.0
                    )

                // =================================================
                // VALIDATE IMPORTANCE
                // =================================================

                let validatedImportance =
                    min(
                        max(
                            result.importance,
                            1
                        ),
                        5
                    )

                // =================================================
                // CLEAN SUMMARY
                // =================================================

                let cleanedSummary =
                    result.summary.trimmingCharacters(
                        in: .whitespacesAndNewlines
                    )

                // =================================================
                // CLEAN TAGS
                // =================================================

                let cleanedTags =
                    result.tags
                        .map {
                            $0.trimmingCharacters(
                                in: .whitespacesAndNewlines
                            )
                        }
                        .filter {
                            !$0.isEmpty
                        }

                // =================================================
                // VALIDATE SUMMARY
                // =================================================

                guard !cleanedSummary.isEmpty else {

                    print(
                        "❌ AIService: Empty summary"
                    )

                    throw AIServiceError.invalidData
                }

                // =================================================
                // CREATE VALIDATED RESPONSE
                // =================================================

                let validatedResponse =
                    AIMemoryResponse(
                        summary:
                            cleanedSummary,

                        tags:
                            cleanedTags,

                        confidence:
                            validatedConfidence,

                        importance:
                            validatedImportance
                    )

                // =================================================
                // SUCCESS LOG
                // =================================================

                print("========================================")
                print("✅ AI MEMORY GENERATED")
                print("========================================")
                print(
                    "Summary:",
                    validatedResponse.summary
                )
                print(
                    "Tags:",
                    validatedResponse.tags
                )
                print(
                    "Confidence:",
                    validatedResponse.confidence
                )
                print(
                    "Importance:",
                    validatedResponse.importance
                )
                print("========================================")

                return validatedResponse

            } catch let error as AIServiceError {

                throw error

            } catch {

                print(
                    "❌ AIService decoding error:",
                    error.localizedDescription
                )

                throw AIServiceError.invalidData
            }

        } catch let error as AIServiceError {

            throw error

        } catch {

            print(
                "❌ AIService network error:",
                error.localizedDescription
            )

            print(
                "Make sure the RecalllQ FastAPI backend is running."
            )

            throw AIServiceError.serviceUnavailable
        }
    }
}
