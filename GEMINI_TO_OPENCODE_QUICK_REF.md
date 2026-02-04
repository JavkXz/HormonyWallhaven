# Gemini 到 OpenCode 快速映射参考

**创建时间:** 2026-02-04
**来源:** ~/.gemini/ 配置迁移

---

## 一、MCP 配置映射

| Gemini MCP | OpenCode 对应 | 使用方式 | 状态 |
|-----------|--------------|---------|------|
| **filesystem** | `bash`, `read`, `write`, `edit` | 直接调用工具 | ✅ 已内置 |
| **context7** | `context7_query-docs`, `context7_resolve-library-id` | 直接调用工具 | ✅ 已内置 |
| **sequential-thinking** | `oracle` (subagent) | `delegate_task(subagent_type="oracle")` | ✅ 已内置 |
| **vibe_kanban** | `todowrite`/`todoread` | Todo 管理 | ⚠️ 功能简化 |
| **exa-mcp-server** | `websearch_web_search_exa` | 直接调用工具 | ✅ 已内置 |

### 使用示例

```typescript
// 1. 文件系统操作
read({ filePath: "..." })
write({ filePath: "...", content: "..." })
edit({ filePath: "...", oldString: "...", newString: "..." })
bash({ command: "...", description: "..." })

// 2. Context7 - 查询文档
context7_resolve_library_id({ libraryName: "spring-boot", query: "REST controller" })
context7_query_docs({ libraryId: "/org/springframework/spring-boot", query: "MyBatis-Plus" })

// 3. Oracle - 复杂推理
delegate_task(
  subagent_type="oracle",
  run_in_background=false,
  load_skills=[],
  prompt="分析这个架构设计问题..."
)

// 4. Web Search - Exa 搜索
websearch_web_search_exa({
  query: "Spring Boot 3.0 最新特性",
  numResults: 10
})

// 5. Todo 管理（替代看板）
todowrite({
  todos: [
    { id: "1", content: "任务描述", status: "pending", priority: "high" }
  ]
})
todoread()
```

---

## 二、Skills 映射

| Gemini Skill | OpenCode 对应 | 使用方式 | 状态 |
|-------------|---------------|---------|------|
| **dimine-backend-coding-enriched** | `docs/java-springboot-standards.md` | 参考文档 | 📄 已迁移 |
| **frontend-design** | `frontend-ui-ux` (skill) | `delegate_task(category="visual-engineering", load_skills=["frontend-ui-ux"])` | ✅ 已内置 |
| **skill-creator** | `delegate_task` | 动态创建代理 | ✅ 已支持 |
| **skill-lookup** | `librarian` (subagent) | `delegate_task(subagent_type="librarian")` | ✅ 已内置 |

### 使用示例

#### 1. 后端编码规范（Spring Boot）

```typescript
// 参考文档：docs/java-springboot-standards.md
// 或者直接使用 OpenCode 的内置功能
```

#### 2. 前端设计

```typescript
delegate_task(
  category="visual-engineering",
  load_skills=["frontend-ui-ux"],
  description="创建精美前端界面",
  prompt="创建一个现代化的仪表盘界面，包含图表和数据展示...",
  run_in_background=false
)
```

#### 3. 查找技能/文档

```typescript
// 搜索远程代码库或文档
delegate_task(
  subagent_type="librarian",
  run_in_background=true,
  load_skills=[],
  prompt="搜索 Spring Boot REST API 的最佳实践示例"
)
```

#### 4. 创建自定义任务

```typescript
// 根据任务复杂度选择合适的 category
delegate_task(
  category="quick",              // 简单任务
  category="deep",               // 复杂问题研究
  category="ultrabrain",         // 逻辑密集型任务
  category="visual-engineering", // 前端任务
  category="writing",            // 文档编写
  load_skills=["frontend-ui-ux", "git-master"],
  description="任务描述",
  prompt="详细任务说明...",
  run_in_background=false
)
```

---

## 三、Extensions 映射

| Gemini Extension | OpenCode 对应 | 使用方式 | 状态 |
|-----------------|---------------|---------|------|
| **context7** | `context7_query-docs`, `context7_resolve-library-id` | 直接调用 | ✅ 已内置 |
| **exa-mcp-server** | `websearch_web_search_exa` | 直接调用 | ✅ 已内置 |
| **gemini-cli-ralph** | `/ulw-loop` (slashcommand) | `slashcommand(command="/ulw-loop")` | ✅ 已内置 |

---

## 四、项目配置（GEMINI.md）迁移

### Gemini 配置要点

```markdown
## 角色设定
- 资深 Java 架构师与全栈开发专家

## 语言规范
- 所有回复必须使用中文

## Git Commit 协议
- Commit = 用户指令意图 + 实际代码变更
- 格式: type: 简短的中文描述

## 技术栈默认配置
- 语言: Java (Latest LTS)
- 构建工具: Maven
- 数据库: PostgreSQL
- 框架: Spring Boot (默认)
```

### OpenCode 对应

| Gemini 规则 | OpenCode 实现 |
|-----------|--------------|
| 中文输出 | ✅ AGENTS.md 中已指定 |
| Todo 管理 | ✅ todowrite/todoread |
| Git 操作 | ✅ git-master skill |
| Java 专属角色 | ⚠️ 可选，Sisyphus 是通用 orchestrator |

### Java 项目开发时添加到 AGENTS.md

