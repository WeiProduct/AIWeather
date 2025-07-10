import Foundation

// MARK: - Cache Policy
enum CachePolicy {
    case ignoreCache
    case cacheFirst
    case networkFirst
    case cacheOnly
}

// MARK: - Cache Entry
struct CacheEntry<T: Codable>: Codable {
    let value: T
    let timestamp: Date
    let expirationInterval: TimeInterval
    
    var isExpired: Bool {
        Date().timeIntervalSince(timestamp) > expirationInterval
    }
}

// MARK: - Cache Manager
actor CacheManager {
    static let shared = CacheManager()
    
    private let memoryCache = NSCache<NSString, NSData>()
    private let diskCacheURL: URL
    private let defaultExpirationInterval: TimeInterval = 900 // 15 minutes
    private let maxDiskCacheSize: Int64 = 100 * 1024 * 1024 // 100MB
    
    private init() {
        guard let documentsPath = FileManager.default.urls(for: .cachesDirectory, 
                                                          in: .userDomainMask).first else {
            fatalError("Unable to access cache directory")
        }
        self.diskCacheURL = documentsPath.appendingPathComponent("WeatherCache")
        
        // Create cache directory if needed
        try? FileManager.default.createDirectory(at: diskCacheURL, 
                                               withIntermediateDirectories: true)
        
        // Configure memory cache
        memoryCache.countLimit = 50
        memoryCache.totalCostLimit = 50 * 1024 * 1024 // 50MB
        
        // Clean expired cache on init
        Task {
            await cleanExpiredCache()
        }
    }
    
    // MARK: - Public Methods
    func get<T: Codable>(_ key: String, type: T.Type) async -> T? {
        // Try memory cache first
        if let data = memoryCache.object(forKey: key as NSString) as Data? {
            if let entry = try? JSONDecoder().decode(CacheEntry<T>.self, from: data),
               !entry.isExpired {
                return entry.value
            } else {
                memoryCache.removeObject(forKey: key as NSString)
            }
        }
        
        // Try disk cache
        let fileURL = diskCacheURL.appendingPathComponent(key.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? key)
        
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return nil
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            let entry = try JSONDecoder().decode(CacheEntry<T>.self, from: data)
            
            if !entry.isExpired {
                // Update memory cache
                memoryCache.setObject(data as NSData, 
                                    forKey: key as NSString, 
                                    cost: data.count)
                return entry.value
            } else {
                // Remove expired cache
                try? FileManager.default.removeItem(at: fileURL)
            }
        } catch {
            print("Cache read error: \(error)")
        }
        
        return nil
    }
    
    func set<T: Codable>(_ value: T, 
                         forKey key: String, 
                         expirationInterval: TimeInterval? = nil) async {
        let entry = CacheEntry(value: value,
                             timestamp: Date(),
                             expirationInterval: expirationInterval ?? defaultExpirationInterval)
        
        do {
            let data = try JSONEncoder().encode(entry)
            
            // Update memory cache
            memoryCache.setObject(data as NSData, 
                                forKey: key as NSString, 
                                cost: data.count)
            
            // Update disk cache
            let fileURL = diskCacheURL.appendingPathComponent(key.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? key)
            try data.write(to: fileURL)
            
            // Check disk cache size and clean if needed
            Task {
                await checkAndCleanDiskCacheIfNeeded()
            }
            
        } catch {
            print("Cache write error: \(error)")
        }
    }
    
    func remove(_ key: String) async {
        // Remove from memory cache
        memoryCache.removeObject(forKey: key as NSString)
        
        // Remove from disk cache
        let fileURL = diskCacheURL.appendingPathComponent(key.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? key)
        try? FileManager.default.removeItem(at: fileURL)
    }
    
    func clearAll() async {
        // Clear memory cache
        memoryCache.removeAllObjects()
        
        // Clear disk cache
        if let files = try? FileManager.default.contentsOfDirectory(at: diskCacheURL,
                                                                   includingPropertiesForKeys: nil) {
            for file in files {
                try? FileManager.default.removeItem(at: file)
            }
        }
    }
    
    // MARK: - Private Methods
    private func cleanExpiredCache() async {
        guard let files = try? FileManager.default.contentsOfDirectory(at: diskCacheURL,
                                                                      includingPropertiesForKeys: [.contentModificationDateKey]) else {
            return
        }
        
        for fileURL in files {
            do {
                let data = try Data(contentsOf: fileURL)
                if let entry = try? JSONDecoder().decode(CacheEntry<Data>.self, from: data),
                   entry.isExpired {
                    try FileManager.default.removeItem(at: fileURL)
                }
            } catch {
                // If we can't decode, remove the file
                try? FileManager.default.removeItem(at: fileURL)
            }
        }
    }
    
    func getCacheSize() async -> Int64 {
        var totalSize: Int64 = 0
        
        if let files = try? FileManager.default.contentsOfDirectory(at: diskCacheURL,
                                                                   includingPropertiesForKeys: [.fileSizeKey]) {
            for fileURL in files {
                if let attributes = try? FileManager.default.attributesOfItem(atPath: fileURL.path),
                   let fileSize = attributes[.size] as? Int64 {
                    totalSize += fileSize
                }
            }
        }
        
        return totalSize
    }
    
    private func checkAndCleanDiskCacheIfNeeded() async {
        let currentSize = await getCacheSize()
        
        if currentSize > maxDiskCacheSize {
            // Get all cache files with modification dates
            guard let files = try? FileManager.default.contentsOfDirectory(at: diskCacheURL,
                                                                          includingPropertiesForKeys: [.contentModificationDateKey, .fileSizeKey]) else {
                return
            }
            
            // Sort by modification date (oldest first)
            let sortedFiles = files.sorted { url1, url2 in
                let date1 = (try? url1.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate) ?? Date.distantPast
                let date2 = (try? url2.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate) ?? Date.distantPast
                return date1 < date2
            }
            
            var deletedSize: Int64 = 0
            let targetSize = maxDiskCacheSize * 80 / 100 // Clean to 80% of max size
            
            for fileURL in sortedFiles {
                if currentSize - deletedSize <= targetSize {
                    break
                }
                
                if let size = try? fileURL.resourceValues(forKeys: [.fileSizeKey]).fileSize {
                    try? FileManager.default.removeItem(at: fileURL)
                    deletedSize += Int64(size)
                }
            }
        }
    }
}

// MARK: - Cache Keys
struct CacheKeys {
    static func weatherData(cityName: String) -> String {
        "weather_\(cityName)"
    }
    
    static func weatherData(lat: Double, lon: Double) -> String {
        "weather_\(lat)_\(lon)"
    }
    
    static func citySearch(query: String) -> String {
        "search_\(query.lowercased())"
    }
    
    static func forecast(lat: Double, lon: Double) -> String {
        "forecast_\(lat)_\(lon)"
    }
}