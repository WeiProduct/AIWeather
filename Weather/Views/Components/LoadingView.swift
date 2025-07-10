import SwiftUI

struct LoadingView: View {
    let message: String
    let color: Color
    
    init(message: String = "Loading...", color: Color = .white) {
        self.message = LocalizedText.get("loading")
        self.color = color
    }
    
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: color))
                .scaleEffect(1.2)
            
            Text(message)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(color)
        }
        .padding(32)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(0.2))
        )
    }
}

#Preview {
    ZStack {
        Color.blue
        LoadingView()
    }
}