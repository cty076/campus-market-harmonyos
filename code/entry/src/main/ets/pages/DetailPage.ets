import {
  CARD_BACKGROUND,
  CARD_PADDING,
  CARD_RADIUS,
  DETAIL_IMAGE_HEIGHT,
  DIVIDER_COLOR,
  FULL_SIZE,
  PAGE_BACKGROUND,
  PAGE_PADDING,
  PRICE_COLOR,
  PRIMARY_COLOR,
  SUCCESS_COLOR,
  TEXT_MUTED,
  TEXT_PRIMARY,
  TEXT_SECONDARY
} from '../common/CommonConstants';
import { findGoodsById } from '../viewmodel/CampusGoodsData';
import { formatRegionNames } from '../viewmodel/CampusRegion';
import { FavoriteStore } from '../viewmodel/FavoriteStore';
import { GoodsModel } from '../viewmodel/GoodsModel';

@Entry
@Component
struct DetailPage {
  @State goods: GoodsModel | undefined = undefined;
  @State isFavorite: boolean = false;
  @State feedbackMessage: string = '';
  @State currentRegionId: string = 'all';

  aboutToAppear(): void {
    const params = this.getUIContext().getRouter().getParams() as Record<string, string>;
    const goodsId = params === undefined ? '' : params.goodsId;
    this.currentRegionId = params === undefined || params.currentRegionId === undefined ? 'all' : params.currentRegionId;
    this.goods = findGoodsById(goodsId);
    if (this.goods !== undefined) {
      this.isFavorite = FavoriteStore.isFavorite(this.goods.id);
    }
  }

  private toggleFavorite(): void {
    if (this.goods === undefined) {
      return;
    }
    this.isFavorite = FavoriteStore.toggle(this.goods.id);
    this.feedbackMessage = this.isFavorite ? '已加入收藏，可在我的收藏中查看' : '已取消收藏';
  }

  private contactSeller(): void {
    if (this.goods === undefined) {
      return;
    }
    this.feedbackMessage = `已向${this.goods.seller}发送联系请求`;
  }

  private openPricingAssistant(): void {
    if (this.goods === undefined) {
      return;
    }
    this.getUIContext().getRouter().pushUrl({
      url: 'pages/PricingAssistantPage',
      params: {
        title: this.goods.title,
        category: this.goods.category,
        condition: this.goods.condition,
        price: this.goods.price,
        listedPrice: this.goods.price,
        description: this.goods.description,
        currentRegionId: this.currentRegionId,
        goodsRegionIds: this.goods.regionIds.join(',')
      }
    }).catch(() => {
      this.feedbackMessage = 'AI 估价页面打开失败，请稍后重试';
    });
  }

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

