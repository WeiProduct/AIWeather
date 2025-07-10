import Foundation

// MARK: - 穿衣建议相关数据模型

struct ClothingAdvice {
    let temperature: Double
    let feelsLike: Double
    let windSpeed: Double
    let humidity: Double
    let precipitation: Double
    let uvIndex: Int
    let weatherCondition: WeatherCondition
    
    // 用户偏好
    var stylePreference: StylePreference = .casual
    var coldSensitivity: ColdSensitivity = .normal
    
    // 温度范围
    var temperatureMin: Double
    var temperatureMax: Double
    
    // 获取穿衣建议
    func getRecommendations() -> ClothingRecommendation {
        let adjustedTemp = calculateAdjustedTemperature()
        let tempCategory = getTemperatureCategory(adjustedTemp)
        
        var recommendation = ClothingRecommendation()
        
        // 基础服装建议 - 根据风格偏好调整
        switch tempCategory {
        case .freezing:
            switch stylePreference {
            case .casual:
                recommendation.upperBody = [.downJacket, .thermalUnderwear, .sweater]
                recommendation.lowerBody = [.thermalPants, .jeans]
            case .formal:
                recommendation.upperBody = [.winterCoat, .thermalUnderwear, .sweater]
                recommendation.lowerBody = [.thermalPants, .warmPants]
            case .sporty:
                recommendation.upperBody = [.downJacket, .thermalUnderwear]
                recommendation.lowerBody = [.thermalPants, .warmPants]
            }
            recommendation.accessories = [.scarf, .gloves, .beanie]
            
        case .cold:
            switch stylePreference {
            case .casual:
                recommendation.upperBody = [.winterCoat, .sweater, .longSleeveShirt]
                recommendation.lowerBody = [.jeans, .warmPants]
            case .formal:
                recommendation.upperBody = [.winterCoat, .sweater, .longSleeveShirt]
                recommendation.lowerBody = [.warmPants]
            case .sporty:
                recommendation.upperBody = [.jacket, .sweater]
                recommendation.lowerBody = [.warmPants]
            }
            recommendation.accessories = [.scarf]
            
        case .cool:
            switch stylePreference {
            case .casual:
                recommendation.upperBody = [.jacket, .longSleeveShirt]
                recommendation.lowerBody = [.jeans, .casualPants]
            case .formal:
                recommendation.upperBody = [.lightJacket, .longSleeveShirt]
                recommendation.lowerBody = [.casualPants]
            case .sporty:
                recommendation.upperBody = [.windbreaker, .longSleeveShirt]
                recommendation.lowerBody = [.casualPants]
            }
            
        case .comfortable:
            switch stylePreference {
            case .casual:
                recommendation.upperBody = [.lightJacket, .tShirt]
                recommendation.lowerBody = [.jeans, .casualPants]
            case .formal:
                recommendation.upperBody = [.lightJacket, .shortSleeveShirt]
                recommendation.lowerBody = [.casualPants]
            case .sporty:
                recommendation.upperBody = [.tShirt]
                recommendation.lowerBody = [.shorts, .casualPants]
            }
            
        case .warm:
            switch stylePreference {
            case .casual:
                recommendation.upperBody = [.tShirt, .shortSleeveShirt]
                recommendation.lowerBody = [.shorts, .lightPants]
            case .formal:
                recommendation.upperBody = [.shortSleeveShirt]
                recommendation.lowerBody = [.lightPants]
            case .sporty:
                recommendation.upperBody = [.tShirt, .tank]
                recommendation.lowerBody = [.shorts]
            }
            
        case .hot:
            switch stylePreference {
            case .casual:
                recommendation.upperBody = [.tShirt, .tank]
                recommendation.lowerBody = [.shorts]
            case .formal:
                recommendation.upperBody = [.shortSleeveShirt]
                recommendation.lowerBody = [.lightPants]
            case .sporty:
                recommendation.upperBody = [.tank]
                recommendation.lowerBody = [.shorts]
            }
            recommendation.accessories = [.sunglasses, .cap]
        }
        
        // 特殊条件调整
        if precipitation > 50 {
            recommendation.accessories.append(.umbrella)
            recommendation.footwear = .waterproofShoes
        } else {
            // 根据温度和风格选择鞋子
            switch stylePreference {
            case .casual:
                recommendation.footwear = tempCategory.rawValue < 15 ? .boots : .sneakers
            case .formal:
                recommendation.footwear = tempCategory.rawValue < 25 ? .boots : .sneakers
            case .sporty:
                recommendation.footwear = tempCategory.rawValue < 30 ? .sneakers : .sandals
            }
        }
        
        if uvIndex > 6 {
            recommendation.accessories.append(.sunscreen)
            recommendation.accessories.append(.sunglasses)
        }
        
        if windSpeed > 20 {
            recommendation.accessories.append(.windbreaker)
            recommendation.avoidItems.append(LocalizedText.get("avoid_skirts"))
        }
        
        if humidity > 80 {
            recommendation.materialSuggestion = LocalizedText.get("breathable_materials")
        }
        
        // 生成建议文本
        recommendation.summary = generateSummary(for: tempCategory)
        recommendation.tips = generateTips(adjustedTemp: adjustedTemp)
        
        return recommendation
    }
    
