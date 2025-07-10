import SwiftUI

struct AlertConfigurationView: View {
    @Binding var threshold: AlertThreshold
    @Environment(\.dismiss) private var dismiss
    
    @State private var minValue: String = ""
    @State private var maxValue: String = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [Color(hex: "#1E3C72"), Color(hex: "#2A5298")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Alert Type Info
                        VStack(spacing: 15) {
                            Image(systemName: threshold.type.icon)
                                .font(.system(size: 50))
                                .foregroundColor(.white.opacity(0.8))
                            
                            Text(threshold.type.displayName)
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundColor(.white)
                            
                            Text(getDescription())
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.7))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                        }
                        .padding(.top, 20)
                        
                        // Configuration Section
                        VStack(spacing: 20) {
                            // Enable/Disable Toggle
                            HStack {
                                Text(LocalizedText.get("enable_alert"))
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                Toggle("", isOn: $threshold.enabled)
                                    .labelsHidden()
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white.opacity(0.15))
                            )
                            
                            if threshold.enabled {
                                // Threshold Values
                                VStack(spacing: 15) {
                                    if shouldShowMinValue() {
                                        ThresholdInput(
                                            label: getMinLabel(),
                                            value: $minValue,
                                            unit: getUnit(),
                                            placeholder: getMinPlaceholder()
                                        )
                                    }
                                    
                                    if shouldShowMaxValue() {
                                        ThresholdInput(
                                            label: getMaxLabel(),
                                            value: $maxValue,
                                            unit: getUnit(),
                                            placeholder: getMaxPlaceholder()
                                        )
                                    }
                                }
                                
                                // Preset Options
                                if let presets = getPresets() {
                                    VStack(alignment: .leading, spacing: 10) {
                                        Text(LocalizedText.get("preset_options"))
                                            .font(.system(size: 14))
                                            .foregroundColor(.white.opacity(0.7))
                                        
                                        ForEach(presets, id: \.label) { preset in
                                            Button(action: {
                                                applyPreset(preset)
                                            }) {
                                                HStack {
                                                    Text(preset.label)
                                                        .font(.system(size: 14))
                                                        .foregroundColor(.white)
                                                    
                                                    Spacer()
                                                    
                                                    Image(systemName: "chevron.right")
                                                        .font(.system(size: 12))
                                                        .foregroundColor(.white.opacity(0.5))
                                                }
                                                .padding(12)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 8)
                                                        .fill(Color.white.opacity(0.1))
                                                )
                                            }
                                        }
                                    }
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.white.opacity(0.15))
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        Spacer(minLength: 50)
                    }
                }
            }
            .navigationTitle(LocalizedText.get("configure_alert"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(LocalizedText.get("cancel")) {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(LocalizedText.get("save")) {
                        saveThreshold()
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
        .onAppear {
            loadValues()
        }
        .localizedView()
    }
    
    // MARK: - Helper Methods
    private func getDescription() -> String {
        switch threshold.type {
        case .severeWeather:
            return LocalizedText.get("severe_weather_desc")
        case .temperatureChange:
            return LocalizedText.get("temperature_change_desc")
        case .precipitation:
            return LocalizedText.get("precipitation_alert_desc")
        case .uvIndex:
            return LocalizedText.get("uv_alert_desc")
        case .airQuality:
            return LocalizedText.get("air_quality_desc")
        }
    }
    
    private func shouldShowMinValue() -> Bool {
        switch threshold.type {
        case .temperatureChange, .precipitation, .uvIndex, .airQuality:
            return true
        case .severeWeather:
            return false
        }
    }
    
    private func shouldShowMaxValue() -> Bool {
        return threshold.type == .temperatureChange
    }
    
    private func getMinLabel() -> String {
        switch threshold.type {
        case .temperatureChange:
            return LocalizedText.get("min_temperature")
        case .precipitation:
            return LocalizedText.get("min_precipitation")
        case .uvIndex:
            return LocalizedText.get("min_uv_index")
        case .airQuality:
            return LocalizedText.get("min_aqi")
        default:
            return ""
        }
    }
    
    private func getMaxLabel() -> String {
        return LocalizedText.get("max_temperature")
    }
    
    private func getUnit() -> String {
        switch threshold.type {
        case .temperatureChange:
            return "°C"
        case .precipitation:
            return "%"
        case .uvIndex, .airQuality:
            return ""
        default:
            return ""
        }
    }
    
    private func getMinPlaceholder() -> String {
        switch threshold.type {
        case .temperatureChange:
            return "0"
        case .precipitation:
            return "60"
        case .uvIndex:
            return "7"
        case .airQuality:
            return "100"
        default:
            return ""
        }
    }
    
    private func getMaxPlaceholder() -> String {
        return "35"
    }
    
    private struct Preset {
        let label: String
        let minValue: Double?
        let maxValue: Double?
    }
    
    private func getPresets() -> [Preset]? {
        switch threshold.type {
        case .temperatureChange:
            return [
                Preset(label: LocalizedText.get("preset_mild"), minValue: 10, maxValue: 28),
                Preset(label: LocalizedText.get("preset_moderate"), minValue: 5, maxValue: 32),
                Preset(label: LocalizedText.get("preset_extreme"), minValue: 0, maxValue: 35)
            ]
        case .precipitation:
            return [
                Preset(label: LocalizedText.get("preset_light_rain"), minValue: 30, maxValue: nil),
                Preset(label: LocalizedText.get("preset_moderate_rain"), minValue: 50, maxValue: nil),
                Preset(label: LocalizedText.get("preset_heavy_rain"), minValue: 70, maxValue: nil)
            ]
        case .uvIndex:
            return [
                Preset(label: LocalizedText.get("preset_moderate_uv"), minValue: 6, maxValue: nil),
                Preset(label: LocalizedText.get("preset_high_uv"), minValue: 8, maxValue: nil),
                Preset(label: LocalizedText.get("preset_extreme_uv"), minValue: 11, maxValue: nil)
            ]
        default:
            return nil
        }
    }
    
    private func applyPreset(_ preset: Preset) {
        if let min = preset.minValue {
            minValue = String(Int(min))
        }
        if let max = preset.maxValue {
            maxValue = String(Int(max))
        }
    }
    
    private func loadValues() {
        if let min = threshold.minValue {
            minValue = String(Int(min))
        }
        if let max = threshold.maxValue {
            maxValue = String(Int(max))
        }
    }
    
    private func saveThreshold() {
        threshold.minValue = Double(minValue)
        threshold.maxValue = Double(maxValue)
    }
}

// MARK: - Threshold Input
struct ThresholdInput: View {
    let label: String
    @Binding var value: String
    let unit: String
    let placeholder: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.7))
            
            HStack {
                TextField(placeholder, text: $value)
                    .keyboardType(.numberPad)
                    .foregroundColor(.white)
                    .font(.system(size: 16))
                
                if !unit.isEmpty {
                    Text(unit)
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white.opacity(0.2))
            )
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.15))
        )
    }
}

#Preview {
    AlertConfigurationView(
        threshold: .constant(
            AlertThreshold(
                type: .temperatureChange,
                enabled: true,
                minValue: 0,
                maxValue: 35
            )
        )
    )
}