
import SwiftUI

// =====================================================
// VIEW: NotesView
// =====================================================
// PURPOSE:
// Main screen of the Notes app.
// Handles input, list display, search, and swipe actions.
// =====================================================

struct NotesView: View {

    // =====================================================
    // VIEWMODEL
    // PURPOSE:
    // Single source of truth for notes data.
    // =====================================================
    @StateObject private var viewModel = NotesViewModel()

    // =====================================================
    // INPUT STATE
    // PURPOSE:
    // Temporary values before creating a note.
    // =====================================================
    @State private var title: String = ""
    @State private var content: String = ""

    // =====================================================
    // KEYBOARD CONTROL
    // PURPOSE:
    // Used to dismiss keyboard after adding note.
    // =====================================================
    @FocusState private var isInputFocused: Bool

    // =====================================================
    // UNDO STATE
    // PURPOSE:
    // Shows undo bar after deletion.
    // =====================================================
    @State private var showUndo: Bool = false

    var body: some View {

        NavigationStack {

            VStack(spacing: 16) {

                // =====================================================
                // SEARCH BAR
                // PURPOSE:
                // Filters notes in real-time.
                // =====================================================
                TextField("Search notes...", text: $viewModel.searchText)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)

                // =====================================================
                // INPUT SECTION
                // PURPOSE:
                // User creates new notes here.
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
                // PURPOSE:
                // Sends new note to ViewModel after validation.
                // =====================================================
                Button {

                    let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
                    let trimmedContent = content.trimmingCharacters(in: .whitespacesAndNewlines)

                    guard !trimmedTitle.isEmpty || !trimmedContent.isEmpty else { return }

                    viewModel.addNote(title: trimmedTitle, content: trimmedContent)

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
                // LIST
                // PURPOSE:
                // Displays filtered + sorted notes.
                // =====================================================
                List {

                    // =====================================================
                    // EMPTY STATE
                    // PURPOSE:
                    // Shows when no notes exist or match search.
                    // =====================================================
                    if viewModel.filteredNotes.isEmpty {

                        VStack(spacing: 10) {

                            Text("No Notes Found")
                                .font(.headline)

                            Text("Add your first note to get started")
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }

                    // =====================================================
                    // NOTE ITEMS
                    // =====================================================
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
                        // PURPOSE:
                        // Quick actions (delete/pin/edit)
                        // =====================================================
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {

                            Button(role: .destructive) {

                                viewModel.deleteNote(id: note.id)
                                showUndo = true

                            } label: {
                                Label("Delete", systemImage: "trash")
                            }

                            Button {

                                viewModel.togglePin(id: note.id)

                            } label: {
                                Label("Pin", systemImage: "pin")
                            }
                            .tint(.orange)
                        }
                    }
                }

                // =====================================================
                // UNDO BAR
                // PURPOSE:
                // Allows user to restore deleted note.
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
