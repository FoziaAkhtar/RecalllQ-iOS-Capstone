
import SwiftUI

// =====================================================
// VIEW: MemoriesView
// =====================================================
// PURPOSE:
// Displays all AI-generated memories.
// =====================================================

struct MemoriesView: View {

    // =====================================================
    // VIEW MODEL
    // =====================================================
    @StateObject private var viewModel = MemoryViewModel()

    // =====================================================
    // MAIN VIEW
    // =====================================================
    var body: some View {

        NavigationStack {

            List {

                // =====================================================
                // MEMORY LIST
                // =====================================================
                ForEach(viewModel.memories) { memory in

                    VStack(alignment: .leading, spacing: 8) {

                        // =====================================================
                        // MEMORY TITLE
                        // =====================================================
                        Text(memory.title)
                            .font(.headline)

                        // =====================================================
                        // MEMORY SUMMARY
                        // =====================================================
                        Text(memory.summary)
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        // =====================================================
                        // MEMORY TAGS
                        // =====================================================
                        HStack {

                            ForEach(memory.tags, id: \.self) { tag in

                                Text("#\(tag)")
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.blue.opacity(0.15))
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }

            }
            .navigationTitle("Memories")
        }
    }
}

// =====================================================
// PREVIEW
// =====================================================

#Preview {
    MemoriesView()
}
