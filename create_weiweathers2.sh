#!/bin/bash

echo "🚀 Creating WeiWeathers2 for App Store submission..."

# 步骤说明
echo "
📱 WeiWeathers2 App Store 上架步骤：

1. 在 App Store Connect 创建新应用
   - 应用名称: WeiWeathers2
   - Bundle ID: com.weiproduct.WeiWeathers2
   - SKU: com.weiproduct.WeiWeathers2

2. 在 Xcode 中上传 Build
   - Product → Clean Build Folder
   - Product → Archive
   - Distribute App → App Store Connect → Upload

3. 等待 Apple 处理 (10-30分钟)

4. 在 App Store Connect 中填写信息
   - 应用描述、截图、关键词等
   - 选择处理完成的 Build
   - 提交审核

5. 使用的隐私政策 URL:
   https://weiproduct.github.io/weiweathers-privacy/
"

echo "✅ 项目已配置完成！"
echo "📋 Bundle ID: com.weiproduct.WeiWeathers2"
echo "📱 应用名称: WeiWeathers2"
echo ""
echo "现在可以在 Xcode 中进行 Archive 并上传到 App Store Connect！"