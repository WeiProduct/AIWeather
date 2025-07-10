import Foundation

// MARK: - 当前天气API响应模型
struct OpenWeatherCurrentResponse: Codable {
    let coord: Coordinates
    let weather: [WeatherConditionAPI]
    let base: String
    let main: MainWeatherInfo
    let visibility: Int
    let wind: Wind
    let clouds: Clouds
    let dt: Int
    let sys: SystemInfo
    let timezone: Int
    let id: Int
    let name: String
    let cod: Int
}

struct Coordinates: Codable {
    let lon: Double
    let lat: Double
}

struct WeatherConditionAPI: Codable {
    let id: Int
    let main: String
    let description: String
    let icon: String
}

struct MainWeatherInfo: Codable {
    let temp: Double
    let feelsLike: Double
    let tempMin: Double
    let tempMax: Double
    let pressure: Int
    let humidity: Int
    let seaLevel: Int?
    let grndLevel: Int?
    
    enum CodingKeys: String, CodingKey {
        case temp
        case feelsLike = "feels_like"
        case tempMin = "temp_min"
        case tempMax = "temp_max"
        case pressure
        case humidity
        case seaLevel = "sea_level"
        case grndLevel = "grnd_level"
    }
}

struct Wind: Codable {
    let speed: Double
    let deg: Int
    let gust: Double?
}

struct Clouds: Codable {
    let all: Int
}

struct SystemInfo: Codable {
    let type: Int?
    let id: Int?
    let country: String
    let sunrise: Int
    let sunset: Int
}

// MARK: - 5天预报API响应模型
struct OpenWeatherForecastResponse: Codable {
    let cod: String
    let message: Int
    let cnt: Int
    let list: [ForecastItem]
    let city: CityInfo
}

struct ForecastItem: Codable {
    let dt: Int
    let main: MainWeatherInfo
    let weather: [WeatherConditionAPI]
    let clouds: Clouds
    let wind: Wind
    let visibility: Int
    let pop: Double // 降水概率
    let sys: ForecastSys
    let dtTxt: String
    
    enum CodingKeys: String, CodingKey {
        case dt, main, weather, clouds, wind, visibility, pop, sys
        case dtTxt = "dt_txt"
    }
}

struct ForecastSys: Codable {
    let pod: String // 白天/夜晚标识
}

struct CityInfo: Codable {
    let id: Int
    let name: String
    let coord: Coordinates
    let country: String
    let population: Int
    let timezone: Int
    let sunrise: Int
    let sunset: Int
}

// MARK: - 地理编码API响应模型
struct GeocodingResponse: Codable {
    let name: String
    let localNames: [String: String]?
    let lat: Double
    let lon: Double
    let country: String
    let state: String?
    
    enum CodingKeys: String, CodingKey {
        case name, lat, lon, country, state
        case localNames = "local_names"
    }
}

// MARK: - 空气质量API响应模型
struct AirQualityResponse: Codable {
    let coord: Coordinates
    let list: [AirQualityData]
}

struct AirQualityData: Codable {
    let main: AirQualityMain
    let components: AirQualityComponents
    let dt: Int
}

struct AirQualityMain: Codable {
    let aqi: Int // 空气质量指数
}

struct AirQualityComponents: Codable {
    let co: Double
    let no: Double
    let no2: Double
    let o3: Double
    let so2: Double
    let pm2_5: Double
    let pm10: Double
    let nh3: Double
} 