import WidgetKit
import SwiftUI

// MARK: - Timeline Entry
struct WeatherEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
    let weatherData: WidgetWeatherData?
}

// MARK: - Widget Weather Data Model
struct WidgetWeatherData: Codable {
    let cityName: String
    let temperature: Double
    let temperatureMin: Double
    let temperatureMax: Double
    let weatherCondition: String
    let weatherDescription: String
    let humidity: Double
    let feelsLike: Double
    let lastUpdated: Date
}

// MARK: - Timeline Provider
struct WeatherProvider: IntentTimelineProvider {
    func placeholder(in context: Context) -> WeatherEntry {
        WeatherEntry(
            date: Date(),
            configuration: ConfigurationIntent(),
            weatherData: WidgetWeatherData(
                cityName: "北京",
                temperature: 25,
                temperatureMin: 18,
                temperatureMax: 28,
                weatherCondition: "sunny",
                weatherDescription: "晴",
                humidity: 45,
                feelsLike: 26,
                lastUpdated: Date()
            )
        )
    }
    
    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (WeatherEntry) -> ()) {
        let entry = WeatherEntry(
            date: Date(),
            configuration: configuration,
            weatherData: loadWeatherData()
        )
        completion(entry)
    }
    
    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [WeatherEntry] = []
        
        // 创建当前时间的条目
        let currentDate = Date()
        let weatherData = loadWeatherData()
        let entry = WeatherEntry(
            date: currentDate,
            configuration: configuration,
            weatherData: weatherData
        )
        entries.append(entry)
        
        // 每15分钟刷新一次
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: currentDate)!
        let timeline = Timeline(entries: entries, policy: .after(nextUpdate))
        
        completion(timeline)
    }
    
    // 从共享容器加载天气数据
    private func loadWeatherData() -> WidgetWeatherData? {
        guard let sharedDefaults = UserDefaults(suiteName: "group.com.weiweathers.weather") else {
            return nil
        }
        
        guard let data = sharedDefaults.data(forKey: "widget_weather_data"),
              let weatherData = try? JSONDecoder().decode(WidgetWeatherData.self, from: data) else {
            return nil
        }
        
        return weatherData
    }
}

// MARK: - Widget Views
struct WeatherWidgetEntryView : View {
    var entry: WeatherProvider.Entry
    @Environment(\.widgetFamily) var widgetFamily
    
    var body: some View {
        switch widgetFamily {
        case .systemSmall:
            SmallWeatherView(weatherData: entry.weatherData)
        case .systemMedium:
            MediumWeatherView(weatherData: entry.weatherData)
        case .systemLarge:
            LargeWeatherView(weatherData: entry.weatherData)
        case .systemExtraLarge:
            LargeWeatherView(weatherData: entry.weatherData)
        @unknown default:
            SmallWeatherView(weatherData: entry.weatherData)
        }
    }
}

// MARK: - Small Widget View
struct SmallWeatherView: View {
    let weatherData: WidgetWeatherData?
    
