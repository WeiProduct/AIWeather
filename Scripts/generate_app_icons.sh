#!/bin/bash

# Generate App Icons Script
# Creates all required iOS app icon sizes from a base 1024x1024 image

# Create the scripts directory if it doesn't exist
mkdir -p "$(dirname "$0")"

# Base icon path (you need to provide a 1024x1024 PNG)
BASE_ICON="/Users/weifu/Desktop/Weather/Weather/Assets.xcassets/AppIcon.appiconset/icon-1024.png"
ICON_DIR="/Users/weifu/Desktop/Weather/Weather/Assets.xcassets/AppIcon.appiconset"

# Create the icon directory if it doesn't exist
mkdir -p "$ICON_DIR"

# First, let's create a simple default icon if the base doesn't exist
if [ ! -f "$BASE_ICON" ]; then
    echo "Creating default app icon..."
    
    # Use ImageMagick or sips to create a simple icon
    # Using sips (built into macOS)
    
    # Create a simple gradient icon using sips and Core Image
    cat > /tmp/create_icon.swift << 'EOF'
import Cocoa

let size = CGSize(width: 1024, height: 1024)
let image = NSImage(size: size)

image.lockFocus()

// Create gradient
let gradient = NSGradient(colors: [
    NSColor(red: 0.2, green: 0.6, blue: 1.0, alpha: 1.0),
    NSColor(red: 0.1, green: 0.3, blue: 0.8, alpha: 1.0)
])!
gradient.draw(in: NSRect(origin: .zero, size: size), angle: -45)

// Add weather symbol
let paragraphStyle = NSMutableParagraphStyle()
paragraphStyle.alignment = .center

let attributes: [NSAttributedString.Key: Any] = [
    .font: NSFont.systemFont(ofSize: 400, weight: .light),
    .foregroundColor: NSColor.white,
    .paragraphStyle: paragraphStyle
]

let text = "☀️"
let textSize = text.size(withAttributes: attributes)
let textRect = NSRect(
    x: (size.width - textSize.width) / 2,
    y: (size.height - textSize.height) / 2,
    width: textSize.width,
    height: textSize.height
)
text.draw(in: textRect, withAttributes: attributes)

// Add app name
let nameAttributes: [NSAttributedString.Key: Any] = [
    .font: NSFont.systemFont(ofSize: 120, weight: .medium),
    .foregroundColor: NSColor.white,
    .paragraphStyle: paragraphStyle
]

let appName = "Weather"
let nameSize = appName.size(withAttributes: nameAttributes)
let nameRect = NSRect(
    x: (size.width - nameSize.width) / 2,
    y: 100,
    width: nameSize.width,
    height: nameSize.height
)
appName.draw(in: nameRect, withAttributes: nameAttributes)

image.unlockFocus()

// Save as PNG
let bitmap = NSBitmapImageRep(data: image.tiffRepresentation!)!
let pngData = bitmap.representation(using: .png, properties: [:])!
try! pngData.write(to: URL(fileURLWithPath: "/Users/weifu/Desktop/Weather/Weather/Assets.xcassets/AppIcon.appiconset/icon-1024.png"))
EOF

    swift /tmp/create_icon.swift
    rm /tmp/create_icon.swift
fi

# Generate all required sizes using sips
echo "Generating app icons..."

# iPhone icons
sips -z 180 180 "$BASE_ICON" --out "$ICON_DIR/icon-180.png" >/dev/null 2>&1
sips -z 120 120 "$BASE_ICON" --out "$ICON_DIR/icon-120.png" >/dev/null 2>&1
sips -z 87 87 "$BASE_ICON" --out "$ICON_DIR/icon-87.png" >/dev/null 2>&1
sips -z 80 80 "$BASE_ICON" --out "$ICON_DIR/icon-80.png" >/dev/null 2>&1
sips -z 60 60 "$BASE_ICON" --out "$ICON_DIR/icon-60.png" >/dev/null 2>&1
sips -z 58 58 "$BASE_ICON" --out "$ICON_DIR/icon-58.png" >/dev/null 2>&1
sips -z 40 40 "$BASE_ICON" --out "$ICON_DIR/icon-40.png" >/dev/null 2>&1
sips -z 29 29 "$BASE_ICON" --out "$ICON_DIR/icon-29.png" >/dev/null 2>&1
sips -z 20 20 "$BASE_ICON" --out "$ICON_DIR/icon-20.png" >/dev/null 2>&1

# iPad icons
sips -z 167 167 "$BASE_ICON" --out "$ICON_DIR/icon-167.png" >/dev/null 2>&1
sips -z 152 152 "$BASE_ICON" --out "$ICON_DIR/icon-152.png" >/dev/null 2>&1
sips -z 76 76 "$BASE_ICON" --out "$ICON_DIR/icon-76.png" >/dev/null 2>&1

echo "✅ App icons generated successfully!"
echo "Icons saved to: $ICON_DIR"

# List generated files
echo ""
echo "Generated files:"
ls -la "$ICON_DIR"/*.png | awk '{print "  " $9}'