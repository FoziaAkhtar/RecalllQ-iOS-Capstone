
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

    // =====================================================
    // FILTERED + SORTED NOTES
    // =====================================================
    private var notes: [Note] {

        appState.notesViewModel.notes
            .filter { $0.reminderDate != nil }
            .sorted { lhs, rhs in

                guard let left = lhs.reminderDate else { return false }
                guard let right = rhs.reminderDate else { return true }

                return left < right
            }
    }

    var body: some View {

        NavigationStack {

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
                if notes.isEmpty {

                    Spacer()

                    Text("No reminders set yet")
                        .foregroundColor(.gray)

                    Spacer()

                } else {

                    // =====================================================
                    // LIST (FIXED STRUCTURE)
                    // =====================================================
                    List(notes) { note in

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
