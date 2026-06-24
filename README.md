# 校园二手好物

HarmonyOS ArkTS 项目，主题为“位置感知的校园二手好物推荐与 AI 定价助手”。项目聚焦校园二手交易中的一个精细功能链路：根据用户当前位置识别所在校园区域，优先展示适合同校当面交易的商品，并在商品详情中结合市场数据和大模型能力给出估价建议。

## 核心功能

- 校园二手商品列表、分类 Tabs、关键词搜索、下拉刷新、到底提示
- 商品详情、商品所属学校展示、同校/跨校/区域外交易提示
- 收藏页和商品收藏状态切换
- 基于高德 Web API 的当前位置获取与高德坐标转换
- 基于校园多边形区域的学校识别，当前支持北京工业大学、北京大学、北京理工大学
- 基于 DeepSeek 的 AI 估价助手，结合挂牌价、同类均价、学校位置和交易适配性生成建议
- 33 个商品均已配置 256x256 专属商品图片，减少占位图重复感

## 目录结构

```text
code/                  HarmonyOS ArkTS 源码工程
goods_item_images/     商品图片整理结果，包含 goods-001.png 到 goods-033.png
```

## 运行与验证

结构校验脚本：

```powershell
cd D:\mobile_app\final_work_wzq\code
node scripts\verify-campus-market.mjs
```

预期输出：

```text
CampusMarket verification passed.
```

DevEco Studio 中打开 `code/` 目录即可构建和运行。若使用命令行构建，需要根据本机 DevEco Studio 安装路径配置 SDK 和 Hvigor。

## API 配置

运行定位和 AI 估价前，需要在 `code/entry/src/main/ets/common/ApiConfig.ets` 中配置：

```ts
AMAP_API_KEY
AMAP_WEB_SERVICE_API_KEY
DEEPSEEK_API_KEY
```
