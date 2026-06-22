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
import { CampusRegion, LocationStatus, defaultRegion, getRegionNameById } from '../viewmodel/CampusRegion';

@Component
export struct RegionRecommendPanel {
  @Prop currentRegion: CampusRegion = defaultRegion;
  @Prop status: LocationStatus = LocationStatus.READY;
  @Prop message: string = '点击定位后，将根据你所在校园区域推荐商品';
  @Prop goodsCount: number = 0;
  @Prop selectedRegionId: string = 'all';
  @Prop isExpanded: boolean = false;
  onLocate: () => void = () => {};
  onSelectRegion: (regionId: string) => void = (_regionId: string) => {};
  onToggleExpanded: () => void = () => {};

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

  private viewingRegionName(): string {
    return this.selectedRegionId === defaultRegion.id ? '全部商品' : `${getRegionNameById(this.selectedRegionId)}商品`;
  }

  private tradeJudgementText(): string {
    if (this.currentRegion.id === defaultRegion.id) {
      return '定位后判断';
    }

    if (this.selectedRegionId === defaultRegion.id) {
      return '同校/跨校';
    }

    return this.selectedRegionId === this.currentRegion.id ? '同校优先' : '跨校提醒';
  }

  private compactSummaryText(): string {
    return `${this.viewingRegionName()} · ${this.goodsCount}件 · ${this.tradeJudgementText()}`;
  }

  private panelHintText(): string {
    if (this.currentRegion.id === defaultRegion.id) {
      return '定位后，商品详情可判断同校或跨校交易。';
    }

    if (this.selectedRegionId === defaultRegion.id) {
      return `查看全部时，商品详情仍会根据${this.currentRegion.shortName}定位判断同校或跨校交易。`;
    }

    if (this.selectedRegionId === this.currentRegion.id) {
      return `当前正在查看${this.currentRegion.shortName}商品，优先适合同校当面验货交易。`;
    }

    return `已定位到${this.currentRegion.shortName}，当前查看${getRegionNameById(this.selectedRegionId)}商品，详情页会提示跨校交易建议。`;
  }

