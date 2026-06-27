
import SwiftUI

// =====================================================
// VIEW: ReminderView
// =====================================================
// PURPOSE:
// Shows all notes with active reminders
// Sorted by upcoming reminder time
// =====================================================

struct ReminderView: View {

    @EnvironmentObject var appState: AppState

    var body: some View {

        // =====================================================
        // FILTER + SORT DIRECTLY IN BODY (IMPORTANT FIX)
        // Ensures SwiftUI tracks updates properly
        // =====================================================
        let reminderNotes = appState.notesViewModel.notes
            .filter { $0.reminderDate != nil }
            .sorted { lhs, rhs in

                guard let left = lhs.reminderDate else { return false }
                guard let right = rhs.reminderDate else { return true }

                return left < right
            }

        return NavigationStack {

            VStack(spacing: 0) {

                // =====================================================
                // HEADER
                // =====================================================
                Text("⏰ Reminders")
                    .font(.largeTitle)
                    .bold()
                    .padding()

                // =====================================================
                // EMPTY STATE
                // =====================================================
                if reminderNotes.isEmpty {

                    Spacer()

                    Text("No reminders set yet")
                        .foregroundColor(.gray)

                    Spacer()

                } else {

                    // =====================================================
                    // LIST
                    // =====================================================
                    List(reminderNotes) { note in

                        VStack(alignment: .leading, spacing: 6) {

                            Text(note.title)
                                .font(.headline)

                            Text(note.content)
                                .font(.subheadline)
                                .foregroundColor(.gray)

                            if let date = note.reminderDate {

                                Text("⏰ \(date.formatted(date: .abbreviated, time: .shortened))")
                                    .font(.caption)
                                    .foregroundColor(.orange)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Reminders")
        }
    }
}
