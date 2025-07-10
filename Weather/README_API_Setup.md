# 天气应用 API 配置说明

## 概述

此天气应用使用 OpenWeatherMap API 获取真实的天气数据。如果未配置 API 密钥，应用将使用模拟数据。

## 获取 API 密钥

### 1. 注册 OpenWeatherMap 账号

1. 访问 [OpenWeatherMap](https://openweathermap.org/api)
2. 点击 "Sign Up" 注册新账号
3. 完成邮箱验证

### 2. 获取免费 API 密钥

1. 登录后，访问 [API Keys 页面](https://home.openweathermap.org/api_keys)
2. 复制默认的 API 密钥，或者创建新的 API 密钥
3. 免费版本限制：
   - 每分钟最多 60 次调用
   - 每月最多 1,000,000 次调用
   - 包含当前天气、5天预报、地理编码等功能

## 配置 API 密钥

### 在应用中配置

1. 找到 `Weather/ApiConfig.swift` 文件
2. 将以下行中的 `YOUR_API_KEY` 替换为您的实际 API 密钥：

```swift
static let openWeatherMapApiKey = "YOUR_API_KEY"
```

### 示例

```swift
// 替换前
static let openWeatherMapApiKey = "YOUR_API_KEY"

// 替换后（示例密钥）
static let openWeatherMapApiKey = "abcd1234efgh5678ijkl9012mnop3456"
```

## 功能说明

### 配置 API 密钥后可用的功能：

✅ **真实天气数据**
- 当前天气信息
- 5天天气预报
- 真实的温度、湿度、风速等数据

✅ **全球城市搜索**
- 搜索世界任意城市
- 自动补全城市名称
- 支持中英文城市名

✅ **准确的地理定位**
- 基于GPS坐标获取当前位置天气
- 准确的城市名称显示

### 未配置 API 密钥时：

⚠️ **模拟数据模式**
- 显示随机生成的天气数据
- 城市搜索仅限于预设城市列表
- 所有功能正常运行，但数据为模拟

## API 使用量监控

建议定期检查您的 API 使用量：

1. 访问 [OpenWeatherMap 统计页面](https://home.openweathermap.org/statistics)
2. 查看每日和每月的 API 调用次数
3. 免费版本限制充足，适合个人使用

## 注意事项

- 🔒 **安全性**: 请不要将 API 密钥上传到公共代码仓库
- 🕐 **激活时间**: 新注册的 API 密钥可能需要 10-60 分钟才能生效
- 📊 **使用量**: 应用会智能缓存数据，减少不必要的 API 调用

## 故障排除

### 如果应用显示"API密钥未配置"：

1. 检查 `ApiConfig.swift` 中的 API 密钥是否正确替换
2. 确保 API 密钥没有多余的空格或引号
3. 重新编译并运行应用

### 如果 API 调用失败：

1. 检查网络连接
2. 确认 API 密钥是否已激活（新密钥需要时间激活）
3. 查看 Xcode 控制台的错误信息

---

**📞 如有问题，请查看 OpenWeatherMap 的 [官方文档](https://openweathermap.org/api) 或联系技术支持。** 