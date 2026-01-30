# PAGES KNOWLEDGE BASE

## 【最高优先级指令】
**所有思考、回答和生成的文件统一使用中文。**

---

**Parent:** `entry/src/main/ets/AGENTS.md`
**Generated:** 2026-01-30

## OVERVIEW
UI 组件，实现声明式 WaterFlow 布局用于壁纸画廊。

## STRUCTURE
```
pages/
├── Index.ets          # 主壁纸列表（254 行，WaterFlow + 搜索）
├── HomePage.ets       # 首页（82 行）
├── SettingsPage.ets    # 设置（81 行）

```

## WHERE TO LOOK
| 任务 | 位置 | 关键组件 |
|------|----------|---------------|
| 壁纸画廊 | Index.ets | `WaterFlow` 配合 `ForEach` |
| 卡片组件 | Index.ets | `@Builder WallpaperCardWithMargin` |
| 加载状态 | Index.ets | `if (this.isLoading)` 块 |
| 搜索触发 | Index.ets | `performSearch()` 方法 |
| API 集成 | Index.ets | `this.wallhavenService.searchWallpapers()` |

## CONVENTIONS

**布局：**
- WaterFlow：`.columnsTemplate('1fr 1fr')` 实现两列网格
- 间距：使用卡片 margin（`.margin({ left/right/top/bottom }`) 而非 Flow gap
- 高度：基于宽高比的 `calculatedHeight` 属性计算

**@Builder 模式：**
```
@Builder
ComponentName(param: Type) {
  // UI
  .width('100%')
  .onClick(() => { })
}
```

**服务访问：**
```
private wallhavenService: WallhavenService = AppConfig.getInstance().getWallhavenService();
```

**UI 错误处理：**
- `try/catch` 块在 `loadWallpaperListFromApi()` 中使用回退数据
- `performSearch()` 中静默错误日志（无用户反馈）

## ANTI-PATTERNS
- 静默搜索失败：仅 `console.error()`，无用户通知
- Index.ets 中硬编码回退数据，应使用独立配置
