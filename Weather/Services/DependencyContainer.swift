import Foundation
import SwiftUI
import CoreLocation

protocol WeatherServiceProtocol: Sendable {
    func fetchWeatherData(for cityName: String) async -> WeatherData?
    func fetchWeatherData(for coordinate: CLLocationCoordinate2D) async -> WeatherData?
    func searchCities(query: String) async -> [City]
    func getDefaultCities() -> [City]
}

@MainActor
protocol LocationServiceProtocol: ObservableObject {
    var currentLocation: CLLocation? { get }
    var authorizationStatus: CLAuthorizationStatus { get }
    var locationError: LocationError? { get }
    var hasLocationPermission: Bool { get }
    var permissionStatusDescription: String { get }
    
    func requestLocationPermission()
    func getCurrentLocation()
    func startLocationUpdates()
    func stopLocationUpdates()
    func getCityName(for location: CLLocation) async -> String?
}

@MainActor
protocol LanguageServiceProtocol: ObservableObject {
    var currentLanguage: AppLanguage { get set }
    func switchLanguage()
    func setLanguage(_ language: AppLanguage)
}

class DependencyContainer: ObservableObject {
    static let shared = DependencyContainer()
    
    lazy var weatherService: WeatherServiceProtocol = WeatherService()
    @MainActor lazy var locationService: any LocationServiceProtocol = LocationManager()
    @MainActor lazy var languageService: any LanguageServiceProtocol = LanguageManager()
    
    private init() {}
}

// Environment key for dependency injection
struct DependencyContainerKey: EnvironmentKey {
    static let defaultValue = DependencyContainer.shared
}

extension EnvironmentValues {
    var dependencies: DependencyContainer {
        get { self[DependencyContainerKey.self] }
        set { self[DependencyContainerKey.self] = newValue }
    }
}