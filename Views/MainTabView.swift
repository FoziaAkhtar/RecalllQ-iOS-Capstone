
import SwiftUI

// =====================================================
// MAIN TAB VIEW
// =====================================================
// PURPOSE:
// - Central navigation hub
// - Ensures AppState is always available
// =====================================================

struct MainTabView: View {

    @EnvironmentObject var appState: AppState

    var body: some View {

        TabView {

            // =================================================
            // DASHBOARD TAB
            // =================================================
            NavigationStack {
                DashboardView()
                    .environmentObject(appState) 
            }
            .tabItem {
                Label("Dashboard", systemImage: "brain.head.profile")
            }

            // =================================================
            // NOTES TAB
            // =================================================
            NavigationStack {
                NotesView()
                    .environmentObject(appState)
            }
            .tabItem {
                Label("Notes", systemImage: "note.text")
            }

            // =================================================
            // MEMORIES TAB
            // =================================================
            NavigationStack {
                MemoriesView()
                    .environmentObject(appState)
            }
            .tabItem {
                Label("Memories", systemImage: "sparkles")
            }
        }
    }
}
