
import SwiftUI

// =====================================================
// VIEW: EditNoteView
// =====================================================
// PURPOSE:
// - Edit existing note
// =====================================================


struct EditNoteView: View {

    // =====================================================
    // VIEWMODEL
    // =====================================================
    @ObservedObject var viewModel: NotesViewModel

    // =====================================================
    // NOTE
    // =====================================================
    let note: Note

    // =====================================================
    // LOCAL STATE
    // =====================================================
    @State private var title: String
    @State private var content: String

    // =====================================================
    // INIT
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
