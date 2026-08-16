
import SwiftUI

// =====================================================
// VIEW: APIKeySettingsView
// =====================================================
// PURPOSE:
// Allows the user to configure the OpenAI API key
// used by QuizAPIService.
//
// IMPORTANT:
// The key is stored locally using UserDefaults.
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
                    "For development, RecalllQ stores the key locally. Never share your API key or commit it to GitHub."
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

        apiKey =
            UserDefaults.standard.string(
                forKey:
                    "OPENAI_API_KEY"
            ) ?? ""
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

        UserDefaults.standard.set(
            cleanedKey,
            forKey:
                "OPENAI_API_KEY"
        )

        showSavedMessage = true

        print(
            "✅ OpenAI API key saved."
        )
    }

    // =====================================================
    // REMOVE API KEY
    // =====================================================

    private func removeAPIKey() {

        UserDefaults.standard.removeObject(
            forKey:
                "OPENAI_API_KEY"
        )

        apiKey = ""

        print(
            "🗑️ OpenAI API key removed."
        )
    }
}
