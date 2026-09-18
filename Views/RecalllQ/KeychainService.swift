
import Foundation
import Security

// =====================================================
// SERVICE: KeychainService
// =====================================================

// PURPOSE:
// Provides secure local storage for sensitive values
// such as the OpenAI API key.
//
// WHY KEYCHAIN:
// UserDefaults is designed for application preferences
// and should not be used to store sensitive secrets.
//
// The iOS Keychain provides protected storage for
// sensitive application data.
//
// FEATURES:
// - Save sensitive strings securely
// - Read sensitive strings securely
// - Delete sensitive strings securely
// - Used by APIKeySettingsView
// - Used by QuizAPIService
// - No external dependencies
// =====================================================

final class KeychainService {

    // =====================================================
    // SHARED INSTANCE
    // =====================================================

    static let shared = KeychainService()

    // =====================================================
    // PRIVATE INITIALIZER
    // =====================================================

    private init() {}

    // =====================================================
    // KEYCHAIN SERVICE IDENTIFIER
    // =====================================================

    private let service = "com.trios2026fak.RecalllQ"

    // =====================================================
    // SAVE VALUE
    // =====================================================

    func save(
        _ value: String,
        forKey key: String
    ) -> Bool {

        guard let data = value.data(
            using: .utf8
        ) else {

            print("❌ Keychain could not encode value.")

            return false
        }

        // =================================================
        // REMOVE EXISTING VALUE
        // =================================================

        delete(
            forKey: key
        )

        // =================================================
        // CREATE KEYCHAIN QUERY
        // =================================================

        let query: [String: Any] = [

            kSecClass as String:
                kSecClassGenericPassword,

            kSecAttrService as String:
                service,

            kSecAttrAccount as String:
                key,

            kSecValueData as String:
                data,

            kSecAttrAccessible as String:
                kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]

        // =================================================
        // SAVE TO KEYCHAIN
        // =================================================

        let status = SecItemAdd(
            query as CFDictionary,
            nil
        )

        // =================================================
        // RESULT
        // =================================================

        if status == errSecSuccess {

            print(
                "🔐 Keychain value saved successfully."
            )

            return true
        }

        print(
            "❌ Keychain save failed. Status: \(status)"
        )

        return false
    }

    // =====================================================
    // READ VALUE
    // =====================================================

    func read(
        forKey key: String
    ) -> String? {

        // =================================================
        // CREATE KEYCHAIN QUERY
        // =================================================

        let query: [String: Any] = [

            kSecClass as String:
                kSecClassGenericPassword,

            kSecAttrService as String:
                service,

            kSecAttrAccount as String:
                key,

            kSecReturnData as String:
                true,

            kSecMatchLimit as String:
                kSecMatchLimitOne
        ]

        // =================================================
        // READ FROM KEYCHAIN
        // =================================================

        var result: AnyObject?

        let status = SecItemCopyMatching(
            query as CFDictionary,
            &result
        )

        // =================================================
        // CHECK RESULT
        // =================================================

        guard status == errSecSuccess else {

            if status != errSecItemNotFound {

                print(
                    "⚠️ Keychain read failed. Status: \(status)"
                )
            }

            return nil
        }

        // =================================================
        // CONVERT DATA TO STRING
        // =================================================

        guard let data = result as? Data else {

            print(
                "⚠️ Keychain returned invalid data."
            )

            return nil
        }

        return String(
            data: data,
            encoding: .utf8
        )
    }

    // =====================================================
    // DELETE VALUE
    // =====================================================

    @discardableResult
    func delete(
        forKey key: String
    ) -> Bool {

        let query: [String: Any] = [

            kSecClass as String:
                kSecClassGenericPassword,

            kSecAttrService as String:
                service,

            kSecAttrAccount as String:
                key
        ]

        let status = SecItemDelete(
            query as CFDictionary
        )

        // =================================================
        // DELETE RESULT
        // =================================================

        if status == errSecSuccess ||
            status == errSecItemNotFound {

            return true
        }

        print(
            "⚠️ Keychain delete failed. Status: \(status)"
        )

        return false
    }
}

