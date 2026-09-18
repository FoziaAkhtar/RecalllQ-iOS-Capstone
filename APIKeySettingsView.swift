
import SwiftUI

// =====================================================
// VIEW: APIKeySettingsView
// =====================================================
// PURPOSE:
// Allows the user to configure the OpenAI API key
// used by QuizAPIService.
//
// SECURITY:
// The API key is stored securely using the iOS Keychain.
//
// IMPORTANT:
// Older versions of RecalllQ stored the key in
// UserDefaults. This version automatically migrates
// an existing key into the Keychain.
//
// For a production application, API requests should
// go through a secure backend instead.
// =====================================================

struct APIKeySettingsView: View {

    // =====================================================
    // API KEY
    // =====================================================
    @State private var apiKey: String = ""

    // =====================================================
    // STATUS
    // =====================================================
    @State private var showSavedMessage = false

    // =====================================================
    // API KEY STORAGE KEY
    // =====================================================
    private let apiKeyStorageKey =
        "OPENAI_API_KEY"

    // =====================================================
    // BODY
    // =====================================================

    var body: some View {

        Form {

            // =================================================
            // INFORMATION
            // =================================================

            Section {

                VStack(
                    alignment: .leading,
                    spacing: 10
                ) {

                    Image(
                        systemName:
                            "key.fill"
                    )
                    .font(.largeTitle)
                    .foregroundColor(
                        RecalllQTheme.smartPurple
                    )

                    Text(
                        "OpenAI API Key"
                    )
                    .font(.title2)
                    .bold()

                    Text(
                        "Enter your OpenAI API key to enable AI-powered quiz generation."
                    )
                    .font(.subheadline)
                    .foregroundColor(
                        RecalllQTheme.secondaryText
                    )
                }
                .padding(.vertical, 8)
            }

            // =================================================
            // API KEY INPUT
            // =================================================

            Section(
                header:
                    Text("API Key")
            ) {

                SecureField(
                    "Enter your API key",
                    text:
                        $apiKey
                )
                .textInputAutocapitalization(
                    .never
                )
                .autocorrectionDisabled()
            }

            // =================================================
            // SAVE BUTTON
            // =================================================

            Section {

                Button {

                    saveAPIKey()

                } label: {

                    HStack {

                        Image(
                            systemName:
                                "checkmark.circle.fill"
                        )

                        Text(
                            "Save API Key"
                        )
                        .bold()

                        Spacer()
                    }
                }
                .disabled(
                    apiKey
                        .trimmingCharacters(
                            in:
                                .whitespacesAndNewlines
                        )
                        .isEmpty
                )
            }

            // =================================================
            // REMOVE BUTTON
            // =================================================

            Section {

                Button(
                    role:
                        .destructive
                ) {

                    removeAPIKey()

                } label: {

                    HStack {

                        Image(
                            systemName:
                                "trash"
                        )

                        Text(
                            "Remove API Key"
                        )
                    }
                }
            }

            // =================================================
            // SECURITY INFORMATION
            // =================================================

            Section(
                header:
                    Text("Security")
            ) {

                Text(
                    "RecalllQ stores your API key securely in the iOS Keychain. Never share your API key or commit it to GitHub."
                )
                .font(.caption)
                .foregroundColor(
                    RecalllQTheme.secondaryText
                )
            }
        }

        .navigationTitle(
            "AI Settings"
        )

        .navigationBarTitleDisplayMode(
            .inline
        )

        .onAppear {

            loadAPIKey()
        }

        .alert(
            "API Key Saved",
            isPresented:
                $showSavedMessage
        ) {

            Button(
                "OK",
                role:
                    .cancel
            ) {}

        } message: {

            Text(
                "AI quiz generation is now configured."
            )
        }
    }

    // =====================================================
    // LOAD API KEY
    // =====================================================

    private func loadAPIKey() {

        // =================================================
        // FIRST:
        // LOAD FROM SECURE KEYCHAIN
        // =================================================

        if let secureKey =
            KeychainService.shared.read(
                forKey:
                    apiKeyStorageKey
            ) {

            apiKey = secureKey

            print(
                "🔐 OpenAI API key loaded from Keychain."
            )

            return
        }

        // =================================================
        // LEGACY MIGRATION
        // =================================================
        //
        // Older versions stored the API key in
        // UserDefaults.
        //
        // If an old key exists, move it to Keychain
        // and then delete the old UserDefaults value.
        // =================================================

        if let legacyKey =
            UserDefaults.standard.string(
                forKey:
                    apiKeyStorageKey
            ) {

            let cleanedKey =
                legacyKey.trimmingCharacters(
                    in:
                        .whitespacesAndNewlines
                )

            guard !cleanedKey.isEmpty else {

                UserDefaults.standard.removeObject(
                    forKey:
                        apiKeyStorageKey
                )

                return
            }

            // =================================================
            // SAVE OLD KEY INTO KEYCHAIN
            // =================================================

            let saved =
                KeychainService.shared.save(
                    cleanedKey,
                    forKey:
                        apiKeyStorageKey
                )

            if saved {

                // =============================================
                // DELETE OLD USERDEFAULTS VALUE
                // =============================================

                UserDefaults.standard.removeObject(
                    forKey:
                        apiKeyStorageKey
                )

                apiKey = cleanedKey

                print(
                    "🔄 Existing API key migrated from UserDefaults to Keychain."
                )
            }
        }
    }

    // =====================================================
    // SAVE API KEY
    // =====================================================

    private func saveAPIKey() {

        let cleanedKey =
            apiKey.trimmingCharacters(
                in:
                    .whitespacesAndNewlines
            )

        guard
            !cleanedKey.isEmpty
        else {
            return
        }

        // =================================================
        // SAVE SECURELY TO KEYCHAIN
        // =================================================

        let saved =
            KeychainService.shared.save(
                cleanedKey,
                forKey:
                    apiKeyStorageKey
            )

        // =================================================
        // CHECK SAVE RESULT
        // =================================================

        guard saved else {

            print(
                "❌ OpenAI API key could not be saved to Keychain."
            )

            return
        }

        // =================================================
        // REMOVE LEGACY USERDEFAULTS VALUE
        // =================================================

        UserDefaults.standard.removeObject(
            forKey:
                apiKeyStorageKey
        )

        // =================================================
        // SUCCESS
        // =================================================

        showSavedMessage = true

        print(
            "🔐 OpenAI API key saved securely in Keychain."
        )
    }

    // =====================================================
    // REMOVE API KEY
    // =====================================================

    private func removeAPIKey() {

        // =================================================
        // REMOVE FROM KEYCHAIN
        // =================================================

        KeychainService.shared.delete(
            forKey:
                apiKeyStorageKey
        )

        // =================================================
        // REMOVE ANY OLD USERDEFAULTS VALUE
        // =================================================

        UserDefaults.standard.removeObject(
            forKey:
                apiKeyStorageKey
        )

        // =================================================
        // CLEAR SCREEN
        // =================================================

        apiKey = ""

        print(
            "🗑️ OpenAI API key removed securely."
        )
    }
}

