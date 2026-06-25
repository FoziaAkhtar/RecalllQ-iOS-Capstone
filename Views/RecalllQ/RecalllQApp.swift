
import SwiftUI


 // ==========================================
 // RECALLQ APP ENTRY POINT
//  ==========================================

//  PURPOSE:
//  - This file launches the entire app
// - It controls the root navigation
// - Everything starts here
// ============================================

//  FLOW:
//  WelcomeView → DashboardView → Other Screens
// =============================================

@main
struct RecalllQApp: App {

    var body: some Scene {

        WindowGroup {

            // **
            // NavigationStack is used to enable:
            // - Push navigation
            // - Back button support
            // - Smooth screen transitions
            // **

            NavigationStack {

                // FIRST SCREEN OF APP
                WelcomeView()
            }
        }
    }
}
