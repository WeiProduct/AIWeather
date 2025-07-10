import Foundation
import SwiftData

@Model
final class WeatherData: @unchecked Sendable {
    var id: UUID
    var cityName: String
    var temperature: Double
    var temperatureMin: Double
    var temperatureMax: Double
    private var weatherConditionRawValue: String
    
    var weatherCondition: WeatherCondition {
        get { WeatherCondition(rawValue: weatherConditionRawValue) ?? .sunny }
        set { weatherConditionRawValue = newValue.rawValue }
    }
    var weatherDescription: String
    var humidity: Double
    var windSpeed: Double
    var windDirection: String
    var pressure: Double
    var visibility: Double
    var uvIndex: Int
    var precipitation: Double
    var feelsLike: Double
    var timestamp: Date
    
    // 7天预报数据
    var weeklyForecast: [DailyWeather]
    
    // 小时级预报数据（用于趋势图表）
    var hourlyForecast: [ForecastItem]
    
    // 日出日落时间（Unix时间戳）
    var sunriseTime: Int?
    var sunsetTime: Int?
    
    // 计算的日出日落时间
    var sunTimes: SunTimes? {
        guard let sunrise = sunriseTime, let sunset = sunsetTime else { return nil }
        
        let sunriseDate = Date(timeIntervalSince1970: TimeInterval(sunrise))
        let sunsetDate = Date(timeIntervalSince1970: TimeInterval(sunset))
        let dayLength = sunsetDate.timeIntervalSince(sunriseDate)
        let solarNoon = sunriseDate.addingTimeInterval(dayLength / 2)
        
        return SunTimes(
            sunrise: sunriseDate,
            sunset: sunsetDate,
            solarNoon: solarNoon,
            dayLength: dayLength
        )
    }
    
    init(
        cityName: String,
        temperature: Double,
        temperatureMin: Double,
        temperatureMax: Double,
        weatherCondition: WeatherCondition,
        weatherDescription: String,
        humidity: Double,
        windSpeed: Double,
        windDirection: String,
        pressure: Double,
        visibility: Double,
        uvIndex: Int,
        precipitation: Double,
        feelsLike: Double,
        weeklyForecast: [DailyWeather] = [],
        hourlyForecast: [ForecastItem] = [],
        sunriseTime: Int? = nil,
        sunsetTime: Int? = nil
    ) {
        self.id = UUID()
        self.cityName = cityName
        self.temperature = temperature
        self.temperatureMin = temperatureMin
        self.temperatureMax = temperatureMax
        self.weatherConditionRawValue = weatherCondition.rawValue
        self.weatherDescription = weatherDescription
        self.humidity = humidity
        self.windSpeed = windSpeed
        self.windDirection = windDirection
        self.pressure = pressure
        self.visibility = visibility
        self.uvIndex = uvIndex
        self.precipitation = precipitation
        self.feelsLike = feelsLike
        self.weeklyForecast = weeklyForecast
        self.hourlyForecast = hourlyForecast
        self.timestamp = Date()
        self.sunriseTime = sunriseTime
        self.sunsetTime = sunsetTime
    }
}

struct DailyWeather: Codable {
    var date: Date
    var dayName: String  // Store original day name
    private var weatherConditionRawValue: String
    
    var weatherCondition: WeatherCondition {
        get { WeatherCondition(rawValue: weatherConditionRawValue) ?? .sunny }
        set { weatherConditionRawValue = newValue.rawValue }
    }
    var temperatureMax: Double
    var temperatureMin: Double
    var precipitation: Double
    
    // Computed property for localized day name
    var localizedDayName: String {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let forecastDay = calendar.startOfDay(for: date)
        let daysDiff = calendar.dateComponents([.day], from: today, to: forecastDay).day ?? 0
        
        if daysDiff == 0 {
            return LocalizedText.get("today")
        } else if daysDiff == 1 {
            return LocalizedText.get("tomorrow")
        } else {
            // Format weekday based on current language
            let formatter = DateFormatter()
            let languageCode = UserDefaults.standard.string(forKey: "appLanguage") ?? "zh_CN"
            let isChineseLanguage = languageCode == "zh_CN"
            formatter.locale = Locale(identifier: isChineseLanguage ? "zh_CN" : "en_US")
            formatter.dateFormat = "EEEE"
            return formatter.string(from: date)
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case date, dayName, temperatureMax, temperatureMin, precipitation
        case weatherConditionRawValue
    }
    
    init(date: Date, dayName: String, weatherCondition: WeatherCondition, temperatureMax: Double, temperatureMin: Double, precipitation: Double) {
        self.date = date
        self.dayName = dayName
        self.weatherConditionRawValue = weatherCondition.rawValue
        self.temperatureMax = temperatureMax
        self.temperatureMin = temperatureMin
        self.precipitation = precipitation
    }
}

@Model
final class City: @unchecked Sendable {
    var id: UUID
    var name: String  // Store original name (for search results)
    var cityKey: String?  // Key for localization (for default cities)
    var isSelected: Bool
    var latitude: Double
    var longitude: Double
    
    // Computed property for display name
    var displayName: String {
        if let key = cityKey {
            return LocalizedText.get(key)
        }
        return name
    }
    
    init(name: String, latitude: Double, longitude: Double, isSelected: Bool = false, cityKey: String? = nil) {
        self.id = UUID()
        self.name = name
        self.cityKey = cityKey
        self.latitude = latitude
        self.longitude = longitude
        self.isSelected = isSelected
    }
} 