
import SwiftUI

// =====================================================
// VIEW: DashboardView
// =====================================================
// PURPOSE:
// Main intelligence dashboard for RecalllQ.
//
// UI/UX POLISH:
// - More lively colors
// - Modern gradients
// - Colorful statistic cards
// - Improved welcome header
// - Improved AI assistant card
// - Colorful progress cards
// - Modern quick actions
// - Keeps existing RecalllQ functionality
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
                spacing: 24
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
                    icon: "chart.bar.fill",
                    color: RecalllQTheme.primary,
                    background: RecalllQTheme.blueBackground
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
                    icon: "chart.line.uptrend.xyaxis",
                    color: RecalllQTheme.smartPurple,
                    background: RecalllQTheme.purpleBackground
                )

                flashcardPerformanceCard

                quizPerformanceCard

                memoryProgressCard

                // =================================================
                // RECOMMENDATIONS
                // =================================================

                sectionHeader(
                    title: "Recommended For You",
                    subtitle: "Personalized study suggestions",
                    icon: "sparkles",
                    color: RecalllQTheme.studyOrange,
                    background: RecalllQTheme.orangeBackground
                )

                recommendationsSection

                // =================================================
                // SMART SUGGESTIONS
                // =================================================

                sectionHeader(
                    title: "Smart Suggestions",
                    subtitle: "Memories that may need review",
                    icon: "lightbulb.fill",
                    color: RecalllQTheme.smartPurple,
                    background: RecalllQTheme.purpleBackground
                )

                smartSuggestionsSection

                // =================================================
                // QUICK ACTIONS
                // =================================================

                sectionHeader(
                    title: "Quick Actions",
                    subtitle: "Continue your learning",
                    icon: "bolt.fill",
                    color: RecalllQTheme.success,
                    background: RecalllQTheme.greenBackground
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
            spacing: 14
        ) {

            HStack {

                VStack(
                    alignment: .leading,
                    spacing: 6
                ) {

                    Text("Welcome back 👋")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(
                            RecalllQTheme.secondary
                        )

                    Text("Let's keep learning.")
                        .font(
                            .system(
                                size: 32,
                                weight: .bold
                            )
                        )
                        .foregroundColor(
                            RecalllQTheme.primaryText
                        )

                    Text(
                        "Your intelligent study companion is ready."
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

                Spacer()

                ZStack {

                    Circle()
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
                            width: 64,
                            height: 64
                        )
                        .shadow(
                            color:
                                RecalllQTheme.primary.opacity(0.25),
                            radius: 10,
                            x: 0,
                            y: 5
                        )

                    Image(
                        systemName:
                            "brain.head.profile"
                    )
                    .font(
                        .system(size: 28)
                    )
                    .foregroundColor(.white)

                    Image(
                        systemName: "sparkles"
                    )
                    .font(.caption)
                    .foregroundColor(.white)
                    .offset(
                        x: 23,
                        y: -23
                    )
                }
            }
        }
    }

    // =====================================================
    // AI ASSISTANT CARD
    // =====================================================

    private var aiAssistantCard: some View {

        VStack(
            alignment: .leading,
            spacing: 18
        ) {

            HStack {

                ZStack {

                    RoundedRectangle(
                        cornerRadius: 17
                    )
                    .fill(
                        Color.white.opacity(0.20)
                    )
                    .frame(
                        width: 58,
                        height: 58
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
                        .fontWeight(.bold)
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
                                .white.opacity(0.92)
                            )
                    }
                }

                Spacer()

                ZStack {

                    Circle()
                        .fill(
                            Color.white.opacity(0.15)
                        )
                        .frame(
                            width: 38,
                            height: 38
                        )

                    Image(
                        systemName: "sparkles"
                    )
                    .font(.headline)
                    .foregroundColor(.white)
                }
            }

            Text(assistantMessage)
                .font(.subheadline)
                .foregroundColor(
                    .white.opacity(0.94)
                )
                .fixedSize(
                    horizontal: false,
                    vertical: true
                )
                .lineSpacing(3)

            Divider()
                .background(
                    Color.white.opacity(0.25)
                )

            HStack {

                Label(
                    "\(memoryVM.memories.count) Memories",
                    systemImage: "brain"
                )

                Spacer()

                Label(
                    "\(memoryVM.allTags.count) Topics",
                    systemImage: "tag.fill"
                )
            }
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(
                .white.opacity(0.90)
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
                    RecalllQTheme.smartPurple,
                    RecalllQTheme.secondary
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(
            RoundedRectangle(
                cornerRadius: 26
            )
        )
        .shadow(
            color:
                RecalllQTheme.primary.opacity(0.25),
            radius: 14,
            x: 0,
            y: 7
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
        icon: String,
        color: Color,
        background: Color
    ) -> some View {

        HStack(
            alignment: .center,
            spacing: 12
        ) {

            ZStack {

                RoundedRectangle(
                    cornerRadius: 11
                )
                .fill(background)
                .frame(
                    width: 40,
                    height: 40
                )

                Image(
                    systemName: icon
                )
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(color)
            }

            VStack(
                alignment: .leading,
                spacing: 3
            ) {

                Text(title)
                    .font(.title3)
                    .fontWeight(.bold)
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
                    RecalllQTheme.primary,
                background:
                    RecalllQTheme.blueBackground
            )

            dashboardStatCard(
                title: "Flashcards",
                value:
                    "\(flashcardVM.totalFlashcards)",
                icon:
                    "rectangle.on.rectangle",
                color:
                    RecalllQTheme.studyOrange,
                background:
                    RecalllQTheme.orangeBackground
            )

            dashboardStatCard(
                title: "Mastered",
                value:
                    "\(flashcardVM.masteredFlashcards)",
                icon:
                    "checkmark.circle.fill",
                color:
                    RecalllQTheme.success,
                background:
                    RecalllQTheme.greenBackground
            )

            dashboardStatCard(
                title: "Quizzes",
                value:
                    "\(quizVM.totalQuizzes)",
                icon:
                    "questionmark.circle.fill",
                color:
                    RecalllQTheme.secondary,
                background:
                    RecalllQTheme.purpleBackground
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
        color: Color,
        background: Color
    ) -> some View {

        VStack(
            alignment: .leading,
            spacing: 12
        ) {

            HStack {

                ZStack {

                    RoundedRectangle(
                        cornerRadius: 12
                    )
                    .fill(background)
                    .frame(
                        width: 42,
                        height: 42
                    )

                    Image(
                        systemName: icon
                    )
                    .font(.headline)
                    .foregroundColor(color)
                }

                Spacer()

                Image(
                    systemName:
                        "arrow.up.right"
                )
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(
                    color.opacity(0.65)
                )
            }

            Text(value)
                .font(
                    .system(
                        size: 29,
                        weight: .bold
                    )
                )
                .foregroundColor(
                    RecalllQTheme.primaryText
                )

            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(
                    RecalllQTheme.secondaryText
                )
        }
        .padding(16)
        .frame(
            maxWidth: .infinity,
            minHeight: 130,
            alignment: .leading
        )
        .background(
            RoundedRectangle(
                cornerRadius: 19
            )
            .fill(
                RecalllQTheme.cardBackground
            )
        )
        .overlay(
            RoundedRectangle(
                cornerRadius: 19
            )
            .stroke(
                color.opacity(0.12),
                lineWidth: 1
            )
        )
        .shadow(
            color:
                Color.black.opacity(0.04),
            radius: 7,
            x: 0,
            y: 3
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
                        width: 54,
                        height: 54
                    )

                Image(
                    systemName:
                        "flame.fill"
                )
                .foregroundColor(
                    RecalllQTheme.studyOrange
                )
                .font(.title3)
            }

            VStack(
                alignment: .leading,
                spacing: 4
            ) {

                Text("Keep your momentum")
                    .font(.headline)
                    .fontWeight(.bold)
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

            VStack(
                alignment: .trailing,
                spacing: 2
            ) {

                Text(
                    "\(Int(flashcardVM.overallAccuracy * 100))%"
                )
                .font(
                    .system(
                        size: 21,
                        weight: .bold
                    )
                )
                .foregroundColor(
                    RecalllQTheme.success
                )

                Text("accuracy")
                    .font(.caption2)
                    .foregroundColor(
                        RecalllQTheme.secondaryText
                    )
            }
        }
        .padding(16)
        .frame(
            maxWidth: .infinity
        )
        .background(
            LinearGradient(
                colors: [
                    RecalllQTheme.greenBackground,
                    RecalllQTheme.blueBackground
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .clipShape(
            RoundedRectangle(
                cornerRadius: 20
            )
        )
        .overlay(
            RoundedRectangle(
                cornerRadius: 20
            )
            .stroke(
                RecalllQTheme.success.opacity(0.12),
                lineWidth: 1
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
                    .fontWeight(.bold)
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
                y: 1.4
            )

            Text(flashcardPerformanceMessage)
                .font(.caption)
                .foregroundColor(
                    RecalllQTheme.secondaryText
                )
                .fixedSize(
                    horizontal: false,
                    vertical: true
                )
        }
        .padding(18)
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .background(
            LinearGradient(
                colors: [
                    RecalllQTheme.blueBackground,
                    RecalllQTheme.purpleBackground
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(
            RoundedRectangle(
                cornerRadius: 21
            )
        )
        .overlay(
            RoundedRectangle(
                cornerRadius: 21
            )
            .stroke(
                RecalllQTheme.primary.opacity(0.12),
                lineWidth: 1
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
                    .fontWeight(.bold)
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
                y: 1.4
            )

            Text(quizPerformanceMessage)
                .font(.caption)
                .foregroundColor(
                    RecalllQTheme.secondaryText
                )
                .fixedSize(
                    horizontal: false,
                    vertical: true
                )
        }
        .padding(18)
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .background(
            LinearGradient(
                colors: [
                    RecalllQTheme.orangeBackground,
                    RecalllQTheme.redBackground
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(
            RoundedRectangle(
                cornerRadius: 21
            )
        )
        .overlay(
            RoundedRectangle(
                cornerRadius: 21
            )
            .stroke(
                RecalllQTheme.studyOrange.opacity(0.12),
                lineWidth: 1
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
                    .fontWeight(.bold)
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
                y: 1.4
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
            LinearGradient(
                colors: [
                    RecalllQTheme.greenBackground,
                    RecalllQTheme.blueBackground
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(
            RoundedRectangle(
                cornerRadius: 21
            )
        )
        .overlay(
            RoundedRectangle(
                cornerRadius: 21
            )
            .stroke(
                RecalllQTheme.success.opacity(0.12),
                lineWidth: 1
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
                        width: 62,
                        height: 62
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
            .fontWeight(.bold)
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
        .padding(24)
        .background(
            RoundedRectangle(
                cornerRadius: 21
            )
            .fill(
                RecalllQTheme.cardBackground
            )
        )
        .overlay(
            RoundedRectangle(
                cornerRadius: 21
            )
            .stroke(
                RecalllQTheme.studyOrange.opacity(0.12),
                lineWidth: 1
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

                    ZStack {

                        Circle()
                            .fill(
                                RecalllQTheme.purpleBackground
                            )
                            .frame(
                                width: 62,
                                height: 62
                            )

                        Image(
                            systemName:
                                "lightbulb.fill"
                        )
                        .font(.title2)
                        .foregroundColor(
                            RecalllQTheme.smartPurple
                        )
                    }

                    Text(
                        "Suggestions coming soon"
                    )
                    .font(.headline)
                    .fontWeight(.bold)
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
                .padding(24)
                .background(
                    RoundedRectangle(
                        cornerRadius: 21
                    )
                    .fill(
                        RecalllQTheme.purpleBackground
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
    // IMPORTANT:
    // We intentionally navigate to FlashcardsView.
    //
    // We DO NOT call:
    //
    // appState.openFlashcard(for: memory)
    //
    // because openFlashcard expects a Flashcard,
    // while this object is a Memory.
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
                            RecalllQTheme.purpleBackground
                        )
                        .frame(
                            width: 46,
                            height: 46
                        )

                    Image(
                        systemName:
                            "brain"
                    )
                    .foregroundColor(
                        RecalllQTheme.smartPurple
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
                    .fontWeight(.bold)
                    .foregroundColor(
                        RecalllQTheme.primaryText
                    )

                    Text(
                        "Suggested review"
                    )
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(
                        RecalllQTheme.smartPurple
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

                ZStack {

                    Circle()
                        .fill(
                            RecalllQTheme.purpleBackground
                        )
                        .frame(
                            width: 30,
                            height: 30
                        )

                    Image(
                        systemName:
                            "chevron.right"
                    )
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(
                        RecalllQTheme.smartPurple
                    )
                }
            }
            .padding(16)
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )
            .background(
                RoundedRectangle(
                    cornerRadius: 19
                )
                .fill(
                    RecalllQTheme.cardBackground
                )
            )
            .overlay(
                RoundedRectangle(
                    cornerRadius: 19
                )
                .stroke(
                    RecalllQTheme.smartPurple.opacity(0.15),
                    lineWidth: 1
                )
            )
            .shadow(
                color:
                    Color.black.opacity(0.035),
                radius: 6,
                x: 0,
                y: 3
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
                        RecalllQTheme.primary,
                    gradientEnd:
                        RecalllQTheme.smartPurple
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
                        RecalllQTheme.studyOrange,
                    gradientEnd:
                        RecalllQTheme.warning
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
                        RecalllQTheme.secondary,
                    gradientEnd:
                        RecalllQTheme.smartPurple
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
                        RecalllQTheme.success,
                    gradientEnd:
                        RecalllQTheme.primary
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
        color: Color,
        gradientEnd: Color
    ) -> some View {

        HStack(spacing: 14) {

            ZStack {

                RoundedRectangle(
                    cornerRadius: 14
                )
                .fill(
                    Color.white.opacity(0.20)
                )
                .frame(
                    width: 50,
                    height: 50
                )

                Image(
                    systemName: icon
                )
                .font(.title3)
                .foregroundColor(.white)
            }

            VStack(
                alignment: .leading,
                spacing: 4
            ) {

                Text(title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(
                        .white.opacity(0.90)
                    )
                    .multilineTextAlignment(
                        .leading
                    )
            }

            Spacer()

            ZStack {

                Circle()
                    .fill(
                        Color.white.opacity(0.16)
                    )
                    .frame(
                        width: 32,
                        height: 32
                    )

                Image(
                    systemName:
                        "arrow.up.right"
                )
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
            }
        }
        .padding(16)
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .background(
            LinearGradient(
                colors: [
                    color,
                    gradientEnd
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .clipShape(
            RoundedRectangle(
                cornerRadius: 21
            )
        )
        .shadow(
            color:
                color.opacity(0.20),
            radius: 9,
            x: 0,
            y: 5
        )
    }
}
