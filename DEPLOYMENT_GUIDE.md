# Vercel 部署指南

## 步骤 1: 登录 Vercel

打开终端，运行以下命令：

```bash
cd /Users/weifu/Desktop/Weather/vercel-proxy
vercel login
```

选择登录方式（推荐使用 GitHub）。

## 步骤 2: 部署项目

```bash
vercel
```

首次部署时会询问：
1. Set up and deploy? **Y**
2. Which scope? 选择你的用户名
3. Link to existing project? **N**
4. Project name? **weather-api-proxy** (或你喜欢的名字)
5. Directory? **./** (当前目录)
6. Want to override settings? **N**

## 步骤 3: 设置环境变量

```bash
vercel env add OPENWEATHER_API_KEY production
```

输入 API 密钥：`4c4d5bc13f2896f47a0787a690afa2a3`

## 步骤 4: 部署到生产环境

```bash
vercel --prod
```

## 步骤 5: 获取部署 URL

部署成功后，Vercel 会显示你的 URL，例如：
- `https://weather-api-proxy.vercel.app`

## 步骤 6: 更新 iOS 应用

复制你的 Vercel URL，我会帮你更新 ApiConfig.swift。

---

**现在请按照上述步骤操作，完成后告诉我你的 Vercel URL。**