# ETS MAIN KNOWLEDGE BASE

## 【最高优先级指令】
**所有思考、回答和生成的文件统一使用中文。**

---

**Parent:** `./AGENTS.md`
**Generated:** 2026-01-30

## OVERVIEW
架构层，包含所有 ArkTS 代码：生命周期、UI、业务逻辑、模型、工具类。

## STRUCTURE
```
ets/
├── entryability/           # UIAbility 生命周期（EntryAbility）
├── entrybackupability/     # BackupExtensionAbility（非标准命名）
├── pages/                 # UI 组件（WaterFlow 画廊）
├── service/               # 业务逻辑（WallhavenService）
├── model/                 # 数据接口（WallpaperItem, SearchParams）
└── utils/                 # 工具类（HttpUtil, AppConfig 单例）
```

## WHERE TO LOOK
| 层 | 位置 | 职责 |
|-------|----------|----------------|
| 生命周期 | entryability/EntryAbility.ets | 应用启动，页面路由（`pages/Index`）|
| 备份 | entrybackupability/EntryBackupAbility.ets | 数据备份/恢复 |
| UI | pages/*.ets | WaterFlow 布局，用户交互 |
| API | service/WallhavenService.ets | Wallhaven API 封装，数据转换 |
| 模型 | model/WallpaperModel.ets | 类型定义（WallpaperItem, SearchParams）|
| HTTP | utils/HttpUtil.ets | @kit.NetworkKit 的 GET/POST |
| 配置 | utils/AppConfig.ets | 单例，服务工厂 |

## DATA FLOW
```
UI (Index.ets)
  → 调用 AppConfig.getInstance().getWallhavenService()
  → 调用 wallhavenService.searchWallpapers(params)
  → 调用 HttpUtil.doGet(url)
  → 解析 JSON → 转换为 WallpaperItem[]
  → 返回到 UI → 在 WaterFlow 中渲染
```

## CONVENTIONS

**服务访问模式：**
```
// 单例工厂
AppConfig.getInstance().getWallhavenService()

// 直接实例使用
this.wallhavenService.searchWallpapers()
```

**错误处理：**
- 服务：失败时返回 `[]` 或 `null`（从不抛出）
- UI：显示回退数据或静默控制台日志
- 不重新抛出错误

**API 响应流：**
```
API (WallpaperResponse.data[])
  → isValidWallpaperData() 检查（id, path, 尺寸）
  → convertToWallpaperItem() 映射字段
  → 返回 WallpaperItem[]（API 字段子集）
```

## ANTI-PATTERNS
- `entrybackupability/` 命名：应为 `extensions/` 或合并到 `entryability/`
- 无集中错误处理：每个服务以不同方式处理错误
