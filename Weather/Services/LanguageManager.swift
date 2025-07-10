import Foundation
import SwiftUI

// MARK: - 语言枚举
enum AppLanguage: String, CaseIterable {
    case chinese = "zh_CN"
    case english = "en_US"
    
    var displayName: String {
        switch self {
        case .chinese:
            return "中文"
        case .english:
            return "English"
        }
    }
    
    var apiCode: String {
        switch self {
        case .chinese:
            return "zh_cn"
        case .english:
            return "en"
        }
    }
}

// MARK: - 语言管理器
@MainActor
class LanguageManager: ObservableObject, LanguageServiceProtocol {
    static let shared = LanguageManager()
    
    @Published var currentLanguage: AppLanguage = .chinese
    
    private let userDefaults = UserDefaults.standard
    private let languageKey = "appLanguage"
    private let hasSelectedLanguageKey = "hasSelectedLanguage"
    
    init() {
        loadSavedLanguage()
    }
    
    func switchLanguage() {
        currentLanguage = currentLanguage == .chinese ? .english : .chinese
        saveLanguage()
    }
    
    func setLanguage(_ language: AppLanguage) {
        currentLanguage = language
        saveLanguage()
    }
    
    var hasSelectedLanguage: Bool {
        return userDefaults.bool(forKey: hasSelectedLanguageKey)
    }
    
    func markLanguageAsSelected() {
        userDefaults.set(true, forKey: hasSelectedLanguageKey)
    }
    
    private func saveLanguage() {
        userDefaults.set(currentLanguage.rawValue, forKey: languageKey)
        // Post notification when language changes
        NotificationCenter.default.post(name: .languageChanged, object: nil)
    }
    
    private func loadSavedLanguage() {
        if let savedLanguage = userDefaults.string(forKey: languageKey),
           let language = AppLanguage(rawValue: savedLanguage) {
            currentLanguage = language
        }
    }
}

// MARK: - 本地化文本
struct LocalizedText {
    static func get(_ key: String, language: AppLanguage? = nil) -> String {
        let lang = language ?? getCurrentLanguage()
        return texts[lang]?[key] ?? key
    }
    
    private static func getCurrentLanguage() -> AppLanguage {
        // Read from UserDefaults directly to avoid MainActor issues
        if let languageString = UserDefaults.standard.string(forKey: "appLanguage"),
           let language = AppLanguage(rawValue: languageString) {
            return language
        }
        return .chinese
    }
    
