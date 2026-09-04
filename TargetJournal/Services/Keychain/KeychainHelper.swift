import Foundation
import Security

/// Secure storage helper using iOS Keychain services.
public final class KeychainHelper: Sendable {
    public static let shared = KeychainHelper()
    
    private let serviceName = "com.targetjournal.apikeys"
    private let deepSeekKeyAccount = "deepseek_api_key"
    
    private init() {}
    
    public func saveDeepSeekKey(_ key: String) throws {
        try save(key: deepSeekKeyAccount, data: Data(key.utf8))
    }
    
    public func getDeepSeekKey() -> String? {
        guard let data = get(key: deepSeekKeyAccount) else { return nil }
        return String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    public func deleteDeepSeekKey() throws {
        try delete(key: deepSeekKeyAccount)
    }
    
    // Generic Keychain operations
    public func save(key: String, data: Data) throws {
        // Delete existing item if present
        let deleteQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(deleteQuery as CFDictionary)
        
        let addQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]
        
        let status = SecItemAdd(addQuery as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.unhandledStatus(status)
        }
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
        
        guard status == errSecSuccess, let data = dataTypeRef as? Data else {
            return nil
        }
        return data
    }
    
    public func delete(key: String) throws {
        let deleteQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key
        ]
        let status = SecItemDelete(deleteQuery as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unhandledStatus(status)
        }
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
