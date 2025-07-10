#!/bin/bash

# App Icon Generator Script
# This script generates all required app icon sizes from a 1024x1024 source image
# Usage: ./GenerateIcons.sh source_icon.png

# Check if source file is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <source_icon_1024x1024.png>"
    exit 1
fi

SOURCE_FILE=$1
OUTPUT_DIR="../Weather/Assets.xcassets/AppIcon.appiconset"

# Check if source file exists
if [ ! -f "$SOURCE_FILE" ]; then
    echo "Error: Source file '$SOURCE_FILE' not found"
    exit 1
fi

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Function to resize image
resize_icon() {
    local size=$1
    local filename=$2
    
    echo "Generating ${size}x${size} icon: $filename"
    sips -z $size $size "$SOURCE_FILE" --out "$OUTPUT_DIR/$filename" >/dev/null 2>&1
    
    if [ $? -eq 0 ]; then
        echo "✓ Generated $filename"
    else
        echo "✗ Failed to generate $filename"
    fi
}

echo "Starting icon generation..."
echo "Source: $SOURCE_FILE"
echo "Output: $OUTPUT_DIR"
echo ""

# Generate all required sizes
resize_icon 1024 "icon-1024.png"
resize_icon 180 "icon-180.png"
resize_icon 167 "icon-167.png"
resize_icon 152 "icon-152.png"
resize_icon 120 "icon-120.png"
resize_icon 87 "icon-87.png"
resize_icon 80 "icon-80.png"
resize_icon 76 "icon-76.png"
resize_icon 60 "icon-60.png"
resize_icon 58 "icon-58.png"
resize_icon 40 "icon-40.png"
resize_icon 29 "icon-29.png"
resize_icon 20 "icon-20.png"

echo ""
echo "Icon generation complete!"
echo ""
echo "Next steps:"
echo "1. Open Xcode and verify the icons are correctly displayed"
echo "2. Build and run to test the app icon"
echo "3. Create a marketing icon (1024x1024) without rounded corners for App Store"

# Make the script executable
chmod +x "$0"