import { TEXT_MUTED, TEXT_SECONDARY } from '../common/CommonConstants';

@Component
export struct EmptyView {
  message: string = '暂无符合条件的校园好物';
  description: string = '可以更换关键词或切换其他分类再试试';

  build() {
    Column() {
      Text('空')
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor(TEXT_MUTED)
        .width(72)
        .height(72)
        .textAlign(TextAlign.Center)
        .backgroundColor('#EEF2F6')
        .borderRadius(36)
        .margin({ bottom: 16 })

      Text(this.message)
        .fontSize(17)
        .fontWeight(FontWeight.Medium)
        .fontColor(TEXT_SECONDARY)

      Text(this.description)
        .fontSize(13)
        .fontColor(TEXT_MUTED)
        .margin({ top: 8 })
    }
    .width('100%')
    .height(260)
    .justifyContent(FlexAlign.Center)
  }
}
