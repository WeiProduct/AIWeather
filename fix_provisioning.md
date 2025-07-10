# 修复 Provisioning Profile 问题

## 🔧 问题说明
App Group 标识符中有换行符导致配置错误。现已修复。

## ✅ 解决步骤

### 1. 清理 Xcode 缓存
```bash
# 关闭 Xcode
# 删除派生数据
rm -rf ~/Library/Developer/Xcode/DerivedData/*

# 清理项目
cd /Users/weifu/Desktop/Weather
xcodebuild clean -project Weather.xcodeproj -alltargets
```

### 2. 在 Xcode 中重新配置

1. **打开 Xcode**
   ```bash
   open Weather.xcodeproj
   ```

2. **主应用 Target (WeathersPro)**
   - 选择 WeathersPro target
   - 进入 Signing & Capabilities
   - 如果看到 App Groups 有错误，点击 "Fix Issue"
   - 或者删除 App Groups capability 并重新添加
   - 重新添加时使用：`group.com.weiweathers.weather`

3. **Widget Extension Target**
   - 选择 WeatherWidgetExtension target
   - 进入 Signing & Capabilities
   - 确保 App Groups 使用相同的标识符
   - 如有错误，同样点击 "Fix Issue"

### 3. 重新生成 Provisioning Profiles

1. **自动管理签名**
   - 确保两个 target 都勾选了 "Automatically manage signing"
   - Xcode 会自动重新生成正确的 provisioning profiles

2. **手动刷新（如果需要）**
   - Xcode → Preferences → Accounts
   - 选择您的 Apple ID
   - 点击 "Download Manual Profiles"

### 4. 验证修复

1. **构建测试**
   ```bash
   # 在 Xcode 中
   Product → Build (Cmd+B)
   ```

2. **检查 entitlements**
   - 两个 target 的 App Groups 都应该显示为：
   - ✅ `group.com.weiweathers.weather`（没有换行符）

## 🎯 修复后继续 Archive

修复完成后，您可以继续创建 Archive：
1. Product → Clean Build Folder (Shift+Cmd+K)
2. Product → Archive
3. 上传到 App Store Connect

## ⚠️ 注意事项

- App Group ID 必须完全一致，不能有空格或换行
- 两个 target 必须使用相同的开发团队
- 确保网络连接正常以下载新的 provisioning profiles