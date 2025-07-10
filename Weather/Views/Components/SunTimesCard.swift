import SwiftUI

struct SunTimesCard: View {
    let sunTimes: SunTimes
    @State private var currentDate = Date()
    @State private var timer: Timer?
    @State private var isExpanded: Bool = false
    
    private let cardHeight: CGFloat = 200
    
    var body: some View {
        VStack(spacing: 0) {
            // 标题栏
            HStack {
                Image(systemName: "sun.max.fill")
                    .font(.system(size: 16))
                Text(LocalizedText.get("sun_times"))
                    .font(.system(size: 16, weight: .medium))
                Spacer()
                Text(sunTimes.formattedDayLength)
                    .font(.system(size: 14))
                    .opacity(0.8)
                
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isExpanded.toggle()
                    }
                }) {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.top, 15)
            .padding(.bottom, isExpanded ? 0 : 15)
            
            if isExpanded {
                // 太阳轨迹图
                GeometryReader { geometry in
                ZStack {
                    // 地平线
                    Path { path in
                        path.move(to: CGPoint(x: 0, y: geometry.size.height * 0.7))
                        path.addLine(to: CGPoint(x: geometry.size.width, y: geometry.size.height * 0.7))
                    }
                    .stroke(Color.white.opacity(0.3), style: StrokeStyle(lineWidth: 1, dash: [5, 5]))
                    
                    // 太阳轨迹弧线
                    Path { path in
                        let startX: CGFloat = 30
                        let endX = geometry.size.width - 30
                        let centerY = geometry.size.height * 0.7
                        let peakY: CGFloat = 20
                        
                        path.move(to: CGPoint(x: startX, y: centerY))
                        path.addCurve(
                            to: CGPoint(x: endX, y: centerY),
                            control1: CGPoint(x: geometry.size.width * 0.3, y: peakY),
                            control2: CGPoint(x: geometry.size.width * 0.7, y: peakY)
                        )
                    }
                    .stroke(
                        LinearGradient(
                            colors: [Color.yellow.opacity(0.3), Color.orange.opacity(0.5)],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        lineWidth: 2
                    )
                    
                    // 当前太阳位置
                    if let position = sunTimes.currentSunPosition(at: currentDate) {
                        let sunX = 30 + (geometry.size.width - 60) * position
                        let sunY = calculateSunY(position: position, height: geometry.size.height)
                        
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [.yellow, .orange],
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: 12
                                )
                            )
                            .frame(width: 24, height: 24)
                            .position(x: sunX, y: sunY)
                            .shadow(color: .yellow.opacity(0.5), radius: 10)
                    }
                    
                    // 时间标记
                    VStack {
                        Spacer()
                        HStack {
                            // 日出时间
                            VStack(spacing: 4) {
                                Image(systemName: "sunrise.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.orange)
                                Text(formatTime(sunTimes.sunrise))
                                    .font(.system(size: 12))
                                    .foregroundColor(.white)
                            }
                            
                            Spacer()
                            
                            // 正午
                            VStack(spacing: 4) {
                                Image(systemName: "sun.max.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.yellow)
                                Text(formatTime(sunTimes.solarNoon))
                                    .font(.system(size: 12))
                                    .foregroundColor(.white)
                            }
                            
                            Spacer()
                            
                            // 日落时间
                            VStack(spacing: 4) {
                                Image(systemName: "sunset.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.orange)
                                Text(formatTime(sunTimes.sunset))
                                    .font(.system(size: 12))
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.horizontal, 30)
                        .padding(.bottom, 15)
                    }
                }
            }
            .frame(height: 120)
            
                // 特殊时刻提示
                if let nextMoment = sunTimes.nextSpecialMoment(from: currentDate) {
                    HStack(spacing: 8) {
                        Image(systemName: nextMoment.moment.icon)
                            .font(.system(size: 14))
                        Text(nextMoment.moment.localizedName)
                            .font(.system(size: 14, weight: .medium))
                        Spacer()
                        Text(timeUntil(nextMoment.time))
                            .font(.system(size: 12))
                            .opacity(0.8)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 15)
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.15))
        )
        .onAppear {
            startTimer()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    private func calculateSunY(position: Double, height: CGFloat) -> CGFloat {
        let centerY = height * 0.7
        let peakY: CGFloat = 20
        // 使用抛物线公式计算Y位置
        let progress = sin(position * .pi)
        return centerY - (centerY - peakY) * progress
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: LanguageManager.shared.currentLanguage == .chinese ? "zh_CN" : "en_US")
        return formatter.string(from: date)
    }
    
    private func timeUntil(_ date: Date) -> String {
        let interval = date.timeIntervalSince(currentDate)
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        
        if LanguageManager.shared.currentLanguage == .chinese {
            if hours > 0 {
                return "\(hours)小时\(minutes)分钟后"
            } else {
                return "\(minutes)分钟后"
            }
        } else {
            if hours > 0 {
                return "in \(hours)h \(minutes)m"
            } else {
                return "in \(minutes)m"
            }
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
            currentDate = Date()
        }
    }
}

// MARK: - 黄金时刻卡片
struct GoldenHourCard: View {
    let sunTimes: SunTimes
    @State private var showingNotificationSettings = false
    @State private var isExpanded: Bool = false
    
    var body: some View {
        VStack(spacing: 12) {
            // 标题
            HStack {
                Image(systemName: "camera.fill")
                    .font(.system(size: 16))
                Text(LocalizedText.get("photography_times"))
                    .font(.system(size: 16, weight: .medium))
                Spacer()
                Button(action: {
                    showingNotificationSettings = true
                }) {
                    Image(systemName: "bell.badge")
                        .font(.system(size: 14))
                }
                
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isExpanded.toggle()
                    }
                }) {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            .foregroundColor(.white)
            
            if isExpanded {
                // 时间段列表
                VStack(spacing: 8) {
                    // 早晨蓝调时刻
                    TimeRangeRow(
                        icon: "moon.stars.fill",
                        title: LocalizedText.get("morning_blue_hour"),
                        startTime: sunTimes.morningBlueHourStart,
                        endTime: sunTimes.morningBlueHourEnd,
                        color: .blue
                    )
                    
                    // 早晨黄金时刻
                    TimeRangeRow(
                        icon: "camera.fill",
                        title: LocalizedText.get("morning_golden_hour"),
                        startTime: sunTimes.morningGoldenHourStart,
                        endTime: sunTimes.morningGoldenHourEnd,
                        color: .orange
                    )
                    
                    // 傍晚黄金时刻
                    TimeRangeRow(
                        icon: "camera.fill",
                        title: LocalizedText.get("evening_golden_hour"),
                        startTime: sunTimes.eveningGoldenHourStart,
                        endTime: sunTimes.eveningGoldenHourEnd,
                        color: .orange
                    )
                    
                    // 傍晚蓝调时刻
                    TimeRangeRow(
                        icon: "moon.stars.fill",
                        title: LocalizedText.get("evening_blue_hour"),
                        startTime: sunTimes.eveningBlueHourStart,
                        endTime: sunTimes.eveningBlueHourEnd,
                        color: .blue
                    )
                }
                
                // 当前状态提示
                if sunTimes.isInGoldenHour() {
                    HStack {
                        Image(systemName: "sparkles")
                        Text(LocalizedText.get("golden_hour_now"))
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundColor(.yellow)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.yellow.opacity(0.2))
                    )
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.15))
        )
    }
}

// MARK: - 时间范围行
struct TimeRangeRow: View {
    let icon: String
    let title: String
    let startTime: Date
    let endTime: Date
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(color)
                .frame(width: 20)
            
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.9))
            
            Spacer()
            
            Text("\(formatTime(startTime)) - \(formatTime(endTime))")
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.7))
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: LanguageManager.shared.currentLanguage == .chinese ? "zh_CN" : "en_US")
        return formatter.string(from: date)
    }
}