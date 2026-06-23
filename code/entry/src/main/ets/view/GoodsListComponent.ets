import { LIST_SPACE } from '../common/CommonConstants';
import { CampusGoodsDataSource } from '../viewmodel/CampusGoodsDataSource';
import { GoodsModel } from '../viewmodel/GoodsModel';
import { BottomTip } from './BottomTip';
import { EmptyView } from './EmptyView';
import { GoodsCardComponent } from './GoodsCardComponent';

@Component
export struct GoodsListComponent {
  @ObjectLink dataSource: CampusGoodsDataSource;
  @Prop currentRegionId: string = 'all';
  @Prop hasLocatedPoint: boolean = false;
  onLoadMore: () => void = () => {};

  build() {
    Column() {
      if (this.dataSource.isEmpty()) {
        EmptyView()
      } else {
        List({ space: LIST_SPACE }) {
          LazyForEach(this.dataSource, (item: GoodsModel) => {
            ListItem() {
              GoodsCardComponent({
                goods: item,
                currentRegionId: this.currentRegionId,
                hasLocatedPoint: this.hasLocatedPoint
              })
            }
          }, (item: GoodsModel) => item.id)

          ListItem() {
            BottomTip({ hasMore: this.dataSource.hasMore() })
          }
        }
        .width('100%')
        .edgeEffect(EdgeEffect.Spring)
        .onReachEnd(() => {
          this.onLoadMore();
        })
      }
    }
    .width('100%')
    .layoutWeight(1)
  }
}
