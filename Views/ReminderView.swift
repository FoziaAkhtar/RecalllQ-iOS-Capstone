
import SwiftUI

// =====================================================
// VIEW: ReminderView
// =====================================================
// PURPOSE:
// - Displays all notes that have reminders
// - Sorts reminders by upcoming date/time
// - Provides a clean and professional reminder interface
// - Uses AppState as the single source of truth
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

        // =====================================================
        // FILTER + SORT REMINDERS
        // =====================================================
        // Only notes containing a reminder date are displayed.
        // Reminders are sorted from earliest to latest.
        // =====================================================

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

        return ScrollView {

            VStack(alignment: .leading, spacing: 22) {

                // =====================================================
                // HEADER
                // =====================================================

                VStack(alignment: .leading, spacing: 6) {

                    HStack(spacing: 10) {

                        Image(systemName: "bell.badge.fill")
                            .font(.title2)
                            .foregroundColor(.orange)

                        Text("Reminders")
                            .font(.largeTitle)
                            .bold()
                    }

                    Text("Stay on top of important tasks and study plans.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 8)

                // =====================================================
                // REMINDER SUMMARY
                // =====================================================

                HStack(spacing: 12) {

                    Image(systemName: "clock.fill")
                        .font(.title3)
                        .foregroundColor(.orange)

                    VStack(alignment: .leading, spacing: 3) {

                        Text("\(reminderNotes.count)")
                            .font(.title2)
                            .bold()

                        Text(
                            reminderNotes.count == 1
                            ? "Active Reminder"
                            : "Active Reminders"
                        )
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }

                    Spacer()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.orange.opacity(0.10))
                )

                // =====================================================
                // EMPTY STATE
                // =====================================================

                if reminderNotes.isEmpty {

                    VStack(spacing: 16) {

                        Image(systemName: "bell.slash")
                            .font(.system(size: 45))
                            .foregroundColor(.secondary)

                        Text("No reminders yet")
                            .font(.title3)
                            .bold()

                        Text(
                            "Create a reminder when adding a note and it will appear here."
                        )
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 50)
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .fill(Color.gray.opacity(0.08))
                    )

                } else {

                    // =====================================================
                    // UPCOMING REMINDERS
                    // =====================================================

                    Text("Upcoming")
                        .font(.title3)
                        .bold()

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

        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// =====================================================
// COMPONENT: ReminderCard
// =====================================================
// PURPOSE:
// Reusable card displaying one reminder.
// =====================================================

private struct ReminderCard: View {

    let note: Note

    var body: some View {

        HStack(alignment: .top, spacing: 14) {

            // =====================================================
            // REMINDER ICON
            // =====================================================

            ZStack {

                Circle()
                    .fill(Color.orange.opacity(0.15))
                    .frame(width: 46, height: 46)

                Image(systemName: "bell.fill")
                    .foregroundColor(.orange)
            }

            // =====================================================
            // REMINDER INFORMATION
            // =====================================================

            VStack(alignment: .leading, spacing: 6) {

                Text(
                    note.title.isEmpty
                    ? "Untitled Note"
                    : note.title
                )
                .font(.headline)
                .lineLimit(2)

                if !note.content.isEmpty {

                    Text(note.content)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }

                // =====================================================
                // REMINDER DATE
                // =====================================================

                if let date = note.reminderDate {

                    HStack(spacing: 6) {

                        Image(systemName: "clock")

                        Text(
                            date.formatted(
                                date: .abbreviated,
                                time: .shortened
                            )
                        )
                    }
                    .font(.caption)
                    .foregroundColor(.orange)
                }
            }

            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.gray.opacity(0.08))
        )
    }
}
