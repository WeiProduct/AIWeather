import Foundation
import CoreLocation

/// 使用 Vercel 代理服务器的天气服务
/// 保护 API 密钥，防止在客户端暴露
final class ProxyWeatherService: ObservableObject, WeatherServiceProtocol, @unchecked Sendable {
    static let shared = ProxyWeatherService()
    
    private let session = URLSession.shared
    private let decoder = JSONDecoder()
    
    init() {}
    
    // MARK: - 获取天气数据
    func fetchWeatherData(for cityName: String) async -> WeatherData? {
        do {
            // 使用代理 API
            guard var components = URLComponents(string: "\(ApiConfig.proxyBaseURL)/api/weather") else {
                print("❌ 无法创建 URL components")
                return nil
            }
            components.queryItems = [
                URLQueryItem(name: "city", value: cityName)
            ]
            
            guard let url = components.url else {
                print("❌ 无效的 URL")
                return nil
            }
            
            let request = URLRequest(url: url)
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  200...299 ~= httpResponse.statusCode else {
                print("❌ 无效的响应")
                return nil
            }
            
            // 使用与 WeatherService 相同的响应模型
            let weatherResponse = try decoder.decode(OpenWeatherCurrentResponse.self, from: data)
            
            // 获取预报数据
            if let forecast = await fetchForecast(for: cityName) {
                return convertToWeatherData(current: weatherResponse, forecast: forecast)
            } else {
                // 如果预报失败，只返回当前天气
                return convertToWeatherData(current: weatherResponse, forecast: nil)
            }
        } catch {
            print("❌ 获取天气数据失败: \(error.localizedDescription)")
            return nil
        }
    }
    
    func fetchWeatherData(for coordinate: CLLocationCoordinate2D) async -> WeatherData? {
        // 先获取城市名称
        let cityName = await getCityName(for: coordinate) ?? "当前位置"
        return await fetchWeatherData(for: cityName)
    }
    
    // MARK: - 城市搜索
    func searchCities(query: String) async -> [City] {
        guard !query.isEmpty else { return [] }
        
        do {
            guard var components = URLComponents(string: "\(ApiConfig.proxyBaseURL)/api/search") else {
                print("❌ 无法创建 URL components")
                return []
            }
            components.queryItems = [
                URLQueryItem(name: "q", value: query),
                URLQueryItem(name: "limit", value: "10")
            ]
            
            guard let url = components.url else { return [] }
            
            let request = URLRequest(url: url)
            let (data, _) = try await session.data(for: request)
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
            return []
        }
    }
    
