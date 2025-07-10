import SwiftUI

struct LanguageSelectionView: View {
    @ObservedObject var languageManager = LanguageManager.shared
    @Binding var showLanguageSelection: Bool
    @State private var selectedLanguage: AppLanguage?
    @State private var animateIn = false
    var onCompletion: (() -> Void)?
    
    var body: some View {
        ZStack {
            // 背景渐变
            LinearGradient(
                colors: [Color(hex: "4A90E2"), Color(hex: "7B68EE")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Logo 和标题
                VStack(spacing: 20) {
                    Image(systemName: "sun.max.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                        .scaleEffect(animateIn ? 1.0 : 0.5)
                        .opacity(animateIn ? 1.0 : 0.0)
                    
                    Text("WeiWeathers")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
                        .opacity(animateIn ? 1.0 : 0.0)
                        .offset(y: animateIn ? 0 : 20)
                    
                    Text("选择您的语言 / Choose Your Language")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .opacity(animateIn ? 1.0 : 0.0)
                        .offset(y: animateIn ? 0 : 20)
                }
                
                Spacer()
                
                // 语言选择按钮
                VStack(spacing: 20) {
                    LanguageButton(
                        language: .chinese,
                        title: "中文",
                        subtitle: "简体中文",
                        isSelected: selectedLanguage == .chinese,
                        action: {
                            selectLanguage(.chinese)
                        }
                    )
                    .opacity(animateIn ? 1.0 : 0.0)
                    .offset(x: animateIn ? 0 : -50)
                    
                    LanguageButton(
                        language: .english,
                        title: "English",
                        subtitle: "English",
                        isSelected: selectedLanguage == .english,
                        action: {
                            selectLanguage(.english)
                        }
                    )
                    .opacity(animateIn ? 1.0 : 0.0)
                    .offset(x: animateIn ? 0 : 50)
                }
                .padding(.horizontal, 40)
                
                Spacer()
                
                // 底部说明
                Text("您可以稍后在设置中更改\nYou can change this later in settings")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .opacity(animateIn ? 1.0 : 0.0)
                    .padding(.bottom, 40)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                animateIn = true
            }
        }
    }
    
    private func selectLanguage(_ language: AppLanguage) {
        withAnimation(.easeInOut(duration: 0.3)) {
            selectedLanguage = language
        }
        
        // 延迟一下让用户看到选中效果
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            languageManager.setLanguage(language)
            languageManager.markLanguageAsSelected()
            
            withAnimation(.easeInOut(duration: 0.3)) {
                showLanguageSelection = false
            }
            
            // 语言选择完成后，调用回调
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                onCompletion?()
            }
        }
    }
}

struct LanguageButton: View {
    let language: AppLanguage
    let title: String
    let subtitle: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text(title)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(isSelected ? .white : .white.opacity(0.9))
                    
                    Text(subtitle)
                        .font(.system(size: 14))
                        .foregroundColor(isSelected ? .white.opacity(0.9) : .white.opacity(0.7))
                }
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? .white : .white.opacity(0.5))
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color.white.opacity(0.25) : Color.white.opacity(0.15))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? Color.white.opacity(0.5) : Color.clear, lineWidth: 2)
                    )
            )
            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
            .scaleEffect(isSelected ? 1.02 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    LanguageSelectionView(showLanguageSelection: .constant(true))
}