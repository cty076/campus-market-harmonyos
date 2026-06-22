# Campus Location AI Pricing Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 将现有“高德定位推荐”和“DeepSeek AI 估价”升级为一条完整的校园交易圈闭环：定位识别学校、推荐本校商品、详情页解释交易匹配度、AI 结合校园市场上下文给出估价。

**Architecture:** 保持现有 MVVM 分层不变：`pages` 和 `view` 只负责页面展示与事件分发，`viewmodel` 只负责模型与数据结构，`service` 负责外部 API 与业务上下文计算，`utils` 保持纯算法工具。新增估价上下文服务，不把定位逻辑、商品统计和 Prompt 拼接塞进页面。

**Tech Stack:** HarmonyOS NEXT, ArkTS, ArkUI, 高德 Web 服务坐标转换, DeepSeek Chat Completions, 现有 `verify-campus-market.mjs` 结构校验脚本。

---

## File Structure

**Create**
- `code/entry/src/main/ets/viewmodel/PricingContextModel.ets`  
  定义 AI 估价所需的本地市场上下文模型，包括同类商品数量、均价、最低价、最高价、当前定位学校、商品所属学校和交易匹配文案。

- `code/entry/src/main/ets/service/PricingContextService.ets`  
  从 `campusGoodsList` 中计算同类商品参考价格，生成 `PricingContext`。该服务不调用 DeepSeek，只做本地数据统计。

**Modify**
- `code/entry/src/main/ets/viewmodel/CampusRegion.ets`  
  给区域模型增加短名称、交易建议、未定位提示等展示字段，避免页面硬编码文案。

- `code/entry/src/main/ets/viewmodel/RegionGoodsService.ets`  
  增加区域推荐摘要方法，例如商品数量、当前区域名称、推荐解释。仍然只处理商品和区域数据。

- `code/entry/src/main/ets/viewmodel/PricingModel.ets`  
  扩展 `PricingRequest` 和 `PricingResult`，支持校园市场上下文、估价可信度、同类参考、议价策略。

- `code/entry/src/main/ets/service/PricingService.ets`  
  保留输入校验职责，调用 `PricingContextService` 生成上下文，再交给 `LlmPricingProvider`。

- `code/entry/src/main/ets/service/LlmPricingProvider.ets`  
  更新 Prompt 和 JSON 解析，要求 DeepSeek 返回严格 JSON，字段包含 `suggestedPrice`、`priceRange`、`confidence`、`marketReference`、`reason`、`bargainAdvice`、`riskTip`。

- `code/entry/src/main/ets/view/RegionRecommendPanel.ets`  
  展示当前学校、区域推荐摘要、定位状态，并增加“全部 / 北京工业大学 / 北京大学”手动切换按钮。

- `code/entry/src/main/ets/pages/Index.ets`  
  管理当前区域状态，处理自动定位和手动切换，把当前区域传给列表。

- `code/entry/src/main/ets/view/CampusTabBar.ets`  
  把 `regionId` 继续传给 `GoodsListComponent`。

- `code/entry/src/main/ets/view/GoodsListComponent.ets`  
  把 `currentRegionId` 传给 `GoodsCardComponent`。

- `code/entry/src/main/ets/view/GoodsCardComponent.ets`  
  跳转详情页时传入 `currentRegionId`。

- `code/entry/src/main/ets/pages/DetailPage.ets`  
  展示“当前位置与商品所属学校是否匹配”的交易建议，并把当前区域传给 AI 估价页。

- `code/entry/src/main/ets/pages/PricingAssistantPage.ets`  
  自动带入商品、当前学校、商品所属学校和挂牌价；展示可信度、同类参考、议价策略。

- `code/scripts/verify-campus-market.mjs`  
  增加对新增模型、服务和关键字段的结构检查。

---

## Task 1: Extend Region Model Without Changing Location Service

