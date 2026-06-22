import {
  FULL_SIZE,
  PAGE_BACKGROUND,
  PAGE_PADDING
} from '../common/CommonConstants';
import { EmptyView } from '../view/EmptyView';
import { GoodsCardComponent } from '../view/GoodsCardComponent';
import { findGoodsById } from '../viewmodel/CampusGoodsData';
import { FavoriteStore } from '../viewmodel/FavoriteStore';
import { GoodsModel } from '../viewmodel/GoodsModel';

@Entry
@Component
struct FavoritePage {
  @State favoriteGoods: GoodsModel[] = [];

  aboutToAppear(): void {
    this.reloadFavorites();
  }

  private reloadFavorites(): void {
    const goods: GoodsModel[] = [];
    FavoriteStore.getIds().forEach((id: string) => {
      const item = findGoodsById(id);
      if (item !== undefined) {
        goods.push(item);
      }
    });
    this.favoriteGoods = goods;
  }

  build() {
    Navigation() {
      Column() {
        if (this.favoriteGoods.length === 0) {
          EmptyView({
            message: '我的收藏还是空的',
            description: '在商品详情页点击收藏后，会出现在这里'
          })
        } else {
          List({ space: 12 }) {
            ForEach(this.favoriteGoods, (item: GoodsModel) => {
              ListItem() {
                GoodsCardComponent({ goods: item })
              }
            }, (item: GoodsModel) => item.id)
          }
          .width(FULL_SIZE)
          .edgeEffect(EdgeEffect.Spring)
        }
      }
      .width(FULL_SIZE)
      .height(FULL_SIZE)
      .padding(PAGE_PADDING)
      .backgroundColor(PAGE_BACKGROUND)
    }
    .title('我的收藏')
    .titleMode(NavigationTitleMode.Mini)
  }
}
