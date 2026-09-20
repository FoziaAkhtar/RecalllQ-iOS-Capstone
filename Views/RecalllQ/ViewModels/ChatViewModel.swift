
import Foundation
import SwiftUI
import Combine

// =====================================================
// VIEW MODEL: ChatViewModel
// =====================================================
// PURPOSE:
// Controls the RecalllQ AI Study Chat.
//
// RESPONSIBILITIES:
//
// • Stores chat messages
// • Sends student questions
// • Sends conversation history to backend
// • Receives AI/local study assistant responses
// • Controls loading state
// • Handles connection errors
// • Provides clear-chat functionality
// • Creates conversation titles
//
// ARCHITECTURE:
//
// ChatView
//     ↓
// ChatViewModel
//     ↓
// RecalllQ AI Backend
//     ↓
// /api/chat
//     ↓
// Local RecalllQ Study Assistant
//
// IMPORTANT:
//
// This version intentionally connects directly to the
// RecalllQ backend chat endpoint.
//
// The backend is configured to use the local RecalllQ
// Study Assistant and does NOT require OpenAI API credits.
//
// =====================================================

@MainActor
final class ChatViewModel: ObservableObject {

    // =====================================================
    // MARK: - BACKEND CONFIGURATION
    // =====================================================

    // =====================================================
    // API BASE URL
    // =====================================================
    // PURPOSE:
    // Points the iOS application to the local RecalllQ
    // FastAPI backend running on the Mac.
    //
    // IMPORTANT:
    // 127.0.0.1 works when the app is running in the
    // iOS Simulator because the simulator can access
    // services running on the development Mac.
    //
    // Backend:
    //
    // http://127.0.0.1:8000
    //
    // =====================================================

    private let apiBaseURL = "http://127.0.0.1:8000"

    // =====================================================
    // CHAT ENDPOINT
    // =====================================================

    private var chatURL: URL? {
        URL(
            string: "\(apiBaseURL)/api/chat"
        )
    }

    // =====================================================
    // MARK: - PUBLISHED PROPERTIES
    // =====================================================

    // =====================================================
    // CHAT MESSAGES
    // =====================================================
    // Contains every message currently displayed in the
    // conversation.
    // =====================================================

    @Published var messages: [ChatMessage] = []

    // =====================================================
    // CURRENT INPUT
    // =====================================================
    // Contains the text currently being typed by the
    // student.
    // =====================================================

    @Published var inputText: String = ""

    // =====================================================
    // LOADING STATE
    // =====================================================
    // Used by ChatView to display an AI typing/loading
    // indicator while waiting for the backend response.
    // =====================================================

    @Published var isLoading: Bool = false

    // =====================================================
    // ERROR MESSAGE
    // =====================================================
    // Stores a user-friendly error message when something
    // goes wrong.
    // =====================================================

    @Published var errorMessage: String?

    // =====================================================
    // CONVERSATION TITLE
    // =====================================================
    // Provides a simple title for the current conversation.
    //
    // Later this can be expanded into saved conversations.
    // =====================================================

    @Published var conversationTitle: String = "New Study Chat"

    // =====================================================
    // INITIALIZER
    // =====================================================

    init() {

        // =================================================
        // START WITH A WELCOME MESSAGE
        // =================================================
        // This makes the chat immediately useful when the
        // student opens it for the first time.
        // =================================================

        messages = [

            ChatMessage(
                content: """
                Hi! I'm RecalllQ AI. 👋

                I'm your local RecalllQ Study Assistant.

                You can ask me to:

                • Explain a difficult concept
                • Simplify a topic
                • Summarize information
                • Create flashcards
                • Create practice quiz questions
                • Help you review your notes
                • Help you understand a study topic

                What would you like to study today?
                """,
                role: .assistant
            )

        ]
    }

    // =====================================================
    // MARK: - SEND MESSAGE
    // =====================================================

    // =====================================================
    // PURPOSE:
    // Sends the student's current question to the
    // RecalllQ backend.
    //
    // FLOW:
    //
    // Student enters question
    //       ↓
    // ChatViewModel
    //       ↓
    // POST /api/chat
    //       ↓
    // RecalllQ Local Study Assistant
    //       ↓
    // ChatResponse
    //       ↓
    // ChatViewModel
    //       ↓
    // ChatView
    //
    // =====================================================

