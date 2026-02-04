# ArkTS 编程规范核心摘要 (Stage 模型)

## 1. 强制类型声明
- 严禁使用 `any`。
- 所有变量、函数参数、返回值必须显式标注类型。
- 优先使用 `interface` 定义数据模型。

## 2. 声明式 UI (ArkUI) 规范
- 使用 `@Entry`, `@Component`, `@State`, `@Prop`, `@Link`, `@Provide`, `@Consume` 进行状态管理。
- 布局优先使用 `Column`, `Row`, `Stack`, `Flex`。
- 长列表必须使用 `List` 或 `WaterFlow` 结合 `LazyForEach`。
- 列表项高度预计算：在 WaterFlow 中，为了防止瀑布流闪烁，应提前计算并存储图片高度。

## 3. 命名约定
- 类名/组件名：`PascalCase` (如 `WallpaperCard`)。
- 变量/函数：`camelCase` (如 `loadData`)。
- 常量：`UPPER_SNAKE_CASE` (如 `MAX_PAGE_SIZE`)。
- 私有成员：建议以 `_` 开头或使用 `private` 关键字。

## 4. 异步与并发
- UI 线程严禁执行耗时任务（如超过 100ms 的计算）。
- 使用 `TaskPool` 执行 CPU 密集型任务。
- 网络请求使用 `@kit.NetworkKit` (http) 模块，结合 `async/await`。

## 5. 资源管理
- 颜色、字符串、数值应定义在 `resources/base/element/` 下。
- 较大的图片资源建议放在 `rawfile` 或云端。

## 6. 性能优化 (KISS 原则)
- 减少组件嵌套层级。
- 避免在 `build()` 函数中进行复杂计算。
- 频繁变化的状态应尽可能下沉到子组件。
