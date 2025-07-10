import Foundation
import Security

class KeychainHelper {
    static let shared = KeychainHelper()
    
    private let service = "com.weather.app"
    private let apiKeyAccount = "openweather_api_key"
    
    private init() {}
    
    // Save API key to Keychain
    func saveApiKey(_ apiKey: String) -> Bool {
        guard let data = apiKey.data(using: .utf8) else {
            print("Failed to convert API key to data")
            return false
        }
        
        // Delete any existing item
        let deleteQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: apiKeyAccount
        ]
        SecItemDelete(deleteQuery as CFDictionary)
        
        // Add new item
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: apiKeyAccount,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    // Retrieve API key from Keychain
    func getApiKey() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: apiKeyAccount,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        if status == errSecSuccess,
           let data = dataTypeRef as? Data,
           let apiKey = String(data: data, encoding: .utf8) {
            return apiKey
        }
        
        return nil
    }
    
    // Delete API key from Keychain
    func deleteApiKey() -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: apiKeyAccount
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess
    }
}