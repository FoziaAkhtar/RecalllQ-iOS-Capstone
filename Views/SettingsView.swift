
import SwiftUI


// ========================================
// SETTINGS VIEW
// ========================================

//  PURPOSE:
//  - App settings screen
//  - Shows app info
//  - Future user preferences
// ===========================================

struct SettingsView: View {

    var body: some View {

        Form {

            Section(header: Text("App Info")) {

                Text("RecallQ")
                Text("Version 1.0")
            }

            Section(header: Text("Account")) {

                Text("User Profile (coming soon)")
            }
        }
        .navigationTitle("Settings")
    }
}
