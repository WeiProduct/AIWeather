#!/usr/bin/env python3
"""
配置 Weather 应用的 Widget Extension
"""

import os
import plistlib
import json

def update_info_plist():
    """更新主应用的 Info.plist 以支持 App Groups"""
    info_plist_path = "/Users/weifu/Desktop/Weather/Weather/Info.plist"
    
    try:
        with open(info_plist_path, 'rb') as f:
            plist = plistlib.load(f)
        
        # 添加 App Groups 权限
        if 'UIApplicationSceneManifest' not in plist:
            plist['UIApplicationSceneManifest'] = {
                'UIApplicationSupportsMultipleScenes': True
            }
        
        # 保存更新后的 plist
        with open(info_plist_path, 'wb') as f:
            plistlib.dump(plist, f)
        
        print("✅ 已更新 Info.plist")
        
    except Exception as e:
        print(f"❌ 更新 Info.plist 失败: {e}")

def create_entitlements():
    """创建应用权限文件"""
    # 主应用权限文件
    app_entitlements = """<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.security.application-groups</key>
    <array>
        <string>group.com.weiweathers.weather</string>
    </array>
</dict>
</plist>"""
    
    # Widget 权限文件
    widget_entitlements = """<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.security.application-groups</key>
    <array>
        <string>group.com.weiweathers.weather</string>
    </array>
</dict>
</plist>"""
    
    # 创建权限文件
    with open("/Users/weifu/Desktop/Weather/Weather/Weather.entitlements", 'w') as f:
        f.write(app_entitlements)
    
    with open("/Users/weifu/Desktop/Weather/WeatherWidget/WeatherWidget.entitlements", 'w') as f:
        f.write(widget_entitlements)
    
    print("✅ 已创建权限文件")

def update_widget_data_manager():
    """更新 WidgetDataManager 中的 App Group ID"""
    manager_path = "/Users/weifu/Desktop/Weather/Weather/Services/WidgetDataManager.swift"
    
    try:
        with open(manager_path, 'r') as f:
            content = f.read()
        
        # 更新 App Group ID
        content = content.replace(
            'private let appGroupIdentifier = "group.com.yourcompany.weather"',
            'private let appGroupIdentifier = "group.com.weiweathers.weather"'
        )
        
        with open(manager_path, 'w') as f:
            f.write(content)
        
        print("✅ 已更新 WidgetDataManager 的 App Group ID")
        
    except Exception as e:
        print(f"❌ 更新 WidgetDataManager 失败: {e}")

def update_widget_swift():
    """更新 WeatherWidget.swift 中的 App Group ID"""
    widget_path = "/Users/weifu/Desktop/Weather/WeatherWidget/WeatherWidget.swift"
    
    try:
        with open(widget_path, 'r') as f:
            content = f.read()
        
        # 更新 App Group ID
        content = content.replace(
            'guard let sharedDefaults = UserDefaults(suiteName: "group.com.yourcompany.weather")',
            'guard let sharedDefaults = UserDefaults(suiteName: "group.com.weiweathers.weather")'
        )
        
        with open(widget_path, 'w') as f:
            f.write(content)
        
        print("✅ 已更新 WeatherWidget.swift 的 App Group ID")
        
    except Exception as e:
        print(f"❌ 更新 WeatherWidget.swift 失败: {e}")

def create_widget_bundle_resources():
    """创建 Widget 所需的资源文件"""
    # 创建 Assets.xcassets 目录
    assets_path = "/Users/weifu/Desktop/Weather/WeatherWidget/Assets.xcassets"
    os.makedirs(assets_path, exist_ok=True)
    
    # 创建 Contents.json
    contents = {
        "info": {
            "author": "xcode",
            "version": 1
        }
    }
    
    with open(f"{assets_path}/Contents.json", 'w') as f:
        json.dump(contents, f, indent=2)
    
    # 创建 AccentColor.colorset
    accent_color_path = f"{assets_path}/AccentColor.colorset"
    os.makedirs(accent_color_path, exist_ok=True)
    
    accent_contents = {
        "colors": [
            {
                "idiom": "universal"
            }
        ],
        "info": {
            "author": "xcode",
            "version": 1
        }
    }
    
    with open(f"{accent_color_path}/Contents.json", 'w') as f:
        json.dump(accent_contents, f, indent=2)
    
    # 创建 AppIcon.appiconset
    app_icon_path = f"{assets_path}/AppIcon.appiconset"
    os.makedirs(app_icon_path, exist_ok=True)
    
    icon_contents = {
        "images": [
            {
                "idiom": "universal",
                "platform": "ios",
                "size": "1024x1024"
            }
        ],
        "info": {
            "author": "xcode",
            "version": 1
        }
    }
    
    with open(f"{app_icon_path}/Contents.json", 'w') as f:
        json.dump(icon_contents, f, indent=2)
    
    print("✅ 已创建 Widget 资源文件")

def create_widget_preview_content():
    """创建预览内容"""
    preview_path = "/Users/weifu/Desktop/Weather/WeatherWidget/Preview Content"
    os.makedirs(preview_path, exist_ok=True)
    
    # 创建空的 Contents.json
    contents = {
        "info": {
            "author": "xcode",
            "version": 1
        }
    }
    
    preview_assets_path = f"{preview_path}/Preview Assets.xcassets"
    os.makedirs(preview_assets_path, exist_ok=True)
    
    with open(f"{preview_assets_path}/Contents.json", 'w') as f:
        json.dump(contents, f, indent=2)
    
    print("✅ 已创建预览内容目录")

def create_widget_bridging_header():
    """创建桥接头文件（如果需要）"""
    bridging_header = """//
//  WeatherWidget-Bridging-Header.h
//  WeatherWidget
//

#ifndef WeatherWidget_Bridging_Header_h
#define WeatherWidget_Bridging_Header_h

#endif /* WeatherWidget_Bridging_Header_h */
"""
    
    with open("/Users/weifu/Desktop/Weather/WeatherWidget/WeatherWidget-Bridging-Header.h", 'w') as f:
        f.write(bridging_header)
    
    print("✅ 已创建桥接头文件")

def main():
    print("🔧 开始配置 Widget Extension...")
    
    # 执行各项配置
    update_info_plist()
    create_entitlements()
    update_widget_data_manager()
    update_widget_swift()
    create_widget_bundle_resources()
    create_widget_preview_content()
    create_widget_bridging_header()
    
    print("\n✅ Widget Extension 配置完成！")
    print("\n📝 接下来的步骤：")
    print("1. 在 Xcode 中打开项目")
    print("2. File → New → Target → Widget Extension")
    print("3. 命名为 'WeatherWidget'")
    print("4. 将 /WeatherWidget 文件夹中的所有文件添加到 Widget target")
    print("5. 在两个 target 的 Signing & Capabilities 中添加 App Groups")
    print("6. 使用 App Group ID: group.com.weiweathers.weather")
    print("7. 编译并运行应用")

if __name__ == "__main__":
    main()