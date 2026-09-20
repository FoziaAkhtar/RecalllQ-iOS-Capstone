import SwiftUI

// =====================================================
// MAIN TAB VIEW
// =====================================================
// PURPOSE:
// Central navigation hub for RecalllQ.
//
// FEATURES:
//
// - Dashboard navigation
// - Notes navigation
// - Memories navigation
// - Flashcards navigation
// - Custom More navigation
// - Uses global AppState
// - Uses RecalllQTheme for visual styling
// - Resets More navigation when switching tabs
//
// TAB INDEX:
//
// 0 = Dashboard
// 1 = Notes
// 2 = Memories
// 3 = Flashcards
// 4 = More
//
// MORE SCREEN:
//
// More
//    ↓
// Quiz
// AI Study Chat
// Settings
//
// IMPORTANT:
//
// Previously RecalllQ had seven separate tabs:
//
// 0 = Dashboard
// 1 = Notes
// 2 = Memories
// 3 = Flashcards
// 4 = Quiz
// 5 = AI Chat
// 6 = Settings
//
// Because there were more than five tabs, SwiftUI automatically
// created its own system "More" screen.
//
// That automatic More screen did not use RecalllQTheme.background.
//
// We now use a custom MoreView so RecalllQ controls the complete
// appearance and navigation of the More screen.
// =====================================================

struct MainTabView: View {

    // =====================================================
    // GLOBAL APP STATE
    // =====================================================

    @EnvironmentObject var appState: AppState

    // =====================================================
    // MORE NAVIGATION RESET
    // =====================================================
    //
    // WHY THIS EXISTS:
    //
    // The custom More screen contains navigation to:
    //
    // More
    //     ↓
    // Quiz
    //
    // More
    //     ↓
    // AI Study Chat
    //
    // More
    //     ↓
    // Settings
    //
    // When the user switches away from More, SwiftUI can
    // sometimes keep the navigation hierarchy alive.
    //
    // This ID forces the More navigation hierarchy to be
    // recreated when the user leaves the More tab.
    // =====================================================

    @State private var moreNavigationID = UUID()

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
                //
                // FlashcardsView observes FlashcardViewModel
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
            // MORE
            // =================================================
            //
            // PURPOSE:
            //
            // Provides access to secondary RecalllQ features.
            //
            // The custom MoreView contains:
            //
            // - Quiz
            // - AI Study Chat
            // - Settings
            //
            // This replaces the automatic SwiftUI More screen.
            // =================================================

            NavigationStack {

                MoreView()
                    .environmentObject(appState)

            }
            // =================================================
            // MORE NAVIGATION RESET
            // =================================================
            //
            // Every time the user leaves the More tab,
            // moreNavigationID changes.
            //
            // This causes the More NavigationStack to be
            // recreated the next time More is opened.
            // =================================================

            .id(moreNavigationID)

            .tabItem {

                Label(
                    "More",
                    systemImage: "ellipsis.circle.fill"
                )

            }
            .tag(4)
        }

        // =====================================================
        // WATCH FOR TAB CHANGES
        // =====================================================
        //
        // When the user moves away from More, reset the
        // More NavigationStack.
        //
        // Example:
        //
        // More
        //     ↓
        // Settings
        //     ↓
        // Switch Account
        //     ↓
        // Continue as Guest
        //     ↓
        // Dashboard
        //
        // When the user returns to More later, the More screen
        // starts from its root instead of keeping the previous
        // navigation hierarchy.
        // =====================================================

        .onChange(
            of: appState.selectedTab
        ) { _, newTab in

            if newTab != 4 {

                moreNavigationID = UUID()

            }
        }

        // =====================================================
        // TAB BAR APPEARANCE
        // =====================================================

        .tint(
            RecalllQTheme.primary
        )
    }
}

// =====================================================
// PREVIEW
// =====================================================

#Preview {

    MainTabView()
        .environmentObject(
            AppState()
        )
}
