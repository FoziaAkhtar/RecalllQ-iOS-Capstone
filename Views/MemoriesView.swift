
import SwiftUI

// =====================================================
// VIEW: MemoriesView
// =====================================================
// PURPOSE:
// Displays the student's AI-generated academic Memories.
//
// FEATURES:
// - Memory search
// - Memory count
// - Memory cards
// - AI-generated summaries
// - Memory tags
// - Delete memories
// - Generate Flashcards from Memories
// - Open existing Flashcards
// - Flashcard navigation
// =====================================================

struct MemoriesView: View {

    // =====================================================
    // APP STATE
    // =====================================================

    @EnvironmentObject var appState: AppState

    // =====================================================
    // VIEW MODEL
    // =====================================================

    private var vm: MemoryViewModel {
        appState.memoryViewModel
    }

    // =====================================================
    // BODY
    // =====================================================

    var body: some View {

        ScrollView(showsIndicators: false) {

            VStack(
                alignment: .leading,
                spacing: 20
            ) {

                headerSection

                searchSection

                summarySection

                if vm.memories.isEmpty {

                    emptyState

                } else {

                    memoriesSection
                }
            }
            .padding()
            .padding(.bottom, 30)
        }
        .background(
            RecalllQTheme.background
                .ignoresSafeArea()
        )
        .navigationTitle("Memories")
        .navigationBarTitleDisplayMode(.inline)
    }

    // =====================================================
    // HEADER
    // =====================================================

