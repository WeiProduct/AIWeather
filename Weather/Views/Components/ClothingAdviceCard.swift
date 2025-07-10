import SwiftUI

struct ClothingAdviceCard: View {
    let weather: WeatherData
    @State private var showingFullAdvice = false
    @State private var isExpanded: Bool = false
    @State private var stylePreference: StylePreference = {
        if let saved = UserDefaults.standard.string(forKey: "clothing_style_preference"),
           let preference = StylePreference(rawValue: saved) {
            return preference
        }
        return .casual
    }()
    @State private var coldSensitivity: ColdSensitivity = {
        let saved = UserDefaults.standard.integer(forKey: "cold_sensitivity")
        return ColdSensitivity(rawValue: saved) ?? .normal
    }()
    
    private var clothingAdvice: ClothingRecommendation {
        var advice = ClothingAdvice(
            temperature: weather.temperature,
            feelsLike: weather.feelsLike,
            windSpeed: weather.windSpeed,
            humidity: weather.humidity,
            precipitation: weather.precipitation,
            uvIndex: weather.uvIndex,
            weatherCondition: weather.weatherCondition,
            temperatureMin: weather.temperatureMin,
            temperatureMax: weather.temperatureMax
        )
        advice.stylePreference = stylePreference
        advice.coldSensitivity = coldSensitivity
        return advice.getRecommendations()
    }
    
    var body: some View {
        VStack(spacing: 15) {
            // 标题栏
            HStack {
                Image(systemName: "tshirt.fill")
                    .font(.system(size: 16))
                Text(LocalizedText.get("clothing_advice"))
                    .font(.system(size: 16, weight: .medium))
                Spacer()
                Button(action: {
                    showingFullAdvice = true
                }) {
                    Image(systemName: "arrow.up.left.and.arrow.down.right")
                        .font(.system(size: 14))
                }
                
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isExpanded.toggle()
                    }
                }) {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            .foregroundColor(.white)
            
            if isExpanded {
                // 快速建议
                VStack(alignment: .leading, spacing: 12) {
                    // 主要建议
                    Text(clothingAdvice.summary)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    // 服装项目
                    VStack(alignment: .leading, spacing: 8) {
                        // 上装
                        if !clothingAdvice.upperBody.isEmpty {
                            ClothingRow(
                                icon: "tshirt.fill",
                                label: LocalizedText.get("upper_body"),
                                items: clothingAdvice.upperBody.map { $0.localizedName }
                            )
                        }
                        
                        // 下装
                        if !clothingAdvice.lowerBody.isEmpty {
                            ClothingRow(
                                icon: "figure.stand",
                                label: LocalizedText.get("lower_body"),
                                items: clothingAdvice.lowerBody.map { $0.localizedName }
                            )
                        }
                        
                        // 配饰
                        if !clothingAdvice.accessories.isEmpty {
                            ClothingRow(
                                icon: "umbrella.fill",
                                label: LocalizedText.get("accessories"),
                                items: clothingAdvice.accessories.map { $0.localizedName }
                            )
                        }
                    }
                    
                    // 特别提示
                    if !clothingAdvice.tips.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            ForEach(clothingAdvice.tips, id: \.self) { tip in
                                HStack(alignment: .top, spacing: 6) {
                                    Image(systemName: "info.circle.fill")
                                        .font(.system(size: 10))
                                        .foregroundColor(.yellow.opacity(0.8))
                                        .padding(.top, 2)
                                    Text(tip)
                                        .font(.system(size: 12))
                                        .foregroundColor(.white.opacity(0.8))
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                        }
                        .padding(.top, 4)
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.15))
        )
        .sheet(isPresented: $showingFullAdvice) {
            ClothingAdviceDetailView(
                weather: weather,
                stylePreference: $stylePreference,
                coldSensitivity: $coldSensitivity
            )
        }
    }
}

// MARK: - 服装行组件
struct ClothingRow: View {
    let icon: String
    let label: String
    let items: [String]
    
    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.7))
                .frame(width: 16)
            
            Text(label + ":")
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.7))
                .frame(width: 50, alignment: .leading)
            
            Text(items.joined(separator: " + "))
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white.opacity(0.9))
                .lineLimit(1)
        }
    }
}

