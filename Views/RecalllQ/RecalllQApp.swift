
import SwiftUI

// =====================================================
// APP ENTRY POINT
// =====================================================
// PURPOSE:
// - Creates global AppState (single source of truth)
// - Injects it into ALL views
// - Wires ViewModels together (IMPORTANT FIX)
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
            // EVERYTHING IN THE APP STARTS HERE
            // =================================================
            MainTabView()
                .environmentObject(appState)
        }
    }
}