**Files:**
- Modify: `code/entry/src/main/ets/viewmodel/CampusRegion.ets`
- Modify: `code/entry/src/main/ets/viewmodel/RegionGoodsService.ets`

- [ ] **Step 1: Extend `CampusRegion` fields**

Update the constructor and class fields to include:

```ts
shortName: string;
tradeAdvice: string;
fallbackAdvice: string;
```

For `bjut`, set:

```ts
shortName: '北京工业大学',
tradeAdvice: '当前位于北京工业大学交易圈，优先展示适合同校当面交易的商品。',
fallbackAdvice: '可在北工大校内约定教学楼、宿舍区或图书馆附近验货交易。'
```

For `pku`, set:

```ts
shortName: '北京大学',
tradeAdvice: '当前位于北京大学交易圈，优先展示适合同校当面交易的商品。',
fallbackAdvice: '可在北大校内约定宿舍区、教学楼或图书馆附近验货交易。'
```

For `defaultRegion`, set:

```ts
shortName: '全部',
tradeAdvice: '当前未匹配到已划定校园区域，展示全部校园二手商品。',
fallbackAdvice: '可以手动选择学校，也可以重新定位后获取本校推荐。'
```

- [ ] **Step 2: Keep `getRegionNameById` simple**

Change `getRegionNameById(regionId)` to return `matchedRegion.shortName` when found, otherwise `defaultRegion.shortName`。不要再通过字符串 replace 去清理区域名称。

- [ ] **Step 3: Add region summary model in `RegionGoodsService.ets`**

Add a class:

```ts
export class RegionRecommendSummary {
  regionId: string;
  regionName: string;
  goodsCount: number;
  reason: string;
  tradeAdvice: string;

  constructor(regionId: string, regionName: string, goodsCount: number, reason: string, tradeAdvice: string) {
    this.regionId = regionId;
    this.regionName = regionName;
    this.goodsCount = goodsCount;
    this.reason = reason;
    this.tradeAdvice = tradeAdvice;
  }
}
```

- [ ] **Step 4: Add summary method**

Add:

```ts
static buildSummary(goodsList: GoodsModel[], region: CampusRegion): RegionRecommendSummary {
  const matchedCount = region.id === 'all'
    ? goodsList.length
    : goodsList.filter((item: GoodsModel) => item.regionIds.includes(region.id)).length;
  return new RegionRecommendSummary(
    region.id,
    region.shortName,
    matchedCount,
    region.tradeAdvice,
    region.fallbackAdvice
  );
}
```

- [ ] **Step 5: Verify compile-level references**

Run:

```powershell
cd D:\mobile_app\final_work_wzq\code
node scripts/verify-campus-market.mjs
```

Expected after this task may still fail because the verify script has not been updated for new fields. There must be no ArkTS syntax errors introduced in edited files.

---

## Task 2: Thread Current Region Through List To Detail

**Files:**
- Modify: `code/entry/src/main/ets/view/CampusTabBar.ets`
- Modify: `code/entry/src/main/ets/view/GoodsListComponent.ets`
- Modify: `code/entry/src/main/ets/view/GoodsCardComponent.ets`
- Modify: `code/entry/src/main/ets/pages/DetailPage.ets`

- [ ] **Step 1: Add prop to `GoodsListComponent`**

Add:

```ts
currentRegionId: string = 'all';
```

Pass it into cards:

```ts
GoodsCardComponent({ goods: item, currentRegionId: this.currentRegionId })
```

- [ ] **Step 2: Pass region from `CampusTabBar`**

Change the list call to:

```ts
GoodsListComponent({
  dataSource: this.dataSource,
  currentRegionId: this.regionId,
  onLoadMore: () => {
    this.dataSource.loadMore();
  }
})
```

- [ ] **Step 3: Add prop to `GoodsCardComponent`**

Add:

```ts
currentRegionId: string = 'all';
```

Change router params:

