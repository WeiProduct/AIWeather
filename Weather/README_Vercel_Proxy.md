# Weather App API 安全方案

## 问题
直接在 iOS 应用中包含 API 密钥是不安全的，用户可以通过以下方式获取：
- 反编译应用
- 使用代理工具拦截请求
- 查看应用包内容

## 解决方案：Vercel 代理服务器

使用免费的 Vercel 服务器作为代理，将 API 密钥保存在服务器端。

### 架构
```
iOS App → Vercel Proxy → OpenWeatherMap API
```

## 部署步骤

### 1. 准备工作
确保你已经创建了 `/vercel-proxy` 目录及其所有文件。

### 2. 安装 Vercel CLI
```bash
npm install -g vercel
```

### 3. 部署到 Vercel
```bash
cd vercel-proxy
vercel
```

首次部署时会询问：
- 登录/注册账号（使用 GitHub 账号即可）
- 项目名称（例如：weather-api-proxy）
- 选择框架：选择 "Other"

### 4. 配置环境变量
```bash
# 使用你的 OpenWeatherMap API 密钥
vercel env add OPENWEATHER_API_KEY production
# 输入你的 OpenWeatherMap API 密钥
```

### 5. 重新部署
```bash
vercel --prod
```

### 6. 获取你的 URL
部署完成后，Vercel 会给你一个 URL，例如：
```
https://weather-api-proxy.vercel.app
```

### 7. 更新 iOS 应用
编辑 `/Weather/ApiConfig.swift`：
```swift
// 将这行改为你的 Vercel URL
static let proxyBaseURL = "https://weather-api-proxy.vercel.app"
```

## 测试

### 本地测试
```bash
cd vercel-proxy
cp .env.example .env.local
# 编辑 .env.local，添加你的 API 密钥

vercel dev
# 访问 http://localhost:3000/api/weather?city=Beijing
```

### 线上测试
```bash
# 测试天气 API
curl https://your-app.vercel.app/api/weather?city=Beijing

# 测试预报 API
curl https://your-app.vercel.app/api/forecast?city=Beijing

# 测试搜索 API
curl https://your-app.vercel.app/api/search?q=Beijing
```

## 开发/生产环境切换

在 `ApiConfig.swift` 中已经配置了自动切换：
- **Debug 模式**：直接使用 API（方便开发调试）
- **Release 模式**：使用 Vercel 代理（保护 API 密钥）

## 免费额度
Vercel 免费套餐包含：
- **请求数**：无限制
- **流量**：100GB/月
- **执行时间**：10秒超时
- **并发**：1000

对于天气应用完全够用！

## 其他免费选择
如果你不想用 Vercel，还有其他选择：

### Netlify Functions
```javascript
// netlify/functions/weather.js
exports.handler = async (event) => {
    // 类似的代理代码
}
```

### Cloudflare Workers
```javascript
// worker.js
addEventListener('fetch', event => {
    event.respondWith(handleRequest(event.request))
})
```

两者都有类似的免费额度。

## 安全最佳实践
1. **永远不要**在客户端代码中硬编码 API 密钥
2. **使用 HTTPS** 确保传输安全
3. **添加速率限制**防止滥用（可选）
4. **监控使用情况**及时发现异常

## 故障排除

### API 密钥未配置
如果看到 "API key not configured" 错误：
1. 检查环境变量是否设置：`vercel env ls`
2. 确保重新部署：`vercel --prod`

### CORS 错误
代理已经配置了 CORS，如果还有问题：
1. 检查请求头
2. 确保使用正确的 URL

### 请求超时
1. 检查网络连接
2. OpenWeatherMap 服务可能暂时不可用

## 下一步
1. 部署 Vercel 代理
2. 更新 iOS 应用中的 `proxyBaseURL`
3. 发布应用到 App Store！

现在你的 API 密钥完全安全了！🎉