    // MARK: - 私有方法
    private func getCityName(for coordinate: CLLocationCoordinate2D) async -> String? {
        do {
            guard var components = URLComponents(string: "\(ApiConfig.proxyBaseURL)/api/search") else {
                print("❌ 无法创建 URL components")
                return nil
            }
            components.queryItems = [
                URLQueryItem(name: "lat", value: String(coordinate.latitude)),
                URLQueryItem(name: "lon", value: String(coordinate.longitude)),
                URLQueryItem(name: "limit", value: "1")
            ]
            
            guard let url = components.url else { return nil }
            
            let request = URLRequest(url: url)
            let (data, _) = try await session.data(for: request)
            let geocodingResults = try decoder.decode([GeocodingResponse].self, from: data)
            
            return geocodingResults.first?.name
        } catch {
            print("❌ 反向地理编码失败: \(error.localizedDescription)")
            return nil
        }
    }
    
    
    private func formatDayName(_ date: Date) -> String {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        if calendar.isDate(date, inSameDayAs: today) {
            return "今天"
        } else if calendar.isDate(date, inSameDayAs: calendar.date(byAdding: .day, value: 1, to: today) ?? Date()) {
            return "明天"
        } else {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "zh_CN")
            formatter.dateFormat = "EEEE"
            return formatter.string(from: date)
        }
    }
    
    private func convertWindDirection(_ degrees: Int) -> String {
        let directions = ["北", "东北", "东", "东南", "南", "西南", "西", "西北"]
        let index = Int((Double(degrees) + 22.5) / 45.0) % 8
        return directions[index]
    }
    
    // 获取预定义城市列表
    func getDefaultCities() -> [City] {
        return [
            City(name: "Beijing", latitude: 39.9042, longitude: 116.4074, isSelected: true, cityKey: "city_beijing"),
            City(name: "Shanghai", latitude: 31.2304, longitude: 121.4737, cityKey: "city_shanghai"),
            City(name: "Guangzhou", latitude: 23.1291, longitude: 113.2644, cityKey: "city_guangzhou"),
            City(name: "Shenzhen", latitude: 22.5431, longitude: 114.0579, cityKey: "city_shenzhen"),
            City(name: "Hangzhou", latitude: 30.2741, longitude: 120.1551, cityKey: "city_hangzhou")
        ]
    }
    
    // MARK: - 获取预报数据
    private func fetchForecast(for cityName: String) async -> OpenWeatherForecastResponse? {
        do {
            guard var components = URLComponents(string: "\(ApiConfig.proxyBaseURL)/api/forecast") else {
                print("❌ 无法创建 URL components")
                return nil
            }
            components.queryItems = [
                URLQueryItem(name: "city", value: cityName)
            ]
            
            guard let url = components.url else { return nil }
            
            let request = URLRequest(url: url)
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  200...299 ~= httpResponse.statusCode else {
                return nil
            }
            
            return try self.decoder.decode(OpenWeatherForecastResponse.self, from: data)
        } catch {
            print("❌ 获取预报数据失败: \(error.localizedDescription)")
            return nil
        }
    }
    
    private func convertToWeatherData(current: OpenWeatherCurrentResponse, forecast: OpenWeatherForecastResponse?) -> WeatherData {
        // 转换天气条件
        let weatherCondition = WeatherCondition.fromOpenWeatherMain(current.weather.first?.main ?? "Clear")
        
        // 计算每日预报
        let dailyForecast: [DailyWeather]
        if let forecast = forecast {
            dailyForecast = processForecastData(forecast.list)
        } else {
            dailyForecast = []
        }
        
        // 计算风向
        let windDirection = convertWindDirection(current.wind.deg)
        
        // 获取今日的温度范围（从预报数据中计算）
        var todayMinTemp = current.main.tempMin
        var todayMaxTemp = current.main.tempMax
        
        if let forecast = forecast {
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
            
            // 计算最低和最高温度
            todayMinTemp = allTemperatures.min() ?? current.main.temp
            todayMaxTemp = allTemperatures.max() ?? current.main.temp
        }
        
        // 确保最低温度不高于当前温度，最高温度不低于当前温度
        let adjustedMinTemp = min(todayMinTemp, current.main.temp)
        let adjustedMaxTemp = max(todayMaxTemp, current.main.temp)
        
        // 获取当前或最近时刻的降水概率
        let precipitation: Double
        if let forecast = forecast {
            let currentTime = Date()
            let closestForecast = forecast.list.min(by: { item1, item2 in
                let time1 = Date(timeIntervalSince1970: TimeInterval(item1.dt))
                let time2 = Date(timeIntervalSince1970: TimeInterval(item2.dt))
                return abs(time1.timeIntervalSince(currentTime)) < abs(time2.timeIntervalSince(currentTime))
            })
            precipitation = (closestForecast?.pop ?? 0.0) * 100 // 转换为百分比
        } else {
            precipitation = 0
        }
        
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
            uvIndex: 5, // 默认值
            precipitation: precipitation,
            feelsLike: current.main.feelsLike,
            weeklyForecast: dailyForecast,
            hourlyForecast: forecast?.list ?? [],
            sunriseTime: current.sys.sunrise,
            sunsetTime: current.sys.sunset
        )
    }
    
    private func processForecastData(_ forecastList: [ForecastItem]) -> [DailyWeather] {
        let calendar = Calendar.current
        _ = calendar.startOfDay(for: Date())
        
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
        
        return sortedDays.prefix(7).map { date in
            let items = dailyData[date] ?? []
            
            let maxTemp = items.map { $0.main.tempMax }.max() ?? 0
            let minTemp = items.map { $0.main.tempMin }.min() ?? 0
            let avgPrecipitation = items.map { $0.pop * 100 }.reduce(0, +) / Double(items.count)
            
            let weatherConditionString = items.first?.weather.first?.main ?? "Clear"
            let weatherCondition = WeatherCondition.fromOpenWeatherMain(weatherConditionString)
            
            return DailyWeather(
                date: date,
                dayName: self.formatDayName(date),
                weatherCondition: weatherCondition,
                temperatureMax: maxTemp,
                temperatureMin: minTemp,
                precipitation: avgPrecipitation
            )
        }
    }
}