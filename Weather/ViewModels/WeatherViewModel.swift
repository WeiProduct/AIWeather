import Foundation
import SwiftData
import CoreLocation
import Combine

@MainActor
class WeatherViewModel: ObservableObject {
    @Published var currentWeather: WeatherData?
    @Published var cities: [City] = []
    @Published var isLoading = false
    @Published var showingWelcome = true
    @Published var selectedCity: City?
    
    // 设置相关
    @Published var temperatureUnit: TemperatureUnit = .celsius
    @Published var windSpeedUnit: WindSpeedUnit = .kmh
    @Published var weatherNotificationsEnabled = true
    @Published var dailyNotificationsEnabled = true
    @Published var autoLocationEnabled = false {
        didSet {
            handleAutoLocationToggle()
        }
    }
    
    // 功能板块显示设置
    @Published var showSunTimes: Bool = UserDefaults.standard.object(forKey: "show_sun_times") as? Bool ?? true {
        didSet {
            UserDefaults.standard.set(showSunTimes, forKey: "show_sun_times")
        }
    }
    @Published var showPhotographyTimes: Bool = UserDefaults.standard.object(forKey: "show_photography_times") as? Bool ?? false {
        didSet {
            UserDefaults.standard.set(showPhotographyTimes, forKey: "show_photography_times")
        }
    }
    @Published var showClothingAdvice: Bool = UserDefaults.standard.object(forKey: "show_clothing_advice") as? Bool ?? true {
        didSet {
            UserDefaults.standard.set(showClothingAdvice, forKey: "show_clothing_advice")
        }
    }
    @Published var showWeatherTrends: Bool = UserDefaults.standard.object(forKey: "show_weather_trends") as? Bool ?? true {
        didSet {
            UserDefaults.standard.set(showWeatherTrends, forKey: "show_weather_trends")
        }
    }
    
    // 位置相关
    @Published var locationError: String?
    @Published var currentLocationCity: City?
    @Published var showLocationDeniedAlert = false
    
    private let weatherService: WeatherServiceProtocol
    let locationManager = LocationManager.shared
    private let notificationManager = NotificationManager.shared
    
    init() {
        // 根据配置选择适当的服务
        if ApiConfig.useProxy {
            self.weatherService = ProxyWeatherService.shared
        } else {
            self.weatherService = WeatherService.shared
        }
        
        setupDefaultCities()
        observeLocationUpdates()
        setupNotificationObservers()
    }
    
    private func setupDefaultCities() {
        cities = weatherService.getDefaultCities()
        selectedCity = cities.first { $0.isSelected }
    }
    
