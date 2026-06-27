
import SwiftUI

// =====================================================
// MAIN TAB VIEW
// =====================================================
// PURPOSE:
// - Navigation system for entire app
// - Uses shared AppState from root
// =====================================================

struct MainTabView: View {

    // =====================================================
    // GLOBAL STATE (INJECTED FROM APP ROOT)
    // =====================================================
    @EnvironmentObject var appState: AppState

    var body: some View {

        TabView {

            // =================================================
            // DASHBOARD TAB
            // =================================================
            NavigationStack {
                DashboardView()
            }
            .tabItem {
                Label("Dashboard", systemImage: "brain.head.profile")
            }

            // =================================================
            // NOTES TAB
            // =================================================
            NavigationStack {
                NotesView()
            }
            .tabItem {
                Label("Notes", systemImage: "note.text")
            }

            // =================================================
            // MEMORIES TAB
            // =================================================
            NavigationStack {
                MemoriesView()
            }
            .tabItem {
                Label("Memories", systemImage: "sparkles")
            }
        }
    }
}
