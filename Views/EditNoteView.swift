
import SwiftUI

// =====================================================
// VIEW: EditNoteView
// =====================================================
// PURPOSE:
// - Edit existing note safely
// - Uses AppState as the single source of truth
// =====================================================

struct EditNoteView: View {

    // =====================================================
    // GLOBAL APP STATE
    // =====================================================
    @EnvironmentObject var appState: AppState

    // =====================================================
    // NOTE BEING EDITED
    // =====================================================
    let note: Note

    // =====================================================
    // LOCAL STATE
    // =====================================================
    @State private var title: String
    @State private var content: String

    // =====================================================
    // DISMISS
    // =====================================================
    @Environment(\.dismiss) private var dismiss

    // =====================================================
    // INIT
    // =====================================================
    init(note: Note) {

        self.note = note

        _title = State(
            initialValue: note.title
        )

        _content = State(
            initialValue: note.content
        )
    }

    // =====================================================
    // BODY
    // =====================================================
    var body: some View {

        VStack(spacing: 16) {

            // =====================================================
            // TITLE
            // =====================================================
            TextField(
                "Title",
                text: $title
            )
            .textFieldStyle(.roundedBorder)

            // =====================================================
            // CONTENT
            // =====================================================
            TextField(
                "Content",
                text: $content
            )
            .textFieldStyle(.roundedBorder)

            // =====================================================
            // SAVE BUTTON
            // =====================================================
            Button {

                let cleanTitle = title.trimmingCharacters(
                    in: CharacterSet.whitespacesAndNewlines
                )

                let cleanContent = content.trimmingCharacters(
                    in: CharacterSet.whitespacesAndNewlines
                )

                // Don't save completely empty notes
                guard !cleanTitle.isEmpty ||
                      !cleanContent.isEmpty else {
                    return
                }

                // =====================================================
                // UPDATE NOTE
                // =====================================================
                appState.notesViewModel.updateNote(
                    id: note.id,
                    newTitle: cleanTitle,
                    newContent: cleanContent
                )

                // Close edit screen
                dismiss()

            } label: {

                Text("Save Changes")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }

            Spacer()
        }
        .padding()
        .navigationTitle("Edit Note")
    }
}
