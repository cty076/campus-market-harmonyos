import { CARD_RADIUS, FULL_SIZE, PAGE_BACKGROUND, PAGE_PADDING, PRIMARY_COLOR, TEXT_MUTED, TEXT_PRIMARY } from '../common/CommonConstants';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { LocationService } from '../service/LocationService';
import { findRegionByPoint } from '../utils/GeoUtils';
import { CampusTabBar } from '../view/CampusTabBar';
import { RegionRecommendPanel } from '../view/RegionRecommendPanel';
import { SearchBarComponent } from '../view/SearchBarComponent';
import { campusGoodsList } from '../viewmodel/CampusGoodsData';
import { CampusRegion, LocationResult, LocationStatus, campusRegions, defaultRegion } from '../viewmodel/CampusRegion';
import { GoodsModel } from '../viewmodel/GoodsModel';

const DOMAIN = 0x0000;

@Entry
@Component
struct Index {
  @State keyword: string = '';
  @State regionId: string = 'all';
  @State currentRegion: CampusRegion = defaultRegion;
  @State locationStatus: LocationStatus = LocationStatus.READY;
  @State locationMessage: string = '点击重新定位后，将使用高德定位识别你所在的校园区域';
  @State recommendGoodsCount: number = campusGoodsList.length;

  aboutToAppear(): void {
    this.updateRegionSummary();
  }

  private updateRegionSummary(): void {
    this.recommendGoodsCount = this.regionId === 'all'
      ? campusGoodsList.length
      : campusGoodsList.filter((item: GoodsModel) => item.regionIds.includes(this.regionId)).length;
  }

  private applyLocation(result: LocationResult): void {
    this.locationStatus = result.status;
    this.locationMessage = result.message;

    if (result.point === undefined) {
      this.currentRegion = defaultRegion;
      this.regionId = defaultRegion.id;
      this.updateRegionSummary();
      return;
    }

    const matchedRegion = findRegionByPoint(result.point, campusRegions);
    this.currentRegion = matchedRegion === undefined ? defaultRegion : matchedRegion;
    this.regionId = this.currentRegion.id;
    this.updateRegionSummary();
    hilog.info(
      DOMAIN,
      'LocationDebug',
      'apply status=%{public}s region=%{public}s message=%{public}s',
      this.locationStatus,
      this.currentRegion.name,
      this.locationMessage
    );
  }

  private applyManualRegion(regionId: string): void {
    const matchedRegion = campusRegions.find((region: CampusRegion) => region.id === regionId);
    this.currentRegion = matchedRegion === undefined ? defaultRegion : matchedRegion;
    this.regionId = this.currentRegion.id;
    this.locationStatus = LocationStatus.SUCCESS;
    this.locationMessage = regionId === 'all' ? '已手动切换为全部商品' : `已手动切换为${this.currentRegion.shortName}`;
    this.updateRegionSummary();
  }

  private locate(): void {
    this.locationStatus = LocationStatus.LOCATING;
    LocationService.getCurrentLocation().then((result: LocationResult) => {
      this.applyLocation(result);
    }).catch(() => {
      this.applyLocation(LocationService.failedLocation('高德定位失败，已切换为校内通用推荐'));
    });
  }

  build() {
    Navigation() {
      Column() {
        Row() {
          Column() {
            Text('校园二手好物')
              .fontSize(26)
              .fontWeight(FontWeight.Bold)
              .fontColor(TEXT_PRIMARY)

            Text('按你所在的校园交易圈推荐更适合当面交易的商品')
              .fontSize(13)
              .fontColor(TEXT_MUTED)
              .margin({ top: 4 })
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)

          Button('收藏')
            .height(34)
            .fontSize(14)
            .fontColor(Color.White)
            .backgroundColor(PRIMARY_COLOR)
            .borderRadius(CARD_RADIUS)
            .onClick(() => {
              this.getUIContext().getRouter().pushUrl({
                url: 'pages/FavoritePage'
              });
            })
        }
        .width(FULL_SIZE)
        .alignItems(VerticalAlign.Center)
        .margin({ bottom: 14 })

        SearchBarComponent({ keyword: $keyword })
          .margin({ bottom: 10 })

        RegionRecommendPanel({
          currentRegion: this.currentRegion,
          status: this.locationStatus,
          message: this.locationMessage,
          goodsCount: this.recommendGoodsCount,
          selectedRegionId: this.regionId,
          onLocate: () => {
            this.locate();
          },
          onSelectRegion: (regionId: string) => {
            this.applyManualRegion(regionId);
          }
        })
          .margin({ bottom: 10 })

        CampusTabBar({ keyword: $keyword, regionId: $regionId })
      }
      .width(FULL_SIZE)
      .height(FULL_SIZE)
      .padding({
        left: PAGE_PADDING,
        right: PAGE_PADDING,
        top: 18,
        bottom: 8
      })
      .backgroundColor(PAGE_BACKGROUND)
    }
    .hideTitleBar(true)
    .width(FULL_SIZE)
    .height(FULL_SIZE)
  }
}
