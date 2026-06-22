# Location Pricing Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add campus region-aware goods recommendation and AI-style second-hand pricing while preserving the existing HarmonyOS project structure.

**Architecture:** Keep `pages/`, `view/`, `viewmodel/`, and `common/` as the visible app structure. Add small `service/` and `utils/` modules so pages do not contain map, location, geo, or LLM business logic.

**Tech Stack:** HarmonyOS ArkTS, local mock services for stable demo, Node.js verification script, hvigor HAP build.

---

## File Structure

- Create `code/entry/src/main/ets/viewmodel/CampusRegion.ets`: region and location data models plus A/B region seed data.
- Create `code/entry/src/main/ets/utils/GeoUtils.ets`: pure point-in-polygon and region matching helpers.
- Create `code/entry/src/main/ets/service/LocationService.ets`: simulated location service and placeholder boundary for future AMap SDK integration.
- Create `code/entry/src/main/ets/viewmodel/RegionGoodsService.ets`: combines region, category, and keyword filtering.
- Create `code/entry/src/main/ets/view/RegionRecommendPanel.ets`: region recommendation UI component.
- Create `code/entry/src/main/ets/viewmodel/PricingModel.ets`: pricing request/result models.
- Create `code/entry/src/main/ets/service/MockPricingProvider.ets`: deterministic local AI-pricing style result.
- Create `code/entry/src/main/ets/service/LlmPricingProvider.ets`: future real model API boundary.
- Create `code/entry/src/main/ets/service/PricingService.ets`: single pricing entry point.
- Create `code/entry/src/main/ets/pages/PricingAssistantPage.ets`: pricing form/result page.
- Modify `code/entry/src/main/ets/viewmodel/GoodsModel.ets`: add `regionIds` while preserving existing matching behavior.
- Modify `code/entry/src/main/ets/viewmodel/CampusGoodsData.ets`: assign goods to regions and expose region-aware filtering.
- Modify `code/entry/src/main/ets/pages/Index.ets`: add recommendation panel and use region-aware filtering.
- Modify `code/entry/src/main/ets/pages/DetailPage.ets`: add AI pricing entry.
- Modify `code/entry/src/main/resources/base/profile/main_pages.json`: register pricing page.
- Modify `code/entry/src/main/module.json5`: add network and location permissions.
- Modify `code/scripts/verify-campus-market.mjs`: add verification for new files and core source patterns.

## Task 1: Verification Coverage

**Files:**
- Modify: `code/scripts/verify-campus-market.mjs`

- [ ] **Step 1: Add failing checks for new architecture**

Add required file checks for:

```js
[
  'entry/src/main/ets/viewmodel/CampusRegion.ets',
  'entry/src/main/ets/utils/GeoUtils.ets',
  'entry/src/main/ets/service/LocationService.ets',
  'entry/src/main/ets/viewmodel/RegionGoodsService.ets',
  'entry/src/main/ets/view/RegionRecommendPanel.ets',
  'entry/src/main/ets/viewmodel/PricingModel.ets',
  'entry/src/main/ets/service/MockPricingProvider.ets',
  'entry/src/main/ets/service/LlmPricingProvider.ets',
  'entry/src/main/ets/service/PricingService.ets',
  'entry/src/main/ets/pages/PricingAssistantPage.ets'
]
```

Add source-pattern checks for:

```js
assertContains('entry/src/main/ets/utils/GeoUtils.ets', 'pointInPolygon');
assertContains('entry/src/main/ets/viewmodel/GoodsModel.ets', 'regionIds');
assertContains('entry/src/main/ets/pages/Index.ets', 'RegionRecommendPanel');
assertContains('entry/src/main/ets/pages/DetailPage.ets', 'PricingAssistantPage');
assertContains('entry/src/main/resources/base/profile/main_pages.json', 'pages/PricingAssistantPage');
```

- [ ] **Step 2: Run verification and expect failure**

Run:

```powershell
node scripts/verify-campus-market.mjs
```

Expected: failure because the new files do not exist yet.

- [ ] **Step 3: Keep the failing verification for implementation**

Do not weaken checks. Continue to Task 2 and make them pass with real code.

## Task 2: Region Data and Geo Utilities

**Files:**
- Create: `code/entry/src/main/ets/viewmodel/CampusRegion.ets`
- Create: `code/entry/src/main/ets/utils/GeoUtils.ets`

- [ ] **Step 1: Implement region model and seed regions**

Create `CampusRegion.ets` with `GeoPoint`, `CampusRegion`, `LocationStatus`, `LocationResult`, and `campusRegions`.

- [ ] **Step 2: Implement geo helpers**

Create `GeoUtils.ets` with:

```ts
pointInPolygon(point: GeoPoint, polygon: GeoPoint[]): boolean
findRegionByPoint(point: GeoPoint, regions: CampusRegion[]): CampusRegion | undefined
```

- [ ] **Step 3: Run verification**

Run:

```powershell
node scripts/verify-campus-market.mjs
```

Expected: still fails because other feature files are missing.

## Task 3: Goods Region Filtering

**Files:**
- Modify: `code/entry/src/main/ets/viewmodel/GoodsModel.ets`
- Modify: `code/entry/src/main/ets/viewmodel/CampusGoodsData.ets`
- Create: `code/entry/src/main/ets/viewmodel/RegionGoodsService.ets`

