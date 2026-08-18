
import SwiftUI

// =====================================================
// MAIN TAB VIEW
// =====================================================
// PURPOSE:
// Central navigation hub for RecalllQ.
//
// FEATURES:
// - Dashboard navigation
// - Notes navigation
// - Memories navigation
// - Flashcards navigation
// - Quiz navigation
// - Settings navigation
// - Uses global AppState
// - Uses RecalllQTheme for visual styling
//
// TAB INDEX:
// 0 = Dashboard
// 1 = Notes
// 2 = Memories
// 3 = Flashcards
// 4 = Quiz
// 5 = Settings
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

        TabView(
            selection: $appState.selectedTab
        ) {

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
                    systemImage: "brain.head.profile"
                )

            }
            .tag(0)

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
                    systemImage: "note.text"
                )

            }
            .tag(1)

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
                    systemImage: "brain.head.profile"
                )

            }
            .tag(2)

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
                    systemImage: "rectangle.on.rectangle"
                )

            }
            .tag(3)

            // =================================================
            // QUIZ
            // =================================================

            NavigationStack {

                QuizView()
                    .environmentObject(appState)

            }
            .tabItem {

                Label(
                    "Quiz",
                    systemImage: "questionmark.circle.fill"
                )

            }
            .tag(4)

            // =================================================
            // SETTINGS
            // =================================================

            NavigationStack {

                SettingsView()
                    .environmentObject(appState)

            }
            .tabItem {

                Label(
                    "Settings",
                    systemImage: "gearshape.fill"
                )

            }
            .tag(5)
        }

        // =====================================================
        // TAB BAR APPEARANCE
        // =====================================================

        .tint(RecalllQTheme.primary)
    }
}

// =====================================================
// PREVIEW
// =====================================================

#Preview {

    MainTabView()
        .environmentObject(AppState())
}
