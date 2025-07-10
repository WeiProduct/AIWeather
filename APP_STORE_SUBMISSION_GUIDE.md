# WeathersPro App Store 上架完整指南

## 📋 上架前检查清单

### 1. 应用基本信息
- **应用名称**: WeathersPro (或 WeiWeathers)
- **Bundle ID**: com.weiproduct.WeathersPro
- **版本号**: 1.0
- **分类**: 天气类应用

### 2. 必需材料准备

#### App 图标 (必需)
- **1024×1024**: App Store 展示图标 (PNG, 无圆角)
- **不同尺寸**: Xcode 会自动生成其他尺寸

#### 截图 (必需)
**iPhone 6.7" (iPhone 14 Pro Max, 15 Pro Max)**:
- 尺寸: 1290×2796 或 1284×2778
- 数量: 3-10张
- 格式: PNG 或 JPEG

**iPhone 6.5" (iPhone XS Max, 11 Pro Max)**:
- 尺寸: 1242×2688
- 数量: 3-10张

**推荐截图内容**:
1. 主界面 - 显示天气信息
2. 天气详情页面
3. 设置页面
4. 城市管理页面
5. 小组件展示

#### 应用描述文本
- **应用描述** (最多 4000 字符)
- **关键词** (最多 100 字符)
- **宣传文本** (最多 170 字符)

## 🔧 配置 Xcode 项目

### 1. 检查项目设置

```bash
# 检查当前 Bundle ID
grep -r "PRODUCT_BUNDLE_IDENTIFIER" Weather.xcodeproj/project.pbxproj
```

### 2. 设置版本信息
- **版本号 (CFBundleShortVersionString)**: 1.0
- **构建号 (CFBundleVersion)**: 1

### 3. 配置权限描述
确保 Info.plist 包含:
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>天气应用需要访问您的位置信息，以便为您提供当前位置的天气预报服务</string>
```

### 4. 设置部署目标
- **iOS Deployment Target**: 14.0 或更高
- **支持设备**: iPhone 和 iPad

## 📱 App Store Connect 配置

### 1. 创建应用记录
1. 访问 [App Store Connect](https://appstoreconnect.apple.com)
2. 点击 "我的 App" → "+" → "新建 App"
3. 填写基本信息:
   - **名称**: WeathersPro
   - **主要语言**: 简体中文
   - **Bundle ID**: com.weiproduct.WeathersPro
   - **SKU**: weatherspro2024 (唯一标识符)

### 2. 设置应用信息

#### 应用信息页面
- **分类**: 天气
- **二级分类**: (可选)
- **内容版权**: © 2024 Wei Fu
- **年龄分级**: 4+ (无限制内容)

#### 定价与供应状况
- **价格**: 免费
- **供应状况**: 在所有地区提供

#### App 隐私
设置隐私信息:
- **收集位置数据**: 是
- **使用目的**: 提供天气服务
- **数据处理**: 不与第三方共享

### 3. 版本信息

#### 截图上传
按设备类型上传截图:
- iPhone 6.7"
- iPhone 6.5"
- iPhone 5.5" (可选)

#### 描述文本
```text
应用描述示例:
WeathersPro 是一款简洁美观的天气应用，为您提供准确的天气预报和实用的生活建议。

主要功能：
• 实时天气数据，支持全球城市查询
• 精美的天气动画和渐变背景
• 日出日落时间及黄金时段提醒
• 智能穿衣建议，根据天气推荐服装
• 天气趋势图表，直观显示变化
• iOS 桌面小组件支持
• 天气预警通知
• 支持中英文切换

界面简洁直观，操作流畅，让您随时掌握天气变化，做好生活规划。
```

#### 关键词
```text
天气,预报,温度,雨,雪,风,湿度,气压,紫外线,空气质量
```

#### 宣传文本
```text
简洁美观的天气应用，提供准确预报和生活建议
```

## 📦 创建和上传构建版本

### 1. 准备构建环境
```bash
# 确保 Xcode 是最新版本
xcode-select --install

# 清理构建缓存
rm -rf ~/Library/Developer/Xcode/DerivedData
```

### 2. 配置代码签名
1. 选择 **WeathersPro** target
2. **Signing & Capabilities** → **Automatically manage signing** ✅
3. 选择开发团队
4. 对 **WeatherWidgetExtension** 重复相同步骤

### 3. 创建归档 (Archive)
1. 在 Xcode 中选择 **Any iOS Device (arm64)**
2. **Product** → **Archive**
3. 等待构建完成

### 4. 上传到 App Store
1. 在 Organizer 中选择刚创建的归档
2. 点击 **Distribute App**
3. 选择 **App Store Connect**
4. 选择 **Upload**
5. 配置选项:
   - **Strip Swift symbols**: ✅
   - **Upload your app's symbols**: ✅
   - **Manage Version and Build Number**: Xcode 管理
6. 点击 **Upload**

### 5. 等待处理
- 上传后需要等待 Apple 处理 (通常 5-15 分钟)
- 在 App Store Connect 中检查构建状态

## ✅ 提交审核

### 1. 选择构建版本
1. 在 App Store Connect 中进入应用
2. 选择 **iOS App** 版本
3. 在 **构建版本** 部分选择刚上传的版本

### 2. 完成版本信息
- 确保所有必需字段都已填写
- 检查截图是否正确显示
- 验证应用描述和关键词

### 3. 审核信息
- **联系信息**: 填写有效的邮箱和电话
- **备注**: 可以添加审核说明
- **演示账户**: 如果需要登录，提供测试账号

### 4. 提交审核
1. 点击 **提交以供审核**
2. 回答广告标识符问题 (通常选择 "否")
3. 确认导出合规性 (如果不加密选择 "否")
4. 最终提交

## ⏰ 审核时间线

### 预期时间
- **处理时间**: 1-7天 (平均 24-48 小时)
- **状态追踪**: 在 App Store Connect 中查看

### 可能的状态
- **等待审核**: 已提交，排队中
- **正在审核**: Apple 正在审核
- **被拒绝**: 需要修改后重新提交
- **准备销售**: 审核通过，即将上架
- **可供销售**: 已在 App Store 上架

## 🚨 常见拒绝原因及解决方案

### 1. 功能问题
**问题**: 应用功能不完整或崩溃
**解决**: 
- 全面测试应用功能
- 修复所有已知 bug
- 确保网络请求正常

### 2. 界面问题
**问题**: UI 适配问题或布局错误
**解决**:
- 测试不同设备尺寸
- 检查安全区域适配
- 修复界面错误

### 3. 权限问题
**问题**: 权限使用说明不清楚
**解决**:
- 完善权限使用说明
- 确保权限请求合理

### 4. 元数据问题
**问题**: 描述与实际功能不符
**解决**:
- 确保描述准确
- 截图展示实际功能

## 📞 支持联系

### Apple 支持
- **开发者支持**: https://developer.apple.com/support/
- **审核指南**: https://developer.apple.com/app-store/review/guidelines/

### 常用资源
- **Human Interface Guidelines**: iOS 设计规范
- **App Store Connect 帮助**: 上架流程指导

---

## 🎯 下一步行动

1. **准备材料**: 创建图标和截图
2. **配置项目**: 检查 Xcode 设置
3. **创建应用记录**: 在 App Store Connect 中设置
4. **上传构建**: 创建归档并上传
5. **提交审核**: 完成所有信息填写

祝您上架顺利！如有问题，随时询问。