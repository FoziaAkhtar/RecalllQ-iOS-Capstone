
import SwiftUI

// =========================================
// SEARCH VIEW (CONNECTED + FUNCTIONAL)
// =========================================
// PURPOSE:
// - Search across Notes + Memories
// - Uses MVVM (AppState)
// - Foundation for future AI search upgrade
// ==========================================

struct SearchView: View {

    // =====================================================
    // SHARED APP STATE
    // =====================================================
    @EnvironmentObject var appState: AppState

    // =====================================================
    // LOCAL SEARCH INPUT
    // =====================================================
    @State private var searchText: String = ""

    var body: some View {

        NavigationStack {

            VStack(spacing: 16) {

                // =====================================================
                // SEARCH BAR
                // =====================================================
                TextField("Search notes & memories...", text: $searchText)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)

                // =====================================================
                // NOTES RESULTS
                // =====================================================
                if !filteredNotes.isEmpty {

                    VStack(alignment: .leading, spacing: 8) {

                        Text("Notes")
                            .font(.headline)
                            .padding(.horizontal)

                        ForEach(filteredNotes) { note in

                            VStack(alignment: .leading, spacing: 4) {
                                Text(note.title).bold()
                                Text(note.content)
                                    .foregroundColor(.gray)
                                    .font(.caption)
                            }
                            .padding(.horizontal)
                        }
                    }
                }

                // =====================================================
                // MEMORIES RESULTS
                // =====================================================
                if !filteredMemories.isEmpty {

                    VStack(alignment: .leading, spacing: 8) {

                        Text("Memories")
                            .font(.headline)
                            .padding(.horizontal)

                        ForEach(filteredMemories) { memory in

                            VStack(alignment: .leading, spacing: 4) {
                                Text(memory.title).bold()
                                Text(memory.summary)
                                    .foregroundColor(.gray)
                                    .font(.caption)
                            }
                            .padding(.horizontal)
                        }
                    }
                }

                // =====================================================
                // EMPTY STATE
                // =====================================================
                if filteredNotes.isEmpty && filteredMemories.isEmpty {

                    Spacer()

                    Text("No results found")
                        .foregroundColor(.gray)

                    Spacer()
                }
            }
            .navigationTitle("Search")
        }
    }

    // =====================================================
    // FILTERED NOTES
    // =====================================================
    private var filteredNotes: [Note] {

        guard !searchText.isEmpty else { return [] }

        return appState.notesViewModel.notes.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.content.localizedCaseInsensitiveContains(searchText)
        }
    }

    // =====================================================
    // FILTERED MEMORIES
    // =====================================================
    private var filteredMemories: [Memory] {

        guard !searchText.isEmpty else { return [] }

        return appState.memoryViewModel.memories.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.content.localizedCaseInsensitiveContains(searchText)
        }
    }
}
