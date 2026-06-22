import {
  CARD_BACKGROUND,
  CARD_PADDING,
  CARD_RADIUS,
  DIVIDER_COLOR,
  GOODS_IMAGE_SIZE,
  PRICE_COLOR,
  PRIMARY_COLOR,
  TEXT_MUTED,
  TEXT_PRIMARY,
  TEXT_SECONDARY
} from '../common/CommonConstants';
import { GoodsModel } from '../viewmodel/GoodsModel';
import { campusGoodsList } from '../viewmodel/CampusGoodsData';
import { FavoriteStore } from '../viewmodel/FavoriteStore';

@Component
export struct GoodsCardComponent {
  goods: GoodsModel = campusGoodsList[0];
  currentRegionId: string = 'all';

  build() {
    Row() {
      Image(this.goods.image)
        .width(GOODS_IMAGE_SIZE)
        .height(GOODS_IMAGE_SIZE)
        .borderRadius(CARD_RADIUS)
        .objectFit(ImageFit.Cover)
        .margin({ right: 12 })

      Column() {
        Row() {
          Text(this.goods.title)
            .fontSize(17)
            .fontWeight(FontWeight.Medium)
            .fontColor(TEXT_PRIMARY)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .layoutWeight(1)

          Text(FavoriteStore.isFavorite(this.goods.id) ? '已藏' : this.goods.category)
            .fontSize(12)
            .fontColor(FavoriteStore.isFavorite(this.goods.id) ? PRIMARY_COLOR : TEXT_SECONDARY)
            .padding({ left: 8, right: 8, top: 3, bottom: 3 })
            .backgroundColor(FavoriteStore.isFavorite(this.goods.id) ? '#EAF3FF' : '#F2F4F7')
            .borderRadius(6)
        }
        .width('100%')

        Text(this.goods.description)
          .fontSize(13)
          .fontColor(TEXT_SECONDARY)
          .maxLines(2)
          .lineHeight(19)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ top: 8 })

        Row() {
          Text(this.goods.price)
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor(PRICE_COLOR)

          Blank()

          Text(this.goods.condition)
            .fontSize(12)
            .fontColor(TEXT_MUTED)
            .margin({ right: 10 })

          Text(this.goods.publishTime)
            .fontSize(12)
            .fontColor(TEXT_MUTED)
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)
        .margin({ top: 10 })
      }
      .layoutWeight(1)
      .height(GOODS_IMAGE_SIZE)
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width('100%')
    .padding(CARD_PADDING)
    .backgroundColor(CARD_BACKGROUND)
    .borderRadius(CARD_RADIUS)
    .border({ width: 1, color: DIVIDER_COLOR })
    .onClick(() => {
      this.getUIContext().getRouter().pushUrl({
        url: 'pages/DetailPage',
        params: {
          goodsId: this.goods.id,
          currentRegionId: this.currentRegionId
        }
      });
    })
  }
}