  @Builder
  GoodsContent(goods: GoodsModel) {
    Scroll() {
      Column() {
        Image(goods.image)
          .width(FULL_SIZE)
          .height(DETAIL_IMAGE_HEIGHT)
          .objectFit(ImageFit.Cover)
          .borderRadius(CARD_RADIUS)

        Column() {
          Row() {
            Text(goods.title)
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor(TEXT_PRIMARY)
              .layoutWeight(1)

            Text(goods.category)
              .fontSize(13)
              .fontColor(PRIMARY_COLOR)
              .padding({ left: 10, right: 10, top: 5, bottom: 5 })
              .backgroundColor('#EAF3FF')
              .borderRadius(6)
          }
          .width(FULL_SIZE)
          .alignItems(VerticalAlign.Center)

          Text(goods.price)
            .fontSize(30)
            .fontWeight(FontWeight.Bold)
            .fontColor(PRICE_COLOR)
            .margin({ top: 10 })
            .alignSelf(ItemAlign.Start)

          Row() {
            Text(goods.condition)
              .fontSize(13)
              .fontColor(TEXT_SECONDARY)
            Text(goods.publishTime)
              .fontSize(13)
              .fontColor(TEXT_MUTED)
              .margin({ left: 12 })
          }
          .width(FULL_SIZE)
          .margin({ top: 8 })

          Row() {
            Text('所属学校')
              .fontSize(13)
              .fontColor(TEXT_MUTED)
            Text(formatRegionNames(goods.regionIds))
              .fontSize(13)
              .fontColor(SUCCESS_COLOR)
              .margin({ left: 10 })
              .layoutWeight(1)
          }
          .width(FULL_SIZE)
          .margin({ top: 8 })

          Text(this.tradeMatchText(goods))
            .fontSize(13)
            .fontColor(this.isSameCampusGoods(goods) ? SUCCESS_COLOR : TEXT_MUTED)
            .lineHeight(20)
            .margin({ top: 8 })

          Divider()
            .color(DIVIDER_COLOR)
            .margin({ top: 16, bottom: 16 })

          Text('商品描述')
            .fontSize(17)
            .fontWeight(FontWeight.Medium)
            .fontColor(TEXT_PRIMARY)
            .alignSelf(ItemAlign.Start)

          Text(goods.description)
            .fontSize(15)
            .lineHeight(23)
            .fontColor(TEXT_SECONDARY)
            .margin({ top: 8 })

          Text('卖家信息')
            .fontSize(17)
            .fontWeight(FontWeight.Medium)
            .fontColor(TEXT_PRIMARY)
            .margin({ top: 18 })
            .alignSelf(ItemAlign.Start)

          Row() {
            Text(goods.seller)
              .fontSize(15)
              .fontColor(TEXT_SECONDARY)
              .layoutWeight(1)

            Text('校内当面交易')
              .fontSize(13)
              .fontColor(SUCCESS_COLOR)
          }
          .width(FULL_SIZE)
          .margin({ top: 8 })
        }
        .width(FULL_SIZE)
        .padding(CARD_PADDING)
        .backgroundColor(CARD_BACKGROUND)
        .borderRadius(CARD_RADIUS)
        .border({ width: 1, color: DIVIDER_COLOR })
        .margin({ top: 14 })
      }
      .width(FULL_SIZE)
      .padding(PAGE_PADDING)
    }
    .layoutWeight(1)
  }

  build() {
    Navigation() {
      Column() {
        if (this.goods === undefined) {
          Column() {
            Text('未找到商品')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor(TEXT_PRIMARY)
            Button('返回')
              .margin({ top: 16 })
              .onClick(() => {
                this.getUIContext().getRouter().back();
              })
          }
          .width(FULL_SIZE)
          .height(FULL_SIZE)
          .justifyContent(FlexAlign.Center)
        } else {
          this.GoodsContent(this.goods)

          if (this.feedbackMessage.length > 0) {
            Row() {
              Text(this.feedbackMessage)
                .fontSize(14)
                .fontColor(SUCCESS_COLOR)
            }
            .width(FULL_SIZE)
            .height(38)
            .justifyContent(FlexAlign.Center)
            .backgroundColor('#F0F8F4')
            .border({ width: 1, color: SUCCESS_COLOR })
          }

          Row() {
            Button(this.isFavorite ? '取消收藏' : '收藏')
              .layoutWeight(1)
              .height(46)
              .fontSize(15)
              .fontColor(this.isFavorite ? PRIMARY_COLOR : TEXT_PRIMARY)
              .backgroundColor(this.isFavorite ? '#EAF3FF' : '#FFFFFF')
              .border({ width: 1, color: this.isFavorite ? PRIMARY_COLOR : DIVIDER_COLOR })
              .borderRadius(CARD_RADIUS)
              .onClick(() => {
                this.toggleFavorite();
              })

            Button('AI 估价')
              .layoutWeight(1)
              .height(46)
              .fontSize(15)
              .fontColor(PRIMARY_COLOR)
              .backgroundColor('#EAF3FF')
              .borderRadius(CARD_RADIUS)
              .margin({ left: 10 })
              .onClick(() => {
                this.openPricingAssistant();
              })

            Button('联系卖家')
              .layoutWeight(1)
              .height(46)
              .fontSize(15)
              .fontColor(Color.White)
              .backgroundColor(PRIMARY_COLOR)
              .borderRadius(CARD_RADIUS)
              .margin({ left: 10 })
              .onClick(() => {
                this.contactSeller();
              })
          }
          .width(FULL_SIZE)
          .padding({
            left: PAGE_PADDING,
            right: PAGE_PADDING,
            top: 10,
            bottom: 14
          })
          .backgroundColor(CARD_BACKGROUND)
        }
      }
      .width(FULL_SIZE)
      .height(FULL_SIZE)
      .backgroundColor(PAGE_BACKGROUND)
    }
    .title('商品详情')
    .titleMode(NavigationTitleMode.Mini)
  }
}
