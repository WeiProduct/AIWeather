import Foundation
import CoreLocation

final class WeatherService: ObservableObject, WeatherServiceProtocol, @unchecked Sendable {
    static let shared = WeatherService()
    
    private let session = URLSession.shared
    private let decoder = JSONDecoder()
    
    init() {}
    
    // MARK: - 获取天气数据
    func fetchWeatherData(for cityName: String) async -> WeatherData? {
        // 如果API密钥未配置，返回模拟数据
        guard ApiConfig.isApiKeyConfigured else {
            print("⚠️ API密钥未配置，使用模拟数据")
            return generateMockWeatherData(for: cityName)
        }
        
        // 1. 先通过地理编码获取坐标
        guard let coordinates = await getCoordinates(for: cityName) else {
            print("❌ 无法获取城市坐标: \(cityName)")
            return nil
        }
        
        // 2. 使用坐标获取天气数据
        return await fetchWeatherData(for: coordinates)
    }
    
    func fetchWeatherData(for coordinate: CLLocationCoordinate2D) async -> WeatherData? {
        guard ApiConfig.isApiKeyConfigured else {
            print("⚠️ API密钥未配置，使用模拟数据")
            return generateMockWeatherData(for: "当前位置")
        }
        
        do {
            // 获取当前天气
            let currentWeather = try await fetchCurrentWeather(lat: coordinate.latitude, lon: coordinate.longitude)
            
            // 获取5天预报
            let forecast = try await fetchForecast(lat: coordinate.latitude, lon: coordinate.longitude)
            
            // 转换为应用内部模型
            return convertToWeatherData(current: currentWeather, forecast: forecast)
        } catch {
            print("❌ 获取天气数据失败: \(error.localizedDescription)")
            return generateMockWeatherData(for: "当前位置")
        }
    }
    
    // MARK: - 城市搜索
    func searchCities(query: String) async -> [City] {
        guard ApiConfig.isApiKeyConfigured, !query.isEmpty else {
            return getDefaultCities().filter { $0.name.contains(query) }
        }
        
        do {
            guard var components = URLComponents(string: "\(ApiConfig.openWeatherMapGeoBaseURL)/direct") else {
                print("❌ 无法创建 URL components")
                return []
            }
            components.queryItems = [
                URLQueryItem(name: "q", value: query),
                URLQueryItem(name: "limit", value: "10"),
                URLQueryItem(name: "appid", value: ApiConfig.openWeatherMapApiKey)
            ]
            
            guard let url = components.url else { return [] }
            
            let (data, _) = try await session.data(from: url)
            let geocodingResults = try decoder.decode([GeocodingResponse].self, from: data)
            
            return geocodingResults.map { result in
                let cityName = result.state != nil ? "\(result.name), \(result.state!)" : result.name
                return City(
                    name: cityName,
                    latitude: result.lat,
                    longitude: result.lon
                )
            }
        } catch {
            print("❌ 搜索城市失败: \(error.localizedDescription)")
            return getDefaultCities().filter { $0.name.contains(query) }
        }
    }
    
    // MARK: - 私有方法
    private func getCoordinates(for cityName: String) async -> CLLocationCoordinate2D? {
        do {
            guard var components = URLComponents(string: "\(ApiConfig.openWeatherMapGeoBaseURL)/direct") else {
                print("❌ 无法创建 URL components")
                return nil
            }
            components.queryItems = [
                URLQueryItem(name: "q", value: cityName),
                URLQueryItem(name: "limit", value: "1"),
                URLQueryItem(name: "appid", value: ApiConfig.openWeatherMapApiKey)
            ]
            
            guard let url = components.url else { return nil }
            
            let (data, _) = try await session.data(from: url)
            let geocodingResults = try decoder.decode([GeocodingResponse].self, from: data)
            
            guard let first = geocodingResults.first else { return nil }
            
            return CLLocationCoordinate2D(latitude: first.lat, longitude: first.lon)
        } catch {
            print("❌ 地理编码失败: \(error.localizedDescription)")
            return nil
        }
    }
    
