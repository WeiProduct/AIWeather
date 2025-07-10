#!/bin/bash

echo "🚀 App Store 发布准备脚本"
echo "======================="

# 1. 清理项目
echo "1. 清理构建..."
xcodebuild clean -project Weather.xcodeproj -scheme Weather

# 2. 更新版本号
echo ""
echo "2. 当前版本信息："
/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" Weather/Info.plist
/usr/libexec/PlistBuddy -c "Print CFBundleVersion" Weather/Info.plist

echo ""
echo "⚠️  记得更新版本号："
echo "   - Marketing Version (CFBundleShortVersionString): 1.0.0"
echo "   - Build Number (CFBundleVersion): 1"

# 3. 检查配置
echo ""
echo "3. 检查发布配置..."
echo "   ✓ 确保使用 Release 配置"
echo "   ✓ 确保 API 使用代理模式"
echo "   ✓ 确保没有调试代码"

# 4. 归档步骤
echo ""
echo "4. 归档并上传到 App Store Connect："
echo ""
echo "   在 Xcode 中："
echo "   1) Product > Scheme > Weather"
echo "   2) Product > Destination > Any iOS Device"
echo "   3) Product > Archive"
echo "   4) 在 Organizer 中选择 'Distribute App'"
echo "   5) 选择 'App Store Connect'"
echo "   6) 选择 'Upload'"
echo ""
echo "   或使用命令行："
echo "   xcodebuild -project Weather.xcodeproj -scheme Weather -configuration Release archive -archivePath ./build/Weather.xcarchive"
echo "   xcodebuild -exportArchive -archivePath ./build/Weather.xcarchive -exportPath ./build -exportOptionsPlist ExportOptions.plist"

# 5. 提交审核
echo ""
echo "5. 在 App Store Connect 中："
echo "   - 上传截图"
echo "   - 填写应用描述"
echo "   - 选择构建版本"
echo "   - 提交审核"

echo ""
echo "✅ 准备完成！"