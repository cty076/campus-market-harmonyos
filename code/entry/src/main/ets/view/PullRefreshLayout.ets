import { PRIMARY_COLOR, SUCCESS_COLOR, TEXT_SECONDARY } from '../common/CommonConstants';

@Component
export struct PullRefreshLayout {
  text: string = '正在刷新校园好物';

  build() {
    Row() {
      LoadingProgress()
        .width(28)
        .height(28)
        .color(PRIMARY_COLOR)
        .margin({ right: 10 })

      Text(this.text)
        .fontSize(14)
        .fontColor(TEXT_SECONDARY)
    }
    .width('100%')
    .height(56)
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#F0F8F4')
    .borderRadius(8)
    .border({ width: 1, color: SUCCESS_COLOR })
  }
}