```ts
params: {
  goodsId: this.goods.id,
  currentRegionId: this.currentRegionId
}
```

- [ ] **Step 4: Read current region in `DetailPage`**

Add state:

```ts
@State currentRegionId: string = 'all';
```

Inside `aboutToAppear`, after reading params:

```ts
this.currentRegionId = params.currentRegionId === undefined ? 'all' : params.currentRegionId;
```

- [ ] **Step 5: Add transaction match helper in `DetailPage`**

Add methods:

```ts
private isSameCampusGoods(goods: GoodsModel): boolean {
  return this.currentRegionId !== 'all' && goods.regionIds.includes(this.currentRegionId);
}

private tradeMatchText(goods: GoodsModel): string {
  if (this.currentRegionId === 'all') {
    return '定位后可判断该商品是否适合同校当面交易。';
  }
  if (this.isSameCampusGoods(goods)) {
    return '该商品与你当前校园一致，适合校内当面验货交易。';
  }
  return '该商品属于其他校园，建议提前沟通交易地点和取货时间。';
}
```

---

## Task 3: Upgrade Region Panel With Manual School Switch

**Files:**
- Modify: `code/entry/src/main/ets/view/RegionRecommendPanel.ets`
- Modify: `code/entry/src/main/ets/pages/Index.ets`

- [ ] **Step 1: Add props to panel**

In `RegionRecommendPanel`, add:

```ts
@Prop goodsCount: number = 0;
@Prop selectedRegionId: string = 'all';
onSelectRegion: (regionId: string) => void = (_regionId: string) => {};
```

- [ ] **Step 2: Add manual options builder**

Add a small button builder:

```ts
@Builder
RegionOption(label: string, regionId: string) {
  Text(label)
    .fontSize(12)
    .fontColor(this.selectedRegionId === regionId ? Color.White : PRIMARY_COLOR)
    .padding({ left: 10, right: 10, top: 6, bottom: 6 })
    .backgroundColor(this.selectedRegionId === regionId ? PRIMARY_COLOR : '#EAF3FF')
    .borderRadius(6)
    .onClick(() => {
      this.onSelectRegion(regionId);
    })
}
```

- [ ] **Step 3: Display recommendation count**

In the panel body, show:

```ts
Text(`当前推荐 ${this.goodsCount} 件商品`)
  .fontSize(13)
  .fontColor(TEXT_SECONDARY)
  .margin({ top: 8 })
```

- [ ] **Step 4: Add option row**

Add:

```ts
Row() {
  this.RegionOption('全部', 'all')
  this.RegionOption('北京工业大学', 'bjut')
  this.RegionOption('北京大学', 'pku')
}
.width(FULL_SIZE)
.margin({ top: 12 })
```

- [ ] **Step 5: Add summary state in `Index.ets`**

Import `campusGoodsList`, `RegionGoodsService`, and `RegionRecommendSummary`。Add:

```ts
@State recommendGoodsCount: number = 0;
```

Add method:

```ts
private updateRegionSummary(): void {
  this.recommendGoodsCount = this.regionId === 'all'
    ? campusGoodsList.length
    : campusGoodsList.filter((item: GoodsModel) => item.regionIds.includes(this.regionId)).length;
}
```

- [ ] **Step 6: Call summary updates**

Call `this.updateRegionSummary()` in:

```ts
aboutToAppear()
applyLocation(result)
applyManualRegion(regionId)
```

Add:

```ts
private applyManualRegion(regionId: string): void {
  const matchedRegion = campusRegions.find((region: CampusRegion) => region.id === regionId);
  this.currentRegion = matchedRegion === undefined ? defaultRegion : matchedRegion;
  this.regionId = this.currentRegion.id;
  this.locationStatus = LocationStatus.SUCCESS;
  this.locationMessage = regionId === 'all' ? '已手动切换为全部商品' : `已手动切换为${this.currentRegion.shortName}`;
  this.updateRegionSummary();
}
```

