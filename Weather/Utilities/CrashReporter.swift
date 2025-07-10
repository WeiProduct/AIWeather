import Foundation
import os.log

// Simple crash reporter that captures and logs crashes
// For production, integrate Firebase Crashlytics or Sentry
class CrashReporter {
    static let shared = CrashReporter()
    private let logger = Logger(subsystem: "com.weather.app", category: "CrashReporter")
    private let crashLogFile = "crash_logs.json"
    
    private init() {
        setupCrashHandling()
    }
    
    // MARK: - Crash Handling Setup
    private func setupCrashHandling() {
        // Set up exception handler
        NSSetUncaughtExceptionHandler { exception in
            CrashReporter.shared.handleException(exception)
        }
        
        // Set up signal handlers for crashes
        signal(SIGABRT) { _ in
            CrashReporter.shared.handleSignal("SIGABRT")
        }
        
        signal(SIGSEGV) { _ in
            CrashReporter.shared.handleSignal("SIGSEGV")
        }
        
        signal(SIGBUS) { _ in
            CrashReporter.shared.handleSignal("SIGBUS")
        }
        
        signal(SIGILL) { _ in
            CrashReporter.shared.handleSignal("SIGILL")
        }
    }
    
    // MARK: - Crash Recording
    private func handleException(_ exception: NSException) {
        let crashInfo = CrashInfo(
            type: .exception,
            name: exception.name.rawValue,
            reason: exception.reason,
            stackTrace: exception.callStackSymbols,
            timestamp: Date(),
            appVersion: getAppVersion(),
            osVersion: getOSVersion()
        )
        
        saveCrashInfo(crashInfo)
        logger.critical("Uncaught exception: \(exception.name.rawValue) - \(exception.reason ?? "No reason")")
    }
    
    private func handleSignal(_ signal: String) {
        let crashInfo = CrashInfo(
            type: .signal,
            name: signal,
            reason: "Signal received: \(signal)",
            stackTrace: Thread.callStackSymbols,
            timestamp: Date(),
            appVersion: getAppVersion(),
            osVersion: getOSVersion()
        )
        
        saveCrashInfo(crashInfo)
        logger.critical("Signal received: \(signal)")
    }
    
    // MARK: - Non-Fatal Error Reporting
    func logError(_ error: Error, file: String = #file, function: String = #function, line: Int = #line) {
        let errorInfo = ErrorInfo(
            error: error.localizedDescription,
            file: URL(fileURLWithPath: file).lastPathComponent,
            function: function,
            line: line,
            timestamp: Date(),
            appVersion: getAppVersion()
        )
        
        logger.error("Error in \(errorInfo.file):\(errorInfo.line) - \(errorInfo.function): \(error.localizedDescription)")
        
        // In production, send to crash reporting service
        #if DEBUG
        print("🔴 Error: \(errorInfo)")
        #endif
    }
    
    // MARK: - Breadcrumbs (User Actions)
    internal var breadcrumbs: [Breadcrumb] = []
    private let maxBreadcrumbs = 20
    
    func addBreadcrumb(_ action: String, category: String = "user_action") {
        let breadcrumb = Breadcrumb(
            action: action,
            category: category,
            timestamp: Date()
        )
        
        breadcrumbs.append(breadcrumb)
        
        // Keep only recent breadcrumbs
        if breadcrumbs.count > maxBreadcrumbs {
            breadcrumbs.removeFirst()
        }
        
        logger.info("Breadcrumb: \(category) - \(action)")
    }
    
    // MARK: - Crash Report Management
    private func saveCrashInfo(_ crashInfo: CrashInfo) {
        // In production, send to crash reporting service
        // For now, save locally
        
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        
        let fileURL = documentsDirectory.appendingPathComponent(crashLogFile)
        
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(crashInfo)
            
            // Append to existing crashes
            if FileManager.default.fileExists(atPath: fileURL.path) {
                try data.write(to: fileURL)
            } else {
                try data.write(to: fileURL)
            }
        } catch {
            logger.error("Failed to save crash info: \(error.localizedDescription)")
        }
    }
    
    func getPendingCrashReports() -> [CrashInfo] {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return []
        }
        
        let fileURL = documentsDirectory.appendingPathComponent(crashLogFile)
        
        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            let crashes = try decoder.decode([CrashInfo].self, from: data)
            return crashes
        } catch {
            return []
        }
    }
    
    func clearCrashReports() {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        
        let fileURL = documentsDirectory.appendingPathComponent(crashLogFile)
        try? FileManager.default.removeItem(at: fileURL)
    }
    
    // MARK: - Helper Methods
    private func getAppVersion() -> String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "Unknown"
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "Unknown"
        return "\(version) (\(build))"
    }
    
    private func getOSVersion() -> String {
        let osVersion = ProcessInfo.processInfo.operatingSystemVersion
        return "\(osVersion.majorVersion).\(osVersion.minorVersion).\(osVersion.patchVersion)"
    }
}

// MARK: - Data Models
struct CrashInfo: Codable {
    enum CrashType: String, Codable {
        case exception
        case signal
    }
    
    let type: CrashType
    let name: String
    let reason: String?
    let stackTrace: [String]
    let timestamp: Date
    let appVersion: String
    let osVersion: String
    let breadcrumbs: [Breadcrumb]?
    
    init(type: CrashType, name: String, reason: String?, stackTrace: [String], timestamp: Date, appVersion: String, osVersion: String) {
        self.type = type
        self.name = name
        self.reason = reason
        self.stackTrace = stackTrace
        self.timestamp = timestamp
        self.appVersion = appVersion
        self.osVersion = osVersion
        self.breadcrumbs = CrashReporter.shared.breadcrumbs
    }
}

struct ErrorInfo: Codable {
    let error: String
    let file: String
    let function: String
    let line: Int
    let timestamp: Date
    let appVersion: String
}

struct Breadcrumb: Codable {
    let action: String
    let category: String
    let timestamp: Date
}

// MARK: - Crash Reporter Configuration
extension CrashReporter {
    func configure() {
        // Check for pending crash reports on app launch
        let pendingCrashes = getPendingCrashReports()
        if !pendingCrashes.isEmpty {
            logger.warning("Found \(pendingCrashes.count) pending crash reports")
            // In production, send these to your crash reporting service
            // Then clear them
            clearCrashReports()
        }
        
        // Log app launch
        addBreadcrumb("app_launched", category: "lifecycle")
    }
}