import SwiftUI

struct LaunchScreen: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color(hex: "#1E3C72"),
                    Color(hex: "#2A5298")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // App Icon
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.15))
                        .frame(width: 120, height: 120)
                        .blur(radius: isAnimating ? 10 : 0)
                    
                    Image(systemName: "cloud.sun.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.white)
                        .symbolRenderingMode(.hierarchical)
                        .scaleEffect(isAnimating ? 1.1 : 1.0)
                }
                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                
                // App Name
                Text("Weather")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .opacity(isAnimating ? 1 : 0)
                
                // Tagline
                Text(LocalizedText.get("accurate_forecast"))
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                    .opacity(isAnimating ? 1 : 0)
            }
            
            // Loading indicator
            VStack {
                Spacer()
                
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.2)
                    .padding(.bottom, 100)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0)) {
                isAnimating = true
            }
        }
    }
}

#Preview {
    LaunchScreen()
}