```markdown
## PROJECT-SPECIFIC CONVENTIONS

### Java 项目开发规范

当用户在 Java/Spring Boot 项目中工作时：

**技术栈默认配置：**
- 语言: Java (Latest LTS)
- 构建工具: Maven
- 数据库: PostgreSQL
- 框架: Spring Boot 3.x (Jakarta EE)

**编码规范：**
- 严格遵循 Google Java Style Guide
- 关键逻辑必须包含中文注释
- 使用 @Resource 进行依赖注入
- 使用 Jakarta Validation 进行参数校验
- 使用 MyBatis-Plus Lambda 查询
- 参考: `docs/java-springboot-standards.md`

**Git Commit 协议：**
- Commit 信息 = 用户指令意图 + 实际代码变更
- 格式: type: 简短的中文描述
- 严禁描述未修改的功能
```

---

## 五、常用命令对照

| Gemini | OpenCode | 说明 |
|--------|----------|------|
| 文件操作 | `read`, `write`, `edit`, `bash` | 文件读写和命令执行 |
| 代码搜索 | `grep`, `glob`, `ast_grep_search` | 代码搜索和匹配 |
| Git 操作 | `bash("git ...")` 或 git-master skill | Git 命令 |
| MCP 调用 | `context7_*`, `websearch_*` | 直接调用工具 |
| 代理任务 | `delegate_task()` | 委托给子代理 |
| Slash 命令 | `slashcommand()` | 执行内置命令 |

---

## 六、完整工作流示例

### 场景：创建 Spring Boot 用户管理模块

#### Gemini 方式

```bash
# 触发 dimine-backend-coding-enriched skill
"帮我创建一个 Spring Boot 用户管理模块，使用 MyBatis-Plus"
```

#### OpenCode 方式

```typescript
// 1. 创建 Todo 列表
todowrite({
  todos: [
    { id: "1", content: "设计数据库表结构", status: "in_progress", priority: "high" },
    { id: "2", content: "创建 Entity (DO) 类", status: "pending", priority: "high" },
    { id: "3", content: "创建 Mapper 接口", status: "pending", priority: "medium" },
    { id: "4", content: "创建 Service 接口和实现", status: "pending", priority: "medium" },
    { id: "5", content: "创建 Controller 和 VOs", status: "pending", priority: "medium" },
    { id: "6", content: "编写单元测试", status: "pending", priority: "low" }
  ]
})

// 2. 查询 Spring Boot 文档（并行）
context7_resolve_library_id({
  libraryName: "spring-boot",
  query: "创建 REST controller"
})

// 3. 搜索最佳实践（并行）
delegate_task(
  subagent_type="librarian",
  run_in_background=true,
  load_skills=[],
  prompt="搜索 Spring Boot MyBatis-Plus 用户管理的最佳实践示例"
)

// 4. 编写代码
write({
  filePath: "UserDO.java",
  content: `@Data
@TableName("t_sys_user")
public class UserDO extends SuperTenantEntity {
    @TableId(type = IdType.AUTO)
    private Long id;
    // ... 字段定义
}`
})

// 5. 更新 Todo 状态
todowrite({
  todos: [
    { id: "1", content: "设计数据库表结构", status: "completed", priority: "high" },
    { id: "2", content: "创建 Entity (DO) 类", status: "in_progress", priority: "high" }
  ]
})

// 6. Git Commit
delegate_task(
  category="quick",
  load_skills=["git-master"],
  description="提交代码",
  prompt="提交用户管理模块代码",
  run_in_background=false
)
```

---

## 七、API Keys 配置

### Gemini MCP 配置（原始）

```json
{
  "context7": {
    "httpUrl": "https://mcp.context7.com/mcp",
    "headers": {
      "CONTEXT7_API_KEY": "YOUR_API_KEY",
      "Accept": "application/json, text/event-stream"
    }
  }
}
```

### OpenCode 配置方式

OpenCode 的 MCP 工具已内置，API Key 需要通过环境变量或配置文件设置：

```bash
# Context7 API Key
export CONTEXT7_API_KEY="your-api-key-here"

# Exa API Key
export EXA_API_KEY="your-exa-api-key-here"
```

---

## 八、技能和代理对比

| 维度 | Gemini Skills | OpenCode Skills + Agents |
|-----|--------------|-------------------------|
| **触发方式** | 自动（基于 description） | 手动（`delegate_task`） |
| **文件结构** | SKILL.md + references/ | Category + Subagent Type + Skills |
| **资源加载** | 渐进式加载 | 动态加载 |
| **持久化** | 本地文件系统 | Session-based |
| **并发** | 单个 skill | 多个 agents 并行 |

---

## 九、快速查找

### 我需要...

- 📄 **查询文档** → `context7_query-docs`, `context7_resolve-library-id`
- 🔍 **搜索网络** → `websearch_web_search_exa`
- 📁 **文件操作** → `read`, `write`, `edit`, `bash`
- 🔍 **代码搜索** → `grep`, `glob`, `ast_grep_search`
- 🤖 **复杂推理** → `delegate_task(subagent_type="oracle")`
- 🎨 **前端设计** → `delegate_task(category="visual-engineering", load_skills=["frontend-ui-ux"])`
- 📚 **外部文档** → `delegate_task(subagent_type="librarian")`
- 🗂️ **任务管理** → `todowrite`, `todoread`
- 🔧 **Git 操作** → `delegate_task(category="quick", load_skills=["git-master"])`
- 🧪 **代码分析** → `delegate_task(subagent_type="explore")`

---

## 十、配置文件位置

| 平台 | 配置位置 |
|-----|---------|
| **Gemini** | `~/.gemini/` |
| **OpenCode** | `AGENTS.md`, `.env`, 项目根目录 |

---

**文档版本:** 1.0
**最后更新:** 2026-02-04
**维护者:** AI Assistant
