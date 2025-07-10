import SwiftUI

// This is a template for generating app icons
// Use a screenshot tool or export from SwiftUI Previews at 1024x1024

struct AppIconTemplate: View {
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color(red: 0.118, green: 0.235, blue: 0.447),  // #1E3C72
                    Color(red: 0.165, green: 0.322, blue: 0.596)   // #2A5298
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Icon design
            ZStack {
                // Sun
                Circle()
                    .fill(Color.yellow.opacity(0.9))
                    .frame(width: 280, height: 280)
                    .offset(x: 80, y: -80)
                    .blur(radius: 3)
                
                // Sun rays
                ForEach(0..<8) { index in
                    Rectangle()
                        .fill(Color.yellow.opacity(0.6))
                        .frame(width: 20, height: 100)
                        .offset(y: -190)
                        .rotationEffect(.degrees(Double(index) * 45))
                        .offset(x: 80, y: -80)
                }
                .blur(radius: 2)
                
                // Cloud
                ZStack {
                    // Main cloud body
                    Ellipse()
                        .fill(Color.white.opacity(0.95))
                        .frame(width: 400, height: 280)
                        .offset(y: 60)
                    
                    // Cloud puffs
                    Circle()
                        .fill(Color.white.opacity(0.95))
                        .frame(width: 200, height: 200)
                        .offset(x: -100, y: 0)
                    
                    Circle()
                        .fill(Color.white.opacity(0.95))
                        .frame(width: 240, height: 240)
                        .offset(x: 100, y: -20)
                    
                    Circle()
                        .fill(Color.white.opacity(0.95))
                        .frame(width: 180, height: 180)
                        .offset(x: 0, y: -40)
                }
                .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
            }
            .scaleEffect(0.7)
        }
        .frame(width: 1024, height: 1024)
    }
}

// Alternative minimalist design
struct AppIconMinimalist: View {
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [
                    Color(red: 0.118, green: 0.235, blue: 0.447),
                    Color(red: 0.165, green: 0.322, blue: 0.596)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Weather symbol
            Image(systemName: "cloud.sun.fill")
                .font(.system(size: 500, weight: .medium))
                .foregroundStyle(
                    Color.white,
                    Color.yellow.opacity(0.9)
                )
                .symbolRenderingMode(.palette)
                .shadow(color: .black.opacity(0.3), radius: 30, x: 0, y: 20)
        }
        .frame(width: 1024, height: 1024)
    }
}

#Preview("Detailed") {
    AppIconTemplate()
        .previewLayout(.fixed(width: 1024, height: 1024))
}

#Preview("Minimalist") {
    AppIconMinimalist()
        .previewLayout(.fixed(width: 1024, height: 1024))
}

// Icon Size Reference:
// 1024x1024 - App Store
// 180x180 - iPhone @3x
// 120x120 - iPhone @2x
// 167x167 - iPad Pro
// 152x152 - iPad @2x
// 76x76 - iPad @1x
// 60x60 - iPhone Notification @3x
// 40x40 - iPhone Notification @2x
// 20x20 - iPhone Notification @1x