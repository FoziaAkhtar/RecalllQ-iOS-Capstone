
import SwiftUI

// =====================================================
// APP ENTRY POINT
// =====================================================
// PURPOSE:
// - Creates global AppState (single source of truth)
// - Injects it into ALL views in the app
// =====================================================

@main
struct RecalllQApp: App {

    // =====================================================
    // GLOBAL APP STATE
    // =====================================================
    @StateObject private var appState = AppState()

    var body: some Scene {

        WindowGroup {

            // =================================================
            // ROOT VIEW
            // IMPORTANT: EVERYTHING MUST BE INSIDE THIS
            // =================================================
            MainTabView()
                .environmentObject(appState)
        }
    }
}
