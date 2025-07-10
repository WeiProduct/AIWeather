import Foundation
import Combine

// MARK: - Network Error Types
enum NetworkError: LocalizedError {
    case invalidURL
    case noData
    case decodingError(Error)
    case httpError(statusCode: Int)
    case networkUnavailable
    case timeout
    case unknown(Error)
    case apiKeyMissing
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return LocalizedText.get("error_invalid_url")
        case .noData:
            return LocalizedText.get("error_no_data")
        case .decodingError:
            return LocalizedText.get("error_parsing_data")
        case .httpError(let statusCode):
            return "\(LocalizedText.get("error_http")) \(statusCode)"
        case .networkUnavailable:
            return LocalizedText.get("error_no_network")
        case .timeout:
            return LocalizedText.get("error_timeout")
        case .apiKeyMissing:
            return LocalizedText.get("error_api_key_missing")
        case .unknown:
            return LocalizedText.get("error_unknown")
        }
    }
    
    var isRetryable: Bool {
        switch self {
        case .networkUnavailable, .timeout:
            return true
        case .httpError(let statusCode):
            return statusCode >= 500 || statusCode == 429
        default:
            return false
        }
    }
}

// MARK: - API Endpoint
enum APIEndpoint {
    case currentWeather(lat: Double, lon: Double)
    case forecast(lat: Double, lon: Double)
    case geocoding(query: String)
    case reverseGeocoding(lat: Double, lon: Double)
    
    var path: String {
        switch self {
        case .currentWeather:
            return "/weather"
        case .forecast:
            return "/forecast"
        case .geocoding, .reverseGeocoding:
            return "/direct"
        }
    }
    
    var baseURL: String {
        switch self {
        case .currentWeather, .forecast:
            return ApiConfig.openWeatherMapBaseURL
        case .geocoding, .reverseGeocoding:
            return ApiConfig.openWeatherMapGeoBaseURL
        }
    }
    
    var queryItems: [URLQueryItem] {
        var items: [URLQueryItem] = []
        
        switch self {
        case .currentWeather(let lat, let lon), .forecast(let lat, let lon):
            items.append(contentsOf: [
                URLQueryItem(name: "lat", value: String(lat)),
                URLQueryItem(name: "lon", value: String(lon)),
                URLQueryItem(name: "appid", value: ApiConfig.openWeatherMapApiKey),
                URLQueryItem(name: "units", value: "metric"),
                URLQueryItem(name: "lang", value: "en") // Use English as default for this API
            ])
            
        case .geocoding(let query):
            items.append(contentsOf: [
                URLQueryItem(name: "q", value: query),
                URLQueryItem(name: "limit", value: "10"),
                URLQueryItem(name: "appid", value: ApiConfig.openWeatherMapApiKey)
            ])
            
        case .reverseGeocoding(let lat, let lon):
            items.append(contentsOf: [
                URLQueryItem(name: "lat", value: String(lat)),
                URLQueryItem(name: "lon", value: String(lon)),
                URLQueryItem(name: "limit", value: "1"),
                URLQueryItem(name: "appid", value: ApiConfig.openWeatherMapApiKey)
            ])
        }
        
        return items
    }
}

// MARK: - Network Manager
class NetworkManager {
    static let shared = NetworkManager()
    
    private let session: URLSession
    private let decoder = JSONDecoder()
    private let maxRetries = 3
    private let retryDelay: TimeInterval = 1.0
    
    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        configuration.waitsForConnectivity = true
        
        self.session = URLSession(configuration: configuration)
    }
    
    // MARK: - Public Methods
    func request<T: Decodable>(_ endpoint: APIEndpoint, 
                               type: T.Type,
                               retryCount: Int = 0) async throws -> T {
        guard ApiConfig.isApiKeyConfigured else {
            throw NetworkError.apiKeyMissing
        }
        
        let url = try buildURL(for: endpoint)
        
        do {
            let (data, response) = try await session.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.unknown(NSError(domain: "Invalid response", code: -1))
            }
            
            switch httpResponse.statusCode {
            case 200...299:
                return try decoder.decode(T.self, from: data)
                
            case 401:
                throw NetworkError.apiKeyMissing
                
            case 429, 500...599:
                if retryCount < maxRetries {
                    try await Task.sleep(nanoseconds: UInt64(retryDelay * Double(retryCount + 1) * 1_000_000_000))
                    return try await request(endpoint, type: type, retryCount: retryCount + 1)
                }
                throw NetworkError.httpError(statusCode: httpResponse.statusCode)
                
            default:
                throw NetworkError.httpError(statusCode: httpResponse.statusCode)
            }
            
        } catch let error as NetworkError {
            throw error
            
        } catch let error as DecodingError {
            throw NetworkError.decodingError(error)
            
        } catch {
            if (error as NSError).code == NSURLErrorNotConnectedToInternet {
                throw NetworkError.networkUnavailable
            } else if (error as NSError).code == NSURLErrorTimedOut {
                throw NetworkError.timeout
            }
            
            if error is NetworkError == false && retryCount < maxRetries {
                try await Task.sleep(nanoseconds: UInt64(retryDelay * Double(retryCount + 1) * 1_000_000_000))
                return try await request(endpoint, type: type, retryCount: retryCount + 1)
            }
            
            throw NetworkError.unknown(error)
        }
    }
    
    // MARK: - Private Methods
    private func buildURL(for endpoint: APIEndpoint) throws -> URL {
        var components = URLComponents(string: endpoint.baseURL + endpoint.path)
        components?.queryItems = endpoint.queryItems
        
        guard let url = components?.url else {
            throw NetworkError.invalidURL
        }
        
        return url
    }
}

// MARK: - Combine Support
extension NetworkManager {
    func requestPublisher<T: Decodable>(_ endpoint: APIEndpoint, 
                                       type: T.Type) -> AnyPublisher<T, NetworkError> {
        Future { promise in
            Task {
                do {
                    let result = try await self.request(endpoint, type: type)
                    promise(.success(result))
                } catch let error as NetworkError {
                    promise(.failure(error))
                } catch {
                    promise(.failure(.unknown(error)))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}