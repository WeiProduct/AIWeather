import SwiftUI
import UIKit

struct CityManagementView: View {
    @ObservedObject var viewModel: WeatherViewModel
    @ObservedObject var languageManager = LanguageManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var searchResults: [City] = []
    @State private var isSearching = false
    @State private var searchTask: Task<Void, Never>?
    
    var allCities: [City] {
        var cities = viewModel.cities
        // 如果有当前位置城市，添加到列表开头
        if let currentLocationCity = viewModel.currentLocationCity {
            cities.insert(currentLocationCity, at: 0)
        }
        return cities
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // 背景渐变
                LinearGradient(
                    colors: [
                        Color(hex: "#00BCD4"),
                        Color(hex: "#4CAF50")
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
                        
                        Spacer()
                        
                        Text(LocalizedText.get("my_cities"))
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    .padding(.bottom, 20)
                    
                    // 搜索栏
                    VStack(spacing: 8) {
                        HStack(spacing: 12) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.8))
                            
                            SearchTextField(text: $searchText, onTextChange: performSearch)
                                .frame(height: 20)
                            
                            if isSearching {
                                ProgressView()
                                    .scaleEffect(0.7)
                                    .tint(.white)
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white.opacity(0.15))
                        )
                        
                        // 搜索结果
                        if !searchResults.isEmpty {
                            VStack(spacing: 6) {
                                ForEach(searchResults.prefix(3).filter { searchCity in
                                    !allCities.contains { $0.name == searchCity.name }
                                }, id: \.id) { city in
                                    CompactSearchResultRow(city: city) {
                                        viewModel.addCity(city)
                                        searchText = ""
                                        searchResults = []
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 15)
                    
                    // 自动定位提示
                    if !viewModel.canUseAutoLocation && viewModel.currentLocationCity == nil {
                        LocationPermissionBanner(viewModel: viewModel)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 15)
                    }
                    
                    // 城市列表
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(allCities, id: \.id) { city in
                                CityRow(
                                    city: city,
                                    isSelected: isSelected(city),
                                    isCurrentLocation: isCurrentLocationCity(city),
                                    viewModel: viewModel
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    Spacer()
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .navigationBarHidden(true)
        .localizedView()
        .onDisappear {
            searchTask?.cancel()
        }
    }
    
    private func isSelected(_ city: City) -> Bool {
        if let currentLocationCity = viewModel.currentLocationCity,
           city.id == currentLocationCity.id {
            return viewModel.autoLocationEnabled
        }
        return city.isSelected
    }
    
    private func isCurrentLocationCity(_ city: City) -> Bool {
        return viewModel.currentLocationCity?.id == city.id
    }
    
    private func performSearch(query: String) {
        // 取消之前的搜索任务
        searchTask?.cancel()
        
        // 如果搜索文本为空，清空搜索结果
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            searchResults = []
            isSearching = false
            return
        }
        
        // 创建新的搜索任务
        searchTask = Task { @MainActor in
            isSearching = true
            
            // 减少延迟以提高响应速度
            try? await Task.sleep(nanoseconds: 300_000_000) // 0.3秒
            
            // 检查任务是否被取消
            guard !Task.isCancelled else {
                isSearching = false
                return
            }
            
            let results = await WeatherService.shared.searchCities(query: query.trimmingCharacters(in: .whitespacesAndNewlines))
            
            // 再次检查任务是否被取消
            guard !Task.isCancelled else {
                isSearching = false
                return
            }
            
            searchResults = results
            isSearching = false
        }
    }
}

struct CompactSearchResultRow: View {
    let city: City
    let onAdd: () -> Void
    
    var body: some View {
        Button(action: onAdd) {
            HStack(spacing: 10) {
                Text(city.displayName)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                
                Spacer()
                
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.green)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.white.opacity(0.1))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct LocationPermissionBanner: View {
    @ObservedObject var viewModel: WeatherViewModel
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "location.slash")
                .font(.system(size: 20))
                .foregroundColor(.orange)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(LocalizedText.get("enable_location_service"))
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                
                Text(LocalizedText.get("allow_location_access"))
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
            
            Button(LocalizedText.get("location_settings")) {
                viewModel.requestLocationPermission()
            }
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(.blue)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white.opacity(0.2))
        )
    }
}

struct CityRow: View {
    let city: City
    let isSelected: Bool
    let isCurrentLocation: Bool
    @ObservedObject var viewModel: WeatherViewModel
    @State private var weather: WeatherData?
    
