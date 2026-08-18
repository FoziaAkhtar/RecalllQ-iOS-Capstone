
import SwiftUI

// =====================================================
// VIEW: SettingsView
// =====================================================
// PURPOSE:
// - Professional RecalllQ settings screen
// - AI configuration
// - AI Memory Engine information
// - Account information
// - Sign out
// - App information
// - Feature overview
// - Protected reset-data action
//
// AUTHENTICATION:
// SettingsView uses the global AppState.
//
// Sign Out:
// SettingsView
//      ↓
// appState.logout()
//      ↓
// isAuthenticated = false
//      ↓
// RecalllQApp
//      ↓
// WelcomeView
// =====================================================

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
    // RESET DATA CONFIRMATION
    // =====================================================

    @State private var showResetConfirmation = false

    // =====================================================
    // BODY
    // =====================================================

    var body: some View {

        NavigationStack {

            Form {

                // =====================================================
                // AI & INTELLIGENCE
                // =====================================================

                Section {

                    // -------------------------------------------------
                    // OPENAI API KEY
                    // -------------------------------------------------

                    NavigationLink {
                        APIKeySettingsView()
                    } label: {

                        settingsRow(
                            icon: "key.fill",
                            title: "OpenAI API Key",
                            description: "Configure AI-powered quiz generation",
                            color: RecalllQTheme.smartPurple
                        )
                    }

                    // -------------------------------------------------
                    // AI MEMORY ENGINE
                    // -------------------------------------------------

                    settingsRow(
                        icon: "brain.head.profile",
                        title: "AI Memory Engine",
                        description: "Converts notes into structured memories",
                        color: RecalllQTheme.smartPurple
                    )

                    // -------------------------------------------------
                    // AI QUIZ GENERATION
                    // -------------------------------------------------

                    settingsRow(
                        icon: "sparkles",
                        title: "AI Quiz Generation",
                        description: "Create quizzes from your learning memories",
                        color: RecalllQTheme.primary
                    )
                } header: {

                    Text("AI & Intelligence")

                } footer: {

                    Text(
                        "RecalllQ uses AI to transform your study material into useful learning resources."
                    )
                }

                // =====================================================
                // ACCOUNT
                // =====================================================

                Section {

                    // -------------------------------------------------
                    // USER PROFILE
                    // -------------------------------------------------

                    HStack(spacing: 12) {

                        Image(
                            systemName: "person.circle.fill"
                        )
                        .font(.title3)
                        .foregroundColor(
                            RecalllQTheme.primary
                        )

                        VStack(
                            alignment: .leading,
                            spacing: 3
                        ) {

                            Text("User Profile")
                                .font(.body)
                                .fontWeight(.medium)
                                .foregroundColor(
                                    RecalllQTheme.primaryText
                                )

                            Text("Your RecalllQ account")
                                .font(.caption)
                                .foregroundColor(
                                    RecalllQTheme.secondaryText
                                )
                        }

                        Spacer()

                        HStack(spacing: 5) {

                            Circle()
                                .fill(
                                    RecalllQTheme.success
                                )
                                .frame(
                                    width: 8,
                                    height: 8
                                )

                            Text("Active")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(
                                    RecalllQTheme.success
                                )
                        }
                    }

                    // -------------------------------------------------
                    // SIGN OUT
                    // -------------------------------------------------

                    Button {

                        showSignOutConfirmation = true

                    } label: {

                        HStack(spacing: 12) {

                            ZStack {

                                RoundedRectangle(
                                    cornerRadius: 8
                                )
                                .fill(
                                    RecalllQTheme.error
                                        .opacity(0.10)
                                )
                                .frame(
                                    width: 36,
                                    height: 36
                                )

                                Image(
                                    systemName:
                                        "rectangle.portrait.and.arrow.right"
                                )
                                .font(.body)
                                .foregroundColor(
                                    RecalllQTheme.error
                                )
                            }

                            VStack(
                                alignment: .leading,
                                spacing: 3
                            ) {

                                Text("Sign Out")
                                    .font(.body)
                                    .fontWeight(.semibold)
                                    .foregroundColor(
                                        RecalllQTheme.error
                                    )

                                Text(
                                    "Return to the RecalllQ welcome screen"
                                )
                                .font(.caption)
                                .foregroundColor(
                                    RecalllQTheme.secondaryText
                                )
                            }

                            Spacer()

                            Image(
                                systemName: "chevron.right"
                            )
                            .font(
                                .caption.weight(.semibold)
                            )
                            .foregroundColor(
                                RecalllQTheme.error
                                    .opacity(0.7)
                            )
                        }
                    }
                    .buttonStyle(.plain)

                } header: {

                    Text("Account")

                } footer: {

                    Text(
                        "Signing out will not delete your saved learning data."
                    )
                }

                // =====================================================
                // APP INFORMATION
                // =====================================================

                Section {

                    informationRow(
                        title: "App Name",
                        value: "RecalllQ"
                    )

                    informationRow(
                        title: "Version",
                        value: "1.0"
                    )

                    informationRow(
                        title: "Platform",
                        value: "iOS"
                    )

                    informationRow(
                        title: "AI Integration",
                        value: "Enabled"
                    )

                } header: {

                    Text("App Information")
                }

                // =====================================================
                // FEATURES
                // =====================================================

                Section {

                    featureRow(
                        icon: "brain.head.profile",
                        title: "AI Memory Engine"
                    )

                    featureRow(
                        icon: "note.text",
                        title: "Smart Notes"
                    )

                    featureRow(
                        icon: "rectangle.on.rectangle",
                        title: "Flashcards"
                    )

                    featureRow(
                        icon: "questionmark.circle.fill",
                        title: "AI Quiz Generation"
                    )

                    featureRow(
                        icon: "bell.fill",
                        title: "Reminder System"
                    )

                    featureRow(
                        icon: "book.fill",
                        title: "Study Sessions"
                    )

                    featureRow(
                        icon: "chart.bar.fill",
                        title: "Learning Progress"
                    )

                    featureRow(
                        icon: "lightbulb.fill",
                        title: "Personalized Recommendations"
                    )

                } header: {

                    Text("Features")

                } footer: {

                    Text(
                        "RecalllQ combines AI memory organization with active learning tools to help students study more effectively."
                    )
                }

                // =====================================================
                // DANGER ZONE
                // =====================================================

                Section {

                    Button {

                        showResetConfirmation = true

                    } label: {

                        HStack(spacing: 12) {

                            ZStack {

                                RoundedRectangle(
                                    cornerRadius: 8
                                )
                                .fill(
                                    RecalllQTheme.error
                                        .opacity(0.10)
                                )
                                .frame(
                                    width: 36,
                                    height: 36
                                )

                                Image(
                                    systemName: "trash.fill"
                                )
                                .foregroundColor(
                                    RecalllQTheme.error
                                )
                            }

                            VStack(
                                alignment: .leading,
                                spacing: 3
                            ) {

                                Text("Reset Learning Data")
                                    .font(.body)
                                    .fontWeight(.semibold)
                                    .foregroundColor(
                                        RecalllQTheme.error
                                    )

                                Text(
                                    "Delete saved notes, memories and quizzes"
                                )
                                .font(.caption)
                                .foregroundColor(
                                    RecalllQTheme.secondaryText
                                )
                            }

                            Spacer()
                        }
                    }
                    .buttonStyle(.plain)

                } header: {

                    Text("Danger Zone")
                        .foregroundColor(
                            RecalllQTheme.error
                        )

                } footer: {

                    Text(
                        "This action removes locally saved learning data from RecalllQ. Your account will remain active."
                    )
                }
            }

            // =====================================================
            // NAVIGATION TITLE
            // =====================================================

            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)

            // =====================================================
            // SIGN OUT CONFIRMATION
            // =====================================================

            .confirmationDialog(
                "Sign Out of RecalllQ?",
                isPresented: $showSignOutConfirmation,
                titleVisibility: .visible
            ) {

                Button(
                    "Sign Out",
                    role: .destructive
                ) {

                    print(
                        "========================================"
                    )

                    print(
                        "👋 SIGNING OUT OF RECALLIQ"
                    )

                    print(
                        "========================================"
                    )

                    appState.logout()

                    print(
                        "✅ AppState.isAuthenticated = \(appState.isAuthenticated)"
                    )

                    print(
                        "➡️ Returning to WelcomeView"
                    )

                    print(
                        "========================================"
                    )
                }

                Button(
                    "Cancel",
                    role: .cancel
                ) { }

            } message: {

                Text(
                    "You will be returned to the RecalllQ welcome screen. Your saved learning data will remain on this device."
                )
            }

            // =====================================================
            // RESET DATA CONFIRMATION
            // =====================================================

            .confirmationDialog(
                "Reset RecalllQ Learning Data?",
                isPresented: $showResetConfirmation,
                titleVisibility: .visible
            ) {

                Button(
                    "Reset Learning Data",
                    role: .destructive
                ) {

                    resetAppData()
                }

                Button(
                    "Cancel",
                    role: .cancel
                ) { }

            } message: {

                Text(
                    "This will delete your saved notes, memories and quizzes from this device. This action cannot be undone."
                )
            }
        }
    }

    // =====================================================
    // SETTINGS ROW
    // =====================================================

    @ViewBuilder
    private func settingsRow(
        icon: String,
        title: String,
        description: String,
        color: Color
    ) -> some View {

        HStack(spacing: 12) {

            ZStack {

                RoundedRectangle(
                    cornerRadius: 8
                )
                .fill(
                    color.opacity(0.10)
                )
                .frame(
                    width: 36,
                    height: 36
                )

                Image(
                    systemName: icon
                )
                .font(.body)
                .foregroundColor(color)
            }

            VStack(
                alignment: .leading,
                spacing: 3
            ) {

                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(
                        RecalllQTheme.primaryText
                    )

                Text(description)
                    .font(.caption)
                    .foregroundColor(
                        RecalllQTheme.secondaryText
                    )
            }

            Spacer()
        }
    }

    // =====================================================
    // INFORMATION ROW
    // =====================================================

    @ViewBuilder
    private func informationRow(
        title: String,
        value: String
    ) -> some View {

        HStack {

            Text(title)
                .foregroundColor(
                    RecalllQTheme.primaryText
                )

            Spacer()

            Text(value)
                .foregroundColor(
                    RecalllQTheme.secondaryText
                )
        }
    }

    // =====================================================
    // FEATURE ROW
    // =====================================================

    @ViewBuilder
    private func featureRow(
        icon: String,
        title: String
    ) -> some View {

        HStack(spacing: 12) {

            Image(
                systemName: icon
            )
            .frame(
                width: 24
            )
            .foregroundColor(
                RecalllQTheme.primary
            )

            Text(title)
                .foregroundColor(
                    RecalllQTheme.primaryText
                )

            Spacer()

            Image(
                systemName: "checkmark.circle.fill"
            )
            .font(.caption)
            .foregroundColor(
                RecalllQTheme.success
            )
        }
    }

    // =====================================================
    // RESET APP DATA
    // =====================================================

    private func resetAppData() {

        print(
            "========================================"
        )

        print(
            "🗑️ RESETTING RECALLIQ LEARNING DATA"
        )

        print(
            "========================================"
        )

        // -------------------------------------------------
        // REMOVE NOTES
        // -------------------------------------------------

        appState.notesViewModel.notes.removeAll()

        UserDefaults.standard.removeObject(
            forKey: "saved_notes"
        )

        // -------------------------------------------------
        // REMOVE MEMORIES
        // -------------------------------------------------

        appState.memoryViewModel.memories.removeAll()

        // -------------------------------------------------
        // REMOVE QUIZZES
        // -------------------------------------------------

        UserDefaults.standard.removeObject(
            forKey: "saved_quizzes"
        )

        print(
            "✅ RecalllQ learning data reset."
        )

        print(
            "========================================"
        )
    }
}

// =====================================================
// PREVIEW
// =====================================================

#Preview {

    SettingsView()
        .environmentObject(
            AppState()
        )
}
