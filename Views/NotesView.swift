
import SwiftUI

// =====================================================
// VIEW: NotesView 
// =====================================================

struct NotesView: View {

    // =====================================================
    // GLOBAL STATE (ONLY SOURCE OF TRUTH)
    // =====================================================
    @EnvironmentObject var appState: AppState

    // =====================================================
    // LOCAL UI STATE
    // =====================================================
    @State private var title = ""
    @State private var content = ""
    @FocusState private var isInputFocused: Bool
    @State private var showUndo = false

    var body: some View {

        NavigationStack {

            VStack(spacing: 12) {

                // =====================================================
                // SEARCH (SAFE DIRECT BINDING)
                // =====================================================
                TextField(
                    "Search notes...",
                    text: Binding(
                        get: { appState.notesViewModel.searchText },
                        set: { appState.notesViewModel.searchText = $0 }
                    )
                )
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)

                // =====================================================
                // INPUT
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

                    let cleanTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
                    let cleanContent = content.trimmingCharacters(in: .whitespacesAndNewlines)

                    guard !cleanTitle.isEmpty || !cleanContent.isEmpty else { return }

                    appState.notesViewModel.addNote(
                        title: cleanTitle,
                        content: cleanContent
                    )

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
                // =====================================================
                List {

                    ForEach(appState.notesViewModel.filteredNotes) { note in

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
                        .swipeActions {

                            Button(role: .destructive) {
                                appState.notesViewModel.deleteNote(id: note.id)
                                showUndo = true
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }

                            Button {
                                appState.notesViewModel.togglePin(id: note.id)
                            } label: {
                                Label("Pin", systemImage: "pin")
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
                            appState.notesViewModel.undoDelete()
                            showUndo = false
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Notes")
        }
    }
}
#Preview {
    NotesView()
        .environmentObject(AppState())
}
