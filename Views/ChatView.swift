
import SwiftUI

// =====================================================
// VIEW: ChatView
// =====================================================
// PURPOSE:
// Main AI Study Chat interface for RecalllQ.
//
// FEATURES:
//
// • Student message bubbles
// • RecalllQ AI message bubbles
// • Chat input field
// • Send button
// • AI typing indicator
// • Automatic scrolling
// • Clear conversation button
// • Modern RecalllQ visual design
//
// ARCHITECTURE:
//
// ChatView
//     ↓
// ChatViewModel
//     ↓
// ChatMessage
//
// The real AIService connection will be added after
// the chat interface has been tested successfully.
// =====================================================

struct ChatView: View {

    // =====================================================
    // MARK: - VIEW MODEL
    // =====================================================

    @StateObject private var viewModel = ChatViewModel()

    // =====================================================
    // MARK: - BODY
    // =====================================================

    var body: some View {

        NavigationStack {

            VStack(spacing: 0) {

                // =================================================
                // CHAT MESSAGE AREA
                // =================================================

                ScrollViewReader { proxy in

                    ScrollView {

                        LazyVStack(
                            alignment: .leading,
                            spacing: 16
                        ) {

                            // =============================================
                            // TOP SPACING
                            // =============================================

                            Color.clear
                                .frame(height: 8)

                            // =============================================
                            // CHAT MESSAGES
                            // =============================================

                            ForEach(viewModel.messages) { message in

                                ChatMessageBubble(
                                    message: message
                                )
                                .id(message.id)
                            }

                            // =============================================
                            // AI TYPING INDICATOR
                            // =============================================

                            if viewModel.isLoading {

                                ChatTypingIndicator()
                                    .id("typingIndicator")
                            }

                            // =============================================
                            // BOTTOM SPACING
                            // =============================================

                            Color.clear
                                .frame(height: 8)
                        }
                        .padding(.horizontal, 16)
                    }

                    // =====================================================
                    // AUTOMATIC SCROLLING
                    // =====================================================

                    .onChange(
                        of: viewModel.messages.count
                    ) {

                        guard let lastMessage =
                                viewModel.messages.last
                        else {
                            return
                        }

                        withAnimation(.easeOut(duration: 0.25)) {

                            proxy.scrollTo(
                                lastMessage.id,
                                anchor: .bottom
                            )
                        }
                    }

                    .onChange(
                        of: viewModel.isLoading
                    ) {

                        if viewModel.isLoading {

                            withAnimation(.easeOut(duration: 0.25)) {

                                proxy.scrollTo(
                                    "typingIndicator",
                                    anchor: .bottom
                                )
                            }
                        }
                    }
                }

                // =================================================
                // ERROR MESSAGE
                // =================================================

                if let errorMessage =
                    viewModel.errorMessage {

                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 6)
                }

                // =================================================
                // MESSAGE INPUT
                // =================================================

                ChatInputBar(
                    text: $viewModel.inputText,
                    isLoading: viewModel.isLoading,
                    onSend: {
                        viewModel.sendMessage()
                    }
                )
            }

            // =====================================================
            // NAVIGATION TITLE
            // =====================================================

            .navigationTitle("AI Study Chat")
            .navigationBarTitleDisplayMode(.inline)

            // =====================================================
            // NAVIGATION BAR BUTTONS
            // =====================================================

            .toolbar {

                ToolbarItem(
                    placement: .topBarTrailing
                ) {

                    Menu {

                        // =============================================
                        // CLEAR CHAT
                        // =============================================

                        Button(
                            role: .destructive
                        ) {

                            viewModel.clearChat()

                        } label: {

                            Label(
                                "Clear Chat",
                                systemImage: "trash"
                            )
                        }

                    } label: {

                        Image(systemName: "ellipsis.circle")
                            .font(.title3)
                    }
                }
            }
        }
    }
}

// =====================================================
// COMPONENT: ChatMessageBubble
// =====================================================
// PURPOSE:
// Displays either a student message or an AI message.
//
// Student messages appear on the trailing/right side.
//
// AI messages appear on the leading/left side.
// =====================================================

private struct ChatMessageBubble: View {

    // =====================================================
    // MESSAGE
    // =====================================================

    let message: ChatMessage

    // =====================================================
    // BODY
    // =====================================================

