import Foundation

// MARK: - 日出日落相关数据模型

struct SunTimes {
    let sunrise: Date
    let sunset: Date
    let solarNoon: Date
    let dayLength: TimeInterval
    
    // 黄金时刻（Golden Hour）- 日出后和日落前的一小时
    var morningGoldenHourStart: Date {
        return sunrise
    }
    
    var morningGoldenHourEnd: Date {
        return sunrise.addingTimeInterval(3600) // 日出后1小时
    }
    
    var eveningGoldenHourStart: Date {
        return sunset.addingTimeInterval(-3600) // 日落前1小时
    }
    
    var eveningGoldenHourEnd: Date {
        return sunset
    }
    
    // 蓝调时刻（Blue Hour）- 日出前和日落后的30分钟
    var morningBlueHourStart: Date {
        return sunrise.addingTimeInterval(-1800) // 日出前30分钟
    }
    
    var morningBlueHourEnd: Date {
        return sunrise
    }
    
    var eveningBlueHourStart: Date {
        return sunset
    }
    
    var eveningBlueHourEnd: Date {
        return sunset.addingTimeInterval(1800) // 日落后30分钟
    }
    
    // 当前太阳位置（0-1，0=日出，0.5=正午，1=日落）
    func currentSunPosition(at date: Date = Date()) -> Double? {
        guard date >= sunrise && date <= sunset else { return nil }
        
        let totalDaylight = sunset.timeIntervalSince(sunrise)
        let currentProgress = date.timeIntervalSince(sunrise)
        
        return currentProgress / totalDaylight
    }
    
    // 格式化日照时长
    var formattedDayLength: String {
        let hours = Int(dayLength) / 3600
        let minutes = (Int(dayLength) % 3600) / 60
        
        let languageCode = UserDefaults.standard.string(forKey: "appLanguage") ?? "zh_CN"
        if languageCode == "zh_CN" {
            return "\(hours)小时\(minutes)分钟"
        } else {
            return "\(hours)h \(minutes)m"
        }
    }
    
    // 检查当前是否在特殊时刻
    func isInGoldenHour(at date: Date = Date()) -> Bool {
        return (date >= morningGoldenHourStart && date <= morningGoldenHourEnd) ||
               (date >= eveningGoldenHourStart && date <= eveningGoldenHourEnd)
    }
    
    func isInBlueHour(at date: Date = Date()) -> Bool {
        return (date >= morningBlueHourStart && date <= morningBlueHourEnd) ||
               (date >= eveningBlueHourStart && date <= eveningBlueHourEnd)
    }
    
    // 下一个特殊时刻
    func nextSpecialMoment(from date: Date = Date()) -> (moment: SpecialMoment, time: Date)? {
        let moments: [(SpecialMoment, Date)] = [
            (.morningBlueHour, morningBlueHourStart),
            (.sunrise, sunrise),
            (.morningGoldenHour, morningGoldenHourStart),
            (.solarNoon, solarNoon),
            (.eveningGoldenHour, eveningGoldenHourStart),
            (.sunset, sunset),
            (.eveningBlueHour, eveningBlueHourStart)
        ]
        
        return moments.first { $0.1 > date }
    }
}

enum SpecialMoment {
    case morningBlueHour
    case sunrise
    case morningGoldenHour
    case solarNoon
    case eveningGoldenHour
    case sunset
    case eveningBlueHour
    
    var localizedName: String {
        switch self {
        case .morningBlueHour:
            return LocalizedText.get("morning_blue_hour")
        case .sunrise:
            return LocalizedText.get("sunrise")
        case .morningGoldenHour:
            return LocalizedText.get("morning_golden_hour")
        case .solarNoon:
            return LocalizedText.get("solar_noon")
        case .eveningGoldenHour:
            return LocalizedText.get("evening_golden_hour")
        case .sunset:
            return LocalizedText.get("sunset")
        case .eveningBlueHour:
            return LocalizedText.get("evening_blue_hour")
        }
    }
    
    var icon: String {
        switch self {
        case .morningBlueHour, .eveningBlueHour:
            return "moon.stars.fill"
        case .sunrise:
            return "sunrise.fill"
        case .morningGoldenHour, .eveningGoldenHour:
            return "camera.fill"
        case .solarNoon:
            return "sun.max.fill"
        case .sunset:
            return "sunset.fill"
        }
    }
    
    var notificationMessage: String {
        switch self {
        case .morningBlueHour, .eveningBlueHour:
            return LocalizedText.get("blue_hour_notification")
        case .sunrise:
            return LocalizedText.get("sunrise_notification")
        case .morningGoldenHour, .eveningGoldenHour:
            return LocalizedText.get("golden_hour_notification")
        case .solarNoon:
            return LocalizedText.get("solar_noon_notification")
        case .sunset:
            return LocalizedText.get("sunset_notification")
        }
    }
}

