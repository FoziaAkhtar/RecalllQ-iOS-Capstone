
import Foundation
import Combine

// =====================================================
//
// VIEWMODEL: AuthenticationViewModel
//
// =====================================================
//
// PURPOSE:
//
// Controls RecalllQ authentication.
//
// SUPPORTED AUTHENTICATION METHODS:
//
// - Email + Password
// - Sign in with Apple
// - Sign in with Google
// - Guest Mode handled by the app authentication flow
//
// IMPORTANT:
//
// Each account has:
//
// - Unique user ID
// - Name
// - Email
//
// Email/password accounts also have a password stored
// securely in the iOS Keychain.
//
// Apple and Google accounts do not require a local
// RecalllQ password.
//
// This allows RecalllQ to keep each user's:
//
// - Notes
// - Memories
// - Flashcards
// - Quizzes
// - Study sessions
// - Progress
//
// completely separate.
//
// =====================================================
//
// SECURITY:
//
// - Account passwords are stored securely in the
//   iOS Keychain.
// - UserDefaults stores only non-sensitive account
//   information.
// - Existing legacy passwords stored in UserDefaults
//   are automatically migrated into the Keychain.
// - Google authentication is handled through the
//   Google Sign-In SDK.
// - Apple authentication is handled through
//   AppleSignInManager.
//
// =====================================================
//
// APPLE SIGN-IN:
//
// Sign in with Apple uses AppleSignInManager.
//
// The Apple authentication result provides:
//
// - Apple user identifier
// - Email
// - Display name
//
// The Apple email is then connected to the same local
// RecalllQ account system used by email/password login.
//
// =====================================================
//
// GOOGLE SIGN-IN:
//
// Sign in with Google uses GoogleSignInManager.
//
// The Google authentication result provides:
//
// - Google user identifier
// - Email
// - Display name
//
// The Google email is connected to the same local
// RecalllQ account system.
//
// This means Apple, Google, and email/password users
// all use the same user-specific data isolation system.
//
// =====================================================
//
// NOTE:
//
// This is still LOCAL DEVELOPMENT authentication.
//
// For a production application, authentication tokens
// should be securely validated through a backend service.
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

    private let accountsKey =
        "recalllq_accounts"

    private let currentUserIDKey =
        "recalllq_current_user_id"

    private let loggedInKey =
        "recalllq_logged_in"

    // =====================================================
    // PASSWORD KEYCHAIN PREFIX
    // =====================================================

    // Each email/password account gets its own Keychain
    // password entry.
    //
    // Example:
    //
    // RECALLIQ_PASSWORD_12345678-1234-1234-1234-123456789ABC
    //
    // This keeps passwords separated by user ID.
    // =====================================================

    private let passwordKeyPrefix =
        "RECALLIQ_PASSWORD_"

    // =====================================================
    // ACCOUNT MODEL
    // =====================================================

    // IMPORTANT:
    //
    // This model contains ONLY non-sensitive account data.
    //
    // Password is intentionally NOT part of this model.
    //
    // Apple and Google accounts can also use this same
    // model.
    // =====================================================

    private struct LocalAccount: Codable {

        // =================================================
        // UNIQUE USER ID
        // =================================================

        let id: UUID

        // =================================================
        // DISPLAY NAME
        // =================================================

        let name: String

        // =================================================
        // EMAIL
        // =================================================

        let email: String

        // =================================================
        // ACCOUNT CREATION DATE
        // =================================================

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

        let loggedIn =
            UserDefaults.standard.bool(
                forKey: loggedInKey
            )

        isAuthenticated =
            loggedIn

        // =================================================
        // RESTORE CURRENT USER
        // =================================================

        if loggedIn,
           let savedUserID =
                UserDefaults.standard.string(
                    forKey: currentUserIDKey
                ),
           let uuid =
                UUID(uuidString: savedUserID) {

            currentUserID =
                uuid.uuidString

            // =================================================
            // LOAD CURRENT USER ACCOUNT
            // =================================================

            if let account =
                findAccount(
                    userID: uuid.uuidString
                ) {

                currentUserName =
                    account.name

                currentUserEmail =
                    account.email

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
            email
                .trimmingCharacters(
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

        var accounts =
            loadAccounts()

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

        let newUserID =
            UUID()

        let account =
            LocalAccount(
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

        accounts[
            newUserID.uuidString
        ] =
            account

        saveAccounts(
            accounts
        )

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

        isAuthenticated =
            false

        // =================================================
        // CLEAN EMAIL
        // =================================================

        let cleanEmail =
            email
                .trimmingCharacters(
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

        let accounts =
            loadAccounts()

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

        isLoading =
            true

        setCurrentUser(
            account
        )

        isLoading =
            false

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
    // SIGN IN WITH APPLE
    // =====================================================

    // PURPOSE:
    //
    // Connects Apple's authentication result to the existing
    // RecalllQ local account system.
    //
    // IMPORTANT:
    //
    // This does NOT create a separate Apple-only data system.
    //
    // The Apple account is connected to the same:
    //
    // - Notes
    // - Memories
    // - Flashcards
    // - Quizzes
    // - Study sessions
    // - Progress
    //
    // storage used by the existing RecalllQ account system.
    // =====================================================

    func signInWithApple() async {

        clearMessages()

        // =================================================
        // START LOADING STATE
        // =================================================

        isLoading =
            true

        defer {
            isLoading =
                false
        }

        // =================================================
        // START APPLE AUTHENTICATION
        // =================================================

        do {

            let result =
                try await AppleSignInManager.shared.signIn()

            // =================================================
            // CLEAN APPLE EMAIL
            // =================================================

            let cleanEmail =
                result.email
                    .trimmingCharacters(
                        in: .whitespacesAndNewlines
                    )
                    .lowercased()

            // =================================================
            // VALIDATE APPLE EMAIL
            // =================================================

            guard isValidEmail(cleanEmail) else {

                errorMessage =
                    "Apple Sign In returned an invalid email address."

                return
            }

            // =================================================
            // LOAD EXISTING RECALLIQ ACCOUNTS
            // =================================================

            var accounts =
                loadAccounts()

            // =================================================
            // CHECK FOR EXISTING RECALLIQ ACCOUNT
            // =================================================

            if let existingAccount =
                accounts.values.first(
                    where: {

                        $0.email.localizedCaseInsensitiveCompare(
                            cleanEmail
                        ) == .orderedSame
                    }
                ) {

                // =================================================
                // EXISTING ACCOUNT FOUND
                // =================================================

                setCurrentUser(
                    existingAccount
                )

                name =
                    existingAccount.name

                email =
                    existingAccount.email

                password = ""
                confirmPassword = ""

                successMessage =
                    "Welcome back to RecalllQ!"

                print(
                    "========================================"
                )

                print(
                    " RECALLIQ APPLE LOGIN SUCCESSFUL"
                )

                print(
                    "Name: \(existingAccount.name)"
                )

                print(
                    "Email: \(existingAccount.email)"
                )

                print(
                    "User ID: \(existingAccount.id.uuidString)"
                )

                print(
                    "Authentication: Sign in with Apple"
                )

                print(
                    "========================================"
                )

                return
            }

            // =================================================
            // CREATE NEW LOCAL RECALLIQ ACCOUNT
            // =================================================

            let newUserID =
                UUID()

            // =================================================
            // DETERMINE DISPLAY NAME
            // =================================================

            let appleName =
                result.name
                    .trimmingCharacters(
                        in: .whitespacesAndNewlines
                    )

            let finalName =
                appleName.isEmpty
                ? "RecalllQ Student"
                : appleName

            // =================================================
            // CREATE ACCOUNT MODEL
            // =================================================

            let newAccount =
                LocalAccount(
                    id: newUserID,
                    name: finalName,
                    email: cleanEmail,
                    createdAt: Date()
                )

            // =================================================
            // SAVE ACCOUNT
            // =================================================

            accounts[
                newUserID.uuidString
            ] =
                newAccount

            saveAccounts(
                accounts
            )

            // =================================================
            // START NEW USER SESSION
            // =================================================

            setCurrentUser(
                newAccount
            )

            // =================================================
            // UPDATE FORM INFORMATION
            // =================================================

            name =
                finalName

            email =
                cleanEmail

            password = ""
            confirmPassword = ""

            // =================================================
            // SUCCESS MESSAGE
            // =================================================

            successMessage =
                "Welcome to RecalllQ!"

            // =================================================
            // DEBUG INFORMATION
            // =================================================

            print(
                "========================================"
            )

            print(
                " NEW RECALLIQ APPLE ACCOUNT CREATED"
            )

            print(
                "Name: \(finalName)"
            )

            print(
                "Email: \(cleanEmail)"
            )

            print(
                "User ID: \(newUserID.uuidString)"
            )

            print(
                "Authentication: Sign in with Apple"
            )

            print(
                "Password: [NOT REQUIRED FOR APPLE SIGN IN]"
            )

            print(
                "========================================"
            )

        } catch AppleSignInError.userCancelled {

            // =================================================
            // USER CANCELLED APPLE SIGN IN
            // =================================================

            errorMessage =
                nil

            successMessage =
                nil

        } catch {

            // =================================================
            // APPLE SIGN IN FAILED
            // =================================================

            errorMessage =
                error.localizedDescription

            print(
                "❌ RecalllQ Apple Sign In failed: \(error.localizedDescription)"
            )
        }
    }

    // =====================================================
    // SIGN IN WITH GOOGLE
    // =====================================================

    // PURPOSE:
    //
    // Connects Google's authentication result to the
    // existing RecalllQ local account system.
    //
    // IMPORTANT:
    //
    // Google users use the SAME LocalAccount model as:
    //
    // - Email/password users
    // - Apple users
    //
    // This means Google authentication does not create
    // another data storage system.
    //
    // All user-specific data continues to use the same
    // AppState and user-specific storage architecture.
    //
    // =====================================================

    func signInWithGoogle() async {

        clearMessages()

        // =================================================
        // START LOADING STATE
        // =================================================

        isLoading =
            true

        defer {
            isLoading =
                false
        }

        // =================================================
        // START GOOGLE AUTHENTICATION
        // =================================================

        do {

            let result =
                try await GoogleSignInManager
                    .shared
                    .signIn()

            // =================================================
            // CLEAN GOOGLE EMAIL
            // =================================================

            let cleanEmail =
                result.email
                    .trimmingCharacters(
                        in: .whitespacesAndNewlines
                    )
                    .lowercased()

            // =================================================
            // VALIDATE GOOGLE EMAIL
            // =================================================

            guard isValidEmail(cleanEmail) else {

                errorMessage =
                    "Google Sign In returned an invalid email address."

                return
            }

            // =================================================
            // LOAD EXISTING RECALLIQ ACCOUNTS
            // =================================================

            var accounts =
                loadAccounts()

            // =================================================
            // CHECK FOR EXISTING RECALLIQ ACCOUNT
            // =================================================

            if let existingAccount =
                accounts.values.first(
                    where: {

                        $0.email.localizedCaseInsensitiveCompare(
                            cleanEmail
                        ) == .orderedSame
                    }
                ) {

                // =================================================
                // EXISTING ACCOUNT FOUND
                // =================================================

                setCurrentUser(
                    existingAccount
                )

                // =================================================
                // UPDATE FORM INFORMATION
                // =================================================

                name =
                    existingAccount.name

                email =
                    existingAccount.email

                password = ""
                confirmPassword = ""

                // =================================================
                // SUCCESS MESSAGE
                // =================================================

                successMessage =
                    "Welcome back to RecalllQ!"

                // =================================================
                // DEBUG INFORMATION
                // =================================================

                print(
                    "========================================"
                )

                print(
                    "🔵 RECALLIQ GOOGLE LOGIN SUCCESSFUL"
                )

                print(
                    "Name: \(existingAccount.name)"
                )

                print(
                    "Email: \(existingAccount.email)"
                )

                print(
                    "User ID: \(existingAccount.id.uuidString)"
                )

                print(
                    "Authentication: Sign in with Google"
                )

                print(
                    "========================================"
                )

                return
            }

            // =================================================
            // CREATE NEW LOCAL RECALLIQ ACCOUNT
            // =================================================

            let newUserID =
                UUID()

            // =================================================
            // DETERMINE DISPLAY NAME
            // =================================================

            let googleName =
                result.name
                    .trimmingCharacters(
                        in: .whitespacesAndNewlines
                    )

            let finalName =
                googleName.isEmpty
                ? "RecalllQ Student"
                : googleName

            // =================================================
            // CREATE ACCOUNT MODEL
            // =================================================

            let newAccount =
                LocalAccount(
                    id: newUserID,
                    name: finalName,
                    email: cleanEmail,
                    createdAt: Date()
                )

            // =================================================
            // SAVE ACCOUNT
            // =================================================

            accounts[
                newUserID.uuidString
            ] =
                newAccount

            saveAccounts(
                accounts
            )

            // =================================================
            // START NEW USER SESSION
            // =================================================

            setCurrentUser(
                newAccount
            )

            // =================================================
            // UPDATE FORM INFORMATION
            // =================================================

            name =
                finalName

            email =
                cleanEmail

            password = ""
            confirmPassword = ""

            // =================================================
            // SUCCESS MESSAGE
            // =================================================

            successMessage =
                "Welcome to RecalllQ!"

            // =================================================
            // DEBUG INFORMATION
            // =================================================

            print(
                "========================================"
            )

            print(
                "🔵 NEW RECALLIQ GOOGLE ACCOUNT CREATED"
            )

            print(
                "Name: \(finalName)"
            )

            print(
                "Email: \(cleanEmail)"
            )

            print(
                "User ID: \(newUserID.uuidString)"
            )

            print(
                "Authentication: Sign in with Google"
            )

            print(
                "Password: [NOT REQUIRED FOR GOOGLE SIGN IN]"
            )

            print(
                "========================================"
            )

        } catch {

            // =================================================
            // GOOGLE SIGN IN FAILED
            // =================================================

            errorMessage =
                error.localizedDescription

            print(
                "❌ RecalllQ Google Sign In failed: \(error.localizedDescription)"
            )
        }
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
            email
                .trimmingCharacters(
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

        let accounts =
            loadAccounts()

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
        //
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

        isAuthenticated =
            true
    }

    // =====================================================
    // CLEAR CURRENT SESSION
    // =====================================================

    private func clearCurrentSession() {

        currentUserID =
            nil

        currentUserName =
            ""

        currentUserEmail =
            ""

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

        isAuthenticated =
            false
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

                let legacyAccount =
                    item.value

                result[item.key] =
                    LocalAccount(
                        id:
                            legacyAccount.id,
                        name:
                            legacyAccount.name,
                        email:
                            legacyAccount.email,
                        createdAt:
                            legacyAccount.createdAt
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

                let legacyAccount =
                    item.value

                result[item.key] =
                    LocalAccount(
                        id:
                            legacyAccount.id,
                        name:
                            legacyAccount.name,
                        email:
                            legacyAccount.email,
                        createdAt:
                            legacyAccount.createdAt
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
        _ legacyAccounts:
            [String: LegacyLocalAccount]
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
            // DO NOT OVERWRITE EXISTING KEYCHAIN PASSWORD
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

        let accounts =
            loadAccounts()

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

        errorMessage =
            nil

        successMessage =
            nil
    }
}

