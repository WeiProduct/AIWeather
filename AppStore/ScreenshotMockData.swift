import Foundation

// Mock data for generating App Store screenshots
struct ScreenshotMockData {
    
    // Main weather screen data
    static let mainWeatherData = WeatherData(
        cityName: "San Francisco",
        temperature: 18,
        temperatureMin: 14,
        temperatureMax: 22,
        weatherCondition: .partlyCloudy,
        weatherDescription: "Partly Cloudy",
        humidity: 65,
        windSpeed: 12,
        windDirection: "NW",
        pressure: 1013,
        visibility: 10,
        uvIndex: 6,
        precipitation: 20
    )
    
    // Multiple cities for city management screen
    static let cities = [
        City(name: "San Francisco", latitude: 37.7749, longitude: -122.4194, isSelected: true),
        City(name: "New York", latitude: 40.7128, longitude: -74.0060, isSelected: false),
        City(name: "London", latitude: 51.5074, longitude: -0.1278, isSelected: false),
        City(name: "Tokyo", latitude: 35.6762, longitude: 139.6503, isSelected: false),
        City(name: "Sydney", latitude: -33.8688, longitude: 151.2093, isSelected: false)
    ]
    
    // Weekly forecast data
    static let weeklyForecastData: [DailyWeather] = {
        let calendar = Calendar.current
        let today = Date()
        
        return [
            DailyWeather(
                date: today,
                temperatureMin: 14,
                temperatureMax: 22,
                weatherCondition: .partlyCloudy,
                precipitation: 20
            ),
            DailyWeather(
                date: calendar.date(byAdding: .day, value: 1, to: today)!,
                temperatureMin: 12,
                temperatureMax: 20,
                weatherCondition: .clear,
                precipitation: 0
            ),
            DailyWeather(
                date: calendar.date(byAdding: .day, value: 2, to: today)!,
                temperatureMin: 15,
                temperatureMax: 23,
                weatherCondition: .cloudy,
                precipitation: 40
            ),
            DailyWeather(
                date: calendar.date(byAdding: .day, value: 3, to: today)!,
                temperatureMin: 16,
                temperatureMax: 24,
                weatherCondition: .rain,
                precipitation: 80
            ),
            DailyWeather(
                date: calendar.date(byAdding: .day, value: 4, to: today)!,
                temperatureMin: 17,
                temperatureMax: 25,
                weatherCondition: .partlyCloudy,
                precipitation: 30
            ),
            DailyWeather(
                date: calendar.date(byAdding: .day, value: 5, to: today)!,
                temperatureMin: 18,
                temperatureMax: 26,
                weatherCondition: .clear,
                precipitation: 10
            ),
            DailyWeather(
                date: calendar.date(byAdding: .day, value: 6, to: today)!,
                temperatureMin: 19,
                temperatureMax: 27,
                weatherCondition: .clear,
                precipitation: 5
            )
        ]
    }()
    
    // Beautiful weather scenarios
    static let weatherScenarios = [
        // Sunny day
        WeatherData(
            cityName: "Los Angeles",
            temperature: 25,
            temperatureMin: 20,
            temperatureMax: 28,
            weatherCondition: .clear,
            weatherDescription: "Clear Sky",
            humidity: 45,
            windSpeed: 8,
            windDirection: "W",
            pressure: 1015,
            visibility: 10,
            uvIndex: 9,
            precipitation: 0
        ),
        
        // Rainy day
        WeatherData(
            cityName: "Seattle",
            temperature: 12,
            temperatureMin: 10,
            temperatureMax: 14,
            weatherCondition: .rain,
            weatherDescription: "Light Rain",
            humidity: 85,
            windSpeed: 15,
            windDirection: "SW",
            pressure: 1008,
            visibility: 8,
            uvIndex: 2,
            precipitation: 90
        ),
        
        // Snowy day
        WeatherData(
            cityName: "Denver",
            temperature: -2,
            temperatureMin: -5,
            temperatureMax: 0,
            weatherCondition: .snow,
            weatherDescription: "Snow",
            humidity: 75,
            windSpeed: 20,
            windDirection: "N",
            pressure: 1010,
            visibility: 5,
            uvIndex: 1,
            precipitation: 95
        ),
        
        // Thunderstorm
        WeatherData(
            cityName: "Miami",
            temperature: 28,
            temperatureMin: 25,
            temperatureMax: 30,
            weatherCondition: .thunderstorm,
            weatherDescription: "Thunderstorm",
            humidity: 90,
            windSpeed: 25,
            windDirection: "E",
            pressure: 1005,
            visibility: 6,
            uvIndex: 3,
            precipitation: 100
        )
    ]
}

// Screenshot configuration
struct ScreenshotConfig {
    static let deviceSizes = [
        "iPhone 15 Pro Max": CGSize(width: 430, height: 932),  // 6.7"
        "iPhone 14 Plus": CGSize(width: 428, height: 926),     // 6.5"
        "iPhone 8 Plus": CGSize(width: 414, height: 736),      // 5.5"
        "iPad Pro 12.9": CGSize(width: 1024, height: 1366)     // 12.9"
    ]
    
    static let screenshotScenes = [
        "Main Weather",
        "Weekly Forecast",
        "Weather Details",
        "City Management",
        "Settings",
        "Notification Settings"
    ]
    
    static func generateScreenshotInstructions() -> String {
        return """
        App Store Screenshot Instructions:
        
        1. Open Xcode and select each device from the simulator menu
        2. For each device, capture these screens:
           - Main Weather (showing current conditions)
           - Weekly Forecast (7-day view)
           - Weather Details (detailed metrics)
           - City Management (showing multiple cities)
           - Settings (showing customization options)
        
        3. Use these keyboard shortcuts:
           - ⌘+S to take a screenshot
           - Screenshots save to Desktop by default
        
        4. Name screenshots with this format:
           - Device_Screen_Number.png
           - Example: iPhone15ProMax_MainWeather_1.png
        
        5. Required sizes:
           - iPhone 6.7" (1290 × 2796) - 5 screenshots
           - iPhone 6.5" (1242 × 2688) - 5 screenshots  
           - iPhone 5.5" (1242 × 2208) - 5 screenshots
           - iPad Pro 12.9" (2048 × 2732) - Optional
        
        6. Tips for great screenshots:
           - Use beautiful weather conditions
           - Show variety (sunny, cloudy, rainy)
           - Ensure all text is readable
           - Hide status bar if needed
           - Use attractive city names
        """
    }
}