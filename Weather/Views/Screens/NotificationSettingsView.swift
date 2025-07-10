import SwiftUI

struct NotificationSettingsView: View {
    @ObservedObject var notificationManager = NotificationManager.shared
    @State private var showingPermissionAlert = false
    @State private var selectedAlertType: WeatherAlertType?
    @State private var showingAlertConfig = false
    
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
                        // Permission Status Card
                        if !notificationManager.hasNotificationPermission {
                            PermissionCard()
                                .padding(.horizontal, 20)
                        }
                        
                        // Weather Alerts Section
                        VStack(alignment: .leading, spacing: 15) {
                            SectionHeader(title: LocalizedText.get("weather_alerts"))
                            
                            ForEach(WeatherAlertType.allCases, id: \.self) { alertType in
                                AlertTypeRow(
                                    alertType: alertType,
                                    threshold: binding(for: alertType),
                                    onTap: {
                                        selectedAlertType = alertType
                                        showingAlertConfig = true
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Daily Reminders Section
                        VStack(alignment: .leading, spacing: 15) {
                            SectionHeader(title: LocalizedText.get("daily_reminders"))
                            
                            DailyReminderCard(settings: $notificationManager.dailyReminderSettings)
                        }
                        .padding(.horizontal, 20)
                        
                        // Quiet Hours Section
                        VStack(alignment: .leading, spacing: 15) {
                            SectionHeader(title: LocalizedText.get("quiet_hours"))
                            
                            QuietHoursCard(
                                enabled: $notificationManager.quietHoursEnabled,
                                startTime: $notificationManager.quietHoursStart,
                                endTime: $notificationManager.quietHoursEnd
                            )
                        }
                        .padding(.horizontal, 20)
                        
                        Spacer(minLength: 30)
                    }
                    .padding(.top, 20)
                }
            }
            .navigationTitle(LocalizedText.get("notification_settings"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(LocalizedText.get("save")) {
                        notificationManager.saveSettings()
                    }
                    .foregroundColor(.white)
                }
            }
        }
        .sheet(isPresented: $showingAlertConfig) {
            if let alertType = selectedAlertType,
               let index = notificationManager.weatherAlertSettings.firstIndex(where: { $0.type == alertType }) {
                AlertConfigurationView(threshold: $notificationManager.weatherAlertSettings[index])
            }
        }
        .alert(LocalizedText.get("enable_notifications"), isPresented: $showingPermissionAlert) {
            Button(LocalizedText.get("go_to_settings")) {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button(LocalizedText.get("cancel"), role: .cancel) {}
        } message: {
            Text(LocalizedText.get("notification_permission_message"))
        }
        .localizedView()
    }
    
    private func binding(for alertType: WeatherAlertType) -> Binding<AlertThreshold> {
        let index = notificationManager.weatherAlertSettings.firstIndex(where: { $0.type == alertType }) ?? 0
        return $notificationManager.weatherAlertSettings[index]
    }
}

// MARK: - Permission Card
struct PermissionCard: View {
    @ObservedObject var notificationManager = NotificationManager.shared
    
    var body: some View {
        VStack(spacing: 15) {
            Image(systemName: "bell.slash")
                .font(.system(size: 40))
                .foregroundColor(.white.opacity(0.8))
            
            Text(LocalizedText.get("notifications_disabled"))
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
            
            Text(LocalizedText.get("enable_notifications_desc"))
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
            
            Button(action: {
                Task {
                    await notificationManager.requestNotificationPermission()
                }
            }) {
                Text(LocalizedText.get("enable_notifications"))
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.blue)
                    )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.15))
        )
    }
}

// MARK: - Alert Type Row
struct AlertTypeRow: View {
    let alertType: WeatherAlertType
    @Binding var threshold: AlertThreshold
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Image(systemName: alertType.icon)
                    .font(.system(size: 20))
                    .foregroundColor(.white.opacity(0.8))
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(alertType.displayName)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                    
                    if let subtitle = getSubtitle() {
                        Text(subtitle)
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
                
                Spacer()
                
                Toggle("", isOn: $threshold.enabled)
                    .labelsHidden()
                    .scaleEffect(0.8)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.15))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func getSubtitle() -> String? {
        guard threshold.enabled else { return nil }
        
        switch alertType {
        case .temperatureChange:
            if let min = threshold.minValue, let max = threshold.maxValue {
                return "\(Int(min))°C - \(Int(max))°C"
            }
        case .precipitation:
            if let min = threshold.minValue {
                return "> \(Int(min))%"
            }
        case .uvIndex:
            if let min = threshold.minValue {
                return "> \(Int(min))"
            }
        default:
            return nil
        }
        return nil
    }
}

// MARK: - Daily Reminder Card
struct DailyReminderCard: View {
    @Binding var settings: DailyReminderSettings
    @State private var showingTimeConfig = false
    
