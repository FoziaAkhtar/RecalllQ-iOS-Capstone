
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
// - Error messages
// - Success messages
//
// NOTE:
// This version provides local authentication so the UI
// can work immediately. The AuthenticationService can
// later be connected to Firebase/API authentication.
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
    private let loggedInKey = "recalllq_logged_in"

    // =====================================================
    // INIT
    // =====================================================

    init() {
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
        // PREVENT DUPLICATE ACCOUNT
        // -------------------------------------------------

        if let existingEmail =
            UserDefaults.standard.string(
                forKey: accountKey
            ) {

            if existingEmail
                .localizedCaseInsensitiveCompare(cleanEmail)
                == .orderedSame {

                errorMessage =
                    "An account with this email already exists."

                return
            }
        }

        // -------------------------------------------------
        // CREATE ACCOUNT
        // -------------------------------------------------

        isLoading = true

        UserDefaults.standard.set(
            cleanEmail,
            forKey: accountKey
        )

        UserDefaults.standard.set(
            true,
            forKey: loggedInKey
        )

        isAuthenticated = true
        isLoading = false

        successMessage =
            "Account created successfully."

        print("========================================")
        print("✅ RECALLlQ ACCOUNT CREATED")
        print("Name: \(cleanName)")
        print("Email: \(cleanEmail)")
        print("========================================")
    }

    // =====================================================
    // LOGIN
    // =====================================================

    func login() {

        clearMessages()

        let cleanEmail =
            email.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

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

        guard !password.isEmpty else {
            errorMessage =
                "Please enter your password."
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
        // LOGIN
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

        print("========================================")
        print("✅ RECALLlQ LOGIN SUCCESSFUL")
        print("Email: \(cleanEmail)")
        print("========================================")
    }

    // =====================================================
    // LOGOUT
    // =====================================================

    func logout() {

        UserDefaults.standard.set(
            false,
            forKey: loggedInKey
        )

        isAuthenticated = false

        clearMessages()

        email = ""
        password = ""
        confirmPassword = ""

        print("👋 RecalllQ user logged out.")
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

        guard isValidEmail(cleanEmail) else {
            errorMessage =
                "Enter your email address first."
            return
        }

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

        guard
            savedEmail.localizedCaseInsensitiveCompare(
                cleanEmail
            ) == .orderedSame
        else {

            errorMessage =
                "No account was found with this email."

            return
        }

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


