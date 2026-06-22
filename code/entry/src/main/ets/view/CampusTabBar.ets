import { CATEGORIES, FULL_SIZE, REFRESH_DISTANCE, REFRESH_TIME, TAB_BAR_HEIGHT, TEXT_MUTED, TEXT_PRIMARY } from '../common/CommonConstants';
import { CampusGoodsDataSource } from '../viewmodel/CampusGoodsDataSource';
import { GoodsListComponent } from './GoodsListComponent';
import { PullRefreshLayout } from './PullRefreshLayout';

@Component
export struct CampusTabBar {
  @Link @Watch('onKeywordChange') keyword: string;
  @Link @Watch('onRegionChange') regionId: string;
  @State currentIndex: number = 0;
  @State refreshStatus: boolean = false;
  @State currentCategory: string = '全部';
  @State dataSource: CampusGoodsDataSource = new CampusGoodsDataSource();
  private startY: number = 0;
  private timer: number = 0;

  aboutToAppear(): void {
    this.dataSource.updateRegion(this.regionId);
    this.dataSource.updateFilter(this.keyword, this.currentCategory);
  }

  aboutToDisappear(): void {
    clearTimeout(this.timer);
  }

  private updateData(category: string): void {
    this.currentCategory = category;
    this.dataSource.updateFilter(this.keyword, category);
  }

  onKeywordChange(): void {
    this.dataSource.updateFilter(this.keyword, this.currentCategory);
  }

  onRegionChange(): void {
    this.dataSource.updateRegion(this.regionId);
  }

  private handleTouch(event?: TouchEvent): void {
    if (event === undefined) {
      return;
    }
    switch (event.type) {
      case TouchType.Down:
        this.startY = event.touches[0].y;
        break;
      case TouchType.Move:
        this.refreshStatus = event.touches[0].y - this.startY > REFRESH_DISTANCE;
        break;
      case TouchType.Up:
        if (this.refreshStatus) {
          this.dataSource.refresh();
          this.timer = setTimeout(() => {
            this.refreshStatus = false;
          }, REFRESH_TIME);
        }
        break;
      default:
        break;
    }
  }

  @Builder
  tabBuilder(title: string, index: number) {
    Column() {
      Text(title)
        .fontSize(this.currentIndex === index ? 18 : 15)
        .fontWeight(this.currentIndex === index ? FontWeight.Bold : FontWeight.Regular)
        .fontColor(this.currentIndex === index ? TEXT_PRIMARY : TEXT_MUTED)
        .height(TAB_BAR_HEIGHT)
        .textAlign(TextAlign.Center)
        .padding({ left: 14, right: 14 })
    }
    .height(TAB_BAR_HEIGHT)
    .justifyContent(FlexAlign.Center)
  }

  build() {
    Tabs({ barPosition: BarPosition.Start }) {
      ForEach(CATEGORIES, (category: string, index: number) => {
        TabContent() {
          Column() {
            if (this.refreshStatus) {
              PullRefreshLayout()
                .margin({ bottom: 10 })
            }
            GoodsListComponent({
              dataSource: this.dataSource,
              currentRegionId: this.regionId,
              onLoadMore: () => {
                this.dataSource.loadMore();
              }
            })
          }
          .width(FULL_SIZE)
          .height(FULL_SIZE)
          .onTouch((event?: TouchEvent) => {
            this.handleTouch(event);
          })
        }
        .tabBar(this.tabBuilder(category, index))
      }, (category: string) => category)
    }
    .barHeight(TAB_BAR_HEIGHT)
    .barMode(BarMode.Scrollable)
    .vertical(false)
    .onChange((index: number) => {
      this.currentIndex = index;
      this.updateData(CATEGORIES[index]);
    })
    .onAnimationStart((_index: number, targetIndex: number, _event: TabsAnimationEvent) => {
      this.currentIndex = targetIndex;
      this.updateData(CATEGORIES[targetIndex]);
    })
    .width(FULL_SIZE)
    .layoutWeight(1)
  }
}
