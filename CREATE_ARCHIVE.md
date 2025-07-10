# 创建 Archive 并上传到 App Store Connect

## 在 Xcode 中操作（推荐）

1. **打开 Xcode**
   ```bash
   open Weather.xcodeproj
   ```

2. **选择设备**
   - 在顶部工具栏，选择 "Any iOS Device (arm64)"

3. **创建 Archive**
   - 菜单栏：Product > Archive
   - 等待构建完成（约2-3分钟）

4. **在 Organizer 中上传**
   - Archive 完成后会自动打开 Organizer
   - 选择刚创建的 Archive
   - 点击 "Distribute App"
   - 选择 "App Store Connect"
   - 选择 "Upload"
   - 按照提示完成上传

## 命令行方式（备选）

如果你想用命令行：

```bash
# 1. 清理
xcodebuild clean -project Weather.xcodeproj -scheme Weather

# 2. 创建 Archive
xcodebuild -project Weather.xcodeproj \
  -scheme Weather \
  -configuration Release \
  -archivePath ./build/Weather.xcarchive \
  archive

# 3. 导出 IPA
xcodebuild -exportArchive \
  -archivePath ./build/Weather.xcarchive \
  -exportPath ./build \
  -exportOptionsPlist ExportOptions.plist
```

## 检查清单

✅ Vercel 代理已部署并工作正常
✅ ApiConfig.swift 已更新为你的 URL
✅ 版本号设置为 1.0
✅ 应用名称设置为 "简洁天气"
✅ Release 版本构建成功

## 下一步

1. 在 App Store Connect 创建应用
2. 上传截图（使用模拟器截图）
3. 填写应用描述（使用 AppStore/app_store_listing.md）
4. 提交审核

---

**现在就打开 Xcode 创建 Archive 吧！**