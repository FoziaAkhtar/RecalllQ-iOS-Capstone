
import SwiftUI

// =====================================================
// VIEW: FlashcardsView
// =====================================================
// PURPOSE:
// Main flashcard learning screen for RecalllQ.
//
// FEATURES:
// - Flashcard statistics
// - Search flashcards
// - Generate flashcards from Memories
// - Reset all flashcards
// - Study mode
// - Show / hide answer
// - Easy / Medium / Hard review
// - Previous / Next navigation
// - Progress tracking
// - Delete flashcards
// - Study session integration
//
// STUDY SESSION INTEGRATION:
// - FlashcardViewModel records completed reviews
// - Each Easy / Medium / Hard review counts once
// - Prevents duplicate Study Session counting
// =====================================================

struct FlashcardsView: View {

    // =====================================================
    // GLOBAL APP STATE
    // =====================================================

    @EnvironmentObject var appState: AppState

    // =====================================================
    // VIEW MODEL
    // =====================================================

    private var vm: FlashcardViewModel {
        appState.flashcardViewModel
    }

    // =====================================================
    // RESET CONFIRMATION
    // =====================================================

    @State private var showingResetConfirmation = false

    // =====================================================
    // BODY
    // =====================================================

    var body: some View {

        ScrollView(
            showsIndicators: false
        ) {

            VStack(
                alignment: .leading,
                spacing: 18
            ) {

                // =================================================
                // HEADER
                // =================================================

                HStack {

                    VStack(
                        alignment: .leading,
                        spacing: 4
                    ) {

                        Text("Flashcards")
                            .font(.largeTitle)
                            .bold()
                            .foregroundColor(
                                RecalllQTheme.primaryText
                            )

                        Text(
                            "Practice what you have learned."
                        )
                        .font(.subheadline)
                        .foregroundColor(
                            RecalllQTheme.secondaryText
                        )
                    }

                    Spacer()

                    ZStack {

                        Circle()
                            .fill(
                                RecalllQTheme.primary
                                    .opacity(0.12)
                            )
                            .frame(
                                width: 52,
                                height: 52
                            )

                        Image(
                            systemName:
                                "rectangle.on.rectangle"
                        )
                        .font(.title2)
                        .foregroundColor(
                            RecalllQTheme.primary
                        )
                    }
                }

                // =================================================
                // STATISTICS
                // =================================================

                HStack(spacing: 10) {

                    statisticCard(
                        value:
                            "\(vm.totalFlashcards)",
                        title:
                            "Cards",
                        icon:
                            "rectangle.stack.fill",
                        color:
                            RecalllQTheme.primary
                    )

                    statisticCard(
                        value:
                            "\(vm.masteredFlashcards)",
                        title:
                            "Mastered",
                        icon:
                            "checkmark.circle.fill",
                        color:
                            RecalllQTheme.success
                    )

                    statisticCard(
                        value:
                            accuracyText,
                        title:
                            "Accuracy",
                        icon:
                            "chart.bar.fill",
                        color:
                            RecalllQTheme.secondary
                    )
                }

                // =================================================
                // GENERATE FLASHCARDS
                // =================================================

                Button {

                    appState.createFlashcardsFromAllMemories()

                } label: {

                    HStack(spacing: 12) {

                        Image(
                            systemName:
                                "sparkles"
                        )
                        .font(.title3)

                        VStack(
                            alignment: .leading,
                            spacing: 3
                        ) {

                            Text(
                                "Generate Flashcards"
                            )
                            .font(.headline)

                            Text(
                                "Create cards from your Memories"
                            )
                            .font(.caption)
                            .opacity(0.9)
                        }

                        Spacer()

                        Image(
                            systemName:
                                "arrow.right"
                        )
                    }
                    .padding()
                    .frame(
                        maxWidth: .infinity
                    )
                    .foregroundColor(.white)
                    .background(
                        LinearGradient(
                            colors: [
                                RecalllQTheme.primary,
                                RecalllQTheme.primary.opacity(0.75)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius:
                                RecalllQTheme.mediumRadius
                        )
                    )
                    .shadow(
                        color:
                            RecalllQTheme.primary.opacity(0.18),
                        radius: 8,
                        x: 0,
                        y: 4
                    )
                }

                // =================================================
                // RESET ALL FLASHCARDS
                // =================================================

                if !vm.flashcards.isEmpty {

                    Button {

                        showingResetConfirmation = true

                    } label: {

                        HStack {

                            Image(
                                systemName:
                                    "trash.fill"
                            )

                            Text(
                                "Reset All Flashcards"
                            )
                            .font(.headline)

                            Spacer()
                        }
                        .padding()
                        .frame(
                            maxWidth: .infinity
                        )
                        .foregroundColor(
                            RecalllQTheme.error
                        )
                        .background(
                            RoundedRectangle(
                                cornerRadius:
                                    RecalllQTheme.mediumRadius
                            )
                            .fill(
                                RecalllQTheme.redBackground
                            )
                        )
                    }
                    .alert(
                        "Reset All Flashcards?",
                        isPresented:
                            $showingResetConfirmation
                    ) {

                        Button(
                            "Cancel",
                            role: .cancel
                        ) { }

                        Button(
                            "Reset",
                            role: .destructive
                        ) {

                            vm.resetAllFlashcards()

                        }

                    } message: {

                        Text(
                            "This will permanently delete all your saved flashcards."
                        )
                    }
                }

                // =================================================
                // SEARCH
                // =================================================

                HStack(spacing: 10) {

                    Image(
                        systemName:
                            "magnifyingglass"
                    )
                    .foregroundColor(
                        RecalllQTheme.primary
                    )

                    TextField(
                        "Search flashcards...",
                        text: Binding(
                            get: {
                                vm.searchText
                            },
                            set: {
                                vm.searchText = $0
                            }
                        )
                    )

                    if !vm.searchText.isEmpty {

                        Button {

                            vm.searchText = ""

                        } label: {

                            Image(
                                systemName:
                                    "xmark.circle.fill"
                            )
                            .foregroundColor(
                                RecalllQTheme.secondaryText
                            )
                        }
                    }
                }
                .padding(12)
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
                        RecalllQTheme.primary.opacity(0.12),
                        lineWidth: 1
                    )
                )

                // =================================================
                // STUDY MODE
                // =================================================

                if let card = vm.currentFlashcard {

                    studyCard(
                        card
                    )

                } else {

                    emptyState
                }

                // =================================================
                // FLASHCARD LIST
                // =================================================

                if !vm.filteredFlashcards.isEmpty {

                    HStack {

                        Text(
                            "Your Flashcards"
                        )
                        .font(.title3)
                        .bold()
                        .foregroundColor(
                            RecalllQTheme.primaryText
                        )

                        Spacer()

                        Image(
                            systemName:
                                "sparkles"
                        )
                        .foregroundColor(
                            RecalllQTheme.smartPurple
                        )
                    }

                    ForEach(
                        vm.filteredFlashcards
                    ) { card in

                        flashcardRow(
                            card
                        )
                    }
                }
            }
            .padding()
        }

