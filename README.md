# 九曲拾忆

九曲拾忆是一款面向 HarmonyOS / OpenHarmony 的黄河文化数字档案应用，也是第三届开源鸿蒙大赛参赛作品。项目以河南段黄河文化为主线，将遗址、考古、博物馆、诗词与旅行线索整理为可浏览、可收藏、可关联的个人文化记忆库。

## 项目亮点

- **文化数字档案**：按时代、地点和主题浏览黄河沿线文化遗存。
- **地图与时间线**：通过河南段黄河文化地图和朝代序列建立空间、时间双重索引。
- **个人记忆库**：收藏档案、记录笔记，并自动归纳主题与文化关联。
- **河小忆 AI 助手**：围绕遗址、考古、历史人物、诗词和民俗提供文化讲解。
- **跨设备同步**：支持通过兼容的同步节点同步收藏、笔记、备份和知识图谱。
- **离线优先**：核心档案与个人收藏保存在本地，网络不可用时仍可浏览和编辑。

## 技术栈

- ArkTS / ArkUI
- HarmonyOS / OpenHarmony SDK
- Preferences 本地持久化
- HTTP + WebSocket 实时同步
- 本地化资源与自定义文化视觉素材

## 目录结构

```text
AppScope/                         应用级配置与图标
entry/src/main/ets/pages/         首页、档案、地图、收藏、AI、同步等页面
entry/src/main/ets/components/    公共 UI 组件
entry/src/main/ets/data/          档案与地点数据
entry/src/main/ets/services/      本地存储、AI、同步服务
entry/src/main/resources/         图片、字体、地图与页面资源
docs/                             第三方素材说明
design/                           作品设计方案与设计展示文档
```

说明：`entry/src/main/resources/rawfile/henan_yellow_river_basin.html` 是应用内置的地图资源，不是本项目的网页主体；项目主体是 `entry/src/main/ets/` 下的 ArkTS/ArkUI 工程源码。

## 构建与运行

1. 使用 DevEco Studio 打开项目目录。
2. 安装对应版本的 HarmonyOS / OpenHarmony SDK 与依赖。
3. 在设备或模拟器上选择 `entry` 模块运行。

也可以根据本机环境执行项目内的 `build.bat`、`build.sh` 或 `build-mac.sh`。

## 同步配置

公开仓库不包含真实同步网关、同步令牌、AI API Key、签名私密材料或 HAP 构建产物。使用前请把 `SyncConfig.ets`、`CloudSyncService.ets`、`SyncPage.ets` 和 `network_config.json` 中的 `your-sync-server.example.com:8080` 替换成自己的同步服务地址，并在设备端填写自己的令牌；AI 能力应通过服务端代理提供凭据。`build-profile.json5` 是本地签名配置，仓库只提供 [`build-profile.example.json5`](build-profile.example.json5)。

## 素材与许可

第三方图片、字体和其他素材说明见 [`docs/THIRD_PARTY_ASSETS.md`](docs/THIRD_PARTY_ASSETS.md)。

## 参赛说明

本项目用于展示黄河文化数字化表达、个人知识沉淀与 OpenHarmony 多设备协同能力。欢迎围绕内容准确性、无障碍体验、数据同步和文化传播提出改进建议。