    var body: some View {

        HStack(
            alignment: .bottom,
            spacing: 8
        ) {

            // =================================================
            // AI MESSAGE
            // =================================================

            if message.role == .assistant {

                // =============================================
                // AI ICON
                // =============================================

                ZStack {

                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.blue,
                                    Color.purple
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 15))
                        .foregroundStyle(.white)
                }
                .frame(
                    width: 34,
                    height: 34
                )

                // =============================================
                // AI BUBBLE
                // =============================================

                Text(message.content)
                    .font(.body)
                    .foregroundStyle(.primary)
                    .padding(.horizontal, 15)
                    .padding(.vertical, 12)
                    .background(
                        Color(.secondarySystemBackground)
                    )
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: 18,
                            style: .continuous
                        )
                    )

                Spacer(
                    minLength: 45
                )

            } else {

                // =================================================
                // STUDENT MESSAGE
                // =================================================

                Spacer(
                    minLength: 45
                )

                Text(message.content)
                    .font(.body)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 15)
                    .padding(.vertical, 12)
                    .background(
                        LinearGradient(
                            colors: [
                                Color.blue,
                                Color.purple
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: 18,
                            style: .continuous
                        )
                    )

                // =============================================
                // STUDENT ICON
                // =============================================

                ZStack {

                    Circle()
                        .fill(
                            Color(.systemGray5)
                        )

                    Image(systemName: "person.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
                }
                .frame(
                    width: 34,
                    height: 34
                )
            }
        }
    }
}

// =====================================================
// COMPONENT: ChatTypingIndicator
// =====================================================
// PURPOSE:
// Shows a small animated-style indicator while RecalllQ
// is preparing an AI response.
// =====================================================

private struct ChatTypingIndicator: View {

    // =====================================================
    // BODY
    // =====================================================

    var body: some View {

        HStack(
            alignment: .bottom,
            spacing: 8
        ) {

            // =================================================
            // AI ICON
            // =================================================

            ZStack {

                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.blue,
                                Color.purple
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                Image(systemName: "brain.head.profile")
                    .font(.system(size: 15))
                    .foregroundStyle(.white)
            }
            .frame(
                width: 34,
                height: 34
            )

            // =================================================
            // TYPING BUBBLE
            // =================================================

            HStack(spacing: 5) {

                Circle()
                    .frame(
                        width: 7,
                        height: 7
                    )

                Circle()
                    .frame(
                        width: 7,
                        height: 7
                    )

                Circle()
                    .frame(
                        width: 7,
                        height: 7
                    )
            }
            .foregroundStyle(.secondary)
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                Color(.secondarySystemBackground)
            )
            .clipShape(
                RoundedRectangle(
                    cornerRadius: 18,
                    style: .continuous
                )
            )

            Spacer(
                minLength: 45
            )
        }
    }
}

// =====================================================
// COMPONENT: ChatInputBar
// =====================================================
// PURPOSE:
// Provides the student with the text field and send
// button used to communicate with RecalllQ AI.
// =====================================================

private struct ChatInputBar: View {

    // =====================================================
    // BINDINGS
    // =====================================================

    @Binding var text: String

    // =====================================================
    // LOADING STATE
    // =====================================================

    let isLoading: Bool

    // =====================================================
    // SEND ACTION
    // =====================================================

    let onSend: () -> Void

    // =====================================================
    // BODY
    // =====================================================

    var body: some View {

        HStack(
            alignment: .bottom,
            spacing: 10
        ) {

            // =================================================
            // TEXT FIELD
            // =================================================

            TextField(
                "Ask RecalllQ anything...",
                text: $text,
                axis: .vertical
            )
            .textFieldStyle(.plain)
            .lineLimit(
                1...5
            )
            .padding(.horizontal, 14)
            .padding(.vertical, 11)
            .background(
                Color(.secondarySystemBackground)
            )
            .clipShape(
                RoundedRectangle(
                    cornerRadius: 20,
                    style: .continuous
                )
            )
            .disabled(isLoading)

            // =================================================
            // SEND BUTTON
            // =================================================

            Button {

                onSend()

            } label: {

                Image(
                    systemName:
                        "arrow.up.circle.fill"
                )
                .font(
                    .system(size: 34)
                )
                .foregroundStyle(
                    canSend
                    ? Color.blue
                    : Color.gray
                )
            }
            .disabled(
                !canSend
            )
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            .bar
        )
    }

    // =====================================================
    // COMPUTED PROPERTY: CAN SEND
    // =====================================================

    private var canSend: Bool {

        !text
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )
            .isEmpty
        && !isLoading
    }
}

// =====================================================
// PREVIEW
// =====================================================

#Preview {

    ChatView()
}

