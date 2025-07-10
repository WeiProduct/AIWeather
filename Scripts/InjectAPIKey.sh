#!/bin/bash

# Script to inject API key at build time
# Add this as a Build Phase in Xcode

# Check if we're in release configuration
if [ "${CONFIGURATION}" = "Release" ]; then
    # Get API key from environment variable or xcconfig
    API_KEY="${OPENWEATHER_API_KEY}"
    
    if [ -z "$API_KEY" ] || [ "$API_KEY" = "YOUR_RELEASE_API_KEY_HERE" ]; then
        echo "error: API key not configured for release build"
        exit 1
    fi
    
    # Update Info.plist with the API key
    /usr/libexec/PlistBuddy -c "Set :OPENWEATHER_API_KEY ${API_KEY}" "${TARGET_BUILD_DIR}/${INFOPLIST_PATH}"
    
    echo "API key injected into Info.plist"
else
    echo "Debug build - using hardcoded obfuscated key"
fi