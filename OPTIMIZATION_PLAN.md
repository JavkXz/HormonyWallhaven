# HarmonyOS Wallpaper App 优化与演进路线图

## 🚀 已完成阶段 (Milestone: Core, Polish & Magic)
- [x] **搜索与联动**：实现关键词搜索及详情页标签点击回溯搜索。
- [x] **视觉动效**：图片渐入加载（Fade-in）、现代化 LoadingProgress、超厚毛玻璃。
- [x] **极致交互**：详情页“极简模式”与“设置弹窗”状态避让逻辑、全屏预览。
- [x] **安全下载**：集成 `SaveButton` 安全保存图片至系统相册。
- [x] **核心壁纸功能**：调用系统 `wallpaper` 模块，支持桌面/锁屏设置（浅色高对比度方案）。
- [x] **共享元素转场 (Shared Element)**：使用 `geometryTransition` 实现图片无缝生长的“魔术”动效。
- [x] **UI/UX 焕新**：全面采用浅色现代简约风，统一按钮布局与像素级对齐。

## 🎯 当前优先级 (High Priority)
### 1. 本地化持久化 (Local Persistence)
- [ ] **搜索历史**：使用 `Preferences` 存储用户的搜索足迹，支持一键清空与再次搜索。
- [ ] **我的收藏**：使用 `RelationalStore (RDB)` 构建本地数据库，支持离线查看已收藏的壁纸。

### 2. 极致用户体验 (UX Refinement)
- [ ] **空状态 UI (Empty States)**：设计并实现“断网”、“搜索无结果”等场景下的精美插画与引导页面。
- [ ] **触感反馈 (Haptic)**：在设置成功、收藏操作时加入系统级线性马达反馈（Vibration）。

## 🛠️ 技术深度优化 (Advanced Engineering)
### 3. 网络与性能
- [ ] **预加载策略**：在 WaterFlow 滑动时，预测性预取下一页数据以消除等待感。
- [ ] **智能配色提取**：从壁纸中提取主色调，动态调整应用内的强调色（Accent Color）。

## 🌈 未来愿景 (Future Vision)
- [ ] **分布式同步**：利用 HarmonyOS 跨端能力，在平板、折叠屏与手机间同步收藏。

---
*Last Updated: 2026-02-04*