    var body: some View {
        Button(action: {
            if isCurrentLocation {
                viewModel.autoLocationEnabled = true
            } else {
                viewModel.selectCity(city)
            }
        }) {
            HStack(spacing: 15) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        if isCurrentLocation {
                            Image(systemName: "location.fill")
                                .font(.system(size: 14))
                                .foregroundColor(.blue)
                        }
                        
                        Text(city.displayName)
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                        
                        if isSelected {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.green)
                        }
                    }
                    
                    if let weather = weather {
                        Text(weather.weatherDescription)
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.7))
                    } else if isCurrentLocation && viewModel.currentWeather != nil {
                        Text(viewModel.currentWeather?.weatherDescription ?? "")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.7))
                    } else {
                        Text(LocalizedText.get("loading"))
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    if let weather = weather {
                        Text(viewModel.formattedTemperature(weather.temperature))
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(.white)
                        
                        HStack(spacing: 4) {
                            Text(viewModel.formattedTemperature(weather.temperatureMin))
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.7))
                            Text("/")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.7))
                            Text(viewModel.formattedTemperature(weather.temperatureMax))
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.7))
                        }
                    } else if isCurrentLocation, let currentWeather = viewModel.currentWeather {
                        Text(viewModel.formattedTemperature(currentWeather.temperature))
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(.white)
                        
                        HStack(spacing: 4) {
                            Text(viewModel.formattedTemperature(currentWeather.temperatureMin))
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.7))
                            Text("/")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.7))
                            Text(viewModel.formattedTemperature(currentWeather.temperatureMax))
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.7))
                        }
                    } else {
                        Text("--°")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(.white.opacity(0.5))
                    }
                }
                
                // 删除按钮（当前位置城市不显示删除按钮）
                if !isSelected && !isCurrentLocation {
                    Button(action: {
                        viewModel.removeCity(city)
                    }) {
                        Image(systemName: "trash")
                            .font(.system(size: 16))
                            .foregroundColor(.red.opacity(0.7))
                    }
                    .padding(.leading, 10)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.white.opacity(0.25) : Color.white.opacity(0.15))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color.white.opacity(0.4) : Color.clear, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            if !isCurrentLocation {
                loadWeatherData()
            }
        }
    }
    
    private func loadWeatherData() {
        Task { @MainActor in
            weather = await WeatherService.shared.fetchWeatherData(for: city.name)
        }
    }
}


// 简洁的搜索输入框，完全支持中文拼音输入
struct SearchTextField: UIViewRepresentable {
    @Binding var text: String
    let onTextChange: (String) -> Void
    
    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        
        // 基本样式
        textField.placeholder = LocalizedText.get("search_and_add")
        textField.font = UIFont.systemFont(ofSize: 14)
        textField.textColor = UIColor.white
        textField.backgroundColor = UIColor.clear
        textField.borderStyle = .none
        
        // 中文输入优化
        textField.keyboardType = .default
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .yes
        textField.returnKeyType = .search
        
        // 占位符样式
        let placeholderColor = UIColor.white.withAlphaComponent(0.6)
        textField.attributedPlaceholder = NSAttributedString(
            string: LocalizedText.get("search_and_add"),
            attributes: [.foregroundColor: placeholderColor]
        )
        
        // 设置代理和监听
        textField.delegate = context.coordinator
        textField.addTarget(
            context.coordinator,
            action: #selector(Coordinator.textDidChange),
            for: .editingChanged
        )
        
        return textField
    }
    
    func updateUIView(_ uiView: UITextField, context: Context) {
        if uiView.text != text {
            uiView.text = text
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UITextFieldDelegate {
        let parent: SearchTextField
        
        init(_ parent: SearchTextField) {
            self.parent = parent
        }
        
        @objc func textDidChange(_ textField: UITextField) {
            let newText = textField.text ?? ""
            DispatchQueue.main.async {
                self.parent.text = newText
                self.parent.onTextChange(newText)
            }
        }
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
            return true
        }
    }
}

#Preview {
    CityManagementView(viewModel: WeatherViewModel())
} 