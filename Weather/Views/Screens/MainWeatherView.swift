import SwiftUI

struct MainWeatherView: View {
    @ObservedObject var viewModel: WeatherViewModel
    @ObservedObject var languageManager = LanguageManager.shared
    @State private var showingDetail = false
    @State private var showingWeekly = false
    @State private var showingCities = false
    @State private var showingSettings = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // 背景渐变
                if let weather = viewModel.currentWeather {
                    let colors = viewModel.weatherBackgroundColor(for: weather.weatherCondition)
                    LinearGradient(
                        colors: [Color(hex: colors[0]), Color(hex: colors[1])],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()
                }
                
                if viewModel.isLoading {
                    ProgressView(LocalizedText.get("loading"))
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .foregroundColor(.white)
                } else if let weather = viewModel.currentWeather {
                    ScrollView {
                        VStack(spacing: 15) {
                            // 顶部工具栏
                            HStack(spacing: 12) {
                                Button(action: {
                                    showingCities = true
                                }) {
                                    HStack {
                                        Image(systemName: "location.fill")
                                            .font(.system(size: 14))
                                        Text(weather.cityName)
                                            .font(.system(size: 16, weight: .medium))
                                    }
                                    .foregroundColor(.white)
                                }
                                
                                // Auto-location button
                                Button(action: {
                                    if viewModel.locationManager.hasLocationPermission {
                                        viewModel.autoLocationEnabled = true
                                    } else if viewModel.locationManager.authorizationStatus == .notDetermined {
                                        // 如果权限未确定，请求权限
                                        viewModel.requestLocationPermission()
                                        viewModel.autoLocationEnabled = true
                                    } else {
                                        // 权限被拒绝，可以提示用户去设置
                                        viewModel.showLocationDeniedAlert = true
                                    }
                                }) {
                                    Image(systemName: viewModel.autoLocationEnabled ? "location.circle.fill" : "location.circle")
                                        .font(.system(size: 20))
                                        .foregroundColor(viewModel.autoLocationEnabled ? .blue : .white)
                                        .opacity(viewModel.autoLocationEnabled || viewModel.locationManager.authorizationStatus == .notDetermined ? 1.0 : 0.5)
                                }
                                .padding(.trailing, 10)
                                
                                Spacer()
                                
                                HStack(spacing: 15) {
                                    Button(action: {
                                        Task {
                                            await viewModel.refreshWeatherData()
                                        }
                                    }) {
                                        Image(systemName: "arrow.clockwise")
                                            .font(.system(size: 16))
                                            .foregroundColor(.white)
                                    }
                                    
                                    // 语言切换按钮
                                    Button(action: {
                                        withAnimation(.easeInOut(duration: 0.3)) {
                                            languageManager.switchLanguage()
                                        }
                                    }) {
                                        HStack(spacing: 4) {
                                            Image(systemName: "globe")
                                                .font(.system(size: 14))
                                            Text(languageManager.currentLanguage == .chinese ? "EN" : "中")
                                                .font(.system(size: 12, weight: .medium))
                                        }
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color.white.opacity(0.2))
                                        )
                                    }
                                    
                                    Button(action: {
                                        showingSettings = true
                                    }) {
                                        Image(systemName: "line.horizontal.3")
                                            .font(.system(size: 16))
                                            .foregroundColor(.white)
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 5)
                            
                            // 主要天气信息
                            VStack(spacing: 20) {
                                // 温度
                                Text(viewModel.formattedTemperature(weather.temperature))
                                    .font(.system(size: 72, weight: .thin))
                                    .foregroundColor(.white)
                                
                                // 天气描述
                                Text(weather.weatherDescription)
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.white.opacity(0.9))
                                
                                // 温度范围
                                Text("\(viewModel.formattedTemperature(weather.temperatureMin)) / \(viewModel.formattedTemperature(weather.temperatureMax))")
                                    .font(.system(size: 16))
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            .padding(.top, 20)
                            
                            // 天气指标网格
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 20) {
                                WeatherMetricCard(
                                    icon: "eye.fill",
                                    value: "\(Int(weather.visibility))km",
                                    label: LocalizedText.get("visibility")
                                )
                                
                                WeatherMetricCard(
                                    icon: "drop.fill",
                                    value: "\(Int(weather.humidity))%",
                                    label: LocalizedText.get("humidity")
                                )
                                
                                WeatherMetricCard(
                                    icon: "wind",
                                    value: viewModel.formattedWindSpeed(weather.windSpeed),
                                    label: LocalizedText.get("wind_speed")
                                )
                            }
                            .padding(.horizontal, 20)
                            
                            // 24小时预报标题
                            HStack {
                                Text(LocalizedText.get("24hour_forecast"))
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white.opacity(0.9))
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            
                            // 24小时预报 - 当前使用今日温度范围估算
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 15) {
                                    ForEach(0..<24, id: \.self) { hour in
                                        HourlyWeatherCard(
                                            time: viewModel.formattedHour(hour),
                                            icon: viewModel.weatherIcon(for: weather.weatherCondition),
                                            temperature: viewModel.formattedTemperature(estimateHourlyTemp(
                                                hour: hour,
                                                min: weather.temperatureMin,
                                                max: weather.temperatureMax,
                                                current: weather.temperature
                                            ))
                                        )
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                            
                            // 新功能卡片区域
                            VStack(spacing: 15) {
                                // 穿衣建议卡片
                                if viewModel.showClothingAdvice {
                                    ClothingAdviceCard(weather: weather)
                                        .padding(.horizontal, 20)
                                        .transition(.asymmetric(
                                            insertion: .move(edge: .trailing).combined(with: .opacity),
                                            removal: .move(edge: .leading).combined(with: .opacity)
                                        ))
                                }
                                
                                // 日出日落卡片
                                if let sunTimes = weather.sunTimes, viewModel.showSunTimes {
                                    SunTimesCard(sunTimes: sunTimes)
                                        .padding(.horizontal, 20)
                                        .transition(.asymmetric(
                                            insertion: .move(edge: .trailing).combined(with: .opacity),
                                            removal: .move(edge: .leading).combined(with: .opacity)
                                        ))
                                }
                                
                                // 摄影时刻卡片
                                if let sunTimes = weather.sunTimes, viewModel.showPhotographyTimes {
                                    GoldenHourCard(sunTimes: sunTimes)
                                        .padding(.horizontal, 20)
                                        .transition(.asymmetric(
                                            insertion: .move(edge: .trailing).combined(with: .opacity),
                                            removal: .move(edge: .leading).combined(with: .opacity)
                                        ))
                                }
                                
                                // 天气趋势图表卡片
                                if viewModel.showWeatherTrends && !weather.hourlyForecast.isEmpty {
                                    WeatherTrendsCard(forecast: weather.hourlyForecast)
                                        .padding(.horizontal, 20)
                                        .transition(.asymmetric(
                                            insertion: .move(edge: .trailing).combined(with: .opacity),
                                            removal: .move(edge: .leading).combined(with: .opacity)
                                        ))
                                }
                            }
                            .padding(.top, 5)
                            .padding(.bottom, 0)
                            .animation(.easeInOut(duration: 0.3), value: viewModel.showSunTimes)
                            .animation(.easeInOut(duration: 0.3), value: viewModel.showPhotographyTimes)
                            .animation(.easeInOut(duration: 0.3), value: viewModel.showClothingAdvice)
                            .animation(.easeInOut(duration: 0.3), value: viewModel.showWeatherTrends)
                            
                            // 底部按钮区域
                            VStack(spacing: 10) {
                                // 功能按钮网格
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 15) {
                                    ActionButton(icon: "info.circle.fill", label: LocalizedText.get("details")) {
                                        showingDetail = true
                                    }
                                    
                                    ActionButton(icon: "clock.fill", label: LocalizedText.get("forecast")) {
                                        showingWeekly = true
                                    }
                                    
                                    ActionButton(icon: "building.2.fill", label: LocalizedText.get("cities")) {
                                        showingCities = true
                                    }
                                    
                                    ActionButton(icon: "gearshape.fill", label: LocalizedText.get("settings")) {
                                        showingSettings = true
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                            .padding(.bottom, 15)
                        }
                        .frame(maxWidth: 600)
                        .frame(maxWidth: .infinity)
                    }
                } else {
                    Text(LocalizedText.get("no_weather_data"))
                        .foregroundColor(.white)
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(isPresented: $showingDetail) {
            if let weather = viewModel.currentWeather {
                WeatherDetailView(weather: weather, viewModel: viewModel)
            }
        }
        .sheet(isPresented: $showingWeekly) {
            if let weather = viewModel.currentWeather {
                WeeklyForecastView(weather: weather, viewModel: viewModel)
            }
        }
        .sheet(isPresented: $showingCities) {
            CityManagementView(viewModel: viewModel)
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView(viewModel: viewModel)
        }
        .alert(LocalizedText.get("location_permission_denied"), isPresented: $viewModel.showLocationDeniedAlert) {
            Button(LocalizedText.get("go_to_settings")) {
                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsUrl)
                }
            }
            Button(LocalizedText.get("cancel"), role: .cancel) { }
        } message: {
            Text(LocalizedText.get("location_permission_desc"))
        }
        .localizedView()
    }
    
    // 根据一天中的时间估算温度
    private func estimateHourlyTemp(hour: Int, min: Double, max: Double, current: Double) -> Double {
        let currentHour = Calendar.current.component(.hour, from: Date())
        
        // 使用正弦曲线模拟一天的温度变化
        // 凌晨4点最低，下午2点最高
        let hoursFromMin = Double((hour + 24 - 4) % 24)
        let tempRange = max - min
        let estimatedTemp = min + tempRange * (0.5 + 0.5 * sin((hoursFromMin - 6) * .pi / 12))
        
        // 如果是当前小时，返回实际温度
        if hour == currentHour {
            return current
        }
        
        return estimatedTemp
    }
}

struct WeatherMetricCard: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.white.opacity(0.8))
            
            Text(value)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
            
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 15)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.15))
        )
    }
}

struct HourlyWeatherCard: View {
    let time: String
    let icon: String
    let temperature: String
    
    var body: some View {
        VStack(spacing: 10) {
            Text(time)
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.7))
            
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(.white)
            
            Text(temperature)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)
        }
        .frame(width: 50)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.15))
        )
    }
}

struct ActionButton: View {
    let icon: String
    let label: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(.white.opacity(0.8))
                
                Text(label)
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.7))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.15))
            )
        }
    }
}

#Preview {
    MainWeatherView(viewModel: WeatherViewModel())
} 