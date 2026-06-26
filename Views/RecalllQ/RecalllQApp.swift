
import SwiftUI

// =====================================================
// RECALLQ APP ENTRY POINT
// =====================================================
// PURPOSE:
// - Starts the app
// - Creates global AppState
// - Injects it into entire environment
// =====================================================

@main
struct RecalllQApp: App {

    // =====================================================
    // SINGLE GLOBAL STATE OBJECT
    // =====================================================
    @StateObject private var appState = AppState()

    var body: some Scene {

        WindowGroup {

            // =================================================
            // ROOT NAVIGATION
            // =================================================
            NavigationStack {

                // FIRST SCREEN
                WelcomeView()
            }
            .environmentObject(appState)
        }
    }
}
