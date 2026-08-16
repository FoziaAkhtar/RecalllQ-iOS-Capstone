
import SwiftUI

// =====================================================
// VIEW: SmartSuggestionsView
// =====================================================
// PURPOSE:
// Displays personalized RecalllQ study suggestions.
//
// USER CAN:
// - See why a memory is recommended
// - Create a flashcard from the suggestion
// - Open an existing flashcard
// - Start studying the suggested flashcard
// =====================================================

struct SmartSuggestionsView: View {

    // =====================================================
    // APP STATE
    // =====================================================

    @EnvironmentObject var appState: AppState

    // =====================================================
    // BODY
    // =====================================================

    var body: some View {

        VStack(
            alignment: .leading,
            spacing: 14
        ) {

            // =================================================
            // HEADER
            // =================================================

            HStack {

                VStack(
                    alignment: .leading,
                    spacing: 4
                ) {

                    Text("Smart Suggestions")
                        .font(.title2)
                        .bold()
                        .foregroundColor(
                            RecalllQTheme.primaryText
                        )

                    Text(
                        "RecalllQ recommends what you should study next."
                    )
                    .font(.caption)
                    .foregroundColor(
                        RecalllQTheme.secondaryText
                    )
                }

                Spacer()

                Image(
                    systemName: "sparkles"
                )
                .font(.title2)
                .foregroundColor(
                    RecalllQTheme.smartPurple
                )
            }

            // =================================================
            // SUGGESTIONS
            // =================================================

            if appState.studyRecommendations.isEmpty {

                emptySuggestions

            } else {

                ForEach(
                    appState.studyRecommendations
                ) { recommendation in

                    suggestionCard(
                        recommendation
                    )
                }
            }
        }
    }

    // =====================================================
    // SUGGESTION CARD
    // =====================================================

    @ViewBuilder
    private func suggestionCard(
        _ recommendation:
        StudyRecommendationService.Recommendation
    ) -> some View {

        let memory =
            recommendation.memory

        let hasFlashcard =
            appState.flashcardViewModel.hasFlashcard(
                for: memory.id
            )

        Button {

            handleSuggestionTap(
                memory: memory
            )

        } label: {

            HStack(
                alignment: .top,
                spacing: 12
            ) {

                // -----------------------------------------
                // ICON
                // -----------------------------------------

                ZStack {

                    Circle()
                        .fill(
                            RecalllQTheme.smartPurple
                                .opacity(0.12)
                        )
                        .frame(
                            width: 46,
                            height: 46
                        )

                    Image(
                        systemName:
                            hasFlashcard
                            ? "rectangle.on.rectangle.fill"
                            : "sparkles"
                    )
                    .foregroundColor(
                        RecalllQTheme.smartPurple
                    )
                }

                // -----------------------------------------
                // CONTENT
                // -----------------------------------------

                VStack(
                    alignment: .leading,
                    spacing: 6
                ) {

                    Text(
                        memory.title
                    )
                    .font(.headline)
                    .foregroundColor(
                        RecalllQTheme.primaryText
                    )
                    .multilineTextAlignment(
                        .leading
                    )

                    Text(
                        recommendation.reason
                    )
                    .font(.caption)
                    .foregroundColor(
                        RecalllQTheme.secondaryText
                    )
                    .multilineTextAlignment(
                        .leading
                    )
                    .lineLimit(3)

                    // -------------------------------------
                    // ACTION LABEL
                    // -------------------------------------

                    HStack(
                        spacing: 5
                    ) {

                        Image(
                            systemName:
                                hasFlashcard
                                ? "play.fill"
                                : "plus.circle.fill"
                        )

                        Text(
                            hasFlashcard
                            ? "Study Flashcard"
                            : "Create Flashcard"
                        )
                        .font(.caption)
                        .bold()
                    }
                    .foregroundColor(
                        RecalllQTheme.primary
                    )
                }

                Spacer()

                Image(
                    systemName:
                        "chevron.right"
                )
                .foregroundColor(
                    RecalllQTheme.secondaryText
                )
                .padding(.top, 4)
            }
            .padding()
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )
            .background(
                RoundedRectangle(
                    cornerRadius:
                        RecalllQTheme.mediumRadius
                )
                .fill(
                    RecalllQTheme.cardBackground
                )
            )
            .overlay(
                RoundedRectangle(
                    cornerRadius:
                        RecalllQTheme.mediumRadius
                )
                .stroke(
                    RecalllQTheme.smartPurple
                        .opacity(0.15),
                    lineWidth: 1
                )
            )
            .shadow(
                color:
                    Color.black.opacity(
                        RecalllQTheme.shadowOpacity
                    ),
                radius:
                    RecalllQTheme.shadowRadius,
                x: 0,
                y:
                    RecalllQTheme.shadowY
            )
        }
        .buttonStyle(
            .plain
        )
    }

    // =====================================================
    // HANDLE TAP
    // =====================================================

    private func handleSuggestionTap(
        memory: Memory
    ) {

        let flashcardVM =
            appState.flashcardViewModel

        // -------------------------------------------------
        // Existing flashcard
        // -------------------------------------------------

        if let flashcard =
            flashcardVM.flashcardForMemory(
                memory.id
            ) {

            flashcardVM.searchText = ""

            flashcardVM.selectFlashcard(
                id: flashcard.id
            )

            print(
                "🎯 Smart Suggestion selected flashcard."
            )

            return
        }

        // -------------------------------------------------
        // No flashcard yet
        // -------------------------------------------------

        appState.createFlashcardFromMemory(
            memory
        )

        // -------------------------------------------------
        // Find newly created flashcard
        // -------------------------------------------------

        if let newFlashcard =
            flashcardVM.flashcardForMemory(
                memory.id
            ) {

            flashcardVM.selectFlashcard(
                id: newFlashcard.id
            )

            print(
                "✨ Smart Suggestion created flashcard."
            )
        }
    }

    // =====================================================
    // EMPTY STATE
    // =====================================================

    private var emptySuggestions: some View {

        VStack(
            spacing: 10
        ) {

            Image(
                systemName:
                    "sparkles"
            )
            .font(
                .system(size: 30)
            )
            .foregroundColor(
                RecalllQTheme.smartPurple
            )

            Text(
                "No smart suggestions yet"
            )
            .font(.headline)
            .foregroundColor(
                RecalllQTheme.primaryText
            )

            Text(
                "Create some Memories and RecalllQ will recommend what to study."
            )
            .font(.caption)
            .foregroundColor(
                RecalllQTheme.secondaryText
            )
            .multilineTextAlignment(
                .center
            )
        }
        .frame(
            maxWidth: .infinity
        )
        .padding(24)
        .background(
            RoundedRectangle(
                cornerRadius:
                    RecalllQTheme.largeRadius
            )
            .fill(
                RecalllQTheme.cardBackground
            )
        )
    }
}
