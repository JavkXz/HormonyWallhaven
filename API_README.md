# HarmonyOS 壁纸应用

这是一个基于HarmonyOS的壁纸下载应用，使用ArkTS/ETS语言开发，采用ArkUI框架构建用户界面。应用从wallhaven.cc获取壁纸资源。

## 功能特性

- 浏览wallhaven.cc上的壁纸
- 搜索和筛选壁纸
- 下载壁纸功能
- 响应式网格布局

## API集成

应用集成了wallhaven.cc的API，支持以下功能：

- 搜索壁纸
- 按类别、纯净度、分辨率等筛选
- 获取壁纸详细信息

## 配置API密钥

1. 注册wallhaven.cc账户
2. 在账户设置中获取API密钥
3. 在应用的设置页面输入API密钥

API密钥用于访问NSFW内容和提高API调用限制。

## 项目结构

```
FirstApplication/
├── AppScope/                 # 应用全局配置
│   └── app.json5             # 应用元数据（包名、版本等）
├── entry/                    # 主应用模块
│   ├── src/
│   │   ├── main/             # 主源码
│   │   │   ├── ets/          # ArkTS/ETS源文件
│   │   │   │   ├── entryability/     # 应用生命周期管理
│   │   │   │   │   └── EntryAbility.ets
│   │   │   │   ├── entrybackupability/ # 备份能力
│   │   │   │   │   └── EntryBackupAbility.ets
│   │   │   │   ├── model/            # 数据模型
│   │   │   │   │   └── WallpaperModel.ets
│   │   │   │   ├── service/          # 业务服务
│   │   │   │   │   └── WallhavenService.ets
│   │   │   │   ├── utils/            # 工具类
│   │   │   │   │   ├── HttpUtil.ets
│   │   │   │   │   └── AppConfig.ets
│   │   │   │   └── pages/            # UI页面
│   │   │   │       ├── Index.ets      # 主页（壁纸网格展示）
│   │   │   │       └── SettingsPage.ets # 设置页面
│   │   │   ├── resources/    # 资源文件（字符串、颜色、媒体）
│   │   │   └── module.json5  # 模块配置
│   ├── build-profile.json5   # 模块构建配置
│   └── oh-package.json5      # 模块依赖
├── hvigorfile.ts             # Hvigor构建配置
├── build-profile.json5       # 全局构建配置
├── oh-package.json5          # 项目依赖
```

## 开发环境

- DevEco Studio 4.x
- HarmonyOS SDK API 6.0.2 (22)
- Node.js环境

## 构建和运行

```bash
# 构建调试版本
hvigor buildDebug

# 构建发布版本
hvigor buildRelease
```

在DevEco Studio中点击运行按钮或使用命令：`hvigor deploy`

## API使用说明

应用使用wallhaven.cc的API，主要功能包括：

- 搜索壁纸：`https://wallhaven.cc/api/v1/search`
- 获取壁纸详情：`https://wallhaven.cc/api/v1/w/{id}`

API调用遵循以下限制：
- 每分钟最多45次API调用
- NSFW内容需要有效的API密钥