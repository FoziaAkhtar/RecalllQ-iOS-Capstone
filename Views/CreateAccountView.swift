
import SwiftUI

// =====================================================
// VIEW: CreateAccountView
// =====================================================
// PURPOSE:
//
// RecalllQ account registration screen.
//
// AUTHENTICATION FLOW:
//
// Create Account
//      ↓
// AuthenticationViewModel
//      ↓
// auth.isAuthenticated = true
//      ↓
// appState.login(email: auth.email)
//      ↓
// User-specific data is loaded
//      ↓
// RecalllQApp detects authentication
//      ↓
// MainTabView
//      ↓
// Dashboard
//
// USER DATA ISOLATION:
//
// The authenticated email becomes the local user ID.
//
// Example:
//
// student1@email.com
//      ↓
// user ID = student1@email.com
//
// student2@email.com
//      ↓
// user ID = student2@email.com
//
// Each user receives separate notes, memories,
// flashcards, quizzes, and study data.
// =====================================================

struct CreateAccountView: View {

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
    // DISMISS
    // =====================================================

    @Environment(\.dismiss)
    private var dismiss

    // =====================================================
    // PASSWORD VISIBILITY
    // =====================================================

    @State private var showPassword = false
    @State private var showConfirmPassword = false

    // =====================================================
    // BODY
    // =====================================================

