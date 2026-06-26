
import SwiftUI

// =====================================================
// VIEW: NotesView (FIXED FOR APPSTATE ARCHITECTURE)
// =====================================================

struct NotesView: View {

    // =====================================================
    // SHARED APP STATE
    // =====================================================
    @EnvironmentObject var appState: AppState

    var viewModel: NotesViewModel {
        appState.notesViewModel
    }

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

                // =================================================
                // SEARCH FIELD
                // =================================================
                TextField("Search notes...", text: $viewModel.searchText)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)

                // =================================================
                // INPUT FIELDS
                // =================================================
                VStack(spacing: 10) {

                    TextField("Enter title", text: $title)
                        .textFieldStyle(.roundedBorder)
                        .focused($isInputFocused)

                    TextField("Enter content", text: $content)
                        .textFieldStyle(.roundedBorder)
                        .focused($isInputFocused)
                }
                .padding(.horizontal)

                // =================================================
                // ADD BUTTON
                // =================================================
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

                // =================================================
                // LIST
                // =================================================
                List {

                    if viewModel.filteredNotes.isEmpty {
                        Text("No Notes Found")
                            .foregroundColor(.gray)
                    }

                    ForEach(viewModel.filteredNotes) { note in

                        VStack(alignment: .leading, spacing: 6) {

                            HStack {
                                Text(note.title).bold()
                                Spacer()
                                Image(systemName: note.isPinned ? "pin.fill" : "pin")
                                    .foregroundColor(.orange)
                            }

                            Text(note.content)
                                .foregroundColor(.gray)
                        }

                        // =================================================
                        // SWIPE ACTIONS (FIXED LOCATION)
                        // =================================================
                        .swipeActions {

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

                // =================================================
                // UNDO BAR
                // =================================================
                if showUndo {

                    HStack {
                        Text("Note deleted")
                        Spacer()

                        Button("Undo") {
                            viewModel.undoDelete()
                            showUndo = false
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    .padding(.horizontal)
                }
            }
            .navigationTitle("Notes")
        }
    }
}
