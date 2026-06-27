
import SwiftUI

// =========================================
// SEARCH VIEW (CONNECTED + FUNCTIONAL)
// =========================================

struct SearchView: View {

    @EnvironmentObject var appState: AppState

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
                // EMPTY SEARCH STATE (IMPROVED UX)
                // =====================================================
                if searchText.isEmpty {

                    Spacer()

                    Text("Start typing to search notes and memories")
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding()

                    Spacer()
                }

                // =====================================================
                // RESULTS
                // =====================================================
                else {

                    ScrollView {

                        VStack(alignment: .leading, spacing: 20) {

                            // =========================
                            // NOTES SECTION
                            // =========================
                            if !filteredNotes.isEmpty {

                                Text("Notes")
                                    .font(.headline)
                                    .padding(.horizontal)

                                ForEach(filteredNotes) { note in

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(note.title)
                                            .font(.subheadline)
                                            .bold()

                                        Text(note.content)
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    .padding(.horizontal)
                                }
                            }

                            // =========================
                            // MEMORIES SECTION
                            // =========================
                            if !filteredMemories.isEmpty {

                                Text("Memories")
                                    .font(.headline)
                                    .padding(.horizontal)

                                ForEach(filteredMemories) { memory in

                                    VStack(alignment: .leading, spacing: 4) {

                                        Text(memory.title)
                                            .font(.subheadline)
                                            .bold()

                                        Text(memory.summary.isEmpty ? memory.content : memory.summary)
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    .padding(.horizontal)
                                }
                            }

                            // =========================
                            // NO RESULTS STATE
                            // =========================
                            if filteredNotes.isEmpty && filteredMemories.isEmpty {

                                Spacer()

                                Text("No results found")
                                    .foregroundColor(.gray)
                                    .padding()

                                Spacer()
                            }
                        }
                    }
                }
            }
            .navigationTitle("Search")
        }
    }

    // =====================================================
    // FILTERED NOTES
    // =====================================================
    private var filteredNotes: [Note] {
        appState.notesViewModel.notes.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.content.localizedCaseInsensitiveContains(searchText)
        }
    }

    // =====================================================
    // FILTERED MEMORIES
    // =====================================================
    private var filteredMemories: [Memory] {
        appState.memoryViewModel.memories.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.content.localizedCaseInsensitiveContains(searchText)
        }
    }
}
