
import SwiftUI

// =====================================================
// DASHBOARD VIEW (AI PRODUCT LEVEL)
// =====================================================
// PURPOSE:
// - Central intelligence dashboard
// - Shows live memory analytics + AI suggestions
// - Feels like a real AI product UI
// =====================================================

struct DashboardView: View {

    // =====================================================
    // SHARED APP STATE
    // =====================================================
    @EnvironmentObject var appState: AppState

    var viewModel: MemoryViewModel {
        appState.memoryViewModel
    }

    var body: some View {

        ScrollView {

            VStack(spacing: 22) {

                // =====================================================
                // HEADER
                // =====================================================
                VStack(spacing: 6) {

                    Text("AI Dashboard")
                        .font(.largeTitle)
                        .bold()

                    Text("RecallQ Intelligent Memory System")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }

                // =====================================================
                // AI INSIGHT CARD
                // =====================================================
                VStack(alignment: .leading, spacing: 8) {

                    Text("🧠 AI Insight")
                        .font(.headline)

                    Text(
                        viewModel.memories.isEmpty
                        ? "No data available. Start adding memories to activate AI analysis."
                        : "System analyzing \(viewModel.memories.count) memories across \(viewModel.allTags.count) categories."
                    )
                    .font(.body)
                    .foregroundColor(.gray)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(14)

                // =====================================================
                // STATS GRID
                // =====================================================
                HStack(spacing: 12) {

                    StatCard(
                        title: "Memories",
                        value: "\(viewModel.memories.count)"
                    )

                    StatCard(
                        title: "Tags",
                        value: "\(viewModel.allTags.count)"
                    )
                }

                HStack(spacing: 12) {

                    StatCard(
                        title: "Suggestions",
                        value: "\(viewModel.suggestedMemories.count)"
                    )

                    StatCard(
                        title: "Status",
                        value: viewModel.memories.isEmpty ? "Idle" : "Active"
                    )
                }

                // =====================================================
                // SMART SUGGESTIONS
                // =====================================================
                VStack(alignment: .leading, spacing: 12) {

                    Text("🔮 Smart Suggestions")
                        .font(.headline)

                    if viewModel.suggestedMemories.isEmpty {

                        Text("Add memories to activate AI recommendation engine.")
                            .foregroundColor(.gray)
                            .font(.subheadline)

                    } else {

                        ForEach(viewModel.suggestedMemories) { memory in

                            VStack(alignment: .leading, spacing: 4) {

                                Text(memory.title)
                                    .font(.headline)

                                Text(memory.summary)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .padding(10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.gray.opacity(0.12))
                            .cornerRadius(10)
                        }
                    }
                }

                // =====================================================
                // NAVIGATION BUTTONS
                // =====================================================
                VStack(spacing: 12) {

                    NavigationLink {
                        MemoriesView()
                    } label: {
                        Text("Open Memories")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }

                    NavigationLink {
                        NotesView()
                    } label: {
                        Text("Open Notes")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Dashboard")
        .navigationBarTitleDisplayMode(.large)

        // IMPORTANT: ensures suggestions always refresh correctly
        .onAppear {
            viewModel.generateSuggestions()
        }
    }
}
