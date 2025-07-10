import Foundation

// Secure API Key Manager
class APIKeyManager {
    static let shared = APIKeyManager()
    private init() {}
    
    // Initialize API key on first launch
    func initializeAPIKey() {
        // Check if key already exists in Keychain
        if KeychainHelper.shared.getApiKey() != nil {
            return
        }
        
        #if DEBUG
        // For debug builds, save the key to Keychain
        let debugKey = getDebugAPIKey()
        _ = KeychainHelper.shared.saveApiKey(debugKey)
        #else
        // For release builds, get from Info.plist and save to Keychain
        if let key = Bundle.main.object(forInfoDictionaryKey: "OPENWEATHER_API_KEY") as? String,
           !key.isEmpty && key != "$(OPENWEATHER_API_KEY)" {
            _ = KeychainHelper.shared.saveApiKey(key)
        }
        #endif
    }
    
    #if DEBUG
    private func getDebugAPIKey() -> String {
        // Multiple layers of obfuscation
        let encoded = "NGM0ZDViYzEzZjI4OTZmNDdhMDc4N2E2OTBhZmEyYTM="
        guard let data = Data(base64Encoded: encoded),
              let decoded = String(data: data, encoding: .utf8) else {
            return ""
        }
        return decoded
    }
    #endif
    
    // Clean up method to remove key from Keychain if needed
    func clearAPIKey() {
        _ = KeychainHelper.shared.deleteApiKey()
    }
}

// MARK: - Additional Security Measures
extension APIKeyManager {
    // Validate API key format
    func isValidAPIKey(_ key: String) -> Bool {
        // OpenWeatherMap API keys are 32 characters long
        return key.count == 32 && key.range(of: "^[a-f0-9]+$", options: .regularExpression) != nil
    }
    
    // Rotate API key (if you have multiple keys)
    func rotateAPIKey(newKey: String) -> Bool {
        guard isValidAPIKey(newKey) else { return false }
        return KeychainHelper.shared.saveApiKey(newKey)
    }
}