    @MainActor
    private func fetchCurrentWeather(lat: Double, lon: Double) async throws -> OpenWeatherCurrentResponse {
        guard var components = URLComponents(string: "\(ApiConfig.openWeatherMapBaseURL)/weather") else {
            throw WeatherError.invalidURL
        }
        components.queryItems = [
            URLQueryItem(name: "lat", value: String(lat)),
            URLQueryItem(name: "lon", value: String(lon)),
            URLQueryItem(name: "appid", value: ApiConfig.openWeatherMapApiKey),
            URLQueryItem(name: "units", value: "metric"),
            URLQueryItem(name: "lang", value: LanguageManager.shared.currentLanguage.apiCode)
        ]
        
        guard let url = components.url else {
            throw WeatherError.invalidURL
        }
        
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              200...299 ~= httpResponse.statusCode else {
            throw WeatherError.invalidResponse
        }
        
        return try decoder.decode(OpenWeatherCurrentResponse.self, from: data)
    }
    
    @MainActor
    private func fetchForecast(lat: Double, lon: Double) async throws -> OpenWeatherForecastResponse {
        guard var components = URLComponents(string: "\(ApiConfig.openWeatherMapBaseURL)/forecast") else {
            throw WeatherError.invalidURL
        }
        components.queryItems = [
            URLQueryItem(name: "lat", value: String(lat)),
            URLQueryItem(name: "lon", value: String(lon)),
            URLQueryItem(name: "appid", value: ApiConfig.openWeatherMapApiKey),
            URLQueryItem(name: "units", value: "metric"),
            URLQueryItem(name: "lang", value: LanguageManager.shared.currentLanguage.apiCode)
        ]
        
        guard let url = components.url else {
            throw WeatherError.invalidURL
        }
        
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              200...299 ~= httpResponse.statusCode else {
            throw WeatherError.invalidResponse
        }
        
        return try decoder.decode(OpenWeatherForecastResponse.self, from: data)
    }
    
    private func convertToWeatherData(current: OpenWeatherCurrentResponse, forecast: OpenWeatherForecastResponse) -> WeatherData {
        // 转换天气条件
        let weatherCondition = WeatherCondition.fromOpenWeatherMain(current.weather.first?.main ?? "Clear")
        
        // 计算每日预报
        let dailyForecast = processForecastData(forecast.list)
        
        // 计算风向
        let windDirection = convertWindDirection(current.wind.deg)
        
        // 获取今日的温度范围（从预报数据中计算）
        let calendar = Calendar.current
        let now = Date()
        let today = calendar.startOfDay(for: now)
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        
        // 获取今日所有的预报数据
        let todayForecastItems = forecast.list.filter { item in
            let itemDate = Date(timeIntervalSince1970: TimeInterval(item.dt))
            return itemDate >= today && itemDate < tomorrow
        }
        
        // 收集所有温度值，包括当前温度
        var allTemperatures = todayForecastItems.map { $0.main.temp }
        allTemperatures.append(current.main.temp) // 添加当前温度
        
        // 如果今日数据太少，使用更宽的时间范围（前后12小时）
        if allTemperatures.count < 3 {
            let extendedItems = forecast.list.filter { item in
                let itemDate = Date(timeIntervalSince1970: TimeInterval(item.dt))
                let hoursDiff = abs(itemDate.timeIntervalSince(now) / 3600)
                return hoursDiff <= 12
            }
            allTemperatures = extendedItems.map { $0.main.temp }
            allTemperatures.append(current.main.temp)
        }
        
        // 计算最低和最高温度，确保逻辑合理
        let todayMinTemp = allTemperatures.min() ?? current.main.temp
        let todayMaxTemp = allTemperatures.max() ?? current.main.temp
        
        // 确保最低温度不高于当前温度，最高温度不低于当前温度
        let adjustedMinTemp = min(todayMinTemp, current.main.temp)
        let adjustedMaxTemp = max(todayMaxTemp, current.main.temp)
        
        // 获取当前或最近时刻的降水概率
        let currentTime = Date()
        let closestForecast = forecast.list.min(by: { item1, item2 in
            let time1 = Date(timeIntervalSince1970: TimeInterval(item1.dt))
            let time2 = Date(timeIntervalSince1970: TimeInterval(item2.dt))
            return abs(time1.timeIntervalSince(currentTime)) < abs(time2.timeIntervalSince(currentTime))
        })
        let precipitation = closestForecast?.pop ?? 0.0
        
        return WeatherData(
            cityName: current.name,
            temperature: current.main.temp,
            temperatureMin: adjustedMinTemp,
            temperatureMax: adjustedMaxTemp,
            weatherCondition: weatherCondition,
            weatherDescription: current.weather.first?.description.capitalized ?? "晴朗",
            humidity: Double(current.main.humidity),
            windSpeed: current.wind.speed * 3.6, // 转换为 km/h
            windDirection: windDirection,
            pressure: Double(current.main.pressure),
            visibility: Double(current.visibility / 1000), // 转换为 km
            uvIndex: 5, // OpenWeatherMap免费版不提供UV指数，使用默认值
            precipitation: precipitation * 100, // 转换为百分比
            feelsLike: current.main.feelsLike,
            weeklyForecast: dailyForecast,
            hourlyForecast: forecast.list,
            sunriseTime: current.sys.sunrise,
            sunsetTime: current.sys.sunset
        )
    }
    
