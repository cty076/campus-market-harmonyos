import { existsSync, mkdtempSync, readFileSync, rmSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { execFileSync } from 'node:child_process';

const root = process.cwd();

const requiredFiles = [
  'entry/src/main/ets/pages/Index.ets',
  'entry/src/main/ets/pages/DetailPage.ets',
  'entry/src/main/ets/pages/FavoritePage.ets',
  'entry/src/main/ets/pages/PricingAssistantPage.ets',
  'entry/src/main/ets/common/CommonConstants.ets',
  'entry/src/main/ets/common/ApiConfig.ets',
  'entry/src/main/ets/view/CampusTabBar.ets',
  'entry/src/main/ets/view/GoodsListComponent.ets',
  'entry/src/main/ets/view/GoodsCardComponent.ets',
  'entry/src/main/ets/view/SearchBarComponent.ets',
  'entry/src/main/ets/view/PullRefreshLayout.ets',
  'entry/src/main/ets/view/EmptyView.ets',
  'entry/src/main/ets/view/BottomTip.ets',
  'entry/src/main/ets/view/RegionRecommendPanel.ets',
  'entry/src/main/ets/viewmodel/GoodsModel.ets',
  'entry/src/main/ets/viewmodel/CampusGoodsData.ets',
  'entry/src/main/ets/viewmodel/CampusGoodsDataSource.ets',
  'entry/src/main/ets/viewmodel/FavoriteStore.ets',
  'entry/src/main/ets/viewmodel/CampusRegion.ets',
  'entry/src/main/ets/viewmodel/RegionGoodsService.ets',
  'entry/src/main/ets/viewmodel/PricingModel.ets',
  'entry/src/main/ets/viewmodel/PricingContextModel.ets',
  'entry/src/main/ets/utils/GeoUtils.ets',
  'entry/src/main/ets/service/LocationService.ets',
  'entry/src/main/ets/service/PricingService.ets',
  'entry/src/main/ets/service/PricingContextService.ets',
  'entry/src/main/ets/service/LlmPricingProvider.ets',
];

const requiredText = [
  ['entry/src/main/ets/pages/Index.ets', 'SearchBarComponent'],
  ['entry/src/main/ets/pages/Index.ets', 'CampusTabBar'],
  ['entry/src/main/ets/pages/Index.ets', 'RegionRecommendPanel'],
  ['entry/src/main/ets/pages/Index.ets', 'locatedRegionId'],
  ['entry/src/main/ets/pages/Index.ets', 'isRegionPanelExpanded'],
  ['entry/src/main/ets/pages/DetailPage.ets', 'PricingAssistantPage'],
  ['entry/src/main/ets/pages/DetailPage.ets', '所属学校'],
  ['entry/src/main/ets/pages/DetailPage.ets', 'formatRegionNames'],
  ['entry/src/main/ets/pages/FavoritePage.ets', 'FavoriteStore'],
  ['entry/src/main/ets/view/GoodsListComponent.ets', 'LazyForEach'],
  ['entry/src/main/ets/view/GoodsListComponent.ets', 'CampusGoodsDataSource'],
  ['entry/src/main/ets/view/GoodsListComponent.ets', '@Prop currentRegionId'],
  ['entry/src/main/ets/view/CampusTabBar.ets', 'Tabs'],
  ['entry/src/main/ets/view/CampusTabBar.ets', 'PullRefreshLayout'],
  ['entry/src/main/ets/view/CampusTabBar.ets', '@Prop currentRegionId'],
  ['entry/src/main/ets/view/CampusTabBar.ets', 'currentRegionId: this.currentRegionId'],
  ['entry/src/main/ets/view/GoodsListComponent.ets', 'BottomTip'],
  ['entry/src/main/ets/view/GoodsCardComponent.ets', '@Prop currentRegionId'],
  ['entry/src/main/ets/viewmodel/GoodsModel.ets', 'regionIds'],
  ['entry/src/main/ets/viewmodel/CampusGoodsData.ets', 'campusGoodsList'],
  ['entry/src/main/ets/viewmodel/CampusRegion.ets', 'campusRegions'],
  ['entry/src/main/ets/viewmodel/CampusRegion.ets', 'bjut'],
  ['entry/src/main/ets/viewmodel/CampusRegion.ets', 'pku'],
  ['entry/src/main/ets/viewmodel/CampusRegion.ets', 'bit'],
  ['entry/src/main/ets/viewmodel/CampusRegion.ets', '北京工业大学'],
  ['entry/src/main/ets/viewmodel/CampusRegion.ets', '北京大学'],
  ['entry/src/main/ets/viewmodel/CampusRegion.ets', '北京理工大学'],
  ['entry/src/main/ets/viewmodel/CampusRegion.ets', 'getRegionNameById'],
  ['entry/src/main/ets/viewmodel/CampusRegion.ets', 'formatRegionNames'],
  ['entry/src/main/ets/viewmodel/CampusRegion.ets', 'shortName'],
  ['entry/src/main/ets/viewmodel/CampusRegion.ets', 'tradeAdvice'],
  ['entry/src/main/ets/viewmodel/CampusRegion.ets', 'fallbackAdvice'],
  ['entry/src/main/ets/viewmodel/CampusGoodsData.ets', "['bjut'"],
  ['entry/src/main/ets/viewmodel/CampusGoodsData.ets', "['pku'"],
  ['entry/src/main/ets/viewmodel/CampusGoodsData.ets', "['bit'"],
  ['entry/src/main/ets/viewmodel/RegionGoodsService.ets', 'filterGoodsForRegion'],
  ['entry/src/main/ets/viewmodel/RegionGoodsService.ets', 'RegionRecommendSummary'],
  ['entry/src/main/ets/viewmodel/RegionGoodsService.ets', 'buildSummary'],
  ['entry/src/main/ets/viewmodel/PricingModel.ets', 'PricingRequest'],
  ['entry/src/main/ets/viewmodel/PricingModel.ets', 'confidence'],
  ['entry/src/main/ets/viewmodel/PricingModel.ets', 'marketReference'],
  ['entry/src/main/ets/viewmodel/PricingContextModel.ets', 'sameCategoryAveragePrice'],
  ['entry/src/main/ets/utils/GeoUtils.ets', 'pointInPolygon'],
  ['entry/src/main/ets/common/ApiConfig.ets', 'AMAP_API_KEY'],
  ['entry/src/main/ets/common/ApiConfig.ets', 'AMAP_COORDINATE_CONVERT_URL'],
  ['entry/src/main/ets/common/ApiConfig.ets', 'deepseek-v4-flash'],
  ['entry/src/main/ets/common/ApiConfig.ets', 'https://api.deepseek.com/chat/completions'],
  ['entry/src/main/ets/service/LocationService.ets', 'getCurrentLocation'],
  ['entry/src/main/ets/service/LocationService.ets', 'convertToAmapCoordinate'],
  ['entry/src/main/ets/service/PricingService.ets', 'estimate'],
  ['entry/src/main/ets/service/PricingContextService.ets', 'buildContext'],
  ['entry/src/main/ets/service/LlmPricingProvider.ets', 'estimateWithLlm'],
  ['entry/src/main/ets/service/LlmPricingProvider.ets', 'normalizePricingText'],
  ['entry/src/main/ets/service/LlmPricingProvider.ets', 'marketReference'],
  ['entry/src/main/ets/view/RegionRecommendPanel.ets', 'currentRegion'],
  ['entry/src/main/ets/view/RegionRecommendPanel.ets', 'onSelectRegion'],
  ['entry/src/main/ets/view/RegionRecommendPanel.ets', '北京理工大学'],
  ['entry/src/main/ets/view/RegionRecommendPanel.ets', '@Prop currentRegion'],
  ['entry/src/main/ets/view/RegionRecommendPanel.ets', '@Prop status'],
  ['entry/src/main/ets/view/RegionRecommendPanel.ets', '@Prop message'],
  ['entry/src/main/ets/view/RegionRecommendPanel.ets', '@Prop isExpanded'],
  ['entry/src/main/ets/view/RegionRecommendPanel.ets', 'onToggleExpanded'],
  ['entry/src/main/ets/view/RegionRecommendPanel.ets', 'viewingRegionName'],
  ['entry/src/main/ets/view/RegionRecommendPanel.ets', 'tradeJudgementText'],
  ['entry/src/main/ets/view/RegionRecommendPanel.ets', 'SummaryCell'],
  ['entry/src/main/ets/view/RegionRecommendPanel.ets', '当前定位'],
  ['entry/src/main/ets/view/RegionRecommendPanel.ets', '正在查看'],
  ['entry/src/main/ets/view/RegionRecommendPanel.ets', '定位学校'],
  ['entry/src/main/ets/view/RegionRecommendPanel.ets', '交易判断'],
  ['entry/src/main/ets/view/RegionRecommendPanel.ets', '展开'],
  ['entry/src/main/ets/view/RegionRecommendPanel.ets', '收起'],
  ['entry/src/main/ets/pages/DetailPage.ets', 'tradeMatchText'],
  ['entry/src/main/ets/pages/PricingAssistantPage.ets', 'currentRegionId'],
  ['entry/src/main/ets/entryability/EntryAbility.ets', 'signatureInfo.appId'],
  ['entry/src/main/resources/base/profile/main_pages.json', 'pages/DetailPage'],
  ['entry/src/main/resources/base/profile/main_pages.json', 'pages/FavoritePage'],
  ['entry/src/main/resources/base/profile/main_pages.json', 'pages/PricingAssistantPage'],
];

const forbiddenText = [
  ['entry/src/main/ets/pages/Index.ets', 'simulateDormitoryLocation'],
  ['entry/src/main/ets/pages/Index.ets', 'simulateStudyLocation'],
  ['entry/src/main/ets/pages/Index.ets', 'simulateSportsLocation'],
  ['entry/src/main/ets/view/RegionRecommendPanel.ets', 'onDormitoryDemo'],
  ['entry/src/main/ets/view/RegionRecommendPanel.ets', 'onStudyDemo'],
  ['entry/src/main/ets/view/RegionRecommendPanel.ets', 'onSportsDemo'],
  ['entry/src/main/ets/service/PricingService.ets', 'MockPricingProvider'],
  ['entry/src/main/ets/service/LocationService.ets', 'simulate'],
  ['entry/src/main/ets/viewmodel/CampusRegion.ets', "'dormitory'"],
  ['entry/src/main/ets/viewmodel/CampusRegion.ets', "'study'"],
  ['entry/src/main/ets/viewmodel/CampusRegion.ets', "'sports'"],
  ['entry/src/main/ets/viewmodel/CampusGoodsData.ets', "'dormitory'"],
  ['entry/src/main/ets/viewmodel/CampusGoodsData.ets', "'study'"],
  ['entry/src/main/ets/viewmodel/CampusGoodsData.ets', "'sports'"],
  ['entry/src/main/ets/service/LocationService.ets', '@amap/amap_lbs_location'],
  ['entry/src/main/ets/entryability/EntryAbility.ets', '@amap/amap_lbs_location'],
  ['entry/src/main/ets/service/LlmPricingProvider.ets', "parsed.priceRange ?? '-'"],
  ['entry/src/main/ets/service/LlmPricingProvider.ets', "parsed.suggestedPrice ?? '-'"],
  ['entry/src/main/ets/view/RegionRecommendPanel.ets', 'SummaryCell(label: string, value: string'],
  ['entry/src/main/ets/view/RegionRecommendPanel.ets', 'SummaryCellFrame'],
  ['entry/src/main/ets/view/RegionRecommendPanel.ets', 'scrollBar(BarState.Off)'],
];

const failures = [];

function assertFileExists(file) {
  if (!existsSync(join(root, file))) {
    failures.push(`Missing file: ${file}`);
  }
}

function assertContains(file, text) {
  const path = join(root, file);
  if (!existsSync(path)) {
    failures.push(`Cannot check missing file: ${file}`);
    return;
  }

  const content = readFileSync(path, 'utf8');
  if (!content.includes(text)) {
    failures.push(`Missing text "${text}" in ${file}`);
  }
}

function assertNotContains(file, text) {
  const path = join(root, file);
  if (!existsSync(path)) {
    return;
  }

  const content = readFileSync(path, 'utf8');
  if (content.includes(text)) {
    failures.push(`Forbidden text "${text}" found in ${file}`);
  }
}

for (const file of requiredFiles) {
  assertFileExists(file);
}

for (const [file, text] of requiredText) {
  assertContains(file, text);
}

for (const [file, text] of forbiddenText) {
  assertNotContains(file, text);
}

function verifySchoolCategoryCoverage() {
  const goodsPath = join(root, 'entry/src/main/ets/viewmodel/CampusGoodsData.ets');
  if (!existsSync(goodsPath)) {
    return;
  }

  const content = readFileSync(goodsPath, 'utf8');
  const goodsRegex = /new GoodsModel\([\s\S]*?'([^']+)',\s*'([^']+)',\s*'([^']+)',\s*'([^']+)',\s*'([^']+)',\s*'([^']+)',\s*'([^']+)',\s*'([^']+)',\s*\$r\('([^']+)'\),\s*\[[^\]]*\],\s*\[([^\]]*)\]\s*\)/g;
  const coverage = new Map([
    ['bjut', new Set()],
    ['pku', new Set()],
    ['bit', new Set()]
  ]);
  let matchedCount = 0;

  for (const match of content.matchAll(goodsRegex)) {
    matchedCount++;
    const category = match[3];
    const regionIds = [...match[10].matchAll(/'([^']+)'/g)].map((regionMatch) => regionMatch[1]);

    if (regionIds.length !== 1) {
      failures.push(`Goods ${match[1]} must belong to exactly one school, got: ${regionIds.join(', ')}`);
      continue;
    }

    const regionCoverage = coverage.get(regionIds[0]);
    if (regionCoverage === undefined) {
      failures.push(`Goods ${match[1]} uses unknown school region: ${regionIds[0]}`);
      continue;
    }

    regionCoverage.add(category);
  }

  if (matchedCount === 0) {
    failures.push('No GoodsModel entries parsed from CampusGoodsData.ets');
  }

  if (matchedCount < 31) {
    failures.push(`Expected at least 31 goods items, got: ${matchedCount}`);
  }

  const requiredCategories = ['教材', '考研', '数码', '生活', '运动'];
  for (const [regionId, categories] of coverage.entries()) {
    for (const category of requiredCategories) {
      if (!categories.has(category)) {
        failures.push(`Region ${regionId} is missing category ${category}`);
      }
    }
  }
}

verifySchoolCategoryCoverage();

const hapFile = join(root, 'entry/build/default/outputs/default/entry-default-signed.hap');
if (existsSync(hapFile)) {
  const tempDir = mkdtempSync(join(tmpdir(), 'campus-market-hap-'));
  try {
    execFileSync('tar', ['-xf', hapFile, '-C', tempDir]);
    const extracted = execFileSync('powershell', [
      '-NoProfile',
      '-Command',
      `Get-ChildItem -Recurse -Path '${tempDir.replaceAll("'", "''")}' -Filter *.so | Select-Object -ExpandProperty FullName`
    ], { encoding: 'utf8' }).trim();

    if (extracted.length > 0) {
      failures.push(`Native .so files are packaged in HAP: ${extracted}`);
    }
  } catch (err) {
    failures.push(`Cannot inspect HAP native libraries: ${String(err)}`);
  } finally {
    rmSync(tempDir, { recursive: true, force: true });
  }
}

if (failures.length > 0) {
  console.error('CampusMarket verification failed:');
  for (const failure of failures) {
    console.error(`- ${failure}`);
  }
  process.exit(1);
}

console.log('CampusMarket verification passed.');
