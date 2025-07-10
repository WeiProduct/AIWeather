//
//  ContentView.swift
//  Weather
//
//  Created by weifu on 6/21/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @StateObject private var viewModel = WeatherViewModel()
    @StateObject private var languageManager = LanguageManager.shared
    @State private var showLanguageSelection = false
    
    var body: some View {
        Group {
            if showLanguageSelection {
                LanguageSelectionView(showLanguageSelection: $showLanguageSelection) {
                    // 语言选择完成后请求位置权限
                    checkAndRequestLocationPermission()
                }
                .transition(.opacity)
            } else if viewModel.showingWelcome {
                WelcomeView(viewModel: viewModel)
            } else {
                MainWeatherView(viewModel: viewModel)
            }
        }
        .animation(.easeInOut, value: viewModel.showingWelcome)
        .animation(.easeInOut, value: showLanguageSelection)
        .localizedView()
        .onAppear {
            // Check if language has been selected before
            if !languageManager.hasSelectedLanguage {
                showLanguageSelection = true
            } else {
                // 如果已经选择了语言，检查并请求位置权限
                checkAndRequestLocationPermission()
            }
        }
    }
    
    private func checkAndRequestLocationPermission() {
        // 如果位置权限状态是未确定，主动请求权限
        if viewModel.locationManager.authorizationStatus == .notDetermined {
            viewModel.requestLocationPermission()
            // 启用自动定位
            viewModel.autoLocationEnabled = true
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [WeatherData.self, City.self], inMemory: true)
}
