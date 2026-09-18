
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
// SECURITY:
// - Account passwords are stored securely in the iOS Keychain.
// - UserDefaults stores only non-sensitive account information.
// - Existing legacy passwords stored in UserDefaults are
//   automatically migrated into the Keychain.
//
// NOTE:
// This is still LOCAL DEVELOPMENT authentication.
//
// For a production application, use Firebase/Auth API
// or another secure authentication backend with proper
// password hashing, authentication tokens, and account
// recovery.
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

    // UserDefaults stores only non-sensitive account
    // information.
    //
    // Passwords are NEVER stored in UserDefaults.
    // =====================================================

    private let accountsKey = "recalllq_accounts"
    private let currentUserIDKey = "recalllq_current_user_id"
    private let loggedInKey = "recalllq_logged_in"

    // =====================================================
    // PASSWORD KEYCHAIN PREFIX
    // =====================================================

    // Each account gets its own Keychain password entry.
    //
    // Example:
    //
    // RECALLIQ_PASSWORD_12345678-1234-1234-1234-123456789ABC
    //
    // This keeps passwords separated by user ID.
    // =====================================================

    private let passwordKeyPrefix = "RECALLIQ_PASSWORD_"

    // =====================================================
    // ACCOUNT MODEL
    // =====================================================

    // IMPORTANT:
    // This model contains ONLY non-sensitive account data.
    //
    // Password is intentionally NOT part of this model.
    // =====================================================

    private struct LocalAccount: Codable {

        let id: UUID
        let name: String
        let email: String
        let createdAt: Date
    }

    // =====================================================
    // LEGACY ACCOUNT MODEL
    // =====================================================

    // Older versions of RecalllQ stored the password
    // directly inside UserDefaults.
    //
    // This model is used ONLY to migrate old accounts.
    //
    // After migration, the password is moved to Keychain
    // and the legacy account data is replaced with the
    // secure account model above.
    // =====================================================

    private struct LegacyLocalAccount: Codable {

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

        // =================================================
        // MIGRATE LEGACY ACCOUNT PASSWORDS
        // =================================================

        migrateLegacyAccounts()

        // =================================================
        // RESTORE LOGIN STATE
        // =================================================

        let loggedIn = UserDefaults.standard.bool(
            forKey: loggedInKey
        )

        isAuthenticated = loggedIn

        // =================================================
        // RESTORE CURRENT USER
        // =================================================

        if loggedIn,
           let savedUserID = UserDefaults.standard.string(
                forKey: currentUserIDKey
           ),
           let uuid = UUID(uuidString: savedUserID) {

            currentUserID = uuid.uuidString

            // =================================================
            // LOAD CURRENT USER ACCOUNT
            // =================================================

            if let account = findAccount(
                userID: uuid.uuidString
            ) {

                currentUserName = account.name
                currentUserEmail = account.email

            } else {

                // =================================================
                // ACCOUNT NO LONGER EXISTS
                // =================================================

                clearCurrentSession()
            }
        }
    }

    // =====================================================
    // CREATE ACCOUNT
    // =====================================================

    func createAccount() {

        clearMessages()

        // =================================================
        // CLEAN FORM DATA
        // =================================================

        let cleanName =
            name.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        let cleanEmail =
            email.trimmingCharacters(
                in: .whitespacesAndNewlines
            )
            .lowercased()

        // =================================================
        // VALIDATE NAME
        // =================================================

        guard !cleanName.isEmpty else {

            errorMessage =
                "Please enter your name."

            return
        }

        // =================================================
        // VALIDATE EMAIL
        // =================================================

        guard isValidEmail(cleanEmail) else {

            errorMessage =
                "Please enter a valid email address."

            return
        }

        // =================================================
        // VALIDATE PASSWORD
        // =================================================

        guard password.count >= 6 else {

            errorMessage =
                "Password must contain at least 6 characters."

            return
        }

        // =================================================
        // CONFIRM PASSWORD
        // =================================================

        guard password == confirmPassword else {

            errorMessage =
                "Passwords do not match."

            return
        }

        // =================================================
        // LOAD EXISTING ACCOUNTS
        // =================================================

        var accounts = loadAccounts()

        // =================================================
        // CHECK DUPLICATE EMAIL
        // =================================================

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

        // =================================================
        // CREATE UNIQUE USER ID
        // =================================================

        let newUserID = UUID()

        let account = LocalAccount(
            id: newUserID,
            name: cleanName,
            email: cleanEmail,
            createdAt: Date()
        )

        // =================================================
        // SAVE PASSWORD SECURELY
        // =================================================

        let passwordSaved =
            savePasswordToKeychain(
                password,
                for: newUserID
            )

        guard passwordSaved else {

            errorMessage =
                "The account could not be created because the password could not be stored securely."

            return
        }

        // =================================================
        // SAVE NON-SENSITIVE ACCOUNT INFORMATION
        // =================================================

        accounts[newUserID.uuidString] = account

        saveAccounts(accounts)

        // =================================================
        // START USER SESSION
        // =================================================

        setCurrentUser(
            account
        )

        // =================================================
        // CLEAR PASSWORD FIELDS
        // =================================================

        password = ""
        confirmPassword = ""

        // =================================================
        // SUCCESS MESSAGE
        // =================================================

        successMessage =
            "Account created successfully."

        // =================================================
        // DEBUG INFORMATION
        // =================================================

        // IMPORTANT:
        // Password is NEVER printed.
        // =================================================

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
            "Password: [SECURED IN KEYCHAIN]"
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

        // =================================================
        // RESET AUTHENTICATION STATE
        // =================================================

        isAuthenticated = false

        // =================================================
        // CLEAN EMAIL
        // =================================================

        let cleanEmail =
            email.trimmingCharacters(
                in: .whitespacesAndNewlines
            )
            .lowercased()

        // =================================================
        // VALIDATE EMAIL
        // =================================================

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

        // =================================================
        // VALIDATE PASSWORD
        // =================================================

        guard !password.isEmpty else {

            errorMessage =
                "Please enter your password."

            return
        }

        // =================================================
        // LOAD ALL ACCOUNTS
        // =================================================

        let accounts = loadAccounts()

        // =================================================
        // FIND ACCOUNT BY EMAIL
        // =================================================

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

        // =================================================
        // LOAD PASSWORD FROM KEYCHAIN
        // =================================================

        guard let storedPassword =
                loadPasswordFromKeychain(
                    for: account.id
                )
        else {

            errorMessage =
                "The account password could not be accessed securely."

            print(
                "❌ Password could not be loaded from Keychain for user \(account.id.uuidString)"
            )

            return
        }

        // =================================================
        // CHECK PASSWORD
        // =================================================

        guard password == storedPassword else {

            errorMessage =
                "The email or password is incorrect."

            return
        }

        // =================================================
        // LOGIN SUCCESS
        // =================================================

        isLoading = true

        setCurrentUser(
            account
        )

        isLoading = false

        successMessage =
            "Welcome back to RecalllQ!"

        // =================================================
        // CLEAR PASSWORD FIELD
        // =================================================

        password = ""
        confirmPassword = ""

        // =================================================
        // DEBUG INFORMATION
        // =================================================

        // IMPORTANT:
        // Password is NEVER printed.
        // =================================================

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
            "Password: [SECURED IN KEYCHAIN]"
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

        // =================================================
        // CLEAR FORM
        // =================================================

        name = ""
        email = ""
        password = ""
        confirmPassword = ""

        // =================================================
        // DEBUG INFORMATION
        // =================================================

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

        // =================================================
        // CLEAN EMAIL
        // =================================================

        let cleanEmail =
            email.trimmingCharacters(
                in: .whitespacesAndNewlines
            )
            .lowercased()

        // =================================================
        // VALIDATE EMAIL
        // =================================================

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

        // =================================================
        // CHECK ACCOUNT
        // =================================================

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

        // =================================================
        // PASSWORD RESET
        // =================================================

        // IMPORTANT:
        // This is still a local-development placeholder.
        //
        // A real production password reset would send a
        // secure reset link through an authentication
        // backend.
        // =================================================

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

        // =================================================
        // UPDATE CURRENT USER
        // =================================================

        currentUserID =
            account.id.uuidString

        currentUserName =
            account.name

        currentUserEmail =
            account.email

        // =================================================
        // SAVE CURRENT USER ID
        // =================================================

        UserDefaults.standard.set(
            account.id.uuidString,
            forKey: currentUserIDKey
        )

        // =================================================
        // SAVE LOGIN STATE
        // =================================================

        UserDefaults.standard.set(
            true,
            forKey: loggedInKey
        )

        // =================================================
        // UPDATE AUTHENTICATION STATE
        // =================================================

        isAuthenticated = true
    }

    // =====================================================
    // CLEAR CURRENT SESSION
    // =====================================================

    private func clearCurrentSession() {

        currentUserID = nil
        currentUserName = ""
        currentUserEmail = ""

        // =================================================
        // CLEAR LOGIN STATE
        // =================================================

        UserDefaults.standard.set(
            false,
            forKey: loggedInKey
        )

        UserDefaults.standard.removeObject(
            forKey: currentUserIDKey
        )

        // =================================================
        // UPDATE AUTHENTICATION STATE
        // =================================================

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

        // =================================================
        // TRY LEGACY FORMAT FIRST
        // =================================================

        // This is important because the legacy format
        // contains the password.
        //
        // We need to detect and migrate it before decoding
        // the new secure account format.
        // =================================================

        if let legacyAccounts =
            try? JSONDecoder().decode(
                [String: LegacyLocalAccount].self,
                from: data
            ) {

            // =================================================
            // MIGRATE LEGACY PASSWORDS
            // =================================================

            let migrationSuccessful =
                migrateLegacyAccounts(
                    legacyAccounts
                )

            guard migrationSuccessful else {

                print(
                    "❌ Legacy account password migration could not be completed."
                )

                return [:]
            }

            // =================================================
            // RETURN SECURE ACCOUNT MODEL
            // =================================================

            return legacyAccounts.reduce(
                into: [String: LocalAccount]()
            ) { result, item in

                let legacyAccount = item.value

                result[item.key] =
                    LocalAccount(
                        id: legacyAccount.id,
                        name: legacyAccount.name,
                        email: legacyAccount.email,
                        createdAt: legacyAccount.createdAt
                    )
            }
        }

        // =================================================
        // LOAD CURRENT SECURE FORMAT
        // =================================================

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

            // =================================================
            // SAVE ONLY NON-SENSITIVE DATA
            // =================================================

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
    // MIGRATE ALL LEGACY ACCOUNTS
    // =====================================================

    private func migrateLegacyAccounts() {

        guard let data =
                UserDefaults.standard.data(
                    forKey: accountsKey
                )
        else {

            return
        }

        guard let legacyAccounts =
            try? JSONDecoder().decode(
                [String: LegacyLocalAccount].self,
                from: data
            )
        else {

            // =================================================
            // DATA IS ALREADY USING THE NEW SECURE FORMAT
            // =================================================

            return
        }

        // =================================================
        // MIGRATE PASSWORDS
        // =================================================

        guard migrateLegacyAccounts(
            legacyAccounts
        ) else {

            print(
                "⚠️ RecalllQ account security migration is still pending."
            )

            return
        }

        // =================================================
        // CREATE SECURE ACCOUNT DICTIONARY
        // =================================================

        let secureAccounts =
            legacyAccounts.reduce(
                into: [String: LocalAccount]()
            ) { result, item in

                let legacyAccount = item.value

                result[item.key] =
                    LocalAccount(
                        id: legacyAccount.id,
                        name: legacyAccount.name,
                        email: legacyAccount.email,
                        createdAt: legacyAccount.createdAt
                    )
            }

        // =================================================
        // REPLACE LEGACY USERDEFAULTS DATA
        // =================================================

        saveAccounts(
            secureAccounts
        )

        print(
            "🔐 RecalllQ legacy account passwords migrated to Keychain."
        )
    }

    // =====================================================
    // MIGRATE LEGACY ACCOUNT PASSWORDS
    // =====================================================

    private func migrateLegacyAccounts(
        _ legacyAccounts: [String: LegacyLocalAccount]
    ) -> Bool {

        // =================================================
        // SAVE EVERY PASSWORD TO KEYCHAIN
        // =================================================

        for account in legacyAccounts.values {

            let key =
                passwordKey(
                    for: account.id
                )

            // =================================================
            // DO NOT OVERWRITE AN EXISTING KEYCHAIN PASSWORD
            // =================================================

            if KeychainService.shared.read(
                forKey: key
            ) != nil {

                continue
            }

            // =================================================
            // SAVE LEGACY PASSWORD SECURELY
            // =================================================

            let saved =
                KeychainService.shared.save(
                    account.password,
                    forKey: key
                )

            guard saved else {

                print(
                    "❌ Could not migrate password for user \(account.id.uuidString)"
                )

                return false
            }
        }

        return true
    }

    // =====================================================
    // SAVE PASSWORD TO KEYCHAIN
    // =====================================================

    private func savePasswordToKeychain(
        _ password: String,
        for userID: UUID
    ) -> Bool {

        let key =
            passwordKey(
                for: userID
            )

        return KeychainService.shared.save(
            password,
            forKey: key
        )
    }

    // =====================================================
    // LOAD PASSWORD FROM KEYCHAIN
    // =====================================================

    private func loadPasswordFromKeychain(
        for userID: UUID
    ) -> String? {

        let key =
            passwordKey(
                for: userID
            )

        return KeychainService.shared.read(
            forKey: key
        )
    }

    // =====================================================
    // CREATE PASSWORD KEYCHAIN KEY
    // =====================================================

    private func passwordKey(
        for userID: UUID
    ) -> String {

        return passwordKeyPrefix +
            userID.uuidString
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
