# HarmonyOS Wallpaper App - Optimization Plan

**Generated:** 2026-02-02
**Author:** Gemini (Senior HarmonyOS Architect)

基于对 `Index.ets`, `WallhavenService.ets`, `HttpUtil.ets` 等核心文件的审查，制定以下优化计划。

## 1. 性能优化 (Performance) - [CRITICAL]

### 1.1 图片加载策略 (Image Loading)
- **现状**: `WallhavenService` 将 `imageUrl` 映射为 `apiItem.path` (原图)。
- **问题**: 在瀑布流列表中加载几十张 4K/2K 原图会导致严重的内存压力（OOM风险）和卡顿，且浪费用户流量。
- **方案**:
    - 修改 `WallpaperItem` 模型，区分 `thumbUrl` (列表用) 和 `fullUrl` (详情/下载用)。
    - 在 `WallhavenService` 中，优先使用 `apiItem.thumbs.small` 或 `apiItem.thumbs.original` 作为 `thumbUrl`。
    - 在 `Index.ets` 的 `WallpaperCard` 中仅加载 `thumbUrl`。

### 1.2 列表渲染 (List Rendering)
- **现状**: `WaterFlow` 使用 `ForEach`。
- **问题**: `ForEach` 会一次性初始化所有项的数据对象，当分页加载数据增多时，性能会线性下降。
- **方案**:
    - 引入 `LazyForEach`。
    - 实现 `IDataSource` 接口 (例如 `WallpaperDataSource`) 来管理数据懒加载。
    - 给 `FlowItem` 设置固定的 `key` 生成策略。

## 2. 架构重构 (Architecture)

### 2.1 引入 MVVM 模式
- **现状**: `Index.ets` 包含约 400 行代码，混合了 UI 布局、状态管理 (Page/Category/Sort)、API 调用和错误处理。
- **方案**:
    - 提取 `MainViewModel`。
    - 将 `loadWallpapers`, `loadMore`, `searchParams` 构建逻辑移至 VM。
    - UI 组件仅通过 `@ObjectLink` 或 `@State` 观察 VM 的数据变化。

### 2.2 常量与配置管理
- **现状**: `Index.ets` 中硬编码了大量的筛选选项 (SFW, Sketchy, 排序方式)。
- **方案**:
    - 创建 `entry/src/main/ets/common/Constants.ets`。
    - 统一管理枚举值和 UI 显示文本（便于未来国际化）。

## 3. 健壮性与错误处理 (Robustness)

### 3.1 网络层增强
- **现状**: `HttpUtil` 缺乏统一的拦截器，JSON 解析错误可能导致 crash (虽然有 try-catch，但处理分散)。
- **方案**:
    - 封装统一的 `ApiResponse<T>` 泛型处理。
    - 在 `HttpUtil` 中处理 HTTP 状态码（如 429 Too Many Requests，Wallhaven 常见限制）。

### 3.2 优雅的降级策略
- **现状**: 失败时加载本地写死的 `getFallbackWallpapers`。
- **方案**:
    - 区分“无网络”和“API错误”。
    - 提供“重试”按钮而非直接显示假数据（假数据会误导用户）。

## 4. 实施路线图 (Roadmap)

1.  **Phase 1 (Quick Wins)**:
    - [ ] 修复图片源，列表页使用缩略图 (Critical)。
    - [ ] 提取常量，清理 `Index.ets` 头部代码。

2.  **Phase 2 (Refactoring)**:
    - [ ] 实现 `MainViewModel`。
    - [ ] 改造 `WaterFlow` 为 `LazyForEach`。

3.  **Phase 3 (Polish)**:
    - [ ] 优化 Loading 骨架屏。
    - [ ] 增加图片点击进入大图预览页面的逻辑。

---
*建议立即执行 Phase 1，特别是图片缩略图的修复，这对应用体验至关重要。*
