import Foundation

// MARK: - 趋势数据点
struct TrendDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
    let label: String
}

// MARK: - 趋势数据系列
struct TrendSeries {
    let name: String
    let dataPoints: [TrendDataPoint]
    let color: String // Hex color
    let unit: String
}

// MARK: - 图表类型
enum ChartType: String, CaseIterable {
    case temperature = "temperature"
    case humidity = "humidity"
    case precipitation = "precipitation"
    case wind = "wind"
    
    var displayName: String {
        switch self {
        case .temperature:
            return LocalizedText.get("temperature")
        case .humidity:
            return LocalizedText.get("humidity")
        case .precipitation:
            return LocalizedText.get("precipitation")
        case .wind:
            return LocalizedText.get("wind_speed")
        }
    }
    
    var icon: String {
        switch self {
        case .temperature:
            return "thermometer"
        case .humidity:
            return "drop.fill"
        case .precipitation:
            return "cloud.rain.fill"
        case .wind:
            return "wind"
        }
    }
    
    var unit: String {
        switch self {
        case .temperature:
            return "°C"
        case .humidity:
            return "%"
        case .precipitation:
            return "%"
        case .wind:
            return "km/h"
        }
    }
    
    var colors: [String] {
        switch self {
        case .temperature:
            return ["#FF6B6B", "#FFE66D"] // 红到黄
        case .humidity:
            return ["#4ECDC4", "#45B7D1"] // 青到蓝
        case .precipitation:
            return ["#667EEA", "#764BA2"] // 紫到深紫
        case .wind:
            return ["#20E3B2", "#29FCCA"] // 绿到浅绿
        }
    }
}

// MARK: - 时间范围
enum TimeRange: String, CaseIterable {
    case day = "24h"
    case twoDays = "48h"
    case week = "7d"
    
    var displayName: String {
        switch self {
        case .day:
            return LocalizedText.get("24_hours")
        case .twoDays:
            return LocalizedText.get("48_hours")
        case .week:
            return LocalizedText.get("7_days")
        }
    }
    
    var hours: Int {
        switch self {
        case .day:
            return 24
        case .twoDays:
            return 48
        case .week:
            return 168
        }
    }
}

// MARK: - 趋势数据生成器
class TrendDataGenerator {
    
    // 从预报数据生成趋势数据
    static func generateTrendData(from forecast: [ForecastItem], type: ChartType, range: TimeRange) -> TrendSeries {
        let endDate = Date().addingTimeInterval(TimeInterval(range.hours * 3600))
        
        // 过滤在时间范围内的数据
        let filteredItems = forecast.filter { item in
            let itemDate = Date(timeIntervalSince1970: TimeInterval(item.dt))
            return itemDate <= endDate
        }.prefix(range.hours / 3) // 预报数据每3小时一个点
        
        let dataPoints = filteredItems.map { item -> TrendDataPoint in
            let date = Date(timeIntervalSince1970: TimeInterval(item.dt))
            let value: Double
            
            switch type {
            case .temperature:
                value = item.main.temp
            case .humidity:
                value = Double(item.main.humidity)
            case .precipitation:
                value = item.pop * 100
            case .wind:
                value = item.wind.speed * 3.6 // 转换为 km/h
            }
            
            let formatter = DateFormatter()
            formatter.dateFormat = range == .week ? "MM/dd" : "HH:mm"
            let label = formatter.string(from: date)
            
            return TrendDataPoint(date: date, value: value, label: label)
        }
        
        return TrendSeries(
            name: type.displayName,
            dataPoints: Array(dataPoints),
            color: type.colors.first ?? "#000000",
            unit: type.unit
        )
    }
    
    // 获取值的范围（用于Y轴）
    static func getValueRange(for series: TrendSeries) -> (min: Double, max: Double) {
        let values = series.dataPoints.map { $0.value }
        let minValue = values.min() ?? 0
        let maxValue = values.max() ?? 100
        
        // 添加一些padding
        let padding = (maxValue - minValue) * 0.1
        return (minValue - padding, maxValue + padding)
    }
}