import SwiftUI

struct GradientBackground: View {
    let colors: [Color]
    let startPoint: UnitPoint
    let endPoint: UnitPoint
    
    init(colors: [Color], 
         startPoint: UnitPoint = .topLeading, 
         endPoint: UnitPoint = .bottomTrailing) {
        self.colors = colors
        self.startPoint = startPoint
        self.endPoint = endPoint
    }
    
    init(hexColors: [String], 
         startPoint: UnitPoint = .topLeading, 
         endPoint: UnitPoint = .bottomTrailing) {
        self.colors = hexColors.map { Color(hex: $0) }
        self.startPoint = startPoint
        self.endPoint = endPoint
    }
    
    var body: some View {
        LinearGradient(
            colors: colors,
            startPoint: startPoint,
            endPoint: endPoint
        )
        .ignoresSafeArea()
    }
}

#Preview {
    GradientBackground(hexColors: ["#FF9A56", "#FFAD56"])
}