        // =====================================================
        // PAGE BACKGROUND
        // =====================================================

        .background(
            RecalllQTheme.background
                .ignoresSafeArea()
        )

        // =====================================================
        // NAVIGATION
        // =====================================================

        .navigationTitle(
            "Flashcards"
        )
        .navigationBarTitleDisplayMode(
            .inline
        )
    }

    // =====================================================
    // ACCURACY TEXT
    // =====================================================

    private var accuracyText: String {

        let percentage =
            vm.overallAccuracy * 100

        return String(
            format: "%.0f%%",
            percentage
        )
    }

    // =====================================================
    // STATISTICS CARD
    // =====================================================

    @ViewBuilder
    private func statisticCard(
        value: String,
        title: String,
        icon: String,
        color: Color
    ) -> some View {

        VStack(
            spacing: 7
        ) {

            Image(
                systemName:
                    icon
            )
            .foregroundColor(
                color
            )

            Text(
                value
            )
            .font(.headline)
            .bold()
            .foregroundColor(
                RecalllQTheme.primaryText
            )

            Text(
                title
            )
            .font(.caption2)
            .foregroundColor(
                RecalllQTheme.secondaryText
            )
        }
        .frame(
            maxWidth: .infinity
        )
        .padding(.vertical, 12)
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
                color.opacity(0.10),
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

    // =====================================================
    // STUDY CARD
    // =====================================================

    @ViewBuilder
    private func studyCard(
        _ card: Flashcard
    ) -> some View {

        VStack(
            alignment: .leading,
            spacing: 16
        ) {

            // =================================================
            // STUDY HEADER
            // =================================================

            HStack {

                Label(
                    "Study Mode",
                    systemImage:
                        "brain.head.profile"
                )
                .font(.headline)
                .foregroundColor(
                    RecalllQTheme.primary
                )

                Spacer()

                Text(
                    "\(vm.currentIndex + 1) / \(vm.filteredFlashcards.count)"
                )
                .font(.caption)
                .foregroundColor(
                    RecalllQTheme.secondaryText
                )
            }

            Divider()

            // =================================================
            // QUESTION
            // =================================================

            Text(
                "Question"
            )
            .font(.caption)
            .foregroundColor(
                RecalllQTheme.secondaryText
            )

            Text(
                card.question
            )
            .font(.title3)
            .bold()
            .foregroundColor(
                RecalllQTheme.primaryText
            )
            .fixedSize(
                horizontal: false,
                vertical: true
            )

            // =================================================
            // ANSWER
            // =================================================

            if vm.isShowingAnswer {

                Divider()

                Text(
                    "Answer"
                )
                .font(.caption)
                .foregroundColor(
                    RecalllQTheme.secondaryText
                )

                Text(
                    card.answer
                )
                .font(.body)
                .foregroundColor(
                    RecalllQTheme.primaryText
                )
                .fixedSize(
                    horizontal: false,
                    vertical: true
                )

                // =================================================
                // DIFFICULTY
                // =================================================

                Text(
                    "How difficult was this?"
                )
                .font(.caption)
                .foregroundColor(
                    RecalllQTheme.secondaryText
                )
                .padding(.top, 4)

                HStack(spacing: 8) {

                    // =================================================
                    // EASY
                    // =================================================

                    difficultyButton(
                        title:
                            "Easy",
                        icon:
                            "face.smiling.fill",
                        color:
                            RecalllQTheme.success
                    ) {

                        vm.markEasy()

                    }

                    // =================================================
                    // MEDIUM
                    // =================================================

                    difficultyButton(
                        title:
                            "Medium",
                        icon:
                            "minus.circle.fill",
                        color:
                            RecalllQTheme.secondary
                    ) {

                        vm.markMedium()

                    }

                    // =================================================
                    // HARD
                    // =================================================

                    difficultyButton(
                        title:
                            "Hard",
                        icon:
                            "exclamationmark.circle.fill",
                        color:
                            RecalllQTheme.error
                    ) {

                        vm.markHard()

                    }
                }

            } else {

                // =================================================
                // SHOW ANSWER
                // =================================================

                Button {

                    vm.showAnswer()

                } label: {

                    HStack {

                        Image(
                            systemName:
                                "eye.fill"
                        )

                        Text(
                            "Show Answer"
                        )
                        .font(.headline)

                        Spacer()

                        Image(
                            systemName:
                                "arrow.down"
                        )
                    }
                    .padding()
                    .frame(
                        maxWidth: .infinity
                    )
                    .foregroundColor(.white)
                    .background(
                        LinearGradient(
                            colors: [
                                RecalllQTheme.primary,
                                RecalllQTheme.primary.opacity(0.75)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius:
                                RecalllQTheme.mediumRadius
                        )
                    )
                }
            }

            // =================================================
            // NAVIGATION
            // =================================================

            HStack {

                Button {

                    vm.previousCard()

                } label: {

                    Label(
                        "Previous",
                        systemImage:
                            "chevron.left"
                    )
                }

                Spacer()

                Button {

                    vm.nextCard()

                } label: {

                    Label(
                        "Next",
                        systemImage:
                            "chevron.right"
                    )
                }
            }
            .font(.subheadline)
            .bold()
            .foregroundColor(
                RecalllQTheme.primary
            )
        }
        .padding(
            RecalllQTheme.largePadding
        )
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .background(
            RoundedRectangle(
                cornerRadius:
                    RecalllQTheme.largeRadius
            )
            .fill(
                RecalllQTheme.cardBackground
            )
        )
        .overlay(
            RoundedRectangle(
                cornerRadius:
                    RecalllQTheme.largeRadius
            )
            .stroke(
                RecalllQTheme.primary.opacity(
                    0.12
                ),
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

    // =====================================================
    // DIFFICULTY BUTTON
    // =====================================================

    @ViewBuilder
    private func difficultyButton(
        title: String,
        icon: String,
        color: Color,
        action: @escaping () -> Void
    ) -> some View {

        Button {

            action()

        } label: {

            VStack(
                spacing: 5
            ) {

                Image(
                    systemName:
                        icon
                )

                Text(
                    title
                )
                .font(.caption)
                .bold()
            }
            .frame(
                maxWidth: .infinity
            )
            .padding(.vertical, 10)
            .foregroundColor(
                color
            )
            .background(
                RoundedRectangle(
                    cornerRadius:
                        RecalllQTheme.smallRadius
                )
                .fill(
                    color.opacity(0.10)
                )
            )
        }
    }

    // =====================================================
    // FLASHCARD ROW
    // =====================================================

    @ViewBuilder
    private func flashcardRow(
        _ card: Flashcard
    ) -> some View {

        HStack(
            alignment: .top,
            spacing: 12
        ) {

            ZStack {

                Circle()
                    .fill(
                        RecalllQTheme.blueBackground
                    )
                    .frame(
                        width: 42,
                        height: 42
                    )

                Image(
                    systemName:
                        "rectangle.on.rectangle"
                )
                .foregroundColor(
                    RecalllQTheme.primary
                )
            }

            VStack(
                alignment: .leading,
                spacing: 6
            ) {

                Text(
                    card.question
                )
                .font(.headline)
                .foregroundColor(
                    RecalllQTheme.primaryText
                )
                .lineLimit(2)

                Text(
                    card.answer
                )
                .font(.caption)
                .foregroundColor(
                    RecalllQTheme.secondaryText
                )
                .lineLimit(2)

                HStack(
                    spacing: 8
                ) {

                    Text(
                        card.difficulty.displayName
                    )
                    .font(.caption2)
                    .bold()

                    Text(
                        "\(card.timesReviewed) reviews"
                    )
                    .font(.caption2)
                    .foregroundColor(
                        RecalllQTheme.secondaryText
                    )

                    if card.timesReviewed > 0 {

                        Text(
                            "\(Int(card.accuracy * 100))%"
                        )
                        .font(.caption2)
                        .foregroundColor(
                            RecalllQTheme.success
                        )
                    }
                }
            }

            Spacer()
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
                Color.gray.opacity(0.08),
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
        .contextMenu {

            Button(
                role: .destructive
            ) {

                vm.deleteFlashcard(
                    id: card.id
                )

            } label: {

                Label(
                    "Delete",
                    systemImage:
                        "trash"
                )
            }
        }
    }

    // =====================================================
    // EMPTY STATE
    // =====================================================

    private var emptyState: some View {

        VStack(
            spacing: 14
        ) {

            ZStack {

                Circle()
                    .fill(
                        RecalllQTheme.blueBackground
                    )
                    .frame(
                        width: 80,
                        height: 80
                    )

                Image(
                    systemName:
                        "rectangle.on.rectangle"
                )
                .font(
                    .system(size: 32)
                )
                .foregroundColor(
                    RecalllQTheme.primary
                )
            }

            Text(
                vm.searchText.isEmpty
                ? "No flashcards yet"
                : "No flashcards found"
            )
            .font(.headline)
            .foregroundColor(
                RecalllQTheme.primaryText
            )

            Text(
                vm.searchText.isEmpty
                ? "Create Memories first, then generate flashcards from your knowledge."
                : "Try another search term."
            )
            .font(.caption)
            .foregroundColor(
                RecalllQTheme.secondaryText
            )
            .multilineTextAlignment(
                .center
            )
            .padding(.horizontal)

            if vm.flashcards.isEmpty &&
                !appState.memoryViewModel.memories.isEmpty {

                Button {

                    appState
                        .createFlashcardsFromAllMemories()

                } label: {

                    Label(
                        "Generate From Memories",
                        systemImage:
                            "sparkles"
                    )
                    .font(.headline)
                    .padding()
                    .frame(
                        maxWidth: .infinity
                    )
                    .foregroundColor(.white)
                    .background(
                        LinearGradient(
                            colors: [
                                RecalllQTheme.primary,
                                RecalllQTheme.smartPurple
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius:
                                RecalllQTheme.mediumRadius
                        )
                    )
                }
                .padding(.horizontal)
            }
        }
        .frame(
            maxWidth: .infinity
        )
        .padding(30)
        .background(
            RoundedRectangle(
                cornerRadius:
                    RecalllQTheme.largeRadius
            )
            .fill(
                RecalllQTheme.cardBackground
            )
        )
        .overlay(
            RoundedRectangle(
                cornerRadius:
                    RecalllQTheme.largeRadius
            )
            .stroke(
                RecalllQTheme.primary.opacity(0.10),
                lineWidth: 1
            )
        )
    }
}
