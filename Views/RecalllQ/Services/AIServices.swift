
import Foundation

// =====================================================
// SERVICE: AIService
// =====================================================
// PURPOSE:
// Handles communication with the external AI service.
//
// This service is separated from MemoryEngine so that
// API communication stays independent from the local
// memory-processing logic.
//
// IMPORTANT:
// - Never store a real API key inside the iOS app.
// - Never commit API keys to GitHub.
// - The local MemoryEngine remains available as a fallback.
// =====================================================

final class AIService {

    // =====================================================
    // AI MEMORY RESPONSE
    // =====================================================
    // Represents the structured information we want
    // from the AI service.
    // =====================================================

    struct AIMemoryResponse: Codable {

        let summary: String
        let tags: [String]
        let confidence: Double
        let importance: Int
    }

    // =====================================================
    // AI SERVICE ERROR
    // =====================================================
    // Defines possible errors from the AI service.
    // =====================================================

    enum AIServiceError: Error {

        case invalidURL
        case invalidResponse
        case requestFailed
        case invalidData
        case serviceUnavailable
    }

    // =====================================================
    // API URL
    // =====================================================
    // IMPORTANT:
    // This should eventually point to YOUR secure backend.
    //
    // Do not put an OpenAI secret key directly into the
    // mobile application.
    // =====================================================

    private let apiURL = "https://example.com/api/memory"

    // =====================================================
    // INIT
    // =====================================================

    init() {
        print("✅ AIService initialized")
    }

    // =====================================================
    // GENERATE AI MEMORY
    // =====================================================
    // Sends a note to the AI service and expects a
    // structured memory response.
    //
    // This function is asynchronous because network
    // communication takes time.
    // =====================================================

    func generateMemory(
        title: String,
        content: String
    ) async throws -> AIMemoryResponse {

        // =================================================
        // CHECK URL
        // =================================================

        guard let url = URL(string: apiURL) else {

            print("❌ AIService: Invalid API URL")

            throw AIServiceError.invalidURL
        }

        // =================================================
        // CREATE REQUEST
        // =================================================

        var request = URLRequest(url: url)

        request.httpMethod = "POST"

        request.setValue(
            "application/json",
            forHTTPHeaderField: "Content-Type"
        )

        // =================================================
        // REQUEST DATA
        // =================================================
        // The backend will receive the note title and
        // content and return structured AI information.
        // =================================================

        let requestBody: [String: String] = [
            "title": title,
            "content": content
        ]

        do {

            request.httpBody = try JSONEncoder().encode(
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
        // SEND REQUEST
        // =================================================

        do {

            let (data, response) = try await URLSession.shared.data(
                for: request
            )

            // =================================================
            // CHECK SERVER RESPONSE
            // =================================================

            guard let httpResponse = response as? HTTPURLResponse else {

                print("❌ AIService: Invalid server response")

                throw AIServiceError.invalidResponse
            }

            // =================================================
            // CHECK STATUS CODE
            // =================================================

            guard (200...299).contains(httpResponse.statusCode) else {

                print(
                    "❌ AIService HTTP error:",
                    httpResponse.statusCode
                )

                throw AIServiceError.requestFailed
            }

            // =================================================
            // DECODE AI RESPONSE
            // =================================================

            do {

                let result = try JSONDecoder().decode(
                    AIMemoryResponse.self,
                    from: data
                )

                print("✅ AI memory generated successfully")

                return result

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

            throw AIServiceError.serviceUnavailable
        }
    }
}
