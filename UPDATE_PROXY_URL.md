# 更新代理 URL 指南

## 当你完成 Vercel 部署后：

1. 打开 `/Users/weifu/Desktop/Weather/Weather/ApiConfig.swift`

2. 找到第 6 行：
   ```swift
   static let proxyBaseURL = "https://weather-api-proxy.vercel.app"
   ```

3. 替换为你的实际 URL，例如：
   ```swift
   static let proxyBaseURL = "https://your-app-name.vercel.app"
   ```

4. 保存文件

5. 在 Xcode 中测试：
   - 选择 Release 配置
   - 运行应用
   - 确认天气数据正常加载

## 测试命令

部署后可以用以下命令测试你的代理：

```bash
# 测试天气 API
curl https://your-app-name.vercel.app/api/weather?city=Beijing

# 测试预报 API  
curl https://your-app-name.vercel.app/api/forecast?city=Beijing

# 测试搜索 API
curl https://your-app-name.vercel.app/api/search?q=Beijing
```

如果返回 JSON 数据，说明代理工作正常！