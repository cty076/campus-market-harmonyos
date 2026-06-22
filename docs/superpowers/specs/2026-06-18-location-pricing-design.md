# 位置感知推荐与 AI 定价功能设计

## 目标

在现有“校园二手好物”HarmonyOS 工程基础上，新增两个聚焦能力：

1. 基于高德地图/定位能力识别用户所在校园区域，并按区域推荐商品。
2. 基于大模型能力为二手商品生成定价建议。

设计原则是保持现有工程架构不变，不重写页面结构，不把业务逻辑塞进页面文件。新增能力通过独立 service、utils、viewmodel 和 view 组件接入，确保代码可读、可维护、可演示。

## 当前架构

当前代码主要分层如下：

- `pages/`：页面入口，例如首页、详情页、收藏页。
- `view/`：可复用 UI 组件，例如商品卡片、列表、搜索栏、Tab。
- `viewmodel/`：商品模型、商品数据源、收藏状态。
- `common/`：颜色、尺寸等公共常量。
- `resources/`：图片、字符串、页面路由等资源。

新增功能继续沿用该分层。页面只持有 UI 状态和调用入口；定位、区域判断、商品过滤、AI 定价全部放在独立模块里。

## 功能一：基于高德 API 的定位推荐

### 用户体验

首页增加一个“位置推荐”模块，位于搜索栏和商品列表之间。

展示内容包括：

- 当前定位状态：定位中、定位成功、定位失败、未授权。
- 当前区域名称：例如“宿舍生活区 A”“教学学习区 B”。
- 推荐理由：例如“你当前在宿舍生活区，优先推荐宿舍用品和数码外设”。
- 操作按钮：重新定位、演示切换 A/B 区。

商品列表根据当前区域自动过滤。用户位于 A 区时展示 A 区商品，位于 B 区时展示 B 区商品。用户未授权或定位失败时，展示默认推荐，并允许通过演示按钮切换区域，保证课堂演示稳定。

### 区域模型

新增 `CampusRegion.ets`，定义校园区域：

- `id`：区域唯一标识，例如 `dormitory`、`study`。
- `name`：区域名称。
- `description`：区域说明。
- `recommendReason`：推荐理由。
- `points`：区域多边形经纬度点。
- `categoryHints`：该区域更适合展示的商品类型。

示例区域：

- A 区：宿舍生活区，推荐生活用品、数码外设、宿舍家具。
- B 区：教学学习区，推荐教材、考研资料、学习工具。

### 区域判断

新增 `GeoUtils.ets`，只负责地理计算：

- 判断一个经纬度点是否落入某个多边形区域。
- 遍历所有区域，返回第一个匹配区域。
- 如果没有匹配区域，返回 `undefined` 或默认区域。

该模块不依赖 UI、不依赖商品数据、不依赖高德 SDK，便于单独测试。

### 定位服务

新增 `LocationService.ets`，封装高德定位：

- 申请或触发单次定位。
- 返回统一的定位结果对象。
- 处理权限失败、定位失败、网络异常。

页面不直接调用高德 SDK。后续如果高德配置、API Key 或定位实现发生变化，只修改该 service。

第一阶段为了保证构建和演示稳定，保留演示定位能力：

- `simulateDormitoryLocation()`
- `simulateStudyLocation()`

真实定位可接入高德 HarmonyOS NEXT 定位 SDK；演示定位用于没有 API Key、没有真机定位权限或课堂录屏时。

### 商品过滤

扩展 `GoodsModel.ets`，新增：

- `regionIds: string[]`

每个商品可以属于一个或多个推荐区域。新增 `RegionGoodsService.ets`：

- 根据区域 id 过滤商品。
- 保留原有分类和搜索能力。
- 区域为空时返回默认商品列表。

商品过滤顺序建议为：

1. 先按区域过滤。
2. 再按分类过滤。
3. 再按关键词过滤。

这样不会破坏现有搜索和分类逻辑。

### UI 接入

新增 `RegionRecommendPanel.ets`，负责展示定位推荐模块。

修改 `Index.ets`：

- 增加当前区域状态。
- 增加定位状态。
- 调用 `LocationService` 获取位置。
- 调用 `GeoUtils` 匹配区域。
- 调用 `RegionGoodsService` 获取商品。
- 渲染 `RegionRecommendPanel`。

`Index.ets` 不实现点在多边形内判断，不直接写高德 SDK 调用，不直接拼接复杂筛选逻辑。

## 功能二：基于大模型的智能定价

### 用户体验

新增“AI 定价助手”页面。入口有两个：

- 商品详情页按钮：`AI 估价`。
- 首页可选入口：`智能定价`。

页面表单字段：

- 商品名称。
- 商品分类。
- 当前成色。
- 原价。
- 使用时长。
- 商品描述。

输出内容：

- 建议成交价。
- 合理价格区间。
- 定价理由。
- 议价建议。
- 风险提示。

### 数据模型

新增 `PricingModel.ets`：

- `PricingRequest`：定价请求。
- `PricingResult`：定价结果。
- `PricingStatus`：加载、成功、失败等状态。

