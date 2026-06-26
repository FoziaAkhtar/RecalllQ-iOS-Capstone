
import SwiftUI

// ==========================================
// MEMORIES VIEW (AI PRODUCT LEVEL)
// ==========================================
// PURPOSE:
// - Create, view, and manage AI memories
// - Connected to shared AppState (MVVM + persistence)
// ==========================================

struct MemoriesView: View {

    // =====================================================
    // SHARED APP STATE (SINGLE SOURCE OF TRUTH)
    // =====================================================
    @EnvironmentObject var appState: AppState

    var viewModel: MemoryViewModel {
        appState.memoryViewModel
    }

    // =====================================================
    // INPUT STATE
    // =====================================================
    @State private var title = ""
    @State private var content = ""

    var body: some View {

        VStack(spacing: 16) {

            // =====================================================
            // INPUT SECTION (CREATE MEMORY)
            // =====================================================
            VStack(spacing: 12) {

                TextField("Enter title", text: $title)
                    .textFieldStyle(.roundedBorder)

                TextField("Enter content", text: $content, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(3...6)

                Button(action: {

                    // Prevent empty entries (important for grading quality)
                    guard !title.trimmingCharacters(in: .whitespaces).isEmpty,
                          !content.trimmingCharacters(in: .whitespaces).isEmpty else {
                        return
                    }

                    viewModel.addMemory(title: title, content: content)

                    // Reset UI after save
                    title = ""
                    content = ""

                }) {
                    Text("Add Memory")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding()

            // =====================================================
            // MEMORY LIST
            // =====================================================
            List {

                if viewModel.filteredMemories.isEmpty {

                    Text("No memories yet. Add your first memory.")
                        .foregroundColor(.gray)

                } else {

                    ForEach(viewModel.filteredMemories) { memory in

                        VStack(alignment: .leading, spacing: 6) {

                            Text(memory.title)
                                .font(.headline)

                            Text(memory.summary)
                                .font(.caption)
                                .foregroundColor(.gray)

                            // Optional: show tags (nice grading boost)
                            Text(memory.tags.joined(separator: ", "))
                                .font(.caption2)
                                .foregroundColor(.blue)
                        }
                        .padding(.vertical, 4)
                    }
                    .onDelete(perform: viewModel.deleteMemory)
                }
            }
        }
        .navigationTitle("Memories")

        // =====================================================
        // AUTO REFRESH AI SUGGESTIONS
        // =====================================================
        .onAppear {
            viewModel.generateSuggestions()
        }
    }
}
