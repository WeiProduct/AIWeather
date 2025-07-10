import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: WeatherViewModel
    @ObservedObject var languageManager = LanguageManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var showingLocationPermissionAlert = false
    @State private var showingNotificationSettings = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // 背景渐变
                LinearGradient(
                    colors: [
                        Color(hex: "#424242"),
                        Color(hex: "#616161")
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
                        
                        Text(LocalizedText.get("settings"))
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    .padding(.bottom, 30)
                    
                    ScrollView {
                        VStack(spacing: 25) {
                            // 显示设置
                            SettingsSection(title: LocalizedText.get("display_settings")) {
                                VStack(spacing: 15) {
                                    SettingsRow(
                                        icon: "thermometer",
                                        title: LocalizedText.get("temperature_unit"),
                                        value: viewModel.temperatureUnit.displayName
                                    ) {
                                        // 温度单位选择逻辑
                                        viewModel.temperatureUnit = viewModel.temperatureUnit == .celsius ? .fahrenheit : .celsius
                                    }
                                    
                                    SettingsRow(
                                        icon: "wind",
                                        title: LocalizedText.get("wind_speed_unit"),
                                        value: viewModel.windSpeedUnit.displayName
                                    ) {
                                        // 风速单位选择逻辑
                                        viewModel.windSpeedUnit = viewModel.windSpeedUnit == .kmh ? .mph : .kmh
                                    }
                                    
                                    // 语言切换
                                    LanguageSwitchRow()
                                }
                            }
                            
                            // 功能板块设置
                            SettingsSection(title: LocalizedText.get("feature_modules")) {
                                VStack(spacing: 15) {
                                    ToggleRow(
                                        icon: "sun.max.fill",
                                        title: LocalizedText.get("sun_times"),
                                        isOn: $viewModel.showSunTimes
                                    )
                                    
                                    ToggleRow(
                                        icon: "camera.fill",
                                        title: LocalizedText.get("photography_times"),
                                        isOn: $viewModel.showPhotographyTimes
                                    )
                                    
                                    ToggleRow(
                                        icon: "tshirt.fill",
                                        title: LocalizedText.get("clothing_advice"),
                                        isOn: $viewModel.showClothingAdvice
                                    )
                                    
                                    ToggleRow(
                                        icon: "chart.line.uptrend.xyaxis",
                                        title: LocalizedText.get("weather_trends"),
                                        isOn: $viewModel.showWeatherTrends
                                    )
                                }
                            }
                            
                            // 位置设置
                            SettingsSection(title: LocalizedText.get("location_settings_title")) {
                                VStack(spacing: 15) {
                                    // 位置权限状态
                                    LocationPermissionRow(viewModel: viewModel)
                                    
                                    // 自动定位开关
                                    AutoLocationToggleRow(viewModel: viewModel)
                                }
                            }
                            
                            // 通知设置
                            SettingsSection(title: LocalizedText.get("notification_settings")) {
                                VStack(spacing: 15) {
                                    SettingsRow(
                                        icon: "bell.badge.fill",
                                        title: LocalizedText.get("notification_settings"),
                                        value: ""
                                    ) {
                                        showingNotificationSettings = true
                                    }
                                }
                            }
                            
                            // 其他设置
                            SettingsSection(title: LocalizedText.get("other_settings")) {
                                VStack(spacing: 15) {
                                    SettingsRow(
                                        icon: "info.circle.fill",
                                        title: LocalizedText.get("about_us"),
                                        value: "v1.0.0"
                                    ) {
                                        // 关于页面
                                    }
                                }
                            }
                            
                            Spacer(minLength: 50)
                        }
                        .padding(.horizontal, 20)
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .navigationBarHidden(true)
        .localizedView()
        .sheet(isPresented: $showingNotificationSettings) {
            NotificationSettingsView()
        }
        .alert("位置权限", isPresented: $showingLocationPermissionAlert) {
            Button("去设置") {
                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsUrl)
                }
            }
            Button("取消", role: .cancel) { }
        } message: {
            Text("请在系统设置中允许Weather访问您的位置信息，以便提供基于当前位置的天气预报。")
        }
    }
}

