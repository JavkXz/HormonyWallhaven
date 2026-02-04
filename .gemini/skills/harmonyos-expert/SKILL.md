---
name: harmonyos-expert
description: 专业的 HarmonyOS (Next) 应用开发专家，专注于 ArkTS 和 ArkUI 标准化开发。适用于：(1) 构建 ArkUI 声明式界面, (2) 编写 ArkTS 业务逻辑, (3) 优化 HarmonyOS 应用性能, (4) 从 Java/JS 迁移到 ArkTS。
---

# HarmonyOS Expert Skill

## 概述
本 Skill 旨在指导 Agent 遵循 HarmonyOS Next (API 12+) 官方规范进行开发。它强制要求使用 ArkTS 语言和 ArkUI 声明式框架，摒弃过时的 Java 或类 Web 开发模式。

## 核心准则
1. **ArkTS 优先**：严格遵守静态类型检查，禁止使用 `any`。
2. **声明式 UI**：使用组件化开发，利用状态驱动 UI 更新。
3. **架构规范**：遵循 Stage 模型，合理划分 HAP/HSP 模块。
4. **性能基准**：长列表必须使用 `LazyForEach`，UI 线程严禁阻塞。

## 常用开发模式

### 1. 数据模型定义
始终使用 `interface` 在独立的 model 文件中定义数据结构。
```typescript
export interface DataItem {
  id: string;
  title: string;
  // 显式类型
}
```

### 2. 状态管理
合理使用状态装饰器：
- `@State`: 组件内私有状态。
- `@Prop`: 父传子，单向同步。
- `@Link`: 父子双向同步。
- `@Observed/@ObjectLink`: 嵌套对象属性监控。

### 3. 长列表优化 (WaterFlow/List)
必须结合 `BasicDataSource` 和 `LazyForEach`。
```typescript
WaterFlow() {
  LazyForEach(this.dataSource, (item: Item) => {
    FlowItem() {
      // 子组件
    }
  }, (item: Item) => item.id)
}
```

## 资源引用
- **编码规范**: 详见 [arkts-coding-style.md](references/arkts-coding-style.md)
- **API 参考**: 系统 API 请参考官方文档或项目内已有的 `HttpUtil.ets`, `AppConfig.ets` 等实现。

## 交互建议
- 当接收到 Java 逻辑时，自动转换为 ArkTS 实现。
- 提供 UI 代码时，优先展示基于 `Column/Row` 的响应式布局。
