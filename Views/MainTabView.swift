
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
// - Resets Settings navigation when switching accounts
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
    // SETTINGS NAVIGATION RESET
    // =====================================================

    //
    // WHY THIS EXISTS:
    //
    // Settings contains additional NavigationLinks such as:
    //
    // Settings
    //     ↓
    // Switch Account
    //     ↓
    // Continue as Guest
    //
    // When AppState changes selectedTab from 5 → 0,
    // SwiftUI can sometimes keep the Settings NavigationStack
    // alive.
    //
    // This ID forces the Settings NavigationStack to be
    // recreated whenever the selected tab changes.
    // =====================================================

    @State private var settingsNavigationID = UUID()

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

                // =================================================
                // IMPORTANT:
                // FlashcardsView now observes FlashcardViewModel
                // directly.
                //
                // This allows SwiftUI to detect changes to:
                //
                // - currentIndex
                // - currentFlashcard
                // - isShowingAnswer
                // - flashcards
                //
                // This is required for the Next / Previous buttons
                // to refresh the displayed question correctly.
                // =================================================

                FlashcardsView(
                    viewModel: appState.flashcardViewModel
                )
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

            // =================================================
            // SETTINGS NAVIGATION RESET
            // =================================================

            //
            // Every time selectedTab changes, this ID changes.
            //
            // If the user was deep inside Settings and switches
            // to another tab, SwiftUI receives a fresh Settings
            // NavigationStack the next time Settings is opened.
            // =================================================

            .id(settingsNavigationID)

            .tabItem {

                Label(
                    "Settings",
                    systemImage: "gearshape.fill"
                )
            }

            .tag(5)
        }

        // =====================================================
        // WATCH FOR TAB CHANGES
        // =====================================================

        //
        // When the app moves away from Settings, reset the
        // Settings NavigationStack.
        //
        // This is especially important for:
        //
        // Account A
        //     ↓
        // Settings
        //     ↓
        // Switch Account
        //     ↓
        // Continue as Guest
        //     ↓
        // Dashboard
        //
        // The Dashboard tab will now become the visible root
        // screen instead of leaving the Settings navigation
        // hierarchy on screen.
        // =====================================================

        .onChange(of: appState.selectedTab) { _, newTab in

            if newTab != 5 {

                settingsNavigationID = UUID()
            }
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
