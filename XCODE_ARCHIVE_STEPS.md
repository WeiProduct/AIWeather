# Xcode Archive 和上传步骤

## 🚀 第一步：准备 Archive

### 1. 打开 Xcode 项目
```bash
open /Users/weifu/Desktop/Weather/Weather.xcodeproj
```

### 2. 配置设置
1. 选择 **WeathersPro** target
2. 确保 **Scheme** 选择为 "WeathersPro"
3. 选择 **"Any iOS Device (arm64)"** 或连接的真机

### 3. 检查代码签名
- **WeathersPro** target → Signing & Capabilities
  - ✅ Automatically manage signing
  - 选择您的开发团队
- **WeatherWidgetExtension** target → Signing & Capabilities  
  - ✅ Automatically manage signing
  - 选择相同的开发团队

## 📦 第二步：创建 Archive

### 1. 清理项目
- 菜单: **Product** → **Clean Build Folder** (Shift+Cmd+K)

### 2. 创建 Archive  
- 菜单: **Product** → **Archive**
- 等待构建完成 (可能需要几分钟)

### 3. Archive 成功标志
- Xcode 会自动打开 **Organizer** 窗口
- 显示新创建的 Archive

## 📤 第三步：上传到 App Store

### 1. 在 Organizer 中操作
1. 选择刚创建的 Archive
2. 点击 **"Distribute App"**

### 2. 选择分发方式
1. 选择 **"App Store Connect"**
2. 点击 **"Next"**

### 3. 选择分发选项
1. 选择 **"Upload"**
2. 点击 **"Next"**

### 4. 配置选项 (保持默认)
- ✅ Strip Swift symbols
- ✅ Upload your app's symbols to receive symbolicated reports
- ✅ Manage Version and Build Number (Xcode Managed)
- 点击 **"Next"**

### 5. 重新签名 (如果需要)
- 通常保持默认设置
- 点击 **"Next"**

### 6. 审查和上传
1. 检查应用信息
2. 点击 **"Upload"**
3. 等待上传完成

## ⏳ 第四步：等待处理

### 上传后状态
- 上传完成后会显示成功消息
- App Store Connect 需要 5-15 分钟处理构建版本

### 检查状态
1. 访问 App Store Connect
2. 进入您的应用
3. 查看 **"构建版本"** 部分
4. 状态变为 **"可供使用"** 即可选择

## 🎯 第五步：选择构建版本并提交

### 1. 在 App Store Connect 中
1. 进入应用的 **"iOS App"** 版本
2. 在 **"构建版本"** 部分点击 **"选择构建版本"**
3. 选择刚上传的版本

### 2. 完成版本信息
- 确保截图已上传
- 检查应用描述
- 填写版本发布说明

### 3. 提交审核
1. 点击 **"提交以供审核"**
2. 回答广告标识符问题 (通常选择 "否")
3. 确认导出合规性 (不加密选择 "否")
4. 最终提交

## ⚠️ 常见问题

### Archive 失败
- 检查代码签名设置
- 确保没有编译错误
- 更新 Xcode 到最新版本

### 上传失败
- 检查网络连接
- 确保 Apple ID 权限正确
- 重试上传

### 构建版本不显示
- 等待 15-30 分钟
- 检查上传是否真正成功
- 查看邮件通知

## ✅ 成功标志

当您看到以下内容时表示成功：
- ✅ Archive 在 Organizer 中显示
- ✅ 上传完成显示成功消息  
- ✅ App Store Connect 中显示新构建版本
- ✅ 可以选择构建版本进行审核

---

完成这些步骤后，您的应用就提交审核了！
审核时间通常为 1-7 天，平均 24-48 小时。