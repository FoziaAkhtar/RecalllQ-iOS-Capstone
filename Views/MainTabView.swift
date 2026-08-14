
import SwiftUI

// =====================================================
// MAIN TAB VIEW
// =====================================================
// PURPOSE:
// - Central navigation hub for RecalllQ
// - Provides access to all major learning features
// - Keeps AppState available to every screen
//
// TABS:
// 1. Dashboard
// 2. Notes
// 3. Memories
// 4. Flashcards
// =====================================================

struct MainTabView: View {

    // =====================================================
    // GLOBAL APP STATE
    // =====================================================

    @EnvironmentObject var appState: AppState

    // =====================================================
    // BODY
    // =====================================================

    var body: some View {

        TabView {

            // =================================================
            // DASHBOARD
            // =================================================

            NavigationStack {

                DashboardView()
                    .environmentObject(appState)
            }
            .tabItem {

                Label(
                    "Dashboard",
                    systemImage:
                        "brain.head.profile"
                )
            }

            // =================================================
            // NOTES
            // =================================================

            NavigationStack {

                NotesView()
                    .environmentObject(appState)
            }
            .tabItem {

                Label(
                    "Notes",
                    systemImage:
                        "note.text"
                )
            }

            // =================================================
            // MEMORIES
            // =================================================

            NavigationStack {

                MemoriesView()
                    .environmentObject(appState)
            }
            .tabItem {

                Label(
                    "Memories",
                    systemImage:
                        "sparkles"
                )
            }

            // =================================================
            // FLASHCARDS
            // =================================================

            NavigationStack {

                FlashcardsView()
                    .environmentObject(appState)
            }
            .tabItem {

                Label(
                    "Flashcards",
                    systemImage:
                        "rectangle.on.rectangle"
                )
            }
        }
    }
}
