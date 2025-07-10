#!/usr/bin/env python3
"""
自动添加 Widget Extension 到 Xcode 项目
"""

import os
import re
import uuid
import subprocess

def generate_uuid():
    """生成 Xcode 使用的 24 字符 UUID"""
    return ''.join(str(uuid.uuid4()).split('-'))[:24].upper()

def read_project_file():
    """读取项目文件"""
    project_path = "/Users/weifu/Desktop/Weather/Weather.xcodeproj/project.pbxproj"
    with open(project_path, 'r') as f:
        return f.read()

def write_project_file(content):
    """写入项目文件"""
    project_path = "/Users/weifu/Desktop/Weather/Weather.xcodeproj/project.pbxproj"
    with open(project_path, 'w') as f:
        f.write(content)

def add_widget_files_to_project():
    """添加 Widget 文件到项目"""
    content = read_project_file()
    
    # 生成必要的 UUID
    widget_group_id = generate_uuid()
    widget_target_id = generate_uuid()
    widget_product_id = generate_uuid()
    widget_build_file_id = generate_uuid()
    widget_sources_phase_id = generate_uuid()
    widget_frameworks_phase_id = generate_uuid()
    widget_resources_phase_id = generate_uuid()
    widget_embed_phase_id = generate_uuid()
    widget_config_list_id = generate_uuid()
    widget_debug_config_id = generate_uuid()
    widget_release_config_id = generate_uuid()
    
    # Widget 文件 IDs
    widget_swift_id = generate_uuid()
    widget_swift_build_id = generate_uuid()
    widget_info_plist_id = generate_uuid()
    widget_entitlements_id = generate_uuid()
    widget_assets_id = generate_uuid()
    widget_assets_build_id = generate_uuid()
    widget_intent_id = generate_uuid()
    widget_intent_build_id = generate_uuid()
    
    # 查找主应用的 target ID
    main_target_match = re.search(r'75002DAE2E0741CD00E5E081.*?/\* WeathersPro \*/', content)
    if not main_target_match:
        print("❌ 无法找到主应用 target")
        return False
    
    # 在 PBXBuildFile section 添加 Widget 文件
    build_files_section = """
		{widget_swift_build_id} /* WeatherWidget.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {widget_swift_id} /* WeatherWidget.swift */; }};
		{widget_assets_build_id} /* Assets.xcassets in Resources */ = {{isa = PBXBuildFile; fileRef = {widget_assets_id} /* Assets.xcassets */; }};
		{widget_intent_build_id} /* WeatherWidget.intentdefinition in Sources */ = {{isa = PBXBuildFile; fileRef = {widget_intent_id} /* WeatherWidget.intentdefinition */; }};
		{widget_build_file_id} /* WeatherWidgetExtension.appex in Embed App Extensions */ = {{isa = PBXBuildFile; fileRef = {widget_product_id} /* WeatherWidgetExtension.appex */; settings = {{ATTRIBUTES = (RemoveHeadersOnCopy, ); }}; }};
""".format(
        widget_swift_build_id=widget_swift_build_id,
        widget_swift_id=widget_swift_id,
        widget_assets_build_id=widget_assets_build_id,
        widget_assets_id=widget_assets_id,
        widget_intent_build_id=widget_intent_build_id,
        widget_intent_id=widget_intent_id,
        widget_build_file_id=widget_build_file_id,
        widget_product_id=widget_product_id
    )
    
    # 在 PBXBuildFile section 末尾添加
    content = content.replace(
        "/* End PBXBuildFile section */",
        build_files_section + "/* End PBXBuildFile section */"
    )
    
    # 在 PBXFileReference section 添加文件引用
    file_references = """
		{widget_swift_id} /* WeatherWidget.swift */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = WeatherWidget.swift; sourceTree = "<group>"; }};
		{widget_info_plist_id} /* Info.plist */ = {{isa = PBXFileReference; lastKnownFileType = text.plist.xml; path = Info.plist; sourceTree = "<group>"; }};
		{widget_entitlements_id} /* WeatherWidget.entitlements */ = {{isa = PBXFileReference; lastKnownFileType = text.plist.entitlements; path = WeatherWidget.entitlements; sourceTree = "<group>"; }};
		{widget_assets_id} /* Assets.xcassets */ = {{isa = PBXFileReference; lastKnownFileType = folder.assetcatalog; path = Assets.xcassets; sourceTree = "<group>"; }};
		{widget_intent_id} /* WeatherWidget.intentdefinition */ = {{isa = PBXFileReference; lastKnownFileType = file.intentdefinition; path = WeatherWidget.intentdefinition; sourceTree = "<group>"; }};
		{widget_product_id} /* WeatherWidgetExtension.appex */ = {{isa = PBXFileReference; explicitFileType = "wrapper.app-extension"; includeInIndex = 0; path = WeatherWidgetExtension.appex; sourceTree = BUILT_PRODUCTS_DIR; }};
""".format(
        widget_swift_id=widget_swift_id,
        widget_info_plist_id=widget_info_plist_id,
        widget_entitlements_id=widget_entitlements_id,
        widget_assets_id=widget_assets_id,
        widget_intent_id=widget_intent_id,
        widget_product_id=widget_product_id
    )
    
    content = content.replace(
        "/* End PBXFileReference section */",
        file_references + "/* End PBXFileReference section */"
    )
    
    # 添加 Widget Group
    widget_group = """
		{widget_group_id} /* WeatherWidget */ = {{
			isa = PBXGroup;
			children = (
				{widget_swift_id} /* WeatherWidget.swift */,
				{widget_intent_id} /* WeatherWidget.intentdefinition */,
				{widget_assets_id} /* Assets.xcassets */,
				{widget_info_plist_id} /* Info.plist */,
				{widget_entitlements_id} /* WeatherWidget.entitlements */,
			);
			path = WeatherWidget;
			sourceTree = "<group>";
		}};
""".format(
        widget_group_id=widget_group_id,
        widget_swift_id=widget_swift_id,
        widget_intent_id=widget_intent_id,
        widget_assets_id=widget_assets_id,
        widget_info_plist_id=widget_info_plist_id,
        widget_entitlements_id=widget_entitlements_id
    )
    
    # 在主 group 中添加 Widget group
    main_group_pattern = r'(75002DA62E0741CD00E5E081 = \{[^}]+children = \([^)]+)'
    main_group_match = re.search(main_group_pattern, content, re.DOTALL)
    if main_group_match:
        new_children = main_group_match.group(1) + f"\n\t\t\t\t{widget_group_id} /* WeatherWidget */,"
        content = content.replace(main_group_match.group(1), new_children)
    
    # 在 PBXGroup section 末尾添加 widget group
    content = content.replace(
        "/* End PBXGroup section */",
        widget_group + "/* End PBXGroup section */"
    )
    
    # 添加到 Products group
    products_pattern = r'(75002DB02E0741CD00E5E081 /\* Products \*/ = \{[^}]+children = \([^)]+)'
    products_match = re.search(products_pattern, content, re.DOTALL)
    if products_match:
        new_products = products_match.group(1) + f"\n\t\t\t\t{widget_product_id} /* WeatherWidgetExtension.appex */,"
        content = content.replace(products_match.group(1), new_products)
    
    # 添加 Widget Target
    widget_target = """
		{widget_target_id} /* WeatherWidgetExtension */ = {{
			isa = PBXNativeTarget;
			buildConfigurationList = {widget_config_list_id} /* Build configuration list for PBXNativeTarget "WeatherWidgetExtension" */;
			buildPhases = (
				{widget_sources_phase_id} /* Sources */,
				{widget_frameworks_phase_id} /* Frameworks */,
				{widget_resources_phase_id} /* Resources */,
			);
			buildRules = (
			);
			dependencies = (
			);
			name = WeatherWidgetExtension;
			productName = WeatherWidgetExtension;
			productReference = {widget_product_id} /* WeatherWidgetExtension.appex */;
			productType = "com.apple.product-type.app-extension";
		}};
""".format(
        widget_target_id=widget_target_id,
        widget_config_list_id=widget_config_list_id,
        widget_sources_phase_id=widget_sources_phase_id,
        widget_frameworks_phase_id=widget_frameworks_phase_id,
        widget_resources_phase_id=widget_resources_phase_id,
        widget_product_id=widget_product_id
    )
    
    # 在 PBXNativeTarget section 末尾添加
    content = content.replace(
        "/* End PBXNativeTarget section */",
        widget_target + "/* End PBXNativeTarget section */"
    )
    
    # 添加 Build Phases
    build_phases = """
/* Begin PBXSourcesBuildPhase section */
		{widget_sources_phase_id} /* Sources */ = {{
			isa = PBXSourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
				{widget_swift_build_id} /* WeatherWidget.swift in Sources */,
				{widget_intent_build_id} /* WeatherWidget.intentdefinition in Sources */,
			);
			runOnlyForDeploymentPostprocessing = 0;
		}};
/* End PBXSourcesBuildPhase section */

/* Begin PBXResourcesBuildPhase section */
		{widget_resources_phase_id} /* Resources */ = {{
			isa = PBXResourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
				{widget_assets_build_id} /* Assets.xcassets in Resources */,
			);
			runOnlyForDeploymentPostprocessing = 0;
		}};
/* End PBXResourcesBuildPhase section */

/* Begin PBXFrameworksBuildPhase section */
		{widget_frameworks_phase_id} /* Frameworks */ = {{
			isa = PBXFrameworksBuildPhase;
			buildActionMask = 2147483647;
			files = (
			);
			runOnlyForDeploymentPostprocessing = 0;
		}};
/* End PBXFrameworksBuildPhase section */
""".format(
        widget_sources_phase_id=widget_sources_phase_id,
        widget_swift_build_id=widget_swift_build_id,
        widget_intent_build_id=widget_intent_build_id,
        widget_resources_phase_id=widget_resources_phase_id,
        widget_assets_build_id=widget_assets_build_id,
        widget_frameworks_phase_id=widget_frameworks_phase_id
    )
    
    # 查找合适的位置插入 build phases
    if "/* Begin PBXSourcesBuildPhase section */" in content:
        content = content.replace(
            "/* Begin PBXSourcesBuildPhase section */",
            build_phases + "\n/* Begin PBXSourcesBuildPhase section */"
        )
    else:
        # 如果没有找到，在 PBXFrameworksBuildPhase 后添加
        content = content.replace(
            "/* End PBXFrameworksBuildPhase section */",
            "/* End PBXFrameworksBuildPhase section */\n" + build_phases
        )
    
    # 添加 Build Configuration
    build_configs = """
		{widget_debug_config_id} /* Debug */ = {{
			isa = XCBuildConfiguration;
			buildSettings = {{
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				ASSETCATALOG_COMPILER_WIDGET_BACKGROUND_COLOR_NAME = AccentColor;
				CODE_SIGN_ENTITLEMENTS = WeatherWidget/WeatherWidget.entitlements;
				CODE_SIGN_STYLE = Automatic;
				CURRENT_PROJECT_VERSION = 1;
				GENERATE_INFOPLIST_FILE = YES;
				INFOPLIST_FILE = WeatherWidget/Info.plist;
				INFOPLIST_KEY_CFBundleDisplayName = WeatherWidget;
				INFOPLIST_KEY_NSHumanReadableCopyright = "";
				IPHONEOS_DEPLOYMENT_TARGET = 14.0;
				LD_RUNPATH_SEARCH_PATHS = (
					"$(inherited)",
					"@executable_path/Frameworks",
					"@executable_path/../../Frameworks",
				);
				MARKETING_VERSION = 1.0;
				PRODUCT_BUNDLE_IDENTIFIER = com.weiweathers.weather.widget;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SKIP_INSTALL = YES;
				SWIFT_EMIT_LOC_STRINGS = YES;
				SWIFT_VERSION = 5.0;
				TARGETED_DEVICE_FAMILY = "1,2";
			}};
			name = Debug;
		}};
		{widget_release_config_id} /* Release */ = {{
			isa = XCBuildConfiguration;
			buildSettings = {{
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				ASSETCATALOG_COMPILER_WIDGET_BACKGROUND_COLOR_NAME = AccentColor;
				CODE_SIGN_ENTITLEMENTS = WeatherWidget/WeatherWidget.entitlements;
				CODE_SIGN_STYLE = Automatic;
				CURRENT_PROJECT_VERSION = 1;
				GENERATE_INFOPLIST_FILE = YES;
				INFOPLIST_FILE = WeatherWidget/Info.plist;
				INFOPLIST_KEY_CFBundleDisplayName = WeatherWidget;
				INFOPLIST_KEY_NSHumanReadableCopyright = "";
				IPHONEOS_DEPLOYMENT_TARGET = 14.0;
				LD_RUNPATH_SEARCH_PATHS = (
					"$(inherited)",
					"@executable_path/Frameworks",
					"@executable_path/../../Frameworks",
				);
				MARKETING_VERSION = 1.0;
				PRODUCT_BUNDLE_IDENTIFIER = com.weiweathers.weather.widget;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SKIP_INSTALL = YES;
				SWIFT_EMIT_LOC_STRINGS = YES;
				SWIFT_VERSION = 5.0;
				TARGETED_DEVICE_FAMILY = "1,2";
			}};
			name = Release;
		}};
""".format(
        widget_debug_config_id=widget_debug_config_id,
        widget_release_config_id=widget_release_config_id
    )
    
    # 在 XCBuildConfiguration section 末尾添加
    content = content.replace(
        "/* End XCBuildConfiguration section */",
        build_configs + "/* End XCBuildConfiguration section */"
    )
    
    # 添加 Configuration List
    config_list = """
		{widget_config_list_id} /* Build configuration list for PBXNativeTarget "WeatherWidgetExtension" */ = {{
			isa = XCConfigurationList;
			buildConfigurations = (
				{widget_debug_config_id} /* Debug */,
				{widget_release_config_id} /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		}};
""".format(
        widget_config_list_id=widget_config_list_id,
        widget_debug_config_id=widget_debug_config_id,
        widget_release_config_id=widget_release_config_id
    )
    
    # 在 XCConfigurationList section 末尾添加
    content = content.replace(
        "/* End XCConfigurationList section */",
        config_list + "/* End XCConfigurationList section */"
    )
    
    # 添加 Widget target 到项目的 targets 列表
    project_targets_pattern = r'(targets = \([^)]+)'
    project_targets_match = re.search(project_targets_pattern, content)
    if project_targets_match:
        new_targets = project_targets_match.group(1) + f"\n\t\t\t\t{widget_target_id} /* WeatherWidgetExtension */,"
        content = content.replace(project_targets_match.group(1), new_targets)
    
    # 添加 Embed App Extensions build phase 到主 target
    main_target_pattern = r'(75002DAE2E0741CD00E5E081 /\* WeathersPro \*/ = \{[^}]+buildPhases = \([^)]+)'
    main_target_match = re.search(main_target_pattern, content, re.DOTALL)
    if main_target_match:
        new_phases = main_target_match.group(1) + f"\n\t\t\t\t{widget_embed_phase_id} /* Embed App Extensions */,"
        content = content.replace(main_target_match.group(1), new_phases)
    
    # 添加 Copy Files Phase (Embed App Extensions)
    copy_files_phase = """
		{widget_embed_phase_id} /* Embed App Extensions */ = {{
			isa = PBXCopyFilesBuildPhase;
			buildActionMask = 2147483647;
			dstPath = "";
			dstSubfolderSpec = 13;
			files = (
				{widget_build_file_id} /* WeatherWidgetExtension.appex in Embed App Extensions */,
			);
			name = "Embed App Extensions";
			runOnlyForDeploymentPostprocessing = 0;
		}};
""".format(
        widget_embed_phase_id=widget_embed_phase_id,
        widget_build_file_id=widget_build_file_id
    )
    
    # 在 PBXCopyFilesBuildPhase section 添加
    if "/* Begin PBXCopyFilesBuildPhase section */" in content:
        content = content.replace(
            "/* End PBXCopyFilesBuildPhase section */",
            copy_files_phase + "/* End PBXCopyFilesBuildPhase section */"
        )
    else:
        # 如果没有 PBXCopyFilesBuildPhase section，创建一个
        content = content.replace(
            "/* End PBXBuildPhase section */",
            "/* End PBXBuildPhase section */\n\n/* Begin PBXCopyFilesBuildPhase section */\n" + 
            copy_files_phase + 
            "/* End PBXCopyFilesBuildPhase section */"
        )
    
    # 写回文件
    write_project_file(content)
    print("✅ Widget Extension 已添加到项目")
    return True

