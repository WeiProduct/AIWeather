import Foundation
import UserNotifications
import CoreLocation

// MARK: - Notification Types
enum NotificationType: String, CaseIterable {
    case weatherAlert = "weatherAlert"
    case dailyReminder = "dailyReminder"
    
    var categoryIdentifier: String {
        return rawValue + "Category"
    }
}

// MARK: - Weather Alert Types
enum WeatherAlertType: String, CaseIterable, Codable {
    case severeWeather = "severeWeather"
    case temperatureChange = "temperatureChange"
    case precipitation = "precipitation"
    case uvIndex = "uvIndex"
    case airQuality = "airQuality"
    
    var displayName: String {
        switch self {
        case .severeWeather:
            return LocalizedText.get("alert_severe_weather")
        case .temperatureChange:
            return LocalizedText.get("alert_temperature_change")
        case .precipitation:
            return LocalizedText.get("alert_precipitation")
        case .uvIndex:
            return LocalizedText.get("alert_uv_index")
        case .airQuality:
            return LocalizedText.get("alert_air_quality")
        }
    }
    
    var icon: String {
        switch self {
        case .severeWeather: return "tornado"
        case .temperatureChange: return "thermometer"
        case .precipitation: return "cloud.rain"
        case .uvIndex: return "sun.max"
        case .airQuality: return "aqi.medium"
        }
    }
}

// MARK: - Alert Threshold
struct AlertThreshold: Codable {
    let type: WeatherAlertType
    var enabled: Bool
    var minValue: Double?
    var maxValue: Double?
    
    static var defaults: [AlertThreshold] {
        return [
            AlertThreshold(type: .severeWeather, enabled: true),
            AlertThreshold(type: .temperatureChange, enabled: true, minValue: 0, maxValue: 35),
            AlertThreshold(type: .precipitation, enabled: true, minValue: 60),
            AlertThreshold(type: .uvIndex, enabled: true, minValue: 7),
            AlertThreshold(type: .airQuality, enabled: false, minValue: 100)
        ]
    }
}

// MARK: - Daily Reminder Settings
struct DailyReminderSettings: Codable {
    var enabled: Bool
    var morningTime: Date?
    var eveningTime: Date?
    var includeWeeklyOutlook: Bool
    var includeClothingSuggestion: Bool
    var selectedDataTypes: Set<WeatherDataType>
    
    init(
        enabled: Bool = false,
        morningTime: Date? = nil,
        eveningTime: Date? = nil,
        includeWeeklyOutlook: Bool = false,
        includeClothingSuggestion: Bool = true,
        selectedDataTypes: Set<WeatherDataType>? = nil
    ) {
        self.enabled = enabled
        let defaultMorning = DateComponents(calendar: .current, hour: 7, minute: 0).date ?? Date()
        let defaultEvening = DateComponents(calendar: .current, hour: 18, minute: 0).date ?? Date()
        self.morningTime = morningTime ?? defaultMorning
        self.eveningTime = eveningTime ?? defaultEvening
        self.includeWeeklyOutlook = includeWeeklyOutlook
        self.includeClothingSuggestion = includeClothingSuggestion
        self.selectedDataTypes = selectedDataTypes ?? [.temperature, .precipitation, .uvIndex]
    }
    
    enum WeatherDataType: String, CaseIterable, Codable {
        case temperature, precipitation, wind, humidity, uvIndex, airQuality
        
        var displayName: String {
            switch self {
            case .temperature: return LocalizedText.get("temperature")
            case .precipitation: return LocalizedText.get("precipitation")
            case .wind: return LocalizedText.get("wind_speed")
            case .humidity: return LocalizedText.get("humidity")
            case .uvIndex: return LocalizedText.get("uv_index")
            case .airQuality: return LocalizedText.get("air_quality")
            }
        }
    }
}