    private var headerSection: some View {

        HStack(spacing: 14) {

            VStack(
                alignment: .leading,
                spacing: 5
            ) {

                Text("Memories")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(
                        RecalllQTheme.primaryText
                    )

                Text(
                    "Your AI-powered academic knowledge base."
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
                        LinearGradient(
                            colors: [
                                RecalllQTheme.primary.opacity(0.18),
                                RecalllQTheme.smartPurple.opacity(0.12)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(
                        width: 56,
                        height: 56
                    )

                Image(
                    systemName: "brain.head.profile"
                )
                .font(.title2)
                .foregroundColor(
                    RecalllQTheme.primary
                )
            }
        }
    }

    // =====================================================
    // SEARCH
    // =====================================================

    private var searchSection: some View {

        HStack(spacing: 10) {

            Image(
                systemName: "magnifyingglass"
            )
            .foregroundColor(
                RecalllQTheme.primary
            )

            TextField(
                "Search your memories...",
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
                        systemName: "xmark.circle.fill"
                    )
                    .foregroundColor(
                        RecalllQTheme.secondaryText
                    )
                }
            }
        }
        .padding(13)
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
                RecalllQTheme.primary.opacity(0.10),
                lineWidth: 1
            )
        )
    }

    // =====================================================
    // SUMMARY SECTION
    // =====================================================

    private var summarySection: some View {

        HStack(spacing: 12) {

            summaryCard(
                value: "\(vm.memories.count)",
                title: "Memories",
                icon: "brain.head.profile",
                color: RecalllQTheme.primary
            )

            summaryCard(
                value: "\(appState.flashcardViewModel.totalFlashcards)",
                title: "Flashcards",
                icon: "rectangle.stack.fill",
                color: RecalllQTheme.smartPurple
            )
        }
    }

    // =====================================================
    // SUMMARY CARD
    // =====================================================

    @ViewBuilder
    private func summaryCard(
        value: String,
        title: String,
        icon: String,
        color: Color
    ) -> some View {

        VStack(
            alignment: .leading,
            spacing: 8
        ) {

            Image(systemName: icon)
                .font(.headline)
                .foregroundColor(color)

            Text(value)
                .font(.title2)
                .bold()
                .foregroundColor(
                    RecalllQTheme.primaryText
                )

            Text(title)
                .font(.caption)
                .foregroundColor(
                    RecalllQTheme.secondaryText
                )
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .padding()
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
                color.opacity(0.12),
                lineWidth: 1
            )
        )
    }

    // =====================================================
    // MEMORIES SECTION
    // =====================================================

    @ViewBuilder
    private var memoriesSection: some View {

        VStack(
            alignment: .leading,
            spacing: 14
        ) {

            HStack {

                VStack(
                    alignment: .leading,
                    spacing: 3
                ) {

                    Text("Knowledge Base")
                        .font(.title3)
                        .bold()
                        .foregroundColor(
                            RecalllQTheme.primaryText
                        )

                    Text(
                        "\(vm.memories.count) saved academic memor\(vm.memories.count == 1 ? "y" : "ies")"
                    )
                    .font(.caption)
                    .foregroundColor(
                        RecalllQTheme.secondaryText
                    )
                }

                Spacer()
            }

            ForEach(vm.memories) { memory in

                memoryCard(memory)
            }
        }
    }

    // =====================================================
    // MEMORY CARD
    // =====================================================

    @ViewBuilder
    private func memoryCard(
        _ memory: Memory
    ) -> some View {

        VStack(
            alignment: .leading,
            spacing: 14
        ) {

            // =====================================================
            // MEMORY HEADER
            // =====================================================

            HStack(
                alignment: .top,
                spacing: 12
            ) {

                ZStack {

                    RoundedRectangle(
                        cornerRadius: 12
                    )
                    .fill(
                        RecalllQTheme.blueBackground
                    )
                    .frame(
                        width: 46,
                        height: 46
                    )

                    Image(
                        systemName:
                            "brain.head.profile"
                    )
                    .foregroundColor(
                        RecalllQTheme.primary
                    )
                }

                VStack(
                    alignment: .leading,
                    spacing: 5
                ) {

                    Text(memory.title)
                        .font(.headline)
                        .foregroundColor(
                            RecalllQTheme.primaryText
                        )
                        .fixedSize(
                            horizontal: false,
                            vertical: true
                        )

                    Text(
                        memory.source == "ai"
                        ? "AI Enhanced Memory"
                        : "Academic Memory"
                    )
                    .font(.caption)
                    .foregroundColor(
                        RecalllQTheme.secondaryText
                    )
                }

                Spacer()

                Button {

                    vm.deleteMemory(
                        id: memory.id
                    )

                } label: {

                    Image(
                        systemName:
                            "trash"
                    )
                    .foregroundColor(
                        RecalllQTheme.error
                    )
                }
                .buttonStyle(.plain)
            }

            // =====================================================
            // SUMMARY
            // =====================================================

            if !memory.summary
                .trimmingCharacters(
                    in: .whitespacesAndNewlines
                )
                .isEmpty {

                VStack(
                    alignment: .leading,
                    spacing: 7
                ) {

                    Text("AI SUMMARY")
                        .font(.caption2)
                        .bold()
                        .tracking(1)
                        .foregroundColor(
                            RecalllQTheme.secondaryText
                        )

                    Text(memory.summary)
                        .font(.subheadline)
                        .foregroundColor(
                            RecalllQTheme.primaryText
                        )
                        .fixedSize(
                            horizontal: false,
                            vertical: true
                        )
                }
            }

            // =====================================================
            // TAGS
            // =====================================================

            if !memory.tags.isEmpty {

                ScrollView(
                    .horizontal,
                    showsIndicators: false
                ) {

                    HStack(spacing: 7) {

                        ForEach(
                            memory.tags,
                            id: \.self
                        ) { tag in

                            Text(tag)
                                .font(.caption2)
                                .bold()
                                .foregroundColor(
                                    RecalllQTheme.primary
                                )
                                .padding(
                                    .horizontal,
                                    8
                                )
                                .padding(
                                    .vertical,
                                    5
                                )
                                .background(
                                    RecalllQTheme.primary
                                        .opacity(0.09)
                                )
                                .clipShape(
                                    Capsule()
                                )
                        }
                    }
                }
            }

            // =====================================================
            // FLASHCARD ACTION
            // =====================================================

            flashcardActionSection(
                for: memory
            )
        }
        .padding()
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
                RecalllQTheme.primary.opacity(0.10),
                lineWidth: 1
            )
        )
        .shadow(
            color: Color.black.opacity(
                RecalllQTheme.shadowOpacity
            ),
            radius: RecalllQTheme.shadowRadius,
            x: 0,
            y: RecalllQTheme.shadowY
        )
    }

    // =====================================================
    // FLASHCARD ACTION SECTION
    // =====================================================

    @ViewBuilder
    private func flashcardActionSection(
        for memory: Memory
    ) -> some View {

        let hasFlashcard =
            appState.flashcardViewModel
                .hasFlashcard(
                    for: memory.id
                )

        VStack(
            alignment: .leading,
            spacing: 8
        ) {

            Divider()

            if hasFlashcard {

                // =====================================================
                // EXISTING FLASHCARD
                // =====================================================

                Button {

                    appState.openMemoryInFlashcards(
                        memory
                    )

                } label: {

                    HStack(spacing: 12) {

                        ZStack {

                            Circle()
                                .fill(
                                    RecalllQTheme.success
                                        .opacity(0.12)
                                )
                                .frame(
                                    width: 38,
                                    height: 38
                                )

                            Image(
                                systemName:
                                    "rectangle.on.rectangle.fill"
                            )
                            .foregroundColor(
                                RecalllQTheme.success
                            )
                        }

                        VStack(
                            alignment: .leading,
                            spacing: 3
                        ) {

                            Text(
                                "Flashcard Ready"
                            )
                            .font(.subheadline)
                            .bold()
                            .foregroundColor(
                                RecalllQTheme.primaryText
                            )

                            Text(
                                "Open this Memory's flashcard in Study Mode"
                            )
                            .font(.caption)
                            .foregroundColor(
                                RecalllQTheme.secondaryText
                            )
                        }

                        Spacer()

                        Image(
                            systemName:
                                "arrow.right.circle.fill"
                        )
                        .font(.title3)
                        .foregroundColor(
                            RecalllQTheme.success
                        )
                    }
                    .padding(12)
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
                            RecalllQTheme.success
                                .opacity(0.07)
                        )
                    )
                }
                .buttonStyle(.plain)

            } else {

                // =====================================================
                // GENERATE NEW FLASHCARD
                // =====================================================

                Button {

                    appState.createFlashcardFromMemory(
                        memory
                    )

                    // =====================================================
                    // OPEN FLASHCARD TAB
                    // =====================================================

                    appState.selectedTab = 3

                } label: {

                    HStack(spacing: 12) {

                        ZStack {

                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            RecalllQTheme.primary
                                                .opacity(0.16),
                                            RecalllQTheme.smartPurple
                                                .opacity(0.14)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(
                                    width: 38,
                                    height: 38
                                )

                            Image(
                                systemName:
                                    "sparkles"
                            )
                            .foregroundColor(
                                RecalllQTheme.primary
                            )
                        }

                        VStack(
                            alignment: .leading,
                            spacing: 3
                        ) {

                            Text(
                                "Generate Flashcard"
                            )
                            .font(.subheadline)
                            .bold()
                            .foregroundColor(
                                RecalllQTheme.primaryText
                            )

                            Text(
                                "Turn this Memory into an active study card"
                            )
                            .font(.caption)
                            .foregroundColor(
                                RecalllQTheme.secondaryText
                            )
                        }

                        Spacer()

                        Image(
                            systemName:
                                "arrow.right.circle.fill"
                        )
                        .font(.title3)
                        .foregroundColor(
                            RecalllQTheme.primary
                        )
                    }
                    .padding(12)
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
                            RecalllQTheme.primary
                                .opacity(0.06)
                        )
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    // =====================================================
    // EMPTY STATE
    // =====================================================

    private var emptyState: some View {

        VStack(spacing: 16) {

            ZStack {

                Circle()
                    .fill(
                        RecalllQTheme.blueBackground
                    )
                    .frame(
                        width: 88,
                        height: 88
                    )

                Image(
                    systemName:
                        "brain.head.profile"
                )
                .font(
                    .system(size: 36)
                )
                .foregroundColor(
                    RecalllQTheme.primary
                )
            }

            Text(
                vm.searchText.isEmpty
                ? "Your Knowledge Base is Ready"
                : "No Memories Found"
            )
            .font(.title3)
            .bold()
            .foregroundColor(
                RecalllQTheme.primaryText
            )

            Text(
                vm.searchText.isEmpty
                ? "Add study notes and RecalllQ will transform them into intelligent academic Memories."
                : "Try another search term."
            )
            .font(.caption)
            .foregroundColor(
                RecalllQTheme.secondaryText
            )
            .multilineTextAlignment(.center)
            .fixedSize(
                horizontal: false,
                vertical: true
            )
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
