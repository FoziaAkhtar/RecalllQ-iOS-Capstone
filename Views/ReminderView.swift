
import SwiftUI

// =====================================================
// VIEW: ReminderView
// =====================================================
// PURPOSE:
// - Displays all notes that have reminders
// - Sorts reminders by upcoming date/time
// - Uses RecalllQ learning colours
// - Blue = learning / trust
// - Orange = reminders / focus
// - Green = positive progress
// =====================================================

struct ReminderView: View {

    // =====================================================
    // GLOBAL APP STATE
    // =====================================================

    @EnvironmentObject var appState: AppState

    // =====================================================
    // BODY
    // =====================================================

    var body: some View {

        let reminderNotes = appState.notesViewModel.notes
            .filter { $0.reminderDate != nil }
            .sorted { first, second in

                guard let firstDate = first.reminderDate else {
                    return false
                }

                guard let secondDate = second.reminderDate else {
                    return true
                }

                return firstDate < secondDate
            }

        // =====================================================
        // MAIN VIEW
        // =====================================================

        ScrollView {

            VStack(alignment: .leading, spacing: 22) {

                // =====================================================
                // HEADER
                // =====================================================

                VStack(alignment: .leading, spacing: 6) {

                    HStack(spacing: 10) {

                        ZStack {

                            Circle()
                                .fill(
                                    RecalllQTheme.secondary
                                        .opacity(0.15)
                                )
                                .frame(
                                    width: 44,
                                    height: 44
                                )

                            Image(
                                systemName: "bell.badge.fill"
                            )
                            .font(.title2)
                            .foregroundColor(
                                RecalllQTheme.secondary
                            )
                        }

                        Text("Reminders")
                            .font(.largeTitle)
                            .bold()
                            .foregroundColor(
                                RecalllQTheme.primaryText
                            )
                    }

                    Text(
                        "Stay on top of important tasks and study plans."
                    )
                    .font(.subheadline)
                    .foregroundColor(
                        RecalllQTheme.secondaryText
                    )
                }
                .padding(.top, 8)

                // =====================================================
                // REMINDER SUMMARY
                // =====================================================

                HStack(spacing: 14) {

                    ZStack {

                        Circle()
                            .fill(
                                RecalllQTheme.primary
                                    .opacity(0.12)
                            )
                            .frame(
                                width: 46,
                                height: 46
                            )

                        Image(
                            systemName: "clock.fill"
                        )
                        .font(.title3)
                        .foregroundColor(
                            RecalllQTheme.primary
                        )
                    }

                    VStack(
                        alignment: .leading,
                        spacing: 3
                    ) {

                        Text("\(reminderNotes.count)")
                            .font(.title2)
                            .bold()
                            .foregroundColor(
                                RecalllQTheme.primary
                            )

                        Text(
                            reminderNotes.count == 1
                            ? "Active Reminder"
                            : "Active Reminders"
                        )
                        .font(.caption)
                        .foregroundColor(
                            RecalllQTheme.secondaryText
                        )
                    }

                    Spacer()

                    Image(
                        systemName: "checkmark.circle.fill"
                    )
                    .font(.title2)
                    .foregroundColor(
                        RecalllQTheme.success
                    )
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

                // =====================================================
                // EMPTY STATE
                // =====================================================

                if reminderNotes.isEmpty {

                    VStack(spacing: 16) {

                        ZStack {

                            Circle()
                                .fill(
                                    RecalllQTheme.orangeBackground
                                )
                                .frame(
                                    width: 80,
                                    height: 80
                                )

                            Image(
                                systemName: "bell.slash.fill"
                            )
                            .font(.system(size: 32))
                            .foregroundColor(
                                RecalllQTheme.secondary
                            )
                        }

                        Text("No reminders yet")
                            .font(.title3)
                            .bold()
                            .foregroundColor(
                                RecalllQTheme.primaryText
                            )

                        Text(
                            "Create a reminder when adding a note and it will appear here."
                        )
                        .font(.subheadline)
                        .foregroundColor(
                            RecalllQTheme.secondaryText
                        )
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    }
                    .frame(
                        maxWidth: .infinity
                    )
                    .padding(.vertical, 50)
                    .background(
                        RoundedRectangle(
                            cornerRadius:
                                RecalllQTheme.largeRadius
                        )
                        .fill(
                            RecalllQTheme.orangeBackground
                        )
                    )

                } else {

                    // =====================================================
                    // UPCOMING REMINDERS
                    // =====================================================

                    HStack {

                        Text("Upcoming")
                            .font(.title3)
                            .bold()
                            .foregroundColor(
                                RecalllQTheme.primaryText
                            )

                        Spacer()

                        Image(
                            systemName: "sparkles"
                        )
                        .foregroundColor(
                            RecalllQTheme.secondary
                        )
                    }

                    // =====================================================
                    // REMINDER CARDS
                    // =====================================================

                    VStack(spacing: 12) {

                        ForEach(reminderNotes) { note in

                            ReminderCard(note: note)
                        }
                    }
                }
            }
            .padding()
        }

        // =====================================================
        // NAVIGATION
        // =====================================================

        .navigationTitle("Reminders")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// =====================================================
// COMPONENT: ReminderCard
// =====================================================

private struct ReminderCard: View {

    let note: Note

    var body: some View {

        HStack(
            alignment: .top,
            spacing: 14
        ) {

            // =====================================================
            // REMINDER ICON
            // =====================================================

            ZStack {

                Circle()
                    .fill(
                        RecalllQTheme.secondary
                            .opacity(0.15)
                    )
                    .frame(
                        width: 48,
                        height: 48
                    )

                Image(
                    systemName: "bell.fill"
                )
                .foregroundColor(
                    RecalllQTheme.secondary
                )
            }

            // =====================================================
            // REMINDER INFORMATION
            // =====================================================

            VStack(
                alignment: .leading,
                spacing: 6
            ) {

                Text(
                    note.title.isEmpty
                    ? "Untitled Note"
                    : note.title
                )
                .font(.headline)
                .foregroundColor(
                    RecalllQTheme.primaryText
                )
                .lineLimit(2)

                if !note.content.isEmpty {

                    Text(note.content)
                        .font(.subheadline)
                        .foregroundColor(
                            RecalllQTheme.secondaryText
                        )
                        .lineLimit(2)
                }

                // =====================================================
                // REMINDER DATE
                // =====================================================

                if let date = note.reminderDate {

                    HStack(spacing: 6) {

                        Image(
                            systemName: "clock.fill"
                        )

                        Text(
                            date.formatted(
                                date: .abbreviated,
                                time: .shortened
                            )
                        )
                    }
                    .font(.caption)
                    .bold()
                    .foregroundColor(
                        RecalllQTheme.secondary
                    )
                }
            }

            Spacer()
        }
        .padding(
            RecalllQTheme.mediumPadding
        )
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

