# Java/Spring Boot 编码规范（从 Gemini 迁移）

**来源:** Gemini `dimine-backend-coding-enriched` skill (v2.2)
**适用项目:** 基于 Dimine 框架的 Spring Boot 3.x 项目
**创建时间:** 2026-02-04

---

## 📖 概述

为 Dimine 框架后端开发强制执行一致的编码标准。本规范提供**完整的规范文档 + 代码模板**，覆盖数据库、安全、日志、错误处理、性能优化和测试等全方位最佳实践。

### 核心原则

- **多模块架构**: `xxx-api`（VOs）+ `xxx-service`（实现）
- **继承框架基类**: `SuperEntity`/`SuperTenantEntity`
- **直接返回对象**: Controller 方法直接返回对象（不使用 `R<T>` 包装）
- **框架自动填充**: 审计字段（createBy, createTime, updateBy, updateTime, tenantId）
- **内置多租户**: 通过 `SuperTenantEntity` 自动租户隔离
- **OpenAPI 3.x**: 统一使用 `@Tag`、`@Operation`、`@Schema` 注解

### 技术栈

- **Spring Boot 3.x** → **Jakarta EE**（`jakarta.*` 非 `javax.*`）
- **MyBatis-Plus 3.5+** → Lambda 查询、自动填充、分页插件
- **OpenAPI 3.x** → `@Tag`、`@Operation`、`@Schema` 注解
- **PostgreSQL** → 支持 MySQL/GaussDB/达梦
- **Flyway** → 数据库版本管理
- **JUnit 5 + Mockito** → 测试框架
- **Spring Cloud Stream** → 消息队列框架

---

## 🎯 快速参考

### [必须] 基本规则

1. **多模块结构**: VOs 在 `xxx-api`，实现在 `xxx-service`
2. **实体基类**: 继承 `SuperEntity` 或 `SuperTenantEntity`
3. **直接返回**: Controller 方法直接返回对象（不使用 `R<T>` 包装）
4. **分页**: Request 继承 `PageInput`，Response 使用 `PageOutput<T>`
5. **依赖注入**: 使用 `@Resource`（非 `@Autowired`）
6. **校验**: Controller 参数使用 `@Valid`，使用 `jakarta.validation.*` 注解
7. **API 文档**: OpenAPI 3.x（`@Tag`、`@Operation`、`@Schema`）
8. **Lombok**: `@Data @Builder @NoArgsConstructor @AllArgsConstructor`

### [必须] 命名规范

| 层级 | 模式 | 示例 |
|-----|------|------|
| API 模块 VO | `AddXxxReq`、`UpdateXxxReq`、`ListXxxByPageReq` | `AddPluginInfoReq` |
| API 模块 VO | `XxxVo`、`ListXxxByPageResp` | `PluginInfoVo` |
| Service 模块 Entity | `XxxDO` | `PluginInfoDO` |
| Mapper | `XxxMapper` | `PluginInfoMapper` |
| Service 接口 | `XxxService` | `PluginInfoService` |
| Service 实现 | `XxxServiceImpl` | `PluginInfoServiceImpl` |
| Controller | `XxxController` | `PluginInfoController` |

### [必须] Controller 方法模式

| 操作 | 方法名 | HTTP 方法 | 路径 | 返回类型 |
|-----|--------|----------|------|---------|
| 新增 | `addXxx` | POST | `/xxx/addXxx` | `XxxVo` |
| 修改 | `updateXxx` | PUT | `/xxx/updateXxx` | `void` |
| 删除 | `deleteXxxById` | DELETE | `/xxx/deleteXxxById` | `Boolean` |
| 根据ID查询 | `getXxxById` | GET | `/xxx/getXxxById` | `XxxVo` |
| 分页列表 | `listXxxByPage` | POST | `/xxx/listXxxByPage` | `PageOutput<ListXxxByPageResp>` |

### [推荐] 注解速查表

**Lombok:**
```java
@Data @Builder @NoArgsConstructor @AllArgsConstructor @Accessors(chain = true)
```

**MyBatis-Plus:**
```java
@TableName("t_xxx")           // 实体类
@TableId(type = IdType.AUTO)   // 主键
@Mapper                        // Mapper 接口
```

**OpenAPI 3.x:**
```java
@Tag(name = "...")             // Controller 类
@Operation(summary = "...")     // Controller 方法
@Schema(description = "...")    // VO 类/字段
@Parameter(description = "...") // 方法参数
```

**Jakarta Validation:**
```java
@Valid                         // 启用参数校验
@NotBlank(message = "...")     // 字符串不能为空
@NotNull(message = "...")      // 不能为空
@NotEmpty(message = "...")     // 集合不能为空
```

**Spring:**
```java
@Resource                      // 依赖注入（推荐）
@Transactional(rollbackFor = Exception.class)  // 事务
@Validated                     // 类级校验
```

---

## 🏗️ 架构原则

### [必须] 多模块结构

