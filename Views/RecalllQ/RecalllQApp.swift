
import SwiftUI

// =====================================================
// APP ENTRY POINT
// =====================================================
// PURPOSE:
// - Creates global AppState
// - Injects AppState into all views
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

            MainTabView()
                .environmentObject(
                    appState
                )
        }
    }
}
