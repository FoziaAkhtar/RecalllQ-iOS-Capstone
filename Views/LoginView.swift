
import SwiftUI

// =====================================================
// VIEW: LoginView
// =====================================================
// PURPOSE:
// RecalllQ user login screen.
//
// FEATURES:
// - Email login
// - Password field
// - Show / hide password
// - Forgot password
// - Create account navigation
// - Authentication validation
// - Error messages
// - Success messages
// - RecalllQ branded design
// - Secure login flow
//
// AUTHENTICATION FLOW:
//
// LoginView
//      ↓
// AuthenticationViewModel.login()
//      ↓
// Validate email
//      ↓
// Validate password
//      ↓
// Check saved account
//      ↓
// Check password
//      ↓
// SUCCESS
//      ↓
// AppState.login()
//      ↓
// MainTabView
//
// =====================================================

struct LoginView: View {

    // =====================================================
    // APP STATE
    // =====================================================

    @EnvironmentObject var appState: AppState

    // =====================================================
    // AUTHENTICATION
    // =====================================================

    @StateObject private var auth =
        AuthenticationViewModel()

    // =====================================================
    // NAVIGATION
    // =====================================================

    @State private var showCreateAccount = false

    @State private var showForgotPassword = false

    // =====================================================
    // PASSWORD VISIBILITY
    // =====================================================

    @State private var showPassword = false

    // =====================================================
    // BODY
    // =====================================================

    var body: some View {

        ScrollView(
            showsIndicators: false
        ) {

            VStack(spacing: 24) {

                // =================================================
                // BRANDING
                // =================================================

                brandingSection

                // =================================================
                // LOGIN CARD
                // =================================================

                loginCard

                // =================================================
                // CREATE ACCOUNT
                // =================================================

                createAccountSection

                Spacer(
                    minLength: 20
                )
            }
            .padding(.horizontal, 24)
            .padding(.top, 30)
        }

        // =====================================================
        // BACKGROUND
        // =====================================================

        .background(
            RecalllQTheme.background
                .ignoresSafeArea()
        )

        // =====================================================
        // CREATE ACCOUNT NAVIGATION
        // =====================================================

        .navigationDestination(
            isPresented: $showCreateAccount
        ) {

            CreateAccountView()
                .environmentObject(appState)
        }

        // =====================================================
        // FORGOT PASSWORD NAVIGATION
        // =====================================================

        .navigationDestination(
            isPresented: $showForgotPassword
        ) {

            ForgotPasswordView()
                .environmentObject(appState)
        }

        // =====================================================
        // NAVIGATION BAR
        // =====================================================

        .navigationTitle("")

        .navigationBarTitleDisplayMode(
            .inline
        )
    }

    // =====================================================
    // BRANDING SECTION
    // =====================================================

    private var brandingSection: some View {

        VStack(spacing: 12) {

            // =================================================
            // ICON
            // =================================================

            ZStack {

                Circle()
                    .fill(
                        RecalllQTheme.primary
                            .opacity(0.12)
                    )
                    .frame(
                        width: 90,
                        height: 90
                    )

                Image(
                    systemName:
                        "brain.head.profile"
                )
                .font(
                    .system(
                        size: 42,
                        weight: .semibold
                    )
                )
                .foregroundColor(
                    RecalllQTheme.primary
                )
            }

            // =================================================
            // APP NAME
            // =================================================

            Text("RecalllQ")
                .font(
                    .system(
                        size: 34,
                        weight: .bold
                    )
                )
                .foregroundColor(
                    RecalllQTheme.primaryText
                )

            // =================================================
            // WELCOME
            // =================================================

            Text("Welcome back")
                .font(.title3)
                .bold()
                .foregroundColor(
                    RecalllQTheme.primaryText
                )

            // =================================================
            // DESCRIPTION
            // =================================================

            Text(
                "Sign in to continue your learning journey."
            )
            .font(.subheadline)
            .foregroundColor(
                RecalllQTheme.secondaryText
            )
            .multilineTextAlignment(
                .center
            )
        }
    }

    // =====================================================
    // LOGIN CARD
    // =====================================================

    private var loginCard: some View {

        VStack(
            alignment: .leading,
            spacing: 18
        ) {

            Text("Sign In")
                .font(.title2)
                .bold()
                .foregroundColor(
                    RecalllQTheme.primaryText
                )

            // =================================================
            // EMAIL
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
                        systemName:
                            "envelope.fill"
                    )
                    .foregroundColor(
                        RecalllQTheme.primary
                    )

                    TextField(
                        "Enter your email",
                        text: $auth.email
                    )
                    .keyboardType(
                        .emailAddress
                    )
                    .textInputAutocapitalization(
                        .never
                    )
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
            }

