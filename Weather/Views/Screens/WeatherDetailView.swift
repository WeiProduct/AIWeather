import SwiftUI

struct WeatherDetailView: View {
    let weather: WeatherData
    @ObservedObject var viewModel: WeatherViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                // 背景渐变
                let colors = viewModel.weatherBackgroundColor(for: weather.weatherCondition)
                LinearGradient(
                    colors: [Color(hex: colors[0]), Color(hex: colors[1])],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        // 顶部导航
                        HStack {
                            Button(action: { dismiss() }) {
                                HStack {
                                    Image(systemName: "chevron.left")
                                        .font(.system(size: 16, weight: .medium))
                                    Text(LocalizedText.get("weather_details"))
                                        .font(.system(size: 18, weight: .medium))
                                }
                                .foregroundColor(.white)
                            }
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                        
                        // 主要天气信息
                        VStack(spacing: 15) {
                            Text(viewModel.formattedTemperature(weather.temperature))
                                .font(.system(size: 64, weight: .thin))
                                .foregroundColor(.white)
                            
                            Text(weather.weatherDescription)
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(.white.opacity(0.9))
                        }
                        
                        // 详细指标网格
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 20) {
                            DetailMetricCard(
                                icon: "thermometer",
                                title: LocalizedText.get("feels_like_temp"),
                                value: viewModel.formattedTemperature(weather.feelsLike),
                                subtitle: LocalizedText.get("feels_like_subtitle")
                            )
                            
                            DetailMetricCard(
                                icon: "sun.max.fill",
                                title: LocalizedText.get("uv_index_title"),
                                value: "\(weather.uvIndex)",
                                subtitle: uvIndexDescription(weather.uvIndex)
                            )
                            
                            DetailMetricCard(
                                icon: "barometer",
                                title: LocalizedText.get("pressure_hpa"),
                                value: "\(Int(weather.pressure))",
                                subtitle: LocalizedText.get("standard_pressure")
                            )
                            
                            DetailMetricCard(
                                icon: "cloud.rain.fill",
                                title: LocalizedText.get("precipitation_probability"),
                                value: "\(Int(weather.precipitation))%",
                                subtitle: precipitationDescription(weather.precipitation)
                            )
                        }
                        .padding(.horizontal, 20)
                        
                        // 今日温度变化
                        VStack(alignment: .leading, spacing: 15) {
                            HStack {
                                Text(LocalizedText.get("today_temperature_change"))
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white.opacity(0.9))
                                Spacer()
                            }
                            
                            VStack(spacing: 15) {
                                // 温度范围条
                                TemperatureRangeBar(
                                    minTemp: weather.temperatureMin,
                                    maxTemp: weather.temperatureMax,
                                    currentTemp: weather.temperature,
                                    viewModel: viewModel
                                )
                                
                                HStack {
                                    Text(LocalizedText.get("minimum"))
                                        .font(.system(size: 14))
                                        .foregroundColor(.white.opacity(0.7))
                                    Text(viewModel.formattedTemperature(weather.temperatureMin))
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                    
                                    Text(LocalizedText.get("maximum"))
                                        .font(.system(size: 14))
                                        .foregroundColor(.white.opacity(0.7))
                                    Text(viewModel.formattedTemperature(weather.temperatureMax))
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.white)
                                }
                            }
                            .padding(20)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white.opacity(0.15))
                            )
                        }
                        .padding(.horizontal, 20)
                        
                        Spacer(minLength: 50)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .localizedView()
    }
    
    private func uvIndexDescription(_ index: Int) -> String {
        switch index {
        case 0...2: return LocalizedText.get("uv_low")
        case 3...5: return LocalizedText.get("uv_moderate")
        case 6...7: return LocalizedText.get("uv_high")
        case 8...10: return LocalizedText.get("uv_very_high")
        default: return LocalizedText.get("uv_extreme")
        }
    }
    
    private func precipitationDescription(_ precipitation: Double) -> String {
        switch precipitation {
        case 0...10: return LocalizedText.get("no_rain")
        case 11...30: return LocalizedText.get("light_rain")
        case 31...60: return LocalizedText.get("moderate_rain")
        default: return LocalizedText.get("heavy_rain")
        }
    }
}

struct DetailMetricCard: View {
    let icon: String
    let title: String
    let value: String
    let subtitle: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(.white.opacity(0.8))
                
                Text(title)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.7))
                
                Spacer()
            }
            
            Text(value)
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(.white)
            
            Text(subtitle)
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.15))
        )
    }
}

struct TemperatureRangeBar: View {
    let minTemp: Double
    let maxTemp: Double
    let currentTemp: Double
    let viewModel: WeatherViewModel
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("\(LocalizedText.get("current")) \(viewModel.formattedTemperature(currentTemp))")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                Spacer()
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // 背景条
                    Rectangle()
                        .fill(Color.white.opacity(0.2))
                        .frame(height: 6)
                        .cornerRadius(3)
                    
                    // 温度范围条
                    Rectangle()
                        .fill(LinearGradient(
                            colors: [Color.blue.opacity(0.7), Color.orange.opacity(0.7)],
                            startPoint: .leading,
                            endPoint: .trailing
                        ))
                        .frame(height: 6)
                        .cornerRadius(3)
                    
                    // 当前温度指示器
                    Circle()
                        .fill(Color.white)
                        .frame(width: 12, height: 12)
                        .offset(x: currentTempOffset(geometry.size.width))
                }
            }
            .frame(height: 12)
        }
    }
    
    private func currentTempOffset(_ width: CGFloat) -> CGFloat {
        let range = maxTemp - minTemp
        let position = (currentTemp - minTemp) / range
        return width * position - 6
    }
}

#Preview {
    WeatherDetailView(
        weather: WeatherData(
            cityName: "北京市",
            temperature: 23,
            temperatureMin: 15,
            temperatureMax: 28,
            weatherCondition: .partlyCloudy,
            weatherDescription: "多云转晴",
            humidity: 65,
            windSpeed: 12,
            windDirection: "东北",
            pressure: 1013,
            visibility: 10,
            uvIndex: 6,
            precipitation: 20,
            feelsLike: 25,
            hourlyForecast: []
        ),
        viewModel: WeatherViewModel()
    )
} 