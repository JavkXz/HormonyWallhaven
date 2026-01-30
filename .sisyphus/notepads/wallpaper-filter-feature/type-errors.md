# HarmonyOS ArkTS 类型错误总结（更新版）

## 【最高优先级指令】
**所有思考、回答和生成的文件统一使用中文。**

---

**Generated:** 2026-01-30
**Updated:** 2026-01-30（更新版）
**Context:** Index.ets 筛选功能实现中的类型错误

---

## 错误列表

### 1. ❌ 接口定义语法错误

**错误代码：**
```typescript
  // 选择器选项接口
  private interface SelectOption {
    value: string;
    label: string;
  }
```

**问题：**
ArkTS 不支持在 `struct` 内部使用 `private interface` 定义接口。

**正确写法：**
```typescript
// 在 struct 外部定义接口，或
// 直接使用内联类型，不单独声明接口
```

---

### 2. ❌ 对象字面量用作类型声明

**错误代码：**
```typescript
private purityOptions: Array<SelectOption> = [
  { value: '100', label: 'SFW (安全)' },
  ...
];
```

**问题：**
ArkTS 要求对象字面量必须对应已声明的类或接口，不能直接使用对象字面量作为类型声明。

**正确写法：**
```typescript
// 方式 1：在外部定义接口（推荐）
interface SelectOption {
  value: string;
  label: string;
}

private purityOptions: SelectOption[] = [
  { value: '100', label: 'SFW (安全)' },
  ...
];

// 方式 2：使用内联类型定义
private purityOptions: Array<{ value: string, label: string }> = [
  { value: '100', label: 'SFW (安全)' },
  ...
];
```

---

### 3. ❌ 函数类型参数不匹配

**错误代码：**
```typescript
@Builder
FilterSection(title: string, content: () => void) {
  ...
}
```

**问题：**
ArkTS 不支持 `() => void` 语法，必须使用显式的函数签名类型。

**正确写法：**
```typescript
// 方式 1：不使用 content 参数，直接内联
@Builder
FilterSection(title: string) {
  Column() {
    Text(title)
      .fontSize(14)
      .fontColor('#666666')
  }
  .width('100%')
  .alignItems(HorizontalAlign.Start)
}

// 方式 2：如果需要 content，使用显式函数类型
// 但 ArkUI @Builder 函数参数类型有限制
```

---

### 4. ❌ `any` 类型使用

**错误代码：**
```typescript
(searchParams as unknown as { resolutions: string }).resolutions = this.selectedResolution;
```

**问题：**
- `any` 类型绕过了类型检查
- 类型断言链过于复杂且不安全

**正确写法：**
```typescript
// 直接赋值，假设接口已有该字段
searchParams.resolutions = this.selectedResolution;

// 或者在接口中定义该字段（推荐）
export interface SearchParams {
  q?: string;
  categories?: string;
  purity?: string;
  sorting?: string;
  order?: string;
  topRange?: string;
  atleast?: string;
  resolutions?: string;  // 添加此字段
  ratios?: string;
  colors?: string;
  page?: number;
  seed?: string;
}
```

---

## ArkTS 类型系统核心规则

### 1. 接口定义
- ❌ 不能在 `struct` 内部使用 `private interface`
- ✅ 在文件顶部、其他文件中定义接口
- ✅ 或直接使用内联类型

### 2. 对象字面量
- ❌ 不能用作类型声明
- ✅ 必须使用已声明的类或接口
- ✅ 使用内联类型：`Array<{ value: string, label: string }>`

### 3. 函数类型
- ❌ 不支持 `() => void` 语法
- ✅ @Builder 函数参数使用简单类型
- ✅ 避免复杂的参数类型

### 4. `any` 类型
- ❌ 禁止使用 `any`
- ✅ 使用具体类型
- ✅ 或使用 `unknown`（更安全）

### 5. 可选字段
- ✅ 使用 `?` 标记可选字段
- ✅ 赋值前检查字段是否存在

---

## 最佳实践

1. **优先使用已有接口**（如 `SearchParams`, `WallpaperItem`）
2. **接口定义在文件顶部或单独文件**（model 目录）
3. **数组类型使用显式声明**（`Array<{ ... }>`）
4. **避免使用 `any` 类型**
5. **@Builder 函数保持简单**（避免复杂的参数类型）
6. **对象字面量使用内联类型**（而非引用类型）
7. **可选字段赋值前检查**（`if (param.field) { ... }`）

---

## 记录日期
2026-01-30（初始版本）
2026-01-30（更新版）

## 相关文件
- `entry/src/main/ets/model/WallpaperModel.ets`（接口定义）
- `entry/src/main/ets/pages/Index.ets`（类型错误）
