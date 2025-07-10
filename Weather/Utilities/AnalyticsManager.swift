import Foundation
import os.log

// Simple analytics manager for tracking user behavior
// For production, integrate Firebase Analytics, Mixpanel, or Amplitude
class AnalyticsManager {
    static let shared = AnalyticsManager()
    private let logger = Logger(subsystem: "com.weather.app", category: "Analytics")
    
    private init() {}
    
    // MARK: - Event Types
    enum EventCategory: String {
        case navigation = "navigation"
        case weather = "weather"
        case settings = "settings"
        case notification = "notification"
        case error = "error"
        case performance = "performance"
    }
    
    // MARK: - Standard Events
    enum StandardEvent: String {
        // Navigation
        case screenView = "screen_view"
        case appLaunch = "app_launch"
        case appBackground = "app_background"
        case appForeground = "app_foreground"
        
        // Weather
        case weatherDataLoaded = "weather_data_loaded"
        case weatherDataRefreshed = "weather_data_refreshed"
        case cityAdded = "city_added"
        case cityRemoved = "city_removed"
        case citySelected = "city_selected"
        case locationPermissionGranted = "location_permission_granted"
        case locationPermissionDenied = "location_permission_denied"
        
        // Settings
        case temperatureUnitChanged = "temperature_unit_changed"
        case windSpeedUnitChanged = "wind_speed_unit_changed"
        case languageChanged = "language_changed"
        case notificationSettingsChanged = "notification_settings_changed"
        
        // Features
        case weeklyForecastViewed = "weekly_forecast_viewed"
        case weatherDetailsViewed = "weather_details_viewed"
        case notificationReceived = "notification_received"
        case notificationTapped = "notification_tapped"
    }
    
    // MARK: - Track Event
    func track(event: StandardEvent, parameters: [String: Any]? = nil) {
        track(eventName: event.rawValue, category: getCategoryForEvent(event), parameters: parameters)
    }
    
    func track(eventName: String, category: EventCategory, parameters: [String: Any]? = nil) {
        var eventData: [String: Any] = [
            "event_name": eventName,
            "category": category.rawValue,
            "timestamp": Date().timeIntervalSince1970,
            "session_id": sessionId,
            "app_version": getAppVersion()
        ]
        
        // Add custom parameters
        if let parameters = parameters {
            eventData["parameters"] = parameters
        }
        
        // Add user properties
        eventData["user_properties"] = getUserProperties()
        
        // Log the event
        logger.info("Analytics Event: \(eventName) - \(String(describing: parameters))")
        
        // In production, send to analytics service
        #if DEBUG
        print("📊 Analytics: \(eventName) - \(parameters ?? [:])")
        #endif
        
        // Also add as breadcrumb for crash reporting
        CrashReporter.shared.addBreadcrumb(eventName, category: category.rawValue)
    }
    
    // MARK: - Screen Tracking
    func trackScreen(_ screenName: String) {
        track(event: .screenView, parameters: ["screen_name": screenName])
    }
    
    // MARK: - User Properties
    private var userProperties: [String: Any] = [:]
    
    func setUserProperty(_ value: Any?, forKey key: String) {
        if let value = value {
            userProperties[key] = value
        } else {
            userProperties.removeValue(forKey: key)
        }
    }
    
    private func getUserProperties() -> [String: Any] {
        var properties = userProperties
        
        // Add default properties
        properties["os_version"] = getOSVersion()
        properties["device_model"] = getDeviceModel()
        
        // Properties that require MainActor will be added when available
        // They cannot be accessed synchronously from non-MainActor context
        
        return properties
    }
    
    // Call this from MainActor context to get complete properties
    @MainActor
    func getUserPropertiesComplete() -> [String: Any] {
        var properties = getUserProperties()
        
        // Add MainActor-isolated properties
        properties["language"] = LanguageManager.shared.currentLanguage.rawValue
        properties["has_location_permission"] = LocationManager.shared.hasLocationPermission  
        properties["notification_enabled"] = NotificationManager.shared.hasNotificationPermission
        
        return properties
    }
    
    // MARK: - Session Management
    private var sessionId = UUID().uuidString
    private var sessionStartTime = Date()
    
    func startNewSession() {
        sessionId = UUID().uuidString
        sessionStartTime = Date()
        track(event: .appLaunch)
    }
    
    func endSession() {
        let sessionDuration = Date().timeIntervalSince(sessionStartTime)
        track(eventName: "session_end", category: .navigation, parameters: [
            "duration_seconds": Int(sessionDuration)
        ])
    }
    
    // MARK: - Performance Tracking
    func trackPerformance(operation: String, duration: TimeInterval) {
        track(eventName: "performance_metric", category: .performance, parameters: [
            "operation": operation,
            "duration_ms": Int(duration * 1000)
        ])
    }
    
    // MARK: - Error Tracking
    func trackError(_ error: Error, context: String? = nil) {
        var parameters: [String: Any] = [
            "error_description": error.localizedDescription,
            "error_domain": (error as NSError).domain,
            "error_code": (error as NSError).code
        ]
        
        if let context = context {
            parameters["context"] = context
        }
        
        track(eventName: "error_occurred", category: .error, parameters: parameters)
    }
    
    // MARK: - Helper Methods
    private func getCategoryForEvent(_ event: StandardEvent) -> EventCategory {
        switch event {
        case .screenView, .appLaunch, .appBackground, .appForeground:
            return .navigation
        case .weatherDataLoaded, .weatherDataRefreshed, .cityAdded, .cityRemoved, .citySelected, .locationPermissionGranted, .locationPermissionDenied:
            return .weather
        case .temperatureUnitChanged, .windSpeedUnitChanged, .languageChanged, .notificationSettingsChanged:
            return .settings
        case .weeklyForecastViewed, .weatherDetailsViewed:
            return .weather
        case .notificationReceived, .notificationTapped:
            return .notification
        }
    }
    
    private func getAppVersion() -> String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "Unknown"
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "Unknown"
        return "\(version) (\(build))"
    }
    
    private func getOSVersion() -> String {
        let osVersion = ProcessInfo.processInfo.operatingSystemVersion
        return "\(osVersion.majorVersion).\(osVersion.minorVersion).\(osVersion.patchVersion)"
    }
    
    private func getDeviceModel() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }
}

// MARK: - Analytics Helper Extensions
extension AnalyticsManager {
    // Convenience methods for common tracking scenarios
    
    func trackWeatherLoad(city: String, loadTime: TimeInterval, success: Bool) {
        track(event: .weatherDataLoaded, parameters: [
            "city": city,
            "load_time_ms": Int(loadTime * 1000),
            "success": success
        ])
        
        if loadTime > 2.0 {
            trackPerformance(operation: "weather_load_slow", duration: loadTime)
        }
    }
    
    func trackCityAction(action: String, cityName: String) {
        let event: StandardEvent
        switch action {
        case "add":
            event = .cityAdded
        case "remove":
            event = .cityRemoved
        case "select":
            event = .citySelected
        default:
            return
        }
        
        track(event: event, parameters: ["city_name": cityName])
    }
    
    func trackSettingChange(setting: String, oldValue: Any?, newValue: Any?) {
        track(eventName: "setting_changed", category: .settings, parameters: [
            "setting_name": setting,
            "old_value": String(describing: oldValue),
            "new_value": String(describing: newValue)
        ])
    }
}