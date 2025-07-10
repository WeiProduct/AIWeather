// 运行这个脚本来重置 Photography Times 设置
import Foundation

// 清除 Photography Times 的设置
UserDefaults.standard.removeObject(forKey: "show_photography_times")
UserDefaults.standard.synchronize()

print("✅ Photography Times 设置已重置为默认值（隐藏）")
print("请重新运行应用以查看效果")
EOF < /dev/null