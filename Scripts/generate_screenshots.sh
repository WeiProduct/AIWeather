#!/bin/bash

# App Store Screenshot Requirements
# iPhone 6.7" (1290 x 2796) - iPhone 15 Pro Max
# iPhone 6.5" (1242 x 2688) - iPhone 11 Pro Max
# iPhone 5.5" (1242 x 2208) - iPhone 8 Plus
# iPad 12.9" (2048 x 2732) - iPad Pro

echo "📸 App Store 截图生成指南"
echo "========================"
echo ""
echo "需要的截图尺寸："
echo "1. iPhone 6.7\" - 1290 x 2796 (必需)"
echo "2. iPhone 6.5\" - 1242 x 2688 (可选)"
echo "3. iPad 12.9\" - 2048 x 2732 (如支持 iPad)"
echo ""
echo "建议截图内容："
echo "1. 主界面 - 展示当前天气"
echo "2. 一周预报 - 展示7天天气"
echo "3. 城市管理 - 展示多城市功能"
echo "4. 设置界面 - 展示个性化选项"
echo "5. 通知设置 - 展示天气预警功能"
echo ""
echo "截图技巧："
echo "- 使用 Xcode Simulator 的 Device > Screenshot"
echo "- 选择有代表性的天气状况（晴天、雨天等）"
echo "- 确保界面语言正确（中文/英文）"
echo "- 隐藏状态栏时间，使用 9:41"
echo ""
echo "自动化方案："
echo "可以使用 fastlane snapshot 自动生成"