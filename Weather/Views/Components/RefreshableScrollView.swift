import SwiftUI

struct RefreshableScrollView<Content: View>: View {
    let content: Content
    let onRefresh: () async -> Void
    
    @State private var isRefreshing = false
    
    init(@ViewBuilder content: () -> Content, onRefresh: @escaping () async -> Void) {
        self.content = content()
        self.onRefresh = onRefresh
    }
    
    var body: some View {
        ScrollView {
            content
        }
        .refreshable {
            await onRefresh()
        }
    }
}

// MARK: - Custom Pull to Refresh with Animation
struct CustomRefreshableScrollView<Content: View>: View {
    let content: Content
    let onRefresh: () async -> Void
    
    @State private var isRefreshing = false
    @State private var pullProgress: CGFloat = 0
    @State private var contentOffset: CGFloat = 0
    
    private let refreshThreshold: CGFloat = 80
    
    init(@ViewBuilder content: () -> Content, onRefresh: @escaping () async -> Void) {
        self.content = content()
        self.onRefresh = onRefresh
    }
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 0) {
                    // Refresh indicator
                    RefreshIndicator(
                        progress: pullProgress,
                        isRefreshing: isRefreshing
                    )
                    .frame(height: refreshThreshold)
                    .offset(y: -refreshThreshold + (pullProgress * refreshThreshold))
                    
                    // Main content
                    content
                        .anchorPreference(
                            key: ScrollOffsetKey.self,
                            value: .top
                        ) { geometry[$0].y }
                }
            }
            .onPreferenceChange(ScrollOffsetKey.self) { offset in
                handleScrollOffset(offset, in: geometry)
            }
        }
    }
    
    private func handleScrollOffset(_ offset: CGFloat, in geometry: GeometryProxy) {
        contentOffset = offset
        
        if !isRefreshing {
            let pullDistance = max(0, offset - geometry.safeAreaInsets.top)
            pullProgress = min(1, pullDistance / refreshThreshold)
            
            if pullProgress >= 1 && !isRefreshing {
                triggerRefresh()
            }
        }
    }
    
    private func triggerRefresh() {
        isRefreshing = true
        
        Task {
            // Add haptic feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
            
            await onRefresh()
            
            withAnimation(.spring()) {
                isRefreshing = false
                pullProgress = 0
            }
        }
    }
}

// MARK: - Refresh Indicator
struct RefreshIndicator: View {
    let progress: CGFloat
    let isRefreshing: Bool
    
    var body: some View {
        ZStack {
            if isRefreshing {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.2)
            } else {
                Image(systemName: "arrow.down")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                    .rotationEffect(.degrees(progress * 180))
                    .opacity(progress)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: progress)
        .animation(.easeInOut(duration: 0.2), value: isRefreshing)
    }
}

// MARK: - Scroll Offset Preference Key
struct ScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        Color.blue
        
        RefreshableScrollView {
            VStack(spacing: 20) {
                ForEach(0..<10) { index in
                    Text("Item \(index)")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(10)
                }
            }
            .padding()
        } onRefresh: {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            print("Refreshed!")
        }
    }
}