    func sendMessage() {

        // =================================================
        // CLEAN INPUT
        // =================================================

        let trimmedMessage =
            inputText.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        // =================================================
        // VALIDATE INPUT
        // =================================================
        // Do not send empty messages.
        // =================================================

        guard !trimmedMessage.isEmpty else {
            return
        }

        // =================================================
        // PREVENT MULTIPLE REQUESTS
        // =================================================
        // Prevents the student from sending another
        // message while RecalllQ is processing the
        // previous one.
        // =================================================

        guard !isLoading else {
            return
        }

        // =================================================
        // CLEAR PREVIOUS ERROR
        // =================================================

        errorMessage = nil

        // =================================================
        // CREATE STUDENT MESSAGE
        // =================================================

        let studentMessage = ChatMessage(
            content: trimmedMessage,
            role: .student
        )

        // =================================================
        // ADD STUDENT MESSAGE TO CONVERSATION
        // =================================================

        messages.append(studentMessage)

        // =================================================
        // UPDATE CONVERSATION TITLE
        // =================================================

        updateConversationTitleIfNeeded(
            with: trimmedMessage
        )

        // =================================================
        // CLEAR TEXT FIELD
        // =================================================

        inputText = ""

        // =================================================
        // START LOADING STATE
        // =================================================

        isLoading = true

        // =================================================
        // SEND REQUEST TO BACKEND
        // =================================================

        Task {

            await sendChatRequest(
                message: trimmedMessage
            )

        }
    }

    // =====================================================
    // MARK: - SEND CHAT REQUEST
    // =====================================================

    // =====================================================
    // PURPOSE:
    // Performs the actual network request to the
    // RecalllQ FastAPI backend.
    // =====================================================

    private func sendChatRequest(
        message: String
    ) async {

        // =================================================
        // CREATE URL
        // =================================================

        guard let url = chatURL else {

            errorMessage =
                "Unable to connect to RecalllQ AI."

            isLoading = false

            return
        }

        // =================================================
        // CREATE REQUEST
        // =================================================

        var request = URLRequest(
            url: url
        )

        // =================================================
        // HTTP METHOD
        // =================================================

        request.httpMethod = "POST"

        // =================================================
        // REQUEST HEADERS
        // =================================================

        request.setValue(
            "application/json",
            forHTTPHeaderField: "Content-Type"
        )

        request.setValue(
            "application/json",
            forHTTPHeaderField: "Accept"
        )

        // =================================================
        // BUILD CONVERSATION HISTORY
        // =================================================
        // The backend accepts previous student and
        // assistant messages.
        //
        // We exclude the new student message because it
        // is already supplied separately as "message".
        // =================================================

        let previousMessages = messages.dropLast()

        let history: [
            ChatHistoryRequestMessage
        ] = previousMessages.map { message in

            ChatHistoryRequestMessage(
                role: message.role == .student
                    ? "student"
                    : "assistant",
                content: message.content
            )
        }

        // =================================================
        // CREATE REQUEST BODY
        // =================================================

        let requestBody = ChatRequestBody(
            message: message,
            history: history
        )

        // =================================================
        // ENCODE REQUEST BODY
        // =================================================

        do {

            request.httpBody = try JSONEncoder().encode(
                requestBody
            )

        } catch {

            errorMessage =
                "Unable to prepare your study question."

            isLoading = false

            return
        }

        // =================================================
        // PERFORM NETWORK REQUEST
        // =================================================

        do {

            let (
                data,
                response
            ) = try await URLSession.shared.data(
                for: request
            )

            // =================================================
            // VERIFY HTTP RESPONSE
            // =================================================

            guard let httpResponse =
                    response as? HTTPURLResponse
            else {

                throw ChatNetworkError.invalidResponse
            }

            // =================================================
            // VERIFY STATUS CODE
            // =================================================

            guard (
                200...299
            ).contains(
                httpResponse.statusCode
            ) else {

                throw ChatNetworkError.serverError(
                    httpResponse.statusCode
                )
            }

            // =================================================
            // DECODE BACKEND RESPONSE
            // =================================================

            let chatResponse =
                try JSONDecoder().decode(
                    ChatResponseBody.self,
                    from: data
                )

            // =================================================
            // CREATE ASSISTANT MESSAGE
            // =================================================

            let assistantMessage = ChatMessage(
                content: chatResponse.response,
                role: .assistant
            )

            // =================================================
            // ADD RESPONSE TO CONVERSATION
            // =================================================

            messages.append(
                assistantMessage
            )

            // =================================================
            // STOP LOADING
            // =================================================

            isLoading = false

        } catch {

            // =================================================
            // HANDLE NETWORK ERROR
            // =================================================

            handleChatError(
                error
            )
        }
    }

