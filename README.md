# HarmonyOS 壁纸应用

基于 HarmonyOS 的壁纸浏览与收藏应用，使用 ArkTS/ETS 语言开发，集成 [wallhaven.cc](https://wallhaven.cc) API。

## 功能特性

- 🖼️ **瀑布流浏览** — WaterFlow 自适应高度布局，沉浸式画廊体验
- 🔍 **搜索与筛选** — 按类别、纯净度、分辨率等多维度筛选壁纸
- ❤️ **本地收藏** — 基于关系型数据库 (RDB) 的收藏持久化
- 📱 **壁纸详情** — 全屏预览，沉浸式模糊背景，一键设置壁纸
- ⚙️ **设置管理** — API Key 配置，个性化偏好

## 核心架构 (MVVM)

项目采用标准的 MVVM 模式，利用 HarmonyOS Next 的 `@ObservedV2` 和 `@Trace` 实现响应式数据流：
- **View**: ArkUI 声明式组件，通过 ViewModel 驱动 UI 更新。
- **ViewModel**: 处理 UI 逻辑与数据转换，解耦 View 与 Service。
- **Model/Service**: 封装 API 请求 (`WallhavenService`) 与本地持久化 (`FavoriteRepository`)。

## 未来规划 (Roadmap)

- [ ] **网络层演进**：迁移至 `Remote Communication Kit (RCP)`，提升并发性能与请求拦截能力。
- [ ] **性能优化**：引入图片二级缓存（Disk Cache）及 `TaskPool` 并发解析 JSON，确保瀑布流 0 掉帧。
- [ ] **功能增强**：实现一键设置壁纸功能，支持锁屏与桌面同步设置。
- [ ] **多端适配**：针对折叠屏、平板及 PC 端优化分栏布局与多列响应式显示。
- [ ] **原子化服务**：提取核心功能，支持 HarmonyOS 元服务卡片预览。

## 技术栈

| 项目 | 详情 |
|------|------|
| 目标 SDK | HarmonyOS 6.0.2 (API Level 22) |
| 开发语言 | ArkTS/ETS |
| UI 框架 | ArkUI (声明式 UI) |
| 架构模式 | MVVM |
| 状态管理 | `@ObservedV2` + `@Trace` |
| 数据持久化 | Preferences + RDB |
| 网络 | @kit.NetworkKit (HTTP) |

## 项目结构

```
FirstApplication/
├── AppScope/                        # 应用全局配置
│   └── app.json5
├── entry/                           # 主应用模块
│   └── src/main/
│       ├── ets/
│       │   ├── common/              # 公共基础类
│       │   │   ├── BasicDataSource.ets    # LazyForEach 数据源基类
│       │   │   ├── Constants.ets          # 全局常量
│       │   │   └── GlobalState.ets        # 全局状态管理 (@ObservedV2)
│       │   ├── components/          # 可复用 UI 组件
│       │   │   ├── ModernComponents.ets   # 现代风格卡片/筛选组件
│       │   │   ├── EmptyStateComponent.ets # 空状态占位组件
│       │   │   └── SearchHistoryComponent.ets # 搜索历史组件
│       │   ├── model/               # 数据模型
│       │   │   ├── WallpaperModel.ets     # 壁纸数据接口
│       │   │   └── WallpaperDataSource.ets # LazyForEach 数据适配器
│       │   ├── pages/               # UI 页面
│       │   │   ├── Index.ets              # 主页 (壁纸瀑布流)
│       │   │   ├── HomePage.ets           # 首页 Tab
│       │   │   ├── WallpaperDetail.ets    # 壁纸详情 (沉浸式)
│       │   │   ├── FavoritesPage.ets      # 收藏页
│       │   │   └── SettingsPage.ets       # 设置页
│       │   ├── service/             # 业务服务
│       │   │   └── WallhavenService.ets   # Wallhaven API 封装
│       │   ├── utils/               # 工具类
│       │   │   ├── HttpUtil.ets           # HTTP 请求封装
│       │   │   ├── AppConfig.ets          # 单例配置 & 服务工厂
│       │   │   ├── FavoriteRepository.ets # 收藏数据仓库 (RDB)
│       │   │   ├── PreferencesUtil.ets    # Preferences 封装
│       │   │   └── HapticFeedback.ets     # 触感反馈工具
│       │   ├── viewmodel/           # 视图模型
│       │   │   └── MainViewModel.ets      # 主页 ViewModel
│       │   ├── entryability/        # UIAbility 生命周期
│       │   │   └── EntryAbility.ets
│       │   └── entrybackupability/  # BackupExtensionAbility
│       │       └── EntryBackupAbility.ets
│       └── resources/               # 应用资源
├── build-profile.json5              # 全局构建配置
└── oh-package.json5                 # 项目依赖
```

## 开发环境

- DevEco Studio 4.x
- HarmonyOS SDK API 6.0.2 (22)
- Node.js 环境

## 构建与运行

```bash
# 调试构建
hvigor buildDebug

# 发布构建
hvigor buildRelease

# 部署到设备
hvigor deploy
```

## API 配置

应用使用 wallhaven.cc API，基础功能无需 API Key。

| 接口 | 地址 |
|------|------|
| 搜索壁纸 | `https://wallhaven.cc/api/v1/search` |
| 壁纸详情 | `https://wallhaven.cc/api/v1/w/{id}` |

- 每分钟最多 45 次 API 调用
- NSFW 内容需要 API Key（在设置页配置）
