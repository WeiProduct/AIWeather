import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - App Color Palette
extension Color {
    struct Weather {
        // Background gradients
        static let sunnyGradient = [Color(hex: "#FF9A56"), Color(hex: "#FFAD56")]
        static let cloudyGradient = [Color(hex: "#54717A"), Color(hex: "#64B5F6")]
        static let partlyCloudyGradient = [Color(hex: "#5B9BD5"), Color(hex: "#70C1B3")]
        static let rainyGradient = [Color(hex: "#73737D"), Color(hex: "#4A5568")]
        static let snowyGradient = [Color(hex: "#E0E5EC"), Color(hex: "#B8C1CC")]
        static let stormyGradient = [Color(hex: "#4A5568"), Color(hex: "#2D3748")]
        static let foggyGradient = [Color(hex: "#A0AEC0"), Color(hex: "#718096")]
        
        // UI Colors
        static let cardBackground = Color.white.opacity(0.15)
        static let cardBackgroundDark = Color.white.opacity(0.25)
        static let textPrimary = Color.white
        static let textSecondary = Color.white.opacity(0.8)
        static let textTertiary = Color.white.opacity(0.6)
    }
    
    struct App {
        static let welcomeGradient = [Color(hex: "#6366F1"), Color(hex: "#8B5CF6")]
        static let cityManagementGradient = [Color(hex: "#00BCD4"), Color(hex: "#4CAF50")]
        static let settingsGradient = [Color(hex: "#424242"), Color(hex: "#616161")]
        static let weeklyForecastGradient = [Color(hex: "#E91E63"), Color(hex: "#F06292")]
    }
}