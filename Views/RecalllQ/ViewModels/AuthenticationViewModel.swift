
import Foundation
import Combine

// =====================================================
// VIEWMODEL: AuthenticationViewModel
// =====================================================
// PURPOSE:
// Controls RecalllQ authentication.
//
// FEATURES:
// - Login
// - Create Account
// - Logout
// - Forgot Password
// - Authentication state
// - Form validation
// - Email validation
// - Password validation
// - Local account storage
// - Error messages
// - Success messages
//
// IMPORTANT:
// This version uses local authentication for development.
//
// Later, the same ViewModel can be connected to:
// - Firebase Authentication
// - RecalllQ API
// - Secure token authentication
//
// =====================================================

@MainActor
final class AuthenticationViewModel: ObservableObject {

    // =====================================================
    // AUTHENTICATION STATE
    // =====================================================

    @Published var isAuthenticated: Bool = false

    @Published var isLoading: Bool = false

    // =====================================================
    // FORM DATA
    // =====================================================

    @Published var name: String = ""

    @Published var email: String = ""

    @Published var password: String = ""

    @Published var confirmPassword: String = ""

    // =====================================================
    // MESSAGES
    // =====================================================

    @Published var errorMessage: String?

    @Published var successMessage: String?

    // =====================================================
    // STORAGE KEYS
    // =====================================================

    private let accountKey = "recalllq_account"

    private let passwordKey = "recalllq_password"

    private let loggedInKey = "recalllq_logged_in"

    // =====================================================
    // INIT
    // =====================================================

    init() {

        // IMPORTANT:
        // We restore authentication only when the persisted
        // login state is actually true.

        isAuthenticated =
            UserDefaults.standard.bool(
                forKey: loggedInKey
            )
    }

    // =====================================================
    // CREATE ACCOUNT
    // =====================================================

    func createAccount() {

        clearMessages()

        let cleanName =
            name.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        let cleanEmail =
            email.trimmingCharacters(
                in: .whitespacesAndNewlines
            )
            .lowercased()

        // -------------------------------------------------
        // VALIDATE NAME
        // -------------------------------------------------

        guard !cleanName.isEmpty else {

            errorMessage =
                "Please enter your name."

            return
        }

        // -------------------------------------------------
        // VALIDATE EMAIL
        // -------------------------------------------------

        guard isValidEmail(cleanEmail) else {

            errorMessage =
                "Please enter a valid email address."

            return
        }

        // -------------------------------------------------
        // VALIDATE PASSWORD
        // -------------------------------------------------

        guard password.count >= 6 else {

            errorMessage =
                "Password must contain at least 6 characters."

            return
        }

        // -------------------------------------------------
        // CONFIRM PASSWORD
        // -------------------------------------------------

        guard password == confirmPassword else {

            errorMessage =
                "Passwords do not match."

            return
        }

        // -------------------------------------------------
        // CHECK FOR EXISTING ACCOUNT
        // -------------------------------------------------

        if let existingEmail =
            UserDefaults.standard.string(
                forKey: accountKey
            ) {

            if existingEmail
                .localizedCaseInsensitiveCompare(
                    cleanEmail
                ) == .orderedSame {

                errorMessage =
                    "An account with this email already exists."

                return
            }
        }

        // -------------------------------------------------
        // CREATE ACCOUNT
        // -------------------------------------------------

        isLoading = true

        // Save email
        UserDefaults.standard.set(
            cleanEmail,
            forKey: accountKey
        )

        // Save password for local development authentication
        UserDefaults.standard.set(
            password,
            forKey: passwordKey
        )

        // Mark user as logged in
        UserDefaults.standard.set(
            true,
            forKey: loggedInKey
        )

        // Update current authentication state
        isAuthenticated = true

        isLoading = false

        successMessage =
            "Account created successfully."

        print(
            "========================================"
        )

        print(
            "✅ RECALLIQ ACCOUNT CREATED"
        )

        print(
            "Name: \(cleanName)"
        )

        print(
            "Email: \(cleanEmail)"
        )

        print(
            "========================================"
        )
    }

    // =====================================================
    // LOGIN
    // =====================================================

