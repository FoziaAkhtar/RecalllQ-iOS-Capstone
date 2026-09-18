import SwiftUI

// =====================================================
// VIEW: AccountSwitchView 2
// =====================================================
//
// PURPOSE:
//
// Provides a safe way to switch between RecalllQ users
// without requiring the current user to sign out first.
//
// AVAILABLE OPTIONS:
//
// - Sign in to another registered account
// - Continue as Guest
// - Cancel and return to Settings
//
// DATA ISOLATION:
//
// Before switching accounts, AppState is responsible for:
//
// - Saving the current user's learning data
// - Clearing the current user's active data from memory
// - Loading the selected user's data
//
// IMPORTANT:
//
// Logout and Switch Account are intentionally separate.
//
// Logout:
//      Current Account
//          ↓
//      WelcomeView
//
// Switch Account:
//      Current Account
//          ↓
//      Another Account OR Guest
//
// =====================================================

struct AccountSwitchView: View {

// =====================================================
// GLOBAL APP STATE
// =====================================================

@EnvironmentObject var appState: AppState

// =====================================================
// DISMISS CURRENT SCREEN
// =====================================================

@Environment(\.dismiss) private var dismiss

// =====================================================
// BODY
// =====================================================

var body: some View {

    Form {

        // =====================================================
        // CURRENT ACCOUNT
        // =====================================================

        Section {

            HStack(spacing: 12) {

                ZStack {

                    RoundedRectangle(
                        cornerRadius: 10
                    )
                    .fill(
                        RecalllQTheme.primary
                            .opacity(0.10)
                    )
                    .frame(
                        width: 44,
                        height: 44
                    )

                    Image(
                        systemName: "person.circle.fill"
                    )
                    .font(.title2)
                    .foregroundColor(
                        RecalllQTheme.primary
                    )
                }

                VStack(
                    alignment: .leading,
                    spacing: 4
                ) {

                    Text("Current Account")
                        .font(.caption)
                        .foregroundColor(
                            RecalllQTheme.secondaryText
                        )

                    if appState.isGuestUser {

                        Text("Guest Mode")
                            .font(.body)
                            .fontWeight(.semibold)
                            .foregroundColor(
                                RecalllQTheme.primaryText
                            )

                    } else {

                        Text(
                            appState.currentUserEmail
                                ?? "Registered Account"
                        )
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundColor(
                            RecalllQTheme.primaryText
                        )
                    }
                }

                Spacer()

                Image(
                    systemName: "checkmark.circle.fill"
                )
                .foregroundColor(
                    RecalllQTheme.success
                )
            }

        } header: {

            Text("Active Account")

        } footer: {

            Text(
                "Your learning data remains separated from other RecalllQ accounts on this device."
            )
        }

        // =====================================================
        // SWITCH TO REGISTERED ACCOUNT
        // =====================================================

        Section {

            NavigationLink {

                LoginView()

            } label: {

                HStack(spacing: 12) {

                    ZStack {

                        RoundedRectangle(
                            cornerRadius: 10
                        )
                        .fill(
                            RecalllQTheme.primary
                                .opacity(0.10)
                        )
                        .frame(
                            width: 44,
                            height: 44
                        )

                        Image(
                            systemName: "person.badge.key.fill"
                        )
                        .font(.title3)
                        .foregroundColor(
                            RecalllQTheme.primary
                        )
                    }

                    VStack(
                        alignment: .leading,
                        spacing: 4
                    ) {

                        Text("Sign In to Another Account")
                            .font(.body)
                            .fontWeight(.semibold)
                            .foregroundColor(
                                RecalllQTheme.primaryText
                            )

                        Text(
                            "Switch to a different registered account"
                        )
                        .font(.caption)
                        .foregroundColor(
                            RecalllQTheme.secondaryText
                        )
                    }

                    Spacer()
                }
            }

        } header: {

            Text("Registered Account")

        } footer: {

            Text(
                "Your current learning data will be saved before the new account is loaded."
            )
        }

        // =====================================================
        // CONTINUE AS GUEST
        // =====================================================

        Section {

            Button {

                switchToGuest()

            } label: {

                HStack(spacing: 12) {

                    ZStack {

                        RoundedRectangle(
                            cornerRadius: 10
                        )
                        .fill(
                            RecalllQTheme.smartPurple
                                .opacity(0.10)
                        )
                        .frame(
                            width: 44,
                            height: 44
                        )

                        Image(
                            systemName:
                                "person.crop.circle.badge.questionmark"
                        )
                        .font(.title3)
                        .foregroundColor(
                            RecalllQTheme.smartPurple
                        )
                    }

                    VStack(
                        alignment: .leading,
                        spacing: 4
                    ) {

                        Text("Continue as Guest")
                            .font(.body)
                            .fontWeight(.semibold)
                            .foregroundColor(
                                RecalllQTheme.primaryText
                            )

                        Text(
                            "Switch to your isolated Guest Mode"
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
                        RecalllQTheme.secondaryText
                    )
                }
            }
            .buttonStyle(.plain)

        } header: {

            Text("Guest Mode")

        } footer: {

            Text(
                "Guest Mode uses its own separate learning data and does not require an email address."
            )
        }

        // =====================================================
        // INFORMATION
        // =====================================================

        Section {

            HStack(
                alignment: .top,
                spacing: 12
            ) {

                Image(
                    systemName: "lock.shield.fill"
                )
                .foregroundColor(
                    RecalllQTheme.success
                )

                VStack(
                    alignment: .leading,
                    spacing: 5
                ) {

                    Text("Your Data Stays Separate")
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundColor(
                            RecalllQTheme.primaryText
                        )

                    Text(
                        "RecalllQ stores learning data using a separate local storage namespace for each account."
                    )
                    .font(.caption)
                    .foregroundColor(
                        RecalllQTheme.secondaryText
                    )
                }
            }

        } header: {

            Text("Privacy & Data")
        }
    }

    // =====================================================
    // NAVIGATION TITLE
    // =====================================================

    .navigationTitle("Switch Account")
    .navigationBarTitleDisplayMode(.large)
}

// =====================================================
// SWITCH TO GUEST
// =====================================================

private func switchToGuest() {

    print(
        "========================================"
    )

    print(
        "🔄 ACCOUNT SWITCH"
    )

    print(
        "========================================"
    )

    print(
        "👤 Current account: \(appState.currentUserEmail ?? "Unknown")"
    )

    print(
        "➡️ Switching to Guest Mode..."
    )

    // =================================================
    // SAVE CURRENT USER AND LOAD GUEST
    // =================================================

    appState.switchToGuest()

    print(
        "✅ Guest Mode activated."
    )

    // =================================================
    // DISMISS ACCOUNT SWITCH SCREEN FIRST
    // =================================================
    //
    // AccountSwitchView is currently presented from
    // Settings.
    //
    // We dismiss this screen first so SwiftUI can
    // finish the navigation transition.
    //
    // =================================================

    dismiss()

    // =================================================
    // OPEN DASHBOARD AFTER DISMISSAL
    // =================================================
    //
    // AppState.switchToGuest() already prepares the
    // Guest account and selects Dashboard.
    //
    // We set selectedTab again after dismissal to make
    // sure the Dashboard becomes the visible tab.
    //
    // =================================================

    DispatchQueue.main.async {

        appState.selectedTab = 0

        print(
            "➡️ Guest Dashboard selected."
        )

        print(
            "========================================"
        )
    }
}

}

// =====================================================
// PREVIEW
// =====================================================

#Preview {

NavigationStack {

    AccountSwitchView()
}
.environmentObject(
    AppState()
)

}
