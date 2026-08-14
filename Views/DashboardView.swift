
import SwiftUI

// =====================================================
// VIEW: DashboardView
// =====================================================
// PURPOSE:
// Main dashboard screen for RecalllQ.
//
// FEATURES:
// - Welcome section
// - AI Memory Assistant
// - Live learning statistics
// - Memory progress
// - Flashcard progress
// - Quiz progress
// - Smart suggestions
// - Quick learning actions
// =====================================================

struct DashboardView: View {

    // =====================================================
    // GLOBAL APP STATE
    // =====================================================

    @EnvironmentObject var appState: AppState

    // =====================================================
    // VIEW MODELS
    // =====================================================

    private var memoryVM: MemoryViewModel {
        appState.memoryViewModel
    }

    private var flashcardVM: FlashcardViewModel {
        appState.flashcardViewModel
    }

    private var quizVM: QuizViewModel {
        appState.quizViewModel
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

            VStack(
                alignment: .leading,
                spacing: 24
            ) {

                // =====================================================
                // WELCOME HEADER
                // =====================================================

                VStack(
                    alignment: .leading,
                    spacing: 6
                ) {

                    Text("Welcome back 👋")
                        .font(.subheadline)
                        .foregroundColor(
                            RecalllQTheme.secondaryText
                        )

                    Text("RecalllQ")
                        .font(
                            .system(
                                size: 34,
                                weight: .bold
                            )
                        )
                        .foregroundColor(
                            RecalllQTheme.primary
                        )

                    Text(
                        "Your intelligent study companion"
                    )
                    .font(.subheadline)
                    .foregroundColor(
                        RecalllQTheme.secondaryText
                    )
                }

                // =====================================================
                // AI MEMORY ASSISTANT
                // =====================================================

                VStack(
                    alignment: .leading,
                    spacing: 14
                ) {

                    HStack {

                        ZStack {

                            Circle()
                                .fill(
                                    RecalllQTheme.primary
                                        .opacity(0.15)
                                )
                                .frame(
                                    width: 50,
                                    height: 50
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

                            Text(
                                "AI Memory Assistant"
                            )
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
                        memoryVM.memories.isEmpty
                        ? "Create your first note and RecalllQ will organize it into a structured memory."
                        : "RecalllQ is tracking \(memoryVM.memories.count) memories across \(memoryVM.allTags.count) study categories."
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
                // MEMORY + FLASHCARD
                // =====================================================

                HStack(spacing: 12) {

                    dashboardStatCard(
                        title: "Memories",
                        value:
                            "\(memoryVM.memories.count)",
                        icon:
                            "brain.head.profile",
                        color:
                            RecalllQTheme.primary
                    )

                    dashboardStatCard(
                        title: "Flashcards",
                        value:
                            "\(flashcardVM.totalFlashcards)",
                        icon:
                            "rectangle.on.rectangle",
                        color:
                            RecalllQTheme.studyOrange
                    )
                }

                // =====================================================
                // MASTERED + QUIZZES
                // =====================================================

                HStack(spacing: 12) {

                    dashboardStatCard(
                        title: "Mastered",
                        value:
                            "\(flashcardVM.masteredFlashcards)",
                        icon:
                            "checkmark.circle.fill",
                        color:
                            RecalllQTheme.success
                    )

                    dashboardStatCard(
                        title: "Quizzes",
                        value:
                            "\(quizVM.totalQuizzes)",
                        icon:
                            "questionmark.circle.fill",
                        color:
                            RecalllQTheme.secondary
                    )
                }

                // =====================================================
                // FLASHCARD PERFORMANCE
                // =====================================================

                VStack(
                    alignment: .leading,
                    spacing: 14
                ) {

                    HStack {

                        VStack(
                            alignment: .leading,
                            spacing: 4
                        ) {

                            Text("Flashcard Performance")
                                .font(.headline)

                            Text(
                                "\(flashcardVM.reviewedFlashcards) cards reviewed"
                            )
                            .font(.caption)
                            .foregroundColor(
                                RecalllQTheme.secondaryText
                            )
                        }

                        Spacer()

                        Text(
                            "\(Int(flashcardVM.overallAccuracy * 100))%"
                        )
                        .font(.headline)
                        .bold()
                        .foregroundColor(
                            RecalllQTheme.primary
                        )
                    }

                    ProgressView(
                        value:
                            flashcardVM.overallAccuracy,
                        total: 1.0
                    )
                    .tint(
                        RecalllQTheme.primary
                    )

                    Text(
                        flashcardVM.totalFlashcards == 0
                        ? "Generate flashcards from your Memories to start studying."
                        : flashcardVM.reviewedFlashcards == 0
                        ? "Start reviewing your flashcards to build your accuracy."
                        : "Keep practicing to improve your recall."
                    )
                    .font(.caption)
                    .foregroundColor(
                        RecalllQTheme.secondaryText
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
                        RecalllQTheme.blueBackground
                    )
                )

                // =====================================================
                // QUIZ PERFORMANCE
                // =====================================================

                VStack(
                    alignment: .leading,
                    spacing: 14
                ) {

                    HStack {

                        VStack(
                            alignment: .leading,
                            spacing: 4
                        ) {

                            Text("Quiz Performance")
                                .font(.headline)

                            Text(
                                "\(quizVM.completedQuizzes) of \(quizVM.totalQuizzes) quizzes completed"
                            )
                            .font(.caption)
                            .foregroundColor(
                                RecalllQTheme.secondaryText
                            )
                        }

                        Spacer()

                        Text(
                            "\(Int(quizVM.overallPercentage))%"
                        )
                        .font(.headline)
                        .bold()
                        .foregroundColor(
                            RecalllQTheme.studyOrange
                        )
                    }

                    ProgressView(
                        value:
                            quizVM.overallPercentage / 100,
                        total: 1.0
                    )
                    .tint(
                        RecalllQTheme.studyOrange
                    )

                    Text(
                        quizVM.totalQuizzes == 0
                        ? "Create a quiz from your Memories to test your knowledge."
                        : quizVM.completedQuizzes == 0
                        ? "Complete a quiz to see your score here."
                        : "Great work! Keep testing your knowledge."
                    )
                    .font(.caption)
                    .foregroundColor(
                        RecalllQTheme.secondaryText
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
                        RecalllQTheme.orangeBackground
                    )
                )

                // =====================================================
                // MEMORY PROGRESS
                // =====================================================

                VStack(
                    alignment: .leading,
                    spacing: 14
                ) {

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
                            "\(min(memoryVM.memories.count, memoryGoal))/\(memoryGoal)"
                        )
                        .font(.headline)
                        .bold()
                        .foregroundColor(
                            RecalllQTheme.primary
                        )
                    }

                    ProgressView(
                        value:
                            Double(
                                min(
                                    memoryVM.memories.count,
                                    memoryGoal
                                )
                            ),
                        total:
                            Double(memoryGoal)
                    )
                    .tint(
                        RecalllQTheme.primary
                    )

                    Text(
                        memoryVM.memories.count >= memoryGoal
                        ? "🎉 Great job! You reached your memory goal."
                        : "\(memoryGoal - memoryVM.memories.count) more memories to reach your goal."
                    )
                    .font(.caption)
                    .foregroundColor(
                        RecalllQTheme.secondaryText
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
                        RecalllQTheme.greenBackground
                    )
                )

                // =====================================================
                // SMART SUGGESTIONS
                // =====================================================

                HStack {

                    Text("Smart Suggestions")
                        .font(.title3)
                        .bold()

                    Spacer()

                    Image(
                        systemName:
                            "sparkles"
                    )
                    .foregroundColor(
                        RecalllQTheme.studyOrange
                    )
                }

                if memoryVM.suggestedMemories.isEmpty {

                    VStack(spacing: 12) {

                        Image(
                            systemName:
                                "lightbulb"
                        )
                        .font(.largeTitle)
                        .foregroundColor(
                            RecalllQTheme.studyOrange
                        )

                        Text(
                            "Suggestions coming soon"
                        )
                        .font(.headline)

                        Text(
                            "Create a few memories and RecalllQ will start showing useful study suggestions."
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
                        memoryVM.suggestedMemories
                    ) { memory in

                        VStack(
                            alignment: .leading,
                            spacing: 8
                        ) {

                            HStack {

                                Image(
                                    systemName:
                                        "brain"
                                )
                                .foregroundColor(
                                    RecalllQTheme.studyOrange
                                )

                                Text(
                                    memory.title
                                )
                                .font(.headline)

                                Spacer()
                            }

                            Text(
                                memory.summary
                            )
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
                    destination:
                        NotesView()
                        .environmentObject(
                            appState
                        )
                ) {

                    HStack(spacing: 14) {

                        ZStack {

                            Circle()
                                .fill(
                                    Color.white
                                        .opacity(0.18)
                                )
                                .frame(
                                    width: 44,
                                    height: 44
                                )

                            Image(
                                systemName:
                                    "note.text"
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
                            systemName:
                                "chevron.right"
                        )
                    }
                    .padding()
                    .frame(
                        maxWidth: .infinity
                    )
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
                    destination:
                        MemoriesView()
                        .environmentObject(
                            appState
                        )
                ) {

                    HStack(spacing: 14) {

                        ZStack {

                            Circle()
                                .fill(
                                    Color.white
                                        .opacity(0.18)
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

                            Text(
                                "Explore Memories"
                            )
                            .font(.headline)

                            Text(
                                "Review your organized knowledge"
                            )
                            .font(.caption)
                            .opacity(0.9)
                        }

                        Spacer()

                        Image(
                            systemName:
                                "chevron.right"
                        )
                    }
                    .padding()
                    .frame(
                        maxWidth: .infinity
                    )
                    .foregroundColor(.white)
                    .background(
                        RoundedRectangle(
                            cornerRadius:
                                RecalllQTheme.mediumRadius
                        )
                        .fill(
                            RecalllQTheme.studyOrange
                        )
                    )
                }
            }
            .padding()
        }

        // =====================================================
        // NAVIGATION
        // =====================================================

        .navigationTitle("Dashboard")
        .navigationBarTitleDisplayMode(
            .inline
        )

        // =====================================================
        // REFRESH SUGGESTIONS
        // =====================================================

        .onAppear {

            memoryVM.generateSuggestions()
        }
    }

    // =====================================================
    // DASHBOARD STAT CARD
    // =====================================================

    @ViewBuilder
    private func dashboardStatCard(
        title: String,
        value: String,
        icon: String,
        color: Color
    ) -> some View {

        VStack(
            spacing: 8
        ) {

            Image(
                systemName: icon
            )
            .font(.title3)
            .foregroundColor(color)

            Text(value)
                .font(.title2)
                .bold()

            Text(title)
                .font(.caption)
                .foregroundColor(
                    RecalllQTheme.secondaryText
                )
        }
        .frame(
            maxWidth: .infinity
        )
        .padding(.vertical, 16)
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
}

