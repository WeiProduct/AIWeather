#!/bin/bash

# Weather App Build and Submission Script
# This script helps prepare the app for App Store submission

echo "================================================"
echo "Weather App - App Store Build Script"
echo "================================================"
echo ""

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✓ $2${NC}"
    else
        echo -e "${RED}✗ $2${NC}"
        exit 1
    fi
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# 1. Check for required tools
echo "1. Checking required tools..."
which xcodebuild > /dev/null
print_status $? "Xcode command line tools installed"

# 2. Clean build folder
echo ""
echo "2. Cleaning build folder..."
xcodebuild clean -project Weather.xcodeproj -scheme Weather -configuration Release > /dev/null 2>&1
print_status $? "Build folder cleaned"

# 3. Check API key configuration
echo ""
echo "3. Checking API key configuration..."
if grep -q "YOUR_RELEASE_API_KEY_HERE" "../Weather/Configuration/Release.xcconfig" 2>/dev/null; then
    print_warning "Release API key not configured!"
    echo "   Please update Release.xcconfig with your actual API key"
    exit 1
else
    print_status 0 "API key configured"
fi

# 4. Run SwiftLint (if available)
echo ""
echo "4. Running code quality checks..."
if which swiftlint > /dev/null; then
    cd .. && swiftlint --quiet
    print_status $? "SwiftLint passed"
else
    print_warning "SwiftLint not installed - skipping"
fi

# 5. Check for debug code
echo ""
echo "5. Checking for debug code..."
DEBUG_COUNT=$(grep -r "print(" ../Weather --include="*.swift" | grep -v "CrashReporter\|Analytics" | wc -l)
if [ $DEBUG_COUNT -gt 0 ]; then
    print_warning "Found $DEBUG_COUNT print statements in code"
    echo "   Consider removing debug print statements"
else
    print_status 0 "No debug print statements found"
fi

# 6. Verify Info.plist
echo ""
echo "6. Verifying Info.plist..."
if [ -f "../Weather/Info.plist" ]; then
    print_status 0 "Info.plist exists"
    
    # Check for required keys
    /usr/libexec/PlistBuddy -c "Print :NSLocationWhenInUseUsageDescription" ../Weather/Info.plist > /dev/null 2>&1
    print_status $? "Location permission description set"
    
    /usr/libexec/PlistBuddy -c "Print :ITSAppUsesNonExemptEncryption" ../Weather/Info.plist > /dev/null 2>&1
    print_status $? "Export compliance key set"
else
    print_status 1 "Info.plist not found"
fi

# 7. Check app icons
echo ""
echo "7. Checking app icons..."
ICON_COUNT=$(ls ../Weather/Assets.xcassets/AppIcon.appiconset/*.png 2>/dev/null | wc -l)
if [ $ICON_COUNT -gt 0 ]; then
    print_status 0 "Found $ICON_COUNT app icons"
else
    print_warning "No app icons found - please generate icons first"
fi

# 8. Build release version
echo ""
echo "8. Building release version..."
echo "   This may take a few minutes..."

BUILD_DIR="build"
mkdir -p $BUILD_DIR

xcodebuild build \
    -project ../Weather.xcodeproj \
    -scheme Weather \
    -configuration Release \
    -derivedDataPath $BUILD_DIR \
    -destination 'generic/platform=iOS' \
    CODE_SIGN_IDENTITY="" \
    CODE_SIGNING_REQUIRED=NO \
    > build.log 2>&1

if [ $? -eq 0 ]; then
    print_status 0 "Release build successful"
else
    print_status 1 "Release build failed - check build.log"
fi

# 9. Archive for submission
echo ""
echo "9. Creating archive..."
echo "   Note: This requires proper signing certificates"

read -p "Do you have signing certificates configured? (y/n) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    xcodebuild archive \
        -project ../Weather.xcodeproj \
        -scheme Weather \
        -configuration Release \
        -archivePath $BUILD_DIR/Weather.xcarchive \
        > archive.log 2>&1
    
    if [ $? -eq 0 ]; then
        print_status 0 "Archive created successfully"
        
        # Export archive
        echo ""
        echo "10. Exporting archive..."
        xcodebuild -exportArchive \
            -archivePath $BUILD_DIR/Weather.xcarchive \
            -exportPath $BUILD_DIR/Weather-Export \
            -exportOptionsPlist ExportOptions.plist \
            > export.log 2>&1
            
        if [ $? -eq 0 ]; then
            print_status 0 "Export successful"
        else
            print_warning "Export failed - check export.log"
        fi
    else
        print_warning "Archive failed - check archive.log"
    fi
else
    print_warning "Skipping archive - configure signing first"
fi

# Summary
echo ""
echo "================================================"
echo "Build Summary"
echo "================================================"
echo ""
echo "✅ Completed Steps:"
echo "   - Build environment verified"
echo "   - Code quality checked"
echo "   - Release build created"
echo ""
echo "📋 Next Steps:"
echo "   1. Generate app icons using GenerateIcons.sh"
echo "   2. Take screenshots on required devices"
echo "   3. Update Release.xcconfig with API key"
echo "   4. Configure signing in Xcode"
echo "   5. Create archive in Xcode (Product > Archive)"
echo "   6. Upload to App Store Connect"
echo "   7. Fill in app metadata"
echo "   8. Submit for review"
echo ""
echo "📚 Documentation:"
echo "   - Submission checklist: SubmissionChecklist.md"
echo "   - App metadata: Metadata.md"
echo "   - Privacy policy: ../Weather/Resources/PrivacyPolicy.md"
echo ""
echo "Good luck with your submission! 🚀"

# Make the script executable
chmod +x "$0"