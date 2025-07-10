// Vercel Serverless Function
// 这个文件会部署到 Vercel，保护你的 API 密钥

export default async function handler(req, res) {
  // 允许 CORS
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, X-App-Bundle-ID');
  
  // 处理 OPTIONS 请求
  if (req.method === 'OPTIONS') {
    return res.status(200).end();
  }
  
  // 从环境变量获取 API 密钥（在 Vercel 后台设置）
  const API_KEY = process.env.OPENWEATHER_API_KEY;
  
  if (!API_KEY) {
    return res.status(500).json({ 
      error: 'Server configuration error',
      message: 'API key not configured' 
    });
  }
  
  // 获取请求参数
  const { city, lat, lon, lang = 'zh_cn', units = 'metric' } = req.query;
  
  // 验证请求来源（可选）
  const bundleId = req.headers['x-app-bundle-id'];
  const allowedBundleIds = ['com.weiproduct.WeiWeathers', 'com.yourcompany.weather'];
  
  // 如果需要严格验证，可以启用这个检查
  // if (bundleId && !allowedBundleIds.includes(bundleId)) {
  //   return res.status(403).json({ error: 'Forbidden' });
  // }
  
  try {
    let weatherUrl;
    
    if (city) {
      // 通过城市名查询
      weatherUrl = `https://api.openweathermap.org/data/2.5/weather?q=${encodeURIComponent(city)}&appid=${API_KEY}&units=${units}&lang=${lang}`;
    } else if (lat && lon) {
      // 通过坐标查询
      weatherUrl = `https://api.openweathermap.org/data/2.5/weather?lat=${lat}&lon=${lon}&appid=${API_KEY}&units=${units}&lang=${lang}`;
    } else {
      return res.status(400).json({ 
        error: 'Bad Request',
        message: 'Please provide city name or coordinates' 
      });
    }
    
    // 请求 OpenWeatherMap API
    const response = await fetch(weatherUrl);
    const data = await response.json();
    
    if (!response.ok) {
      return res.status(response.status).json(data);
    }
    
    // 添加缓存控制（缓存 5 分钟）
    res.setHeader('Cache-Control', 's-maxage=300, stale-while-revalidate');
    
    // 返回天气数据
    return res.status(200).json(data);
    
  } catch (error) {
    console.error('Weather API Error:', error);
    return res.status(500).json({ 
      error: 'Internal Server Error',
      message: 'Failed to fetch weather data' 
    });
  }
}