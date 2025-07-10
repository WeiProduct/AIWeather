# 部署云函数保护 API 密钥

## 方案对比

| 方案 | 成本 | 安全性 | 实现难度 |
|-----|------|--------|---------|
| 直接使用 API 密钥 | 免费 | ⚠️ 低 | 简单 |
| Vercel 云函数 | 免费 | ✅ 高 | 中等 |
| AWS Lambda | 按用量计费 | ✅ 高 | 中等 |
| 自建服务器 | 月费 | ✅✅ 最高 | 复杂 |

## 使用 Vercel（推荐）

### 1. 注册 Vercel
- 访问 https://vercel.com
- 使用 GitHub 登录（免费）

### 2. 创建项目
```bash
# 创建新文件夹
mkdir weather-api-proxy
cd weather-api-proxy

# 初始化项目
npm init -y

# 创建 API 文件
mkdir api
cp weather-proxy.js api/weather.js
```

### 3. 部署
```bash
# 安装 Vercel CLI
npm i -g vercel

# 部署
vercel

# 设置环境变量
vercel env add OPENWEATHER_API_KEY
```

### 4. 更新 iOS App
```swift
// ApiConfig.swift
struct ApiConfig {
    // 使用你的 Vercel 函数 URL
    static let weatherProxyURL = "https://your-app.vercel.app/api/weather"
    
    // 不再需要 API 密钥！
}
```

## 使用 Cloudflare Workers（备选）

```javascript
// Cloudflare Worker 示例
addEventListener('fetch', event => {
  event.respondWith(handleRequest(event.request))
})

async function handleRequest(request) {
  const url = new URL(request.url)
  const city = url.searchParams.get('city')
  
  // API 密钥在 Cloudflare 环境变量中
  const apiKey = OPENWEATHER_API_KEY
  
  const response = await fetch(
    `https://api.openweathermap.org/data/2.5/weather?q=${city}&appid=${apiKey}`
  )
  
  return response
}
```

## 额外安全措施

### 1. 请求签名
```swift
// iOS App 中
func createSignature(for request: URLRequest) -> String {
    let timestamp = Int(Date().timeIntervalSince1970)
    let secret = "your-shared-secret"
    let data = "\(timestamp)\(request.url?.absoluteString ?? "")"
    return data.hmac(algorithm: .sha256, key: secret)
}
```

### 2. 证书固定
```swift
// 防止中间人攻击
class WeatherService: NSObject, URLSessionDelegate {
    func urlSession(_ session: URLSession, 
                   didReceive challenge: URLAuthenticationChallenge) {
        // 验证服务器证书
        guard let serverTrust = challenge.protectionSpace.serverTrust else {
            return
        }
        // 实现证书固定逻辑
    }
}
```

## 最简单的开始

如果你想快速开始：

1. **使用 Vercel**（5分钟搞定）
   - 免费额度够用
   - 自动 HTTPS
   - 全球 CDN

2. **更新 App 代码**
   - 把 API 调用改为你的云函数 URL
   - 移除所有 API 密钥相关代码

这样，即使有人反编译你的 App，也拿不到 API 密钥！