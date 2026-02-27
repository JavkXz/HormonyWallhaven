# Immersive Fluidity 设计规范

**设计理念：悬浮艺术与流动光影 (Floating Art & Living Light)**

本应用是一个流动的数字画廊。界面像水中的悬浮物一样轻盈，背景随内容起舞。设计风格定位为 **"Modern Minimalism with Fluidity"（流动的现代极简主义）**，强调图片的艺术性，减少 UI 元素干扰。

---

## 1. 设计原则

### Content First（内容至上）
UI 元素作为背景或半透明覆盖层，确保壁纸占据视觉统治地位。

### Layered Depth（层级深度）
不使用分割线，仅通过阴影和模糊层级区分空间：
- **底层** (Z-0)：沉浸式模糊背景
- **中层** (Z-10)：内容卡片 (Shadow Radius: 24)
- **顶层** (Z-100)：交互功能岛 (Blur: Ultra Thick)

### Contextual Continuity（情境连续性）
用户不应感到"页面切换"，而应感到"视觉聚焦"：
- 首页背景实时获取首屏壁纸缩略图进行高斯模糊
- 所有列表→详情转场使用 `geometryTransition`

### Purposeful Motion（物理动效）
动效必须符合物理直觉，快起慢停：
- 统一时长：**350ms**
- 曲线：**Curve.FastOutSlowIn**
- 按钮按下：缩放 `scale: 0.97` + 触感反馈 (利用 `HapticFeedback.ets`)

---

## 2. 色彩方案

自适应色彩系统，支持亮/暗模式：

| 角色 | Light | Dark | 用途 |
|:---|:---|:---|:---|
| Primary | `#007DFF` | `#3F97FF` | 核心操作、高亮 |
| Background | `#F1F3F5` | `#000000` | 页面基底 |
| Surface | `rgba(255,255,255,0.85)` | `rgba(28,28,28,0.75)` | 卡片/面板 (带模糊) |
| Accent | `#FF6B6B` | `#FF5252` | 收藏、警示 |
| Text Primary | `#182431` | `#E5E8EA` | 标题 |
| Text Secondary | `#999999` | `#7E848C` | 辅助说明 |

**材质偏好：** 优先使用 `backgroundBlurStyle` 而非纯色填充。

---

## 3. 组件规范

| 组件 | 规范 |
|------|------|
| WaterFlow 瀑布流 | `columnsGap: 12vp`, `borderRadius: 20vp` |
| 搜索栏 | 浮动式，滚动时收缩为胶囊 |
| 详情面板 | 半高抽屉式，支持分级展开 |
| 按钮 | 大面积使用 `ButtonType.Circle` / `ButtonType.Capsule` |
| 圆角 | 统一 **24vp** |
| 标题字体 | `FontWeight.Bold` + 轻微阴影 |
| 正文字体 | `FontWeight.Medium`, `rgba(255,255,255,0.85)` |

---

## 4. 核心页面设计

### 首页 (Index)
- 沉浸式顶部：搜索栏与状态栏融合，`BlurStyle.COMPONENT_ULTRA_THICK`
- 筛选标签选中时伴随缩放动画和阴影变化
- 骨架屏 + 柔和淡入预加载效果

### 详情页 (WallpaperDetail)
- 全屏"禅意模式"：点击隐藏所有 UI，沉浸式预览。
- 主色提取：利用 `effectKit` 从壁纸中提取主色，应用到操作按钮背景。
- `geometryTransition` 共享元素转场：从列表缩略图到全屏大图的无缝切换。

### 收藏页 (Favorites)
- 情感化空白页：Symbol 矢量动画展示"暂无收藏"

---

## 5. 动效规范

| 场景 | 方式 | 时长 | 曲线 |
|------|------|------|------|
| 页面转场 | `Slide` + `Opacity` | 400ms | `Curve.FastOutSlowIn` |
| 列表进入 | 交错动画 (Staggered) | 350ms | `Curve.FastOutSlowIn` |
| 点击反馈 | `scale: {x: 0.95, y: 0.95}` | 150ms | Spring |

---

## 6. 响应式策略

- **自动列数**：Phone: 2列, Tablet: 4列, PC: 6列（`GridCol`）
- **宽屏详情**：左右分栏布局（左图右信息）
- **WaterFlow**：利用自适应能力自动调整
- **操作栏**：宽屏设备向中心聚合，避免跨屏幕操作
