// Vercel/Netlify 云函数示例
// 将此部署到 Vercel，用户只能访问你的云函数 URL

export default async function handler(req, res) {
  const { city, lat, lon } = req.query;
  
  // API 密钥存储在环境变量中
  const API_KEY = process.env.OPENWEATHER_API_KEY;
  
  // 可选：验证请求来源
  const allowedOrigins = ['your-app-bundle-id'];
  const origin = req.headers['x-app-bundle-id'];
  
  if (!allowedOrigins.includes(origin)) {
    return res.status(403).json({ error: 'Forbidden' });
  }
  
  // 代理请求到 OpenWeatherMap
  try {
    const weatherUrl = `https://api.openweathermap.org/data/2.5/weather?appid=${API_KEY}&q=${city}`;
    const response = await fetch(weatherUrl);
    const data = await response.json();
    
    // 可选：添加速率限制
    res.setHeader('X-RateLimit-Limit', '100');
    
    res.status(200).json(data);
  } catch (error) {
    res.status(500).json({ error: 'Weather service error' });
  }
}