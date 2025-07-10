# Fix for "Multiple commands produce Info.plist" Error

This error occurs when Xcode's build system finds conflicting references to Info.plist. Here's how to fix it:

## Solution Steps:

### 1. Open Xcode and Select Your Project
- Open `Weather.xcodeproj` in Xcode
- Select the project file in the navigator (blue icon at the top)

### 2. Check Build Settings
1. Select the "Weather" target
2. Go to "Build Settings" tab
3. Search for "Info.plist"
4. Find "Info.plist File" setting
5. Make sure it's set to: `Weather/Info.plist`

### 3. Check Build Phases
1. Go to "Build Phases" tab
2. Expand "Copy Bundle Resources"
3. **Remove Info.plist if it's listed here** (Info.plist should NOT be in Copy Bundle Resources)
4. Info.plist is processed separately and should not be copied as a resource

### 4. Clean and Rebuild
1. Product → Clean Build Folder (⇧⌘K)
2. Product → Build (⌘B)

### 5. Alternative: Command Line Fix
```bash
# Clean all build data
rm -rf ~/Library/Developer/Xcode/DerivedData/Weather-*
xcodebuild clean -project Weather.xcodeproj -alltargets
```

### 6. If the Issue Persists
Check for duplicate target membership:
1. Select Info.plist in the file navigator
2. Open File Inspector (right panel)
3. Under "Target Membership", ensure only "Weather" is checked
4. Uncheck any other targets if present

### Common Causes:
- Info.plist accidentally added to "Copy Bundle Resources"
- Multiple targets with the same Info.plist
- Corrupted derived data
- Incorrect build settings

### Prevention:
- Never manually add Info.plist to Copy Bundle Resources
- Use a single Info.plist per target
- Keep build settings consistent

After following these steps, the error should be resolved and you can build successfully.