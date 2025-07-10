import SwiftUI

struct WeeklyForecastView: View {
    let weather: WeatherData
    @ObservedObject var viewModel: WeatherViewModel
    @ObservedObject var languageManager = LanguageManager.shared
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                // 背景渐变
                LinearGradient(
                    colors: [
                        Color(hex: "#E91E63"),
                        Color(hex: "#F06292")
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // 顶部导航
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.white)
                        }
                        
                        Text(LocalizedText.get("weekly_forecast"))
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    .padding(.bottom, 20)
                    
                    // 当前天气概览
                    VStack(spacing: 15) {
                        HStack {
                            Image(systemName: "calendar")
                                .font(.system(size: 16))
                                .foregroundColor(.white.opacity(0.8))
                            
                            Text(LocalizedText.get("today"))
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white.opacity(0.9))
                            
                            Spacer()
                            
                            Text(viewModel.formattedTemperature(weather.temperature))
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 20)
                        
                        Divider()
                            .background(Color.white.opacity(0.3))
                            .padding(.horizontal, 20)
                    }
                    
                    // 7天预报列表
                    ScrollView {
                        LazyVStack(spacing: 15) {
                            ForEach(weather.weeklyForecast, id: \.date) { forecast in
                                WeeklyForecastRow(
                                    forecast: forecast,
                                    viewModel: viewModel
                                )
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 20)
                    }
                    
                    Spacer()
                }
            }
        }
        .navigationBarHidden(true)
        .localizedView()
    }
}

struct WeeklyForecastRow: View {
    let forecast: DailyWeather
    let viewModel: WeatherViewModel
    
    var body: some View {
        HStack(spacing: 12) {
            // 日期
            VStack(alignment: .leading, spacing: 4) {
                Text(forecast.localizedDayName)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                
                if forecast.localizedDayName != LocalizedText.get("today") {
                    Text(formatDate(forecast.date))
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            .frame(width: 90, alignment: .leading)
            
            // 天气图标
            Image(systemName: viewModel.weatherIcon(for: forecast.weatherCondition))
                .font(.system(size: 24))
                .foregroundColor(.white)
                .frame(width: 28)
            
            // 降水概率
            VStack(spacing: 4) {
                Image(systemName: "cloud.rain.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.7))
                
                Text("\(Int(forecast.precipitation))%")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.7))
            }
            .frame(width: 35)
            
            Spacer()
            
            // 温度范围
            HStack(spacing: 15) {
                // 最低温度
                Text(viewModel.formattedTemperature(forecast.temperatureMin))
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.7))
                    .frame(width: 30, alignment: .trailing)
                
                // 温度范围条
                TemperatureBar(
                    minTemp: forecast.temperatureMin,
                    maxTemp: forecast.temperatureMax,
                    globalMin: 10,
                    globalMax: 35
                )
                .frame(width: 60)
                
                // 最高温度
                Text(viewModel.formattedTemperature(forecast.temperatureMax))
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 30, alignment: .leading)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.15))
        )
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: date)
    }
}

struct TemperatureBar: View {
    let minTemp: Double
    let maxTemp: Double
    let globalMin: Double
    let globalMax: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // 背景条
                Rectangle()
                    .fill(Color.white.opacity(0.2))
                    .frame(height: 4)
                    .cornerRadius(2)
                
                // 温度范围条
                let range = globalMax - globalMin
                let startPosition = (minTemp - globalMin) / range
                let endPosition = (maxTemp - globalMin) / range
                let barWidth = (endPosition - startPosition) * geometry.size.width
                
                Rectangle()
                    .fill(LinearGradient(
                        colors: [Color.blue.opacity(0.8), Color.orange.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    ))
                    .frame(width: barWidth, height: 4)
                    .cornerRadius(2)
                    .offset(x: startPosition * geometry.size.width)
            }
        }
        .frame(height: 4)
    }
}

#Preview {
    let sampleWeather = WeatherData(
        cityName: "北京市",
        temperature: 28,
        temperatureMin: 15,
        temperatureMax: 29,
        weatherCondition: .sunny,
        weatherDescription: "晴",
        humidity: 45,
        windSpeed: 8,
        windDirection: "西北风",
        pressure: 1020,
        visibility: 15,
        uvIndex: 7,
        precipitation: 10,
        feelsLike: 30,
        weeklyForecast: [
            DailyWeather(date: Date(), dayName: "今天", weatherCondition: .sunny, temperatureMax: 29, temperatureMin: 15, precipitation: 0),
            DailyWeather(date: Calendar.current.date(byAdding: .day, value: 1, to: Date())!, dayName: "明天", weatherCondition: .cloudy, temperatureMax: 26, temperatureMin: 17, precipitation: 20),
            DailyWeather(date: Calendar.current.date(byAdding: .day, value: 2, to: Date())!, dayName: "周三", weatherCondition: .rainy, temperatureMax: 22, temperatureMin: 14, precipitation: 80),
            DailyWeather(date: Calendar.current.date(byAdding: .day, value: 3, to: Date())!, dayName: "周四", weatherCondition: .partlyCloudy, temperatureMax: 24, temperatureMin: 16, precipitation: 30),
            DailyWeather(date: Calendar.current.date(byAdding: .day, value: 4, to: Date())!, dayName: "周五", weatherCondition: .sunny, temperatureMax: 27, temperatureMin: 18, precipitation: 10),
            DailyWeather(date: Calendar.current.date(byAdding: .day, value: 5, to: Date())!, dayName: "周六", weatherCondition: .cloudy, temperatureMax: 25, temperatureMin: 16, precipitation: 40),
            DailyWeather(date: Calendar.current.date(byAdding: .day, value: 6, to: Date())!, dayName: "周日", weatherCondition: .sunny, temperatureMax: 29, temperatureMin: 19, precipitation: 5)
        ],
        hourlyForecast: []
    )
    
    WeeklyForecastView(weather: sampleWeather, viewModel: WeatherViewModel())
} 