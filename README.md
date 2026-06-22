# 校园二手好物

HarmonyOS ArkTS 课程大作业项目，主题为“位置感知的校园二手好物推荐与 AI 定价助手”。

核心功能：

- 校园二手商品列表、分类、搜索、下拉刷新、到底提示
- 商品详情、收藏、联系卖家反馈
- 基于高德定位和校园多边形区域的本校商品推荐
- 基于 DeepSeek 的校园二手商品 AI 估价
- AI 估价结合当前学校、商品所属学校、同类商品均价和挂牌价生成建议

## 目录

```text
code/                  HarmonyOS 源码工程
goods_item_images/     商品图片整理结果
docs/                  实施计划和设计过程文档
作业完成指南.md
项目介绍与文件说明.md
```

## API Key

公开仓库中的 `code/entry/src/main/ets/common/ApiConfig.ets` 使用占位 Key。

本地运行真实高德定位和 DeepSeek 估价前，需要把以下字段替换为自己的 Key：

```ts
AMAP_API_KEY
AMAP_WEB_SERVICE_API_KEY
DEEPSEEK_API_KEY
```

不要把真实 Key 提交到公开仓库。
