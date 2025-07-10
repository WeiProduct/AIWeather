import Foundation
import CoreLocation
import Combine

@MainActor
class LocationManager: NSObject, ObservableObject, LocationServiceProtocol {
    static let shared = LocationManager()
    
    @Published var currentLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus
    @Published var locationError: LocationError?
    
    private let locationManager = CLLocationManager()
    private var geocoder = CLGeocoder()
    
    override init() {
        self.authorizationStatus = locationManager.authorizationStatus
        super.init()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 1000 // 1公里变化才更新
        
        print("📍 LocationManager initialized with status: \(authorizationStatus.debugDescription)")
    }
    
    // MARK: - Public Methods
    
    func requestLocationPermission() {
        print("📍 Requesting location permission...")
        locationManager.requestWhenInUseAuthorization()
    }
    
    func getCurrentLocation() {
        print("📍 Getting current location...")
        guard hasLocationPermission else {
            print("❌ No location permission")
            locationError = .permissionDenied
            return
        }
        
        locationManager.requestLocation()
    }
    
    func startLocationUpdates() {
        print("📍 Starting location updates...")
        guard hasLocationPermission else {
            print("❌ No location permission for continuous updates")
            locationError = .permissionDenied
            return
        }
        
        locationManager.startUpdatingLocation()
    }
    
    func stopLocationUpdates() {
        print("📍 Stopping location updates...")
        locationManager.stopUpdatingLocation()
    }
    
    // MARK: - Public Properties
    
    var hasLocationPermission: Bool {
        switch authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            return true
        default:
            return false
        }
    }
    
    var permissionStatusDescription: String {
        switch authorizationStatus {
        case .notDetermined:
            return LocalizedText.get("permission_not_determined")
        case .restricted:
            return LocalizedText.get("permission_restricted")
        case .denied:
            return LocalizedText.get("permission_denied")
        case .authorizedAlways:
            return LocalizedText.get("permission_authorized_always")
        case .authorizedWhenInUse:
            return LocalizedText.get("permission_authorized_when_in_use")
        @unknown default:
            return LocalizedText.get("permission_unknown")
        }
    }
    
    // MARK: - 反向地理编码
    
    func getCityName(for location: CLLocation) async -> String? {
        do {
            print("📍 开始反向地理编码: \(location.coordinate.latitude), \(location.coordinate.longitude)")
            
            let placemarks = try await geocoder.reverseGeocodeLocation(location)
            
            guard let placemark = placemarks.first else {
                print("❌ 未找到地理信息")
                return nil
            }
            
            print("📍 反向地理编码结果:")
            print("  - Country: \(placemark.country ?? "N/A")")
            print("  - Administrative Area: \(placemark.administrativeArea ?? "N/A")")
            print("  - Sub Administrative Area: \(placemark.subAdministrativeArea ?? "N/A")")
            print("  - Locality: \(placemark.locality ?? "N/A")")
            print("  - Sub Locality: \(placemark.subLocality ?? "N/A")")
            print("  - Name: \(placemark.name ?? "N/A")")
            
            // 构建城市名称
            var cityName = ""
            
            // 优先使用locality（城市）
            if let locality = placemark.locality {
                cityName = locality
            }
            // 如果没有locality，使用subAdministrativeArea（县/区）
            else if let subAdministrativeArea = placemark.subAdministrativeArea {
                cityName = subAdministrativeArea
            }
            // 最后使用administrativeArea（州/省）
            else if let administrativeArea = placemark.administrativeArea {
                cityName = administrativeArea
            }
            
            // 添加州/省信息（如果存在且不同于城市名）
            if let administrativeArea = placemark.administrativeArea,
               !cityName.contains(administrativeArea) {
                if !cityName.isEmpty {
                    cityName += ", \(administrativeArea)"
                } else {
                    cityName = administrativeArea
                }
            }
            
            // 添加国家信息（如果不是中国）
            if let country = placemark.country,
               country != "中国" && country != "China" {
                if !cityName.isEmpty {
                    cityName += ", \(country)"
                } else {
                    cityName = country
                }
            }
            
            let finalCityName = cityName.isEmpty ? "未知位置" : cityName
            print("📍 最终城市名称: \(finalCityName)")
            
            return finalCityName
            
        } catch {
            print("❌ 反向地理编码失败: \(error.localizedDescription)")
            return nil
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationManager: CLLocationManagerDelegate {
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        Task { @MainActor in
            print("📍 Location updated: \(location.coordinate.latitude), \(location.coordinate.longitude)")
            currentLocation = location
            locationError = nil
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            print("❌ Location error: \(error.localizedDescription)")
            
            if let clError = error as? CLError {
                switch clError.code {
                case .denied:
                    locationError = .permissionDenied
                case .network:
                    locationError = .networkError
                case .locationUnknown:
                    locationError = .locationUnavailable
                default:
                    locationError = .unknown(error.localizedDescription)
                }
            } else {
                locationError = .unknown(error.localizedDescription)
            }
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        Task { @MainActor in
            print("📍 Authorization status changed: \(status.debugDescription)")
            authorizationStatus = status
            
            switch status {
            case .authorizedWhenInUse, .authorizedAlways:
                locationError = nil
            case .denied, .restricted:
                locationError = .permissionDenied
            case .notDetermined:
                locationError = nil
            @unknown default:
                break
            }
        }
    }
}

// MARK: - LocationError

enum LocationError: LocalizedError {
    case permissionDenied
    case locationUnavailable
    case networkError
    case unknown(String)
    
    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "位置权限被拒绝"
        case .locationUnavailable:
            return "无法获取位置信息"
        case .networkError:
            return "网络错误"
        case .unknown(let message):
            return message
        }
    }
}

// MARK: - Extensions

extension CLAuthorizationStatus {
    var debugDescription: String {
        switch self {
        case .notDetermined:
            return "notDetermined"
        case .restricted:
            return "restricted"
        case .denied:
            return "denied"
        case .authorizedAlways:
            return "authorizedAlways"
        case .authorizedWhenInUse:
            return "authorizedWhenInUse"
        @unknown default:
            return "unknown"
        }
    }
} 