    func login() {

        // -------------------------------------------------
        // ALWAYS RESET OLD MESSAGES
        // -------------------------------------------------

        clearMessages()

        // -------------------------------------------------
        // IMPORTANT:
        // Do NOT assume the user is authenticated.
        // -------------------------------------------------

        isAuthenticated = false

        // -------------------------------------------------
        // CLEAN EMAIL
        // -------------------------------------------------

        let cleanEmail =
            email.trimmingCharacters(
                in: .whitespacesAndNewlines
            )
            .lowercased()

        // -------------------------------------------------
        // VALIDATE EMAIL
        // -------------------------------------------------

        guard !cleanEmail.isEmpty else {

            errorMessage =
                "Please enter your email address."

            return
        }

        guard isValidEmail(cleanEmail) else {

            errorMessage =
                "Please enter a valid email address."

            return
        }

        // -------------------------------------------------
        // VALIDATE PASSWORD
        // -------------------------------------------------

        guard !password.isEmpty else {

            errorMessage =
                "Please enter your password."

            return
        }

        // -------------------------------------------------
        // CHECK WHETHER ACCOUNT EXISTS
        // -------------------------------------------------

        guard
            let savedEmail =
                UserDefaults.standard.string(
                    forKey: accountKey
                )
        else {

            errorMessage =
                "No account found. Please create an account first."

            return
        }

        // -------------------------------------------------
        // CHECK EMAIL
        // -------------------------------------------------

        guard
            savedEmail.localizedCaseInsensitiveCompare(
                cleanEmail
            ) == .orderedSame
        else {

            errorMessage =
                "The email or password is incorrect."

            return
        }

        // -------------------------------------------------
        // CHECK SAVED PASSWORD
        // -------------------------------------------------

        guard
            let savedPassword =
                UserDefaults.standard.string(
                    forKey: passwordKey
                )
        else {

            errorMessage =
                "No password is associated with this account."

            return
        }

        // -------------------------------------------------
        // CHECK PASSWORD
        // -------------------------------------------------

        guard password == savedPassword else {

            errorMessage =
                "The email or password is incorrect."

            return
        }

        // -------------------------------------------------
        // LOGIN SUCCESS
        // -------------------------------------------------

        isLoading = true

        UserDefaults.standard.set(
            true,
            forKey: loggedInKey
        )

        isAuthenticated = true

        isLoading = false

        successMessage =
            "Welcome back to RecalllQ!"

        print(
            "========================================"
        )

        print(
            "✅ RECALLIQ LOGIN SUCCESSFUL"
        )

        print(
            "Email: \(cleanEmail)"
        )

        print(
            "========================================"
        )
    }

    // =====================================================
    // LOGOUT
    // =====================================================

    func logout() {

        // -------------------------------------------------
        // CLEAR LOGIN STATE
        // -------------------------------------------------

        UserDefaults.standard.set(
            false,
            forKey: loggedInKey
        )

        // -------------------------------------------------
        // UPDATE VIEWMODEL STATE
        // -------------------------------------------------

        isAuthenticated = false

        // -------------------------------------------------
        // CLEAR FORM
        // -------------------------------------------------

        email = ""

        password = ""

        confirmPassword = ""

        // -------------------------------------------------
        // CLEAR MESSAGES
        // -------------------------------------------------

        clearMessages()

        print(
            "========================================"
        )

        print(
            "👋 RECALLIQ USER LOGGED OUT"
        )

        print(
            "🔐 Persisted login state cleared."
        )

        print(
            "========================================"
        )
    }

    // =====================================================
    // FORGOT PASSWORD
    // =====================================================

    func forgotPassword() {

        clearMessages()

        let cleanEmail =
            email.trimmingCharacters(
                in: .whitespacesAndNewlines
            )
            .lowercased()

        // -------------------------------------------------
        // VALIDATE EMAIL
        // -------------------------------------------------

        guard !cleanEmail.isEmpty else {

            errorMessage =
                "Enter your email address first."

            return
        }

        guard isValidEmail(cleanEmail) else {

            errorMessage =
                "Please enter a valid email address."

            return
        }

        // -------------------------------------------------
        // CHECK ACCOUNT
        // -------------------------------------------------

        guard
            let savedEmail =
                UserDefaults.standard.string(
                    forKey: accountKey
                )
        else {

            errorMessage =
                "No RecalllQ account was found."

            return
        }

        // -------------------------------------------------
        // CHECK EMAIL
        // -------------------------------------------------

        guard
            savedEmail.localizedCaseInsensitiveCompare(
                cleanEmail
            ) == .orderedSame
        else {

            errorMessage =
                "No account was found with this email."

            return
        }

        // -------------------------------------------------
        // PASSWORD RESET
        // -------------------------------------------------

        successMessage =
            "Password reset instructions will be sent to your email."

        print(
            "📧 Password reset requested for \(cleanEmail)"
        )
    }

    // =====================================================
    // VALIDATE EMAIL
    // =====================================================

    private func isValidEmail(
        _ email: String
    ) -> Bool {

        let pattern =
            "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"

        return email.range(
            of: pattern,
            options: .regularExpression
        ) != nil
    }

    // =====================================================
    // CLEAR MESSAGES
    // =====================================================

    func clearMessages() {

        errorMessage = nil

        successMessage = nil
    }
}
