#!/bin/bash

echo "🔧 Resetting Xcode project structure..."

# Navigate to project root
cd "$(dirname "$0")"

# Remove all xcodeproj user data
echo "Removing user-specific Xcode data..."
rm -rf Weather.xcodeproj/xcuserdata
rm -rf Weather.xcodeproj/project.xcworkspace/xcuserdata

# Remove derived data
echo "Removing derived data..."
rm -rf ~/Library/Developer/Xcode/DerivedData/Weather-*

# Kill Xcode
killall Xcode 2>/dev/null

echo "✅ Reset complete!"
echo ""
echo "⚠️  IMPORTANT: You need to manually:"
echo "1. Open Weather.xcodeproj in Xcode"
echo "2. Remove all red (missing) file references"
echo "3. Right-click on Weather folder and select 'Add Files to Weather...'"
echo "4. Add each folder (Models, Views, Services, etc.) one by one"
echo "5. Make sure 'Create groups' is selected"
echo "6. Clean build folder (Cmd+Shift+K)"
echo "7. Build the project (Cmd+B)"