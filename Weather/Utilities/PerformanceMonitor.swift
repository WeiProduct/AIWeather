import Foundation
import os.log

class PerformanceMonitor {
    static let shared = PerformanceMonitor()
    private let logger = Logger(subsystem: "com.weather.app", category: "Performance")
    
    private init() {}
    
    // MARK: - App Launch Time
    private var appLaunchStartTime: CFAbsoluteTime = 0
    
    func startAppLaunchTimer() {
        appLaunchStartTime = CFAbsoluteTimeGetCurrent()
    }
    
    func endAppLaunchTimer() {
        let launchTime = CFAbsoluteTimeGetCurrent() - appLaunchStartTime
        logger.info("App launch completed in \(launchTime, format: .fixed(precision: 2)) seconds")
        
        #if DEBUG
        if launchTime > 1.0 {
            logger.warning("App launch time exceeded 1 second")
        }
        #endif
    }
    
    // MARK: - Network Performance
    func logNetworkRequest(url: String, startTime: CFAbsoluteTime) {
        let duration = CFAbsoluteTimeGetCurrent() - startTime
        logger.info("Network request to \(url) completed in \(duration, format: .fixed(precision: 3)) seconds")
        
        #if DEBUG
        if duration > 2.0 {
            logger.warning("Network request exceeded 2 seconds: \(url)")
        }
        #endif
    }
    
    // MARK: - Memory Usage
    func logMemoryUsage() {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4
        
        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                         task_flavor_t(MACH_TASK_BASIC_INFO),
                         $0,
                         &count)
            }
        }
        
        if result == KERN_SUCCESS {
            let usedMemory = Double(info.resident_size) / 1024.0 / 1024.0
            logger.info("Memory usage: \(usedMemory, format: .fixed(precision: 1)) MB")
            
            #if DEBUG
            if usedMemory > 100 {
                logger.warning("Memory usage exceeded 100 MB")
            }
            #endif
        }
    }
    
    // MARK: - Custom Performance Markers
    private var performanceMarkers: [String: CFAbsoluteTime] = [:]
    
    func startMeasuring(_ marker: String) {
        performanceMarkers[marker] = CFAbsoluteTimeGetCurrent()
    }
    
    func endMeasuring(_ marker: String) {
        guard let startTime = performanceMarkers[marker] else {
            logger.error("No start time found for marker: \(marker)")
            return
        }
        
        let duration = CFAbsoluteTimeGetCurrent() - startTime
        logger.info("\(marker) completed in \(duration, format: .fixed(precision: 3)) seconds")
        performanceMarkers.removeValue(forKey: marker)
    }
}

// MARK: - Performance Tips
extension PerformanceMonitor {
    func logPerformanceTips() {
        logger.info("""
        Performance Optimization Tips:
        1. Use lazy loading for heavy views
        2. Cache network responses appropriately
        3. Optimize image sizes and formats
        4. Use instruments to profile the app
        5. Minimize main thread blocking operations
        6. Use background queues for heavy computations
        """)
    }
}