struct SettingsSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white.opacity(0.9))
                .padding(.horizontal, 4)
            
            VStack(spacing: 1) {
                content
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.15))
            )
        }
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let value: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(.white.opacity(0.8))
                    .frame(width: 24)
                
                Text(title)
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                
                Spacer()
                
                Text(value)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.7))
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.5))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SettingsToggleRow: View {
    let icon: String
    let title: String
    let subtitle: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(.white.opacity(0.8))
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .toggleStyle(SwitchToggleStyle(tint: .blue))
                .scaleEffect(0.8)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

struct LocationPermissionRow: View {
    @ObservedObject var viewModel: WeatherViewModel
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: "location.fill")
                .font(.system(size: 18))
                .foregroundColor(.white.opacity(0.8))
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(LocalizedText.get("location_settings"))
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                
                Text("\(LocalizedText.get("location_permission_not_determined")): \(viewModel.locationPermissionStatus)")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Spacer()
            
            Button(action: {
                viewModel.requestLocationPermission()
            }) {
                Text(LocalizedText.get("location_settings"))
                    .font(.system(size: 14))
                    .foregroundColor(.blue)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

struct ToggleRow: View {
    let icon: String
    let title: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(.white.opacity(0.8))
                .frame(width: 24)
            
            Text(title)
                .font(.system(size: 16))
                .foregroundColor(.white)
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .toggleStyle(SwitchToggleStyle(tint: .blue))
                .scaleEffect(0.8)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.1))
        )
    }
}

struct AutoLocationToggleRow: View {
    @ObservedObject var viewModel: WeatherViewModel
    @State private var showingPermissionAlert = false
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: "location.circle.fill")
                .font(.system(size: 18))
                .foregroundColor(.white.opacity(0.8))
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(LocalizedText.get("auto_location"))
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                
                Text(viewModel.canUseAutoLocation ? 
                     LocalizedText.get("location_permission_granted") : 
                     LocalizedText.get("location_permission_denied"))
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Spacer()
            
            Toggle("", isOn: Binding(
                get: { viewModel.autoLocationEnabled },
                set: { newValue in
                    if newValue && !viewModel.canUseAutoLocation {
                        // 如果权限状态是未确定，直接请求权限
                        if viewModel.locationManager.authorizationStatus == .notDetermined {
                            viewModel.requestLocationPermission()
                            viewModel.autoLocationEnabled = true
                        } else {
                            // 权限被拒绝或限制，显示弹窗
                            showingPermissionAlert = true
                        }
                    } else {
                        viewModel.autoLocationEnabled = newValue
                    }
                }
            ))
            .toggleStyle(SwitchToggleStyle(tint: .blue))
            .scaleEffect(0.8)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .alert(LocalizedText.get("location_permission_denied"), isPresented: $showingPermissionAlert) {
            Button(LocalizedText.get("go_to_settings")) {
                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsUrl)
                }
            }
            Button(LocalizedText.get("cancel"), role: .cancel) { }
        } message: {
            Text(LocalizedText.get("location_permission_desc"))
        }
    }
}

struct LanguageSwitchRow: View {
    @ObservedObject var languageManager = LanguageManager.shared
    
    var body: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.3)) {
                languageManager.switchLanguage()
            }
        }) {
            HStack(spacing: 15) {
                Image(systemName: "globe")
                    .font(.system(size: 18))
                    .foregroundColor(.white.opacity(0.8))
                    .frame(width: 24)
                
                Text(LocalizedText.get("language"))
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                
                Spacer()
                
                HStack(spacing: 8) {
                    Text(languageManager.currentLanguage.displayName)
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.7))
                    
                    Image(systemName: "arrow.2.squarepath")
                        .font(.system(size: 14))
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    SettingsView(viewModel: WeatherViewModel())
} 