    // 计算体感温度
    private func calculateAdjustedTemperature() -> Double {
        var adjusted = feelsLike
        
        // 风寒效应
        if windSpeed > 10 {
            adjusted -= (windSpeed - 10) * 0.2
        }
        
        // 湿度调整
        if humidity > 70 && temperature > 20 {
            adjusted += 2 // 湿热感觉更热
        }
        
        // 个人偏好调整
        switch coldSensitivity {
        case .veryCold:
            adjusted -= 3
        case .cold:
            adjusted -= 1.5
        case .normal:
            break
        case .warm:
            adjusted += 1.5
        case .veryWarm:
            adjusted += 3
        }
        
        return adjusted
    }
    
    private func getTemperatureCategory(_ temp: Double) -> TemperatureCategory {
        switch temp {
        case ..<(-10):
            return .freezing
        case -10..<5:
            return .cold
        case 5..<15:
            return .cool
        case 15..<25:
            return .comfortable
        case 25..<30:
            return .warm
        default:
            return .hot
        }
    }
    
    private func generateSummary(for category: TemperatureCategory) -> String {
        switch category {
        case .freezing:
            return LocalizedText.get("clothing_freezing")
        case .cold:
            return LocalizedText.get("clothing_cold")
        case .cool:
            return LocalizedText.get("clothing_cool")
        case .comfortable:
            return LocalizedText.get("clothing_comfortable")
        case .warm:
            return LocalizedText.get("clothing_warm")
        case .hot:
            return LocalizedText.get("clothing_hot")
        }
    }
    
    private func generateTips(adjustedTemp: Double) -> [String] {
        var tips: [String] = []
        
        // 温差提醒
        if abs(temperatureMax - temperatureMin) > 10 {
            tips.append(LocalizedText.get("large_temp_difference"))
        }
        
        // 天气状况提醒
        switch weatherCondition {
        case .rainy:
            tips.append(LocalizedText.get("rainy_day_tip"))
        case .snowy:
            tips.append(LocalizedText.get("snowy_day_tip"))
        case .foggy:
            tips.append(LocalizedText.get("foggy_day_tip"))
        default:
            break
        }
        
        return tips
    }
}

// MARK: - 支持类型

enum TemperatureCategory: Double {
    case freezing = -20
    case cold = 0
    case cool = 10
    case comfortable = 20
    case warm = 25
    case hot = 30
}

enum StylePreference: String, CaseIterable {
    case casual = "casual"
    case formal = "formal"
    case sporty = "sporty"
    
    var displayName: String {
        switch self {
        case .casual:
            return LocalizedText.get("style_casual")
        case .formal:
            return LocalizedText.get("style_formal")
        case .sporty:
            return LocalizedText.get("style_sporty")
        }
    }
}

