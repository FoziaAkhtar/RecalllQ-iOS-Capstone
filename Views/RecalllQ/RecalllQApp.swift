
import SwiftUI

// =====================================================
// APP ENTRY POINT
// =====================================================
// PURPOSE:
// - Creates global AppState
// - Injects AppState into all views
// - Controls authentication flow
// - Shows WelcomeView when user is not signed in
// - Shows MainTabView when user is signed in
// - Provides RecalllQ as the root application
// =====================================================

@main
struct RecalllQApp: App {

    // =====================================================
    // GLOBAL APP STATE
    // =====================================================

    @StateObject private var appState = AppState()

    // =====================================================
    // BODY
    // =====================================================

    var body: some Scene {

        WindowGroup {

            if appState.isAuthenticated {

                // =================================================
                // AUTHENTICATED USER
                // =================================================

                MainTabView()
                    .environmentObject(
                        appState
                    )

            } else {

                // =================================================
                // NOT AUTHENTICATED
                // =================================================

                WelcomeView()
                    .environmentObject(
                        appState
                    )
            }
        }
    }
}
