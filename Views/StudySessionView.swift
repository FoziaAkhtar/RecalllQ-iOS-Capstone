
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
// - LIVE timer
// - Current session statistics
// - Today's study time
// - Total study time
// - Session history
// - Flashcard / Memory / Quiz tracking
// - RecalllQ UI/UX styling
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
                spacing: 22
            ) {

                // =================================================
                // HEADER
                // =================================================

                header

                // =================================================
                // CURRENT SESSION
                // =================================================

                currentSessionCard

                // =================================================
                // STATISTICS
                // =================================================

                statisticsSection

                // =================================================
                // RECENT ACTIVITY
                // =================================================

                recentActivitySection
            }
            .padding()
        }
        .background(
            RecalllQTheme.background
                .ignoresSafeArea()
        )
        .navigationTitle("Study")
        .navigationBarTitleDisplayMode(.inline)
    }

    // =====================================================
    // HEADER
    // =====================================================

    private var header: some View {

        HStack {

            VStack(
                alignment: .leading,
                spacing: 6
            ) {

                Text("Study Session")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(
                        RecalllQTheme.primaryText
                    )

                Text(
                    "Focus on learning while RecalllQ tracks your progress."
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
                        width: 52,
                        height: 52
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
            }
        }
    }

    // =====================================================
    // CURRENT SESSION CARD
    // =====================================================

    private var currentSessionCard: some View {

        VStack(spacing: 18) {

            // =================================================
            // STATUS ICON
            // =================================================

            ZStack {

                Circle()
                    .fill(
                        studyVM.isStudying
                        ? RecalllQTheme.greenBackground
                        : RecalllQTheme.blueBackground
                    )
                    .frame(
                        width: 92,
                        height: 92
                    )

                Image(
                    systemName:
                        studyVM.isStudying
                        ? "brain.head.profile"
                        : "book.closed.fill"
                )
                .font(
                    .system(size: 38)
                )
                .foregroundColor(
                    studyVM.isStudying
                    ? RecalllQTheme.success
                    : RecalllQTheme.primary
                )
            }

            // =================================================
            // STATUS
            // =================================================

            VStack(spacing: 5) {

                Text(
                    studyVM.isStudying
                    ? "Study Session Active"
                    : "Ready to Study?"
                )
                .font(.title2)
                .bold()
                .foregroundColor(
                    RecalllQTheme.primaryText
                )

                Text(
                    studyVM.isStudying
                    ? "Keep going — you're making progress."
                    : "Start a session and let RecalllQ track your learning."
                )
                .font(.caption)
                .foregroundColor(
                    RecalllQTheme.secondaryText
                )
                .multilineTextAlignment(.center)
            }

            // =================================================
            // TIMER
            // =================================================

            Text(
                studyVM.isStudying
                ? studyVM.formattedActiveSessionTime
                : "00:00"
            )
            .font(
                .system(
                    size: 42,
                    weight: .bold,
                    design: .monospaced
                )
            )
            .foregroundColor(
                studyVM.isStudying
                ? RecalllQTheme.primary
                : RecalllQTheme.secondaryText
            )
            .animation(
                .none,
                value:
                    studyVM.formattedActiveSessionTime
            )

            // =================================================
            // ACTIVE SESSION STATS
            // =================================================

            if let session =
                studyVM.activeSession {

                HStack(spacing: 10) {

                    sessionStat(
                        value:
                            "\(session.flashcardsReviewed)",
                        title:
                            "Flashcards",
                        icon:
                            "rectangle.on.rectangle"
                    )

                    sessionStat(
                        value:
                            "\(session.memoriesStudied)",
                        title:
                            "Memories",
                        icon:
                            "brain.head.profile"
                    )

                    sessionStat(
                        value:
                            "\(session.quizzesCompleted)",
                        title:
                            "Quizzes",
                        icon:
                            "questionmark.circle"
                    )
                }
                .padding(.top, 4)
            }

            // =================================================
            // ACTION BUTTONS
            // =================================================

            if studyVM.isStudying {

                Button {

                    appState.endStudySession()

                } label: {

                    HStack {

                        Image(
                            systemName:
                                "stop.fill"
                        )

                        Text(
                            "End Study Session"
                        )
                        .bold()

                        Spacer()

                        Image(
                            systemName:
                                "checkmark"
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
                }

                Button {

                    appState.cancelStudySession()

                } label: {

                    Text(
                        "Cancel Session"
                    )
                    .font(.subheadline)
                    .bold()
                    .frame(
                        maxWidth: .infinity
                    )
                    .padding(.vertical, 8)
                    .foregroundColor(
                        RecalllQTheme.secondaryText
                    )
                }

            } else {

                Button {

                    appState.startStudySession()

                } label: {

                    HStack {

                        Image(
                            systemName:
                                "play.fill"
                        )

                        Text(
                            "Start Study Session"
                        )
                        .bold()

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
                }
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
                studyVM.isStudying
                ? RecalllQTheme.greenBackground
                : RecalllQTheme.blueBackground
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
                systemName:
                    icon
            )
            .foregroundColor(
                RecalllQTheme.primary
            )

            Text(value)
                .font(.headline)
                .bold()
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
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(
                cornerRadius:
                    RecalllQTheme.smallRadius
            )
            .fill(
                RecalllQTheme.cardBackground
                    .opacity(0.8)
            )
        )
    }

    // =====================================================
    // STATISTICS SECTION
    // =====================================================

    private var statisticsSection: some View {

        VStack(
            alignment: .leading,
            spacing: 12
        ) {

            Text("Study Statistics")
                .font(.title3)
                .bold()
                .foregroundColor(
                    RecalllQTheme.primaryText
                )

            HStack(spacing: 10) {

                statisticCard(
                    title:
                        "Today",
                    value:
                        studyVM.formattedTodayStudyTime,
                    icon:
                        "calendar"
                )

                statisticCard(
                    title:
                        "Total",
                    value:
                        studyVM.formattedTotalStudyTime,
                    icon:
                        "clock.fill"
                )
            }

            HStack(spacing: 10) {

                statisticCard(
                    title:
                        "Sessions",
                    value:
                        "\(studyVM.totalSessions)",
                    icon:
                        "books.vertical.fill"
                )

                statisticCard(
                    title:
                        "Cards",
                    value:
                        "\(studyVM.totalFlashcardsReviewed)",
                    icon:
                        "rectangle.on.rectangle"
                )
            }
        }
    }

    // =====================================================
    // STATISTIC CARD
    // =====================================================

    @ViewBuilder
    private func statisticCard(
        title: String,
        value: String,
        icon: String
    ) -> some View {

        VStack(spacing: 8) {

            Image(
                systemName:
                    icon
            )
            .font(.title3)
            .foregroundColor(
                RecalllQTheme.primary
            )

            Text(value)
                .font(.headline)
                .bold()
                .foregroundColor(
                    RecalllQTheme.primaryText
                )
                .lineLimit(1)
                .minimumScaleFactor(0.8)

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
    // RECENT ACTIVITY SECTION
    // =====================================================

    private var recentActivitySection: some View {

        VStack(
            alignment: .leading,
            spacing: 12
        ) {

            HStack {

                Text(
                    "Recent Study Activity"
                )
                .font(.title3)
                .bold()
                .foregroundColor(
                    RecalllQTheme.primaryText
                )

                Spacer()

                Image(
                    systemName:
                        "clock.arrow.circlepath"
                )
                .foregroundColor(
                    RecalllQTheme.smartPurple
                )
            }

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

        VStack(spacing: 12) {

            ZStack {

                Circle()
                    .fill(
                        RecalllQTheme.purpleBackground
                    )
                    .frame(
                        width: 72,
                        height: 72
                    )

                Image(
                    systemName:
                        "clock.badge.questionmark"
                )
                .font(.system(size: 30))
                .foregroundColor(
                    RecalllQTheme.smartPurple
                )
            }

            Text(
                "No Study Sessions Yet"
            )
            .font(.headline)
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
                RecalllQTheme.primary.opacity(0.10),
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
            spacing: 12
        ) {

            HStack {

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
                            "clock.fill"
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
                        session.startDate,
                        style: .date
                    )
                    .font(.headline)
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

                Text(
                    studyVM.formatDuration(
                        session.duration
                    )
                )
                .font(.subheadline)
                .bold()
                .foregroundColor(
                    RecalllQTheme.primary
                )
            }

            Divider()

            HStack(spacing: 0) {

                historyStat(
                    value:
                        "\(session.flashcardsReviewed)",
                    title:
                        "Cards",
                    icon:
                        "rectangle.on.rectangle"
                )

                Spacer()

                historyStat(
                    value:
                        "\(session.memoriesStudied)",
                    title:
                        "Memories",
                    icon:
                        "brain.head.profile"
                )

                Spacer()

                historyStat(
                    value:
                        "\(session.quizzesCompleted)",
                    title:
                        "Quizzes",
                    icon:
                        "questionmark.circle"
                )
            }
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

        VStack(spacing: 4) {

            Image(
                systemName:
                    icon
            )
            .font(.caption)
            .foregroundColor(
                RecalllQTheme.primary
            )

            Text(value)
                .font(.subheadline)
                .bold()
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
