#!/usr/bin/env python3
"""
App Store 上架前检查脚本
"""

import os
import plistlib
import re

def check_info_plist():
    """检查 Info.plist 配置"""
    print("🔍 检查 Info.plist 配置...")
    
    plist_path = "/Users/weifu/Desktop/Weather/Weather/Info.plist"
    
    try:
        with open(plist_path, 'rb') as f:
            plist = plistlib.load(f)
        
        checks = {
            "应用显示名称": plist.get('CFBundleDisplayName', '未设置'),
            "位置权限说明": plist.get('NSLocationWhenInUseUsageDescription', '未设置'),
            "通知权限说明": plist.get('NSUserNotificationsUsageDescription', '未设置'),
            "加密豁免": plist.get('ITSAppUsesNonExemptEncryption', '未设置'),
        }
        
        for key, value in checks.items():
            status = "✅" if value != "未设置" else "❌"
            print(f"  {status} {key}: {value}")
            
    except Exception as e:
        print(f"❌ 读取 Info.plist 失败: {e}")

def check_project_settings():
    """检查项目设置"""
    print("\n🔍 检查项目设置...")
    
    project_path = "/Users/weifu/Desktop/Weather/Weather.xcodeproj/project.pbxproj"
    
    try:
        with open(project_path, 'r') as f:
            content = f.read()
        
        # 检查 Bundle ID
        bundle_ids = re.findall(r'PRODUCT_BUNDLE_IDENTIFIER = ([^;]+);', content)
        if bundle_ids:
            print(f"  ✅ Bundle ID: {bundle_ids[0].strip()}")
        else:
            print("  ❌ Bundle ID: 未找到")
        
        # 检查版本号
        marketing_versions = re.findall(r'MARKETING_VERSION = ([^;]+);', content)
        if marketing_versions:
            print(f"  ✅ 版本号: {marketing_versions[0].strip()}")
        else:
            print("  ❌ 版本号: 未找到")
        
        # 检查部署目标
        deployment_targets = re.findall(r'IPHONEOS_DEPLOYMENT_TARGET = ([^;]+);', content)
        if deployment_targets:
            target = deployment_targets[0].strip()
            print(f"  ✅ iOS 部署目标: {target}")
            if float(target) < 14.0:
                print("  ⚠️  建议将部署目标设置为 14.0 以支持小组件")
        else:
            print("  ❌ iOS 部署目标: 未找到")
            
    except Exception as e:
        print(f"❌ 读取项目文件失败: {e}")

def check_required_files():
    """检查必需文件"""
    print("\n🔍 检查必需文件...")
    
    required_files = [
        "/Users/weifu/Desktop/Weather/Weather/Info.plist",
        "/Users/weifu/Desktop/Weather/WeatherWidget/Info.plist",
        "/Users/weifu/Desktop/Weather/Weather/Assets.xcassets",
    ]
    
    for file_path in required_files:
        if os.path.exists(file_path):
            print(f"  ✅ {os.path.basename(file_path)}")
        else:
            print(f"  ❌ {os.path.basename(file_path)} (缺失)")

def check_assets():
    """检查资源文件"""
    print("\n🔍 检查应用图标...")
    
    assets_path = "/Users/weifu/Desktop/Weather/Weather/Assets.xcassets/AppIcon.appiconset"
    
    if os.path.exists(assets_path):
        print("  ✅ AppIcon.appiconset 存在")
        
        # 检查是否有图标文件
        icon_files = [f for f in os.listdir(assets_path) if f.endswith('.png')]
        if icon_files:
            print(f"  ✅ 找到 {len(icon_files)} 个图标文件")
        else:
            print("  ⚠️  没有找到图标文件，需要添加 1024x1024 的应用图标")
    else:
        print("  ❌ AppIcon.appiconset 不存在")

def generate_action_items():
    """生成行动项目清单"""
    print("\n📋 上架行动清单:")
    
    actions = [
        "1. 准备 1024×1024 应用图标 (PNG 格式)",
        "2. 准备至少 3 张应用截图",
        "3. 在 App Store Connect 创建应用记录",
        "4. 配置代码签名证书",
        "5. 创建归档 (Archive)",
        "6. 上传到 App Store Connect",
        "7. 填写应用描述和元数据",
        "8. 提交审核",
    ]
    
    for action in actions:
        print(f"  □ {action}")

def main():
    print("🚀 App Store 上架前检查")
    print("=" * 50)
    
    check_info_plist()
    check_project_settings()
    check_required_files()
    check_assets()
    generate_action_items()
    
    print("\n" + "=" * 50)
    print("✨ 检查完成！请根据上述结果进行必要的修改。")
    print("📖 详细指南请查看: APP_STORE_SUBMISSION_GUIDE.md")

if __name__ == "__main__":
    main()