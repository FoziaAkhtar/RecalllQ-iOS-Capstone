
import SwiftUI

// =====================================================
// VIEW: MemoriesView
// =====================================================
// PURPOSE:
// Displays AI-organized memories created by RecalllQ.
//
// FEATURES:
// - Search memories
// - Filter memories by topic
// - Display memory statistics
// - Display AI-organized memory cards
// - Delete memories with visible delete button
// - Empty state
// - Modern RecalllQ UI
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

        ZStack {

            RecalllQTheme.background
                .ignoresSafeArea()

            VStack(spacing: 0) {

                searchBar

                ScrollView(showsIndicators: false) {

                    VStack(
                        alignment: .leading,
                        spacing: 20
                    ) {

                        memoryHeader

                        memorySummaryCard

                        if !vm.allTags.isEmpty {
                            categorySection
                        }

                        knowledgeBaseHeader

                        if vm.filteredMemories.isEmpty {

                            emptyState

                        } else {

                            ForEach(
                                vm.filteredMemories
                            ) { memory in

                                memoryCard(memory)
                            }
                        }

                        Spacer(minLength: 30)
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 18)
                }
            }
        }
        .navigationTitle("Memories")
        .navigationBarTitleDisplayMode(.inline)
    }

    // =====================================================
    // SEARCH BAR
    // =====================================================

    private var searchBar: some View {

        HStack(spacing: 10) {

            ZStack {

                Circle()
                    .fill(
                        RecalllQTheme.primary.opacity(0.10)
                    )
                    .frame(
                        width: 32,
                        height: 32
                    )

                Image(systemName: "magnifyingglass")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(
                        RecalllQTheme.primary
                    )
            }

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
            .font(.subheadline)

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
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
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
                RecalllQTheme.primary.opacity(0.12),
                lineWidth: 1
            )
        )
        .shadow(
            color: Color.black.opacity(0.05),
            radius: 8,
            x: 0,
            y: 3
        )
        .padding(.horizontal, 18)
        .padding(.top, 10)
    }

    // =====================================================
    // MEMORY HEADER
    // =====================================================

    private var memoryHeader: some View {

        HStack(spacing: 14) {

            ZStack {

                RoundedRectangle(
                    cornerRadius: 16
                )
                .fill(
                    LinearGradient(
                        colors: [
                            RecalllQTheme.primary,
                            RecalllQTheme.smartPurple
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
                    systemName:
                        "brain.head.profile"
                )
                .font(.title2)
                .foregroundColor(.white)
            }

            VStack(
                alignment: .leading,
                spacing: 4
            ) {

                Text("My Memories")
                    .font(.title2.weight(.bold))
                    .foregroundColor(
                        RecalllQTheme.primaryText
                    )

                Text(
                    "\(vm.filteredMemories.count) organized memories"
                )
                .font(.subheadline)
                .foregroundColor(
                    RecalllQTheme.secondaryText
                )
            }

            Spacer()
        }
    }

    // =====================================================
    // MEMORY SUMMARY
    // =====================================================

    private var memorySummaryCard: some View {

        HStack(spacing: 0) {

            summaryMetric(
                value: "\(vm.memories.count)",
                title: "Memories",
                icon: "brain.fill",
                color: RecalllQTheme.primary,
                background: RecalllQTheme.blueBackground
            )

            Rectangle()
                .fill(
                    Color.gray.opacity(0.12)
                )
                .frame(
                    width: 1,
                    height: 48
                )
                .padding(.horizontal, 14)

            summaryMetric(
                value: "\(vm.allTags.count)",
                title: "Topics",
                icon: "tag.fill",
                color: RecalllQTheme.smartPurple,
                background: RecalllQTheme.purpleBackground
            )

            Spacer()
        }
        .padding(18)
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
    }

    // =====================================================
    // SUMMARY METRIC
    // =====================================================

    private func summaryMetric(
        value: String,
        title: String,
        icon: String,
        color: Color,
        background: Color
    ) -> some View {

        HStack(spacing: 10) {

            ZStack {

                Circle()
                    .fill(background)
                    .frame(
                        width: 44,
                        height: 44
                    )

                Image(systemName: icon)
                    .font(.subheadline.weight(.bold))
                    .foregroundColor(color)
            }

            VStack(
                alignment: .leading,
                spacing: 2
            ) {

                Text(value)
                    .font(
                        .system(
                            size: 22,
                            weight: .bold
                        )
                    )
                    .foregroundColor(
                        RecalllQTheme.primaryText
                    )

                Text(title)
                    .font(.caption)
                    .foregroundColor(
                        RecalllQTheme.secondaryText
                    )
            }
        }
    }

    // =====================================================
    // CATEGORY SECTION
    // =====================================================

    private var categorySection: some View {

        VStack(
            alignment: .leading,
            spacing: 10
        ) {

            HStack {

                Label(
                    "Topics",
                    systemImage:
                        "square.grid.2x2.fill"
                )
                .font(.headline)
                .foregroundColor(
                    RecalllQTheme.primaryText
                )

                Spacer()

                Text("\(vm.allTags.count)")
                    .font(.caption.weight(.bold))
                    .foregroundColor(
                        RecalllQTheme.smartPurple
                    )
            }

            ScrollView(
                .horizontal,
                showsIndicators: false
            ) {

                HStack(spacing: 8) {

                    tagButton(
                        title: "All",
                        icon: "sparkles",
                        isSelected:
                            vm.selectedTag == "all"
                    ) {

                        vm.selectedTag = "all"
                    }

                    ForEach(
                        vm.allTags,
                        id: \.self
                    ) { tag in

                        tagButton(
                            title: tag,
                            icon: "tag.fill",
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

    // =====================================================
    // TAG BUTTON
    // =====================================================

    @ViewBuilder
    private func tagButton(
        title: String,
        icon: String,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {

        Button {

            action()

        } label: {

            HStack(spacing: 5) {

                Image(systemName: icon)
                    .font(.caption2.weight(.bold))

                Text(title)
                    .font(.caption.weight(.semibold))
            }
            .padding(.horizontal, 13)
            .padding(.vertical, 9)
            .background(
                Capsule()
                    .fill(
                        isSelected
                        ? RecalllQTheme.primary
                        : RecalllQTheme.cardBackground
                    )
            )
            .overlay(
                Capsule()
                    .stroke(
                        isSelected
                        ? RecalllQTheme.primary
                        : RecalllQTheme.primary.opacity(0.12),
                        lineWidth: 1
                    )
            )
            .foregroundColor(
                isSelected
                ? .white
                : RecalllQTheme.primary
            )
        }
        .buttonStyle(.plain)
    }

    // =====================================================
    // KNOWLEDGE BASE HEADER
    // =====================================================

    private var knowledgeBaseHeader: some View {

        HStack(spacing: 10) {

            ZStack {

                RoundedRectangle(
                    cornerRadius: 10
                )
                .fill(
                    RecalllQTheme.orangeBackground
                )
                .frame(
                    width: 36,
                    height: 36
                )

                Image(systemName: "sparkles")
                    .font(.subheadline.weight(.bold))
                    .foregroundColor(
                        RecalllQTheme.studyOrange
                    )
            }

            VStack(
                alignment: .leading,
                spacing: 2
            ) {

                Text("Knowledge Base")
                    .font(.title3.weight(.bold))
                    .foregroundColor(
                        RecalllQTheme.primaryText
                    )

                Text(
                    "Your AI-organized knowledge"
                )
                .font(.caption)
                .foregroundColor(
                    RecalllQTheme.secondaryText
                )
            }

            Spacer()
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

            // =================================================
            // TITLE + DELETE BUTTON
            // =================================================

            HStack(
                alignment: .top,
                spacing: 12
            ) {

                ZStack {

                    RoundedRectangle(
                        cornerRadius: 13
                    )
                    .fill(
                        LinearGradient(
                            colors: [
                                RecalllQTheme.blueBackground,
                                RecalllQTheme.purpleBackground
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(
                        width: 46,
                        height: 46
                    )

                    Image(
                        systemName:
                            "brain.head.profile"
                    )
                    .font(.headline)
                    .foregroundColor(
                        RecalllQTheme.primary
                    )
                }

                VStack(
                    alignment: .leading,
                    spacing: 5
                ) {

                    Text(
                        memory.title.isEmpty
                        ? "Untitled Memory"
                        : memory.title
                    )
                    .font(
                        .headline.weight(.bold)
                    )
                    .foregroundColor(
                        RecalllQTheme.primaryText
                    )
                    .lineLimit(2)

                    HStack(spacing: 5) {

                        Circle()
                            .fill(
                                RecalllQTheme.success
                            )
                            .frame(
                                width: 6,
                                height: 6
                            )

                        Text("AI Organized Memory")
                            .font(
                                .caption2.weight(.semibold)
                            )
                            .foregroundColor(
                                RecalllQTheme.success
                            )
                    }
                }

                Spacer()

                // =================================================
                // DELETE BUTTON
                // =================================================

                Button {

                    vm.deleteMemory(
                        id: memory.id
                    )

                } label: {

                    Image(
                        systemName:
                            "trash"
                    )
                    .font(
                        .subheadline.weight(.semibold)
                    )
                    .foregroundColor(.red)
                    .frame(
                        width: 36,
                        height: 36
                    )
                    .background(
                        Circle()
                            .fill(
                                Color.red.opacity(0.10)
                            )
                    )
                }
                .buttonStyle(.plain)
            }

            // =================================================
            // DIVIDER
            // =================================================

            Rectangle()
                .fill(
                    Color.gray.opacity(0.08)
                )
                .frame(height: 1)

            // =================================================
            // SUMMARY
            // =================================================

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
            .fixedSize(
                horizontal: false,
                vertical: true
            )

            // =================================================
            // TAGS
            // =================================================

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

                            HStack(spacing: 4) {

                                Image(
                                    systemName:
                                        "tag.fill"
                                )
                                .font(
                                    .system(size: 8)
                                )

                                Text(tag)
                                    .font(
                                        .caption2.weight(
                                            .semibold
                                        )
                                    )
                            }
                            .padding(
                                .horizontal,
                                9
                            )
                            .padding(
                                .vertical,
                                6
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

            // =================================================
            // DELETE LABEL
            // =================================================

            HStack {

                Spacer()

                Button {

                    vm.deleteMemory(
                        id: memory.id
                    )

                } label: {

                    Label(
                        "Delete Memory",
                        systemImage: "trash"
                    )
                    .font(
                        .caption.weight(.semibold)
                    )
                    .foregroundColor(.red)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(18)
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
    }

    // =====================================================
    // EMPTY STATE
    // =====================================================

    private var emptyState: some View {

        VStack(spacing: 16) {

            ZStack {

                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                RecalllQTheme.blueBackground,
                                RecalllQTheme.purpleBackground
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
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
                    .system(
                        size: 36,
                        weight: .medium
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
            .foregroundColor(
                RecalllQTheme.primaryText
            )

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
            .multilineTextAlignment(.center)
            .padding(.horizontal, 20)
        }
        .frame(
            maxWidth: .infinity
        )
        .padding(.vertical, 34)
        .padding(.horizontal, 20)
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
                Color.black.opacity(0.05),
            radius: 8,
            x: 0,
            y: 4
        )
    }
}
