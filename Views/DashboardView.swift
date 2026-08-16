
import SwiftUI

// =====================================================
// VIEW: DashboardView
// =====================================================
// PURPOSE:
// Main intelligence dashboard for RecalllQ.
//
// FEATURES:
// - Welcome header
// - AI Memory Assistant
// - Learning statistics
// - Flashcard performance
// - Quiz performance
// - Memory progress
// - Personalized recommendations
// - Smart memory suggestions
// - Quick study actions
// - Navigation to Flashcards / Memories / Notes
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

        ScrollView(showsIndicators: false) {

            VStack(
                alignment: .leading,
                spacing: 22
            ) {

                // =================================================
                // WELCOME
                // =================================================

                welcomeHeader

                // =================================================
                // AI ASSISTANT
                // =================================================

                aiAssistantCard

                // =================================================
                // LEARNING OVERVIEW
                // =================================================

                sectionHeader(
                    title: "Learning Overview",
                    subtitle: "Your study activity at a glance",
                    icon: "chart.bar.fill"
                )

                learningStats

                // =================================================
                // TODAY'S PROGRESS
                // =================================================

                todayProgressCard

                // =================================================
                // STUDY PERFORMANCE
                // =================================================

                sectionHeader(
                    title: "Study Performance",
                    subtitle: "Track how well you are learning",
                    icon: "chart.line.uptrend.xyaxis"
                )

                flashcardPerformanceCard

                quizPerformanceCard

                memoryProgressCard

                // =================================================
                // RECOMMENDATIONS
                // =================================================

                sectionHeader(
                    title: "Recommended For You",
                    subtitle: "RecalllQ's personalized study suggestions",
                    icon: "sparkles"
                )

                recommendationsSection

                // =================================================
                // SMART SUGGESTIONS
                // =================================================

                sectionHeader(
                    title: "Smart Suggestions",
                    subtitle: "Memories that may need review",
                    icon: "lightbulb.fill"
                )

                smartSuggestionsSection

                // =================================================
                // QUICK ACTIONS
                // =================================================

                sectionHeader(
                    title: "Quick Actions",
                    subtitle: "Continue your learning",
                    icon: "bolt.fill"
                )

                quickActions

                Spacer(minLength: 30)
            }
            .padding(.horizontal, 18)
            .padding(.top, 12)
        }
        .background(
            RecalllQTheme.background
                .ignoresSafeArea()
        )
        .navigationTitle("Dashboard")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {

            memoryVM.generateSuggestions()

            appState.generateStudyRecommendations()
        }
    }

    // =====================================================
    // WELCOME HEADER
    // =====================================================

    private var welcomeHeader: some View {

        VStack(
            alignment: .leading,
            spacing: 8
        ) {

            HStack {

                VStack(
                    alignment: .leading,
                    spacing: 5
                ) {

                    Text("Welcome back 👋")
                        .font(.subheadline)
                        .foregroundColor(
                            RecalllQTheme.secondaryText
                        )

                    Text("Let's keep learning.")
                        .font(
                            .system(
                                size: 30,
                                weight: .bold
                            )
                        )
                        .foregroundColor(
                            RecalllQTheme.primaryText
                        )
                }

                Spacer()

                ZStack {

                    Circle()
                        .fill(
                            RecalllQTheme.blueBackground
                        )
                        .frame(
                            width: 52,
                            height: 52
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
            }

            Text(
                "Your intelligent study companion is ready."
            )
            .font(.subheadline)
            .foregroundColor(
                RecalllQTheme.secondaryText
            )
        }
    }

    // =====================================================
    // AI ASSISTANT CARD
    // =====================================================

    private var aiAssistantCard: some View {

        VStack(
            alignment: .leading,
            spacing: 16
        ) {

            HStack {

                ZStack {

                    RoundedRectangle(
                        cornerRadius: 16
                    )
                    .fill(
                        Color.white.opacity(0.18)
                    )
                    .frame(
                        width: 56,
                        height: 56
                    )

                    Image(
                        systemName:
                            "brain.head.profile"
                    )
                    .font(.title)
                    .foregroundColor(.white)
                }

                VStack(
                    alignment: .leading,
                    spacing: 5
                ) {

                    Text("AI Memory Assistant")
                        .font(.headline)
                        .foregroundColor(.white)

                    HStack(spacing: 6) {

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
                                .white.opacity(0.9)
                            )
                    }
                }

                Spacer()

                Image(
                    systemName:
                        "sparkles"
                )
                .font(.title3)
                .foregroundColor(
                    .white.opacity(0.9)
                )
            }

            Text(assistantMessage)
                .font(.subheadline)
                .foregroundColor(
                    .white.opacity(0.92)
                )
                .fixedSize(
                    horizontal: false,
                    vertical: true
                )

            HStack {

                Label(
                    "\(memoryVM.memories.count) Memories",
                    systemImage: "brain"
                )

                Spacer()

                Label(
                    "\(memoryVM.allTags.count) Topics",
                    systemImage: "tag"
                )
            }
            .font(.caption)
            .foregroundColor(
                .white.opacity(0.85)
            )
        }
        .padding(20)
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .background(
            LinearGradient(
                colors: [
                    RecalllQTheme.primary,
                    RecalllQTheme.primary.opacity(0.72)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(
            RoundedRectangle(
                cornerRadius: 24
            )
        )
        .shadow(
            color:
                RecalllQTheme.primary.opacity(0.20),
            radius: 12,
            x: 0,
            y: 6
        )
    }

    // =====================================================
    // AI MESSAGE
    // =====================================================

    private var assistantMessage: String {

        if memoryVM.memories.isEmpty {

            return
                "Create your first note and RecalllQ will transform it into an organized memory."
        }

        if flashcardVM.totalFlashcards == 0 {

            return
                "You have memories ready to study. Generate flashcards to start active recall."
        }

        if flashcardVM.reviewedFlashcards == 0 {

            return
                "Your flashcards are ready. Start reviewing them to build your learning accuracy."
        }

        if flashcardVM.overallAccuracy < 0.60 {

            return
                "Keep practicing your flashcards. Repetition will help strengthen your recall."
        }

        if flashcardVM.masteredFlashcards <
            flashcardVM.totalFlashcards {

            return
                "You're making progress! Continue reviewing difficult cards to improve mastery."
        }

        return
            "Excellent work! Your knowledge base and flashcard performance are looking strong."
    }

    // =====================================================
    // SECTION HEADER
    // =====================================================

    private func sectionHeader(
        title: String,
        subtitle: String,
        icon: String
    ) -> some View {

        HStack(
            alignment: .center,
            spacing: 12
        ) {

            ZStack {

                RoundedRectangle(
                    cornerRadius: 10
                )
                .fill(
                    RecalllQTheme.blueBackground
                )
                .frame(
                    width: 36,
                    height: 36
                )

                Image(
                    systemName: icon
                )
                .font(.subheadline)
                .foregroundColor(
                    RecalllQTheme.primary
                )
            }

            VStack(
                alignment: .leading,
                spacing: 2
            ) {

                Text(title)
                    .font(.title3)
                    .bold()
                    .foregroundColor(
                        RecalllQTheme.primaryText
                    )

                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(
                        RecalllQTheme.secondaryText
                    )
            }

            Spacer()
        }
    }

    // =====================================================
    // LEARNING STATS
    // =====================================================

    private var learningStats: some View {

        LazyVGrid(
            columns: [
                GridItem(
                    .flexible(),
                    spacing: 12
                ),

                GridItem(
                    .flexible(),
                    spacing: 12
                )
            ],
            spacing: 12
        ) {

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
    }

    // =====================================================
    // STAT CARD
    // =====================================================

    private func dashboardStatCard(
        title: String,
        value: String,
        icon: String,
        color: Color
    ) -> some View {

        VStack(
            alignment: .leading,
            spacing: 12
        ) {

            HStack {

                ZStack {

                    RoundedRectangle(
                        cornerRadius: 10
                    )
                    .fill(
                        color.opacity(0.12)
                    )
                    .frame(
                        width: 38,
                        height: 38
                    )

                    Image(
                        systemName: icon
                    )
                    .foregroundColor(color)
                }

                Spacer()
            }

            Text(value)
                .font(
                    .system(
                        size: 27,
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
        .padding(16)
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .background(
            RoundedRectangle(
                cornerRadius: 18
            )
            .fill(
                RecalllQTheme.cardBackground
            )
        )
        .overlay(
            RoundedRectangle(
                cornerRadius: 18
            )
            .stroke(
                Color.gray.opacity(0.08),
                lineWidth: 1
            )
        )
    }

    // =====================================================
    // TODAY PROGRESS
    // =====================================================

    private var todayProgressCard: some View {

        HStack(spacing: 14) {

            ZStack {

                Circle()
                    .fill(
                        RecalllQTheme.greenBackground
                    )
                    .frame(
                        width: 52,
                        height: 52
                    )

                Image(
                    systemName:
                        "flame.fill"
                )
                .foregroundColor(
                    RecalllQTheme.success
                )
                .font(.title3)
            }

            VStack(
                alignment: .leading,
                spacing: 4
            ) {

                Text("Keep your momentum")
                    .font(.headline)
                    .foregroundColor(
                        RecalllQTheme.primaryText
                    )

                Text(
                    "\(flashcardVM.reviewedFlashcards) flashcards reviewed so far"
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
            .font(
                .system(
                    size: 20,
                    weight: .bold
                )
            )
            .foregroundColor(
                RecalllQTheme.success
            )
        }
        .padding(16)
        .frame(
            maxWidth: .infinity
        )
        .background(
            RoundedRectangle(
                cornerRadius: 20
            )
            .fill(
                RecalllQTheme.greenBackground
            )
        )
    }

    // =====================================================
    // FLASHCARD PERFORMANCE
    // =====================================================

    private var flashcardPerformanceCard: some View {

        VStack(
            alignment: .leading,
            spacing: 14
        ) {

            HStack {

                VStack(
                    alignment: .leading,
                    spacing: 4
                ) {

                    Label(
                        "Flashcard Performance",
                        systemImage:
                            "rectangle.on.rectangle"
                    )
                    .font(.headline)
                    .foregroundColor(
                        RecalllQTheme.primaryText
                    )

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
                .font(
                    .system(
                        size: 24,
                        weight: .bold
                    )
                )
                .foregroundColor(
                    RecalllQTheme.primary
                )
            }

            ProgressView(
                value:
                    flashcardVM.overallAccuracy,
                total: 1
            )
            .tint(
                RecalllQTheme.primary
            )
            .scaleEffect(
                x: 1,
                y: 1.3
            )

            Text(flashcardPerformanceMessage)
                .font(.caption)
                .foregroundColor(
                    RecalllQTheme.secondaryText
                )
        }
        .padding(18)
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .background(
            RoundedRectangle(
                cornerRadius: 20
            )
            .fill(
                RecalllQTheme.blueBackground
            )
        )
    }

    // =====================================================
    // FLASHCARD MESSAGE
    // =====================================================

    private var flashcardPerformanceMessage: String {

        if flashcardVM.totalFlashcards == 0 {

            return
                "Generate flashcards from your memories to begin."
        }

        if flashcardVM.reviewedFlashcards == 0 {

            return
                "Start reviewing to measure your recall accuracy."
        }

        if flashcardVM.overallAccuracy >= 0.80 {

            return
                "Excellent recall! Keep reviewing to maintain your knowledge."
        }

        if flashcardVM.overallAccuracy >= 0.60 {

            return
                "Good progress. Keep practicing to improve your recall."
        }

        return
            "Review difficult cards more frequently to strengthen your memory."
    }

    // =====================================================
    // QUIZ PERFORMANCE
    // =====================================================

    private var quizPerformanceCard: some View {

        VStack(
            alignment: .leading,
            spacing: 14
        ) {

            HStack {

                VStack(
                    alignment: .leading,
                    spacing: 4
                ) {

                    Label(
                        "Quiz Performance",
                        systemImage:
                            "questionmark.circle.fill"
                    )
                    .font(.headline)
                    .foregroundColor(
                        RecalllQTheme.primaryText
                    )

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
                .font(
                    .system(
                        size: 24,
                        weight: .bold
                    )
                )
                .foregroundColor(
                    RecalllQTheme.studyOrange
                )
            }

            ProgressView(
                value:
                    quizVM.overallPercentage / 100,
                total: 1
            )
            .tint(
                RecalllQTheme.studyOrange
            )
            .scaleEffect(
                x: 1,
                y: 1.3
            )

            Text(quizPerformanceMessage)
                .font(.caption)
                .foregroundColor(
                    RecalllQTheme.secondaryText
                )
        }
        .padding(18)
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .background(
            RoundedRectangle(
                cornerRadius: 20
            )
            .fill(
                RecalllQTheme.orangeBackground
            )
        )
    }

    // =====================================================
    // QUIZ MESSAGE
    // =====================================================

    private var quizPerformanceMessage: String {

        if quizVM.totalQuizzes == 0 {

            return
                "Create a quiz from your knowledge to test yourself."
        }

        if quizVM.completedQuizzes == 0 {

            return
                "Complete your first quiz to see your performance."
        }

        if quizVM.overallPercentage >= 80 {

            return
                "Excellent quiz performance! Your knowledge is improving."
        }

        if quizVM.overallPercentage >= 60 {

            return
                "Good work. Continue testing yourself to strengthen recall."
        }

        return
            "Review your memories and try another quiz to improve your score."
    }

    // =====================================================
    // MEMORY PROGRESS
    // =====================================================

    private var memoryProgressCard: some View {

        let current =
            min(
                memoryVM.memories.count,
                memoryGoal
            )

        let progress =
            Double(current)
            / Double(memoryGoal)

        return VStack(
            alignment: .leading,
            spacing: 14
        ) {

            HStack {

                VStack(
                    alignment: .leading,
                    spacing: 4
                ) {

                    Label(
                        "Memory Progress",
                        systemImage:
                            "brain.head.profile"
                    )
                    .font(.headline)
                    .foregroundColor(
                        RecalllQTheme.primaryText
                    )

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
                    "\(current)/\(memoryGoal)"
                )
                .font(
                    .system(
                        size: 22,
                        weight: .bold
                    )
                )
                .foregroundColor(
                    RecalllQTheme.success
                )
            }

            ProgressView(
                value: progress,
                total: 1
            )
            .tint(
                RecalllQTheme.success
            )
            .scaleEffect(
                x: 1,
                y: 1.3
            )

            Text(
                memoryVM.memories.count >= memoryGoal
                ? "🎉 You reached your memory goal!"
                : "\(memoryGoal - memoryVM.memories.count) more memories to reach your goal."
            )
            .font(.caption)
            .foregroundColor(
                RecalllQTheme.secondaryText
            )
        }
        .padding(18)
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .background(
            RoundedRectangle(
                cornerRadius: 20
            )
            .fill(
                RecalllQTheme.greenBackground
            )
        )
    }

    // =====================================================
    // RECOMMENDATIONS
    // =====================================================

    private var recommendationsSection: some View {

        Group {

            if appState.studyRecommendations.isEmpty {

                emptyRecommendationCard

            } else {

                ForEach(
                    appState.studyRecommendations
                ) { recommendation in

                    StudyRecommendationCard(
                        recommendation:
                            recommendation
                    )
                    .environmentObject(
                        appState
                    )
                }
            }
        }
    }

    // =====================================================
    // EMPTY RECOMMENDATION
    // =====================================================

    private var emptyRecommendationCard: some View {

        VStack(spacing: 14) {

            ZStack {

                Circle()
                    .fill(
                        RecalllQTheme.orangeBackground
                    )
                    .frame(
                        width: 58,
                        height: 58
                    )

                Image(
                    systemName:
                        "sparkles"
                )
                .font(.title2)
                .foregroundColor(
                    RecalllQTheme.studyOrange
                )
            }

            Text(
                "Recommendations coming soon"
            )
            .font(.headline)
            .foregroundColor(
                RecalllQTheme.primaryText
            )

            Text(
                "Create memories and flashcards and RecalllQ will recommend what you should study next."
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
        .padding(22)
        .background(
            RoundedRectangle(
                cornerRadius: 20
            )
            .fill(
                RecalllQTheme.cardBackground
            )
        )
    }

    // =====================================================
    // SMART SUGGESTIONS
    // =====================================================

    private var smartSuggestionsSection: some View {

        Group {

            if memoryVM.suggestedMemories.isEmpty {

                VStack(spacing: 14) {

                    Image(
                        systemName:
                            "lightbulb.fill"
                    )
                    .font(.largeTitle)
                    .foregroundColor(
                        RecalllQTheme.studyOrange
                    )

                    Text(
                        "Suggestions coming soon"
                    )
                    .font(.headline)
                    .foregroundColor(
                        RecalllQTheme.primaryText
                    )

                    Text(
                        "Create a few memories and RecalllQ will start suggesting what to review."
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
                .padding(22)
                .background(
                    RoundedRectangle(
                        cornerRadius: 20
                    )
                    .fill(
                        RecalllQTheme.orangeBackground
                    )
                )

            } else {

                ForEach(
                    memoryVM.suggestedMemories
                ) { memory in

                    smartMemoryCard(
                        memory: memory
                    )
                }
            }
        }
    }

    // =====================================================
    // SMART MEMORY CARD
    // =====================================================
    // FIX:
    // The old version called:
    //
    // appState.openFlashcard(for: memory)
    //
    // But openFlashcard expects a Flashcard, not Memory.
    //
    // This version navigates to FlashcardsView instead.
    // =====================================================

    private func smartMemoryCard(
        memory: Memory
    ) -> some View {

        NavigationLink {

            FlashcardsView()
                .environmentObject(
                    appState
                )

        } label: {

            HStack(
                alignment: .top,
                spacing: 12
            ) {

                ZStack {

                    Circle()
                        .fill(
                            RecalllQTheme.orangeBackground
                        )
                        .frame(
                            width: 44,
                            height: 44
                        )

                    Image(
                        systemName:
                            "brain"
                    )
                    .foregroundColor(
                        RecalllQTheme.studyOrange
                    )
                }

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

                    Text(
                        "Suggested review"
                    )
                    .font(.caption)
                    .foregroundColor(
                        RecalllQTheme.studyOrange
                    )

                    Text(
                        memory.summary
                    )
                    .font(.caption)
                    .foregroundColor(
                        RecalllQTheme.secondaryText
                    )
                    .lineLimit(3)
                    .multilineTextAlignment(
                        .leading
                    )
                }

                Spacer()

                Image(
                    systemName:
                        "chevron.right"
                )
                .font(.caption)
                .foregroundColor(
                    RecalllQTheme.secondaryText
                )
            }
            .padding(16)
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )
            .background(
                RoundedRectangle(
                    cornerRadius: 18
                )
                .fill(
                    RecalllQTheme.cardBackground
                )
            )
            .overlay(
                RoundedRectangle(
                    cornerRadius: 18
                )
                .stroke(
                    RecalllQTheme.studyOrange.opacity(0.12),
                    lineWidth: 1
                )
            )
        }
        .buttonStyle(.plain)
    }

    // =====================================================
    // QUICK ACTIONS
    // =====================================================

    private var quickActions: some View {

        VStack(spacing: 12) {

            // -------------------------------------------------
            // START STUDY SESSION
            // -------------------------------------------------

            NavigationLink {

                StudySessionView()
                    .environmentObject(
                        appState
                    )

            } label: {

                actionCard(
                    title:
                        "Start Study Session",
                    subtitle:
                        "Focus and track your study progress",
                    icon:
                        "timer",
                    color:
                        RecalllQTheme.primary
                )
            }
            .buttonStyle(.plain)

            // -------------------------------------------------
            // FLASHCARDS
            // -------------------------------------------------

            NavigationLink {

                FlashcardsView()
                    .environmentObject(
                        appState
                    )

            } label: {

                actionCard(
                    title:
                        "Practice Flashcards",
                    subtitle:
                        "Review your knowledge with active recall",
                    icon:
                        "rectangle.on.rectangle",
                    color:
                        RecalllQTheme.studyOrange
                )
            }
            .buttonStyle(.plain)

            // -------------------------------------------------
            // CREATE NOTE
            // -------------------------------------------------

            NavigationLink {

                NotesView()
                    .environmentObject(
                        appState
                    )

            } label: {

                actionCard(
                    title:
                        "Create a Note",
                    subtitle:
                        "Capture something you want to remember",
                    icon:
                        "note.text",
                    color:
                        RecalllQTheme.secondary
                )
            }
            .buttonStyle(.plain)

            // -------------------------------------------------
            // EXPLORE MEMORIES
            // -------------------------------------------------

            NavigationLink {

                MemoriesView()
                    .environmentObject(
                        appState
                    )

            } label: {

                actionCard(
                    title:
                        "Explore Memories",
                    subtitle:
                        "Review your organized knowledge",
                    icon:
                        "brain.head.profile",
                    color:
                        RecalllQTheme.success
                )
            }
            .buttonStyle(.plain)
        }
    }

    // =====================================================
    // ACTION CARD
    // =====================================================

    private func actionCard(
        title: String,
        subtitle: String,
        icon: String,
        color: Color
    ) -> some View {

        HStack(spacing: 14) {

            ZStack {

                RoundedRectangle(
                    cornerRadius: 13
                )
                .fill(
                    Color.white.opacity(0.18)
                )
                .frame(
                    width: 48,
                    height: 48
                )

                Image(
                    systemName: icon
                )
                .font(.title3)
            }

            VStack(
                alignment: .leading,
                spacing: 3
            ) {

                Text(title)
                    .font(.headline)

                Text(subtitle)
                    .font(.caption)
                    .opacity(0.9)
                    .multilineTextAlignment(
                        .leading
                    )
            }

            Spacer()

            Image(
                systemName:
                    "arrow.up.right"
            )
            .font(.subheadline)
        }
        .padding(16)
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .foregroundColor(.white)
        .background(
            RoundedRectangle(
                cornerRadius: 20
            )
            .fill(color)
        )
        .shadow(
            color:
                color.opacity(0.15),
            radius: 8,
            x: 0,
            y: 4
        )
    }
}
