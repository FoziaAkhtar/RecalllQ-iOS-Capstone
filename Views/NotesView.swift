
import SwiftUI

// =====================================================
// VIEW: NotesView
// ✔ Add notes
// ✔ Delete notes (safe)
// ✔ Search notes
// ✔ Edit notes (new screen)
// ✔ Persistent storage
//✔ MVVM architecture
// =====================================================


struct NotesView: View {

    // =====================================================
    // VIEWMODEL
    // =====================================================
    @StateObject private var viewModel = NotesViewModel()

    // =====================================================
    // INPUT STATE
    // =====================================================
    @State private var title: String = ""
    @State private var content: String = ""

    // =====================================================
    // KEYBOARD CONTROL
    // =====================================================
    @FocusState private var isInputFocused: Bool

    // =====================================================
    // UNDO UI STATE
    // =====================================================
    @State private var showUndo: Bool = false

    var body: some View {

        NavigationStack {

            VStack(spacing: 16) {

                // =====================================================
                // SEARCH BAR
                // =====================================================
                TextField("Search notes...", text: $viewModel.searchText)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)

                // =====================================================
                // INPUT SECTION
                // =====================================================
                VStack(spacing: 10) {

                    TextField("Enter title", text: $title)
                        .textFieldStyle(.roundedBorder)
                        .focused($isInputFocused)

                    TextField("Enter content", text: $content)
                        .textFieldStyle(.roundedBorder)
                        .focused($isInputFocused)
                }
                .padding(.horizontal)

                // =====================================================
                // ADD BUTTON
                // =====================================================
                Button {

                    viewModel.addNote(title: title, content: content)

                    title = ""
                    content = ""
                    isInputFocused = false

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

                    ForEach(viewModel.filteredNotes) { note in

                        NavigationLink {

                            EditNoteView(viewModel: viewModel, note: note)

                        } label: {

                            VStack(alignment: .leading, spacing: 6) {

                                HStack {

                                    Text(note.title)
                                        .font(.headline)

                                    Spacer()

                                    Image(systemName: note.isPinned ? "pin.fill" : "pin")
                                        .foregroundColor(.orange)
                                }

                                Text(note.content)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            .padding(.vertical, 4)
                        }

                        // =====================================================
                        // SWIPE ACTIONS
                        // =====================================================
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {

                            // DELETE
                            Button(role: .destructive) {

                                viewModel.deleteNote(id: note.id)
                                showUndo = true

                            } label: {
                                Label("Delete", systemImage: "trash")
                            }

                            // EDIT
                            NavigationLink {

                                EditNoteView(viewModel: viewModel, note: note)

                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }

                            // PIN
                            Button {

                                viewModel.togglePin(id: note.id)

                            } label: {
                                Label(note.isPinned ? "Unpin" : "Pin", systemImage: "pin")
                            }
                            .tint(.orange)
                        }
                    }
                }

                // =====================================================
                // UNDO BAR
                // =====================================================
                if showUndo {

                    HStack {

                        Text("Note deleted")

                        Spacer()

                        Button("Undo") {

                            viewModel.undoDelete()
                            showUndo = false
                        }
                        .bold()
                    }
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    .padding()
                }
            }
            .navigationTitle("Notes")
        }
    }
}
