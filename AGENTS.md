# PROJECT KNOWLEDGE BASE

## 【最高优先级指令】
**所有思考、回答和生成的文件统一使用中文。**

---

**Generated:** 2026-01-30
**Commit:** Unknown
**Branch:** Unknown

## OVERVIEW
HarmonyOS 壁纸应用，使用 wallhaven.cc API、ArkTS 和声明式 UI（WaterFlow）。

## STRUCTURE
```
./
├── entry/                    # 主模块
│   └── src/main/
│       ├── ets/
│       │   ├── entryability/       # UIAbility 生命周期
│       │   ├── entrybackupability/ # BackupExtensionAbility（非标准命名）
│       │   ├── pages/             # UI 页面
│       │   ├── service/           # 业务逻辑（WallhavenService）
│       │   ├── model/             # 数据接口
│       │   └── utils/            # 工具类（HttpUtil, AppConfig 单例）
│       └── resources/            # 应用资源（media, elements）
├── oh_modules/                   # 依赖（@ohos/hypium, @ohos/hamock）
└── AppScope/                    # 应用级配置
```

## WHERE TO LOOK
| 任务 | 位置 | 备注 |
|------|----------|-------|
| 应用入口 | `entry/src/main/ets/entryability/EntryAbility.ets` | 加载 `pages/Index` |
| 主界面 | `entry/src/main/ets/pages/Index.ets` | 壁纸列表，WaterFlow 布局 |
| API 服务 | `entry/src/main/ets/service/WallhavenService.ets` | Wallhaven API 封装 |
| HTTP 客户端 | `entry/src/main/ets/utils/HttpUtil.ets` | @kit.NetworkKit 封装 |
| 数据模型 | `entry/src/main/ets/model/WallpaperModel.ets` | WallpaperItem, SearchParams 接口 |
| 配置 | `entry/src/main/ets/utils/AppConfig.ets` | 单例模式，服务工厂 |
| 构建配置 | `build-profile.json5`, `entry/build-profile.json5` | HarmonyOS SDK 6.0.2 (API 22) |
| Lint 配置 | `code-linter.json5` | ESLint + TypeScript + 安全规则 |

## CODE MAP
(无 LSP - 手动分析)

| 符号 | 类型 | 位置 | 角色 |
|--------|------|----------|------|
| EntryAbility | class | entryability/EntryAbility.ets | 主 UIAbility，加载 Index 页面 |
| EntryBackupAbility | class | entrybackupability/EntryBackupAbility.ets | BackupExtensionAbility |
| Index | struct | pages/Index.ets | 主壁纸列表页（WaterFlow） |
| HomePage | struct | pages/HomePage.ets | 首页 |
| SettingsPage | struct | pages/SettingsPage.ets | 设置页 |
| WallhavenService | class | service/WallhavenService.ets | API 客户端，搜索/详情方法 |
| HttpUtil | class | utils/HttpUtil.ets | GET/POST 封装，详细日志 |
| AppConfig | class | utils/AppConfig.ets | 单例，服务工厂 |
| WallpaperItem | interface | model/WallpaperModel.ets | 核心数据结构 |

## CONVENTIONS (deviations from standard)

**命名：**
- 私有只读字段：PascalCase 带修饰符（`private readonly CARD_MARGIN: number = 6`）
- 模块常量：UPPER_SNAKE_CASE（`DOMAIN = 0x0000`）
- 文件扩展名：所有源文件使用 `.ets`

**架构：**
- AppConfig 使用单例模式
- 服务层分离 API 调用和 UI
- 模型使用 `| undefined` 表示可选字段
- Index 页面在 API 失败时使用回退数据
- 使用 @Builder 装饰器实现可复用 UI 组件

**非标准：**
- `entrybackupability/` 目录应改为 `extensions/` 或合并到 `entryability/`
- `resources/base/media/` 中的大型静态资源（25MB+）应使用 `rawfile/` 或运行时下载

**日志：**
- 生命周期事件：`hilog.info(DOMAIN, 'testTag', '%{public}s', message)`
- 通用调试：`console.info/error()`（允许中文注释）

## ANTI-PATTERNS (THIS PROJECT)
未发现明确的 TODO/FIXME/DEPRECATED 注释。
安全 lint 规则：禁止不安全的加密操作（AES, hash, MAC, DH, DSA, ECDSA, RSA, 3DES）。

## UNIQUE STYLES
- WaterFlow 基于宽高比计算高度
- HttpUtil 包含详细的 HTTP 请求日志
- 未使用 Object.assign - 手动合并选项
- 服务在错误时返回空数组/null 而非抛出异常
- API key 可选（无 key 也可工作）

## COMMANDS
```bash
# 构建
hvigor buildDebug    # Debug 构建
hvigor buildRelease  # Release 构建
hvigor deploy        # 部署

# Lint（构建时自动运行）
# 配置在 code-linter.json5
```

## NOTES
- 目标 SDK：HarmonyOS 6.0.2 (API Level 22)
- 使用 wallhaven.cc API（基础使用无需 API key）
- 测试使用 Hypium 框架（`@ohos/hypium`）
- Mock 数据位于 `entry/src/mock/` 目录
- Lint 忽略 test/mock/node_modules/build 目录
- HttpUtil 维护单个静态 HttpRequest 实例
- AppConfig.getApiKey() 返回 undefined（硬编码 API key 已禁用）
