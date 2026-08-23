
import Foundation
import Combine

// =====================================================
// VIEWMODEL: AuthenticationViewModel
// =====================================================
// PURPOSE:
// Controls RecalllQ authentication.
//
// IMPORTANT:
// Each account now has:
// - Unique user ID
// - Name
// - Email
// - Password
//
// This allows RecalllQ to keep each user's:
// - Notes
// - Memories
// - Flashcards
// - Quizzes
// - Study sessions
//
// completely separate.
//
// NOTE:
// This is still LOCAL DEVELOPMENT authentication.
// Passwords are stored locally for development only.
// For production, use Firebase/Auth API + secure
// password/token handling.
// =====================================================

@MainActor
final class AuthenticationViewModel: ObservableObject {

    // =====================================================
    // AUTHENTICATION STATE
    // =====================================================

    @Published var isAuthenticated: Bool = false

    @Published var isLoading: Bool = false

    // =====================================================
    // CURRENT USER
    // =====================================================

    @Published private(set) var currentUserID: String?

    @Published private(set) var currentUserName: String = ""

    @Published private(set) var currentUserEmail: String = ""

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
    // STORAGE
    // =====================================================

    // All local development accounts are stored in one
    // dictionary.
    //
    // Email → Account
    //
    // Each Account contains its own UUID.
    // =====================================================

    private let accountsKey = "recalllq_accounts"

    private let currentUserIDKey = "recalllq_current_user_id"

    private let loggedInKey = "recalllq_logged_in"

    // =====================================================
    // ACCOUNT MODEL
    // =====================================================

    private struct LocalAccount: Codable {

        let id: UUID

        let name: String

        let email: String

        let password: String

        let createdAt: Date
    }

    // =====================================================
    // INIT
    // =====================================================

    init() {

        let loggedIn = UserDefaults.standard.bool(
            forKey: loggedInKey
        )

        isAuthenticated = loggedIn

        // -------------------------------------------------
        // RESTORE CURRENT USER
        // -------------------------------------------------

        if loggedIn,
           let savedUserID = UserDefaults.standard.string(
                forKey: currentUserIDKey
           ),
           let uuid = UUID(uuidString: savedUserID) {

            currentUserID = uuid.uuidString

            // Load account information
            if let account = findAccount(
                userID: uuid.uuidString
            ) {

                currentUserName = account.name

                currentUserEmail = account.email
            } else {

                // Account no longer exists.
                clearCurrentSession()
            }
        }
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
        // LOAD EXISTING ACCOUNTS
        // -------------------------------------------------

        var accounts = loadAccounts()

        // -------------------------------------------------
        // CHECK DUPLICATE EMAIL
        // -------------------------------------------------

        let emailAlreadyExists =
            accounts.values.contains {

                $0.email.localizedCaseInsensitiveCompare(
                    cleanEmail
                ) == .orderedSame
            }

        guard !emailAlreadyExists else {

            errorMessage =
                "An account with this email already exists."

            return
        }

        // -------------------------------------------------
        // CREATE UNIQUE USER ID
        // -------------------------------------------------

        let newUserID = UUID()

        let account = LocalAccount(
            id: newUserID,
            name: cleanName,
            email: cleanEmail,
            password: password,
            createdAt: Date()
        )

        // -------------------------------------------------
        // SAVE ACCOUNT
        // -------------------------------------------------

        accounts[newUserID.uuidString] = account

        saveAccounts(accounts)

        // -------------------------------------------------
        // START USER SESSION
        // -------------------------------------------------

        setCurrentUser(
            account
        )

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
            "User ID: \(newUserID.uuidString)"
        )

        print(
            "========================================"
        )
    }

    // =====================================================
    // LOGIN
    // =====================================================

    func login() {

        clearMessages()

        // -------------------------------------------------
        // RESET AUTHENTICATION STATE
        // -------------------------------------------------

        isAuthenticated = false

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
        // LOAD ALL ACCOUNTS
        // -------------------------------------------------

        let accounts = loadAccounts()

        // -------------------------------------------------
        // FIND ACCOUNT BY EMAIL
        // -------------------------------------------------

        guard let account =
            accounts.values.first(
                where: {
                    $0.email.localizedCaseInsensitiveCompare(
                        cleanEmail
                    ) == .orderedSame
                }
            )
        else {

            errorMessage =
                "The email or password is incorrect."

            return
        }

        // -------------------------------------------------
        // CHECK PASSWORD
        // -------------------------------------------------

        guard password == account.password else {

            errorMessage =
                "The email or password is incorrect."

            return
        }

        // -------------------------------------------------
        // LOGIN SUCCESS
        // -------------------------------------------------

        isLoading = true

        setCurrentUser(
            account
        )

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
            "Name: \(account.name)"
        )

        print(
            "Email: \(account.email)"
        )

        print(
            "User ID: \(account.id.uuidString)"
        )

        print(
            "========================================"
        )
    }

    // =====================================================
    // LOGOUT
    // =====================================================

    func logout() {

        clearMessages()

        clearCurrentSession()

        // -------------------------------------------------
        // CLEAR FORM
        // -------------------------------------------------

        name = ""

        email = ""

        password = ""

        confirmPassword = ""

        print(
            "========================================"
        )

        print(
            "👋 RECALLIQ USER LOGGED OUT"
        )

        print(
            "🔐 Current user session cleared."
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

        let accounts = loadAccounts()

        guard accounts.values.contains(
            where: {
                $0.email.localizedCaseInsensitiveCompare(
                    cleanEmail
                ) == .orderedSame
            }
        ) else {

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
    // CURRENT USER SETUP
    // =====================================================

    private func setCurrentUser(
        _ account: LocalAccount
    ) {

        currentUserID =
            account.id.uuidString

        currentUserName =
            account.name

        currentUserEmail =
            account.email

        UserDefaults.standard.set(
            account.id.uuidString,
            forKey: currentUserIDKey
        )

        UserDefaults.standard.set(
            true,
            forKey: loggedInKey
        )

        isAuthenticated = true
    }

    // =====================================================
    // CLEAR CURRENT SESSION
    // =====================================================

    private func clearCurrentSession() {

        currentUserID = nil

        currentUserName = ""

        currentUserEmail = ""

        UserDefaults.standard.set(
            false,
            forKey: loggedInKey
        )

        UserDefaults.standard.removeObject(
            forKey: currentUserIDKey
        )

        isAuthenticated = false
    }

    // =====================================================
    // LOAD ACCOUNTS
    // =====================================================

    private func loadAccounts()
        -> [String: LocalAccount] {

        guard let data =
            UserDefaults.standard.data(
                forKey: accountsKey
            )
        else {

            return [:]
        }

        do {

            return try JSONDecoder().decode(
                [String: LocalAccount].self,
                from: data
            )

        } catch {

            print(
                "⚠️ Could not load accounts:",
                error.localizedDescription
            )

            return [:]
        }
    }

    // =====================================================
    // SAVE ACCOUNTS
    // =====================================================

    private func saveAccounts(
        _ accounts: [String: LocalAccount]
    ) {

        do {

            let data =
                try JSONEncoder().encode(
                    accounts
                )

            UserDefaults.standard.set(
                data,
                forKey: accountsKey
            )

        } catch {

            print(
                "❌ Could not save accounts:",
                error.localizedDescription
            )
        }
    }

    // =====================================================
    // FIND ACCOUNT BY USER ID
    // =====================================================

    private func findAccount(
        userID: String
    ) -> LocalAccount? {

        let accounts = loadAccounts()

        return accounts[userID]
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
