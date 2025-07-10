#!/bin/bash

echo "🚀 准备 WeathersPro 上架到 App Store"
echo "=================================="

# 清理构建缓存
echo "🧹 清理构建缓存..."
rm -rf ~/Library/Developer/Xcode/DerivedData
echo "✅ 构建缓存已清理"

# 检查代码签名团队
echo ""
echo "🔐 检查代码签名设置..."
echo "请确保在 Xcode 中："
echo "1. 选择 WeathersPro target → Signing & Capabilities"
echo "2. 勾选 'Automatically manage signing'"
echo "3. 选择您的开发团队"
echo "4. 对 WeatherWidgetExtension target 重复相同操作"

# 检查部署目标
echo ""
echo "📱 检查部署目标..."
DEPLOYMENT_TARGET=$(grep -o 'IPHONEOS_DEPLOYMENT_TARGET = [^;]*' Weather.xcodeproj/project.pbxproj | head -1 | cut -d'=' -f2 | tr -d ' ')
echo "当前 iOS 部署目标: $DEPLOYMENT_TARGET"

if [ "$DEPLOYMENT_TARGET" = "18.5" ]; then
    echo "⚠️  建议将部署目标降低到 14.0 以支持更多设备"
    echo "   在 Xcode 中: Target → Build Settings → iOS Deployment Target"
fi

# 检查版本号
echo ""
echo "📊 检查版本信息..."
VERSION=$(grep -o 'MARKETING_VERSION = [^;]*' Weather.xcodeproj/project.pbxproj | head -1 | cut -d'=' -f2 | tr -d ' ')
echo "版本号: $VERSION"
echo "确保版本号格式正确 (如 1.0, 1.0.1)"

# 检查 Bundle ID
echo ""
echo "🆔 检查 Bundle ID..."
BUNDLE_ID=$(grep -o 'PRODUCT_BUNDLE_IDENTIFIER = [^;]*' Weather.xcodeproj/project.pbxproj | head -1 | cut -d'=' -f2 | tr -d ' ')
echo "Bundle ID: $BUNDLE_ID"

# 提供 Archive 步骤
echo ""
echo "📦 创建 Archive 的步骤:"
echo "=================================="
echo "1. 在 Xcode 中打开 Weather.xcodeproj"
echo "2. 选择真机或 'Any iOS Device (arm64)'"
echo "3. 确保 Scheme 选择为 'WeathersPro'"
echo "4. 菜单: Product → Archive"
echo "5. 等待构建完成..."
echo ""
echo "📤 上传到 App Store Connect:"
echo "1. Archive 完成后，Organizer 会自动打开"
echo "2. 选择刚创建的 Archive"
echo "3. 点击 'Distribute App'"
echo "4. 选择 'App Store Connect'"
echo "5. 选择 'Upload'"
echo "6. 配置选项并点击 'Upload'"

echo ""
echo "📋 上传前最终检查:"
echo "- ✅ 应用能正常运行，无崩溃"
echo "- ✅ 所有功能正常工作"
echo "- ✅ 已测试不同设备尺寸"
echo "- ✅ Widget 功能正常"
echo "- ✅ 权限请求正确显示"

echo ""
echo "🎯 接下来的步骤:"
echo "1. 运行应用，拍摄截图"
echo "2. 在 App Store Connect 创建应用记录"
echo "3. 创建 Archive 并上传"
echo "4. 填写应用信息并提交审核"

echo ""
echo "📚 参考文档:"
echo "- APP_STORE_SUBMISSION_GUIDE.md (详细指南)"
echo "- SCREENSHOT_GUIDE.md (截图指南)"

echo ""
echo "🚀 准备完成！现在可以在 Xcode 中创建 Archive 了。"