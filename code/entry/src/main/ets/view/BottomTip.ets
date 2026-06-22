import { TEXT_MUTED } from '../common/CommonConstants';

@Component
export struct BottomTip {
  hasMore: boolean = false;

  build() {
    Row() {
      Text(this.hasMore ? '继续上滑加载更多' : '已经到底了')
        .fontSize(13)
        .fontColor(TEXT_MUTED)
    }
    .width('100%')
    .height(48)
    .justifyContent(FlexAlign.Center)
  }
}