模型只描述数据结构，不包含 HTTP 请求和页面逻辑。

### 定价服务

新增 `PricingService.ets` 作为统一入口：

- 页面只调用 `PricingService.estimate(request)`。
- `PricingService` 决定使用真实大模型还是本地模拟结果。

新增两个 provider：

- `MockPricingProvider.ets`：无 API Key 时生成稳定可演示的本地结果。
- `LlmPricingProvider.ets`：调用真实大模型 API，要求返回 JSON 格式结果。

默认先启用 `MockPricingProvider`，确保工程能构建、能演示、能录视频。真实大模型接口作为可配置增强，不把 API Key 写死在源码里。

### 大模型调用约束

真实接口接入时遵循以下约束：

- API Key 不硬编码在公共源码中。
- 请求 prompt 要求模型返回固定 JSON。
- 对返回结果做兜底解析，解析失败时给出友好错误。
- 网络失败时回退到本地定价或提示用户稍后重试。

### UI 接入

新增 `PricingAssistantPage.ets`：

- 表单输入商品信息。
- 调用 `PricingService`。
- 展示定价结果。
- 从详情页跳转时自动带入当前商品信息。

修改 `DetailPage.ets`：

- 增加 `AI 估价` 按钮。
- 点击后跳转到 `PricingAssistantPage`，携带当前商品 id 或商品基础信息。

详情页不直接调用大模型 API。

## 文件改动范围

新增文件：

- `code/entry/src/main/ets/service/LocationService.ets`
- `code/entry/src/main/ets/service/PricingService.ets`
- `code/entry/src/main/ets/service/MockPricingProvider.ets`
- `code/entry/src/main/ets/service/LlmPricingProvider.ets`
- `code/entry/src/main/ets/utils/GeoUtils.ets`
- `code/entry/src/main/ets/viewmodel/CampusRegion.ets`
- `code/entry/src/main/ets/viewmodel/RegionGoodsService.ets`
- `code/entry/src/main/ets/viewmodel/PricingModel.ets`
- `code/entry/src/main/ets/view/RegionRecommendPanel.ets`
- `code/entry/src/main/ets/pages/PricingAssistantPage.ets`

修改文件：

- `code/entry/src/main/ets/pages/Index.ets`
- `code/entry/src/main/ets/pages/DetailPage.ets`
- `code/entry/src/main/ets/viewmodel/GoodsModel.ets`
- `code/entry/src/main/ets/viewmodel/CampusGoodsData.ets`
- `code/entry/src/main/resources/base/profile/main_pages.json`
- `code/entry/src/main/module.json5`
- `code/entry/oh-package.json5`

如高德 SDK 依赖需要放在工程根包配置中，再同步修改 `code/oh-package.json5`。

## 权限与依赖

定位推荐需要：

- 网络权限。
- 近似位置权限。
- 精确位置权限。

高德真实定位和地图显示需要配置高德 API Key 与相关 SDK 依赖。第一阶段先保留演示定位，避免外部配置阻塞主流程。

AI 定价真实接口需要：

- 网络权限。
- 大模型 API Base URL。
- API Key。
- Model 名称。

默认不强制依赖真实大模型 API，避免因 Key 或网络问题影响项目验收。

## 异常处理

定位异常：

- 未授权：提示开启定位权限，并展示默认推荐。
- 定位失败：提示重新定位，并允许演示切换区域。
- 不在 A/B 区：展示“校内通用推荐”。

AI 定价异常：

- 输入不完整：提示补充商品名称、成色、原价等关键字段。
- 网络失败：显示失败原因，允许重试。
- 大模型返回格式错误：使用兜底提示，不让页面崩溃。

## 验证方式

功能验证：

- 首页默认能正常展示商品。
- 点击演示 A 区后，只展示 A 区商品。
- 点击演示 B 区后，只展示 B 区商品。
- 搜索和分类在区域过滤后仍然可用。
- 商品详情页能跳转到 AI 定价页面。
- AI 定价页面能生成建议价格、价格区间和理由。

工程验证：

- 运行现有校验脚本。
- 使用 hvigor 构建 HAP。
- 检查新增页面已写入 `main_pages.json`。
- 检查权限配置不破坏现有启动流程。

## 实施顺序

第一阶段：

1. 新增区域模型和地理判断工具。
2. 扩展商品模型和商品数据。
3. 首页接入区域推荐面板。
4. 实现演示 A/B 区域切换。
5. 新增 AI 定价模型、Mock 定价服务和定价页面。
6. 详情页接入 AI 估价入口。
7. 构建验证。

第二阶段：

1. 接入高德真实定位 SDK。
2. 配置定位权限和 API Key。
3. 接入真实大模型 API。
4. 完善报告和演示视频脚本。

## 设计自检

- 没有改变现有 pages/view/viewmodel/common 的基本架构。
- 页面只做展示和状态管理，核心业务逻辑进入独立模块。
- 外部 API 均通过 service 封装，便于替换和降级。
- 第一阶段不依赖真实 API Key，能稳定演示。
- 功能聚焦在“位置感知推荐”和“智能定价”，没有扩展成大而杂的商城系统。