            // =================================================
            // PASSWORD
            // =================================================

            VStack(
                alignment: .leading,
                spacing: 8
            ) {

                Text("Password")
                    .font(.caption)
                    .bold()
                    .foregroundColor(
                        RecalllQTheme.secondaryText
                    )

                HStack(spacing: 12) {

                    Image(
                        systemName:
                            "lock.fill"
                    )
                    .foregroundColor(
                        RecalllQTheme.primary
                    )

                    Group {

                        if showPassword {

                            TextField(
                                "Enter your password",
                                text: $auth.password
                            )

                        } else {

                            SecureField(
                                "Enter your password",
                                text: $auth.password
                            )
                        }
                    }

                    Button {

                        showPassword.toggle()

                    } label: {

                        Image(
                            systemName:
                                showPassword
                                ? "eye.slash.fill"
                                : "eye.fill"
                        )
                        .foregroundColor(
                            RecalllQTheme.secondaryText
                        )
                    }
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
            }

            // =================================================
            // FORGOT PASSWORD
            // =================================================

            HStack {

                Spacer()

                Button {

                    auth.clearMessages()

                    showForgotPassword = true

                } label: {

                    Text("Forgot Password?")
                        .font(.subheadline)
                        .bold()
                        .foregroundColor(
                            RecalllQTheme.primary
                        )
                }
            }

            // =================================================
            // ERROR MESSAGE
            // =================================================

            if let error = auth.errorMessage {

                messageView(
                    text: error,
                    isError: true
                )
            }

            // =================================================
            // SUCCESS MESSAGE
            // =================================================

            if let success = auth.successMessage {

                messageView(
                    text: success,
                    isError: false
                )
            }

            // =================================================
            // SIGN IN BUTTON
            // =================================================

            Button {

                print(
                    "========================================"
                )

                print(
                    "🔐 SIGN IN BUTTON PRESSED"
                )

                print(
                    "========================================"
                )

                // -------------------------------------------------
                // AUTHENTICATE
                // -------------------------------------------------

                auth.login()

                // -------------------------------------------------
                // ONLY UPDATE GLOBAL APP STATE AFTER SUCCESS
                // -------------------------------------------------

                if auth.isAuthenticated {

                    print(
                        "✅ Credentials accepted."
                    )

                    print(
                        "➡️ Updating AppState..."
                    )

                    appState.login()

                    print(
                        "✅ AppState.isAuthenticated = \(appState.isAuthenticated)"
                    )

                    print(
                        "➡️ MainTabView should now appear."
                    )

                } else {

                    print(
                        "❌ Authentication failed."
                    )

                    print(
                        "Reason: \(auth.errorMessage ?? "Unknown error")"
                    )

                    print(
                        "🔒 User remains on LoginView."
                    )
                }

                print(
                    "========================================"
                )

            } label: {

                HStack {

                    if auth.isLoading {

                        ProgressView()
                            .tint(.white)

                    } else {

                        Image(
                            systemName:
                                "arrow.right.circle.fill"
                        )
                    }

                    Text(
                        auth.isLoading
                        ? "Signing In..."
                        : "Sign In"
                    )
                    .font(.headline)

                    Spacer()

                    if !auth.isLoading {

                        Image(
                            systemName:
                                "chevron.right"
                        )
                    }
                }
                .padding()
                .frame(
                    maxWidth: .infinity
                )
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
            }
            .disabled(
                auth.isLoading
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

    // =====================================================
    // CREATE ACCOUNT SECTION
    // =====================================================

    private var createAccountSection: some View {

        VStack(spacing: 10) {

            Text(
                "Don't have a RecalllQ account?"
            )
            .font(.subheadline)
            .foregroundColor(
                RecalllQTheme.secondaryText
            )

            Button {

                auth.clearMessages()

                showCreateAccount = true

            } label: {

                HStack(spacing: 6) {

                    Text("Create Account")

                    Image(
                        systemName:
                            "arrow.right"
                    )
                }
                .font(.headline)
                .foregroundColor(
                    RecalllQTheme.primary
                )
            }
        }
    }

    // =====================================================
    // MESSAGE VIEW
    // =====================================================

    @ViewBuilder
    private func messageView(
        text: String,
        isError: Bool
    ) -> some View {

        HStack(spacing: 10) {

            Image(
                systemName:
                    isError
                    ? "exclamationmark.triangle.fill"
                    : "checkmark.circle.fill"
            )
            .foregroundColor(
                isError
                ? RecalllQTheme.error
                : RecalllQTheme.success
            )

            Text(text)
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
                isError
                ? RecalllQTheme.redBackground
                : RecalllQTheme.success
                    .opacity(0.10)
            )
        )
    }
}