    private static let texts: [AppLanguage: [String: String]] = [
        .chinese: [
            // 通用
            "loading": "加载中...",
            "refresh": "刷新",
            "settings": "设置",
            "done": "完成",
            "cancel": "取消",
            "save": "保存",
            "back": "返回",
            
            // 主页面
            "weather_assistant": "天气助手",
            "start_using": "开始使用",
            "accurate_forecast": "精准预报，贴心陪伴",
            "24hour_forecast": "24小时预报",
            "details": "详情",
            "forecast": "预报",
            "cities": "城市",
            "no_weather_data": "暂无天气数据",
            
            // 天气指标
            "visibility": "能见度",
            "humidity": "湿度",
            "wind_speed": "风速",
            "feels_like": "体感温度",
            "uv_index": "紫外线指数",
            "pressure": "气压",
            "precipitation": "降水概率",
            
            // 城市管理
            "my_cities": "我的城市",
            "add_city": "添加城市",
            "search_city": "搜索并添加城市",
            "search_placeholder": "输入城市名称",
            "enable_location": "启用定位服务",
            "location_permission_desc": "允许访问位置以获取当前天气",
            "location_settings": "设置",
            
            // 设置页面
            "display_settings": "显示设置",
            "temperature_unit": "温度单位",
            "wind_speed_unit": "风速单位",
            "language": "语言",
            "notification_settings": "通知设置",
            "weather_alerts": "天气预警",
            "daily_reminders": "每日提醒",
            "location_settings_title": "位置设置",
            "auto_location": "自动定位",
            "other_settings": "其他设置",
            "about_us": "关于我们",
            
            // 天气详情
            "weather_details": "天气详情",
            "today_temperature": "今日温度变化",
            
            // 一周预报
            "weekly_forecast": "未来一周",
            "weekly_forecast_title": "一周预报",
            "today": "今天",
            "tomorrow": "明天",
            "monday": "周一",
            "tuesday": "周二",
            "wednesday": "周三",
            "thursday": "周四",
            "friday": "周五",
            "saturday": "周六",
            "sunday": "周日",
            
            // 天气条件
            "clear_sky": "晴空",
            "few_clouds": "少云",
            "scattered_clouds": "多云",
            "broken_clouds": "阴",
            "shower_rain": "阵雨",
            "rain": "雨",
            "thunderstorm": "雷雨",
            "snow": "雪",
            "mist": "雾",
            
            // 位置权限
            "location_permission_denied": "位置权限被拒绝",
            "location_permission_not_determined": "位置权限未设置",
            "location_permission_granted": "位置权限已授予",
            "go_to_settings": "前往设置",
            "search_and_add": "搜索并添加城市",
            "enter_city_name": "输入城市名称",
            "enable_location_service": "启用定位服务",
            "allow_location_access": "允许访问位置以获取当前天气",
            "latitude": "纬度",
            "longitude": "经度",
            
            // 欢迎页面
            "choose_language": "选择语言",
            "chinese": "中文",
            "english": "English",
            "your_weather_assistant": "您的专属天气管家",
            
            // 错误信息
            "error_invalid_url": "无效的URL地址",
            "error_no_data": "没有接收到数据",
            "error_parsing_data": "数据解析失败",
            "error_http": "HTTP错误",
            "error_no_network": "网络连接不可用",
            "error_timeout": "请求超时",
            "error_api_key_missing": "API密钥未配置",
            "error_unknown": "未知错误",
            "error_occurred": "出错了",
            "retry": "重试",
            "cloudy": "多云",
            
            // 温度单位
            "celsius": "摄氏度 °C",
            "fahrenheit": "华氏度 °F",
            
            // 风速单位
            "kmh": "公里/小时",
            "mph": "英里/小时",
            
            // 时间格式
            "hour_format": "%d时",
            
            // 位置权限状态
            "permission_not_determined": "未确定",
            "permission_restricted": "受限制",
            "permission_denied": "已拒绝",
            "permission_authorized_always": "始终允许",
            "permission_authorized_when_in_use": "使用时允许",
            "permission_unknown": "未知状态",
            
            // 城市名称
            "city_beijing": "北京市",
            "city_shanghai": "上海市",
            "city_guangzhou": "广州市",
            "city_shenzhen": "深圳市",
            "city_hangzhou": "杭州市",
            "city_chengdu": "成都市",
            "city_xian": "西安市",
            "city_nanjing": "南京市",
            "city_wuhan": "武汉市",
            "city_tianjin": "天津市",
            
            // 天气详情
            "feels_like_temp": "体感温度",
            "feels_like_subtitle": "感觉像是",
            "uv_index_title": "紫外线指数",
            "pressure_hpa": "气压 hPa",
            "standard_pressure": "标准气压",
            "precipitation_probability": "降水概率",
            "today_temperature_change": "今日温度变化",
            "current": "当前",
            "minimum": "最低",
            "maximum": "最高",
            "no_rain": "无雨",
            "light_rain": "小雨",
            "moderate_rain": "中雨",
            "heavy_rain": "大雨",
            "uv_low": "低",
            "uv_moderate": "中等",
            "uv_high": "高",
            "uv_very_high": "很高",
            "uv_extreme": "极高",
            
            // Notification Settings
            "notifications_disabled": "通知已禁用",
            "enable_notifications": "启用通知",
            "enable_notifications_desc": "启用通知以接收天气预警和每日提醒",
            "notification_permission_message": "需要在系统设置中启用通知权限",
            "view_details": "查看详情",
            "dismiss": "忽略",
            "view_forecast": "查看预报",
            
            // Weather Alerts
            "alert_severe_weather": "恶劣天气",
            "alert_temperature_change": "温度变化",
            "alert_precipitation": "降水概率",
            "alert_uv_index": "紫外线指数",
            "alert_air_quality": "空气质量",
            "severe_weather_desc": "接收暴雨、雷暴、大雪等恶劣天气预警",
            "temperature_change_desc": "当温度超出设定范围时接收提醒",
            "precipitation_alert_desc": "当降水概率超过设定值时接收提醒",
            "uv_alert_desc": "当紫外线指数过高时接收防晒提醒",
            "air_quality_desc": "当空气质量较差时接收健康提醒",
            "enable_alert": "启用预警",
            "configure_alert": "配置预警",
            "min_temperature": "最低温度",
            "max_temperature": "最高温度",
            "min_precipitation": "最低降水概率",
            "min_uv_index": "最低紫外线指数",
            "min_aqi": "最低空气质量指数",
            "preset_options": "预设选项",
            "preset_mild": "温和条件 (10-28°C)",
            "preset_moderate": "适中条件 (5-32°C)",
            "preset_extreme": "极端条件 (0-35°C)",
            "preset_light_rain": "小雨预警 (>30%)",
            "preset_moderate_rain": "中雨预警 (>50%)",
            "preset_heavy_rain": "大雨预警 (>70%)",
            "preset_moderate_uv": "中等紫外线 (>6)",
            "preset_high_uv": "高紫外线 (>8)",
            "preset_extreme_uv": "极高紫外线 (>11)",
            
            // Alert Messages
            "cold_weather_alert": "低温预警",
            "hot_weather_alert": "高温预警",
            "temperature_below_threshold": "%@温度降至%d°C，请注意保暖",
            "temperature_above_threshold": "%@温度升至%d°C，请注意防暑",
            "rain_alert": "降雨提醒",
            "precipitation_alert_body": "%@降水概率%d%%，记得带伞",
            "uv_alert": "紫外线预警",
            "uv_alert_body": "%@紫外线指数%d，请做好防晒",
            "severe_weather_alert": "恶劣天气预警",
            "severe_weather_body": "%@将有%@，请注意安全",
            
            // Daily Reminders
            "daily_weather_reminders": "每日天气提醒",
            "morning_reminder": "早晨提醒",
            "evening_reminder": "晚间提醒",
            "include_in_reminder": "提醒内容",
            "temperature_reminder": "温度",
            "air_quality": "空气质量",
            "include_weekly_outlook": "包含一周天气趋势",
            "include_clothing_suggestion": "包含穿衣建议",
            "daily_weather_title": "%@今日天气",
            "daily_temp_format": "温度: %d°C (最低%d° 最高%d°)",
            "daily_precip_format": "降水概率: %d%%",
            "daily_uv_format": "紫外线指数: %d",
            "bring_umbrella_reminder": "今天可能下雨，记得带伞",
            "wear_warm_clothes": "今天较冷，请注意保暖",
            "wear_light_clothes": "今天较热，建议穿着轻薄衣物",
            "wear_sunscreen": "紫外线较强，请做好防晒",
            "comfortable_weather": "今天天气舒适",
            
            // Quiet Hours
            "quiet_hours": "免打扰时段",
            "quiet_hours_desc": "在此时段内不会收到任何天气通知",
            "from": "从",
            "to": "至",
            "select_time": "选择时间",
            
            // 日出日落功能
            "sun_times": "日出日落",
            "sunrise": "日出",
            "sunset": "日落",
            "solar_noon": "正午",
            "photography_times": "摄影时刻",
            "morning_blue_hour": "晨间蓝调时刻",
            "morning_golden_hour": "晨间黄金时刻",
            "evening_golden_hour": "傍晚黄金时刻",
            "evening_blue_hour": "傍晚蓝调时刻",
            "golden_hour_now": "正处于黄金时刻",
            "blue_hour_notification": "蓝调时刻即将开始，适合拍摄",
            "sunrise_notification": "日出即将开始",
            "golden_hour_notification": "黄金时刻即将开始，最佳摄影光线",
            "solar_noon_notification": "正午时分",
            "sunset_notification": "日落即将开始",
            
            // 穿衣建议功能
            "clothing_advice": "穿衣建议",
            "upper_body": "上装",
            "lower_body": "下装",
            "footwear": "鞋子",
            "accessories": "配饰",
            "personal_preferences": "个人偏好",
            "style_preference": "穿衣风格",
            "cold_sensitivity": "温度敏感度",
            "detailed_advice": "详细建议",
            "weather_factors": "天气因素",
            "additional_tips": "额外提示",
            
            // 服装类型
            "down_jacket": "羽绒服",
            "winter_coat": "厚外套",
            "jacket": "外套",
            "light_jacket": "轻薄外套",
            "windbreaker": "防风衣",
            "sweater": "毛衣",
            "long_sleeve_shirt": "长袖衫",
            "short_sleeve_shirt": "短袖衫",
            "t_shirt": "T恤",
            "tank_top": "背心",
            "thermal_underwear": "保暖内衣",
            "thermal_pants": "保暖裤",
            "jeans": "牛仔裤",
            "warm_pants": "厚裤子",
            "casual_pants": "休闲裤",
            "light_pants": "薄裤子",
            "shorts": "短裤",
            "scarf": "围巾",
            "gloves": "手套",
            "beanie": "毛线帽",
            "cap": "鸭舌帽",
            "sunglasses": "太阳镜",
            "umbrella": "雨伞",
            "sunscreen": "防晒霜",
            "boots": "靴子",
            "sneakers": "运动鞋",
            "waterproof_shoes": "防水鞋",
            "sandals": "凉鞋",
            
            // 穿衣建议文案
            "clothing_freezing": "极寒天气，建议穿着羽绒服等厚重保暖衣物",
            "clothing_cold": "寒冷天气，建议穿着厚外套和毛衣",
            "clothing_cool": "凉爽天气，建议穿着外套或长袖",
            "clothing_comfortable": "舒适温度，轻薄外套即可",
            "clothing_warm": "温暖天气，T恤或短袖即可",
            "clothing_hot": "炎热天气，建议穿着轻薄透气的衣物",
            "large_temp_difference": "今日温差较大，建议层次穿搭",
            "rainy_day_tip": "雨天路滑，建议穿防水鞋",
            "snowy_day_tip": "雪天寒冷，注意保暖防滑",
            "foggy_day_tip": "能见度低，建议穿亮色衣物",
            
            // 风格偏好
            "style_casual": "休闲风格",
            "style_formal": "正式风格",
            "style_sporty": "运动风格",
            
            // 温度敏感度
            "very_cold_sensitive": "非常怕冷",
            "cold_sensitive": "比较怕冷",
            "normal_sensitive": "正常",
            "warm_sensitive": "比较怕热",
            "very_warm_sensitive": "非常怕热",
            
            // 功能板块设置
            "feature_modules": "功能板块",
            
            // 天气趋势图表
            "weather_trends": "天气趋势",
            "24_hours": "24小时",
            "48_hours": "48小时",
            "7_days": "7天",
            "chart_type": "图表类型",
            "time_range": "时间范围",
            "average": "平均",
            
            // 天气因素描述
            "temperature": "温度",
            "wind": "风力",
            "rain_chance": "降雨概率",
            "strong_wind": "风力较大",
            "light_wind": "微风",
            "high_humidity": "湿度较高",
            "comfortable_humidity": "湿度适中",
            "bring_umbrella": "建议携带雨伞",
            "avoid_skirts": "避免穿裙装",
            "breathable_materials": "建议选择透气材质"
        ],
        
        .english: [
            // Common
            "loading": "Loading...",
            "refresh": "Refresh",
            "settings": "Settings",
            "done": "Done",
            "cancel": "Cancel",
            "save": "Save",
            "back": "Back",
            
            // Main page
            "weather_assistant": "Weather Assistant",
            "start_using": "Get Started",
            "accurate_forecast": "Accurate forecast, caring companion",
            "24hour_forecast": "24-Hour Forecast",
            "details": "Details",
            "forecast": "Forecast",
            "cities": "Cities",
            "no_weather_data": "No weather data available",
            
            // Weather metrics
            "visibility": "Visibility",
            "humidity": "Humidity",
            "wind_speed": "Wind Speed",
            "feels_like": "Feels Like",
            "uv_index": "UV Index",
            "pressure": "Pressure",
            "precipitation": "Precipitation",
            
            // City management
            "my_cities": "My Cities",
            "add_city": "Add City",
            "search_city": "Search and add cities",
            "search_placeholder": "Enter city name",
            "enable_location": "Enable Location Services",
            "location_permission_desc": "Allow location access for current weather",
            "location_settings": "Settings",
            
            // Settings page
            "display_settings": "Display Settings",
            "temperature_unit": "Temperature Unit",
            "wind_speed_unit": "Wind Speed Unit",
            "language": "Language",
            "notification_settings": "Notification Settings",
            "weather_alerts": "Weather Alerts",
            "daily_reminders": "Daily Reminders",
            "location_settings_title": "Location Settings",
            "auto_location": "Auto Location",
            "other_settings": "Other Settings",
            "about_us": "About Us",
            
            // Weather details
            "weather_details": "Weather Details",
            "today_temperature": "Today's Temperature",
            
            // Weekly forecast
            "weekly_forecast": "7-Day Forecast",
            "weekly_forecast_title": "Weekly Forecast",
            "today": "Today",
            "tomorrow": "Tomorrow",
            "monday": "Monday",
            "tuesday": "Tuesday",
            "wednesday": "Wednesday",
            "thursday": "Thursday",
            "friday": "Friday",
            "saturday": "Saturday",
            "sunday": "Sunday",
            
            // Weather conditions
            "clear_sky": "Clear Sky",
            "few_clouds": "Few Clouds",
            "scattered_clouds": "Scattered Clouds",
            "broken_clouds": "Broken Clouds",
            "shower_rain": "Shower Rain",
            "rain": "Rain",
            "thunderstorm": "Thunderstorm",
            "snow": "Snow",
            "mist": "Mist",
            
            // Location permissions
            "location_permission_denied": "Location Permission Denied",
            "location_permission_not_determined": "Location Permission Not Set",
            "location_permission_granted": "Location Permission Granted",
            "go_to_settings": "Go to Settings",
            "search_and_add": "Search and add cities",
            "enter_city_name": "Enter city name",
            "enable_location_service": "Enable Location Service",
            "allow_location_access": "Allow location access for current weather",
            "latitude": "Latitude",
            "longitude": "Longitude",
            
            // Welcome page
            "choose_language": "Choose Language",
            "chinese": "中文",
            "english": "English",
            "your_weather_assistant": "Your personal weather assistant",
            
            // Error messages
            "error_invalid_url": "Invalid URL",
            "error_no_data": "No data received",
            "error_parsing_data": "Failed to parse data",
            "error_http": "HTTP Error",
            "error_no_network": "Network unavailable",
            "error_timeout": "Request timeout",
            "error_api_key_missing": "API key not configured",
            "error_unknown": "Unknown error",
            "error_occurred": "Error occurred",
            "retry": "Retry",
            "cloudy": "Cloudy",
            
            // Temperature units
            "celsius": "Celsius °C",
            "fahrenheit": "Fahrenheit °F",
            
            // Wind speed units
            "kmh": "km/h",
            "mph": "mph",
            
            // Time format
            "hour_format": "%d %@",
            
            // Location permission status
            "permission_not_determined": "Not Determined",
            "permission_restricted": "Restricted",
            "permission_denied": "Denied",
            "permission_authorized_always": "Always Allowed",
            "permission_authorized_when_in_use": "When In Use",
            "permission_unknown": "Unknown",
            
            // City names
            "city_beijing": "Beijing",
            "city_shanghai": "Shanghai",
            "city_guangzhou": "Guangzhou",
            "city_shenzhen": "Shenzhen",
            "city_hangzhou": "Hangzhou",
            "city_chengdu": "Chengdu",
            "city_xian": "Xi'an",
            "city_nanjing": "Nanjing",
            "city_wuhan": "Wuhan",
            "city_tianjin": "Tianjin",
            
            // Weather details
            "feels_like_temp": "Feels Like",
            "feels_like_subtitle": "Feels like",
            "uv_index_title": "UV Index",
            "pressure_hpa": "Pressure hPa",
            "standard_pressure": "Standard",
            "precipitation_probability": "Precipitation",
            "today_temperature_change": "Today's Temperature",
            "current": "Current",
            "minimum": "Min",
            "maximum": "Max",
            "no_rain": "No rain",
            "light_rain": "Light rain",
            "moderate_rain": "Moderate rain",
            "heavy_rain": "Heavy rain",
            "uv_low": "Low",
            "uv_moderate": "Moderate",
            "uv_high": "High",
            "uv_very_high": "Very High",
            "uv_extreme": "Extreme",
            
            // Notification Settings
            "notifications_disabled": "Notifications Disabled",
            "enable_notifications": "Enable Notifications",
            "enable_notifications_desc": "Enable notifications to receive weather alerts and daily reminders",
            "notification_permission_message": "Notification permission needs to be enabled in system settings",
            "view_details": "View Details",
            "dismiss": "Dismiss",
            "view_forecast": "View Forecast",
            
            // Weather Alerts
            "alert_severe_weather": "Severe Weather",
            "alert_temperature_change": "Temperature Change",
            "alert_precipitation": "Precipitation",
            "alert_uv_index": "UV Index",
            "alert_air_quality": "Air Quality",
            "severe_weather_desc": "Receive alerts for storms, thunderstorms, heavy snow and other severe weather",
            "temperature_change_desc": "Get notified when temperature exceeds set thresholds",
            "precipitation_alert_desc": "Receive alerts when precipitation probability exceeds threshold",
            "uv_alert_desc": "Get sun protection reminders when UV index is high",
            "air_quality_desc": "Receive health alerts when air quality is poor",
            "enable_alert": "Enable Alert",
            "configure_alert": "Configure Alert",
            "min_temperature": "Minimum Temperature",
            "max_temperature": "Maximum Temperature",
            "min_precipitation": "Minimum Precipitation",
            "min_uv_index": "Minimum UV Index",
            "min_aqi": "Minimum AQI",
            "preset_options": "Preset Options",
            "preset_mild": "Mild Conditions (10-28°C)",
            "preset_moderate": "Moderate Conditions (5-32°C)",
            "preset_extreme": "Extreme Conditions (0-35°C)",
            "preset_light_rain": "Light Rain Alert (>30%)",
            "preset_moderate_rain": "Moderate Rain Alert (>50%)",
            "preset_heavy_rain": "Heavy Rain Alert (>70%)",
            "preset_moderate_uv": "Moderate UV (>6)",
            "preset_high_uv": "High UV (>8)",
            "preset_extreme_uv": "Extreme UV (>11)",
            
            // Alert Messages
            "cold_weather_alert": "Cold Weather Alert",
            "hot_weather_alert": "Hot Weather Alert",
            "temperature_below_threshold": "%@ temperature dropped to %d°C, stay warm",
            "temperature_above_threshold": "%@ temperature reached %d°C, stay cool",
            "rain_alert": "Rain Alert",
            "precipitation_alert_body": "%@ has %d%% chance of rain, bring an umbrella",
            "uv_alert": "UV Alert",
            "uv_alert_body": "%@ UV index is %d, use sun protection",
            "severe_weather_alert": "Severe Weather Alert",
            "severe_weather_body": "%@ will have %@, stay safe",
            
            // Daily Reminders
            "daily_weather_reminders": "Daily Weather Reminders",
            "morning_reminder": "Morning Reminder",
            "evening_reminder": "Evening Reminder",
            "include_in_reminder": "Include in Reminder",
            "temperature_reminder": "Temperature",
            "air_quality": "Air Quality",
            "include_weekly_outlook": "Include weekly weather trend",
            "include_clothing_suggestion": "Include clothing suggestions",
            "daily_weather_title": "%@ Today's Weather",
            "daily_temp_format": "Temperature: %d°C (Low %d° High %d°)",
            "daily_precip_format": "Precipitation: %d%%",
            "daily_uv_format": "UV Index: %d",
            "bring_umbrella_reminder": "Rain expected today, bring an umbrella",
            "wear_warm_clothes": "Cold today, dress warmly",
            "wear_light_clothes": "Hot today, wear light clothing",
            "wear_sunscreen": "High UV, use sunscreen",
            "comfortable_weather": "Comfortable weather today",
            
            // Quiet Hours
            "quiet_hours": "Quiet Hours",
            "quiet_hours_desc": "No weather notifications during this period",
            "from": "From",
            "to": "To",
            "select_time": "Select Time",
            
            // Sun times features
            "sun_times": "Sun Times",
            "sunrise": "Sunrise",
            "sunset": "Sunset",
            "solar_noon": "Solar Noon",
            "photography_times": "Photography Times",
            "morning_blue_hour": "Morning Blue Hour",
            "morning_golden_hour": "Morning Golden Hour",
            "evening_golden_hour": "Evening Golden Hour",
            "evening_blue_hour": "Evening Blue Hour",
            "golden_hour_now": "Currently in Golden Hour",
            "blue_hour_notification": "Blue hour is starting, great for photography",
            "sunrise_notification": "Sunrise is beginning",
            "golden_hour_notification": "Golden hour is starting, best light for photos",
            "solar_noon_notification": "Solar noon",
            "sunset_notification": "Sunset is beginning",
            
            // Clothing advice features
            "clothing_advice": "Clothing Advice",
            "upper_body": "Upper Body",
            "lower_body": "Lower Body",
            "footwear": "Footwear",
            "accessories": "Accessories",
            "personal_preferences": "Personal Preferences",
            "style_preference": "Style Preference",
            "cold_sensitivity": "Temperature Sensitivity",
            "detailed_advice": "Detailed Advice",
            "weather_factors": "Weather Factors",
            "additional_tips": "Additional Tips",
            
            // Clothing types
            "down_jacket": "Down Jacket",
            "winter_coat": "Winter Coat",
            "jacket": "Jacket",
            "light_jacket": "Light Jacket",
            "windbreaker": "Windbreaker",
            "sweater": "Sweater",
            "long_sleeve_shirt": "Long Sleeve Shirt",
            "short_sleeve_shirt": "Short Sleeve Shirt",
            "t_shirt": "T-Shirt",
            "tank_top": "Tank Top",
            "thermal_underwear": "Thermal Underwear",
            "thermal_pants": "Thermal Pants",
            "jeans": "Jeans",
            "warm_pants": "Warm Pants",
            "casual_pants": "Casual Pants",
            "light_pants": "Light Pants",
            "shorts": "Shorts",
            "scarf": "Scarf",
            "gloves": "Gloves",
            "beanie": "Beanie",
            "cap": "Cap",
            "sunglasses": "Sunglasses",
            "umbrella": "Umbrella",
            "sunscreen": "Sunscreen",
            "boots": "Boots",
            "sneakers": "Sneakers",
            "waterproof_shoes": "Waterproof Shoes",
            "sandals": "Sandals",
            
            // Clothing advice texts
            "clothing_freezing": "Freezing weather, wear heavy winter clothing",
            "clothing_cold": "Cold weather, wear warm coat and sweater",
            "clothing_cool": "Cool weather, jacket or long sleeves recommended",
            "clothing_comfortable": "Comfortable temperature, light jacket sufficient",
            "clothing_warm": "Warm weather, T-shirt or short sleeves",
            "clothing_hot": "Hot weather, wear light breathable clothing",
            "large_temp_difference": "Large temperature variation, layer your clothing",
            "rainy_day_tip": "Rainy and slippery, wear waterproof shoes",
            "snowy_day_tip": "Cold and snowy, stay warm and wear non-slip shoes",
            "foggy_day_tip": "Low visibility, wear bright colors",
            
            // Style preferences
            "style_casual": "Casual Style",
            "style_formal": "Formal Style",
            "style_sporty": "Sporty Style",
            
            // Temperature sensitivity
            "very_cold_sensitive": "Very Cold Sensitive",
            "cold_sensitive": "Cold Sensitive",
            "normal_sensitive": "Normal",
            "warm_sensitive": "Warm Sensitive",
            "very_warm_sensitive": "Very Warm Sensitive",
            
            // Feature modules settings
            "feature_modules": "Feature Modules",
            
            // Weather trends chart
            "weather_trends": "Weather Trends",
            "24_hours": "24 Hours",
            "48_hours": "48 Hours",
            "7_days": "7 Days",
            "chart_type": "Chart Type",
            "time_range": "Time Range",
            "average": "Average",
            
            // Weather factor descriptions
            "temperature": "Temperature",
            "wind": "Wind",
            "rain_chance": "Rain Chance",
            "strong_wind": "Strong Wind",
            "light_wind": "Light Breeze",
            "high_humidity": "High Humidity",
            "comfortable_humidity": "Comfortable Humidity",
            "bring_umbrella": "Bring an umbrella",
            "avoid_skirts": "Avoid wearing skirts",
            "breathable_materials": "Choose breathable materials"
        ]
    ]
}

// MARK: - Notification Extension
extension Notification.Name {
    static let languageChanged = Notification.Name("languageChanged")
} 