def update_project_capabilities():
    """更新项目权限设置"""
    # 创建 xcworkspace 数据
    workspace_path = "/Users/weifu/Desktop/Weather/Weather.xcodeproj/project.xcworkspace/contents.xcworkspacedata"
    os.makedirs(os.path.dirname(workspace_path), exist_ok=True)
    
    workspace_content = """<?xml version="1.0" encoding="UTF-8"?>
<Workspace
   version = "1.0">
   <FileRef
      location = "self:">
   </FileRef>
</Workspace>
"""
    
    with open(workspace_path, 'w') as f:
        f.write(workspace_content)
    
    print("✅ 更新了 workspace 设置")

def main():
    print("🚀 开始自动配置 Widget Extension...")
    
    # 备份项目文件
    project_path = "/Users/weifu/Desktop/Weather/Weather.xcodeproj/project.pbxproj"
    backup_path = project_path + ".backup"
    
    try:
        with open(project_path, 'r') as f:
            backup_content = f.read()
        with open(backup_path, 'w') as f:
            f.write(backup_content)
        print("✅ 已创建项目文件备份")
    except Exception as e:
        print(f"❌ 创建备份失败: {e}")
        return
    
    # 添加 Widget 到项目
    if add_widget_files_to_project():
        update_project_capabilities()
        
        print("\n✅ Widget Extension 配置完成！")
        print("\n📝 接下来的步骤：")
        print("1. 在 Xcode 中打开项目")
        print("2. 选择主应用 target → Signing & Capabilities")
        print("3. 添加 App Groups capability")
        print("4. 创建 group.com.weiweathers.weather")
        print("5. 对 WeatherWidgetExtension target 重复相同操作")
        print("6. 选择您的开发团队进行代码签名")
        print("7. 编译并运行")
        print("\n💡 如果遇到问题，可以使用备份文件恢复：")
        print(f"   cp {backup_path} {project_path}")
    else:
        print("❌ 配置失败，请检查错误信息")

if __name__ == "__main__":
    main()