    private func processForecastData(_ forecastList: [ForecastItem]) -> [DailyWeather] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // 按日期分组
        var dailyData: [Date: [ForecastItem]] = [:]
        
        for item in forecastList {
            let date = Date(timeIntervalSince1970: TimeInterval(item.dt))
            let dayStart = calendar.startOfDay(for: date)
            
            if dailyData[dayStart] == nil {
                dailyData[dayStart] = []
            }
            dailyData[dayStart]?.append(item)
        }
        
        // 转换为DailyWeather
        let sortedDays = dailyData.keys.sorted()
        let dayFormatter = DateFormatter()
        dayFormatter.locale = Locale(identifier: "zh_CN")
        
        return sortedDays.prefix(7).enumerated().map { index, date in
            let items = dailyData[date] ?? []
            
            let maxTemp = items.map { $0.main.tempMax }.max() ?? 0
            let minTemp = items.map { $0.main.tempMin }.min() ?? 0
            let avgPrecipitation = items.map { $0.pop * 100 }.reduce(0, +) / Double(items.count)
            
            let weatherConditionString = items.first?.weather.first?.main ?? "Clear"
            let weatherCondition = WeatherCondition.fromOpenWeatherMain(weatherConditionString)
            
            let dayName: String
            if calendar.isDate(date, inSameDayAs: today) {
                dayName = "今天"
            } else if calendar.isDate(date, inSameDayAs: calendar.date(byAdding: .day, value: 1, to: today) ?? Date()) {
                dayName = "明天"
            } else {
                dayFormatter.dateFormat = "EEEE"
                dayName = dayFormatter.string(from: date)
            }
            
            return DailyWeather(
                date: date,
                dayName: dayName,
                weatherCondition: weatherCondition,
                temperatureMax: maxTemp,
                temperatureMin: minTemp,
                precipitation: avgPrecipitation
            )
        }
    }
    
    
    private func convertWindDirection(_ degrees: Int) -> String {
        let directions = ["北", "东北", "东", "东南", "南", "西南", "西", "西北"]
        let index = Int((Double(degrees) + 22.5) / 45.0) % 8
        return directions[index]
    }
    
    // MARK: - 模拟数据（当API密钥未配置时使用）
    private func generateMockWeatherData(for cityName: String) -> WeatherData {
        let weeklyData = generateWeeklyForecast()
        
        let temperature = Double.random(in: 15...35)
        let feelsLike = temperature + Double.random(in: -3...3) // 体感温度随机偏差
        
        return WeatherData(
            cityName: cityName,
            temperature: temperature,
            temperatureMin: Double.random(in: 10...20),
            temperatureMax: Double.random(in: 25...35),
            weatherCondition: [WeatherCondition.sunny, .cloudy, .rainy, .partlyCloudy].randomElement() ?? .sunny,
            weatherDescription: getMockWeatherDescription(cityName),
            humidity: Double.random(in: 40...90),
            windSpeed: Double.random(in: 5...25),
            windDirection: "东北",
            pressure: Double.random(in: 1000...1030),
            visibility: Double.random(in: 5...15),
            uvIndex: Int.random(in: 1...10),
            precipitation: Double.random(in: 0...30),
            feelsLike: feelsLike,
            weeklyForecast: weeklyData
        )
    }
    
    private func getMockWeatherDescription(_ cityName: String) -> String {
        if cityName.contains("北京") {
            return "多云转晴"
        } else if cityName.contains("上海") {
            return "小雨"
        } else if cityName.contains("广州") {
            return "晴"
        } else if cityName.contains("深圳") {
            return "多云"
        } else if cityName.contains("Amherst") {
            return "Clear"
        } else {
            return "多云转晴"
        }
    }
    
    private func generateWeeklyForecast() -> [DailyWeather] {
        let calendar = Calendar.current
        let weekDays = ["今天", "明天", "周三", "周四", "周五", "周六", "周日"]
        let weatherConditions: [WeatherCondition] = [.sunny, .cloudy, .rainy, .partlyCloudy]
        
        return (0..<7).map { index in
            let date = calendar.date(byAdding: .day, value: index, to: Date()) ?? Date()
            return DailyWeather(
                date: date,
                dayName: weekDays[index],
                weatherCondition: weatherConditions.randomElement() ?? .sunny,
                temperatureMax: Double.random(in: 25...35),
                temperatureMin: Double.random(in: 15...25),
                precipitation: Double.random(in: 0...50)
            )
        }
    }
    
    // 获取预定义城市列表
    func getDefaultCities() -> [City] {
        return [
            City(name: "Beijing", latitude: 39.9042, longitude: 116.4074, isSelected: true, cityKey: "city_beijing"),
            City(name: "Shanghai", latitude: 31.2304, longitude: 121.4737, cityKey: "city_shanghai"),
            City(name: "Guangzhou", latitude: 23.1291, longitude: 113.2644, cityKey: "city_guangzhou"),
            City(name: "Shenzhen", latitude: 22.5431, longitude: 114.0579, cityKey: "city_shenzhen"),
            City(name: "Hangzhou", latitude: 30.2741, longitude: 120.1551, cityKey: "city_hangzhou"),
            City(name: "Chengdu", latitude: 30.5728, longitude: 104.0668, cityKey: "city_chengdu"),
            City(name: "Xi'an", latitude: 34.3416, longitude: 108.9398, cityKey: "city_xian"),
            City(name: "Nanjing", latitude: 32.0603, longitude: 118.7969, cityKey: "city_nanjing"),
            City(name: "Wuhan", latitude: 30.5928, longitude: 114.3055, cityKey: "city_wuhan"),
            City(name: "Tianjin", latitude: 39.3434, longitude: 117.3616, cityKey: "city_tianjin")
        ]
    }
}

// MARK: - 错误类型
enum WeatherError: Error {
    case invalidURL
    case noData
    case invalidResponse
    case decodingError
    case networkError
    
    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "无效的URL"
        case .noData:
            return "没有数据"
        case .invalidResponse:
            return "无效的响应"
        case .decodingError:
            return "数据解析错误"
        case .networkError:
            return "网络错误"
        }
    }
} 