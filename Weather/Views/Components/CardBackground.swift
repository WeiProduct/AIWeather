import SwiftUI

struct CardBackground: ViewModifier {
    let opacity: Double
    let cornerRadius: CGFloat
    
    init(opacity: Double = 0.15, cornerRadius: CGFloat = 16) {
        self.opacity = opacity
        self.cornerRadius = cornerRadius
    }
    
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color.white.opacity(opacity))
            )
    }
}

extension View {
    func cardBackground(opacity: Double = 0.15, cornerRadius: CGFloat = 16) -> some View {
        modifier(CardBackground(opacity: opacity, cornerRadius: cornerRadius))
    }
}

#Preview {
    ZStack {
        Color.blue
        Text("Card Content")
            .padding()
            .cardBackground()
    }
}