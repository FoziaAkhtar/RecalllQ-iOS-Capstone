

import Foundation
import AuthenticationServices
import UIKit

// =====================================================
// MANAGER: AppleSignInManager
// =====================================================
//
// PURPOSE:
//
// Handles Sign in with Apple authentication for RecalllQ.
//
// AUTHENTICATION FLOW:
//
// LoginView
//      ↓
// AppleSignInManager
//      ↓
// Apple Authentication
//      ↓
// Apple user identifier
//      ↓
// Apple email / stored email
//      ↓
// AuthenticationViewModel
//      ↓
// AppState
//      ↓
// MainTabView
//
// IMPORTANT:
//
// Sign in with Apple provides a stable Apple user identifier.
//
// Apple may provide the user's email only during the first
// authorization.
//
// Therefore, RecalllQ stores the email locally using the
// Apple user identifier so that future logins can continue
// to identify the same local RecalllQ account.
//
// SECURITY NOTE:
//
// This implementation is appropriate for the current
// LOCAL DEVELOPMENT version of RecalllQ.
//
// A production application should validate Apple's identity
// token on a secure backend server rather than trusting
// authentication information only inside the local app.
//
// =====================================================

@MainActor
final class AppleSignInManager: NSObject {

    // =====================================================
    // SINGLETON
    // =====================================================

    static let shared = AppleSignInManager()

    // =====================================================
    // STORAGE PREFIX
    // =====================================================

    // Each Apple account gets a locally stored email mapping.
    //
    // Example:
    //
    // RECALLIQ_APPLE_EMAIL_<APPLE_USER_IDENTIFIER>
    //
    // This allows RecalllQ to recover the email address if
    // Apple does not provide it during a future login.
    // =====================================================

    private let appleEmailPrefix =
        "RECALLIQ_APPLE_EMAIL_"

    // =====================================================
    // DISPLAY NAME STORAGE PREFIX
    // =====================================================

    // Each Apple account gets a locally stored display name.
    //
    // Example:
    //
    // RECALLIQ_APPLE_NAME_<APPLE_USER_IDENTIFIER>
    // =====================================================

    private let appleNamePrefix =
        "RECALLIQ_APPLE_NAME_"

    // =====================================================
    // AUTHENTICATION CONTINUATION
    // =====================================================

    private var continuation:
        CheckedContinuation<
            AppleSignInResult,
            Error
        >?

    // =====================================================
    // RESULT MODEL
    // =====================================================

    struct AppleSignInResult {

        // =================================================
        // APPLE USER IDENTIFIER
        // =================================================

        let userID: String

        // =================================================
        // EMAIL
        // =================================================

        let email: String

        // =================================================
        // DISPLAY NAME
        // =================================================

        let name: String
    }

    // =====================================================
    // PRIVATE INIT
    // =====================================================

    private override init() {
        super.init()
    }

    // =====================================================
    // SIGN IN WITH APPLE
    // =====================================================

    func signIn() async throws
        -> AppleSignInResult {

        // =================================================
        // CREATE APPLE AUTHORIZATION REQUEST
        // =================================================

        let provider =
            ASAuthorizationAppleIDProvider()

        let request =
            provider.createRequest()

        // =================================================
        // REQUEST USER INFORMATION
        // =================================================

        request.requestedScopes = [
            .fullName,
            .email
        ]

        // =================================================
        // RETURN RESULT THROUGH ASYNC CONTINUATION
        // =================================================

        return try await withCheckedThrowingContinuation {

            continuation in

            // =============================================
            // STORE CONTINUATION
            // =============================================

            self.continuation =
                continuation

            // =============================================
            // CREATE AUTHORIZATION CONTROLLER
            // =============================================

            let controller =
                ASAuthorizationController(
                    authorizationRequests: [
                        request
                    ]
                )

            // =============================================
            // SET DELEGATE
            // =============================================

            controller.delegate = self

            // =============================================
            // SET PRESENTATION CONTEXT
            // =============================================

            controller.presentationContextProvider =
                self

            // =============================================
            // START APPLE AUTHENTICATION
            // =============================================

            controller.performRequests()
        }
    }

    // =====================================================
    // SAVE APPLE ACCOUNT INFORMATION
    // =====================================================

    private func saveAppleAccount(
        userID: String,
        email: String?,
        name: String?
    ) {

        // =================================================
        // SAVE EMAIL
        // =================================================

        if let email = email,
           !email.isEmpty {

            UserDefaults.standard.set(
                email.lowercased(),
                forKey:
                    appleEmailKey(
                        userID: userID
                    )
            )
        }

        // =================================================
        // SAVE NAME
        // =================================================

        if let name = name,
           !name.isEmpty {

            UserDefaults.standard.set(
                name,
                forKey:
                    appleNameKey(
                        userID: userID
                    )
            )
        }
    }

    // =====================================================
    // LOAD SAVED APPLE EMAIL
    // =====================================================

    private func savedAppleEmail(
        userID: String
    ) -> String? {

        return UserDefaults.standard.string(
            forKey:
                appleEmailKey(
                    userID: userID
                )
        )
    }

    // =====================================================
    // LOAD SAVED APPLE NAME
    // =====================================================

