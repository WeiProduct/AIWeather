import SwiftUI

struct WelcomeView: View {
    @ObservedObject var viewModel: WeatherViewModel
    @ObservedObject var languageManager = LanguageManager.shared
    
    var body: some View {
        ZStack {
            // 渐变背景
            LinearGradient(
                colors: [
                    Color(hex: "#6366F1"),
                    Color(hex: "#8B5CF6")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Logo和标题区域
                VStack(spacing: 20) {
                    // 天气图标
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.2))
                            .frame(width: 120, height: 120)
                        
                        Image(systemName: "cloud.sun.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.white)
                    }
                    
                    Text(LocalizedText.get("weather_assistant"))
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                
                // 描述文字
                VStack(spacing: 12) {
                    Text(LocalizedText.get("accurate_forecast"))
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                }
                
                Spacer()
                
                // 语言选择区域
                VStack(spacing: 20) {
                    Text(LocalizedText.get("choose_language"))
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                    
                    HStack(spacing: 20) {
                        // 中文按钮
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                languageManager.setLanguage(.chinese)
                            }
                        }) {
                            VStack(spacing: 8) {
                                Text("🇨🇳")
                                    .font(.system(size: 32))
                                
                                Text("中文")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            .frame(width: 100, height: 80)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(languageManager.currentLanguage == .chinese ? 
                                          Color.white.opacity(0.3) : Color.white.opacity(0.15))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(languageManager.currentLanguage == .chinese ? 
                                                    Color.white.opacity(0.5) : Color.white.opacity(0.2), 
                                                    lineWidth: languageManager.currentLanguage == .chinese ? 2 : 1)
                                    )
                            )
                        }
                        
                        // 英文按钮
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                languageManager.setLanguage(.english)
                            }
                        }) {
                            VStack(spacing: 8) {
                                Text("🇺🇸")
                                    .font(.system(size: 32))
                                
                                Text("English")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            .frame(width: 100, height: 80)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(languageManager.currentLanguage == .english ? 
                                          Color.white.opacity(0.3) : Color.white.opacity(0.15))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(languageManager.currentLanguage == .english ? 
                                                    Color.white.opacity(0.5) : Color.white.opacity(0.2), 
                                                    lineWidth: languageManager.currentLanguage == .english ? 2 : 1)
                                    )
                            )
                        }
                    }
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 30)
                
                // 开始使用按钮
                Button(action: {
                    viewModel.dismissWelcome()
                }) {
                    HStack {
                        Text(LocalizedText.get("start_using"))
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Image(systemName: "arrow.right")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        RoundedRectangle(cornerRadius: 28)
                            .fill(Color.white.opacity(0.2))
                            .overlay(
                                RoundedRectangle(cornerRadius: 28)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                    )
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 50)
            }
        }
    }
}

#Preview {
    WelcomeView(viewModel: WeatherViewModel())
} 