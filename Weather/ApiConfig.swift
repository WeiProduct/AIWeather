import Foundation

struct ApiConfig {
    // Vercel Proxy Configuration
    // 部署后替换为你的 Vercel URL，例如: https://weather-api-proxy.vercel.app
    static let proxyBaseURL = "https://vercel-proxy-weis-projects-90c8634a.vercel.app"
    
    // OpenWeatherMap API 密钥
    static var openWeatherMapApiKey: String {
        // 1. Try to get from Info.plist (configured via build settings)
        if let key = Bundle.main.object(forInfoDictionaryKey: "OPENWEATHER_API_KEY") as? String,
           !key.isEmpty && key != "$(OPENWEATHER_API_KEY)" {
            return key
        }
        
        // 2. Try to get from Keychain
        if let key = KeychainHelper.shared.getApiKey() {
            return key
        }
        
        // 3. For development/debug builds only
        #if DEBUG
        // Use obfuscated key for debug builds
        return deobfuscateKey()
        #else
        // In release builds, return empty string if not configured
        // The app should use proxy service in production
        return ""
        #endif
    }
    
    // API 基础URL
    static let openWeatherMapBaseURL = "https://api.openweathermap.org/data/2.5"
    static let openWeatherMapGeoBaseURL = "https://api.openweathermap.org/geo/1.0"
    
    // 是否使用代理服务器（推荐用于生产环境）
    static var useProxy: Bool {
        // 在生产环境中使用代理
        #if DEBUG
        return false // 开发时可以直接使用 API
        #else
        return true  // 发布版本使用代理保护 API 密钥
        #endif
    }
    
    // 检查API密钥是否已配置
    static var isApiKeyConfigured: Bool {
        // 使用代理服务器时始终返回 true
        if useProxy {
            return true
        }
        let key = openWeatherMapApiKey
        return !key.isEmpty && key != "YOUR_API_KEY" && key != "$(OPENWEATHER_API_KEY)"
    }
    
    // API请求的通用参数
    @MainActor
    static func commonParams() -> [String: String] {
        return [
            "appid": openWeatherMapApiKey,
            "units": "metric", // 使用摄氏度
            "lang": LanguageManager.shared.currentLanguage.apiCode    // 动态语言描述
        ]
    }
    
    // MARK: - API Key Protection
    #if DEBUG
    private static func deobfuscateKey() -> String {
        // Obfuscated key - split and reversed to avoid plain text
        let parts = [
            "a3", "ac", "cf", "fb", "1b", "ce",
            "cc", "b2", "05", "12", "57", "d4",
            "e7", "a7", "94", "e7", "3a", "af",
            "08", "a7", "78", "90", "33", "5b",
            "d4", "bc", "13", "f2", "89", "6f",
            "47", "4c"
        ]
        
        // Simple deobfuscation - reverse and join
        return parts.reversed().joined()
    }
    #endif
} 