// MARK: - 详细建议视图
struct ClothingAdviceDetailView: View {
    let weather: WeatherData
    @Binding var stylePreference: StylePreference
    @Binding var coldSensitivity: ColdSensitivity
    @Environment(\.dismiss) var dismiss
    
    private var clothingAdvice: ClothingRecommendation {
        var advice = ClothingAdvice(
            temperature: weather.temperature,
            feelsLike: weather.feelsLike,
            windSpeed: weather.windSpeed,
            humidity: weather.humidity,
            precipitation: weather.precipitation,
            uvIndex: weather.uvIndex,
            weatherCondition: weather.weatherCondition,
            temperatureMin: weather.temperatureMin,
            temperatureMax: weather.temperatureMax
        )
        advice.stylePreference = stylePreference
        advice.coldSensitivity = coldSensitivity
        return advice.getRecommendations()
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // 背景
                LinearGradient(
                    colors: [Color(hex: "#1E88E5"), Color(hex: "#1565C0")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // 个人偏好设置
                        VStack(spacing: 15) {
                            HStack {
                                Text(LocalizedText.get("personal_preferences"))
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white)
                                Spacer()
                                // 显示当前选择的摘要
                                Text("\(stylePreference.displayName) · \(coldSensitivity.displayName)")
                                    .font(.system(size: 12))
                                    .foregroundColor(.white.opacity(0.6))
                            }
                            
                            // 风格偏好
                            VStack(alignment: .leading, spacing: 8) {
                                Text(LocalizedText.get("style_preference"))
                                    .font(.system(size: 14))
                                    .foregroundColor(.white.opacity(0.8))
                                
                                HStack(spacing: 8) {
                                    ForEach(StylePreference.allCases, id: \.self) { style in
                                        Button(action: {
                                            withAnimation(.easeInOut(duration: 0.2)) {
                                                stylePreference = style
                                                UserDefaults.standard.set(style.rawValue, forKey: "clothing_style_preference")
                                            }
                                        }) {
                                            Text(style.displayName)
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundColor(stylePreference == style ? .black : .white)
                                                .frame(maxWidth: .infinity)
                                                .padding(.vertical, 10)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 8)
                                                        .fill(stylePreference == style ? Color.white : Color.white.opacity(0.2))
                                                )
                                        }
                                    }
                                }
                            }
                            
                            // 温度敏感度
                            VStack(alignment: .leading, spacing: 12) {
                                Text(LocalizedText.get("cold_sensitivity"))
                                    .font(.system(size: 14))
                                    .foregroundColor(.white.opacity(0.8))
                                
                                VStack(spacing: 8) {
                                    HStack(spacing: 10) {
                                        Image(systemName: "thermometer.snowflake")
                                            .foregroundColor(.blue)
                                            .font(.system(size: 20))
                                        
                                        Slider(value: Binding(
                                            get: { Double(coldSensitivity.rawValue) },
                                            set: { 
                                                coldSensitivity = ColdSensitivity(rawValue: Int($0)) ?? .normal
                                                UserDefaults.standard.set(coldSensitivity.rawValue, forKey: "cold_sensitivity")
                                            }
                                        ), in: 1...5, step: 1)
                                        .accentColor(.white)
                                        .tint(.white)
                                        
                                        Image(systemName: "thermometer.sun.fill")
                                            .foregroundColor(.orange)
                                            .font(.system(size: 20))
                                    }
                                    
                                    // 显示5个选项按钮
                                    HStack(spacing: 4) {
                                        ForEach(ColdSensitivity.allCases, id: \.self) { sensitivity in
                                            Circle()
                                                .fill(coldSensitivity == sensitivity ? Color.white : Color.white.opacity(0.3))
                                                .frame(width: 8, height: 8)
                                        }
                                    }
                                    
                                    Text(coldSensitivity.displayName)
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 8)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(Color.white.opacity(0.15))
                                        )
                                }
                            }
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.15))
                        )
                        
                        // 详细建议
                        VStack(spacing: 15) {
                            Text(LocalizedText.get("detailed_advice"))
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            // 服装建议卡片
                            ClothingCategoryCard(
                                title: LocalizedText.get("upper_body"),
                                icon: "tshirt.fill",
                                items: clothingAdvice.upperBody,
                                color: .blue
                            )
                            
                            ClothingCategoryCard(
                                title: LocalizedText.get("lower_body"),
                                icon: "figure.stand",
                                items: clothingAdvice.lowerBody,
                                color: .green
                            )
                            
                            ClothingCategoryCard(
                                title: LocalizedText.get("footwear"),
                                icon: "shoe.fill",
                                items: [clothingAdvice.footwear],
                                color: .purple
                            )
                            
                            if !clothingAdvice.accessories.isEmpty {
                                ClothingCategoryCard(
                                    title: LocalizedText.get("accessories"),
                                    icon: "bag.fill",
                                    items: clothingAdvice.accessories,
                                    color: .orange
                                )
                            }
                        }
                        
                        // 天气因素说明
                        WeatherFactorsCard(weather: weather)
                        
                        // 额外提示
                        if !clothingAdvice.tips.isEmpty || !clothingAdvice.avoidItems.isEmpty {
                            VStack(spacing: 12) {
                                Text(LocalizedText.get("additional_tips"))
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                ForEach(clothingAdvice.tips, id: \.self) { tip in
                                    HStack(alignment: .top, spacing: 10) {
                                        Image(systemName: "lightbulb.fill")
                                            .font(.system(size: 14))
                                            .foregroundColor(.yellow)
                                        Text(tip)
                                            .font(.system(size: 14))
                                            .foregroundColor(.white.opacity(0.9))
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                
                                ForEach(clothingAdvice.avoidItems, id: \.self) { item in
                                    HStack(alignment: .top, spacing: 10) {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.system(size: 14))
                                            .foregroundColor(.red)
                                        Text(item)
                                            .font(.system(size: 14))
                                            .foregroundColor(.white.opacity(0.9))
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                            .padding(20)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white.opacity(0.15))
                            )
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle(LocalizedText.get("clothing_advice"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(LocalizedText.get("done")) {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
}

// MARK: - 服装类别卡片
struct ClothingCategoryCard: View {
    let title: String
    let icon: String
    let items: [ClothingItem]
    let color: Color
    
    var body: some View {
        HStack(spacing: 15) {
            // 图标
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(color)
            }
            
            // 内容
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                
                Text(items.map { $0.localizedName }.joined(separator: " + "))
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding(15)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.1))
        )
    }
}

// MARK: - 天气因素卡片
struct WeatherFactorsCard: View {
    let weather: WeatherData
    
    var body: some View {
        VStack(spacing: 12) {
            Text(LocalizedText.get("weather_factors"))
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 10) {
                WeatherFactorRow(
                    icon: "thermometer",
                    label: LocalizedText.get("temperature"),
                    value: "\(Int(weather.temperature))°C",
                    description: LocalizedText.get("feels_like") + " \(Int(weather.feelsLike))°C"
                )
                
                WeatherFactorRow(
                    icon: "wind",
                    label: LocalizedText.get("wind"),
                    value: "\(Int(weather.windSpeed)) km/h",
                    description: weather.windSpeed > 20 ? LocalizedText.get("strong_wind") : LocalizedText.get("light_wind")
                )
                
                WeatherFactorRow(
                    icon: "humidity",
                    label: LocalizedText.get("humidity"),
                    value: "\(Int(weather.humidity))%",
                    description: weather.humidity > 70 ? LocalizedText.get("high_humidity") : LocalizedText.get("comfortable_humidity")
                )
                
                if weather.precipitation > 30 {
                    WeatherFactorRow(
                        icon: "cloud.rain.fill",
                        label: LocalizedText.get("rain_chance"),
                        value: "\(Int(weather.precipitation))%",
                        description: LocalizedText.get("bring_umbrella")
                    )
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.15))
        )
    }
}

// MARK: - 天气因素行
struct WeatherFactorRow: View {
    let icon: String
    let label: String
    let value: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.white.opacity(0.7))
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(label)
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.7))
                    Spacer()
                    Text(value)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                }
                
                Text(description)
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.6))
            }
        }
    }
}