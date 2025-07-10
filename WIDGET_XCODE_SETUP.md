# Xcode Widget Extension 详细配置指南

## 前置准备
确保您已经运行了 `setup_widget.sh` 脚本，该脚本已经为您创建了所有必要的文件。

## 步骤 1: 创建 Widget Extension Target

1. 打开 `Weather.xcodeproj`
2. 在 Xcode 菜单栏选择 **File → New → Target**
3. 在弹出的模板选择窗口中：
   - 选择 **iOS** 平台
   - 在 Application Extension 分类下选择 **Widget Extension**
   - 点击 **Next**

## 步骤 2: 配置 Widget Extension

在配置页面填写以下信息：
- **Product Name**: `WeatherWidget`
- **Team**: 选择您的开发团队
- **Organization Identifier**: `com.weiweathers`
- **Bundle Identifier**: 会自动生成为 `com.weiweathers.weather.WeatherWidget`
- **Include Configuration Intent**: ✅ 勾选
- **Project**: Weather
- **Embed in Application**: Weather

点击 **Finish**

## 步骤 3: 激活 Scheme

Xcode 会询问是否激活新的 scheme，点击 **Activate**

## 步骤 4: 清理自动生成的文件

1. 在项目导航器中找到 `WeatherWidget` 文件夹
2. 删除以下 Xcode 自动生成的文件：
   - `WeatherWidget.swift`
   - `WeatherWidget.intentdefinition`
   - 保留 `Info.plist`

## 步骤 5: 添加我们创建的文件

1. 右键点击项目导航器中的 `WeatherWidget` 文件夹
2. 选择 **Add Files to "Weather"...**
3. 导航到 `/Users/weifu/Desktop/Weather/WeatherWidget/`
4. 选择以下文件：
   - `WeatherWidget.swift`
   - `WeatherWidget.intentdefinition`
   - `WeatherWidget.entitlements`
   - `Assets.xcassets` (文件夹)
   - `Preview Content` (文件夹)
   - `zh-Hans.lproj` (文件夹)
   - `en.lproj` (文件夹)
5. 在添加选项中：
   - **Destination**: ✅ Copy items if needed
   - **Added to targets**: ✅ WeatherWidget
6. 点击 **Add**

## 步骤 6: 配置主应用的 App Groups

1. 在项目导航器中选择项目名称 (蓝色图标)
2. 选择 **Weather** target (主应用)
3. 选择 **Signing & Capabilities** 标签
4. 点击左上角的 **+ Capability** 按钮
5. 在搜索框中输入 "App Groups"
6. 双击 **App Groups** 添加该功能
7. 在 App Groups 部分：
   - 点击 **+** 按钮
   - 输入: `group.com.weiweathers.weather`
   - 按回车确认

## 步骤 7: 配置 Widget 的 App Groups

1. 选择 **WeatherWidget** target
2. 选择 **Signing & Capabilities** 标签
3. 重复步骤 6 的操作：
   - 添加 **App Groups** capability
   - 使用相同的 group ID: `group.com.weiweathers.weather`

## 步骤 8: 配置 Widget 的 Info.plist

1. 在项目导航器中选择 `WeatherWidget/Info.plist`
2. 确保包含以下键值：
   ```xml
   <key>NSExtension</key>
   <dict>
       <key>NSExtensionPointIdentifier</key>
       <string>com.apple.widgetkit-extension</string>
   </dict>
   ```

## 步骤 9: 验证 Build Settings

1. 选择 **WeatherWidget** target
2. 选择 **Build Settings** 标签
3. 搜索 "deployment target"
4. 确保 **iOS Deployment Target** 设置为 **14.0** 或更高

## 步骤 10: 编译测试

1. 选择模拟器或真机
2. 选择 scheme 为 **Weather** (主应用)
3. 按 **Cmd + B** 编译项目
4. 如果出现编译错误，检查：
   - Import 语句是否正确
   - 文件是否正确添加到 target
   - App Group ID 是否一致

## 步骤 11: 运行和测试

1. 按 **Cmd + R** 运行应用
2. 在应用中刷新获取天气数据
3. 返回主屏幕
4. 长按主屏幕空白处进入编辑模式
5. 点击左上角 **+** 按钮
6. 搜索您的应用名称
7. 选择小组件尺寸并添加

## 常见问题解决

### 问题 1: Widget 不显示数据
- 确认主应用已经获取并保存了天气数据
- 检查 App Group ID 是否在两个 target 中完全一致
- 查看控制台日志是否有错误信息

### 问题 2: 编译错误 "No such module 'WidgetKit'"
- 确保 Widget target 的 iOS Deployment Target >= 14.0
- Clean build folder (Shift + Cmd + K) 后重新编译

### 问题 3: Widget 没有出现在添加列表中
- 确保 Widget Extension 已经正确添加到项目
- 尝试删除应用并重新安装
- 重启设备或模拟器

### 问题 4: App Groups 配置错误
- 确保使用的是相同的 App Group ID
- 检查 Provisioning Profile 是否支持 App Groups
- 在真机上测试时，确保开发证书配置正确

## 成功标志

当您成功配置后，应该能够：
1. ✅ 在主屏幕上添加天气小组件
2. ✅ 小组件显示当前天气数据
3. ✅ 主应用更新数据后，小组件自动刷新
4. ✅ 支持小、中、大三种尺寸

## 下一步

- 自定义小组件的外观设计
- 添加更多天气信息到小组件
- 实现小组件的深度链接功能
- 优化数据更新策略