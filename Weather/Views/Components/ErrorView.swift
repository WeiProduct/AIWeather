import SwiftUI

struct ErrorView: View {
    let error: Error
    let retryAction: (() -> Void)?
    
    private var errorMessage: String {
        if let networkError = error as? NetworkError {
            return networkError.localizedDescription
        } else if let weatherError = error as? WeatherError {
            return weatherError.localizedDescription
        } else {
            return error.localizedDescription
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 50))
                .foregroundColor(.orange)
            
            Text("出错了")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)
            
            Text(errorMessage)
                .font(.system(size: 16))
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            if let retryAction = retryAction {
                Button(action: retryAction) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 16))
                        Text("重试")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color.white.opacity(0.2))
                    )
                }
            }
        }
        .padding(32)
        .cardBackground()
    }
}

// MARK: - Toast Error View
struct ToastErrorView: View {
    let message: String
    @Binding var isShowing: Bool
    
    var body: some View {
        VStack {
            Spacer()
            
            HStack(spacing: 12) {
                Image(systemName: "exclamationmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                
                Text(message)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                    .lineLimit(2)
                
                Spacer()
                
                Button(action: { isShowing = false }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.red.opacity(0.9))
            )
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
        .animation(.spring(), value: isShowing)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                isShowing = false
            }
        }
    }
}

// MARK: - Error State Modifier
struct ErrorStateModifier: ViewModifier {
    @Binding var error: Error?
    let retryAction: (() -> Void)?
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            if let error = error {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        self.error = nil
                    }
                
                ErrorView(error: error, retryAction: retryAction)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.easeInOut, value: error != nil)
    }
}

extension View {
    func errorOverlay(error: Binding<Error?>, retryAction: (() -> Void)? = nil) -> some View {
        modifier(ErrorStateModifier(error: error, retryAction: retryAction))
    }
}

// MARK: - Preview
#Preview("Error View") {
    ZStack {
        Color.blue
        ErrorView(error: NetworkError.networkUnavailable) {
            print("Retry tapped")
        }
    }
}

#Preview("Toast Error") {
    ZStack {
        Color.gray
        ToastErrorView(message: "网络连接失败，请检查您的网络设置", isShowing: .constant(true))
    }
}