    var body: some View {
        VStack(spacing: 15) {
            // Enable Toggle
            HStack {
                Text(LocalizedText.get("daily_weather_reminders"))
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                
                Spacer()
                
                Toggle("", isOn: $settings.enabled)
                    .labelsHidden()
            }
            
            if settings.enabled {
                // Reminder Times
                VStack(spacing: 12) {
                    TimeRow(
                        label: LocalizedText.get("morning_reminder"),
                        time: settings.morningTime ?? Date(),
                        isEnabled: settings.morningTime != nil,
                        onToggle: { enabled in
                            settings.morningTime = enabled ? DateComponents(calendar: .current, hour: 7, minute: 0).date! : nil
                        },
                        onTimeChange: { newTime in
                            settings.morningTime = newTime
                        }
                    )
                    
                    TimeRow(
                        label: LocalizedText.get("evening_reminder"),
                        time: settings.eveningTime ?? Date(),
                        isEnabled: settings.eveningTime != nil,
                        onToggle: { enabled in
                            settings.eveningTime = enabled ? DateComponents(calendar: .current, hour: 18, minute: 0).date! : nil
                        },
                        onTimeChange: { newTime in
                            settings.eveningTime = newTime
                        }
                    )
                }
                
                Divider()
                    .background(Color.white.opacity(0.3))
                
                // Content Options
                VStack(alignment: .leading, spacing: 10) {
                    Text(LocalizedText.get("include_in_reminder"))
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.7))
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 10) {
                        ForEach(DailyReminderSettings.WeatherDataType.allCases, id: \.self) { dataType in
                            DataTypeChip(
                                dataType: dataType,
                                isSelected: settings.selectedDataTypes.contains(dataType),
                                onToggle: { selected in
                                    if selected {
                                        settings.selectedDataTypes.insert(dataType)
                                    } else {
                                        settings.selectedDataTypes.remove(dataType)
                                    }
                                }
                            )
                        }
                    }
                    
                    // Additional Options
                    OptionRow(
                        label: LocalizedText.get("include_weekly_outlook"),
                        isOn: $settings.includeWeeklyOutlook
                    )
                    
                    OptionRow(
                        label: LocalizedText.get("include_clothing_suggestion"),
                        isOn: $settings.includeClothingSuggestion
                    )
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.15))
        )
    }
}

// MARK: - Time Row
struct TimeRow: View {
    let label: String
    let time: Date
    let isEnabled: Bool
    let onToggle: (Bool) -> Void
    let onTimeChange: (Date) -> Void
    
    @State private var showingTimePicker = false
    
    var body: some View {
        HStack {
            Toggle(isOn: Binding(
                get: { isEnabled },
                set: { onToggle($0) }
            )) {
                Text(label)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.8))
            }
            
            if isEnabled {
                Spacer()
                
                Button(action: {
                    showingTimePicker = true
                }) {
                    Text(timeString(from: time))
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white.opacity(0.2))
                        )
                }
            }
        }
        .sheet(isPresented: $showingTimePicker) {
            TimePickerSheet(time: time, onSave: onTimeChange)
        }
    }
    
    private func timeString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Data Type Chip
struct DataTypeChip: View {
    let dataType: DailyReminderSettings.WeatherDataType
    let isSelected: Bool
    let onToggle: (Bool) -> Void
    
    var body: some View {
        Button(action: {
            onToggle(!isSelected)
        }) {
            Text(dataType.displayName)
                .font(.system(size: 12))
                .foregroundColor(isSelected ? .white : .white.opacity(0.7))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isSelected ? Color.blue.opacity(0.8) : Color.white.opacity(0.2))
                )
        }
    }
}

// MARK: - Option Row
struct OptionRow: View {
    let label: String
    @Binding var isOn: Bool
    
    var body: some View {
        Toggle(isOn: $isOn) {
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.8))
        }
    }
}

// MARK: - Quiet Hours Card
struct QuietHoursCard: View {
    @Binding var enabled: Bool
    @Binding var startTime: Date
    @Binding var endTime: Date
    
    var body: some View {
        VStack(spacing: 15) {
            HStack {
                Text(LocalizedText.get("quiet_hours"))
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                
                Spacer()
                
                Toggle("", isOn: $enabled)
                    .labelsHidden()
            }
            
            if enabled {
                HStack {
                    TimeSelector(label: LocalizedText.get("from"), time: $startTime)
                    
                    Spacer()
                    
                    TimeSelector(label: LocalizedText.get("to"), time: $endTime)
                }
            }
            
            Text(LocalizedText.get("quiet_hours_desc"))
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.leading)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.15))
        )
    }
}

// MARK: - Time Selector
struct TimeSelector: View {
    let label: String
    @Binding var time: Date
    @State private var showingPicker = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.6))
            
            Button(action: {
                showingPicker = true
            }) {
                Text(timeString(from: time))
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white.opacity(0.2))
                    )
            }
        }
        .sheet(isPresented: $showingPicker) {
            TimePickerSheet(time: time, onSave: { newTime in
                time = newTime
            })
        }
    }
    
    private func timeString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Section Header
struct SectionHeader: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.system(size: 18, weight: .semibold))
            .foregroundColor(.white)
    }
}

// MARK: - Time Picker Sheet
struct TimePickerSheet: View {
    let time: Date
    let onSave: (Date) -> Void
    
    @State private var selectedTime: Date
    @Environment(\.dismiss) private var dismiss
    
    init(time: Date, onSave: @escaping (Date) -> Void) {
        self.time = time
        self.onSave = onSave
        self._selectedTime = State(initialValue: time)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                DatePicker(
                    "",
                    selection: $selectedTime,
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(WheelDatePickerStyle())
                .labelsHidden()
                
                Spacer()
            }
            .navigationTitle(LocalizedText.get("select_time"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(LocalizedText.get("cancel")) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(LocalizedText.get("done")) {
                        onSave(selectedTime)
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    NotificationSettingsView()
}