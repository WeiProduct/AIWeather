// 7 天天气预报 API
export default async function handler(req, res) {
  // CORS 设置
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, X-App-Bundle-ID');
  
  if (req.method === 'OPTIONS') {
    return res.status(200).end();
  }
  
  const API_KEY = process.env.OPENWEATHER_API_KEY;
  
  if (!API_KEY) {
    return res.status(500).json({ error: 'API key not configured' });
  }
  
  const { city, lat, lon, lang = 'zh_cn', units = 'metric' } = req.query;
  
  try {
    let forecastUrl;
    
    if (city) {
      forecastUrl = `https://api.openweathermap.org/data/2.5/forecast?q=${encodeURIComponent(city)}&appid=${API_KEY}&units=${units}&lang=${lang}`;
    } else if (lat && lon) {
      forecastUrl = `https://api.openweathermap.org/data/2.5/forecast?lat=${lat}&lon=${lon}&appid=${API_KEY}&units=${units}&lang=${lang}`;
    } else {
      return res.status(400).json({ error: 'Please provide city or coordinates' });
    }
    
    const response = await fetch(forecastUrl);
    const data = await response.json();
    
    if (!response.ok) {
      return res.status(response.status).json(data);
    }
    
    // 缓存 30 分钟
    res.setHeader('Cache-Control', 's-maxage=1800, stale-while-revalidate');
    
    return res.status(200).json(data);
    
  } catch (error) {
    console.error('Forecast API Error:', error);
    return res.status(500).json({ error: 'Failed to fetch forecast data' });
  }
}