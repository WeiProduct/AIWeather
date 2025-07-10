# App Store 上架步骤指南

## 第一步：生成 App Store 截图

### 在 Xcode 中操作：
1. 确保 Xcode 已打开 Weather 项目
2. 选择模拟器：iPhone 15 Pro Max (6.7英寸)
3. 点击运行按钮 (▶️) 启动应用
4. 等待应用启动并加载数据

### 截图顺序：
1. **主界面截图**
   - 等待天气数据加载完成
   - 确保显示晴天效果（视觉效果最佳）
   - Device > Screenshot (⌘+S)

2. **一周预报截图**
   - 点击"一周预报"按钮
   - 等待动画完成
   - 截图展示7天天气趋势

3. **城市管理截图**
   - 返回主界面
   - 点击"城市管理"
   - 可以先添加几个城市（北京、上海、深圳）
   - 截图展示多城市列表

4. **设置界面截图**
   - 点击"设置"
   - 确保所有设置选项都可见
   - 截图

5. **通知设置截图**（可选）
   - 在设置中打开通知相关选项
   - 截图展示通知功能

截图会自动保存到桌面，将它们移动到：
`/Users/weifu/Desktop/Weather/AppStore/Screenshots/`

## 第二步：更新 Team ID

编辑 ExportOptions.plist：
```xml
<key>teamID</key>
<string>YOUR_TEAM_ID</string>  <!-- 替换为你的 Team ID -->
```

在 Xcode 中查看 Team ID：
1. 点击项目名称
2. 选择 "Signing & Capabilities"
3. 查看 Team 下方的 ID

## 第三步：创建发布版本归档

### 在 Xcode 中：
1. **选择设备**：顶部选择 "Any iOS Device (arm64)"
2. **清理构建**：Product > Clean Build Folder (⇧⌘K)
3. **创建归档**：Product > Archive
4. 等待构建完成（约2-3分钟）

### 归档完成后：
1. Organizer 窗口会自动打开
2. 选择刚创建的归档
3. 点击 "Distribute App"
4. 选择 "App Store Connect"
5. 选择 "Upload"
6. 保持默认选项，点击 "Next"
7. 等待上传完成

## 第四步：在 App Store Connect 创建应用

### 访问 App Store Connect：
1. 打开 https://appstoreconnect.apple.com
2. 使用你的 Apple Developer 账号登录

### 创建新应用：
1. 点击 "我的 App"
2. 点击 "+" 按钮
3. 选择 "新建 App"

### 填写应用信息：
- **平台**：iOS
- **名称**：WeiWeathers
- **主要语言**：简体中文
- **套装 ID**：选择 com.weiproduct.WeiWeathers
- **SKU**：weather-app-2024

## 第五步：填写应用详情

### 1. 应用信息
- **类别**：天气
- **内容版权**：© 2024 Your Name

### 2. 价格与销售范围
- **价格**：免费
- **销售范围**：所有国家和地区

### 3. 版本信息
使用 `/AppStore/app_store_listing.md` 中的内容：
- **版本号**：1.0.0
- **描述**：复制中文描述
- **新功能**：首次发布

### 4. 关键词
天气,天气预报,气象,温度,降雨,预警,weather,forecast,temperature,rain

### 5. 技术支持和隐私政策
- **技术支持 URL**：https://github.com/yourusername/weather-support
- **隐私政策 URL**：https://github.com/yourusername/weather-privacy

### 6. 上传截图
- 将生成的截图拖拽到对应位置
- 确保 6.7英寸截图已上传（必需）

### 7. App 预览（可选）
- 可以录制一段应用使用视频

## 第六步：提交审核

### 审核前检查：
- ✅ 所有必填信息已填写
- ✅ 截图已上传
- ✅ 构建版本已选择
- ✅ 应用描述准确
- ✅ 联系信息正确

### 提交：
1. 点击 "存储" 保存所有更改
2. 点击 "提交以供审核"
3. 回答审核问题：
   - 是否使用广告标识符：否
   - 是否包含加密：否
   - 是否为内容分级：否

4. 点击 "提交"

## 第七步：等待审核

### 审核时间：
- 通常 24-48 小时
- 首次提交可能需要更长时间

### 审核状态：
- **正在等待审核**：已提交，等待开始
- **正在审核**：Apple 正在审核
- **准备销售**：审核通过，可以上架
- **被拒绝**：需要修改后重新提交

### 如果被拒绝：
1. 查看拒绝原因
2. 根据反馈修改
3. 重新提交审核

## 注意事项

1. **确保 Vercel 代理正常工作**
   - 测试 API 请求是否正常
   - 确保 Bundle ID 验证通过

2. **版本号管理**
   - 每次更新需要递增版本号
   - Build 号必须唯一

3. **应用图标**
   - 确保所有尺寸图标都已包含
   - 图标清晰无水印

4. **权限说明**
   - 位置权限说明要清晰
   - 通知权限说明要准确

祝你顺利上架！🎉