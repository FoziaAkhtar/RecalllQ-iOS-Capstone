
import SwiftUI

// =====================================================
// VIEW: MemoriesView
// =====================================================

struct MemoriesView: View {

    @EnvironmentObject var appState: AppState

    // Shortcut (cleaner + safer)
    private var vm: MemoryViewModel {
        appState.memoryViewModel
    }

    var body: some View {

        VStack(spacing: 12) {

            // =====================================================
            // SEARCH BAR
            // =====================================================
            TextField(
                "Search memories...",
                text: Binding(
                    get: { vm.searchText },
                    set: { vm.searchText = $0 }
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
                        vm.selectedTag = "all"
                    } label: {
                        Text("All")
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(vm.selectedTag == "all" ? Color.blue : Color.gray.opacity(0.2))
                            .foregroundColor(vm.selectedTag == "all" ? .white : .primary)
                            .cornerRadius(10)
                    }

                    ForEach(vm.allTags, id: \.self) { tag in

                        Button {
                            vm.selectedTag = tag
                        } label: {
                            Text(tag)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(vm.selectedTag == tag ? Color.blue : Color.gray.opacity(0.2))
                                .foregroundColor(vm.selectedTag == tag ? .white : .primary)
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

                // EMPTY STATE (FIXED UX)
                if vm.filteredMemories.isEmpty {
                    Text("No memories found")
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                }

                ForEach(vm.filteredMemories) { memory in

                    VStack(alignment: .leading, spacing: 6) {

                        Text(memory.title)
                            .font(.headline)

                        Text(memory.summary.isEmpty ? memory.content : memory.summary)
                            .font(.subheadline)
                            .foregroundColor(.gray)

                        if !memory.tags.isEmpty {
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
                    }
                    .padding(.vertical, 6)

                    .swipeActions {
                        Button(role: .destructive) {
                            vm.deleteMemory(id: memory.id)
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