- [ ] **Step 1: Extend GoodsModel**

Add `regionIds: string[]` to the constructor after `tags`, defaulting to an empty array when omitted.

- [ ] **Step 2: Assign region IDs to goods data**

Assign examples:

```ts
['study']      // textbooks, exam materials
['dormitory']  // desk lamp, storage box, table, earphone, keyboard
['sports']     // basketball, badminton
```

- [ ] **Step 3: Add RegionGoodsService**

Create a small service with:

```ts
filterGoodsForRegion(goodsList, regionId, keyword, category)
```

It should preserve the existing `GoodsModel.matches(keyword, category)` behavior.

- [ ] **Step 4: Run verification**

Run:

```powershell
node scripts/verify-campus-market.mjs
```

Expected: still fails until UI, pricing, and routes exist.

## Task 4: Location Service and Region Recommendation UI

**Files:**
- Create: `code/entry/src/main/ets/service/LocationService.ets`
- Create: `code/entry/src/main/ets/view/RegionRecommendPanel.ets`
- Modify: `code/entry/src/main/ets/pages/Index.ets`

- [ ] **Step 1: Add LocationService**

Expose:

```ts
getCurrentLocation(): Promise<LocationResult>
simulateDormitoryLocation(): LocationResult
simulateStudyLocation(): LocationResult
simulateSportsLocation(): LocationResult
```

The first implementation returns a stable simulated dormitory point and includes comments marking the future AMap SDK boundary.

- [ ] **Step 2: Add RegionRecommendPanel**

Build a compact panel that displays current status, region name, recommendation reason, and buttons for locate/A/B/sports.

- [ ] **Step 3: Update Index**

Add state for current region/status. Use `RegionGoodsService` for filtered goods and pass callbacks into `RegionRecommendPanel`.

- [ ] **Step 4: Run verification**

Run:

```powershell
node scripts/verify-campus-market.mjs
```

Expected: still fails until pricing files/routes exist.

## Task 5: AI Pricing Models and Services

**Files:**
- Create: `code/entry/src/main/ets/viewmodel/PricingModel.ets`
- Create: `code/entry/src/main/ets/service/MockPricingProvider.ets`
- Create: `code/entry/src/main/ets/service/LlmPricingProvider.ets`
- Create: `code/entry/src/main/ets/service/PricingService.ets`

- [ ] **Step 1: Add PricingModel**

Define `PricingRequest` and `PricingResult`.

- [ ] **Step 2: Add MockPricingProvider**

Implement deterministic pricing based on original price and condition:

```ts
八成新 -> 0.62
九成新 -> 0.72
七成新 -> 0.52
default -> 0.6
```

- [ ] **Step 3: Add LlmPricingProvider**

Create a future integration boundary that returns a clear failure result when API config is absent.

- [ ] **Step 4: Add PricingService**

Use mock provider by default.

- [ ] **Step 5: Run verification**

Run:

```powershell
node scripts/verify-campus-market.mjs
```

Expected: still fails until page/route/detail entry exist.

## Task 6: Pricing Page and Detail Entry

**Files:**
- Create: `code/entry/src/main/ets/pages/PricingAssistantPage.ets`
- Modify: `code/entry/src/main/ets/pages/DetailPage.ets`
- Modify: `code/entry/src/main/resources/base/profile/main_pages.json`

- [ ] **Step 1: Add PricingAssistantPage**

Build a form for title, category, condition, original price, usage months, and description. On submit, call `PricingService.estimate`.

- [ ] **Step 2: Add detail page AI estimate entry**

Add a third action button or compact button that routes to:

```ts
url: 'pages/PricingAssistantPage'
```

Pass current goods fields as params.

- [ ] **Step 3: Register route**

Add `pages/PricingAssistantPage` to `main_pages.json`.

- [ ] **Step 4: Run verification**

Run:

```powershell
node scripts/verify-campus-market.mjs
```

Expected: pass.

## Task 7: Permissions and Build

**Files:**
- Modify: `code/entry/src/main/module.json5`

- [ ] **Step 1: Add permissions**

Add `ohos.permission.INTERNET`, `ohos.permission.APPROXIMATELY_LOCATION`, and `ohos.permission.LOCATION` with a location reason string if required by the schema.

- [ ] **Step 2: Build HAP**

Run:

```powershell
$env:DEVECO_SDK_HOME='D:\software\deveco\DevEco Studio\sdk'
& 'D:\software\deveco\DevEco Studio\tools\node\node.exe' 'D:\software\deveco\DevEco Studio\tools\hvigor\bin\hvigorw.js' --mode module -p module=entry@default -p product=default assembleHap --no-daemon
```

Expected: `BUILD SUCCESSFUL`.

## Task 8: Final Verification

**Files:**
- No production files unless verification reveals an issue.

- [ ] **Step 1: Run script verification**

Run:

```powershell
node scripts/verify-campus-market.mjs
```

Expected: `CampusMarket verification passed.`

- [ ] **Step 2: Run HAP build**

Run the hvigor command from Task 7.

Expected: `BUILD SUCCESSFUL`.

- [ ] **Step 3: Summarize changed files**

Report the major changed modules and any remaining external API limitations.

