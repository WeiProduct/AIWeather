import SwiftUI
import Charts

struct WeatherTrendsCard: View {
    let forecast: [ForecastItem]
    @State private var isExpanded: Bool = false
    @State private var selectedChartType: ChartType = .temperature
    @State private var selectedTimeRange: TimeRange = .day
    
    private var trendData: TrendSeries {
        TrendDataGenerator.generateTrendData(
            from: forecast,
            type: selectedChartType,
            range: selectedTimeRange
        )
    }
    
    private var valueRange: (min: Double, max: Double) {
        TrendDataGenerator.getValueRange(for: trendData)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // 标题栏
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 16))
                Text(LocalizedText.get("weather_trends"))
                    .font(.system(size: 16, weight: .medium))
                Spacer()
                
                if isExpanded {
                    // 时间范围选择器
                    Menu {
                        ForEach(TimeRange.allCases, id: \.self) { range in
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    selectedTimeRange = range
                                }
                            }) {
                                HStack {
                                    Text(range.displayName)
                                    if selectedTimeRange == range {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text(selectedTimeRange.displayName)
                                .font(.system(size: 12))
                            Image(systemName: "chevron.down")
                                .font(.system(size: 10))
                        }
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white.opacity(0.2))
                        )
                    }
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
                VStack(spacing: 12) {
                    // 图表类型选择器
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(ChartType.allCases, id: \.self) { type in
                                ChartTypeButton(
                                    type: type,
                                    isSelected: selectedChartType == type
                                ) {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        selectedChartType = type
                                    }
                                }
                            }
                        }
                    }
                    
                    // 图表
                    if #available(iOS 16.0, *) {
                        ChartView(
                            trendData: trendData,
                            valueRange: valueRange
                        )
                        .frame(height: 200)
                    } else {
                        // iOS 16 以下的备用视图
                        LegacyChartView(
                            trendData: trendData,
                            valueRange: valueRange
                        )
                        .frame(height: 200)
                    }
                    
                    // 数值标签
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(LocalizedText.get("current"))
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.6))
                            if let currentValue = trendData.dataPoints.first?.value {
                                Text("\(Int(currentValue))\(trendData.unit)")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white)
                            }
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .center, spacing: 4) {
                            Text(LocalizedText.get("average"))
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.6))
                            let avgValue = trendData.dataPoints.map { $0.value }.reduce(0, +) / Double(trendData.dataPoints.count)
                            Text("\(Int(avgValue))\(trendData.unit)")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text(LocalizedText.get("maximum"))
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.6))
                            if let maxValue = trendData.dataPoints.map({ $0.value }).max() {
                                Text("\(Int(maxValue))\(trendData.unit)")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white)
                            }
                        }
                    }
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

// MARK: - 图表类型按钮
struct ChartTypeButton: View {
    let type: ChartType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: type.icon)
                    .font(.system(size: 20))
                Text(type.displayName)
                    .font(.system(size: 12))
            }
            .foregroundColor(isSelected ? .black : .white)
            .frame(width: 80, height: 60)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.white : Color.white.opacity(0.2))
            )
        }
    }
}

// MARK: - iOS 16+ 图表视图
@available(iOS 16.0, *)
struct ChartView: View {
    let trendData: TrendSeries
    let valueRange: (min: Double, max: Double)
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = trendData.dataPoints.count > 8 ? "HH" : "HH:mm"
        return formatter.string(from: date)
    }
    
    var body: some View {
        Chart(trendData.dataPoints) { point in
            LineMark(
                x: .value("Time", point.date),
                y: .value("Value", point.value)
            )
            .foregroundStyle(
                LinearGradient(
                    colors: [
                        Color(hex: trendData.color),
                        Color(hex: trendData.color).opacity(0.5)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .lineStyle(StrokeStyle(lineWidth: 2))
            
            AreaMark(
                x: .value("Time", point.date),
                y: .value("Value", point.value)
            )
            .foregroundStyle(
                LinearGradient(
                    colors: [
                        Color(hex: trendData.color).opacity(0.3),
                        Color(hex: trendData.color).opacity(0.05)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
        .chartXAxis {
            AxisMarks { value in
                if let date = value.as(Date.self) {
                    AxisValueLabel {
                        Text(formatDate(date))
                            .font(.system(size: 10))
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) { value in
                if let doubleValue = value.as(Double.self) {
                    AxisValueLabel {
                        Text("\(Int(doubleValue))")
                            .font(.system(size: 10))
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
            }
        }
        .chartYScale(domain: valueRange.min...valueRange.max)
    }
}

// MARK: - iOS 16 以下的备用图表视图
struct LegacyChartView: View {
    let trendData: TrendSeries
    let valueRange: (min: Double, max: Double)
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 背景网格
                Path { path in
                    let rows = 4
                    let rowHeight = geometry.size.height / CGFloat(rows)
                    
                    for i in 0...rows {
                        let y = CGFloat(i) * rowHeight
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: geometry.size.width, y: y))
                    }
                }
                .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
                
                // 折线图
                if !trendData.dataPoints.isEmpty {
                    Path { path in
                        let points = calculatePoints(in: geometry.size)
                        
                        path.move(to: points[0])
                        for i in 1..<points.count {
                            path.addLine(to: points[i])
                        }
                    }
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color(hex: trendData.color),
                                Color(hex: trendData.color).opacity(0.7)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        lineWidth: 2
                    )
                    
                    // 填充区域
                    Path { path in
                        let points = calculatePoints(in: geometry.size)
                        
                        path.move(to: CGPoint(x: points[0].x, y: geometry.size.height))
                        path.addLine(to: points[0])
                        
                        for i in 1..<points.count {
                            path.addLine(to: points[i])
                        }
                        
                        path.addLine(to: CGPoint(x: points.last!.x, y: geometry.size.height))
                        path.closeSubpath()
                    }
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: trendData.color).opacity(0.3),
                                Color(hex: trendData.color).opacity(0.05)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    
                    // 数据点
                    ForEach(Array(calculatePoints(in: geometry.size).enumerated()), id: \.offset) { index, point in
                        Circle()
                            .fill(Color(hex: trendData.color))
                            .frame(width: 6, height: 6)
                            .position(point)
                    }
                }
                
                // X轴标签
                VStack {
                    Spacer()
                    HStack {
                        ForEach(Array(trendData.dataPoints.enumerated()), id: \.offset) { index, dataPoint in
                            if index % max(1, trendData.dataPoints.count / 6) == 0 {
                                Text(dataPoint.label)
                                    .font(.system(size: 10))
                                    .foregroundColor(.white.opacity(0.6))
                                    .frame(maxWidth: .infinity)
                            }
                        }
                    }
                }
                .padding(.bottom, -20)
            }
        }
    }
    
    private func calculatePoints(in size: CGSize) -> [CGPoint] {
        guard !trendData.dataPoints.isEmpty else { return [] }
        
        let xStep = size.width / CGFloat(max(1, trendData.dataPoints.count - 1))
        let range = valueRange.max - valueRange.min
        
        return trendData.dataPoints.enumerated().map { index, point in
            let x = CGFloat(index) * xStep
            let normalizedValue = (point.value - valueRange.min) / range
            let y = size.height * (1 - normalizedValue)
            return CGPoint(x: x, y: y)
        }
    }
}