# iOS 小组件配置指南

## 概述
Weather 应用现已支持 iOS 小组件功能，可以在主屏幕上快速查看天气信息。

## 支持的小组件尺寸

### 1. 小尺寸小组件
- 显示城市名称、当前温度、天气描述
- 显示今日最高/最低温度
- 紧凑的布局，适合快速查看

### 2. 中等尺寸小组件
- 包含小尺寸的所有信息
- 额外显示体感温度和湿度
- 更详细的天气信息展示

### 3. 大尺寸小组件
- 完整的天气信息展示
- 包含日期、详细天气数据网格
- 显示最后更新时间
- 适合深度天气信息爱好者

## 配置步骤

### 1. 在 Xcode 中配置 App Groups

1. 选择主应用 Target
2. 进入 "Signing & Capabilities" 标签
3. 点击 "+ Capability" 添加 "App Groups"
4. 创建新的 App Group: `group.com.yourcompany.weather`

5. 选择 Widget Extension Target
6. 重复步骤 2-3
7. 选择相同的 App Group: `group.com.yourcompany.weather`

### 2. 更新 Bundle Identifier

在 `WidgetDataManager.swift` 中更新 App Group 标识符：
```swift
private let appGroupIdentifier = "group.com.yourcompany.weather"
```

### 3. 添加 Widget Extension 到项目

1. 在 Xcode 中选择 File → New → Target
2. 选择 "Widget Extension"
3. 命名为 "WeatherWidget"
4. 确保 "Include Configuration Intent" 被选中
5. 将创建的文件移动到 `/WeatherWidget` 目录

### 4. 配置 Info.plist

确保 Widget Extension 的 Info.plist 包含必要的配置。

## 使用方法

### 添加小组件到主屏幕

1. 长按主屏幕空白处进入编辑模式
2. 点击左上角的 "+" 按钮
3. 搜索 "Weather" 或应用名称
4. 选择想要的小组件尺寸
5. 点击 "添加小组件"

### 小组件数据更新

- 小组件会在每次打开主应用并获取天气数据时自动更新
- 小组件每 15 分钟自动刷新一次
- 可以通过下拉刷新主应用来更新小组件数据

## 技术实现细节

### 数据共享机制

- 使用 App Groups 在主应用和小组件之间共享数据
- 数据通过 UserDefaults(suiteName:) 进行存储和读取
- 使用 JSON 编码/解码进行数据序列化

### 自动更新机制

- 主应用获取天气数据时自动更新小组件
- 使用 WidgetCenter.shared.reloadAllTimelines() 触发刷新
- Timeline 策略设置为每 15 分钟更新一次

### 颜色主题

小组件根据天气状况自动调整背景颜色：
- 晴天：蓝色渐变
- 多云：灰色渐变
- 雨天：深蓝色渐变
- 雪天：浅灰色渐变

## 注意事项

1. 确保 App Groups 配置正确，否则数据无法共享
2. 小组件的刷新频率受系统限制，不会实时更新
3. 首次使用需要打开主应用获取天气数据
4. 小组件显示的是最后一次更新的数据

## 故障排除

### 小组件显示"暂无数据"
- 确认已打开主应用并成功获取天气数据
- 检查 App Groups 配置是否正确
- 尝试删除小组件并重新添加

### 数据不更新
- 检查主应用是否能正常获取天气数据
- 确认 WidgetDataManager 正确调用
- 查看控制台日志是否有错误信息

### 小组件无法添加
- 确保 Widget Extension 已正确添加到项目
- 检查 deployment target 是否支持 WidgetKit（iOS 14.0+）
- 重新编译并安装应用