---

## Task 4: Add Pricing Context Model And Local Market Statistics

**Files:**
- Create: `code/entry/src/main/ets/viewmodel/PricingContextModel.ets`
- Create: `code/entry/src/main/ets/service/PricingContextService.ets`

- [ ] **Step 1: Create `PricingContextModel.ets`**

Create:

```ts
export class PricingContext {
  currentRegionId: string;
  currentRegionName: string;
  goodsRegionNames: string;
  sameCategoryCount: number;
  sameCampusCategoryCount: number;
  sameCategoryAveragePrice: number;
  sameCategoryMinPrice: number;
  sameCategoryMaxPrice: number;
  tradeMatchText: string;

  constructor(
    currentRegionId: string,
    currentRegionName: string,
    goodsRegionNames: string,
    sameCategoryCount: number,
    sameCampusCategoryCount: number,
    sameCategoryAveragePrice: number,
    sameCategoryMinPrice: number,
    sameCategoryMaxPrice: number,
    tradeMatchText: string
  ) {
    this.currentRegionId = currentRegionId;
    this.currentRegionName = currentRegionName;
    this.goodsRegionNames = goodsRegionNames;
    this.sameCategoryCount = sameCategoryCount;
    this.sameCampusCategoryCount = sameCampusCategoryCount;
    this.sameCategoryAveragePrice = sameCategoryAveragePrice;
    this.sameCategoryMinPrice = sameCategoryMinPrice;
    this.sameCategoryMaxPrice = sameCategoryMaxPrice;
    this.tradeMatchText = tradeMatchText;
  }
}
```

- [ ] **Step 2: Create `PricingContextService.ets`**

Implement these helpers:

```ts
private static parsePrice(priceText: string): number {
  const normalized = priceText.replace('¥', '').replace('￥', '').replace('楼', '').trim();
  const value = Number(normalized);
  return Number.isNaN(value) ? 0 : value;
}
```

```ts
static buildContext(category: string, currentRegionId: string, goodsRegionIds: string[]): PricingContext
```

The method must:
- filter `campusGoodsList` by `item.category === category`
- convert prices with `parsePrice`
- ignore zero prices
- calculate count, min, max, average
- calculate same-campus count when `currentRegionId !== 'all'`
- use `getRegionNameById` and `formatRegionNames`
- generate `tradeMatchText` with same logic as `DetailPage`

---

## Task 5: Extend Pricing Request And Result

**Files:**
- Modify: `code/entry/src/main/ets/viewmodel/PricingModel.ets`

- [ ] **Step 1: Import context**

Add:

```ts
import { PricingContext } from './PricingContextModel';
```

- [ ] **Step 2: Extend `PricingRequest`**

Add fields:

```ts
listedPrice: number;
currentRegionId: string;
goodsRegionIds: string[];
context: PricingContext | undefined;
```

Update constructor parameters in this order:

```ts
title,
category,
condition,
originalPrice,
usageMonths,
description,
listedPrice = 0,
currentRegionId = 'all',
goodsRegionIds = [],
context = undefined
```

- [ ] **Step 3: Extend `PricingResult`**

Add fields:

```ts
confidence: string;
marketReference: string;
```

Update constructor to accept:

```ts
success,
suggestedPrice,
priceRange,
confidence,
marketReference,
reason,
bargainAdvice,
riskTip
```

Then update every `new PricingResult(...)` call in `PricingService.ets`, `LlmPricingProvider.ets`, and `PricingAssistantPage.ets`.

---

## Task 6: Build Context Before Calling DeepSeek

**Files:**
- Modify: `code/entry/src/main/ets/service/PricingService.ets`
- Modify: `code/entry/src/main/ets/service/LlmPricingProvider.ets`

- [ ] **Step 1: Build context in `PricingService.ets`**

Import `PricingContextService` and before calling DeepSeek:

