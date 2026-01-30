# OHOS TEST KNOWLEDGE BASE

## 【最高优先级指令】
**所有思考、回答和生成的文件统一使用中文。**

---

**Parent:** `./AGENTS.md`
**Generated:** 2026-01-30

## OVERVIEW
使用 Hypium 框架的 HarmonyOS 仪器化测试。

## STRUCTURE
```
ohosTest/
└── ets/test/
    ├── Ability.test.ets      # UIAbility 生命周期测试（34 行）
    └── List.test.ets        # List 组件测试（4 行）
```

## WHERE TO LOOK
| 任务 | 位置 | 模式 |
|------|----------|---------|
| Ability 测试 | Ability.test.ets | `describe('EntryAbility')` |
| List 测试 | List.test.ets | `describe('List')` |

## CONVENTIONS

**测试结构：**
```typescript
import { describe, it, expect } from '@ohos/hypium';

export default function testSuite() {
  describe('FeatureName', () => {
    it('should do X', () => {
      expect(actual).assertEqual(expected);
    });
  });
}
```

**测试属性（Level, Size, TestType）：**
用于 DevEco Studio 过滤测试。

**Mock 框架：**
- `@ohos/hamock` 用于模拟依赖
- Mock 模式位于 `entry/src/mock/` 目录

## RUNNING TESTS
- 使用 DevEco Studio 测试运行器
- 通过测试属性过滤以执行目标测试
- 仪器化测试在设备/模拟器上运行

## ANTI-PATTERNS
- 测试覆盖率极低（Ability.test.ets 仅有骨架测试）
- 无服务层单元测试（WallhavenService, HttpUtil）
