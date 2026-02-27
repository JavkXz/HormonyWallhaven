# PROJECT KNOWLEDGE BASE

## 【最高优先级指令】
**所有思考、回答和生成的文件统一使用中文。禁止在代码注释、文档或对话中使用英文总结（除非是术语）。**

---

**Updated:** 2026-02-27

## OVERVIEW
HarmonyOS 壁纸应用，采用 MVVM 架构，集成 wallhaven.cc API，使用 ArkTS 声明式 UI（WaterFlow 瀑布流）。支持壁纸浏览、搜索筛选、收藏持久化和沉浸式详情预览。

## STRUCTURE
```
entry/src/main/ets/
├── common/                  # 公共基础
│   ├── BasicDataSource.ets       # LazyForEach 数据源基类
│   ├── Constants.ets             # 全局常量
│   └── GlobalState.ets           # 全局状态管理 (@ObservedV2)
├── components/              # 可复用 UI 组件
│   ├── ModernComponents.ets      # 卡片、筛选 Chip 等现代组件
│   ├── EmptyStateComponent.ets   # 空状态占位组件
│   └── SearchHistoryComponent.ets # 搜索历史
├── model/                   # 数据模型
│   ├── WallpaperModel.ets        # WallpaperItem, SearchParams 接口
│   └── WallpaperDataSource.ets   # LazyForEach 数据适配器
├── pages/                   # UI 页面
│   ├── Index.ets                 # 主页 (WaterFlow 瀑布流)
│   ├── HomePage.ets              # 首页 Tab
│   ├── WallpaperDetail.ets       # 详情页 (沉浸式)
│   ├── FavoritesPage.ets         # 收藏页
│   └── SettingsPage.ets          # 设置页
├── service/                 # 业务服务
│   └── WallhavenService.ets      # Wallhaven API 封装
├── utils/                   # 工具类
│   ├── HttpUtil.ets              # @kit.NetworkKit GET/POST 封装
│   ├── AppConfig.ets             # 单例配置 & 服务工厂
│   ├── FavoriteRepository.ets    # 收藏仓库 (RDB 持久化)
│   ├── PreferencesUtil.ets       # Preferences 封装
│   └── HapticFeedback.ets        # 触感反馈
├── viewmodel/               # 视图模型
│   └── MainViewModel.ets         # 主页 ViewModel
├── entryability/            # UIAbility 生命周期
│   └── EntryAbility.ets
└── entrybackupability/      # BackupExtensionAbility
    └── EntryBackupAbility.ets
```

## WHERE TO LOOK
| 任务 | 位置 | 备注 |
|------|------|------|
| 应用入口 | `entryability/EntryAbility.ets` | 加载 `pages/Index` |
| 主界面/瀑布流 | `pages/Index.ets` | WaterFlow 布局，Tab 导航 |
| 壁纸详情 | `pages/WallpaperDetail.ets` | 沉浸式全屏预览 |
| 收藏管理 | `pages/FavoritesPage.ets` + `utils/FavoriteRepository.ets` | RDB 持久化 |
| 设置 | `pages/SettingsPage.ets` + `utils/PreferencesUtil.ets` | API Key，偏好 |
| API 服务 | `service/WallhavenService.ets` | Wallhaven API 封装 |
| HTTP 客户端 | `utils/HttpUtil.ets` | @kit.NetworkKit 封装 |
| 全局状态 | `common/GlobalState.ets` | @ObservedV2 + @Trace |
| 数据模型 | `model/WallpaperModel.ets` | WallpaperItem, SearchParams |
| ViewModel | `viewmodel/MainViewModel.ets` | 首页业务逻辑 |
| 复用组件 | `components/ModernComponents.ets` | 卡片、筛选 Chip |
| 构建配置 | `build-profile.json5` | HarmonyOS SDK 6.0.2 (API 22) |

## CODE MAP

| 符号 | 类型 | 位置 | 角色 |
|------|------|------|------|
| EntryAbility | class | entryability/ | 主 UIAbility，加载 Index |
| Index | struct | pages/ | 主页，WaterFlow + Tab 导航 |
| HomePage | struct | pages/ | 首页 Tab |
| WallpaperDetail | struct | pages/ | 沉浸式壁纸详情 |
| FavoritesPage | struct | pages/ | 收藏页，LazyForEach 列表 |
| SettingsPage | struct | pages/ | 设置页 |
| GlobalState | class | common/ | @ObservedV2 全局状态中心 |
| BasicDataSource | class | common/ | IDataSource 基类 (LazyForEach) |
| Constants | - | common/ | 全局常量定义 |
| ModernComponents | - | components/ | @Builder 卡片/筛选组件集 |
| EmptyStateComponent | struct | components/ | 空状态 UI |
| SearchHistoryComponent | struct | components/ | 搜索历史 |
| WallpaperModel | interface | model/ | WallpaperItem, SearchParams |
| WallpaperDataSource | class | model/ | LazyForEach 数据适配 |
| WallhavenService | class | service/ | API 搜索/详情，数据转换 |
| HttpUtil | class | utils/ | GET/POST 封装 |
| AppConfig | class | utils/ | 单例，服务工厂 |
| FavoriteRepository | class | utils/ | RDB 收藏 CRUD |
| PreferencesUtil | class | utils/ | Preferences 读写 |
| HapticFeedback | class | utils/ | 触感反馈封装 |
| MainViewModel | class | viewmodel/ | 首页 MVVM 视图模型 |

## DATA FLOW
```
UI (Index.ets / MainViewModel)
  → AppConfig.getInstance().getWallhavenService()
  → WallhavenService.searchWallpapers(params)
  → HttpUtil.doGet(url)
  → JSON → WallpaperItem[]
  → WallpaperDataSource (LazyForEach)
  → WaterFlow 渲染

收藏操作:
  UI → FavoriteRepository.add/remove(wallpaperId)
  → RDB 持久化
  → GlobalState 同步更新
```

## CONVENTIONS

**架构模式：**
- MVVM：ViewModel 处理业务逻辑，View 纯展示
- 全局状态：`@ObservedV2` + `@Trace` 驱动响应式更新
- 单例工厂：`AppConfig.getInstance().getXxxService()`

**命名规范：**
- 私有只读字段：PascalCase (`private readonly CardMargin`)
- 模块常量：UPPER_SNAKE_CASE (`DOMAIN = 0x0000`)
- 文件扩展名：统一 `.ets`

**错误处理：**
- 服务层：失败返回 `[]` 或 `null`，不抛出异常
- UI 层：try/catch + 回退数据或静默日志

**日志：**
- 生命周期：`hilog.info(DOMAIN, 'testTag', '%{public}s', msg)`
- 调试：`console.info/error()`

**设计规范：**
- 参见 `docs/design/DESIGN_GUIDE.md`

## COMMANDS
```bash
hvigor buildDebug    # Debug 构建
hvigor buildRelease  # Release 构建
hvigor deploy        # 部署
```

## NOTES
- 目标 SDK：HarmonyOS 6.0.2 (API Level 22)
- 使用 wallhaven.cc API（基础使用无需 API Key）
- **性能红线**：UI 线程禁止执行 I/O 或复杂计算，必须使用 `TaskPool`。
- **编码规范**：参考项目内置的 ArkTS 编码风格指南。
- 未来规划：RCP 网络层迁移、折叠屏/平板适配、二级缓存方案。
