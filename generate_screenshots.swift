#!/usr/bin/swift
// 截图准备脚本 - 用于生成理想的测试数据

import Foundation

// 理想的天气数据配置
let idealWeatherData = """
天气数据建议：

1. 主界面截图 - 晴天
   - 城市：北京
   - 温度：23°C
   - 天气：晴
   - 温度范围：18°C - 28°C
   - 湿度：45%
   - 风速：12 km/h
   - 能见度：15 km

2. 详情页截图 - 多云
   - 体感温度：25°C
   - 紫外线指数：6 (高)
   - 气压：1013 hPa
   - 降水概率：20%

3. 趋势图表截图
   - 展开天气趋势卡片
   - 显示温度变化图表
   - 时间范围：24小时

4. 设置页面截图
   - 显示所有功能开关
   - 通知设置已开启
   - 语言切换选项可见

5. 小组件截图
   - 在主屏幕添加小、中、大三种尺寸
   - 显示当前天气信息
"""

print(idealWeatherData)

// 生成截图检查清单
let screenshotChecklist = """

📸 截图检查清单：

准备工作：
□ 设置设备时间为整点（如 9:00）
□ 电量显示充足（>80%）
□ 关闭勿扰模式
□ 清除所有通知

截图 1 - 主界面：
□ 选择晴天天气（背景美观）
□ 展开穿衣建议卡片
□ 展开日出日落卡片
□ 隐藏Photography Times（默认隐藏）
□ 确保所有文字清晰可见

截图 2 - 天气详情：
□ 点击 Details 按钮
□ 显示完整的天气指标
□ 温度变化条显示正确

截图 3 - 天气趋势：
□ 展开趋势图表卡片
□ 选择温度图表
□ 显示24小时数据

截图 4 - 设置页面：
□ 点击 Settings 按钮
□ 显示功能模块开关
□ 显示通知设置

截图 5 - 小组件：
□ 返回主屏幕
□ 长按添加小组件
□ 选择不同尺寸展示
"""

print(screenshotChecklist)

// 文件命名建议
let namingGuide = """

📝 文件命名规范：

iPhone 6.7" (1290×2796):
- 01_main_screen_6.7.png
- 02_detail_view_6.7.png
- 03_trends_chart_6.7.png
- 04_settings_6.7.png
- 05_widgets_6.7.png

iPhone 6.5" (1242×2688):
- 01_main_screen_6.5.png
- 02_detail_view_6.5.png
- 03_trends_chart_6.5.png
- 04_settings_6.5.png
- 05_widgets_6.5.png
"""

print(namingGuide)

// 最终提醒
print("\n✅ 截图完成后：")
print("1. 检查每张截图的清晰度")
print("2. 确保没有敏感信息")
print("3. 保存为 PNG 格式")
print("4. 上传到 App Store Connect")