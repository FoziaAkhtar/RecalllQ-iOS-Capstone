
import SwiftUI

 // ==========================================
 // NOTES VIEW (UI LAYER)
 // ==========================================

// PURPOSE:
// - Show list of notes
// - Add new notes
// - Delete notes
// ============================================

struct NotesView: View {

    // ===== ViewModel handles logic =====
    @StateObject private var viewModel = NotesViewModel()

    // ==== Input fields ======
    @State private var title: String = ""
    @State private var content: String = ""

    var body: some View {

        NavigationStack {

            VStack {

                // =====================================================
                // INPUT SECTION
                // =====================================================

                TextField("Enter title", text: $title)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)

                TextField("Enter content", text: $content)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)

                Button(action: {

                    // ======= Add note ===========
                    viewModel.addNote(title: title, content: content)

                    // ====== Clear fields ========
                    title = ""
                    content = ""

                }) {
                    Text("Add Note")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()

                // =====================================================
                // LIST SECTION
                // =====================================================

                List {

                    ForEach(viewModel.notes) { note in

                        VStack(alignment: .leading, spacing: 5) {

                            Text(note.title)
                                .font(.headline)

                            Text(note.content)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    .onDelete(perform: viewModel.deleteNote)
                }
            }
            .navigationTitle("Notes")
        }
    }
}
