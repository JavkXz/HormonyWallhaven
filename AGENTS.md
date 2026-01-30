# Agent Guidelines for HarmonyOS Wallpaper Application

This document provides guidelines for AI coding agents working on this HarmonyOS/OpenHarmony wallpaper application.

## Build Commands

### Build
- **Debug build**: `hvigor buildDebug`
- **Release build**: `hvigor buildRelease`
- **Deploy**: `hvigor deploy`

### Testing
Tests use the Hypium framework (HarmonyOS testing framework).
- **Test files location**:
  - Local unit tests: `entry/src/test/*.ets`
  - Instrumented tests: `entry/src/ohosTest/ets/test/*.ets`
- **Run tests**: Execute tests through DevEco Studio's test runner
- **Test structure**: Each test file exports a function that calls test suites using `describe()`, `it()` from `@ohos/hypium`
- **Single test filter**: Use test attributes (Level, Size, TestType) to filter specific tests

### Linting
- Linting is configured in `code-linter.json5`
- Lints `**/*.ets` files (ignoring test/mock/node_modules/build directories)
- Runs ESLint with TypeScript and performance rules
- Lint automatically runs during build process

## Code Style Guidelines

### File Structure
- **File extension**: All source files use `.ets` extension (ArkTS/TypeScript variant)
- **Directory structure**:
  - `entry/src/main/ets/entryability/` - Application lifecycle (UIAbility)
  - `entry/src/main/ets/pages/` - UI pages/components
  - `entry/src/main/ets/service/` - Business logic services
  - `entry/src/main/ets/model/` - Data models/interfaces
  - `entry/src/main/ets/utils/` - Utility classes

### Imports
```typescript
// HarmonyOS kits - use @kit.* imports
import { http } from '@kit.NetworkKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { image } from '@kit.ImageKit';

// Local imports
import { ServiceClass } from '../service/ServiceClass';
import { ModelInterface } from '../model/Model';
```
- Group imports: HarmonyOS kits first, then local imports
- Use relative paths for local modules

### Naming Conventions
- **Classes/Interfaces**: PascalCase (e.g., `WallpaperService`, `ImageSizeInfo`)
- **Methods/Functions**: camelCase (e.g., `loadWallpaperList`, `buildQueryString`)
- **Variables/Properties**: camelCase (e.g., `wallpaperList`, `isLoading`)
- **Constants**: UPPER_SNAKE_CASE for module-level constants (e.g., `DOMAIN`, `WALLHAVEN_API_BASE_URL`)
- **Private readonly fields**: PascalCase with private modifier (e.g., `private readonly CARD_MARGIN_HORIZONTAL: number = 6`)

### Type Annotations
- Explicitly annotate function parameters and return types
- Use interface definitions for complex types
- Use `| undefined` for optional properties (e.g., `apiKey: string | undefined`)

```typescript
async searchWallpapers(params?: SearchParams): Promise<WallpaperItem[]> {
  // implementation
}

interface SearchParams {
  q?: string;
  purity?: string;
  page?: number;
}
```

### Component Decorators
```typescript
@Entry
@Component
struct PageName {
  @State stateVariable: Type = defaultValue;
  private readonly CONSTANT_NAME: Type = value;

  build() {
    // UI code
  }
}
```

### Error Handling
- Use try-catch blocks for async operations
- Log errors with `console.error()` or `hilog.error()`
- Provide fallback values or error states where appropriate
- Avoid rethrowing errors unless necessary for handling upstream

```typescript
async loadData() {
  try {
    this.isLoading = true;
    const data = await this.service.fetchData();
    this.processData(data);
  } catch (error) {
    console.error('Failed to load data:', error);
    // Set error state or fallback
  } finally {
    this.isLoading = false;
  }
}
```

### Logging
- Use `hilog.info()` for important lifecycle events with domain and tag
- Use `console.info()` for general debug information
- Use `console.error()` for error conditions
- Include context in log messages

```typescript
const DOMAIN = 0x0000;
hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onCreate');
console.info(`图片加载完成: ${item.name}`);
```

### Comments
- Use JSDoc-style comments for functions and interfaces
- Include `@param` and `@return` annotations
- Add brief inline comments for complex logic
- Write comments in Chinese when appropriate for this project

```typescript
/**
 * 搜索壁纸
 * @param params 搜索参数
 */
async searchWallpapers(params?: SearchParams): Promise<WallpaperItem[]> {
  // implementation
}
```

### UI/UX Patterns
- Use `@Builder` decorators for reusable UI components
- Chain UI component methods for styling
- Use proper accessibility attributes
- Handle loading and error states in UI

```typescript
@Builder
CustomComponent(item: ItemType) {
  Column() {
    // UI content
  }
  .width('100%')
  .margin({ top: 8 })
  .onClick(() => {
    // handle click
  })
}
```

### Security Guidelines
The project enforces security rules via linting:
- Avoid unsafe cryptographic operations (AES, hash, MAC, DH, DSA, ECDSA, RSA)
- Follow HarmonyOS security best practices

### Configuration Files
- Project config: `build-profile.json5`
- Module config: `entry/build-profile.json5`
- Lint config: `code-linter.json5`
- Dependencies: `oh-package.json5` (HarmonyOS package format)

### Testing Patterns
```typescript
import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect } from '@ohos/hypium';

export default function testSuite() {
  describe('TestSuiteName', () => {
    beforeAll(() => { /* setup once */ });
    beforeEach(() => { /* setup each test */ });
    afterEach(() => { /* cleanup each test */ });
    afterAll(() => { /* cleanup once */ });

    it('testName', 0, () => {
      // test implementation
      expect(actual).assertEqual(expected);
    });
  });
}
```

### Key Dependencies
- `@ohos/hypium` - Testing framework
- `@ohos/hamock` - Mocking framework
- HarmonyOS SDK kits via `@kit.*` imports

## Project-Specific Notes
- Target SDK: HarmonyOS 6.0.2 (API Level 22)
- App uses wallhaven.cc API for wallpapers
- Singleton pattern used for AppConfig
- HTTP requests use HttpUtil wrapper around @kit.NetworkKit
- UI uses ArkUI with declarative syntax
