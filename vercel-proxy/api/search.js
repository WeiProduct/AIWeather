// 城市搜索 API
export default async function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, X-App-Bundle-ID');
  
  if (req.method === 'OPTIONS') {
    return res.status(200).end();
  }
  
  const API_KEY = process.env.OPENWEATHER_API_KEY;
  const { q, limit = 5 } = req.query;
  
  if (!API_KEY) {
    return res.status(500).json({ error: 'API key not configured' });
  }
  
  if (!q) {
    return res.status(400).json({ error: 'Query parameter is required' });
  }
  
  try {
    const geocodingUrl = `https://api.openweathermap.org/geo/1.0/direct?q=${encodeURIComponent(q)}&limit=${limit}&appid=${API_KEY}`;
    
    const response = await fetch(geocodingUrl);
    const data = await response.json();
    
    if (!response.ok) {
      return res.status(response.status).json(data);
    }
    
    // 缓存 1 小时
    res.setHeader('Cache-Control', 's-maxage=3600, stale-while-revalidate');
    
    return res.status(200).json(data);
    
  } catch (error) {
    console.error('Search API Error:', error);
    return res.status(500).json({ error: 'Failed to search cities' });
  }
}