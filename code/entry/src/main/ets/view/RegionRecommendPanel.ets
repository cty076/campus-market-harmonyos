import {
  CARD_BACKGROUND,
  CARD_PADDING,
  CARD_RADIUS,
  DIVIDER_COLOR,
  FULL_SIZE,
  PRIMARY_COLOR,
  SUCCESS_COLOR,
  TEXT_MUTED,
  TEXT_PRIMARY,
  TEXT_SECONDARY
} from '../common/CommonConstants';
import { CampusRegion, LocationStatus, defaultRegion } from '../viewmodel/CampusRegion';

@Component
export struct RegionRecommendPanel {
  @Prop currentRegion: CampusRegion = defaultRegion;
  @Prop status: LocationStatus = LocationStatus.READY;
  @Prop message: string = '点击定位后，将根据你所在校园区域推荐商品';
  @Prop goodsCount: number = 0;
  @Prop selectedRegionId: string = 'all';
  onLocate: () => void = () => {};
  onSelectRegion: (regionId: string) => void = (_regionId: string) => {};

  private statusText(): string {
    switch (this.status) {
      case LocationStatus.LOCATING:
        return '定位中';
      case LocationStatus.SUCCESS:
        return '已识别';
      case LocationStatus.FAILED:
        return '定位失败';
      default:
        return '待定位';
    }
  }

  @Builder
  RegionOption(label: string, regionId: string) {
    Text(label)
      .fontSize(12)
      .fontColor(this.selectedRegionId === regionId ? Color.White : PRIMARY_COLOR)
      .padding({ left: 10, right: 10, top: 6, bottom: 6 })
      .backgroundColor(this.selectedRegionId === regionId ? PRIMARY_COLOR : '#EAF3FF')
      .borderRadius(6)
      .margin({ right: 8 })
      .onClick(() => {
        this.onSelectRegion(regionId);
      })
  }

  build() {
    Column() {
      Row() {
        Column() {
          Text(this.currentRegion.shortName)
            .fontSize(17)
            .fontWeight(FontWeight.Bold)
            .fontColor(TEXT_PRIMARY)

          Text(this.statusText() + ' · ' + this.message)
            .fontSize(12)
            .fontColor(TEXT_MUTED)
            .margin({ top: 4 })
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        Text('区域推荐')
          .fontSize(12)
          .fontColor(SUCCESS_COLOR)
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .backgroundColor('#F0F8F4')
          .borderRadius(6)
      }
      .width(FULL_SIZE)
      .alignItems(VerticalAlign.Center)

      Text(this.currentRegion.tradeAdvice)
        .fontSize(13)
        .fontColor(TEXT_SECONDARY)
        .lineHeight(20)
        .margin({ top: 10 })

      Text(`当前推荐 ${this.goodsCount} 件商品。${this.currentRegion.fallbackAdvice}`)
        .fontSize(13)
        .fontColor(TEXT_SECONDARY)
        .lineHeight(20)
        .margin({ top: 6 })

      Scroll() {
        Row() {
          this.RegionOption('全部', 'all')
          this.RegionOption('北京工业大学', 'bjut')
          this.RegionOption('北京大学', 'pku')
          this.RegionOption('北京理工大学', 'bit')
        }
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .width(FULL_SIZE)
      .margin({ top: 12 })

      Button('重新定位')
        .height(34)
        .fontSize(13)
        .fontColor(Color.White)
        .backgroundColor(PRIMARY_COLOR)
        .borderRadius(6)
        .margin({ top: 12 })
        .onClick(() => {
          this.onLocate();
        })
    }
    .width(FULL_SIZE)
    .padding(CARD_PADDING)
    .backgroundColor(CARD_BACKGROUND)
    .borderRadius(CARD_RADIUS)
    .border({ width: 1, color: DIVIDER_COLOR })
  }
}