    var body: some View {

        ScrollView(
            showsIndicators: false
        ) {

            VStack(
                spacing: 24
            ) {

                Spacer(
                    minLength: 10
                )

                // =================================================
                // HEADER
                // =================================================

                headerSection

                // =================================================
                // ACCOUNT FORM
                // =================================================

                accountForm

                // =================================================
                // LOGIN SECTION
                // =================================================

                loginSection

                Spacer(
                    minLength: 25
                )
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            .padding(.bottom, 30)
        }

        // =====================================================
        // BACKGROUND
        // =====================================================

        .background(
            RecalllQTheme.background
                .ignoresSafeArea()
        )

        // =====================================================
        // WATCH AUTHENTICATION STATE
        // =====================================================
        //
        // IMPORTANT:
        //
        // We pass the authenticated email to AppState.
        //
        // This is what tells RecalllQ which user's
        // notes/memories/etc. should be loaded.
        //
        // DO NOT use:
        //
        //     appState.login()
        //
        // Instead use:
        //
        //     appState.login(email: auth.email)
        //
        // =====================================================

        .onChange(
            of: auth.isAuthenticated
        ) { _, authenticated in

            if authenticated {

                let cleanEmail = auth.email
                    .trimmingCharacters(
                        in: .whitespacesAndNewlines
                    )
                    .lowercased()

                guard !cleanEmail.isEmpty else {

                    print(
                        "❌ Account authenticated but email is empty."
                    )

                    return
                }

                print(
                    "========================================"
                )

                print(
                    "✅ ACCOUNT CREATION AUTHENTICATED"
                )

                print(
                    "👤 New authenticated user:"
                )

                print(
                    cleanEmail
                )

                print(
                    "🔐 Loading user-specific data..."
                )

                print(
                    "========================================"
                )

                // =================================================
                // IMPORTANT USER ISOLATION STEP
                // =================================================
                //
                // Pass the email to AppState.
                //
                // AppState will use this user ID to load:
                //
                // - Notes
                // - Memories
                // - Flashcards
                // - Quizzes
                // - Study sessions
                // - Progress
                //
                // A brand-new account will receive empty data
                // if no data exists for this user ID.
                // =================================================

                appState.login(
                    email: cleanEmail
                )
            }
        }

        // =====================================================
        // NAVIGATION BAR
        // =====================================================

        .navigationTitle(
            "Create Account"
        )
        .navigationBarTitleDisplayMode(
            .inline
        )
    }

    // =====================================================
    // HEADER
    // =====================================================

    private var headerSection: some View {

        VStack(
            spacing: 14
        ) {

            // =================================================
            // ICON
            // =================================================

            ZStack {

                Circle()
                    .fill(
                        RecalllQTheme.smartPurple
                            .opacity(0.12)
                    )
                    .frame(
                        width: 86,
                        height: 86
                    )

                Image(
                    systemName:
                        "person.badge.plus"
                )
                .font(
                    .system(
                        size: 38,
                        weight: .semibold
                    )
                )
                .foregroundColor(
                    RecalllQTheme.smartPurple
                )
            }

            // =================================================
            // TITLE
            // =================================================

            Text(
                "Create Your Account"
            )
            .font(
                .system(
                    size: 28,
                    weight: .bold
                )
            )
            .foregroundColor(
                RecalllQTheme.primaryText
            )

            // =================================================
            // SUBTITLE
            // =================================================

            Text(
                "Start building smarter learning habits with RecalllQ."
            )
            .font(
                .subheadline
            )
            .foregroundColor(
                RecalllQTheme.secondaryText
            )
            .multilineTextAlignment(
                .center
            )
        }
    }

    // =====================================================
    // ACCOUNT FORM
    // =====================================================

    private var accountForm: some View {

        VStack(
            alignment: .leading,
            spacing: 18
        ) {

            // =================================================
            // SECTION TITLE
            // =================================================

            Text(
                "Your Information"
            )
            .font(
                .title3
            )
            .bold()
            .foregroundColor(
                RecalllQTheme.primaryText
            )

            // =================================================
            // NAME
            // =================================================

            formField(
                title: "Full Name",
                icon: "person.fill"
            ) {

                TextField(
                    "Enter your name",
                    text: $auth.name
                )
                .textInputAutocapitalization(
                    .words
                )
                .autocorrectionDisabled()
            }

            // =================================================
            // EMAIL
            // =================================================

            formField(
                title: "Email",
                icon: "envelope.fill"
            ) {

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

            // =================================================
            // PASSWORD
            // =================================================

            passwordField(
                title: "Password",
                placeholder: "Create a password",
                icon: "lock.fill",
                text: $auth.password,
                isVisible: $showPassword
            )

            // =================================================
            // CONFIRM PASSWORD
            // =================================================

            passwordField(
                title: "Confirm Password",
                placeholder: "Confirm your password",
                icon: "lock.shield.fill",
                text: $auth.confirmPassword,
                isVisible: $showConfirmPassword
            )

            // =================================================
            // PASSWORD REQUIREMENT
            // =================================================

            passwordRequirement

            // =================================================
            // ERROR MESSAGE
            // =================================================

            if let error = auth.errorMessage {

                messageCard(
                    icon:
                        "exclamationmark.triangle.fill",
                    message: error,
                    color:
                        RecalllQTheme.error,
                    background:
                        RecalllQTheme.redBackground
                )
            }

            // =================================================
            // SUCCESS MESSAGE
            // =================================================

            if let success = auth.successMessage {

                messageCard(
                    icon:
                        "checkmark.circle.fill",
                    message: success,
                    color:
                        RecalllQTheme.success,
                    background:
                        RecalllQTheme.success
                            .opacity(0.10)
                )
            }

            // =================================================
            // CREATE ACCOUNT BUTTON
            // =================================================

            Button {

                auth.createAccount()

            } label: {

                HStack(
                    spacing: 12
                ) {

                    if auth.isLoading {

                        ProgressView()
                            .tint(.white)

                    } else {

                        Image(
                            systemName:
                                "person.badge.plus"
                        )
                    }

                    Text(
                        auth.isLoading
                            ? "Creating Account..."
                            : "Create Account"
                    )
                    .font(
                        .headline
                    )

                    Spacer()

                    if !auth.isLoading {

                        Image(
                            systemName:
                                "arrow.right"
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
                .shadow(
                    color:
                        RecalllQTheme.primary
                            .opacity(0.20),
                    radius: 8,
                    x: 0,
                    y: 4
                )
            }
            .disabled(
                auth.isLoading
            )
            .opacity(
                auth.isLoading
                    ? 0.7
                    : 1.0
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
    // PASSWORD REQUIREMENT
    // =====================================================

    private var passwordRequirement: some View {

        HStack(
            spacing: 8
        ) {

            Image(
                systemName:
                    auth.password.count >= 6
                    ? "checkmark.circle.fill"
                    : "circle"
            )
            .foregroundColor(
                auth.password.count >= 6
                ? RecalllQTheme.success
                : RecalllQTheme.secondaryText
            )

            Text(
                "Password must contain at least 6 characters."
            )
            .font(
                .caption
            )
            .foregroundColor(
                RecalllQTheme.secondaryText
            )

            Spacer()
        }
    }

    // =====================================================
    // PASSWORD FIELD
    // =====================================================

    @ViewBuilder
    private func passwordField(
        title: String,
        placeholder: String,
        icon: String,
        text: Binding<String>,
        isVisible: Binding<Bool>
    ) -> some View {

        VStack(
            alignment: .leading,
            spacing: 8
        ) {

            Text(title)
                .font(.caption)
                .bold()
                .foregroundColor(
                    RecalllQTheme.secondaryText
                )

            HStack(
                spacing: 12
            ) {

                Image(
                    systemName: icon
                )
                .foregroundColor(
                    RecalllQTheme.primary
                )

                Group {

                    if isVisible.wrappedValue {

                        TextField(
                            placeholder,
                            text: text
                        )

                    } else {

                        SecureField(
                            placeholder,
                            text: text
                        )
                    }
                }

                Button {

                    isVisible.wrappedValue.toggle()

                } label: {

                    Image(
                        systemName:
                            isVisible.wrappedValue
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
            .overlay(
                RoundedRectangle(
                    cornerRadius:
                        RecalllQTheme.mediumRadius
                )
                .stroke(
                    RecalllQTheme.primary
                        .opacity(0.08),
                    lineWidth: 1
                )
            )
        }
    }

    // =====================================================
    // FORM FIELD
    // =====================================================

    @ViewBuilder
    private func formField<Content: View>(
        title: String,
        icon: String,
        @ViewBuilder content: () -> Content
    ) -> some View {

        VStack(
            alignment: .leading,
            spacing: 8
        ) {

            Text(title)
                .font(.caption)
                .bold()
                .foregroundColor(
                    RecalllQTheme.secondaryText
                )

            HStack(
                spacing: 12
            ) {

                Image(
                    systemName: icon
                )
                .foregroundColor(
                    RecalllQTheme.primary
                )

                content()
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
                        .opacity(0.08),
                    lineWidth: 1
                )
            )
        }
    }

    // =====================================================
    // MESSAGE CARD
    // =====================================================

    private func messageCard(
        icon: String,
        message: String,
        color: Color,
        background: Color
    ) -> some View {

        HStack(
            alignment: .top,
            spacing: 10
        ) {

            Image(
                systemName: icon
            )
            .foregroundColor(color)

            Text(message)
                .font(
                    .caption
                )
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
            .fill(background)
        )
    }

    // =====================================================
    // LOGIN SECTION
    // =====================================================

    private var loginSection: some View {

        VStack(
            spacing: 10
        ) {

            Text(
                "Already have an account?"
            )
            .font(
                .subheadline
            )
            .foregroundColor(
                RecalllQTheme.secondaryText
            )

            Button {

                dismiss()

            } label: {

                HStack(
                    spacing: 6
                ) {

                    Text(
                        "Sign In"
                    )

                    Image(
                        systemName:
                            "arrow.right"
                    )
                }
                .font(
                    .headline
                )
                .foregroundColor(
                    RecalllQTheme.primary
                )
            }
        }
    }
}

// =====================================================
// PREVIEW
// =====================================================

#Preview {

    NavigationStack {

        CreateAccountView()
            .environmentObject(
                AppState()
            )
    }
}
