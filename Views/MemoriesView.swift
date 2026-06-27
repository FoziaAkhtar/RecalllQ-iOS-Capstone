
import SwiftUI

// =====================================================
// VIEW: MemoriesView
// =====================================================

struct MemoriesView: View {

    @EnvironmentObject var appState: AppState

    var body: some View {

        VStack(spacing: 12) {

            // =====================================================
            // SEARCH BAR 
            // =====================================================
            TextField(
                "Search memories...",
                text: Binding(
                    get: { appState.memoryViewModel.searchText },
                    set: { appState.memoryViewModel.searchText = $0 }
                )
            )
            .textFieldStyle(.roundedBorder)
            .padding(.horizontal)

            // =====================================================
            // TAG FILTER
            // =====================================================
            ScrollView(.horizontal, showsIndicators: false) {

                HStack(spacing: 10) {

                    Button {
                        appState.memoryViewModel.selectedTag = "all"
                    } label: {
                        Text("All")
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(appState.memoryViewModel.selectedTag == "all" ? Color.blue : Color.gray.opacity(0.2))
                            .foregroundColor(appState.memoryViewModel.selectedTag == "all" ? .white : .primary)
                            .cornerRadius(10)
                    }

                    ForEach(appState.memoryViewModel.allTags, id: \.self) { tag in

                        Button {
                            appState.memoryViewModel.selectedTag = tag
                        } label: {
                            Text(tag)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(appState.memoryViewModel.selectedTag == tag ? Color.blue : Color.gray.opacity(0.2))
                                .foregroundColor(appState.memoryViewModel.selectedTag == tag ? .white : .primary)
                                .cornerRadius(10)
                        }
                    }
                }
                .padding(.horizontal)
            }

            // =====================================================
            // LIST
            // =====================================================
            List {

                if appState.memoryViewModel.filteredMemories.isEmpty {
                    Text("No memories found")
                        .foregroundColor(.gray)
                }

                ForEach(appState.memoryViewModel.filteredMemories) { memory in

                    VStack(alignment: .leading, spacing: 6) {

                        Text(memory.title)
                            .font(.headline)

                        Text(memory.summary)
                            .font(.subheadline)
                            .foregroundColor(.gray)

                        HStack {
                            ForEach(memory.tags, id: \.self) { tag in
                                Text(tag)
                                    .font(.caption)
                                    .padding(5)
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(6)
                            }
                        }
                    }
                    .padding(.vertical, 6)

                    .swipeActions {
                        Button(role: .destructive) {
                            appState.memoryViewModel.deleteMemory(id: memory.id)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
        }
        .navigationTitle("Memories")
    }
}
#Preview {
    MemoriesView()
        .environmentObject(AppState())
}
