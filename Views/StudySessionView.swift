
import SwiftUI

// =====================================================
// VIEW: StudySessionView
// =====================================================
// PURPOSE:
// Provides the user with a polished personalized
// study session experience.
//
// FEATURES:
// - Start study session
// - End study session
// - Cancel study session
// - Live timer
// - Current session statistics
// - Today's study time
// - Total study time
// - Session history
// - Flashcard / Memory / Quiz tracking
// - RecalllQ branded UI/UX
// =====================================================

struct StudySessionView: View {

    // =====================================================
    // APP STATE
    // =====================================================

    @EnvironmentObject var appState: AppState

    // =====================================================
    // VIEW MODEL
    // =====================================================

    private var studyVM: StudySessionViewModel {
        appState.studySessionViewModel
    }

    // =====================================================
    // BODY
    // =====================================================

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(
                alignment: .leading,
                spacing: 24
            ) {

                // Header
                header

                // Main study session
                currentSessionCard

                // Statistics
                statisticsSection

                // Recent activity
                recentActivitySection

                Spacer(minLength: 20)
            }
            .padding(.horizontal, 18)
            .padding(.top, 12)
            .padding(.bottom, 30)
        }
        .background(
            RecalllQTheme.background
                .ignoresSafeArea()
        )
        .navigationTitle("Study Session")
        .navigationBarTitleDisplayMode(.inline)
    }

    // =====================================================
    // HEADER
    // =====================================================

    private var header: some View {
        HStack(spacing: 16) {

            VStack(
                alignment: .leading,
                spacing: 6
            ) {
                Text("Study Session")
                    .font(
                        .system(
                            size: 30,
                            weight: .bold
                        )
                    )
                    .foregroundColor(
                        RecalllQTheme.primaryText
                    )

                Text(
                    studyVM.isStudying
                    ? "Stay focused and build your learning momentum."
                    : "Focus on learning while RecalllQ tracks your progress."
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
                        studyVM.isStudying
                        ? RecalllQTheme.greenBackground
                        : RecalllQTheme.blueBackground
                    )
                    .frame(
                        width: 56,
                        height: 56
                    )

                Image(
                    systemName:
                        studyVM.isStudying
                        ? "brain.head.profile"
                        : "book.closed.fill"
                )
                .font(.title2)
                .foregroundColor(
                    studyVM.isStudying
                    ? RecalllQTheme.success
                    : RecalllQTheme.primary
                )

                if studyVM.isStudying {
                    Circle()
                        .stroke(
                            RecalllQTheme.success.opacity(0.35),
                            lineWidth: 2
                        )
                        .frame(
                            width: 64,
                            height: 64
                        )
                }
            }
        }
    }

    // =====================================================
    // CURRENT SESSION CARD
    // =====================================================

    private var currentSessionCard: some View {
        VStack(spacing: 20) {

            // =================================================
            // SESSION STATUS
            // =================================================

            HStack {
                HStack(spacing: 8) {

                    Circle()
                        .fill(
                            studyVM.isStudying
                            ? RecalllQTheme.success
                            : RecalllQTheme.primary
                        )
                        .frame(
                            width: 9,
                            height: 9
                        )

                    Text(
                        studyVM.isStudying
                        ? "SESSION ACTIVE"
                        : "READY TO STUDY"
                    )
                    .font(.caption)
                    .fontWeight(.bold)
                    .tracking(1.1)
                    .foregroundColor(
                        studyVM.isStudying
                        ? RecalllQTheme.success
                        : RecalllQTheme.primary
                    )
                }

                Spacer()

                Image(
                    systemName:
                        studyVM.isStudying
                        ? "sparkles"
                        : "book.fill"
                )
                .font(.caption)
                .foregroundColor(
                    studyVM.isStudying
                    ? RecalllQTheme.smartPurple
                    : RecalllQTheme.primary
                )
            }

            // =================================================
            // MAIN ICON
            // =================================================

            ZStack {

                Circle()
                    .fill(
                        LinearGradient(
                            colors: studyVM.isStudying
                                ? [
                                    RecalllQTheme.greenBackground,
                                    RecalllQTheme.blueBackground
                                ]
                                : [
                                    RecalllQTheme.blueBackground,
                                    RecalllQTheme.purpleBackground
                                ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(
                        width: 104,
                        height: 104
                    )

                Circle()
                    .stroke(
                        studyVM.isStudying
                        ? RecalllQTheme.success.opacity(0.22)
                        : RecalllQTheme.primary.opacity(0.16),
                        lineWidth: 2
                    )
                    .frame(
                        width: 116,
                        height: 116
                    )

                Image(
                    systemName:
                        studyVM.isStudying
                        ? "brain.head.profile"
                        : "book.closed.fill"
                )
                .font(
                    .system(size: 42)
                )
                .foregroundColor(
                    studyVM.isStudying
                    ? RecalllQTheme.success
                    : RecalllQTheme.primary
                )
            }
            .padding(.top, 4)

            // =================================================
            // TITLE
            // =================================================

            VStack(spacing: 6) {

                Text(
                    studyVM.isStudying
                    ? "Keep Going!"
                    : "Ready to Learn?"
                )
                .font(
                    .system(
                        size: 25,
                        weight: .bold
                    )
                )
                .foregroundColor(
                    RecalllQTheme.primaryText
                )

                Text(
                    studyVM.isStudying
                    ? "You're building stronger recall with every minute."
                    : "Start a focused session and let RecalllQ track your learning."
                )
                .font(.subheadline)
                .foregroundColor(
                    RecalllQTheme.secondaryText
                )
                .multilineTextAlignment(.center)
                .fixedSize(
                    horizontal: false,
                    vertical: true
                )
            }

            // =================================================
            // TIMER
            // =================================================

            VStack(spacing: 5) {

                Text(
                    studyVM.isStudying
                    ? studyVM.formattedActiveSessionTime
                    : "00:00"
                )
                .font(
                    .system(
                        size: 48,
                        weight: .bold,
                        design: .monospaced
                    )
                )
                .foregroundColor(
                    studyVM.isStudying
                    ? RecalllQTheme.primary
                    : RecalllQTheme.secondaryText
                )
                .minimumScaleFactor(0.7)
                .animation(
                    .none,
                    value:
                        studyVM.formattedActiveSessionTime
                )

                Text(
                    studyVM.isStudying
                    ? "SESSION TIME"
                    : "READY"
                )
                .font(.caption2)
                .fontWeight(.bold)
                .tracking(1)
                .foregroundColor(
                    RecalllQTheme.secondaryText
                )
            }

            // =================================================
            // ACTIVE SESSION STATISTICS
            // =================================================

            if let session = studyVM.activeSession {

                HStack(spacing: 10) {

                    sessionStat(
                        value:
                            "\(session.flashcardsReviewed)",
                        title: "Flashcards",
                        icon:
                            "rectangle.on.rectangle"
                    )

                    sessionStat(
                        value:
                            "\(session.memoriesStudied)",
                        title: "Memories",
                        icon:
                            "brain.head.profile"
                    )

                    sessionStat(
                        value:
                            "\(session.quizzesCompleted)",
                        title: "Quizzes",
                        icon:
                            "questionmark.circle.fill"
                    )
                }
            }

            // =================================================
            // ACTIONS
            // =================================================

            if studyVM.isStudying {

                Button {
                    appState.endStudySession()
                } label: {
                    HStack(spacing: 12) {

                        Image(
                            systemName: "stop.fill"
                        )

                        Text("End Study Session")
                            .fontWeight(.bold)

                        Spacer()

                        Image(
                            systemName: "checkmark"
                        )
                    }
                    .padding(.horizontal, 18)
                    .frame(
                        maxWidth: .infinity,
                        minHeight: 54
                    )
                    .foregroundColor(.white)
                    .background(
                        LinearGradient(
                            colors: [
                                RecalllQTheme.studyOrange,
                                RecalllQTheme.error
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius:
                                RecalllQTheme.buttonRadius
                        )
                    )
                    .shadow(
                        color:
                            RecalllQTheme.studyOrange.opacity(0.20),
                        radius: 8,
                        x: 0,
                        y: 4
                    )
                }
                .buttonStyle(.plain)

                Button {
                    appState.cancelStudySession()
                } label: {
                    Text("Cancel Session")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(
                            RecalllQTheme.secondaryText
                        )
                        .frame(
                            maxWidth: .infinity
                        )
                        .padding(.vertical, 5)
                }
                .buttonStyle(.plain)

            } else {

                Button {
                    appState.startStudySession()
                } label: {
                    HStack(spacing: 12) {

                        Image(
                            systemName: "play.fill"
                        )

                        Text("Start Study Session")
                            .fontWeight(.bold)

                        Spacer()

                        Image(
                            systemName: "arrow.right"
                        )
                    }
                    .padding(.horizontal, 18)
                    .frame(
                        maxWidth: .infinity,
                        minHeight: 54
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
                                RecalllQTheme.buttonRadius
                        )
                    )
                    .shadow(
                        color:
                            RecalllQTheme.primary.opacity(0.22),
                        radius: 9,
                        x: 0,
                        y: 5
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(22)
        .frame(
            maxWidth: .infinity
        )
        .background(
            RoundedRectangle(
                cornerRadius:
                    RecalllQTheme.largeRadius
            )
            .fill(
                LinearGradient(
                    colors:
                        studyVM.isStudying
                        ? [
                            RecalllQTheme.greenBackground,
                            RecalllQTheme.blueBackground
                        ]
                        : [
                            RecalllQTheme.blueBackground,
                            RecalllQTheme.purpleBackground
                        ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        )
        .overlay(
            RoundedRectangle(
                cornerRadius:
                    RecalllQTheme.largeRadius
            )
            .stroke(
                studyVM.isStudying
                ? RecalllQTheme.success.opacity(0.18)
                : RecalllQTheme.primary.opacity(0.12),
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
    // SESSION STAT
    // =====================================================

    @ViewBuilder
    private func sessionStat(
        value: String,
        title: String,
        icon: String
    ) -> some View {

        VStack(spacing: 6) {

            Image(
                systemName: icon
            )
            .font(.subheadline)
            .foregroundColor(
                RecalllQTheme.primary
            )

            Text(value)
                .font(
                    .system(
                        size: 18,
                        weight: .bold
                    )
                )
                .foregroundColor(
                    RecalllQTheme.primaryText
                )

            Text(title)
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
                    RecalllQTheme.smallRadius
            )
            .fill(
                RecalllQTheme.cardBackground
                    .opacity(0.82)
            )
        )
    }

    // =====================================================
    // STATISTICS SECTION
    // =====================================================

    private var statisticsSection: some View {

        VStack(
            alignment: .leading,
            spacing: 14
        ) {

            sectionHeader(
                title: "Study Statistics",
                subtitle:
                    "Track your learning consistency",
                icon: "chart.bar.fill",
                color:
                    RecalllQTheme.primary,
                background:
                    RecalllQTheme.blueBackground
            )

            HStack(spacing: 12) {

                statisticCard(
                    title: "Today",
                    value:
                        studyVM.formattedTodayStudyTime,
                    icon: "calendar",
                    color:
                        RecalllQTheme.primary,
                    background:
                        RecalllQTheme.blueBackground
                )

                statisticCard(
                    title: "Total",
                    value:
                        studyVM.formattedTotalStudyTime,
                    icon: "clock.fill",
                    color:
                        RecalllQTheme.smartPurple,
                    background:
                        RecalllQTheme.purpleBackground
                )
            }

            HStack(spacing: 12) {

                statisticCard(
                    title: "Sessions",
                    value:
                        "\(studyVM.totalSessions)",
                    icon: "books.vertical.fill",
                    color:
                        RecalllQTheme.studyOrange,
                    background:
                        RecalllQTheme.orangeBackground
                )

                statisticCard(
                    title: "Cards Reviewed",
                    value:
                        "\(studyVM.totalFlashcardsReviewed)",
                    icon:
                        "rectangle.on.rectangle",
                    color:
                        RecalllQTheme.success,
                    background:
                        RecalllQTheme.greenBackground
                )
            }
        }
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
    // STATISTIC CARD
    // =====================================================

    @ViewBuilder
    private func statisticCard(
        title: String,
        value: String,
        icon: String,
        color: Color,
        background: Color
    ) -> some View {

        VStack(spacing: 8) {

            ZStack {

                RoundedRectangle(
                    cornerRadius: 11
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

            Text(value)
                .font(
                    .system(
                        size: 19,
                        weight: .bold
                    )
                )
                .foregroundColor(
                    RecalllQTheme.primaryText
                )
                .lineLimit(1)
                .minimumScaleFactor(0.75)

            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(
                    RecalllQTheme.secondaryText
                )
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(
            maxWidth: .infinity,
            minHeight: 125
        )
        .padding(.horizontal, 8)
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
    // RECENT ACTIVITY
    // =====================================================

    private var recentActivitySection: some View {

        VStack(
            alignment: .leading,
            spacing: 14
        ) {

            sectionHeader(
                title: "Recent Study Activity",
                subtitle:
                    "Your latest learning sessions",
                icon:
                    "clock.arrow.circlepath",
                color:
                    RecalllQTheme.smartPurple,
                background:
                    RecalllQTheme.purpleBackground
            )

            if studyVM.recentSessions.isEmpty {

                emptyActivityState

            } else {

                ForEach(
                    studyVM.recentSessions
                ) { session in

                    recentSessionCard(
                        session
                    )
                }
            }
        }
    }

    // =====================================================
    // EMPTY ACTIVITY STATE
    // =====================================================

    private var emptyActivityState: some View {

        VStack(spacing: 14) {

            ZStack {

                Circle()
                    .fill(
                        RecalllQTheme.purpleBackground
                    )
                    .frame(
                        width: 70,
                        height: 70
                    )

                Image(
                    systemName:
                        "clock.badge.questionmark"
                )
                .font(
                    .system(size: 30)
                )
                .foregroundColor(
                    RecalllQTheme.smartPurple
                )
            }

            Text("No Study Sessions Yet")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(
                    RecalllQTheme.primaryText
                )

            Text(
                "Start your first study session to begin tracking your learning progress."
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
        .padding(28)
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
                RecalllQTheme.smartPurple.opacity(0.10),
                lineWidth: 1
            )
        )
    }

    // =====================================================
    // RECENT SESSION CARD
    // =====================================================

    @ViewBuilder
    private func recentSessionCard(
        _ session: StudySession
    ) -> some View {

        VStack(
            alignment: .leading,
            spacing: 14
        ) {

            HStack(spacing: 12) {

                ZStack {

                    Circle()
                        .fill(
                            RecalllQTheme.blueBackground
                        )
                        .frame(
                            width: 46,
                            height: 46
                        )

                    Image(
                        systemName: "clock.fill"
                    )
                    .font(.subheadline)
                    .foregroundColor(
                        RecalllQTheme.primary
                    )
                }

                VStack(
                    alignment: .leading,
                    spacing: 4
                ) {

                    Text(
                        session.startDate,
                        style: .date
                    )
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(
                        RecalllQTheme.primaryText
                    )

                    Text(
                        session.startDate,
                        style: .time
                    )
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
                        studyVM.formatDuration(
                            session.duration
                        )
                    )
                    .font(
                        .system(
                            size: 17,
                            weight: .bold
                        )
                    )
                    .foregroundColor(
                        RecalllQTheme.primary
                    )

                    Text("duration")
                        .font(.caption2)
                        .foregroundColor(
                            RecalllQTheme.secondaryText
                        )
                }
            }

            Divider()

            HStack(spacing: 0) {

                historyStat(
                    value:
                        "\(session.flashcardsReviewed)",
                    title: "Cards",
                    icon:
                        "rectangle.on.rectangle"
                )

                Spacer()

                historyStat(
                    value:
                        "\(session.memoriesStudied)",
                    title: "Memories",
                    icon:
                        "brain.head.profile"
                )

                Spacer()

                historyStat(
                    value:
                        "\(session.quizzesCompleted)",
                    title: "Quizzes",
                    icon:
                        "questionmark.circle.fill"
                )
            }
        }
        .padding(17)
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
            y:
                RecalllQTheme.shadowY
        )
    }

    // =====================================================
    // HISTORY STAT
    // =====================================================

    @ViewBuilder
    private func historyStat(
        value: String,
        title: String,
        icon: String
    ) -> some View {

        VStack(spacing: 5) {

            Image(
                systemName: icon
            )
            .font(.caption)
            .foregroundColor(
                RecalllQTheme.primary
            )

            Text(value)
                .font(
                    .system(
                        size: 16,
                        weight: .bold
                    )
                )
                .foregroundColor(
                    RecalllQTheme.primaryText
                )

            Text(title)
                .font(.caption2)
                .foregroundColor(
                    RecalllQTheme.secondaryText
                )
        }
    }
}

// =====================================================
// PREVIEW
// =====================================================

#Preview {
    NavigationStack {
        StudySessionView()
            .environmentObject(
                AppState()
            )
    }
}