enum ColdSensitivity: Int, CaseIterable {
    case veryCold = 1
    case cold = 2
    case normal = 3
    case warm = 4
    case veryWarm = 5
    
    var displayName: String {
        switch self {
        case .veryCold:
            return LocalizedText.get("very_cold_sensitive")
        case .cold:
            return LocalizedText.get("cold_sensitive")
        case .normal:
            return LocalizedText.get("normal_sensitive")
        case .warm:
            return LocalizedText.get("warm_sensitive")
        case .veryWarm:
            return LocalizedText.get("very_warm_sensitive")
        }
    }
}

// MARK: - 服装类型

enum ClothingItem {
    // 上装
    case downJacket
    case winterCoat
    case jacket
    case lightJacket
    case windbreaker
    case sweater
    case longSleeveShirt
    case shortSleeveShirt
    case tShirt
    case tank
    case thermalUnderwear
    
    // 下装
    case thermalPants
    case jeans
    case warmPants
    case casualPants
    case lightPants
    case shorts
    
    // 配饰
    case scarf
    case gloves
    case beanie
    case cap
    case sunglasses
    case umbrella
    case sunscreen
    
    // 鞋子
    case boots
    case sneakers
    case waterproofShoes
    case sandals
    
    var localizedName: String {
        switch self {
        case .downJacket:
            return LocalizedText.get("down_jacket")
        case .winterCoat:
            return LocalizedText.get("winter_coat")
        case .jacket:
            return LocalizedText.get("jacket")
        case .lightJacket:
            return LocalizedText.get("light_jacket")
        case .windbreaker:
            return LocalizedText.get("windbreaker")
        case .sweater:
            return LocalizedText.get("sweater")
        case .longSleeveShirt:
            return LocalizedText.get("long_sleeve_shirt")
        case .shortSleeveShirt:
            return LocalizedText.get("short_sleeve_shirt")
        case .tShirt:
            return LocalizedText.get("t_shirt")
        case .tank:
            return LocalizedText.get("tank_top")
        case .thermalUnderwear:
            return LocalizedText.get("thermal_underwear")
        case .thermalPants:
            return LocalizedText.get("thermal_pants")
        case .jeans:
            return LocalizedText.get("jeans")
        case .warmPants:
            return LocalizedText.get("warm_pants")
        case .casualPants:
            return LocalizedText.get("casual_pants")
        case .lightPants:
            return LocalizedText.get("light_pants")
        case .shorts:
            return LocalizedText.get("shorts")
        case .scarf:
            return LocalizedText.get("scarf")
        case .gloves:
            return LocalizedText.get("gloves")
        case .beanie:
            return LocalizedText.get("beanie")
        case .cap:
            return LocalizedText.get("cap")
        case .sunglasses:
            return LocalizedText.get("sunglasses")
        case .umbrella:
            return LocalizedText.get("umbrella")
        case .sunscreen:
            return LocalizedText.get("sunscreen")
        case .boots:
            return LocalizedText.get("boots")
        case .sneakers:
            return LocalizedText.get("sneakers")
        case .waterproofShoes:
            return LocalizedText.get("waterproof_shoes")
        case .sandals:
            return LocalizedText.get("sandals")
        }
    }
    
    var icon: String {
        switch self {
        case .umbrella:
            return "umbrella.fill"
        case .sunglasses:
            return "sunglasses.fill"
        case .sunscreen:
            return "sun.max.fill"
        default:
            return "tshirt.fill"
        }
    }
}

// MARK: - 穿衣建议结果

struct ClothingRecommendation {
    var upperBody: [ClothingItem] = []
    var lowerBody: [ClothingItem] = []
    var footwear: ClothingItem = .sneakers
    var accessories: [ClothingItem] = []
    var avoidItems: [String] = []
    var materialSuggestion: String = ""
    var summary: String = ""
    var tips: [String] = []
}