    private func observeLocationUpdates() {
        // 监听位置变化
        locationManager.$currentLocation
            .compactMap { $0 }
            .sink { [weak self] location in
                Task { @MainActor in
                    await self?.handleLocationUpdate(location)
                }
            }
            .store(in: &cancellables)
        
        // 监听位置错误
        locationManager.$locationError
            .compactMap { $0 }
            .sink { [weak self] error in
                self?.locationError = error.localizedDescription
            }
            .store(in: &cancellables)
        
        // 监听权限状态变化
        locationManager.$authorizationStatus
            .sink { [weak self] status in
                Task { @MainActor in
                    await self?.handleAuthorizationStatusChange(status)
                }
            }
            .store(in: &cancellables)
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    private func setupNotificationObservers() {
        // Observe weather notification toggle
        $weatherNotificationsEnabled
            .sink { [weak self] enabled in
                if enabled {
                    Task {
                        await self?.notificationManager.requestNotificationPermission()
                    }
                }
            }
            .store(in: &cancellables)
        
        // Observe daily notification toggle
        $dailyNotificationsEnabled
            .sink { [weak self] enabled in
                if enabled {
                    Task {
                        _ = await self?.notificationManager.requestNotificationPermission()
                        if self?.notificationManager.hasNotificationPermission == true {
                            await self?.notificationManager.scheduleDailyReminders(for: self?.cities ?? [])
                        }
                    }
                } else {
                    Task {
                        await self?.notificationManager.cancelNotifications(type: .dailyReminder)
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    private func handleAutoLocationToggle() {
        if autoLocationEnabled {
            enableAutoLocation()
        } else {
            disableAutoLocation()
        }
    }
    
    private func enableAutoLocation() {
        if locationManager.hasLocationPermission {
            locationManager.getCurrentLocation()
        } else {
            locationManager.requestLocationPermission()
        }
    }
    
    private func disableAutoLocation() {
        locationManager.stopLocationUpdates()
        // 如果当前选中的是位置城市，切换到第一个固定城市
        if let currentLocationCity = currentLocationCity, 
           selectedCity?.id == currentLocationCity.id,
           let firstCity = cities.first(where: { $0.id != currentLocationCity.id }) {
            selectCity(firstCity)
        }
    }
    
    private func handleLocationUpdate(_ location: CLLocation) async {
        // 首先通过LocationManager获取真实的城市名称
        let realCityName = await locationManager.getCityName(for: location)
        
        // 通过坐标获取天气数据
        let weather = await weatherService.fetchWeatherData(for: location.coordinate)
        
        if let weather = weather {
            // 使用真实的城市名称，如果获取失败则使用天气服务返回的名称
            let displayName = realCityName ?? weather.cityName
            
            // 创建或更新当前位置城市
            let locationCity = City(
                name: displayName,
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude,
                isSelected: true
            )
            
            currentLocationCity = locationCity
            
            // 如果启用了自动定位，设置为当前选中城市
            if autoLocationEnabled {
                // 取消其他城市的选中状态
                for i in cities.indices {
                    cities[i].isSelected = false
                }
                
                selectedCity = locationCity
                
                // 更新天气数据的城市名称以匹配显示名称
                let updatedWeather = weather
                updatedWeather.cityName = displayName
                currentWeather = updatedWeather
                
                // 更新小组件数据
                WidgetDataManager.shared.updateWidgetData(from: updatedWeather)
            }
        }
    }
    
    private func handleAuthorizationStatusChange(_ status: CLAuthorizationStatus) async {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            if autoLocationEnabled {
                locationManager.getCurrentLocation()
            }
            locationError = nil
        case .denied, .restricted:
            autoLocationEnabled = false
            locationError = "位置权限被拒绝，请在设置中开启位置权限"
        case .notDetermined:
            break
        @unknown default:
            break
        }
    }
    
    func requestLocationPermission() {
        locationManager.requestLocationPermission()
    }
    
    func loadWeatherData() async {
        // 如果启用了自动定位且有权限，优先使用当前位置
        if autoLocationEnabled && locationManager.hasLocationPermission {
            locationManager.getCurrentLocation()
            return
        }
        
        guard let city = selectedCity else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        if let weather = await weatherService.fetchWeatherData(for: city.name) {
            // Update city name to use localized display name
            weather.cityName = city.displayName
            currentWeather = weather
            
            // Update widget data
            WidgetDataManager.shared.updateWidgetData(from: weather)
            
            // Check for weather alerts
            if weatherNotificationsEnabled {
                Task {
                    await notificationManager.checkWeatherAlerts(for: weather, city: city)
                }
            }
        }
    }
    
    func refreshWeatherData() async {
        if autoLocationEnabled && locationManager.hasLocationPermission {
            locationManager.getCurrentLocation()
        } else {
            await loadWeatherData()
        }
    }
    
    func selectCity(_ city: City) {
        // 如果选择了其他城市，关闭自动定位
        if autoLocationEnabled && city.id != currentLocationCity?.id {
            autoLocationEnabled = false
        }
        
        // 更新选中状态
        for i in cities.indices {
            cities[i].isSelected = (cities[i].id == city.id)
        }
        selectedCity = city
        Task {
            await loadWeatherData()
        }
    }
    
    func addCity(_ city: City) {
        cities.append(city)
    }
    
    func removeCity(_ city: City) {
        cities.removeAll { $0.id == city.id }
        if selectedCity?.id == city.id {
            if let firstCity = cities.first {
                selectCity(firstCity)
            } else {
                selectedCity = nil
                currentWeather = nil
            }
        }
    }
    
    func dismissWelcome() {
        showingWelcome = false
        Task {
            await loadWeatherData()
        }
    }
    
    // 获取位置权限状态描述
    var locationPermissionStatus: String {
        return locationManager.permissionStatusDescription
    }
    
    var canUseAutoLocation: Bool {
        return locationManager.hasLocationPermission
    }
    
    // 温度单位转换
    func formattedTemperature(_ temperature: Double) -> String {
        switch temperatureUnit {
        case .celsius:
            return "\(Int(temperature))°"
        case .fahrenheit:
            return "\(Int(temperature * 9/5 + 32))°"
        }
    }
    
    // 风速单位转换
    func formattedWindSpeed(_ speed: Double) -> String {
        switch windSpeedUnit {
        case .kmh:
            return "\(Int(speed))km/h"
        case .mph:
            return "\(Int(speed * 0.621371))mph"
        }
    }
    
    // 获取天气图标
    func weatherIcon(for condition: WeatherCondition) -> String {
        return condition.icon
    }
    
    // 获取天气背景颜色
    func weatherBackgroundColor(for condition: WeatherCondition) -> [String] {
        return condition.backgroundColors
    }
    
    // 格式化小时显示
    func formattedHour(_ hour: Int) -> String {
        if LanguageManager.shared.currentLanguage == .chinese {
            return "\(hour)时"
        } else {
            let period = hour < 12 ? "AM" : "PM"
            let displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour)
            return "\(displayHour) \(period)"
        }
    }
}

enum TemperatureUnit: String, CaseIterable {
    case celsius = "celsius"
    case fahrenheit = "fahrenheit"
    
    var displayName: String {
        switch self {
        case .celsius:
            return LocalizedText.get("celsius")
        case .fahrenheit:
            return LocalizedText.get("fahrenheit")
        }
    }
}

enum WindSpeedUnit: String, CaseIterable {
    case kmh = "kmh"
    case mph = "mph"
    
    var displayName: String {
        switch self {
        case .kmh:
            return LocalizedText.get("kmh")
        case .mph:
            return LocalizedText.get("mph")
        }
    }
} 