# HarmonyOS Wallpaper App UI 重新设计方案

## 1. 设计愿景 (Design Vision)
构建一个**“沉浸、灵动、纯净”**的壁纸探索体验。设计风格定位为 **"Modern Minimalism with Fluidity" (流动的现代极简主义)**，强调图片本身的艺术性，减少 UI 元素的干扰，通过细腻的动效增强交互的生命感。

## 2. 设计原则 (Design Principles)
*   **Content First (内容至上)**：UI 元素应作为背景或半透明覆盖层，确保壁纸在大屏幕上占据统治地位。
*   **Organic Motion (有机动效)**：避免生硬的位移，使用弹性曲线（Spring Curve）和模糊渐变（Blur Transition）。
*   **Layered Depth (层级深度)**：利用 HarmonyOS 的 `backgroundBlurStyle` 创造多维空间感，模拟磨砂玻璃物理特性。
*   **Intuitive Gesture (直觉手势)**：通过滑动手势替代复杂的点击操作（如：下滑关闭详情，左右滑动切换壁纸）。

## 3. 色彩方案 (Color Palette)
采用**自适应色彩系统**，UI 色彩根据壁纸主色调动态调整（或保持中性平衡）。

| 角色 | 颜色值 (Light) | 颜色值 (Dark) | 用途 |
| :--- | :--- | :--- | :--- |
| **Primary** | `#007DFF` (Harmony Blue) | `#3F97FF` | 核心操作、高亮状态 |
| **Background** | `#F1F3F5` | `#000000` | 页面基底 |
| **Surface** | `rgba(255,255,255,0.85)` | `rgba(28,28,28,0.75)` | 卡片、面板 (带模糊) |
| **Accent** | `#FF6B6B` | `#FF5252` | 收藏、警示 |
| **Text Primary** | `#182431` | `#E5E8EA` | 标题、主要信息 |
| **Text Secondary** | `#999999` | `#7E848C` | 辅助说明、占位符 |

## 4. 组件库选型与规范 (Component Standards)
*   **瀑布流 (WaterFlow)**：采用不等高布局，模拟自然画廊感。
    *   `columnsGap`: 12vp
    *   `borderRadius`: 20vp (更圆润的视觉)
*   **搜索栏 (Search Bar)**：采用浮动式设计，滚动时收缩为胶囊。
*   **详情面板 (Detail Panel)**：半高抽屉式布局，支持分级展开。
*   **按钮 (Buttons)**：大面积使用 `ButtonType.Circle` 和 `ButtonType.Capsule`。

## 5. 核心页面重构策略 (Core Page Strategy)

### 5.1 首页 (Index/Home)
*   **沉浸式顶部**：搜索栏与状态栏融合，背景使用 `BlurStyle.COMPONENT_ULTRA_THICK`。
*   **微交互筛选**：筛选标签（Chips）在选中时伴随缩放动画和阴影变化。
*   **预加载动画**：骨架屏配合柔和的淡入效果。

### 5.2 详情页 (WallpaperDetail)
*   **全屏无界交互**：点击壁纸进入“禅意模式”，隐藏所有 UI 元素。
*   **色彩提取应用**：从壁纸中提取主色，应用到“设为壁纸”按钮的渐变背景。
*   **共享元素转场 (GeometryTransition)**：壁纸从列表卡片平滑拉伸至全屏，无缝衔接。

### 5.3 收藏页 (Favorites)
*   **情感化空白页**：使用精美的 Symbol 矢量动画展示“暂无收藏”。

## 6. 动效规范 (Motion Specification)
*   **页面转场**：`Slide` + `Opacity` 组合，持续时间 400ms，曲线 `Curve.FastOutSlowIn`。
*   **列表进入**：采用交错动画（Staggered Animation），卡片依次从底部浮现。
*   **点击反馈**：微小的缩放 `scale: {x: 0.95, y: 0.95}`，模拟物理按压感。

## 7. 响应式策略 (Responsive Strategy)
*   **折叠屏/平板适配**：
    *   使用 `GridCol` 自动调整列数（Phone: 2, Tablet: 4, PC: 6）。
    *   详情页在宽屏上采用左右分栏布局（左图右息）。
