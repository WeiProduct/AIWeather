import Foundation
import UIKit

// MARK: - App Configuration
struct AppConstants {
    
    // MARK: - API Configuration
    struct API {
        static let requestTimeout: TimeInterval = 30
        static let resourceTimeout: TimeInterval = 60
        static let maxRetries = 3
        static let retryDelay: TimeInterval = 1.0
        static let geocodingLimit = 10
        static let forecastDays = 7
    }
    
    // MARK: - Cache Configuration
    struct Cache {
        static let weatherDataExpiration: TimeInterval = 900 // 15 minutes
        static let citySearchExpiration: TimeInterval = 3600 // 1 hour
        static let memoryCountLimit = 50
        static let memoryCostLimit = 50 * 1024 * 1024 // 50MB
    }
    
    // MARK: - UI Configuration
    struct UI {
        // Animation durations
        static let defaultAnimationDuration: TimeInterval = 0.3
        static let springAnimationDuration: TimeInterval = 0.5
        static let toastDisplayDuration: TimeInterval = 4.0
        
        // Sizes
        static let cornerRadius: CGFloat = 16
        static let smallCornerRadius: CGFloat = 12
        static let cardOpacity: Double = 0.15
        static let refreshThreshold: CGFloat = 80
        
        // Padding
        static let defaultPadding: CGFloat = 20
        static let smallPadding: CGFloat = 10
        static let largePadding: CGFloat = 30
        
        // Weather specific
        static let hourlyForecastCount = 24
        static let weeklyForecastDays = 7
    }
    
    // MARK: - Weather Configuration
    struct Weather {
        // Temperature ranges
        static let temperatureGlobalMin: Double = -20
        static let temperatureGlobalMax: Double = 50
        static let mockTemperatureMin: Double = 10
        static let mockTemperatureMax: Double = 35
        
        // UV Index levels
        static let uvIndexLow = 0...2
        static let uvIndexModerate = 3...5
        static let uvIndexHigh = 6...7
        static let uvIndexVeryHigh = 8...10
        
        // Precipitation levels
        static let precipitationNone = 0...10.0
        static let precipitationLight = 11...30.0
        static let precipitationModerate = 31...60.0
        static let precipitationHeavy = 61...100.0
        
        // Wind speed conversion
        static let mpsToKmhFactor = 3.6
        static let kmhToMphFactor = 0.621371
        
        // Default values
        static let defaultUVIndex = 5
        static let defaultVisibilityDivider = 1000 // Convert meters to km
    }
    
    // MARK: - Search Configuration
    struct Search {
        static let debounceDelay: TimeInterval = 0.3
        static let minimumSearchLength = 2
        static let maxSearchResults = 10
    }
    
    // MARK: - Storage Keys
    struct StorageKeys {
        static let temperatureUnit = "temperatureUnit"
        static let windSpeedUnit = "windSpeedUnit"
        static let weatherNotificationsEnabled = "weatherNotificationsEnabled"
        static let dailyNotificationsEnabled = "dailyNotificationsEnabled"
        static let autoLocationEnabled = "autoLocationEnabled"
        static let appLanguage = "AppLanguage"
        static let savedCities = "savedCities"
        static let hasSeenWelcome = "hasSeenWelcome"
    }
    
    // MARK: - Date Formatting
    struct DateFormat {
        static let dayMonth = "M/d"
        static let weekday = "EEEE"
        static let time24Hour = "HH:mm"
        static let time12Hour = "h:mm a"
    }
}

// MARK: - UV Index Description
extension AppConstants.Weather {
    static func uvIndexDescription(_ index: Int) -> String {
        switch index {
        case uvIndexLow:
            return LocalizedText.get("uv_low")
        case uvIndexModerate:
            return LocalizedText.get("uv_moderate")
        case uvIndexHigh:
            return LocalizedText.get("uv_high")
        case uvIndexVeryHigh:
            return LocalizedText.get("uv_very_high")
        default:
            return LocalizedText.get("uv_extreme")
        }
    }
    
    static func precipitationDescription(_ percentage: Double) -> String {
        switch percentage {
        case precipitationNone:
            return LocalizedText.get("precipitation_none")
        case precipitationLight:
            return LocalizedText.get("precipitation_light")
        case precipitationModerate:
            return LocalizedText.get("precipitation_moderate")
        case precipitationHeavy:
            return LocalizedText.get("precipitation_heavy")
        default:
            return LocalizedText.get("precipitation_heavy")
        }
    }
}