    // =====================================================
    // MARK: - HANDLE CHAT ERROR
    // =====================================================

    private func handleChatError(
        _ error: Error
    ) {

        // =================================================
        // STOP LOADING
        // =================================================

        isLoading = false

        // =================================================
        // PRINT DEBUG INFORMATION
        // =================================================

        print(
            "========================================"
        )

        print(
            "❌ RECALLlQ CHAT ERROR"
        )

        print(
            "========================================"
        )

        print(
            error.localizedDescription
        )

        print(
            "========================================"
        )

        // =================================================
        // USER-FRIENDLY ERROR
        // =================================================

        if let chatError =
            error as? ChatNetworkError {

            switch chatError {

            case .invalidResponse:

                errorMessage =
                    "RecalllQ received an invalid response from the study assistant."

            case .serverError(let statusCode):

                errorMessage =
                    "RecalllQ AI server returned error \(statusCode)."

            }

        } else {

            errorMessage =
                """
                Unable to connect to RecalllQ AI.

                Make sure the RecalllQ backend is running.
                """
        }
    }

    // =====================================================
    // MARK: - CLEAR CHAT
    // =====================================================

    // =====================================================
    // PURPOSE:
    // Removes the current conversation and starts a new
    // study chat.
    // =====================================================

    func clearChat() {

        // =================================================
        // REMOVE EXISTING MESSAGES
        // =================================================

        messages.removeAll()

        // =================================================
        // RESET TITLE
        // =================================================

        conversationTitle = "New Study Chat"

        // =================================================
        // RESET ERROR
        // =================================================

        errorMessage = nil

        // =================================================
        // RESET INPUT
        // =================================================

        inputText = ""

        // =================================================
        // ADD WELCOME MESSAGE
        // =================================================

        messages.append(

            ChatMessage(
                content: """
                Hi! I'm RecalllQ AI. 👋

                I'm your local RecalllQ Study Assistant.

                Ask me anything about your studies.

                You can ask me to:

                • Explain a concept
                • Simplify a topic
                • Summarize information
                • Create flashcards
                • Create practice quiz questions
                • Help you review your notes

                What would you like to study today?
                """,
                role: .assistant
            )

        )
    }

    // =====================================================
    // MARK: - CONVERSATION TITLE
    // =====================================================

    // =====================================================
    // PURPOSE:
    // Creates a simple title from the student's first
    // question.
    // =====================================================

    private func updateConversationTitleIfNeeded(
        with message: String
    ) {

        // =================================================
        // ONLY CREATE TITLE FOR A NEW CHAT
        // =================================================

        guard conversationTitle == "New Study Chat"
        else {
            return
        }

        // =================================================
        // LIMIT TITLE LENGTH
        // =================================================

        let maximumLength = 40

        if message.count <= maximumLength {

            conversationTitle = message

        } else {

            let index = message.index(
                message.startIndex,
                offsetBy: maximumLength
            )

            conversationTitle =
                String(
                    message[..<index]
                ) + "..."
        }
    }
}


// =====================================================
// MARK: - CHAT REQUEST BODY
// =====================================================
// PURPOSE:
// Represents the JSON body sent to:
//
// POST /api/chat
//
// =====================================================

private struct ChatRequestBody: Encodable {

    // =================================================
    // STUDENT MESSAGE
    // =================================================

    let message: String

    // =================================================
    // CONVERSATION HISTORY
    // =================================================

    let history: [
        ChatHistoryRequestMessage
    ]
}


// =====================================================
// MARK: - CHAT HISTORY REQUEST MESSAGE
// =====================================================

private struct ChatHistoryRequestMessage: Encodable {

    // =================================================
    // ROLE
    // =================================================
    // Possible values:
    //
    // student
    // assistant
    //
    // =================================================

    let role: String

    // =================================================
    // MESSAGE CONTENT
    // =================================================

    let content: String
}


// =====================================================
// MARK: - CHAT RESPONSE BODY
// =====================================================
// PURPOSE:
// Represents the response returned from:
//
// POST /api/chat
//
// Backend:
//
// {
//     "response": "Study response..."
// }
//
// =====================================================

private struct ChatResponseBody: Decodable {

    // =================================================
    // AI RESPONSE
    // =================================================

    let response: String
}


// =====================================================
// MARK: - CHAT NETWORK ERROR
// =====================================================

private enum ChatNetworkError: Error {

    // =================================================
    // INVALID RESPONSE
    // =================================================

    case invalidResponse

    // =================================================
    // SERVER ERROR
    // =================================================

    case serverError(Int)
}
