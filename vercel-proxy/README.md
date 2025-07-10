# Weather API 代理服务器

这个服务器保护你的 OpenWeatherMap API 密钥，防止在客户端暴露。

## 部署步骤（5分钟搞定）

### 1. 安装 Vercel CLI
```bash
npm install -g vercel
```

### 2. 登录 Vercel（免费）
```bash
vercel login
```

### 3. 部署
```bash
cd vercel-proxy
vercel
```

### 4. 设置环境变量
```bash
# 部署后，Vercel 会给你一个 URL
# 访问 https://vercel.com/your-username/weather-api-proxy/settings/environment-variables
# 添加 OPENWEATHER_API_KEY = 你的API密钥
```

或者使用命令行：
```bash
vercel env add OPENWEATHER_API_KEY production
# 输入你的 API 密钥
```

### 5. 重新部署使环境变量生效
```bash
vercel --prod
```

## 获得的 API 端点

假设你的部署 URL 是：`https://weather-api-proxy.vercel.app`

- 当前天气：`https://weather-api-proxy.vercel.app/api/weather?city=Beijing`
- 天气预报：`https://weather-api-proxy.vercel.app/api/forecast?city=Beijing`
- 城市搜索：`https://weather-api-proxy.vercel.app/api/search?q=Beijing`

## 本地测试

```bash
# 创建 .env.local 文件
cp .env.example .env.local
# 编辑 .env.local，添加你的 API 密钥

# 运行本地服务器
vercel dev
# 访问 http://localhost:3000/api/weather?city=Beijing
```

## 免费额度

- **请求数**：无限制
- **流量**：100GB/月（约 1000 万次请求）
- **执行时间**：10 秒超时
- **并发**：1000

对于天气 App 来说，完全够用！

## 更新 iOS App

更新你的 `WeatherService.swift`，使用新的代理 URL：

```swift
// 旧代码（不安全）
let url = "https://api.openweathermap.org/data/2.5/weather?appid=YOUR_KEY"

// 新代码（安全）
let url = "https://your-app.vercel.app/api/weather?city=Beijing"
```

现在你的 API 密钥完全安全了！