// MARK: - Notification Manager
@MainActor
class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    @Published var hasNotificationPermission = false
    @Published var weatherAlertSettings: [AlertThreshold] = AlertThreshold.defaults
    @Published var dailyReminderSettings = DailyReminderSettings()
    @Published var quietHoursEnabled = false
    @Published var quietHoursStart = DateComponents(calendar: .current, hour: 22, minute: 0).date ?? Date()
    @Published var quietHoursEnd = DateComponents(calendar: .current, hour: 7, minute: 0).date ?? Date()
    
    private let center = UNUserNotificationCenter.current()
    private let weatherService = WeatherService.shared
    
    init() {
        checkNotificationPermission()
        setupNotificationCategories()
        loadSettings()
    }
    
    // MARK: - Permission Handling
    func requestNotificationPermission() async -> Bool {
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .badge, .sound])
            await MainActor.run {
                self.hasNotificationPermission = granted
            }
            return granted
        } catch {
            print("Failed to request notification permission: \(error)")
            return false
        }
    }
    
    private func checkNotificationPermission() {
        Task {
            let settings = await center.notificationSettings()
            await MainActor.run {
                self.hasNotificationPermission = settings.authorizationStatus == .authorized
            }
        }
    }
    
    // MARK: - Setup
    private func setupNotificationCategories() {
        let categories: [UNNotificationCategory] = [
            UNNotificationCategory(
                identifier: NotificationType.weatherAlert.categoryIdentifier,
                actions: [
                    UNNotificationAction(
                        identifier: "viewDetails",
                        title: LocalizedText.get("view_details"),
                        options: .foreground
                    ),
                    UNNotificationAction(
                        identifier: "dismiss",
                        title: LocalizedText.get("dismiss"),
                        options: .destructive
                    )
                ],
                intentIdentifiers: []
            ),
            UNNotificationCategory(
                identifier: NotificationType.dailyReminder.categoryIdentifier,
                actions: [
                    UNNotificationAction(
                        identifier: "viewForecast",
                        title: LocalizedText.get("view_forecast"),
                        options: .foreground
                    )
                ],
                intentIdentifiers: []
            )
        ]
        
        center.setNotificationCategories(Set(categories))
    }
    
    // MARK: - Weather Alerts
    func checkWeatherAlerts(for weather: WeatherData, city: City) async {
        guard hasNotificationPermission else { return }
        
        for threshold in weatherAlertSettings where threshold.enabled {
            switch threshold.type {
            case .temperatureChange:
                await checkTemperatureAlert(weather: weather, threshold: threshold, city: city)
            case .precipitation:
                await checkPrecipitationAlert(weather: weather, threshold: threshold, city: city)
            case .uvIndex:
                await checkUVIndexAlert(weather: weather, threshold: threshold, city: city)
            case .severeWeather:
                await checkSevereWeatherAlert(weather: weather, city: city)
            case .airQuality:
                // Air quality would need additional API data
                break
            }
        }
    }
    
    private func checkTemperatureAlert(weather: WeatherData, threshold: AlertThreshold, city: City) async {
        let temp = weather.temperature
        
        if let minTemp = threshold.minValue, temp < minTemp {
            await scheduleAlert(
                title: LocalizedText.get("cold_weather_alert"),
                body: String(format: LocalizedText.get("temperature_below_threshold"), city.displayName, Int(temp)),
                identifier: "temp_cold_\(city.id)",
                type: .weatherAlert
            )
        }
        
        if let maxTemp = threshold.maxValue, temp > maxTemp {
            await scheduleAlert(
                title: LocalizedText.get("hot_weather_alert"),
                body: String(format: LocalizedText.get("temperature_above_threshold"), city.displayName, Int(temp)),
                identifier: "temp_hot_\(city.id)",
                type: .weatherAlert
            )
        }
    }
    
    private func checkPrecipitationAlert(weather: WeatherData, threshold: AlertThreshold, city: City) async {
        guard let minProb = threshold.minValue,
              weather.precipitation >= minProb else { return }
        
        await scheduleAlert(
            title: LocalizedText.get("rain_alert"),
            body: String(format: LocalizedText.get("precipitation_alert_body"), city.displayName, Int(weather.precipitation)),
            identifier: "precip_\(city.id)",
            type: .weatherAlert
        )
    }
    
    private func checkUVIndexAlert(weather: WeatherData, threshold: AlertThreshold, city: City) async {
        guard let minUV = threshold.minValue,
              Double(weather.uvIndex) >= minUV else { return }
        
        await scheduleAlert(
            title: LocalizedText.get("uv_alert"),
            body: String(format: LocalizedText.get("uv_alert_body"), city.displayName, weather.uvIndex),
            identifier: "uv_\(city.id)",
            type: .weatherAlert
        )
    }
    
    private func checkSevereWeatherAlert(weather: WeatherData, city: City) async {
        // Check for severe weather conditions
        let severeConditions: [WeatherCondition] = [.stormy, .snowy]
        
        if severeConditions.contains(weather.weatherCondition) {
            await scheduleAlert(
                title: LocalizedText.get("severe_weather_alert"),
                body: String(format: LocalizedText.get("severe_weather_body"), city.displayName, weather.weatherDescription),
                identifier: "severe_\(city.id)",
                type: .weatherAlert
            )
        }
    }
    
    // MARK: - Daily Reminders
    func scheduleDailyReminders(for cities: [City]) async {
        guard hasNotificationPermission && dailyReminderSettings.enabled else { return }
        
        // Cancel existing daily reminders
        await cancelNotifications(type: .dailyReminder)
        
        // Schedule morning reminder
        if let morningTime = dailyReminderSettings.morningTime {
            for city in cities {
                await scheduleDailyReminder(
                    for: city,
                    at: morningTime,
                    identifier: "daily_morning_\(city.id)"
                )
            }
        }
        
        // Schedule evening reminder
        if let eveningTime = dailyReminderSettings.eveningTime {
            for city in cities {
                await scheduleDailyReminder(
                    for: city,
                    at: eveningTime,
                    identifier: "daily_evening_\(city.id)"
                )
            }
        }
    }
    
    private func scheduleDailyReminder(for city: City, at time: Date, identifier: String) async {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: time)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        // Fetch current weather for notification content
        if let weather = await weatherService.fetchWeatherData(for: city.name) {
            let content = createDailyReminderContent(for: weather, city: city)
            
            let request = UNNotificationRequest(
                identifier: identifier,
                content: content,
                trigger: trigger
            )
            
            do {
                try await center.add(request)
            } catch {
                print("Failed to schedule daily reminder: \(error)")
            }
        }
    }
    
    private func createDailyReminderContent(for weather: WeatherData, city: City) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = String(format: LocalizedText.get("daily_weather_title"), city.displayName)
        
        var bodyParts: [String] = []
        
        // Temperature
        if dailyReminderSettings.selectedDataTypes.contains(.temperature) {
            bodyParts.append(String(format: LocalizedText.get("daily_temp_format"), 
                                   Int(weather.temperature), 
                                   Int(weather.temperatureMin), 
                                   Int(weather.temperatureMax)))
        }
        
        // Precipitation
        if dailyReminderSettings.selectedDataTypes.contains(.precipitation) {
            bodyParts.append(String(format: LocalizedText.get("daily_precip_format"), 
                                   Int(weather.precipitation)))
        }
        
        // UV Index
        if dailyReminderSettings.selectedDataTypes.contains(.uvIndex) {
            bodyParts.append(String(format: LocalizedText.get("daily_uv_format"), 
                                   weather.uvIndex))
        }
        
        // Clothing suggestion
        if dailyReminderSettings.includeClothingSuggestion {
            bodyParts.append(getClothingSuggestion(for: weather))
        }
        
        content.body = bodyParts.joined(separator: "\n")
        content.categoryIdentifier = NotificationType.dailyReminder.categoryIdentifier
        content.sound = .default
        
        return content
    }
    
    private func getClothingSuggestion(for weather: WeatherData) -> String {
        let temp = weather.temperature
        let precipitation = weather.precipitation
        
        if precipitation > 50 {
            return LocalizedText.get("bring_umbrella")
        } else if temp < 10 {
            return LocalizedText.get("wear_warm_clothes")
        } else if temp > 30 {
            return LocalizedText.get("wear_light_clothes")
        } else if weather.uvIndex > 7 {
            return LocalizedText.get("wear_sunscreen")
        } else {
            return LocalizedText.get("comfortable_weather")
        }
    }
    
    // MARK: - Helper Methods
    private func scheduleAlert(title: String, body: String, identifier: String, type: NotificationType) async {
        guard !isInQuietHours() else { return }
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.categoryIdentifier = type.categoryIdentifier
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: nil // Immediate delivery
        )
        
        do {
            try await center.add(request)
        } catch {
            print("Failed to schedule alert: \(error)")
        }
    }
    
    private func isInQuietHours() -> Bool {
        guard quietHoursEnabled else { return false }
        
        let now = Date()
        let calendar = Calendar.current
        let currentHour = calendar.component(.hour, from: now)
        let currentMinute = calendar.component(.minute, from: now)
        let currentTime = currentHour * 60 + currentMinute
        
        let startHour = calendar.component(.hour, from: quietHoursStart)
        let startMinute = calendar.component(.minute, from: quietHoursStart)
        let startTime = startHour * 60 + startMinute
        
        let endHour = calendar.component(.hour, from: quietHoursEnd)
        let endMinute = calendar.component(.minute, from: quietHoursEnd)
        let endTime = endHour * 60 + endMinute
        
        if startTime <= endTime {
            return currentTime >= startTime && currentTime < endTime
        } else {
            return currentTime >= startTime || currentTime < endTime
        }
    }
    
    func cancelNotifications(type: NotificationType? = nil) async {
        if let type = type {
            let requests = await center.pendingNotificationRequests()
            let identifiers = requests
                .filter { $0.content.categoryIdentifier == type.categoryIdentifier }
                .map { $0.identifier }
            center.removePendingNotificationRequests(withIdentifiers: identifiers)
        } else {
            center.removeAllPendingNotificationRequests()
        }
    }
    
    // MARK: - Settings Persistence
    func saveSettings() {
        // Save alert thresholds
        if let encoded = try? JSONEncoder().encode(weatherAlertSettings) {
            UserDefaults.standard.set(encoded, forKey: "weatherAlertSettings")
        }
        
        // Save daily reminder settings
        if let encoded = try? JSONEncoder().encode(dailyReminderSettings) {
            UserDefaults.standard.set(encoded, forKey: "dailyReminderSettings")
        }
        
        // Save quiet hours
        UserDefaults.standard.set(quietHoursEnabled, forKey: "quietHoursEnabled")
        UserDefaults.standard.set(quietHoursStart, forKey: "quietHoursStart")
        UserDefaults.standard.set(quietHoursEnd, forKey: "quietHoursEnd")
    }
    
    private func loadSettings() {
        // Load alert thresholds
        if let data = UserDefaults.standard.data(forKey: "weatherAlertSettings"),
           let decoded = try? JSONDecoder().decode([AlertThreshold].self, from: data) {
            weatherAlertSettings = decoded
        }
        
        // Load daily reminder settings
        if let data = UserDefaults.standard.data(forKey: "dailyReminderSettings"),
           let decoded = try? JSONDecoder().decode(DailyReminderSettings.self, from: data) {
            dailyReminderSettings = decoded
        }
        
        // Load quiet hours
        quietHoursEnabled = UserDefaults.standard.bool(forKey: "quietHoursEnabled")
        if let start = UserDefaults.standard.object(forKey: "quietHoursStart") as? Date {
            quietHoursStart = start
        }
        if let end = UserDefaults.standard.object(forKey: "quietHoursEnd") as? Date {
            quietHoursEnd = end
        }
    }
}

