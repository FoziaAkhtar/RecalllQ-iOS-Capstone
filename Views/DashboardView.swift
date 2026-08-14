
import SwiftUI

// =====================================================
// VIEW: DashboardView
// =====================================================
// PURPOSE:
// - Main home screen for RecalllQ
// - Displays learning progress
// - Shows AI memory insights
// - Displays smart suggestions
// - Provides quick actions
// - Uses the RecalllQ professional study theme
// =====================================================

struct DashboardView: View {

    // =====================================================
    // GLOBAL APP STATE
    // =====================================================

    @EnvironmentObject var appState: AppState

    // =====================================================
    // MEMORY VIEW MODEL
    // =====================================================

    private var viewModel: MemoryViewModel {
        appState.memoryViewModel
    }

    // =====================================================
    // MEMORY GOAL
    // =====================================================

    private let memoryGoal = 20

    // =====================================================
    // BODY
    // =====================================================

    var body: some View {

        ScrollView {

            VStack(alignment: .leading, spacing: 24) {

                // =====================================================
                // WELCOME HEADER
                // =====================================================

                VStack(alignment: .leading, spacing: 6) {

                    Text("Welcome back 👋")
                        .font(.subheadline)
                        .foregroundColor(RecalllQTheme.secondaryText)

                    Text("RecalllQ")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(RecalllQTheme.primary)

                    Text("Your intelligent study companion")
                        .font(.subheadline)
                        .foregroundColor(RecalllQTheme.secondaryText)
                }

                // =====================================================
                // AI MEMORY ASSISTANT
                // =====================================================

                VStack(alignment: .leading, spacing: 14) {

                    HStack {

                        ZStack {

                            Circle()
                                .fill(
                                    RecalllQTheme.primary
                                        .opacity(0.15)
                                )
                                .frame(
                                    width: 48,
                                    height: 48
                                )

                            Image(
                                systemName:
                                    "brain.head.profile"
                            )
                            .font(.title2)
                            .foregroundColor(
                                RecalllQTheme.primary
                            )
                        }

                        VStack(
                            alignment: .leading,
                            spacing: 3
                        ) {

                            Text("AI Memory Assistant")
                                .font(.headline)

                            HStack(spacing: 5) {

                                Circle()
                                    .fill(
                                        RecalllQTheme.success
                                    )
                                    .frame(
                                        width: 8,
                                        height: 8
                                    )

                                Text("Ready to learn")
                                    .font(.caption)
                                    .foregroundColor(
                                        RecalllQTheme.success
                                    )
                            }
                        }

                        Spacer()
                    }

                    Text(
                        viewModel.memories.isEmpty
                        ? "Create your first note and RecalllQ will organize it into a structured memory."
                        : "RecalllQ is tracking \(viewModel.memories.count) memories across \(viewModel.allTags.count) study categories."
                    )
                    .font(.subheadline)
                    .foregroundColor(
                        RecalllQTheme.secondaryText
                    )
                    .fixedSize(
                        horizontal: false,
                        vertical: true
                    )
                }
                .padding(RecalllQTheme.largePadding)
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
                        RecalllQTheme.blueBackground
                    )
                )

                // =====================================================
                // LEARNING OVERVIEW
                // =====================================================

                Text("Learning Overview")
                    .font(.title3)
                    .bold()
                    .foregroundColor(
                        RecalllQTheme.primaryText
                    )

                // =====================================================
                // STAT CARDS
                // =====================================================

                HStack(spacing: 12) {

                    StatCard(
                        title: "Memories",
                        value: "\(viewModel.memories.count)",
                        valueColor: RecalllQTheme.primary
                    )

                    StatCard(
                        title: "Categories",
                        value: "\(viewModel.allTags.count)",
                        valueColor: RecalllQTheme.secondary
                    )
                }

                HStack(spacing: 12) {

                    StatCard(
                        title: "Suggestions",
                        value: "\(viewModel.suggestedMemories.count)",
                        valueColor: RecalllQTheme.warning
                    )

                    StatCard(
                        title: "Status",
                        value: viewModel.memories.isEmpty
                            ? "Ready"
                            : "Active",
                        valueColor: RecalllQTheme.success
                    )
                }

                // =====================================================
                // MEMORY PROGRESS
                // =====================================================

                VStack(alignment: .leading, spacing: 14) {

                    HStack {

                        VStack(
                            alignment: .leading,
                            spacing: 4
                        ) {

                            Text("Memory Progress")
                                .font(.headline)

                            Text(
                                "Build your knowledge base"
                            )
                            .font(.caption)
                            .foregroundColor(
                                RecalllQTheme.secondaryText
                            )
                        }

                        Spacer()

                        Text(
                            "\(min(viewModel.memories.count, memoryGoal))/\(memoryGoal)"
                        )
                        .font(.headline)
                        .bold()
                        .foregroundColor(
                            RecalllQTheme.primary
                        )
                    }

                    ProgressView(
                        value: Double(
                            min(
                                viewModel.memories.count,
                                memoryGoal
                            )
                        ),
                        total: Double(memoryGoal)
                    )
                    .tint(RecalllQTheme.primary)

                    Text(
                        viewModel.memories.count >= memoryGoal
                        ? "🎉 Great job! You reached your memory goal."
                        : "\(memoryGoal - viewModel.memories.count) more memories to reach your goal."
                    )
                    .font(.caption)
                    .foregroundColor(
                        RecalllQTheme.secondaryText
                    )
                }
                .padding(RecalllQTheme.largePadding)
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
                        RecalllQTheme.greenBackground
                    )
                )

                // =====================================================
                // SMART SUGGESTIONS HEADER
                // =====================================================

                HStack {

                    Text("Smart Suggestions")
                        .font(.title3)
                        .bold()

                    Spacer()

                    Image(
                        systemName: "sparkles"
                    )
                    .foregroundColor(
                        RecalllQTheme.warning
                    )
                }

                // =====================================================
                // SMART SUGGESTIONS
                // =====================================================

                if viewModel.suggestedMemories.isEmpty {

                    VStack(spacing: 12) {

                        Image(
                            systemName: "lightbulb"
                        )
                        .font(.largeTitle)
                        .foregroundColor(
                            RecalllQTheme.warning
                        )

                        Text("Suggestions coming soon")
                            .font(.headline)

                        Text(
                            "Create a few memories and RecalllQ will start showing useful study suggestions."
                        )
                        .font(.caption)
                        .foregroundColor(
                            RecalllQTheme.secondaryText
                        )
                        .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(25)
                    .background(
                        RoundedRectangle(
                            cornerRadius:
                                RecalllQTheme.mediumRadius
                        )
                        .fill(
                            RecalllQTheme.orangeBackground
                        )
                    )

                } else {

                    ForEach(
                        viewModel.suggestedMemories
                    ) { memory in

                        VStack(
                            alignment: .leading,
                            spacing: 8
                        ) {

                            HStack {

                                Image(
                                    systemName: "brain"
                                )
                                .foregroundColor(
                                    RecalllQTheme.secondary
                                )

                                Text(memory.title)
                                    .font(.headline)

                                Spacer()
                            }

                            Text(memory.summary)
                                .font(.caption)
                                .foregroundColor(
                                    RecalllQTheme.secondaryText
                                )
                                .lineLimit(2)
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
                        .shadow(
                            color: Color.black.opacity(
                                RecalllQTheme.shadowOpacity
                            ),
                            radius:
                                RecalllQTheme.shadowRadius,
                            x: 0,
                            y: RecalllQTheme.shadowY
                        )
                    }
                }

                // =====================================================
                // QUICK ACTIONS
                // =====================================================

                Text("Quick Actions")
                    .font(.title3)
                    .bold()

                // =====================================================
                // CREATE NOTE
                // =====================================================

                NavigationLink(
                    destination: NotesView()
                        .environmentObject(appState)
                ) {

                    HStack(spacing: 14) {

                        ZStack {

                            Circle()
                                .fill(
                                    Color.white.opacity(0.18)
                                )
                                .frame(
                                    width: 44,
                                    height: 44
                                )

                            Image(
                                systemName: "note.text"
                            )
                            .font(.title3)
                        }

                        VStack(
                            alignment: .leading,
                            spacing: 3
                        ) {

                            Text("Create a Note")
                                .font(.headline)

                            Text(
                                "Capture something you want to remember"
                            )
                            .font(.caption)
                            .opacity(0.9)
                        }

                        Spacer()

                        Image(
                            systemName: "chevron.right"
                        )
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.white)
                    .background(
                        RoundedRectangle(
                            cornerRadius:
                                RecalllQTheme.mediumRadius
                        )
                        .fill(
                            RecalllQTheme.primary
                        )
                    )
                }

                // =====================================================
                // EXPLORE MEMORIES
                // =====================================================

                NavigationLink(
                    destination: MemoriesView()
                        .environmentObject(appState)
                ) {

                    HStack(spacing: 14) {

                        ZStack {

                            Circle()
                                .fill(
                                    Color.white.opacity(0.18)
                                )
                                .frame(
                                    width: 44,
                                    height: 44
                                )

                            Image(
                                systemName:
                                    "brain.head.profile"
                            )
                            .font(.title3)
                        }

                        VStack(
                            alignment: .leading,
                            spacing: 3
                        ) {

                            Text("Explore Memories")
                                .font(.headline)

                            Text(
                                "Review your organized knowledge"
                            )
                            .font(.caption)
                            .opacity(0.9)
                        }

                        Spacer()

                        Image(
                            systemName: "chevron.right"
                        )
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.white)
                    .background(
                        RoundedRectangle(
                            cornerRadius:
                                RecalllQTheme.mediumRadius
                        )
                        .fill(
                            RecalllQTheme.secondary
                        )
                    )
                }
            }
            .padding()
        }

        // =====================================================
        // DASHBOARD NAVIGATION
        // =====================================================

        .navigationTitle("Dashboard")
        .navigationBarTitleDisplayMode(.inline)

        // =====================================================
        // REFRESH SUGGESTIONS
        // =====================================================

        .onAppear {

            viewModel.generateSuggestions()
        }
    }
}
