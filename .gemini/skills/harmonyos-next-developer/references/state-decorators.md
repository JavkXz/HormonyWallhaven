# ArkTS 状态装饰器速查表

## 装饰器对比

| 装饰器 | 作用域 | 数据流向 | 是否可修改 | 典型场景 |
|-------|-------|---------|-----------|---------|
| `@State` | 组件内 | - | ✅ | 组件内部计数器、开关状态 |
| `@Prop` | 父子组件 | 父 → 子 | ❌（子组件内） | 配置参数、只读数据传递 |
| `@Link` | 父子组件 | 双向同步 | ✅ | 表单输入、需要反馈的状态 |
| `@Provide/@Consume` | 祖先 - 后代 | 自上而下 | ✅ | 主题、用户信息跨层传递 |
| `@Observed/@ObjectLink` | 嵌套对象 | - | ✅ | 数组元素、对象属性变化监听 |
| `@Watch` | 组件内 | - | ✅ | 状态变化时触发副作用 |

---

## 使用示例

### @State - 组件内状态
```typescript
@Component
struct Counter {
  @State count: number = 0;

  build() {
    Column() {
      Text(`计数：${this.count}`)
      Button('增加')
        .onClick(() => {
          this.count++;  // UI 自动更新
        })
    }
  }
}
```

### @Prop - 单向传递
```typescript
@Component
struct Child {
  @Prop title: string = '';  // 子组件不能修改

  build() {
    Text(this.title)
  }
}

@Entry
@Component
struct Parent {
  @State parentTitle: string = '父组件标题';

  build() {
    Column() {
      Child({ title: this.parentTitle })
    }
  }
}
```

### @Link - 双向同步
```typescript
@Component
struct Child {
  @Link value: number;  // 可修改，同步到父组件

  build() {
    Button('增加')
      .onClick(() => {
        this.value++;  // 父组件同步更新
      })
  }
}

@Entry
@Component
struct Parent {
  @State parentValue: number = 0;

  build() {
    Column() {
      Child({ value: $parentValue })  // 使用 $ 符号建立双向绑定
    }
  }
}
```

### @Provide/@Consume - 跨层传递
```typescript
@Component
struct GrandChild {
  @Consume themeColor: string;  // 消费祖先提供的值

  build() {
    Text('孙组件')
      .fontColor(this.themeColor)
  }
}

@Component
struct Child {
  build() {
    Column() {
      GrandChild()
    }
  }
}

@Entry
@Component
struct Ancestor {
  @Provide themeColor: string = '#007DFF';

  build() {
    Column() {
      Child()
    }
  }
}
```

### @Observed/@ObjectLink - 嵌套对象
```typescript
@Observed
class User {
  name: string;
  age: number;

  constructor(name: string, age: number) {
    this.name = name;
    this.age = age;
  }
}

@Component
struct UserProfile {
  @ObjectLink user: User;  // 监听嵌套对象属性

  build() {
    Column() {
      Text(`姓名：${this.user.name}`)
      Text(`年龄：${this.user.age}`)
      Button('年龄 +1')
        .onClick(() => {
          this.user.age++;  // 触发 UI 更新
        })
    }
  }
}

@Entry
@Component
struct Parent {
  @State currentUser: User = new User('张三', 25);

  build() {
    Column() {
      UserProfile({ user: this.currentUser })
    }
  }
}
```

### @Watch - 状态监听
```typescript
@Component
struct SearchBox {
  @State @Watch('onKeywordChange') keyword: string = '';

  onKeywordChange(): void {
    if (this.keyword.length >= 3) {
      this.searchData();
    }
  }

  searchData(): void {
    // 执行搜索逻辑
  }

  build() {
    TextInput({ placeholder: '搜索...' })
      .onChange((value: string) => {
        this.keyword = value;
      })
  }
}
```

---

## 常见错误

### ❌ 错误：使用 any
```typescript
@State data: any = {};  // 禁止
```

### ✅ 正确：显式类型
```typescript
interface Data {
  id: number;
  value: string;
}

@State data: Data = { id: 0, value: '' };
```

### ❌ 错误：@Prop 子组件修改
```typescript
@Component
struct Child {
  @Prop count: number;

  build() {
    Button('增加')
      .onClick(() => {
        this.count++;  // 错误：@Prop 不能在子组件修改
      })
  }
}
```

### ✅ 正确：使用@Link 双向同步
```typescript
@Component
struct Child {
  @Link count: number;

  build() {
    Button('增加')
      .onClick(() => {
        this.count++;  // 正确：@Link 支持修改
      })
  }
}
```

---

## 选择指南

1. **组件内状态** → 使用 `@State`
2. **父传子，子不修改** → 使用 `@Prop`
3. **父子双向同步** → 使用 `@Link`
4. **跨多层传递** → 使用 `@Provide/@Consume`
5. **嵌套对象/数组** → 使用 `@Observed/@ObjectLink`
6. **状态变化执行副作用** → 使用 `@Watch`
