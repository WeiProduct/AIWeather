#!/bin/bash

echo "🧹 Cleaning Xcode build artifacts..."

# Kill Xcode if running
killall Xcode 2>/dev/null

# Clean derived data
echo "Removing derived data..."
rm -rf ~/Library/Developer/Xcode/DerivedData/Weather-*

# Clean build folder
echo "Removing build folder..."
rm -rf build/

# Remove .DS_Store files
find . -name ".DS_Store" -delete

# Remove xcuserdata
echo "Removing user-specific data..."
rm -rf Weather.xcodeproj/xcuserdata
rm -rf Weather.xcodeproj/project.xcworkspace/xcuserdata

# Clean module cache
echo "Cleaning module cache..."
rm -rf ~/Library/Developer/Xcode/DerivedData/ModuleCache.noindex/

echo "✅ Clean complete!"
echo ""
echo "Next steps:"
echo "1. Open Weather.xcodeproj in Xcode"
echo "2. Wait for indexing to complete"
echo "3. Build the project (Cmd+B)"