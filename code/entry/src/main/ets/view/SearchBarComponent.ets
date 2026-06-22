import { CARD_RADIUS, DIVIDER_COLOR, SEARCH_HEIGHT, TEXT_MUTED } from '../common/CommonConstants';

@Component
export struct SearchBarComponent {
  @Link keyword: string;

  build() {
    Row() {
      Text('搜索')
        .fontSize(14)
        .fontColor(TEXT_MUTED)
        .margin({ left: 12, right: 8 })

      TextInput({ placeholder: '搜索教材、考研资料、宿舍用品', text: this.keyword })
        .fontSize(15)
        .height(SEARCH_HEIGHT)
        .backgroundColor(Color.Transparent)
        .layoutWeight(1)
        .padding({ left: 0, right: 8 })
        .onChange((value: string) => {
          this.keyword = value;
        })
    }
    .height(SEARCH_HEIGHT)
    .width('100%')
    .backgroundColor('#EEF2F6')
    .borderRadius(CARD_RADIUS)
    .border({ width: 1, color: DIVIDER_COLOR })
  }
}
