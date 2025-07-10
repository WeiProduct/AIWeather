import Foundation
import WidgetKit

/// 管理小组件数据的类
final class WidgetDataManager {
    static let shared = WidgetDataManager()
    
    // App Group 标识符 - 需要在项目设置中配置
    private let appGroupIdentifier = "group.com.weiweathers.weather"
    private let widgetDataKey = "widget_weather_data"
    
    private init() {}
    
    /// 更新小组件的天气数据
    func updateWidgetData(from weatherData: WeatherData) {
        guard let sharedDefaults = UserDefaults(suiteName: appGroupIdentifier) else {
            print("❌ 无法访问 App Group UserDefaults")
            return
        }
        
        // 转换为小组件数据模型
        let widgetData = WidgetWeatherData(
            cityName: weatherData.cityName,
            temperature: weatherData.temperature,
            temperatureMin: weatherData.temperatureMin,
            temperatureMax: weatherData.temperatureMax,
            weatherCondition: weatherData.weatherCondition.rawValue,
            weatherDescription: weatherData.weatherDescription,
            humidity: weatherData.humidity,
            feelsLike: weatherData.feelsLike,
            lastUpdated: Date()
        )
        
        // 编码并保存数据
        if let encoded = try? JSONEncoder().encode(widgetData) {
            sharedDefaults.set(encoded, forKey: widgetDataKey)
            
            // 通知小组件刷新
            WidgetCenter.shared.reloadAllTimelines()
            print("✅ 小组件数据已更新")
        } else {
            print("❌ 无法编码小组件数据")
        }
    }
    
    /// 清除小组件数据
    func clearWidgetData() {
        guard let sharedDefaults = UserDefaults(suiteName: appGroupIdentifier) else {
            return
        }
        
        sharedDefaults.removeObject(forKey: widgetDataKey)
        WidgetCenter.shared.reloadAllTimelines()
    }
}

// MARK: - Widget Weather Data Model (与小组件共享)
struct WidgetWeatherData: Codable {
    let cityName: String
    let temperature: Double
    let temperatureMin: Double
    let temperatureMax: Double
    let weatherCondition: String
    let weatherDescription: String
    let humidity: Double
    let feelsLike: Double
    let lastUpdated: Date
}