
import SwiftUI

// =====================================================
// MAIN TAB VIEW (CAPSTONE STRUCTURE)
// =====================================================
// PURPOSE:
// - Central navigation system for RecalllQ
// - Replaces scattered NavigationLinks
// - Scalable architecture for future features
// =====================================================

struct MainTabView: View {

    @EnvironmentObject var appState: AppState

    var body: some View {

        TabView {

            // =====================================================
            // DASHBOARD TAB
            // =====================================================
            NavigationStack {
                DashboardView()
            }
            .tabItem {
                Image(systemName: "brain")
                Text("Dashboard")
            }

            // =====================================================
            // NOTES TAB
            // =====================================================
            NavigationStack {
                NotesView()
            }
            .tabItem {
                Image(systemName: "note.text")
                Text("Notes")
            }

            // =====================================================
            // MEMORIES TAB
            // =====================================================
            NavigationStack {
                MemoriesView()
            }
            .tabItem {
                Image(systemName: "sparkles")
                Text("Memories")
            }
        }
    }
}