```ts
request.context = PricingContextService.buildContext(
  request.category,
  request.currentRegionId,
  request.goodsRegionIds
);
```

- [ ] **Step 2: Keep validation strict**

If title is empty or original price is invalid, return a failed `PricingResult` with:

```ts
confidence: '-'
marketReference: '-'
reason: '商品名称和原价是生成定价建议的必要信息。'
bargainAdvice: '请补充商品名称，并填写大于 0 的原价后重试。'
riskTip: '输入信息不足时，不建议直接给出价格。'
```

- [ ] **Step 3: Update Prompt in `LlmPricingProvider.ets`**

Prompt must explicitly include:

```text
当前定位学校
商品所属学校
当前挂牌价
同类商品数量
同校同类商品数量
同类商品均价
同类商品最低价
同类商品最高价
交易匹配提示
```

Require JSON fields:

```text
suggestedPrice, priceRange, confidence, marketReference, reason, bargainAdvice, riskTip
```

- [ ] **Step 4: Update JSON parser**

Extend `PricingJson` with:

```ts
confidence?: Object | string | number;
marketReference?: Object | string | number;
```

Return:

```ts
new PricingResult(
  true,
  normalizePricingText(parsed.suggestedPrice, '-'),
  normalizePricingText(parsed.priceRange, '-'),
  normalizePricingText(parsed.confidence, '中'),
  normalizePricingText(parsed.marketReference, '已结合本地同类商品价格进行参考。'),
  normalizePricingText(parsed.reason, 'DeepSeek 已返回定价建议，但理由字段为空。'),
  normalizePricingText(parsed.bargainAdvice, '建议结合校内同类商品价格进行议价。'),
  normalizePricingText(parsed.riskTip, 'AI 定价仅作参考，最终成交价以买卖双方沟通为准。')
)
```

---

## Task 7: Upgrade Detail And Pricing Pages

**Files:**
- Modify: `code/entry/src/main/ets/pages/DetailPage.ets`
- Modify: `code/entry/src/main/ets/pages/PricingAssistantPage.ets`

- [ ] **Step 1: Add transaction match panel in detail page**

Below the existing school row, add a small text block:

```ts
Text(this.tradeMatchText(goods))
  .fontSize(13)
  .fontColor(this.isSameCampusGoods(goods) ? SUCCESS_COLOR : TEXT_MUTED)
  .lineHeight(20)
  .margin({ top: 8 })
```

- [ ] **Step 2: Pass richer params to pricing page**

In `openPricingAssistant`, pass:

```ts
currentRegionId: this.currentRegionId,
goodsRegionIds: this.goods.regionIds.join(','),
listedPrice: this.goods.price
```

- [ ] **Step 3: Read params in pricing page**

Add states:

```ts
@State listedPriceValue: string = '';
@State currentRegionId: string = 'all';
@State goodsRegionIdsValue: string = '';
```

In `aboutToAppear`, read `listedPrice`, `currentRegionId`, and `goodsRegionIds`。

- [ ] **Step 4: Build richer request**

In `estimate`, create:

```ts
const listedPrice = Number(this.listedPriceValue.replace('¥', '').replace('￥', '').replace('楼', ''));
const request = new PricingRequest(
  this.titleValue,
  this.categoryValue,
  this.conditionValue,
  Number.isNaN(originalPrice) ? 0 : originalPrice,
  Number.isNaN(usageMonths) ? 0 : usageMonths,
  this.descriptionValue,
  Number.isNaN(listedPrice) ? 0 : listedPrice,
  this.currentRegionId,
  this.goodsRegionIdsValue.length === 0 ? [] : this.goodsRegionIdsValue.split(',')
);
```

- [ ] **Step 5: Display new result fields**

In `ResultPanel`, show:

```ts
Text('可信度：' + result.confidence)
Text('同类参考：' + result.marketReference)
```

Keep existing suggested price, price range, reason, bargain advice, and risk tip.

