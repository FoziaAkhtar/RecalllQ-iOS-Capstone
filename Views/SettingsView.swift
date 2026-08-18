
import SwiftUI

// ========================================
// SETTINGS VIEW
// ========================================
// PURPOSE:
// - App settings screen
// - AI configuration
// - OpenAI API key management
// - App information
// - Account information
// - Feature information
// - Reset options
// - Sign out
// ========================================

struct SettingsView: View {

    // =====================================================
    // GLOBAL APP STATE
    // =====================================================

    @EnvironmentObject var appState: AppState

    // =====================================================
    // SIGN OUT CONFIRMATION
    // =====================================================

    @State private var showSignOutConfirmation = false

    // =====================================================
    // BODY
    // =====================================================

    var body: some View {

        NavigationStack {

            Form {

                // ========================================
                // AI & INTELLIGENCE
                // ========================================

                Section(header: Text("AI & Intelligence")) {

                    NavigationLink {

                        APIKeySettingsView()

                    } label: {

                        HStack(spacing: 12) {

                            Image(systemName: "key.fill")
                                .foregroundColor(
                                    RecalllQTheme.smartPurple
                                )

                            VStack(
                                alignment: .leading,
                                spacing: 3
                            ) {

                                Text("OpenAI API Key")
                                    .font(.body)
                                    .fontWeight(.medium)

                                Text(
                                    "Configure AI-powered quiz generation"
                                )
                                .font(.caption)
                                .foregroundColor(
                                    RecalllQTheme.secondaryText
                                )
                            }

                            Spacer()
                        }
                    }

                    HStack(spacing: 12) {

                        Image(
                            systemName: "brain.head.profile"
                        )
                        .foregroundColor(
                            RecalllQTheme.smartPurple
                        )

                        VStack(
                            alignment: .leading,
                            spacing: 3
                        ) {

                            Text("AI Memory Engine")
                                .font(.body)
                                .fontWeight(.medium)

                            Text(
                                "Converts notes into structured memories"
                            )
                            .font(.caption)
                            .foregroundColor(
                                RecalllQTheme.secondaryText
                            )
                        }

                        Spacer()
                    }
                }

                // ========================================
                // APP INFO
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
                // ACCOUNT
                // ========================================

                Section(header: Text("Account")) {

                    HStack(spacing: 12) {

                        Image(
                            systemName: "person.circle.fill"
                        )
                        .foregroundColor(
                            RecalllQTheme.primary
                        )

                        Text("User Profile")

                        Spacer()

                        Text("Active")
                            .font(.caption)
                            .foregroundColor(
                                RecalllQTheme.success
                            )
                    }

                    // ========================================
                    // SIGN OUT BUTTON
                    // ========================================

                    Button {

                        showSignOutConfirmation = true

                    } label: {

                        HStack(spacing: 12) {

                            Image(
                                systemName: "rectangle.portrait.and.arrow.right"
                            )
                            .foregroundColor(
                                RecalllQTheme.error
                            )

                            Text("Sign Out")
                                .foregroundColor(
                                    RecalllQTheme.error
                                )

                            Spacer()
                        }
                    }
                }

                // ========================================
                // FEATURES
                // ========================================

                Section(header: Text("Features")) {

                    Label(
                        "AI Memory Engine",
                        systemImage: "brain.head.profile"
                    )

                    Label(
                        "Smart Notes",
                        systemImage: "note.text"
                    )

                    Label(
                        "Flashcards",
                        systemImage: "rectangle.on.rectangle"
                    )

                    Label(
                        "AI Quiz Generation",
                        systemImage: "questionmark.circle.fill"
                    )

                    Label(
                        "Reminder System",
                        systemImage: "bell.fill"
                    )

                    Label(
                        "Study Sessions",
                        systemImage: "book.fill"
                    )
                }

                // ========================================
                // DEBUG
                // ========================================

                Section(header: Text("Debug")) {

                    Button(
                        role: .destructive
                    ) {

                        resetAppData()

                    } label: {

                        HStack {

                            Image(
                                systemName: "trash.fill"
                            )

                            Text("Reset App Data")
                        }
                    }
                }
            }

            .navigationTitle("Settings")

            // ========================================
            // SIGN OUT CONFIRMATION
            // ========================================

            .confirmationDialog(
                "Sign Out of RecalllQ?",
                isPresented: $showSignOutConfirmation,
                titleVisibility: .visible
            ) {

                Button(
                    "Sign Out",
                    role: .destructive
                ) {

                    appState.logout()
                }

                Button(
                    "Cancel",
                    role: .cancel
                ) { }

            } message: {

                Text(
                    "You will be returned to the RecalllQ welcome screen."
                )
            }
        }
    }

    // =====================================================
    // APP INFO
    // =====================================================

    private var appName: String {
        "RecalllQ"
    }

    private var appVersion: String {
        "1.0"
    }

    // =====================================================
    // RESET FUNCTION
    // =====================================================

    private func resetAppData() {

        appState.notesViewModel.notes.removeAll()

        appState.memoryViewModel.memories.removeAll()

        UserDefaults.standard.removeObject(
            forKey: "saved_notes"
        )

        UserDefaults.standard.removeObject(
            forKey: "saved_quizzes"
        )

        print("🗑️ RecalllQ app data reset.")
    }
}

// =====================================================
// PREVIEW
// =====================================================

#Preview {

    SettingsView()
        .environmentObject(AppState())
}
