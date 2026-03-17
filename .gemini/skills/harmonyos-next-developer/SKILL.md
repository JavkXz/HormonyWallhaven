---
name: harmonyos-next-developer
description: HarmonyOS Next (API 12+) 全栈开发专家，专注于 ArkTS/ArkUI 声明式开发、Stage 模型架构设计、性能优化与原子化服务开发。
---

# HarmonyOS Next Developer Skill

## 概述
本 Skill 指导开发者遵循 HarmonyOS Next (API 12+) 官方最新规范进行应用开发，采用 ArkTS 静态类型语言和 ArkUI 声明式框架，基于 Stage 模型构建高性能、响应式的鸿蒙原生应用。

---

## 一、核心技术栈

### 1.1 编程语言：ArkTS
- **TypeScript 超集**：在 TypeScript 基础上增加静态类型约束
- **禁止使用 `any`**：所有变量、参数、返回值必须显式声明类型
- **编译时类型检查**：利用静态类型系统提前发现错误

### 1.2 UI 框架：ArkUI
- **声明式范式**：状态驱动 UI 更新
- **链式语法**：组件属性配置采用链式调用
- **组件化设计**：高内聚、低耦合的组件复用

### 1.3 应用模型：Stage 模型
- **UIAbility**：应用基本能力单元，处理界面交互
- **ExtensionAbility**：特定场景能力扩展（如卡片、通知等）
- **Context**：运行环境上下文，提供资源访问能力

---

## 二、项目架构规范

### 2.1 目录结构
```
entry/
├── src/
│   └── main/
│       ├── ets/
│       │   ├── common/
│       │   │   ├── constants/      # 常量定义
│       │   │   ├── enums/          # 枚举定义
│       │   │   ├── interfaces/     # 接口定义
│       │   │   ├── utils/          # 工具类
│       │   │   └── network/        # 网络请求封装
│       │   ├── components/         # 通用 UI 组件
│       │   ├── pages/              # 页面
│       │   ├── viewmodels/         # 视图模型（可选）
│       │   └── entryability/       # UIAbility 入口
│       └── resources/              # 资源文件
│           └── base/
│               ├── element/        # 字符串、颜色、数值
│               ├── media/          # 图片资源
│               └── profile/        # 配置文件
└── oh-package.json5
```

### 2.2 模块划分
| 模块类型 | 说明 | 使用场景 |
|---------|------|---------|
| **HAP** | 应用安装包 | 独立功能模块，可单独安装 |
| **HAR** | 静态共享包 | 公共代码库，编译时静态引用 |
| **HSP** | 动态共享包 | 运行时动态加载，支持热更新 |

---

## 三、ArkTS 编码规范

### 3.1 类型声明规则
```typescript
// ✅ 正确：显式类型声明
const MAX_COUNT: number = 100;
const userName: string = 'John';
interface UserInfo {
  id: number;
  name: string;
  age: number;
}

// ❌ 错误：使用 any
const data: any = getData();  // 禁止
const items = [];  // 禁止，应写为：const items: string[] = [];
```

### 3.2 命名约定
| 类型 | 命名规则 | 示例 |
|-----|---------|------|
| 类/组件/接口 | PascalCase | `UserCard`, `DataModel` |
| 变量/函数/方法 | camelCase | `loadData`, `userList` |
| 常量/枚举值 | UPPER_SNAKE_CASE | `MAX_RETRY_COUNT`, `STATUS_SUCCESS` |
| 私有成员 | 加下划线前缀 | `_internalCount`, `_handleClick()` |

### 3.3 异步编程
```typescript
// ✅ 推荐：async/await 模式
async function fetchUserData(userId: number): Promise<UserInfo> {
  try {
    const response = await http.get(`/api/user/${userId}`);
    return response.data;
  } catch (error) {
    console.error('获取用户失败:', error);
    throw error;
  }
}

// ✅ 耗时任务使用 TaskPool
import { taskPool } from '@kit.ArkTS';

async function processImage(imagePath: string): Promise<string> {
  return await taskPool.exec('processImageData', [imagePath]);
}
```

---

## 四、ArkUI 声明式开发

### 4.1 状态管理装饰器