    var body: some View {
        if let data = weatherData {
            ZStack {
                LinearGradient(
                    colors: backgroundColors(for: data.weatherCondition),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: weatherIcon(for: data.weatherCondition))
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                        Spacer()
                    }
                    
                    Text(data.cityName)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                    
                    Spacer()
                    
                    Text("\(Int(data.temperature))°")
                        .font(.system(size: 36, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text(data.weatherDescription)
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.8))
                    
                    HStack(spacing: 8) {
                        Text("L: \(Int(data.temperatureMin))°")
                        Text("H: \(Int(data.temperatureMax))°")
                    }
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.7))
                }
                .padding()
            }
        } else {
            ZStack {
                LinearGradient(
                    colors: [Color(hex: "#4A90E2"), Color(hex: "#67B3F4")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                VStack {
                    Image(systemName: "cloud.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.white.opacity(0.5))
                    Text("暂无数据")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
        }
    }
    
    private func weatherIcon(for condition: String) -> String {
        switch condition.lowercased() {
        case "clear", "sunny":
            return "sun.max.fill"
        case "clouds", "cloudy":
            return "cloud.fill"
        case "rain", "rainy":
            return "cloud.rain.fill"
        case "snow", "snowy":
            return "cloud.snow.fill"
        case "thunderstorm":
            return "cloud.bolt.rain.fill"
        case "mist", "fog":
            return "cloud.fog.fill"
        default:
            return "cloud.fill"
        }
    }
    
    private func backgroundColors(for condition: String) -> [Color] {
        switch condition.lowercased() {
        case "clear", "sunny":
            return [Color(hex: "#4A90E2"), Color(hex: "#67B3F4")]
        case "clouds", "cloudy":
            return [Color(hex: "#757F9A"), Color(hex: "#D7DDE8")]
        case "rain", "rainy":
            return [Color(hex: "#4B79A1"), Color(hex: "#283E51")]
        case "snow", "snowy":
            return [Color(hex: "#E6DADA"), Color(hex: "#274046")]
        case "thunderstorm":
            return [Color(hex: "#373B44"), Color(hex: "#4286f4")]
        default:
            return [Color(hex: "#4A90E2"), Color(hex: "#67B3F4")]
        }
    }
}

// MARK: - Medium Widget View
struct MediumWeatherView: View {
    let weatherData: WidgetWeatherData?
    
    var body: some View {
        if let data = weatherData {
            ZStack {
                LinearGradient(
                    colors: backgroundColors(for: data.weatherCondition),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                HStack(spacing: 20) {
                    // 左侧：主要信息
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: weatherIcon(for: data.weatherCondition))
                                .font(.system(size: 28))
                                .foregroundColor(.white)
                            Text(data.cityName)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white.opacity(0.9))
                        }
                        
                        Text("\(Int(data.temperature))°")
                            .font(.system(size: 48, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Text(data.weatherDescription)
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    Spacer()
                    
                    // 右侧：详细信息
                    VStack(alignment: .trailing, spacing: 12) {
                        HStack {
                            Image(systemName: "thermometer")
                                .font(.system(size: 14))
                            Text("体感 \(Int(data.feelsLike))°")
                                .font(.system(size: 14))
                        }
                        .foregroundColor(.white.opacity(0.8))
                        
                        HStack {
                            Image(systemName: "drop.fill")
                                .font(.system(size: 14))
                            Text("湿度 \(Int(data.humidity))%")
                                .font(.system(size: 14))
                        }
                        .foregroundColor(.white.opacity(0.8))
                        
                        HStack(spacing: 8) {
                            Text("L: \(Int(data.temperatureMin))°")
                            Text("H: \(Int(data.temperatureMax))°")
                        }
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                    }
                }
                .padding()
            }
        } else {
            PlaceholderView()
        }
    }
    
    private func weatherIcon(for condition: String) -> String {
        switch condition.lowercased() {
        case "clear", "sunny":
            return "sun.max.fill"
        case "clouds", "cloudy":
            return "cloud.fill"
        case "rain", "rainy":
            return "cloud.rain.fill"
        case "snow", "snowy":
            return "cloud.snow.fill"
        case "thunderstorm":
            return "cloud.bolt.rain.fill"
        case "mist", "fog":
            return "cloud.fog.fill"
        default:
            return "cloud.fill"
        }
    }
    
    private func backgroundColors(for condition: String) -> [Color] {
        switch condition.lowercased() {
        case "clear", "sunny":
            return [Color(hex: "#4A90E2"), Color(hex: "#67B3F4")]
        case "clouds", "cloudy":
            return [Color(hex: "#757F9A"), Color(hex: "#D7DDE8")]
        case "rain", "rainy":
            return [Color(hex: "#4B79A1"), Color(hex: "#283E51")]
        case "snow", "snowy":
            return [Color(hex: "#E6DADA"), Color(hex: "#274046")]
        case "thunderstorm":
            return [Color(hex: "#373B44"), Color(hex: "#4286f4")]
        default:
            return [Color(hex: "#4A90E2"), Color(hex: "#67B3F4")]
        }
    }
}

// MARK: - Large Widget View
struct LargeWeatherView: View {
    let weatherData: WidgetWeatherData?
    
    var body: some View {
        if let data = weatherData {
            ZStack {
                LinearGradient(
                    colors: backgroundColors(for: data.weatherCondition),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                VStack(alignment: .leading, spacing: 20) {
                    // 顶部：城市和天气图标
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(data.cityName)
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                            
                            Text(formattedDate())
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.7))
                        }
                        
                        Spacer()
                        
                        Image(systemName: weatherIcon(for: data.weatherCondition))
                            .font(.system(size: 40))
                            .foregroundColor(.white)
                    }
                    
                    // 中间：温度和描述
                    VStack(alignment: .leading, spacing: 8) {
                        Text("\(Int(data.temperature))°")
                            .font(.system(size: 72, weight: .thin))
                            .foregroundColor(.white)
                        
                        Text(data.weatherDescription)
                            .font(.system(size: 18))
                            .foregroundColor(.white.opacity(0.9))
                    }
                    
                    Spacer()
                    
                    // 底部：详细信息网格
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        DetailItem(
                            icon: "thermometer",
                            title: "体感温度",
                            value: "\(Int(data.feelsLike))°"
                        )
                        
                        DetailItem(
                            icon: "drop.fill",
                            title: "湿度",
                            value: "\(Int(data.humidity))%"
                        )
                        
                        DetailItem(
                            icon: "arrow.down",
                            title: "最低",
                            value: "\(Int(data.temperatureMin))°"
                        )
                        
                        DetailItem(
                            icon: "arrow.up",
                            title: "最高",
                            value: "\(Int(data.temperatureMax))°"
                        )
                    }
                    
                    // 更新时间
                    HStack {
                        Spacer()
                        Text("更新于 \(formattedUpdateTime(data.lastUpdated))")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.5))
                    }
                }
                .padding()
            }
        } else {
            PlaceholderView()
        }
    }
    
    private func weatherIcon(for condition: String) -> String {
        switch condition.lowercased() {
        case "clear", "sunny":
            return "sun.max.fill"
        case "clouds", "cloudy":
            return "cloud.fill"
        case "rain", "rainy":
            return "cloud.rain.fill"
        case "snow", "snowy":
            return "cloud.snow.fill"
        case "thunderstorm":
            return "cloud.bolt.rain.fill"
        case "mist", "fog":
            return "cloud.fog.fill"
        default:
            return "cloud.fill"
        }
    }
    
    private func backgroundColors(for condition: String) -> [Color] {
        switch condition.lowercased() {
        case "clear", "sunny":
            return [Color(hex: "#4A90E2"), Color(hex: "#67B3F4")]
        case "clouds", "cloudy":
            return [Color(hex: "#757F9A"), Color(hex: "#D7DDE8")]
        case "rain", "rainy":
            return [Color(hex: "#4B79A1"), Color(hex: "#283E51")]
        case "snow", "snowy":
            return [Color(hex: "#E6DADA"), Color(hex: "#274046")]
        case "thunderstorm":
            return [Color(hex: "#373B44"), Color(hex: "#4286f4")]
        default:
            return [Color(hex: "#4A90E2"), Color(hex: "#67B3F4")]
        }
    }
    
    private func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "M月d日 EEEE"
        return formatter.string(from: Date())
    }
    
    private func formattedUpdateTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