  @Builder
  ViewingSummaryCell() {
    Column() {
      Text('正在查看')
        .fontSize(12)
        .fontColor(TEXT_MUTED)

      Text(this.viewingRegionName())
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor(TEXT_PRIMARY)
        .margin({ top: 6 })
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .alignItems(HorizontalAlign.Start)
    .padding({ left: 12, right: 10, top: 12, bottom: 12 })
    .backgroundColor('#F8FAFD')
    .border({ width: 1, color: DIVIDER_COLOR })
    .borderRadius(8)
    .layoutWeight(1)
    .margin({ right: 8 })
  }

  @Builder
  LocatedSchoolSummaryCell() {
    Column() {
      Text('定位学校')
        .fontSize(12)
        .fontColor(TEXT_MUTED)

      Text(this.currentRegion.shortName)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor(TEXT_PRIMARY)
        .margin({ top: 6 })
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .alignItems(HorizontalAlign.Start)
    .padding({ left: 12, right: 10, top: 12, bottom: 12 })
    .backgroundColor('#F8FAFD')
    .border({ width: 1, color: DIVIDER_COLOR })
    .borderRadius(8)
    .layoutWeight(1)
    .margin({ right: 8 })
  }

  @Builder
  GoodsCountSummaryCell() {
    Column() {
      Text('商品数量')
        .fontSize(12)
        .fontColor(TEXT_MUTED)

      Text(`${this.goodsCount}件`)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor(TEXT_PRIMARY)
        .margin({ top: 6 })
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .alignItems(HorizontalAlign.Start)
    .padding({ left: 12, right: 10, top: 12, bottom: 12 })
    .backgroundColor('#F8FAFD')
    .border({ width: 1, color: DIVIDER_COLOR })
    .borderRadius(8)
    .layoutWeight(1)
    .margin({ right: 8 })
  }

  @Builder
  TradeJudgementSummaryCell() {
    Column() {
      Text('交易判断')
        .fontSize(12)
        .fontColor(TEXT_MUTED)

      Text(this.tradeJudgementText())
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor(SUCCESS_COLOR)
        .margin({ top: 6 })
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .alignItems(HorizontalAlign.Start)
    .padding({ left: 12, right: 10, top: 12, bottom: 12 })
    .backgroundColor('#F8FAFD')
    .border({ width: 1, color: DIVIDER_COLOR })
    .borderRadius(8)
    .layoutWeight(1)
    .margin({ right: 8 })
  }

  @Builder
  RegionOption(label: string, regionId: string) {
    Text(label)
      .fontSize(12)
      .fontColor(this.selectedRegionId === regionId ? Color.White : TEXT_PRIMARY)
      .fontWeight(this.selectedRegionId === regionId ? FontWeight.Medium : FontWeight.Regular)
      .textAlign(TextAlign.Center)
      .padding({ left: 14, right: 14, top: 9, bottom: 9 })
      .backgroundColor(this.selectedRegionId === regionId ? PRIMARY_COLOR : '#F2F4F7')
      .borderRadius(16)
      .margin({ right: 10 })
      .onClick(() => {
        this.onSelectRegion(regionId);
      })
  }

  @Builder
  HeaderContent() {
    Row() {
      Column() {
        Row() {
          Text('当前定位')
            .fontSize(13)
            .fontColor(TEXT_MUTED)

          Text(this.statusText())
            .fontSize(12)
            .fontColor(this.status === LocationStatus.FAILED ? '#B26A00' : SUCCESS_COLOR)
            .padding({ left: 8, right: 8, top: 3, bottom: 3 })
            .backgroundColor(this.status === LocationStatus.FAILED ? '#FFF7E6' : '#F0F8F4')
            .borderRadius(6)
            .margin({ left: 8 })
        }
        .alignItems(VerticalAlign.Center)

        Text(this.currentRegion.shortName)
          .fontSize(this.isExpanded ? 24 : 21)
          .fontWeight(FontWeight.Bold)
          .fontColor(TEXT_PRIMARY)
          .margin({ top: 4 })
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      Button('重新定位')
        .height(34)
        .fontSize(13)
        .fontColor(PRIMARY_COLOR)
        .backgroundColor(Color.White)
        .border({ width: 1, color: PRIMARY_COLOR })
        .borderRadius(8)
        .onClick(() => {
          this.onLocate();
        })
    }
    .width(FULL_SIZE)
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  CompactContent() {
    Row() {
      Column() {
        Text(`正在查看：${this.compactSummaryText()}`)
          .fontSize(13)
          .fontColor(TEXT_SECONDARY)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text(`定位学校：${this.currentRegion.shortName}`)
          .fontSize(12)
          .fontColor(TEXT_MUTED)
          .margin({ top: 4 })
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      Button('展开')
        .height(32)
        .fontSize(13)
        .fontColor(PRIMARY_COLOR)
        .backgroundColor('#EAF3FF')
        .borderRadius(8)
        .onClick(() => {
          this.onToggleExpanded();
        })
    }
    .width(FULL_SIZE)
    .alignItems(VerticalAlign.Center)
    .margin({ top: 10 })
  }

  @Builder
  ExpandedContent() {
    Row() {
      this.ViewingSummaryCell()
      this.LocatedSchoolSummaryCell()
    }
    .width(FULL_SIZE)
    .margin({ top: 16 })

    Row() {
      this.GoodsCountSummaryCell()
      this.TradeJudgementSummaryCell()
    }
    .width(FULL_SIZE)
    .margin({ top: 8 })

    Scroll() {
      Row() {
        this.RegionOption('全部', 'all')
        this.RegionOption('北京工业大学', 'bjut')
        this.RegionOption('北京大学', 'pku')
        this.RegionOption('北京理工大学', 'bit')
        Blank()
          .width(16)
      }
    }
    .scrollable(ScrollDirection.Horizontal)
    .scrollBar(BarState.Auto)
    .width(FULL_SIZE)
    .margin({ top: 14 })

    Text(this.panelHintText())
      .fontSize(13)
      .fontColor(TEXT_SECONDARY)
      .lineHeight(20)
      .margin({ top: 12 })

    Row() {
      Text(this.message)
        .fontSize(12)
        .fontColor(TEXT_MUTED)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .layoutWeight(1)

      Button('收起')
        .height(30)
        .fontSize(12)
        .fontColor(TEXT_MUTED)
        .backgroundColor('#F2F4F7')
        .borderRadius(8)
        .margin({ left: 8 })
        .onClick(() => {
          this.onToggleExpanded();
        })
    }
    .width(FULL_SIZE)
    .alignItems(VerticalAlign.Center)
    .margin({ top: 6 })
  }

  build() {
    Column() {
      this.HeaderContent()

      if (this.isExpanded) {
        this.ExpandedContent()
      } else {
        this.CompactContent()
      }
    }
    .width(FULL_SIZE)
    .padding(CARD_PADDING)
    .backgroundColor(CARD_BACKGROUND)
    .borderRadius(CARD_RADIUS)
    .border({ width: 1, color: DIVIDER_COLOR })
  }
}
