
import SwiftUI

// =====================================================
// VIEW: EditNoteView
// =====================================================
// PURPOSE:
// Allows user to modify existing note.
// Changes are sent back to ViewModel.
// =====================================================

struct EditNoteView: View {

    // =====================================================
    // VIEWMODEL
    // PURPOSE:
    // Shared so updates reflect immediately in main list.
    // =====================================================
    @ObservedObject var viewModel: NotesViewModel

    // =====================================================
    // NOTE
    // PURPOSE:
    // The note being edited.
    // =====================================================
    let note: Note

    // =====================================================
    // LOCAL STATE
    // PURPOSE:
    // Holds editable values before saving.
    // =====================================================
    @State private var title: String
    @State private var content: String

    // =====================================================
    // INIT
    // PURPOSE:
    // Pre-fill fields with existing note data.
    // =====================================================
    init(viewModel: NotesViewModel, note: Note) {

        self.viewModel = viewModel
        self.note = note

        _title = State(initialValue: note.title)
        _content = State(initialValue: note.content)
    }

    var body: some View {

        VStack(spacing: 16) {

            TextField("Title", text: $title)
                .textFieldStyle(.roundedBorder)

            TextField("Content", text: $content)
                .textFieldStyle(.roundedBorder)

            Button {

                viewModel.updateNote(
                    id: note.id,
                    newTitle: title,
                    newContent: content
                )

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
