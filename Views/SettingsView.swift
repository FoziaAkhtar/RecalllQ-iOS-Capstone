
import SwiftUI

// ========================================
// SETTINGS VIEW
// ========================================
// PURPOSE:
// - App settings screen
// - Displays app info
// - Placeholder for future user preferences
// - Matches capstone UI consistency
// ========================================

struct SettingsView: View {

    var body: some View {

        NavigationStack {

            Form {

                // ========================================
                // APP INFO SECTION
                // ========================================
                Section(header: Text("App Info")) {

                    HStack {
                        Text("App Name")
                        Spacer()
                        Text("RecalllQ")
                            .foregroundColor(.gray)
                    }

                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0")
                            .foregroundColor(.gray)
                    }
                }

                // ========================================
                // ACCOUNT SECTION
                // ========================================
                Section(header: Text("Account")) {

                    Text("User Profile (coming soon)")
                        .foregroundColor(.gray)
                }

                // ========================================
                // FUTURE FEATURES SECTION
                // ========================================
                Section(header: Text("Features")) {

                    Text("• AI Memory Engine")
                    Text("• Smart Notes")
                    Text("• Reminder System")
                }
            }
            .navigationTitle("Settings")
        }
    }
}
