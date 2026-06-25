
import SwiftUI

// =====================================================
// VIEW: NotesView
// =====================================================
// PURPOSE:
// - UI layer for Notes feature
// - Displays list of notes
// - Handles user input (title, content)
// - Sends all logic to ViewModel (MVVM)
// =====================================================

struct NotesView: View {

    // =====================================================
    // VIEWMODEL (Source of Truth)
    // =====================================================
    @StateObject private var viewModel = NotesViewModel()

    // =====================================================
    // LOCAL UI STATE (temporary input only)
    // =====================================================
    @State private var title: String = ""
    @State private var content: String = ""

    // =====================================================
    // MAIN VIEW
    // =====================================================
    var body: some View {

        NavigationStack {

            VStack(spacing: 16) {

                // =====================================================
                // SEARCH BAR
                // - Binds directly to ViewModel searchText
                // - Enables live filtering
                // =====================================================
                TextField("Search notes...", text: $viewModel.searchText)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)

                // =====================================================
                // INPUT SECTION (TITLE + CONTENT)
                // =====================================================
                VStack(spacing: 10) {

                    TextField("Enter title", text: $title)
                        .textFieldStyle(.roundedBorder)

                    TextField("Enter content", text: $content)
                        .textFieldStyle(.roundedBorder)
                }
                .padding(.horizontal)

                // =====================================================
                // ADD NOTE BUTTON
                // =====================================================
                Button {

                    // Prevent empty notes
                    guard !title.isEmpty, !content.isEmpty else { return }

                    // Send data to ViewModel
                    viewModel.addNote(title: title, content: content)

                    // Clear inputs after saving
                    title = ""
                    content = ""

                } label: {

                    Text("Add Note")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }

                // =====================================================
                // NOTES LIST
                // =====================================================
                List {

                    // Show filtered notes (search enabled)
                    ForEach(viewModel.filteredNotes) { note in

                        VStack(alignment: .leading, spacing: 6) {

                            // Note title
                            Text(note.title)
                                .font(.headline)

                            // Note content preview
                            Text(note.content)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 4)
                    }

                    // =====================================================
                    // DELETE NOTE (SWIPE ACTION)
                    // =====================================================
                    .onDelete { indexSet in

                        // Convert index → note → UUID
                        indexSet.forEach { index in
                            let note = viewModel.filteredNotes[index]
                            viewModel.deleteNote(id: note.id)
                        }
                    }
                }
            }
            .navigationTitle("Notes")
        }
    }
}
