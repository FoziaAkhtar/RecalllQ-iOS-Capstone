
import SwiftUI

// ========================================
// SETTINGS VIEW
// ========================================
// PURPOSE:
// - App settings screen
// - Future-ready for user preferences
// - Clean MVVM-compatible structure
// ========================================

struct SettingsView: View {

    // =====================================================
    // GLOBAL STATE (READY FOR FUTURE SETTINGS)
    // =====================================================
    @EnvironmentObject var appState: AppState

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
                        Text(appName)
                            .foregroundColor(.gray)
                    }

                    HStack {
                        Text("Version")
                        Spacer()
                        Text(appVersion)
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
                // FEATURES SECTION
                // ========================================
                Section(header: Text("Features")) {

                    Text("• AI Memory Engine")
                    Text("• Smart Notes")
                    Text("• Reminder System")
                }

                // ========================================
                // DEBUG SECTION (OPTIONAL BUT USEFUL)
                // ========================================
                Section(header: Text("Debug")) {

                    Button("Reset App Data") {
                        resetAppData()
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Settings")
        }
    }

    // =====================================================
    // APP INFO (CENTRALIZED)
    // =====================================================
    private var appName: String {
        "RecalllQ"
    }

    private var appVersion: String {
        "1.0"
    }

    // =====================================================
    // RESET FUNCTION (FUTURE USE)
    // =====================================================
    private func resetAppData() {
        appState.notesViewModel.notes.removeAll()
        appState.memoryViewModel.memories.removeAll()

        UserDefaults.standard.removeObject(forKey: "saved_notes")
    }
}
