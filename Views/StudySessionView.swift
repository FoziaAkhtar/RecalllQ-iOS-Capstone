
import SwiftUI
import Combine

// =====================================================
// VIEW: StudySessionView
// =====================================================
// PURPOSE:
// Provides the user with a personalized study session
// screen.
//
// FEATURES:
// - Start study session
// - Stop study session
// - Display today's study time
// - Display total study time
// - Display current session statistics
// - Display recent study sessions
// =====================================================

struct StudySessionView: View {

    // =====================================================
    // APP STATE
    // =====================================================

    @EnvironmentObject var appState: AppState

    // =====================================================
    // COMPUTED VIEW MODEL
    // =====================================================

    private var studyVM: StudySessionViewModel {
        appState.studySessionViewModel
    }

    // =====================================================
    // TIMER
    // =====================================================

    @State private var currentTime = Date()

    private let timer =
        Timer.publish(
            every: 1,
            on: .main,
            in: .common
        ).autoconnect()

    // =====================================================
    // BODY
    // =====================================================

    var body: some View {

        ScrollView {

            VStack(
                alignment: .leading,
                spacing: 24
            ) {

                // =================================================
                // HEADER
                // =================================================

                VStack(
                    alignment: .leading,
                    spacing: 6
                ) {

                    Text("Study Session")
                        .font(
                            .system(
                                size: 32,
                                weight: .bold
                            )
                        )
                        .foregroundColor(
                            RecalllQTheme.primary
                        )

                    Text(
                        "Focus on your learning and let RecalllQ track your progress."
                    )
                    .font(.subheadline)
                    .foregroundColor(
                        RecalllQTheme.secondaryText
                    )
                }

                // =================================================
                // CURRENT SESSION CARD
                // =================================================

                VStack(
                    spacing: 18
                ) {

                    Image(
                        systemName:
                            studyVM.isStudying
                            ? "brain.head.profile"
                            : "book.closed"
                    )
                    .font(.system(size: 50))
                    .foregroundColor(
                        RecalllQTheme.primary
                    )

                    Text(
                        studyVM.isStudying
                        ? "Study Session Active"
                        : "Ready to Study?"
                    )
                    .font(.title2)
                    .bold()

                    // ---------------------------------------------
                    // CURRENT SESSION TIMER
                    // ---------------------------------------------

                    if studyVM.isStudying,
                       let startDate =
                            studyVM.currentSessionStartDate {

                        Text(
                            formattedSessionDuration(
                                from: startDate
                            )
                        )
                        .font(
                            .system(
                                size: 40,
                                weight: .bold,
                                design: .monospaced
                            )
                        )
                        .foregroundColor(
                            RecalllQTheme.primary
                        )

                    } else {

                        Text("00:00")
                            .font(
                                .system(
                                    size: 40,
                                    weight: .bold,
                                    design: .monospaced
                                )
                            )
                            .foregroundColor(
                                RecalllQTheme.secondaryText
                            )
                    }

                    // =================================================
                    // SESSION STATISTICS
                    // =================================================

                    if let session =
                        studyVM.activeSession {

                        HStack(spacing: 12) {

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
                    }

                    // =================================================
                    // START / END BUTTON
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
                            }
                            .frame(
                                maxWidth: .infinity
                            )
                            .padding()
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

                        Button {

                            appState.cancelStudySession()

                        } label: {

                            Text("Cancel Session")
                                .font(.subheadline)
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
                            }
                            .frame(
                                maxWidth: .infinity
                            )
                            .padding()
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
                        RecalllQTheme.blueBackground
                    )
                )

                // =================================================
                // STUDY STATISTICS
                // =================================================

                Text("Study Statistics")
                    .font(.title3)
                    .bold()

                HStack(spacing: 12) {

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
                            "clock"
                    )
                }

                HStack(spacing: 12) {

                    statisticCard(
                        title:
                            "Sessions",
                        value:
                            "\(studyVM.totalSessions)",
                        icon:
                            "books.vertical"
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

                // =================================================
                // RECENT ACTIVITY
                // =================================================

                Text("Recent Study Activity")
                    .font(.title3)
                    .bold()

                if studyVM.recentSessions.isEmpty {

                    VStack(spacing: 10) {

                        Image(
                            systemName:
                                "clock.badge.questionmark"
                        )
                        .font(.largeTitle)
                        .foregroundColor(
                            RecalllQTheme.secondaryText
                        )

                        Text(
                            "No study sessions yet."
                        )
                        .font(.headline)

                        Text(
                            "Start your first study session to begin tracking your learning progress."
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
                            RecalllQTheme.cardBackground
                        )
                    )

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
            .padding()
        }
        .navigationTitle("Study")
        .navigationBarTitleDisplayMode(
            .inline
        )
        .onReceive(timer) {
            value in

            currentTime = value
        }
    }

    // =====================================================
    // SESSION DURATION
    // =====================================================

    private func formattedSessionDuration(
        from startDate: Date
    ) -> String {

        let duration =
            currentTime.timeIntervalSince(
                startDate
            )

        let totalSeconds =
            max(
                Int(duration),
                0
            )

        let hours =
            totalSeconds / 3600

        let minutes =
            (totalSeconds % 3600) / 60

        let seconds =
            totalSeconds % 60

        if hours > 0 {

            return String(
                format:
                    "%02d:%02d:%02d",
                hours,
                minutes,
                seconds
            )
        }

        return String(
            format:
                "%02d:%02d",
            minutes,
            seconds
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

        VStack(spacing: 5) {

            Image(
                systemName: icon
            )
            .foregroundColor(
                RecalllQTheme.primary
            )

            Text(value)
                .font(.headline)
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

        VStack(
            spacing: 8
        ) {

            Image(
                systemName: icon
            )
            .font(.title3)
            .foregroundColor(
                RecalllQTheme.primary
            )

            Text(value)
                .font(.headline)
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
            spacing: 10
        ) {

            HStack {

                Image(
                    systemName:
                        "clock.fill"
                )
                .foregroundColor(
                    RecalllQTheme.primary
                )

                Text(
                    session.startDate,
                    style: .date
                )
                .font(.headline)

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

            HStack(spacing: 20) {

                Label(
                    "\(session.flashcardsReviewed)",
                    systemImage:
                        "rectangle.on.rectangle"
                )

                Label(
                    "\(session.memoriesStudied)",
                    systemImage:
                        "brain.head.profile"
                )

                Label(
                    "\(session.quizzesCompleted)",
                    systemImage:
                        "questionmark.circle"
                )
            }
            .font(.caption)
            .foregroundColor(
                RecalllQTheme.secondaryText
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
                    RecalllQTheme.mediumRadius
            )
            .fill(
                RecalllQTheme.cardBackground
            )
        )
    }
}