---

## Task 8: Verification Script And Build Check

**Files:**
- Modify: `code/scripts/verify-campus-market.mjs`

- [ ] **Step 1: Add required files**

Add:

```js
'entry/src/main/ets/viewmodel/PricingContextModel.ets',
'entry/src/main/ets/service/PricingContextService.ets',
```

- [ ] **Step 2: Add required text checks**

Add checks for:

```js
['entry/src/main/ets/viewmodel/PricingContextModel.ets', 'sameCategoryAveragePrice'],
['entry/src/main/ets/service/PricingContextService.ets', 'buildContext'],
['entry/src/main/ets/viewmodel/PricingModel.ets', 'confidence'],
['entry/src/main/ets/viewmodel/PricingModel.ets', 'marketReference'],
['entry/src/main/ets/service/LlmPricingProvider.ets', 'marketReference'],
['entry/src/main/ets/view/RegionRecommendPanel.ets', 'onSelectRegion'],
['entry/src/main/ets/pages/DetailPage.ets', 'tradeMatchText'],
['entry/src/main/ets/pages/PricingAssistantPage.ets', 'currentRegionId'],
```

- [ ] **Step 3: Run structure verification**

Run:

```powershell
cd D:\mobile_app\final_work_wzq\code
node scripts/verify-campus-market.mjs
```

Expected:

```text
CampusMarket verification passed.
```

- [ ] **Step 4: Run Hvigor build**

Run:

```powershell
cd D:\mobile_app\final_work_wzq\code
$env:DEVECO_SDK_HOME='D:\software\deveco\DevEco Studio\sdk'
& 'D:\software\deveco\DevEco Studio\tools\node\node.exe' 'D:\software\deveco\DevEco Studio\tools\hvigor\bin\hvigorw.js' --mode module -p module=entry@default -p product=default assembleHap --no-daemon
```

Expected: command exits with code `0` and generates HAP under:

```text
entry/build/default/outputs/default/
```

---

## Task 9: Manual Demo Checklist

**Files:**
- No code files. This validates behavior on emulator or device.

- [ ] **Step 1: Homepage default state**

Open app. Expected:
- title remains “校园二手好物”
- location card shows all/default recommendation
- product list appears
- search, tabs, pull refresh, reach end still work

- [ ] **Step 2: Manual Beijing University of Technology switch**

Tap “北京工业大学”. Expected:
- location card shows Beijing University of Technology
- list only shows `bjut` goods
- categories still include all product categories

- [ ] **Step 3: Manual Peking University switch**

Tap “北京大学”. Expected:
- location card shows Peking University
- list only shows `pku` goods
- categories still include all product categories

- [ ] **Step 4: Detail page match message**

Open a same-school product. Expected:
- detail page shows school ownership
- trade match message says it is suitable for same-school in-person trading

Open a cross-school product after switching region manually. Expected:
- trade match message warns that the trading location should be discussed

- [ ] **Step 5: AI pricing page**

Open “AI 估价” from detail. Expected:
- title/category/condition/description/listed price/current region are carried over
- entering original price and usage months can call DeepSeek
- result displays suggested price, range, confidence, same-category reference, reason, bargain advice, risk tip

---

## Self-Review

- Spec coverage: The plan covers location recommendation, manual fallback, detail trade matching, AI context pricing, DeepSeek JSON output, and verification.
- MVVM boundary check: UI files only display and route events; region matching remains in `GeoUtils`; location remains in `LocationService`; pricing context is isolated in `PricingContextService`; LLM calls remain in `LlmPricingProvider`.
- Scope check: No login, publishing, order, payment, chat, or map SDK rendering is included.
- Risk notes: Existing source files display mojibake in terminal because of encoding, so edits must preserve the project’s actual file encoding and verify in DevEco/ArkTS build. API keys are already hardcoded in `ApiConfig.ets`; this plan does not change secret handling.
