---
created: 2026-02-04
source: "Gemini 配置转换"
tags: [gemini, skills, mcp, config]
---

# Gemini 配置转换为 OpenCode 系统

## 概述

本文档将 Gemini CLI 的配置转换为 OpenCode (Sisyphus) 可用的格式。

---

## MCP 配置映射

### Gemini MCP 配置
```json
{
  "mcpServers": {
    "vibe_kanban": {
      "command": "npx",
      "args": ["-y", "vibe-kanban@latest", "--mcp"]
    },
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "D:\\Code", "D:\\File"]
    },
    "context7": {
      "httpUrl": "https://mcp.context7.com/mcp",
      "headers": {
        "CONTEXT7_API_KEY": "YOUR_API_KEY",
        "Accept": "application/json, text/event-stream"
      }
    },
    "sequential-thinking": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-sequential-thinking"],
      "env": {}
    }
  }
}
```

### OpenCode 对应工具

| Gemini MCP | OpenCode 对应工具 | 说明 |
|-----------|------------------|------|
| filesystem | `bash` (内置) | 通过 Bash 工具访问文件系统 |
| context7 | `context7_query-docs`, `context7_resolve-library-id` | 内置 Context7 集成 |
| sequential-thinking | `oracle` (subagent) | Oracle 代理用于复杂推理 |
| vibe_kanban | 待实现 | 需要手动看板管理 |
| exa-mcp-server | `websearch_web_search_exa` | 已有 Exa 搜索集成 |

### MCP 配置转换
```json
{
  "context7": {
    "enabled": true,
    "apiKey": "YOUR_API_KEY",
    "baseURL": "https://mcp.context7.com"
  },
  "exa": {
    "enabled": true,
    "apiKey": "YOUR_EXA_API_KEY"
  }
}
```

---

## Skills 配置转换

### 1. dimine-backend-coding-enriched

**Gemini Skill:** Spring Boot 3.x 后端编码规范（v2.2）

**转换为 OpenCode 技能：**

需要创建一个 Spring Boot 编码规范技能，包含：
- 数据库规范（PostgreSQL, MyBatis-Plus）
- 安全规范（Jakarta Validation, SQL注入防护）
- 日志规范（日志级别、格式）
- 错误处理（BusinessException, 错误码）
- 性能优化（索引、缓存、异步）
- 测试规范（JUnit 5, Mockito）
- 时区国际化
- 编码风格

**推荐方式：**
- 将 `dimine-backend-coding-enriched` 的内容整合到项目 AGENTS.md 中
- 或创建独立的编码规范文档

---

### 2. frontend-design

**Gemini Skill:** 前端设计指导（避免通用AI美学）

**OpenCode 对应：**
- **Skill:** `frontend-ui-ux` (已存在)
- 描述: Designer-turned-developer who crafts stunning UI/UX even without design mockups

**使用方式：**
```typescript
delegate_task(
  category="visual-engineering",
  load_skills=["frontend-ui-ux"],
  description="创建精美的前端界面",
  prompt="..."
)
```

---

### 3. skill-creator

**Gemini Skill:** 创建技能的指南

**OpenCode 对应：**
- **Category:** `unspecified-low` 或 `unspecified-high`
- 使用 `delegate_task` 创建新任务代理

**不需要单独技能**，因为 OpenCode 的代理系统已经支持动态创建。

---

### 4. skill-lookup

**Gemini Skill:** 查找技能

**OpenCode 对应：**
- **Skill:** `librarian` (已存在)
- 描述: Specialized codebase understanding agent for multi-repository analysis, searching remote codebases, retrieving official documentation

**使用方式：**
```typescript
delegate_task(
  subagent_type="librarian",
  run_in_background=true,
  load_skills=[],
  prompt="搜索特定技能或文档"
)
```

---

## Extensions 配置转换

### 1. context7 Extension

**Gemini Extension:** Context7 MCP 服务器

**OpenCode 对应：**
- **工具:** `context7_query-docs`, `context7_resolve-library-id`
- **已内置**，无需额外配置

---

### 2. exa-mcp-server Extension

**Gemini Extension:** Exa 搜索引擎

**OpenCode 对应：**
- **工具:** `websearch_web_search_exa`
- **已内置**，无需额外配置

---

### 3. gemini-cli-ralph Extension

**Gemini Extension:** Ralph 自指开发循环

**OpenCode 对应：**
- **命令:** `/ulw-loop` (builtin)
- 描述: Start ultrawork loop - continues until completion with ultrawork mode

---

## 项目配置（GEMINI.md）转换

### Gemini GEMINI.md 内容

```markdown
# System Instructions & Project Guidelines

## 角色设定
你是一名**资深 Java 架构师与全栈开发专家**。

## 语言与沟通规范
- **主语言**：所有回复、思维链、代码注释及任务清单，**必须**使用**中文**。
- **强制工作流**：
    1. 思考与规划
    2. 方案确认
    3. 任务分解

## Git Commit 生成协议
- Commit 信息 = 用户指令意图 + 实际代码变更
- 格式: type: 简短的中文描述

## 技术栈默认配置
- **语言**：Java (Latest LTS)
- **构建工具**：Maven
- **数据库**：PostgreSQL
- **框架**：Spring Boot (默认)
```

