
import Foundation
import GoogleSignIn
import UIKit

// =====================================================
// MANAGER: GoogleSignInManager
// =====================================================
//
// PURPOSE:
//
// Handles Google Sign In authentication for RecalllQ.
//
// AUTHENTICATION FLOW:
//
// LoginView
//      ↓
// GoogleSignInManager
//      ↓
// Google Authentication
//      ↓
// Google user information
//      ↓
// AuthenticationViewModel
//      ↓
// AppState
//      ↓
// MainTabView
//
// IMPORTANT:
//
// Google Sign In uses Google's OAuth authentication flow.
//
// The Google Client ID was created in Google Cloud for:
//
// RecalllQ
//
// iOS Bundle ID:
//
// com.trios2026fak
//
// SECURITY NOTE:
//
// This implementation is appropriate for the current
// LOCAL DEVELOPMENT version of RecalllQ.
//
// A production application should use Google's recommended
// authentication configuration and securely validate tokens
// on a backend server when required.
//
// =====================================================

@MainActor
final class GoogleSignInManager {

    // =====================================================
    // SINGLETON
    // =====================================================

    static let shared =
        GoogleSignInManager()

    // =====================================================
    // GOOGLE CLIENT ID
    // =====================================================
    //
    // Created in Google Cloud Console.
    //
    // =====================================================

    private let clientID =
        "217697447867-bmushce04a9ovrp8da62dej1qo0titjj.apps.googleusercontent.com"

    // =====================================================
    // RESULT MODEL
    // =====================================================

    struct GoogleSignInResult {

        let userID: String
        let email: String
        let name: String
    }

    // =====================================================
    // PRIVATE INIT
    // =====================================================

    private init() {}

    // =====================================================
    // SIGN IN WITH GOOGLE
    // =====================================================

    func signIn() async throws
        -> GoogleSignInResult {

        // =================================================
        // CONFIGURE GOOGLE SIGN IN
        // =================================================

        let configuration =
            GIDConfiguration(
                clientID: clientID
            )

        GIDSignIn.sharedInstance.configuration =
            configuration

        // =================================================
        // FIND PRESENTING VIEW CONTROLLER
        // =================================================

        guard let presentingViewController =
                Self.topViewController()
        else {

            throw GoogleSignInError
                .presentationUnavailable
        }

        // =================================================
        // START GOOGLE SIGN IN
        // =================================================

        let result =
            try await GIDSignIn.sharedInstance
                .signIn(
                    withPresenting:
                        presentingViewController
                )

        // =================================================
        // GOOGLE USER
        // =================================================

        let user =
            result.user

        // =================================================
        // GOOGLE USER ID
        // =================================================

        let userID =
            user.userID ?? ""

        // =================================================
        // GOOGLE EMAIL
        // =================================================

        let email =
            user.profile?.email
                .trimmingCharacters(
                    in: .whitespacesAndNewlines
                )
                .lowercased()
                ?? ""

        // =================================================
        // GOOGLE DISPLAY NAME
        // =================================================

        let name =
            user.profile?.name
                .trimmingCharacters(
                    in: .whitespacesAndNewlines
                )
                ?? ""

        // =================================================
        // VALIDATE USER ID
        // =================================================

        guard !userID.isEmpty else {

            throw GoogleSignInError
                .userInformationUnavailable
        }

        // =================================================
        // VALIDATE EMAIL
        // =================================================

        guard !email.isEmpty else {

            throw GoogleSignInError
                .emailUnavailable
        }

        // =================================================
        // FINAL DISPLAY NAME
        // =================================================

        let finalName =
            name.isEmpty
            ? "RecalllQ Student"
            : name

        // =================================================
        // DEBUG INFORMATION
        // =================================================

        print(
            "🔵 RecalllQ Google Sign In succeeded."
        )

        print(
            "🔵 Google User ID: \(userID)"
        )

        print(
            "🔵 RecalllQ Email: \(email)"
        )

        print(
            "🔵 RecalllQ Name: \(finalName)"
        )

        // =================================================
        // RETURN RESULT
        // =================================================

        return GoogleSignInResult(
            userID: userID,
            email: email,
            name: finalName
        )
    }

    // =====================================================
    // FIND TOP VIEW CONTROLLER
    // =====================================================

    private static func topViewController(
        base:
            UIViewController? = nil
    ) -> UIViewController? {

        let baseViewController: UIViewController?

        if let base {

            baseViewController =
                base

        } else {

            baseViewController =
                UIApplication.shared
                    .connectedScenes
                    .compactMap {
                        $0 as? UIWindowScene
                    }
                    .flatMap {
                        $0.windows
                    }
                    .first {
                        $0.isKeyWindow
                    }?
                    .rootViewController
        }

        guard let controller =
                baseViewController
        else {

            return nil
        }

        // =================================================
        // NAVIGATION CONTROLLER
        // =================================================

        if let navigationController =
                controller
                as? UINavigationController {

            return topViewController(
                base:
                    navigationController
                    .visibleViewController
            )
        }

        // =================================================
        // TAB BAR CONTROLLER
        // =================================================

        if let tabBarController =
                controller
                as? UITabBarController {

            return topViewController(
                base:
                    tabBarController
                    .selectedViewController
            )
        }

        // =================================================
        // PRESENTED VIEW CONTROLLER
        // =================================================

        if let presentedController =
                controller.presentedViewController {

            return topViewController(
                base:
                    presentedController
            )
        }

        // =================================================
        // RETURN CURRENT CONTROLLER
        // =================================================

        return controller
    }
}

// =====================================================
// MARK: - GoogleSignInError
// =====================================================

enum GoogleSignInError:
    LocalizedError {

    // =====================================================
    // PRESENTATION ERROR
    // =====================================================

    case presentationUnavailable

    // =====================================================
    // USER INFORMATION ERROR
    // =====================================================

    case userInformationUnavailable

    // =====================================================
    // EMAIL ERROR
    // =====================================================

    case emailUnavailable

    // =====================================================
    // ERROR DESCRIPTION
    // =====================================================

    var errorDescription: String? {

        switch self {

        case .presentationUnavailable:

            return
                "RecalllQ could not find the screen needed to present Google Sign In."

        case .userInformationUnavailable:

            return
                "Google Sign In did not return the required user information."

        case .emailUnavailable:

            return
                "Google Sign In did not return an email address."
        }
    }
}