| 装饰器 | 作用域 | 数据流向 | 使用场景 |
|-------|-------|---------|---------|
| `@State` | 组件内 | - | 组件内部私有状态 |
| `@Prop` | 父子组件 | 父→子（单向） | 父组件传值，子组件不修改 |
| `@Link` | 父子组件 | 双向同步 | 父子组件需要同步状态 |
| `@Provide/@Consume` | 祖先-后代 | 自上而下 | 跨层级组件通信 |
| `@Observed/@ObjectLink` | 嵌套对象 | - | 监听嵌套对象属性变化 |
| `@Watch` | 组件内 | - | 状态变化监听回调 |

### 4.2 基础布局组件
```typescript
@Entry
@Component
struct HomePage {
  @State count: number = 0;

  build() {
    Column() {
      // 文本组件
      Text('计数器')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 20 })

      // 按钮
      Button('点击 +1')
        .onClick(() => {
          this.count++;
        })
        .width('80%')
        .height(45)

      // 条件渲染
      If(this.count > 5) {
        Text('已达上限')
          .fontColor(Color.Red)
      }

      // 循环渲染
      ForEach([1, 2, 3], (item: number) => {
        Text(`Item ${item}`)
      })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
}
```

### 4.3 常用布局容器
| 布局 | 描述 | 典型用途 |
|-----|------|---------|
| `Column` | 垂直布局 | 纵向列表、表单 |
| `Row` | 水平布局 | 按钮组、横向排列 |
| `Stack` | 层叠布局 | 悬浮按钮、背景图 + 文字 |
| `Flex` | 弹性布局 | 复杂自适应布局 |
| `Grid` | 网格布局 | 九宫格、商品列表 |
| `List` | 列表 | 纵向滚动列表 |
| `WaterFlow` | 瀑布流 | 图片墙、商品流 |

### 4.4 长列表性能优化
```typescript
// ✅ 正确：使用 LazyForEach + BasicDataSource
@Entry
@Component
struct VideoList {
  @State dataSource: VideoDataSource = new VideoDataSource();

  build() {
    List({ space: 10 }) {
      LazyForEach(this.dataSource, (item: VideoItem) => {
        ListItem() {
          VideoCard({ video: item })
        }
      }, (item: VideoItem) => item.id)
    }
    .width('100%')
    .height('100%')
  }
}

// 自定义数据源
class VideoDataSource implements BasicDataSource {
  private data: VideoItem[] = [];
  private totalCount: number = 0;

  getData(index: number): VideoItem {
    return this.data[index];
  }

  totalCount(): number {
    return this.data.length;
  }
}
```

---

## 五、网络请求封装

### 5.1 HTTP 工具类
```typescript
import { http } from '@kit.NetworkKit';
import { BusinessError } from '@kit.BasicServicesKit';

export class HttpUtil {
  private static BASE_URL = 'https://api.example.com';
  private static TIMEOUT = 10000;

  static async get<T>(url: string, params?: Record<string, string>): Promise<T> {
    const httpRequest = http.createHttp();
    try {
      const response = await httpRequest.request(
        `${this.BASE_URL}${url}`, {
          method: http.RequestMethod.GET,
          header: { 'Content-Type': 'application/json' },
          extraData: params,
          connectTimeout: this.TIMEOUT,
          readTimeout: this.TIMEOUT
        }
      );
      
      if (response.responseCode === 200) {
        return response.result as T;
      }
      throw new Error(`HTTP Error: ${response.responseCode}`);
    } catch (error) {
      console.error('GET request failed:', error);
      throw error;
    } finally {
      httpRequest.destroy();
    }
  }

  static async post<T>(url: string, data: Record<string, unknown>): Promise<T> {
    const httpRequest = http.createHttp();
    try {
      const response = await httpRequest.request(
        `${this.BASE_URL}${url}`, {
          method: http.RequestMethod.POST,
          header: { 'Content-Type': 'application/json' },
          extraData: JSON.stringify(data),
          connectTimeout: this.TIMEOUT,
          readTimeout: this.TIMEOUT
        }
      );
      
      if (response.responseCode === 200) {
        return response.result as T;
      }
      throw new Error(`HTTP Error: ${response.responseCode}`);
    } catch (error) {
      console.error('POST request failed:', error);
      throw error;
    } finally {
      httpRequest.destroy();
    }
  }
}
```

---

## 六、资源管理