### OpenCode 对应配置

**已存在行为：**
- ✅ 中文输出（已在 AGENTS.md 中指定）
- ✅ Todo 管理（todoread/todowrite）
- ✅ Git 操作（git-master skill）
- ⚠️ 角色：Sisyphus（通用 orchestrator，而非 Java 专属）

**推荐整合方式：**

在 AGENTS.md 中添加：

```markdown
## PROJECT-SPECIFIC CONVENTIONS

### Java 项目开发规范

当用户在 Java/Spring Boot 项目中工作时：

**角色定位：** 资深 Java 架构师与全栈开发专家

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

**Git Commit 协议：**
- Commit 信息 = 用户指令意图 + 实际代码变更
- 格式: type: 简短的中文描述
- 严禁描述未修改的功能

**多模块结构：**
- xxx-api: VOs（视图对象）
- xxx-service: 实现（DO, Mapper, Service, Controller）
```

---

## 配置迁移建议

### 优先级 1: 立即可用

以下配置已内置，无需迁移：
1. ✅ context7 (`context7_query-docs`, `context7_resolve-library-id`)
2. ✅ websearch (`websearch_web_search_exa`)
3. ✅ 文件系统 (`bash`, `read`, `write`, `edit`, etc.)
4. ✅ 前端设计 (`frontend-ui-ux` skill)
5. ✅ 文档查找 (`librarian` subagent)

### 优先级 2: 需要手动配置

1. **dimine-backend-coding-enriched**:
   - 将其内容整合到 AGENTS.md 中
   - 或创建独立的编码规范文档（如 `docs/coding-standards.md`）

2. **vibe_kanban**:
   - OpenCode 当前不支持看板
   - 使用 todolist 作为替代

### 优先级 3: 可选迁移

1. **sequential-thinking**:
   - 使用 `oracle` 代理替代

2. **GEMINI.md 规范**:
   - 整合到 AGENTS.md 的 PROJECT-SPECIFIC CONVENTIONS 中

---

## 使用示例

### 原始 Gemini 使用方式

```bash
# 在 Gemini CLI 中
"帮我创建一个 Spring Boot 用户管理模块，使用 MyBatis-Plus"
# 触发 dimine-backend-coding-enriched skill
```

### OpenCode 使用方式

```typescript
// 1. 创建 Todo 列表
todowrite({
  todos: [
    { id: "1", content: "设计数据库表结构", status: "pending", priority: "high" },
    { id: "2", content: "创建 Entity (DO) 类", status: "pending", priority: "high" },
    { id: "3", content: "创建 Mapper 接口", status: "pending", priority: "medium" },
    { id: "4", content: "创建 Service 接口和实现", status: "pending", priority: "medium" },
    { id: "5", content: "创建 Controller 和 VOs", status: "pending", priority: "medium" },
    { id: "6", content: "编写单元测试", status: "pending", priority: "low" }
  ]
})

// 2. 使用 context7 查询 Spring Boot 文档
context7_resolve_library_id({ libraryName: "spring-boot", query: "创建 REST controller" })
context7_query_docs({ libraryId: "/org/springframework/spring-boot", query: "MyBatis-Plus 配置" })

// 3. 编写代码
write({ filePath: "UserDO.java", content: "..." })
```

---

## 技能对照表

| Gemini Skill | OpenCode 对应 | 说明 |
|-------------|---------------|------|
| dimine-backend-coding-enriched | AGENTS.md + 自定义编码规范文档 | 需要迁移内容 |
| frontend-design | frontend-ui-ux (skill) | 已内置 |
| skill-creator | delegate_task | 已支持 |
| skill-lookup | librarian (subagent) | 已内置 |

---

## MCP 工具对照表

| Gemini MCP | OpenCode 工具 | 状态 |
|-----------|--------------|------|
| filesystem | bash, read, write, edit | ✅ 已内置 |
| context7 | context7_* | ✅ 已内置 |
| sequential-thinking | oracle | ✅ 已内置 |
| vibe_kanban | todolist | ⚠️ 功能简化 |
| exa-mcp-server | websearch_web_search_exa | ✅ 已内置 |

---

## 下一步行动

### 如果需要完整迁移 dimine-backend-coding-enriched:

1. 将 `~/.gemini/skills/dimine-backend-coding-enriched/` 的内容复制到项目
2. 创建 `docs/spring-boot-coding-standards/` 目录
3. 将 references 和 templates 整合到项目中
4. 在 AGENTS.md 中添加引用

### 如果只是想使用核心功能:

1. ✅ context7 已可用
2. ✅ websearch 已可用
3. ✅ frontend-ui-ux skill 已可用
4. ✅ librarian subagent 已可用

---

## 注意事项

1. **API Keys:** Context7 和 Exa 需要配置 API Key
2. **文件路径:** 文件系统路径需要转换为绝对路径
3. **技能触发:** OpenCode 使用 `delegate_task` 而非自动触发
4. **代理分类:** OpenCode 有明确的代理分类（visual-engineering, ultrabrain, deep 等）

---

**生成时间:** 2026-02-04
**来源:** Gemini CLI 配置 (~/.gemini/)
