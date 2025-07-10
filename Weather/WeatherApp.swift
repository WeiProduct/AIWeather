//
//  WeatherApp.swift
//  Weather
//
//  Created by weifu on 6/21/25.
//

import SwiftUI
import SwiftData

@main
struct WeatherApp: App {
    @StateObject private var viewModel = WeatherViewModel()
    @State private var showLaunchScreen = true
    
    init() {
        // Start performance monitoring
        PerformanceMonitor.shared.startAppLaunchTimer()
        
        // Initialize API key securely
        APIKeyManager.shared.initializeAPIKey()
        
        // Configure crash reporting
        CrashReporter.shared.configure()
        
        // Start analytics session
        AnalyticsManager.shared.startNewSession()
        
        // Configure app appearance
        configureAppearance()
        
        // Check API configuration
        #if !DEBUG
        guard ApiConfig.isApiKeyConfigured else {
            fatalError("API key not configured for release build")
        }
        #endif
        
        // Set up app lifecycle observers
        setupLifecycleObservers()
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if showLaunchScreen {
                    LaunchScreen()
                        .transition(.opacity)
                } else {
                    if viewModel.showingWelcome {
                        WelcomeView(viewModel: viewModel)
                    } else {
                        MainWeatherView(viewModel: viewModel)
                    }
                }
            }
            .onAppear {
                // Simulate minimum launch screen duration
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        showLaunchScreen = false
                        PerformanceMonitor.shared.endAppLaunchTimer()
                    }
                }
            }
        }
    }
    
    private func configureAppearance() {
        // Configure navigation bar appearance
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        
        // Configure tab bar appearance if needed
        UITabBar.appearance().unselectedItemTintColor = UIColor.white.withAlphaComponent(0.6)
    }
    
    private func setupLifecycleObservers() {
        NotificationCenter.default.addObserver(
            forName: UIApplication.didEnterBackgroundNotification,
            object: nil,
            queue: .main
        ) { _ in
            AnalyticsManager.shared.track(event: .appBackground)
        }
        
        NotificationCenter.default.addObserver(
            forName: UIApplication.willEnterForegroundNotification,
            object: nil,
            queue: .main
        ) { _ in
            AnalyticsManager.shared.track(event: .appForeground)
        }
        
        NotificationCenter.default.addObserver(
            forName: UIApplication.willTerminateNotification,
            object: nil,
            queue: .main
        ) { _ in
            AnalyticsManager.shared.endSession()
        }
    }
}
