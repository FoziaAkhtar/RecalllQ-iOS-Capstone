

import Foundation

// =====================================================
// SERVICE: AuthenticationService
// =====================================================
// PURPOSE:
// Provides the authentication service layer for RecalllQ.
//
// CURRENT:
// - Provides a clean authentication service structure
// - Works with AuthenticationViewModel
//
// FUTURE:
// - Firebase Authentication
// - RecalllQ API authentication
// - Secure token handling
// - Password reset API
// - User profile synchronization
// =====================================================

final class AuthenticationService {

    // =====================================================
    // SHARED INSTANCE
    // =====================================================

    static let shared = AuthenticationService()

    // =====================================================
    // PRIVATE INIT
    // =====================================================

    private init() {}

    // =====================================================
    // LOGIN RESULT
    // =====================================================

    struct AuthenticationResult {

        let success: Bool

        let message: String
    }

    // =====================================================
    // LOGIN
    // =====================================================

    func login(
        email: String,
        password: String
    ) async -> AuthenticationResult {

        let cleanEmail =
            email.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        guard !cleanEmail.isEmpty else {

            return AuthenticationResult(
                success: false,
                message: "Email is required."
            )
        }

        guard !password.isEmpty else {

            return AuthenticationResult(
                success: false,
                message: "Password is required."
            )
        }

        // -------------------------------------------------
        // TEMPORARY LOCAL SERVICE
        // -------------------------------------------------
        // Real API/Firebase authentication will be added
        // here later.
        // -------------------------------------------------

        return AuthenticationResult(
            success: true,
            message: "Login successful."
        )
    }

    // =====================================================
    // CREATE ACCOUNT
    // =====================================================

    func createAccount(
        name: String,
        email: String,
        password: String
    ) async -> AuthenticationResult {

        let cleanName =
            name.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        let cleanEmail =
            email.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        guard !cleanName.isEmpty else {

            return AuthenticationResult(
                success: false,
                message: "Name is required."
            )
        }

        guard !cleanEmail.isEmpty else {

            return AuthenticationResult(
                success: false,
                message: "Email is required."
            )
        }

        guard password.count >= 6 else {

            return AuthenticationResult(
                success: false,
                message:
                    "Password must contain at least 6 characters."
            )
        }

        // -------------------------------------------------
        // TEMPORARY LOCAL SERVICE
        // -------------------------------------------------
        // Real account creation will be connected to
        // Firebase/API here later.
        // -------------------------------------------------

        return AuthenticationResult(
            success: true,
            message: "Account created successfully."
        )
    }

    // =====================================================
    // PASSWORD RESET
    // =====================================================

    func resetPassword(
        email: String
    ) async -> AuthenticationResult {

        let cleanEmail =
            email.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        guard !cleanEmail.isEmpty else {

            return AuthenticationResult(
                success: false,
                message: "Email is required."
            )
        }

        // -------------------------------------------------
        // FUTURE API/FIREBASE PASSWORD RESET
        // -------------------------------------------------

        return AuthenticationResult(
            success: true,
            message:
                "Password reset instructions have been requested."
        )
    }
}