// MARK: - Detail Item View
struct DetailItem: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.white.opacity(0.7))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.6))
                Text(value)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
            }
            
            Spacer()
        }
    }
}

// MARK: - Placeholder View
struct PlaceholderView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "#4A90E2"), Color(hex: "#67B3F4")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            VStack(spacing: 16) {
                Image(systemName: "cloud.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.white.opacity(0.5))
                Text("打开应用以更新天气")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.7))
            }
        }
    }
}

// MARK: - Main Widget
@main
struct WeatherWidget: Widget {
    let kind: String = "WeatherWidget"
    
    var body: some WidgetConfiguration {
        IntentConfiguration(
            kind: kind,
            intent: ConfigurationIntent.self,
            provider: WeatherProvider()
        ) { entry in
            WeatherWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("天气")
        .description("查看当前天气状况")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

// MARK: - Widget Preview
struct WeatherWidget_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            WeatherWidgetEntryView(entry: WeatherEntry(
                date: Date(),
                configuration: ConfigurationIntent(),
                weatherData: WidgetWeatherData(
                    cityName: "北京",
                    temperature: 25,
                    temperatureMin: 18,
                    temperatureMax: 28,
                    weatherCondition: "sunny",
                    weatherDescription: "晴",
                    humidity: 45,
                    feelsLike: 26,
                    lastUpdated: Date()
                )
            ))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
            
            WeatherWidgetEntryView(entry: WeatherEntry(
                date: Date(),
                configuration: ConfigurationIntent(),
                weatherData: WidgetWeatherData(
                    cityName: "上海",
                    temperature: 22,
                    temperatureMin: 19,
                    temperatureMax: 24,
                    weatherCondition: "cloudy",
                    weatherDescription: "多云",
                    humidity: 65,
                    feelsLike: 23,
                    lastUpdated: Date()
                )
            ))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
            
            WeatherWidgetEntryView(entry: WeatherEntry(
                date: Date(),
                configuration: ConfigurationIntent(),
                weatherData: WidgetWeatherData(
                    cityName: "深圳",
                    temperature: 28,
                    temperatureMin: 24,
                    temperatureMax: 31,
                    weatherCondition: "rainy",
                    weatherDescription: "小雨",
                    humidity: 78,
                    feelsLike: 30,
                    lastUpdated: Date()
                )
            ))
            .previewContext(WidgetPreviewContext(family: .systemLarge))
        }
    }
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}