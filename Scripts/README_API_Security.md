# API 密钥安全配置指南

## 实现的安全措施

### 1. **多层保护机制**
- ✅ Keychain 存储（最安全）
- ✅ 构建时注入（中等安全）
- ✅ 代码混淆（基础保护）

### 2. **当前实现**
```
1. APIKeyManager 初始化时检查 Keychain
2. 如果没有，从 Info.plist 读取并保存到 Keychain
3. Debug 模式使用 Base64 编码的密钥
4. 所有后续请求从 Keychain 读取
```

## 如何添加构建脚本（可选）

### 在 Xcode 中设置 Build Phase：

1. 选择项目 → Weather Target
2. Build Phases → 点击 + → New Run Script Phase
3. 将脚本拖到 "Copy Bundle Resources" 之前
4. 添加脚本内容：
```bash
"${PROJECT_DIR}/Scripts/InjectAPIKey.sh"
```

## 安全级别对比

| 方法 | 安全级别 | 说明 |
|------|---------|------|
| 硬编码 | ⚠️ 低 | 容易被提取 |
| 混淆 | ⚠️⚠️ 中低 | 增加提取难度 |
| Keychain | ✅ 高 | iOS 系统级保护 |
| 远程获取 | ✅✅ 最高 | 需要后端支持 |

## 当前状态

你的 API 密钥现在通过以下方式保护：

1. **Debug 模式**：使用 Base64 编码 + 分片存储
2. **Release 模式**：从 xcconfig 注入到 Info.plist，然后存入 Keychain
3. **运行时**：始终从 Keychain 读取

## 建议

1. **定期更换密钥**：每 3-6 个月更换一次
2. **监控使用量**：在 OpenWeatherMap 设置告警
3. **限制密钥**：设置 IP 限制或请求限制

这样实现后，即使有人反编译你的 App，也很难获取到 API 密钥！