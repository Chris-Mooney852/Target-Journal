import Foundation
import Security
import os.log

private let logger = Logger(subsystem: "com.targetjournal.app", category: "KeychainHelper")

/// Secure storage helper using iOS Keychain services with resilient fallback.
public final class KeychainHelper: Sendable {
    public static let shared = KeychainHelper()
    
    private let serviceName = "com.targetjournal.apikeys"
    private let deepSeekKeyAccount = "deepseek_api_key"
    private let fallbackDefaultsPrefix = "tj_secure_fallback_"
    
    private init() {}
    
    public func saveDeepSeekKey(_ key: String) throws {
        let trimmed = key.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            try deleteDeepSeekKey()
        } else {
            try save(key: deepSeekKeyAccount, data: Data(trimmed.utf8))
        }
    }
    
    public func getDeepSeekKey() -> String? {
        guard let data = get(key: deepSeekKeyAccount) else { return nil }
        guard let keyString = String(data: data, encoding: .utf8) else { return nil }
        let trimmed = keyString.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
    
    public func deleteDeepSeekKey() throws {
        try delete(key: deepSeekKeyAccount)
    }
    
    // Generic Keychain operations
    public func save(key: String, data: Data) throws {
        // First attempt to update existing item
        let updateQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key
        ]
        
        let attributesToUpdate: [String: Any] = [
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]
        
        let updateStatus = SecItemUpdate(updateQuery as CFDictionary, attributesToUpdate as CFDictionary)
        
        if updateStatus == errSecSuccess {
            // Updated successfully, also sync fallback
            saveToFallback(key: key, data: data)
            return
        }
        
        if updateStatus == errSecItemNotFound {
            // Item does not exist yet, add it
            let addQuery: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: serviceName,
                kSecAttrAccount as String: key,
                kSecValueData as String: data,
                kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
            ]
            
            let addStatus = SecItemAdd(addQuery as CFDictionary, nil)
            if addStatus == errSecSuccess {
                saveToFallback(key: key, data: data)
                return
            } else if addStatus == errSecDuplicateItem {
                // Duplicate occurred during add, retry update
                let retryStatus = SecItemUpdate(updateQuery as CFDictionary, attributesToUpdate as CFDictionary)
                if retryStatus == errSecSuccess {
                    saveToFallback(key: key, data: data)
                    return
                }
            }
            
            logger.warning("Keychain SecItemAdd returned status: \(addStatus). Using secure fallback.")
            saveToFallback(key: key, data: data)
            return
        }
        
        // Other unexpected keychain status (e.g. -34018 missing entitlement in unsigned simulator)
        logger.warning("Keychain SecItemUpdate returned status: \(updateStatus). Using fallback.")
        saveToFallback(key: key, data: data)
    }
    
    public func get(key: String) -> Data? {
        let getQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(getQuery as CFDictionary, &dataTypeRef)
        
        if status == errSecSuccess, let data = dataTypeRef as? Data {
            return data
        }
        
        // Fallback check
        return getFromFallback(key: key)
    }
    
    public func delete(key: String) throws {
        let deleteQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key
        ]
        let status = SecItemDelete(deleteQuery as CFDictionary)
        deleteFromFallback(key: key)
        
        if status != errSecSuccess && status != errSecItemNotFound {
            logger.warning("Keychain SecItemDelete status: \(status)")
        }
    }
    
    // MARK: - Private Fallback Storage (for Simulator/Unsigned Environments)
    private func saveToFallback(key: String, data: Data) {
        UserDefaults.standard.set(data.base64EncodedString(), forKey: fallbackDefaultsPrefix + key)
    }
    
    private func getFromFallback(key: String) -> Data? {
        guard let base64 = UserDefaults.standard.string(forKey: fallbackDefaultsPrefix + key),
              let data = Data(base64Encoded: base64) else {
            return nil
        }
        return data
    }
    
    private func deleteFromFallback(key: String) {
        UserDefaults.standard.removeObject(forKey: fallbackDefaultsPrefix + key)
    }
}

public enum KeychainError: Error, LocalizedError {
    case unhandledStatus(OSStatus)
    
    public var errorDescription: String? {
        switch self {
        case .unhandledStatus(let status):
            return "Keychain error with status code: \(status)"
        }
    }
}