```
xxx-api/                          # API 模块（接口）
└── src/main/java/
    └── com/dimine/xxx/api/
        ├── vo/                   # 视图对象（在 API 模块中）
        │   ├── request/          # 请求 VOs
        │   │   ├── AddXxxReq.java
        │   │   ├── UpdateXxxReq.java
        │   │   └── ListXxxByPageReq.java
        │   └── response/         # 响应 VOs
        │       ├── XxxVo.java
        │       └── ListXxxByPageResp.java
        └── feign/                # Feign 客户端（可选）

xxx-service/                      # Service 模块（实现）
└── src/main/java/
    └── com/dimine/xxx/
        ├── controller/           # REST 控制器
        ├── service/              # Service 接口
        │   └── impl/            # Service 实现
        └── dao/                 # 数据访问层
            ├── domain/          # 实体类（DO）
            └── mapper/          # Mapper 接口
```

### [必须] 三层架构

```
Controller（薄层）
    ↓ @Valid + 直接返回
Service（业务逻辑）
    ↓ @Transactional + BeanUtils.toBean()
Mapper（数据访问）
    ↓ BaseMapper + LambdaQueryWrapper
Database
```

---

## ✅ 核心规范摘要

### [必须] 安全规范

- ✅ 密码字段必须使用 `@TableField(encrypt = true)`
- ✅ 敏感信息必须脱敏（手机号、身份证号）
- ✅ 使用 Jakarta Validation 输入验证
- ✅ 使用 MyBatis `#{}` 防止注入

### [必须] 数据库规范

- ✅ 表名格式：`t_{module}_{entity}`
- ✅ 字段命名：小写下划线分隔
- ✅ 索引命名：`idx_{table}_{columns}`、`uk_{table}_{columns}`
- ✅ 通用字段：id, createBy, createTime, updateBy, updateTime, tenantId
- ❌ 禁止 `SELECT *`

### [必须] 日志规范

- ✅ **ERROR**: 系统错误，立即处理
- ✅ **WARN**: 业务异常，需要关注
- ✅ **INFO**: 关键操作，正常流程记录
- ✅ **DEBUG**: 调试信息，开发环境
- ❌ 禁止记录密码、身份证号、手机号明文

### [必须] 事务规范

- ✅ 写操作使用 `@Transactional(rollbackFor = Exception.class)`
- ✅ 查询操作使用 `@Transactional(readOnly = true)`
- ❌ 避免大事务（超时 < 30s）

### [推荐] 性能优化

- ✅ 为 WHERE/JOIN/ORDER BY 字段创建索引
- ✅ 使用 MyBatis-Plus 分页插件
- ✅ 使用 Spring Cloud Stream（Kafka）
- ✅ 使用 `@Cacheable` 缓存查询
- ✅ 使用 `@Async` 异步处理
- ❌ 避免 `SELECT *`
- ❌ 避免 N+1 查询
- ❌ 避免大事务（超时时间 < 30s）

### [推荐] 错误处理

- ✅ 使用 `BusinessException` + `IMessage` 枚举
- ✅ 错误码与枚举键一致
- ✅ 全局异常处理器自动转换

### [推荐] 测试规范

- ✅ Controller 测试继承 `BaseControllerTest`
- ✅ Service 测试使用 Mockito
- ✅ 测试覆盖率 > 60%（核心业务 > 80%）

---

## 📋 检查清单

### 新功能开发检查清单

- [ ] 遵循数据库命名规范
- [ ] 使用 MyBatis-Plus Lambda 查询
- [ ] 添加合适的索引
- [ ] 实现全局异常处理
- [ ] 添加业务日志（INFO/WARN/ERROR）
- [ ] 敏感数据脱敏
- [ ] 使用 `@Transactional` 注解
- [ ] 编写单元测试（Controller + Service）
- [ ] 使用 OpenAPI 3.x 注解（`@Tag`, `@Operation`, `@Schema`）
- [ ] 性能测试（慢查询、批量操作）

### 代码审查检查清单

- [ ] 数据库查询优化（避免 `SELECT *`）
- [ ] 无 SQL 注入风险（使用 `#{}`）
- [ ] 无 XSS 漏洞（输入验证、输出编码）
- [ ] 租户隔离正确（`tenantId` 过滤）
- [ ] 日志级别合理（避免 INFO 过多）
- [ ] 错误处理完善（`BusinessException`）
- [ ] 测试覆盖率达标（> 60%）
- [ ] OpenAPI 注解正确（`@Tag`, `@Operation`, `@Schema`）

---

## 🔗 相关资源

### 外部资源
- **MyBatis-Plus**: https://baomidou.com/
- **PostgreSQL**: https://www.postgresql.org/docs/
- **Spring Boot**: https://docs.spring.io/spring-boot/
- **Jakarta EE**: https://jakarta.ee/specifications/
- **JUnit 5**: https://junit.org/junit5/docs/current/user-guide/
- **OpenAPI 3.0**: https://swagger.io/specification/
- **SpringDoc**: https://springdoc.org/

---

**版本:** v2.2 (从 Gemini 迁移)
**创建时间:** 2026-02-04
**来源:** Gemini `dimine-backend-coding-enriched` skill
