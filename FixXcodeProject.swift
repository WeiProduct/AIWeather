#!/usr/bin/swift

import Foundation

// Script to fix Xcode project configuration issues
// This helps resolve "Multiple commands produce Info.plist" errors

print("🔧 Fixing Xcode Project Configuration...")

// Path to the project
let projectPath = "Weather.xcodeproj/project.pbxproj"
let fileManager = FileManager.default

// Check if project file exists
guard fileManager.fileExists(atPath: projectPath) else {
    print("❌ Error: project.pbxproj not found at \(projectPath)")
    exit(1)
}

// Read the project file
do {
    var projectContent = try String(contentsOfFile: projectPath, encoding: .utf8)
    var changesMade = false
    
    // Common fixes for Info.plist issues
    
    // 1. Ensure Info.plist is not in resources build phase
    if projectContent.contains("Info.plist in Resources") {
        print("⚠️  Found Info.plist in Resources build phase - this needs to be removed")
        print("   Please remove Info.plist from 'Copy Bundle Resources' in Xcode")
        changesMade = true
    }
    
    // 2. Check for duplicate Info.plist entries
    let infoPlistMatches = projectContent.components(separatedBy: "Info.plist").count - 1
    if infoPlistMatches > 5 {  // Normal projects have ~3-5 references
        print("⚠️  Found \(infoPlistMatches) references to Info.plist (might indicate duplicates)")
    }
    
    // 3. Ensure INFOPLIST_FILE is set correctly
    if !projectContent.contains("INFOPLIST_FILE = Weather/Info.plist") {
        print("⚠️  INFOPLIST_FILE build setting might not be configured correctly")
        print("   It should be set to: Weather/Info.plist")
    }
    
    // 4. Check for SWIFT_ACTIVE_COMPILATION_CONDITIONS
    if projectContent.contains("SWIFT_ACTIVE_COMPILATION_CONDITIONS = DEBUG") {
        print("✅ Debug configuration found")
    }
    
    // 5. Look for common problematic patterns
    let problematicPatterns = [
        "Info.plist */ = {isa = PBXBuildFile",
        "Info.plist in Copy Bundle Resources",
        "Info.plist in Sources"
    ]
    
    for pattern in problematicPatterns {
        if projectContent.contains(pattern) {
            print("❌ Found problematic pattern: \(pattern)")
            changesMade = true
        }
    }
    
    if !changesMade {
        print("✅ No obvious Info.plist configuration issues found")
    }
    
    print("\n📋 Recommended Actions:")
    print("1. Open Weather.xcodeproj in Xcode")
    print("2. Select the Weather target")
    print("3. Go to Build Phases tab")
    print("4. Expand 'Copy Bundle Resources'")
    print("5. Remove Info.plist if it appears there")
    print("6. Go to Build Settings tab")
    print("7. Search for 'Info.plist'")
    print("8. Ensure 'Info.plist File' is set to: Weather/Info.plist")
    print("9. Clean build folder: Product → Clean Build Folder (⇧⌘K)")
    print("10. Build again: Product → Build (⌘B)")
    
} catch {
    print("❌ Error reading project file: \(error)")
    exit(1)
}

// Additional cleanup commands
print("\n🧹 Cleanup Commands:")
print("rm -rf ~/Library/Developer/Xcode/DerivedData/Weather-*")
print("xcodebuild clean -project Weather.xcodeproj -alltargets")

// Make the script executable
let scriptPath = CommandLine.arguments[0]
_ = try? FileManager.default.setAttributes([.posixPermissions: 0o755], ofItemAtPath: scriptPath)