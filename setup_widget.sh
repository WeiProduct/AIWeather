#!/bin/bash

echo "🚀 开始配置 iOS Widget Extension..."

# 创建 Widget 的 xcconfig 文件
cat > /Users/weifu/Desktop/Weather/WeatherWidget/WeatherWidget.xcconfig << 'EOF'
// WeatherWidget Configuration Settings
PRODUCT_BUNDLE_IDENTIFIER = com.weiweathers.weather.widget
PRODUCT_NAME = WeatherWidget
INFOPLIST_FILE = WeatherWidget/Info.plist

// Deployment
IPHONEOS_DEPLOYMENT_TARGET = 14.0

// Swift
SWIFT_VERSION = 5.0

// Code Signing
CODE_SIGN_ENTITLEMENTS = WeatherWidget/WeatherWidget.entitlements
EOF

echo "✅ 创建了 xcconfig 文件"

# 创建一个简单的 Package.swift 文件用于 SPM（如果需要）
cat > /Users/weifu/Desktop/Weather/WeatherWidget/Package.swift << 'EOF'
// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "WeatherWidget",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(
            name: "WeatherWidget",
            targets: ["WeatherWidget"]),
    ],
    targets: [
        .target(
            name: "WeatherWidget",
            dependencies: []),
    ]
)
EOF

echo "✅ 创建了 Package.swift"

# 更新 gitignore 以包含 Widget 相关文件
if [ -f "/Users/weifu/Desktop/Weather/.gitignore" ]; then
    echo "" >> /Users/weifu/Desktop/Weather/.gitignore
    echo "# Widget specific" >> /Users/weifu/Desktop/Weather/.gitignore
    echo "WeatherWidget.xcodeproj/" >> /Users/weifu/Desktop/Weather/.gitignore
    echo "✅ 更新了 .gitignore"
fi

# 创建 Widget 的本地化文件
mkdir -p /Users/weifu/Desktop/Weather/WeatherWidget/zh-Hans.lproj
mkdir -p /Users/weifu/Desktop/Weather/WeatherWidget/en.lproj

# 创建中文本地化文件
cat > /Users/weifu/Desktop/Weather/WeatherWidget/zh-Hans.lproj/Localizable.strings << 'EOF'
/* Widget Localizations */
"widget_display_name" = "天气";
"widget_description" = "查看当前天气状况";
"no_data" = "暂无数据";
"open_app_hint" = "打开应用以更新天气";
"last_updated" = "更新于";
"feels_like" = "体感温度";
"humidity" = "湿度";
"min_temp" = "最低";
"max_temp" = "最高";
EOF

# 创建英文本地化文件
cat > /Users/weifu/Desktop/Weather/WeatherWidget/en.lproj/Localizable.strings << 'EOF'
/* Widget Localizations */
"widget_display_name" = "Weather";
"widget_description" = "View current weather conditions";
"no_data" = "No Data";
"open_app_hint" = "Open app to update weather";
"last_updated" = "Updated at";
"feels_like" = "Feels Like";
"humidity" = "Humidity";
"min_temp" = "Low";
"max_temp" = "High";
EOF

echo "✅ 创建了本地化文件"

echo ""
echo "📋 配置完成！请按照以下步骤在 Xcode 中完成设置："
echo ""
echo "1️⃣  打开 Xcode 项目"
echo "2️⃣  选择 File → New → Target"
echo "3️⃣  选择 'Widget Extension'"
echo "4️⃣  填写以下信息："
echo "    • Product Name: WeatherWidget"
echo "    • Team: 选择您的开发团队"
echo "    • Bundle Identifier: com.weiweathers.weather.widget"
echo "    • Include Configuration Intent: ✅ 勾选"
echo ""
echo "5️⃣  点击 Finish 创建 Widget Extension"
echo ""
echo "6️⃣  在弹出的对话框中选择 'Activate' 激活 scheme"
echo ""
echo "7️⃣  删除 Xcode 自动生成的文件："
echo "    • WeatherWidget.swift (自动生成的)"
echo "    • WeatherWidget.intentdefinition (自动生成的)"
echo ""
echo "8️⃣  将我们创建的文件添加到 Widget target："
echo "    • 右键点击项目导航器中的 WeatherWidget 文件夹"
echo "    • 选择 'Add Files to \"Weather\"...'"
echo "    • 导航到 /Users/weifu/Desktop/Weather/WeatherWidget/"
echo "    • 选择所有文件"
echo "    • 确保 'WeatherWidget' target 被勾选"
echo "    • 点击 Add"
echo ""
echo "9️⃣  配置 App Groups:"
echo "    主应用 Target:"
echo "    • 选择 Weather target → Signing & Capabilities"
echo "    • 点击 '+ Capability'"
echo "    • 添加 'App Groups'"
echo "    • 点击 '+' 添加新的 App Group"
echo "    • 输入: group.com.weiweathers.weather"
echo ""
echo "    Widget Target:"
echo "    • 选择 WeatherWidget target → Signing & Capabilities"
echo "    • 重复上述步骤"
echo "    • 选择相同的 App Group: group.com.weiweathers.weather"
echo ""
echo "🔟  编译并运行:"
echo "    • 选择真机或模拟器"
echo "    • 运行应用"
echo "    • 长按主屏幕添加小组件"
echo ""
echo "✨ 完成！您的应用现在支持 iOS 小组件了。"