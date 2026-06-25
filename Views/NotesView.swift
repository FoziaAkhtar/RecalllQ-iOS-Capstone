
import SwiftUI

// =====================================================
// VIEW: NotesView
// =====================================================
// PURPOSE:
// - UI layer for Notes feature
// - Displays notes list
// - Handles user input (title/content)
// - Sends actions to ViewModel only
//
// RESPONSIBILITIES:
// ✔ Show notes
// ✔ Add notes
// ✔ Delete notes
// ✔ Search notes
// ❌ NO business logic (kept in ViewModel)
// =====================================================

struct NotesView: View {

    // =====================================================
    // VIEWMODEL (Source of Truth)
    // =====================================================
    @StateObject private var viewModel = NotesViewModel()

    // =====================================================
    // UI STATE (temporary input only)
    // =====================================================
    @State private var title: String = ""
    @State private var content: String = ""

    // =====================================================
    // MAIN VIEW BODY
    // =====================================================
    var body: some View {

        NavigationStack {

            VStack(spacing: 16) {

                // =====================================================
                // SEARCH BAR
                // - Binds directly to ViewModel
                // - Enables live filtering
                // =====================================================
                TextField("Search notes...", text: $viewModel.searchText)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)

                // =====================================================
                // INPUT SECTION (CREATE NOTE)
                // =====================================================
                VStack(spacing: 10) {

                    TextField("Enter title", text: $title)
                        .textFieldStyle(.roundedBorder)

                    TextField("Enter content", text: $content)
                        .textFieldStyle(.roundedBorder)
                }
                .padding(.horizontal)

                // =====================================================
                // ADD BUTTON
                // =====================================================
                Button {

                    // Prevent empty notes
                    guard !title.isEmpty, !content.isEmpty else { return }

                    // Send data to ViewModel
                    viewModel.addNote(title: title, content: content)

                    // Clear input fields after saving
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

                    // Show filtered notes from ViewModel
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

                    // Swipe to delete
                    .onDelete(perform: viewModel.deleteNote)
                }
            }
            .navigationTitle("Notes")
        }
    }
}
