
import SwiftUI

// =====================================================
// VIEW: DashboardView
// =====================================================
// PURPOSE:
// - Central dashboard for RecalllQ
// - Displays AI insights
// - Shows analytics
// - Provides quick navigation
// - Displays smart recommendations
// =====================================================

struct DashboardView: View {

    @EnvironmentObject var appState: AppState

    var viewModel: MemoryViewModel {
        appState.memoryViewModel
    }

    var body: some View {

        ScrollView {

            VStack(spacing: 20) {

                // =====================================================
                // HEADER
                // =====================================================
                VStack(spacing: 8) {

                    Text("RecalllQ Dashboard")
                        .font(.largeTitle)
                        .bold()

                    Text("Your Intelligent Academic Memory Assistant")
                        .foregroundColor(.secondary)
                }

                // =====================================================
                // AI INSIGHT
                // =====================================================
                VStack(alignment: .leading, spacing: 8) {

                    Text("🧠 AI Insight")
                        .font(.headline)

                    Text(
                        viewModel.memories.isEmpty
                        ? "No memories available yet. Start by creating notes and memories."
                        : "Currently tracking \(viewModel.memories.count) memories across \(viewModel.allTags.count) categories."
                    )
                    .font(.body)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color.gray.opacity(0.12))
                .cornerRadius(12)

                // =====================================================
                // DASHBOARD STATISTICS
                // =====================================================
                VStack(spacing: 12) {

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
                }

                // =====================================================
                // PROGRESS SECTION (SAFE)
                // =====================================================
                VStack(alignment: .leading, spacing: 8) {

                    Text("📈 Progress")
                        .font(.headline)

                    ProgressView(
                        value: Double(min(viewModel.memories.count, 20)),
                        total: 20
                    )

                    Text("\(viewModel.memories.count) of 20 memories added")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.blue.opacity(0.08))
                .cornerRadius(12)

                // =====================================================
                // SMART SUGGESTIONS
                // =====================================================
                VStack(alignment: .leading, spacing: 10) {

                    Text("💡 Smart Suggestions")
                        .font(.headline)

                    if viewModel.suggestedMemories.isEmpty {

                        Text("No recommendations yet.")
                            .foregroundColor(.gray)

                    } else {

                        ForEach(viewModel.suggestedMemories) { memory in

                            VStack(alignment: .leading, spacing: 5) {

                                Text(memory.title)
                                    .font(.headline)

                                Text(memory.summary)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.gray.opacity(0.10))
                            .cornerRadius(10)
                        }
                    }
                }

                // =====================================================
                // QUICK NAVIGATION
                // =====================================================
                VStack(spacing: 12) {

                    NavigationLink {

                        NotesView()

                    } label: {

                        Text("📝 Open Notes")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }

                    NavigationLink {

                        MemoriesView()

                    } label: {

                        Text("🧠 Open Memories")
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
        .onAppear {
            viewModel.generateSuggestions()
        }
    }
}
#Preview {
    DashboardView()
        .environmentObject(AppState())
}
