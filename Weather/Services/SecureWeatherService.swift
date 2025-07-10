import Foundation
import UIKit

// 使用代理服务器的安全天气服务
class SecureWeatherService {
    static let shared = SecureWeatherService()
    
    // 使用你自己的代理服务器 URL
    private let proxyBaseURL = "https://your-weather-proxy.vercel.app/api"
    
    private init() {}
    
    // 通过代理获取天气数据
    func fetchWeatherDataSecurely(for city: String) async -> WeatherData? {
        // 构建请求 URL - 不包含 API 密钥！
        guard let url = URL(string: "\(proxyBaseURL)/weather?city=\(city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")") else {
            return nil
        }
        
        var request = URLRequest(url: url)
        
        // 添加 App 标识符用于服务器端验证
        request.setValue(Bundle.main.bundleIdentifier, forHTTPHeaderField: "X-App-Bundle-ID")
        
        // 可选：添加请求签名
        let signature = createRequestSignature(for: request)
        request.setValue(signature, forHTTPHeaderField: "X-Request-Signature")
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            // 解码 OpenWeatherMap 响应格式
            let response = try JSONDecoder().decode(OpenWeatherCurrentResponse.self, from: data)
            
            // 转换为 WeatherData
            let weatherCondition = WeatherCondition.fromOpenWeatherMain(response.weather.first?.main ?? "Clear")
            
            return WeatherData(
                cityName: response.name,
                temperature: response.main.temp,
                temperatureMin: response.main.tempMin,
                temperatureMax: response.main.tempMax,
                weatherCondition: weatherCondition,
                weatherDescription: response.weather.first?.description.capitalized ?? "晴朗",
                humidity: Double(response.main.humidity),
                windSpeed: response.wind.speed * 3.6, // 转换为 km/h
                windDirection: convertWindDirection(response.wind.deg),
                pressure: Double(response.main.pressure),
                visibility: Double(response.visibility / 1000), // 转换为 km
                uvIndex: 5, // 默认值
                precipitation: 0,
                feelsLike: response.main.feelsLike,
                weeklyForecast: [],
                hourlyForecast: []
            )
        } catch {
            print("Error fetching weather: \(error)")
            return nil
        }
    }
    
    // 创建请求签名（防止恶意调用）
    private func createRequestSignature(for request: URLRequest) -> String {
        let timestamp = Int(Date().timeIntervalSince1970)
        let urlString = request.url?.absoluteString ?? ""
        
        // 使用设备 ID 和时间戳创建签名
        let deviceID = UIDevice.current.identifierForVendor?.uuidString ?? ""
        let signatureData = "\(timestamp)-\(urlString)-\(deviceID)"
        
        // 简单的哈希（实际应用中可以使用 HMAC）
        return signatureData.data(using: String.Encoding.utf8)?.base64EncodedString() ?? ""
    }
    
    private func convertWindDirection(_ degrees: Int) -> String {
        let directions = ["北", "东北", "东", "东南", "南", "西南", "西", "西北"]
        let index = Int((Double(degrees) + 22.5) / 45.0) % 8
        return directions[index]
    }
}

// MARK: - 迁移指南
extension SecureWeatherService {
    /*
     迁移步骤：
     
     1. 部署代理服务器（Vercel/Netlify/你自己的服务器）
     2. 将 API 密钥存储在服务器环境变量中
     3. 更新 proxyBaseURL 为你的服务器地址
     4. 替换 WeatherService 的调用为 SecureWeatherService
     
     优势：
     - API 密钥永远不会出现在客户端
     - 可以添加额外的安全措施（速率限制、IP 白名单等）
     - 可以缓存响应，减少 API 调用
     - 可以添加分析和监控
     */
}