### 6.1 资源文件定义
```json
// resources/base/element/string.json
{
  "string": [
    { "name": "app_name", "value": "我的应用" },
    { "name": "login_success", "value": "登录成功" },
    { "name": "network_error", "value": "网络错误，请重试" }
  ]
}

// resources/base/element/color.json
{
  "color": [
    { "name": "primary_color", "value": "#007DFF" },
    { "name": "text_primary", "value": "#1F1F1F" },
    { "name": "text_secondary", "value": "#999999" }
  ]
}
```

### 6.2 资源引用方式
```typescript
import { router } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';

@Entry
@Component
struct LoginPage {
  build() {
    Column() {
      Text($r('app.string.app_name'))
        .fontColor($r('app.color.primary_color'))
      
      Button($r('app.string.login_btn'))
        .onClick(async () => {
          // 路由跳转
          router.pushUrl({ url: 'pages/HomePage' });
        })
    }
  }
}
```

---

## 七、性能优化清单

### 7.1 UI 渲染优化
- [ ] 减少 `build()` 函数内的计算复杂度
- [ ] 避免过度嵌套的组件层级
- [ ] 长列表必须使用 `LazyForEach`
- [ ] 图片使用异步加载和缓存
- [ ] 合理使用 `@Builder` 抽取复用逻辑

### 7.2 内存优化
- [ ] 及时注销事件监听器
- [ ] 大图片使用 `rawfile` 或云端存储
- [ ] 避免循环引用导致内存泄漏
- [ ] 使用 `TaskPool` 处理耗时任务

### 7.3 启动优化
- [ ] 减少 Ability 的 `onCreate` 耗时操作
- [ ] 延迟加载非关键资源
- [ ] 使用预加载技术提升页面切换流畅度

---

## 八、调试与测试

### 8.1 日志输出
```typescript
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG = 'HomePage';
const FORMAT = '%{public}s, %{public}s';

hilog.info(TAG, 'onInit', '页面初始化完成');
hilog.warn(TAG, 'fetchData', '数据加载延迟：%{public}s', `${delay}ms`);
hilog.error(TAG, 'onError', '发生错误：%{public}s', error.message);
```

### 8.2 单元测试
```typescript
// entry/src/main/ets/test/DataUtils.test.ts
import { describe, it, expect } from '@kit.ArkUnit';
import { formatCurrency } from '../common/utils/DataUtils';

describe('DataUtils', () => {
  it('formatCurrency_001', () => {
    const result = formatCurrency(1234.567);
    expect(result).assertEquals('¥1,234.57');
  });
});
```

---

## 九、原子化服务开发

### 9.1 服务卡片（Form）
```typescript
// 卡片提供者配置
// src/main/resources/base/profile/main_form_config.json
{
  "forms": [
    {
      "name": "widget_card",
      "displayName": "信息卡片",
      "description": "展示实时信息",
      "src": "./ets/form/cardProvider.ets",
      "uiSyntax": "arkts",
      "window": {
        "designWidth": 720,
        "autoDesignHeight": true
      }
    }
  ]
}
```

### 9.2 元服务特性
- **免安装**：用户无需下载安装即可使用
- **卡片交互**：支持桌面卡片快速操作
- **跨设备流转**：支持多设备协同

---

## 十、安全检查清单

### 10.1 权限管理
```typescript
// 动态申请权限
import { bundleManager } from '@kit.AbilityKit';

async function requestPermission(): Promise<boolean> {
  const permissions = ['ohos.permission.CAMERA'];
  try {
    const result = await bundleManager.requestPermissionsFromUser(permissions);
    return result.permissions.every(p => p.result === 0);
  } catch (error) {
    console.error('权限申请失败:', error);
    return false;
  }
}
```

### 10.2 数据安全
- [ ] 敏感数据（token、密码）使用 `Preferences` 加密存储
- [ ] HTTPS 证书校验启用
- [ ] 网络传输数据加密
- [ ] 日志中不输出敏感信息

---

## 附录：常用官方资源

### API 参考
- [ArkTS 语言指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/ArkTS-language-overview-V5)
- [ArkUI 状态管理](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/ArkUI-state-management-V5)
- [Stage 模型应用架构](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/application-architecture-V5)
- [@kit 接口文档](https://developer.huawei.com/consumer/cn/doc/harmonyos-references-V5/)

### 最佳实践
- [性能优化指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/performance-optimization-V5)
- [多设备适配](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/device-adaptation-V5)
