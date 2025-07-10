import SwiftUI

enum WeatherCondition: String, CaseIterable, Codable {
    case sunny = "sunny"
    case cloudy = "cloudy"
    case partlyCloudy = "partlyCloudy"
    case rainy = "rainy"
    case snowy = "snowy"
    case stormy = "stormy"
    case foggy = "foggy"
    
    var icon: String {
        switch self {
        case .sunny:
            return "sun.max.fill"
        case .cloudy:
            return "cloud.fill"
        case .partlyCloudy:
            return "cloud.sun.fill"
        case .rainy:
            return "cloud.rain.fill"
        case .snowy:
            return "cloud.snow.fill"
        case .stormy:
            return "cloud.bolt.rain.fill"
        case .foggy:
            return "cloud.fog.fill"
        }
    }
    
    var backgroundColors: [String] {
        switch self {
        case .sunny:
            return ["#FF9A56", "#FFAD56"]
        case .cloudy:
            return ["#54717A", "#64B5F6"]
        case .partlyCloudy:
            return ["#5B9BD5", "#70C1B3"]
        case .rainy:
            return ["#73737D", "#4A5568"]
        case .snowy:
            return ["#E0E5EC", "#B8C1CC"]
        case .stormy:
            return ["#4A5568", "#2D3748"]
        case .foggy:
            return ["#A0AEC0", "#718096"]
        }
    }
    
    var localizedDescription: String {
        switch self {
        case .sunny:
            return LocalizedText.get("clear_sky")
        case .cloudy:
            return LocalizedText.get("cloudy")
        case .partlyCloudy:
            return LocalizedText.get("scattered_clouds")
        case .rainy:
            return LocalizedText.get("rain")
        case .snowy:
            return LocalizedText.get("snow")
        case .stormy:
            return LocalizedText.get("thunderstorm")
        case .foggy:
            return LocalizedText.get("mist")
        }
    }
    
    static func fromOpenWeatherMain(_ main: String) -> WeatherCondition {
        switch main.lowercased() {
        case "clear":
            return .sunny
        case "clouds":
            return .cloudy
        case "rain", "drizzle":
            return .rainy
        case "snow":
            return .snowy
        case "thunderstorm":
            return .stormy
        case "mist", "fog", "haze":
            return .foggy
        default:
            return .partlyCloudy
        }
    }
}