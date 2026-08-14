
import SwiftUI

// =====================================================
// VIEW: MemoriesView
// =====================================================
// PURPOSE:
// Displays AI-organized memories created by RecalllQ.
//
// FEATURES:
// - Search memories
// - Filter by tags
// - Display memory summaries
// - Display memory tags
// - Memory statistics
// - Delete memories
// - Professional RecalllQ design
// - Empty state
// =====================================================

struct MemoriesView: View {

    // =====================================================
    // GLOBAL APP STATE
    // =====================================================

    @EnvironmentObject var appState: AppState

    // =====================================================
    // MEMORY VIEW MODEL
    // =====================================================

    private var vm: MemoryViewModel {
        appState.memoryViewModel
    }

    // =====================================================
    // BODY
    // =====================================================

    var body: some View {

        VStack(spacing: 0) {

            // =================================================
            // SEARCH BAR
            // =================================================

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
                            systemName:
                                "xmark.circle.fill"
                        )
                        .foregroundColor(.secondary)
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
                    RecalllQTheme.blueBackground
                )
            )
            .overlay(
                RoundedRectangle(
                    cornerRadius:
                        RecalllQTheme.mediumRadius
                )
                .stroke(
                    RecalllQTheme.primary.opacity(0.15),
                    lineWidth: 1
                )
            )
            .padding(.horizontal)
            .padding(.top, 10)

            // =================================================
            // MAIN CONTENT
            // =================================================

            ScrollView {

                VStack(
                    alignment: .leading,
                    spacing: 18
                ) {

                    // =============================================
                    // MEMORY HEADER
                    // =============================================

                    HStack {

                        VStack(
                            alignment: .leading,
                            spacing: 4
                        ) {

                            Text("My Memories")
                                .font(.title2)
                                .bold()
                                .foregroundColor(
                                    RecalllQTheme.primaryText
                                )

                            Text(
                                "\(vm.filteredMemories.count) organized memories"
                            )
                            .font(.caption)
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
                                    width: 48,
                                    height: 48
                                )

                            Image(
                                systemName:
                                    "brain.head.profile"
                            )
                            .font(.title3)
                            .foregroundColor(
                                RecalllQTheme.primary
                            )
                        }
                    }

                    // =============================================
                    // MEMORY SUMMARY CARD
                    // =============================================

                    HStack(spacing: 14) {

                        ZStack {

                            Circle()
                                .fill(
                                    RecalllQTheme.greenBackground
                                )
                                .frame(
                                    width: 48,
                                    height: 48
                                )

                            Image(
                                systemName:
                                    "brain.fill"
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
                                "\(vm.memories.count)"
                            )
                            .font(.title2)
                            .bold()
                            .foregroundColor(
                                RecalllQTheme.primary
                            )

                            Text("Total Memories")
                                .font(.caption)
                                .foregroundColor(
                                    RecalllQTheme.secondaryText
                                )
                        }

                        Spacer()

                        VStack(
                            alignment: .trailing,
                            spacing: 3
                        ) {

                            Text(
                                "\(vm.allTags.count)"
                            )
                            .font(.title2)
                            .bold()
                            .foregroundColor(
                                RecalllQTheme.secondary
                            )

                            Text("Categories")
                                .font(.caption)
                                .foregroundColor(
                                    RecalllQTheme.secondaryText
                                )
                        }
                    }
                    .padding(
                        RecalllQTheme.largePadding
                    )
                    .frame(
                        maxWidth: .infinity
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
                    .shadow(
                        color:
                            Color.black.opacity(
                                RecalllQTheme.shadowOpacity
                            ),
                        radius:
                            RecalllQTheme.shadowRadius,
                        x: 0,
                        y: RecalllQTheme.shadowY
                    )

                    // =============================================
                    // CATEGORY FILTER
                    // =============================================

                    if !vm.allTags.isEmpty {

                        VStack(
                            alignment: .leading,
                            spacing: 10
                        ) {

                            Text("Categories")
                                .font(.headline)

                            ScrollView(
                                .horizontal,
                                showsIndicators: false
                            ) {

                                HStack(spacing: 8) {

                                    // ---------------------------------
                                    // ALL FILTER
                                    // ---------------------------------

                                    tagButton(
                                        title: "All",
                                        isSelected:
                                            vm.selectedTag == "all"
                                    ) {

                                        vm.selectedTag = "all"
                                    }

                                    // ---------------------------------
                                    // TAG FILTERS
                                    // ---------------------------------

                                    ForEach(
                                        vm.allTags,
                                        id: \.self
                                    ) { tag in

                                        tagButton(
                                            title: tag,
                                            isSelected:
                                                vm.selectedTag == tag
                                        ) {

                                            vm.selectedTag = tag
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // =============================================
                    // MEMORY SECTION HEADER
                    // =============================================

                    HStack {

                        Text("Knowledge Base")
                            .font(.title3)
                            .bold()

                        Spacer()

                        Image(
                            systemName:
                                "sparkles"
                        )
                        .foregroundColor(
                            RecalllQTheme.warning
                        )
                    }

                    // =============================================
                    // EMPTY STATE
                    // =============================================

                    if vm.filteredMemories.isEmpty {

                        VStack(spacing: 16) {

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
                                        "brain.head.profile"
                                )
                                .font(
                                    .system(
                                        size: 34
                                    )
                                )
                                .foregroundColor(
                                    RecalllQTheme.primary
                                )
                            }

                            Text(
                                vm.searchText.isEmpty &&
                                vm.selectedTag == "all"
                                ? "No memories yet"
                                : "No memories found"
                            )
                            .font(.headline)

                            Text(
                                vm.searchText.isEmpty &&
                                vm.selectedTag == "all"
                                ? "Create a study note and RecalllQ will organize it into an intelligent memory."
                                : "Try another search term or category."
                            )
                            .font(.caption)
                            .foregroundColor(
                                RecalllQTheme.secondaryText
                            )
                            .multilineTextAlignment(
                                .center
                            )
                            .padding(.horizontal)

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
                                RecalllQTheme.blueBackground
                            )
                        )

                    } else {

                        // =========================================
                        // MEMORY CARDS
                        // =========================================

                        ForEach(
                            vm.filteredMemories
                        ) { memory in

                            memoryCard(
                                memory
                            )
                        }
                    }
                }
                .padding()
            }
        }

        // =====================================================
        // NAVIGATION
        // =====================================================

        .navigationTitle("Memories")
        .navigationBarTitleDisplayMode(.inline)
    }

    // =====================================================
    // TAG BUTTON
    // =====================================================

    @ViewBuilder
    private func tagButton(
        title: String,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {

        Button {

            action()

        } label: {

            Text(title)
                .font(.caption)
                .bold()
                .padding(
                    .horizontal,
                    13
                )
                .padding(
                    .vertical,
                    8
                )
                .background(
                    Capsule()
                        .fill(
                            isSelected
                            ? RecalllQTheme.primary
                            : RecalllQTheme.blueBackground
                        )
                )
                .foregroundColor(
                    isSelected
                    ? .white
                    : RecalllQTheme.primary
                )
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
            spacing: 12
        ) {

            // =============================================
            // MEMORY TITLE
            // =============================================

            HStack(
                alignment: .top,
                spacing: 10
            ) {

                ZStack {

                    Circle()
                        .fill(
                            RecalllQTheme.primary
                                .opacity(0.12)
                        )
                        .frame(
                            width: 40,
                            height: 40
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
                    spacing: 4
                ) {

                    Text(
                        memory.title.isEmpty
                        ? "Untitled Memory"
                        : memory.title
                    )
                    .font(.headline)
                    .lineLimit(2)

                    Text("AI Organized Memory")
                        .font(.caption2)
                        .foregroundColor(
                            RecalllQTheme.success
                        )
                }

                Spacer()
            }

            // =============================================
            // SUMMARY
            // =============================================

            Text(
                memory.summary.isEmpty
                ? memory.content
                : memory.summary
            )
            .font(.subheadline)
            .foregroundColor(
                RecalllQTheme.secondaryText
            )
            .lineLimit(4)

            // =============================================
            // TAGS
            // =============================================

            if !memory.tags.isEmpty {

                ScrollView(
                    .horizontal,
                    showsIndicators: false
                ) {

                    HStack(spacing: 6) {

                        ForEach(
                            memory.tags,
                            id: \.self
                        ) { tag in

                            Text(tag)
                                .font(.caption2)
                                .bold()
                                .padding(
                                    .horizontal,
                                    8
                                )
                                .padding(
                                    .vertical,
                                    5
                                )
                                .background(
                                    Capsule()
                                        .fill(
                                            RecalllQTheme
                                                .purpleBackground
                                        )
                                )
                                .foregroundColor(
                                    RecalllQTheme.smartPurple
                                )
                        }
                    }
                }
            }
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
                RecalllQTheme.primary.opacity(0.08),
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
            y: RecalllQTheme.shadowY
        )
        .swipeActions {

            // =============================================
            // DELETE
            // =============================================

            Button(
                role: .destructive
            ) {

                vm.deleteMemory(
                    id: memory.id
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
}
