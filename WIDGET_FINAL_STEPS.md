# Widget 最终配置步骤

## ✅ 已完成的配置
1. 主应用 App Groups 已配置: `group.com.weiweathers.weather`
2. Widget Extension 已添加到项目
3. Bundle Identifier 已修复为: `com.weiproduct.WeathersPro.widget`

## 🔧 请在 Xcode 中完成以下步骤：

### 1. 配置 Widget Extension 的 App Groups
1. 选择 **WeatherWidgetExtension** target
2. 在 **Signing & Capabilities** 标签中
3. 点击 **+ Capability**
4. 添加 **App Groups**
5. 勾选现有的 group: `group.com.weiweathers.weather`（应该已经存在）

### 2. 确认所有文件已正确添加
1. 在项目导航器中检查 `WeatherWidget` 文件夹
2. 确保以下文件存在：
   - WeatherWidget.swift
   - WeatherWidget.intentdefinition
   - Assets.xcassets
   - Info.plist
   - WeatherWidget.entitlements

### 3. 清理并重新编译
1. 按 **Shift + Cmd + K** 清理构建
2. 按 **Cmd + B** 重新编译

### 4. 运行和测试
1. 选择真机或模拟器
2. 按 **Cmd + R** 运行应用
3. 在应用中刷新获取天气数据
4. 返回主屏幕，长按添加小组件

## 🎯 测试检查列表
- [ ] 主应用能正常运行
- [ ] 能获取并显示天气数据
- [ ] 长按主屏幕能看到小组件选项
- [ ] 小组件显示正确的天气数据
- [ ] 小组件支持小、中、大三种尺寸

## ⚠️ 可能的问题及解决方案

### 如果看不到小组件选项：
1. 确保两个 target 都使用相同的 App Group
2. 重启设备或模拟器
3. 删除应用并重新安装

### 如果小组件显示"暂无数据"：
1. 先在主应用中获取天气数据
2. 检查控制台是否有 App Group 相关错误
3. 确认 `WidgetDataManager` 正确保存了数据

### 如果编译失败：
1. 检查 Widget target 的 iOS Deployment Target 是否为 14.0+
2. 确保所有文件都正确添加到 Widget target
3. 查看具体的编译错误信息

## 🎉 成功标志
当您看到以下情况时，说明配置成功：
- 能在主屏幕添加天气小组件
- 小组件显示当前天气信息
- 主应用更新数据后，小组件自动刷新