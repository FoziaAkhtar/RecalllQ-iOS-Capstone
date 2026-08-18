
import SwiftUI

// =====================================================
// VIEW: ForgotPasswordView
// =====================================================
// PURPOSE:
// Allows the user to request password reset instructions.
//
// FEATURES:
// - Email input
// - Email validation
// - Password reset request
// - Success message
// - Error message
// - RecalllQ branded design
// =====================================================

struct ForgotPasswordView: View {

    // =====================================================
    // AUTHENTICATION
    // =====================================================

    @StateObject private var auth = AuthenticationViewModel()

    // =====================================================
    // NAVIGATION
    // =====================================================

    @Environment(\.dismiss) private var dismiss

    // =====================================================
    // BODY
    // =====================================================

    var body: some View {

        ScrollView(showsIndicators: false) {

            VStack(spacing: 24) {

                Spacer(minLength: 20)

                // HEADER
                headerSection

                // RESET FORM
                resetForm

                // BACK TO LOGIN
                Button {
                    dismiss()
                } label: {

                    HStack(spacing: 8) {

                        Image(systemName: "arrow.left")

                        Text("Back to Sign In")
                            .font(.headline)
                    }
                    .foregroundColor(
                        RecalllQTheme.primary
                    )
                }

                Spacer(minLength: 30)
            }
            .padding(.horizontal, 24)
        }

        // =====================================================
        // BACKGROUND
        // =====================================================

        .background(
            RecalllQTheme.background
                .ignoresSafeArea()
        )

        // =====================================================
        // NAVIGATION BAR
        // =====================================================

        .navigationTitle("Reset Password")
        .navigationBarTitleDisplayMode(.inline)
    }

    // =====================================================
    // HEADER
    // =====================================================

    private var headerSection: some View {

        VStack(spacing: 14) {

            ZStack {

                Circle()
                    .fill(
                        RecalllQTheme.primary
                            .opacity(0.12)
                    )
                    .frame(
                        width: 86,
                        height: 86
                    )

                Image(
                    systemName: "lock.rotation"
                )
                .font(
                    .system(
                        size: 36,
                        weight: .semibold
                    )
                )
                .foregroundColor(
                    RecalllQTheme.primary
                )
            }

            Text("Forgot Your Password?")
                .font(
                    .system(
                        size: 27,
                        weight: .bold
                    )
                )
                .foregroundColor(
                    RecalllQTheme.primaryText
                )

            Text(
                "Enter your email address and we'll help you get back into your RecalllQ account."
            )
            .font(.subheadline)
            .foregroundColor(
                RecalllQTheme.secondaryText
            )
            .multilineTextAlignment(.center)
        }
    }

    // =====================================================
    // RESET FORM
    // =====================================================

    private var resetForm: some View {

        VStack(
            alignment: .leading,
            spacing: 18
        ) {

            // =================================================
            // SECTION TITLE
            // =================================================

            Text("Account Email")
                .font(.title3)
                .bold()
                .foregroundColor(
                    RecalllQTheme.primaryText
                )

            // =================================================
            // EMAIL FIELD
            // =================================================

            VStack(
                alignment: .leading,
                spacing: 8
            ) {

                Text("Email")
                    .font(.caption)
                    .bold()
                    .foregroundColor(
                        RecalllQTheme.secondaryText
                    )

                HStack(spacing: 12) {

                    Image(
                        systemName: "envelope.fill"
                    )
                    .foregroundColor(
                        RecalllQTheme.primary
                    )

                    TextField(
                        "Enter your email",
                        text: $auth.email
                    )
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                }
                .padding()
                .background(
                    RoundedRectangle(
                        cornerRadius:
                            RecalllQTheme.mediumRadius
                    )
                    .fill(
                        RecalllQTheme.background
                    )
                )
                .overlay(
                    RoundedRectangle(
                        cornerRadius:
                            RecalllQTheme.mediumRadius
                    )
                    .stroke(
                        RecalllQTheme.primary
                            .opacity(0.10),
                        lineWidth: 1
                    )
                )
            }

            // =================================================
            // ERROR MESSAGE
            // =================================================

            if let error = auth.errorMessage {

                HStack(
                    alignment: .top,
                    spacing: 10
                ) {

                    Image(
                        systemName:
                            "exclamationmark.triangle.fill"
                    )
                    .foregroundColor(
                        RecalllQTheme.error
                    )

                    Text(error)
                        .font(.caption)
                        .foregroundColor(
                            RecalllQTheme.primaryText
                        )

                    Spacer()
                }
                .padding()
                .background(
                    RoundedRectangle(
                        cornerRadius:
                            RecalllQTheme.mediumRadius
                    )
                    .fill(
                        RecalllQTheme.redBackground
                    )
                )
            }

            // =================================================
            // SUCCESS MESSAGE
            // =================================================

            if let message = auth.successMessage {

                HStack(
                    alignment: .top,
                    spacing: 10
                ) {

                    Image(
                        systemName:
                            "checkmark.circle.fill"
                    )
                    .foregroundColor(
                        RecalllQTheme.success
                    )

                    Text(message)
                        .font(.caption)
                        .foregroundColor(
                            RecalllQTheme.primaryText
                        )

                    Spacer()
                }
                .padding()
                .background(
                    RoundedRectangle(
                        cornerRadius:
                            RecalllQTheme.mediumRadius
                    )
                    .fill(
                        RecalllQTheme.success
                            .opacity(0.10)
                    )
                )
            }

            // =================================================
            // RESET BUTTON
            // =================================================

            Button {

                auth.forgotPassword()

            } label: {

                HStack(spacing: 12) {

                    if auth.isLoading {

                        ProgressView()
                            .tint(.white)

                    } else {

                        Image(
                            systemName:
                                "paperplane.fill"
                        )
                    }

                    Text(
                        auth.isLoading
                            ? "Sending..."
                            : "Send Reset Instructions"
                    )
                    .font(.headline)

                    Spacer()

                    if !auth.isLoading {

                        Image(
                            systemName:
                                "arrow.right"
                        )
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .foregroundColor(.white)
                .background(
                    LinearGradient(
                        colors: [
                            RecalllQTheme.primary,
                            RecalllQTheme.smartPurple
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(
                    RoundedRectangle(
                        cornerRadius:
                            RecalllQTheme.mediumRadius
                    )
                )
                .shadow(
                    color:
                        RecalllQTheme.primary
                            .opacity(0.18),
                    radius: 8,
                    x: 0,
                    y: 4
                )
            }
            .disabled(auth.isLoading)
            .opacity(
                auth.isLoading ? 0.7 : 1.0
            )
        }

        // =====================================================
        // CARD DESIGN
        // =====================================================

        .padding(
            RecalllQTheme.largePadding
        )
        .background(
            RoundedRectangle(
                cornerRadius:
                    RecalllQTheme.largeRadius
            )
            .fill(
                RecalllQTheme.cardBackground
            )
        )
        .overlay(
            RoundedRectangle(
                cornerRadius:
                    RecalllQTheme.largeRadius
            )
            .stroke(
                RecalllQTheme.primary
                    .opacity(0.10),
                lineWidth: 1
            )
        )
        .shadow(
            color:
                Color.black.opacity(
                    RecalllQTheme.shadowOpacity
                ),
            radius:
                RecalllQTheme.shadowRadius,
            x: 0,
            y:
                RecalllQTheme.shadowY
        )
    }
}