    private func savedAppleName(
        userID: String
    ) -> String? {

        return UserDefaults.standard.string(
            forKey:
                appleNameKey(
                    userID: userID
                )
        )
    }

    // =====================================================
    // CREATE APPLE EMAIL STORAGE KEY
    // =====================================================

    private func appleEmailKey(
        userID: String
    ) -> String {

        return appleEmailPrefix + userID
    }

    // =====================================================
    // CREATE APPLE NAME STORAGE KEY
    // =====================================================

    private func appleNameKey(
        userID: String
    ) -> String {

        return appleNamePrefix + userID
    }
}

// =====================================================
// MARK: - ASAuthorizationControllerDelegate
// =====================================================

extension AppleSignInManager:
    ASAuthorizationControllerDelegate {

    // =====================================================
    // AUTHORIZATION SUCCESS
    // =====================================================

    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {

        // =================================================
        // GET APPLE CREDENTIAL
        // =================================================

        guard let credential =
                authorization.credential
                as? ASAuthorizationAppleIDCredential
        else {

            continuation?.resume(
                throwing:
                    AppleSignInError.invalidCredential
            )

            continuation = nil

            return
        }

        // =================================================
        // GET APPLE USER ID
        // =================================================

        let userID =
            credential.user

        // =================================================
        // GET EMAIL
        // =================================================

        let email =
            credential.email

        // =================================================
        // GET FULL NAME
        // =================================================

        let givenName =
            credential.fullName?.givenName ?? ""

        let familyName =
            credential.fullName?.familyName ?? ""

        let fullName =
            "\(givenName) \(familyName)"
                .trimmingCharacters(
                    in: .whitespacesAndNewlines
                )

        // =================================================
        // SAVE NEW APPLE ACCOUNT INFORMATION
        // =================================================

        saveAppleAccount(
            userID: userID,
            email: email,
            name:
                fullName.isEmpty
                ? nil
                : fullName
        )

        // =================================================
        // RECOVER EMAIL
        // =================================================

        let finalEmail =
            email?.lowercased()
            ?? savedAppleEmail(
                userID: userID
            )

        // =================================================
        // EMAIL IS REQUIRED FOR CURRENT LOCAL
        // RECALLIQ USER ISOLATION
        // =================================================

        guard let finalEmail,
              !finalEmail.isEmpty
        else {

            continuation?.resume(
                throwing:
                    AppleSignInError.emailUnavailable
            )

            continuation = nil

            return
        }

        // =================================================
        // RECOVER DISPLAY NAME
        // =================================================

        let finalName =
            !fullName.isEmpty
            ? fullName
            : (
                savedAppleName(
                    userID: userID
                ) ?? "RecalllQ Student"
            )

        // =================================================
        // CREATE RESULT
        // =================================================

        let result =
            AppleSignInResult(
                userID: userID,
                email: finalEmail,
                name: finalName
            )

        // =================================================
        // COMPLETE AUTHENTICATION
        // =================================================

        continuation?.resume(
            returning: result
        )

        continuation = nil
    }

    // =====================================================
    // AUTHORIZATION FAILURE
    // =====================================================

    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {

        // =================================================
        // CHECK FOR USER CANCELLATION
        // =================================================

        if let authorizationError =
            error as? ASAuthorizationError {

            if authorizationError.code
                == .canceled {

                continuation?.resume(
                    throwing:
                        AppleSignInError.userCancelled
                )

                continuation = nil

                return
            }
        }

        // =================================================
        // RETURN OTHER AUTHENTICATION ERROR
        // =================================================

        continuation?.resume(
            throwing: error
        )

        continuation = nil
    }
}

// =====================================================
// MARK: - ASAuthorizationControllerPresentationContextProviding
// =====================================================

extension AppleSignInManager:
    ASAuthorizationControllerPresentationContextProviding {

    // =====================================================
    // PRESENTATION WINDOW
    // =====================================================

    func presentationAnchor(
        for controller: ASAuthorizationController
    ) -> ASPresentationAnchor {

        // =================================================
        // FIND ACTIVE APPLICATION WINDOW
        // =================================================

        guard let windowScene =
                UIApplication.shared.connectedScenes
                    .compactMap({
                        $0 as? UIWindowScene
                    })
                    .first
        else {

            return ASPresentationAnchor()
        }

        // =================================================
        // RETURN KEY WINDOW
        // =================================================

        return windowScene.windows.first {
            $0.isKeyWindow
        } ?? ASPresentationAnchor()
    }
}

// =====================================================
// MARK: - AppleSignInError
// =====================================================

enum AppleSignInError: LocalizedError {

    // =====================================================
    // INVALID CREDENTIAL
    // =====================================================

    case invalidCredential

    // =====================================================
    // EMAIL UNAVAILABLE
    // =====================================================

    case emailUnavailable

    // =====================================================
    // USER CANCELLED
    // =====================================================

    case userCancelled

    // =====================================================
    // ERROR DESCRIPTION
    // =====================================================

    var errorDescription: String? {

        switch self {

        case .invalidCredential:

            return
                "Apple Sign In returned an invalid credential."

        case .emailUnavailable:

            return
                "Apple could not provide the email address needed to create your RecalllQ account."

        case .userCancelled:

            return
                "Sign in with Apple was cancelled."
        }
    }
}

