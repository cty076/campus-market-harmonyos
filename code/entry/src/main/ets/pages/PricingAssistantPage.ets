import {
  CARD_BACKGROUND,
  CARD_PADDING,
  CARD_RADIUS,
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
import { PricingService } from '../service/PricingService';
import { getRegionNameById } from '../viewmodel/CampusRegion';
import { PricingRequest, PricingResult } from '../viewmodel/PricingModel';

@Entry
@Component
struct PricingAssistantPage {
  @State titleValue: string = '';
  @State categoryValue: string = '数码';
  @State conditionValue: string = '八成新';
  @State originalPriceValue: string = '';
  @State usageMonthsValue: string = '6';
  @State descriptionValue: string = '';
  @State listedPriceValue: string = '';
  @State currentRegionId: string = 'all';
  @State goodsRegionIdsValue: string = '';
  @State result: PricingResult | undefined = undefined;
  @State loading: boolean = false;

  aboutToAppear(): void {
    const params = this.getUIContext().getRouter().getParams() as Record<string, string>;
    if (params === undefined) {
      return;
    }

    this.titleValue = params.title === undefined ? this.titleValue : params.title;
    this.categoryValue = params.category === undefined ? this.categoryValue : params.category;
    this.conditionValue = params.condition === undefined ? this.conditionValue : params.condition;
    this.descriptionValue = params.description === undefined ? this.descriptionValue : params.description;
    this.listedPriceValue = params.listedPrice === undefined ? this.listedPriceValue : params.listedPrice;
    this.originalPriceValue = params.price === undefined ? this.originalPriceValue : params.price.replace('¥', '').replace('￥', '').replace('楼', '');
    this.currentRegionId = params.currentRegionId === undefined ? 'all' : params.currentRegionId;
    this.goodsRegionIdsValue = params.goodsRegionIds === undefined ? '' : params.goodsRegionIds;
  }

  private parsePrice(value: string): number {
    const parsed = Number(value.replace('¥', '').replace('￥', '').replace('楼', '').trim());
    return Number.isNaN(parsed) ? 0 : parsed;
  }

  private estimate(): void {
    const originalPrice = this.parsePrice(this.originalPriceValue);
    const listedPrice = this.parsePrice(this.listedPriceValue);
    const usageMonths = Number(this.usageMonthsValue);
    const request = new PricingRequest(
      this.titleValue,
      this.categoryValue,
      this.conditionValue,
      originalPrice,
      Number.isNaN(usageMonths) ? 0 : usageMonths,
      this.descriptionValue,
      listedPrice,
      this.currentRegionId,
      this.goodsRegionIdsValue.length === 0 ? [] : this.goodsRegionIdsValue.split(',')
    );

    this.loading = true;
    PricingService.estimate(request).then((result: PricingResult) => {
      this.result = result;
      this.loading = false;
    }).catch(() => {
      this.result = new PricingResult(
        false,
        '-',
        '-',
        '-',
        '-',
        '定价服务暂时不可用。',
        '请稍后重试，或先参考同类商品价格。',
        '网络或接口异常时不要强行给出价格。'
      );
      this.loading = false;
    });
  }

  @Builder
  FormInput(label: string, value: string, placeholder: string, onChange: (value: string) => void) {
    Column() {
      Text(label)
        .fontSize(13)
        .fontColor(TEXT_MUTED)
        .alignSelf(ItemAlign.Start)
      TextInput({ text: value, placeholder: placeholder })
        .height(42)
        .fontSize(14)
        .backgroundColor('#F7F9FC')
        .borderRadius(6)
        .margin({ top: 6 })
        .onChange((inputValue: string) => {
          onChange(inputValue);
        })
    }
    .width(FULL_SIZE)
    .margin({ bottom: 12 })
  }

  @Builder
  ContextPanel() {
    Column() {
      Text('校园市场上下文')
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .fontColor(TEXT_PRIMARY)
        .alignSelf(ItemAlign.Start)

      Text(`当前定位：${getRegionNameById(this.currentRegionId)} · 商品所属：${this.goodsRegionIdsValue.length === 0 ? '未指定' : this.goodsRegionIdsValue}`)
        .fontSize(13)
        .fontColor(TEXT_SECONDARY)
        .lineHeight(20)
        .margin({ top: 8 })

      Text('系统会结合当前校园、商品所属学校、同类商品均价和挂牌价生成估价建议。')
        .fontSize(12)
        .fontColor(TEXT_MUTED)
        .lineHeight(18)
        .margin({ top: 4 })
    }
    .width(FULL_SIZE)
    .padding(CARD_PADDING)
    .backgroundColor('#F7F9FC')
    .borderRadius(CARD_RADIUS)
    .margin({ bottom: 12 })
  }

  @Builder
  ResultPanel(result: PricingResult) {
    Column() {
      Row() {
        Text('建议成交价')
          .fontSize(15)
          .fontColor(TEXT_SECONDARY)
          .layoutWeight(1)
        Text(result.suggestedPrice)
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor(PRICE_COLOR)
      }
      .width(FULL_SIZE)

      Text('合理区间：' + result.priceRange)
        .fontSize(14)
        .fontColor(SUCCESS_COLOR)
        .margin({ top: 6 })
        .alignSelf(ItemAlign.Start)

      Text('可信度：' + result.confidence)
        .fontSize(14)
        .fontColor(TEXT_SECONDARY)
        .margin({ top: 6 })
        .alignSelf(ItemAlign.Start)

      Text('同类参考：' + result.marketReference)
        .fontSize(14)
        .fontColor(TEXT_SECONDARY)
        .lineHeight(22)
        .margin({ top: 8 })

      Divider()
        .color(DIVIDER_COLOR)
        .margin({ top: 14, bottom: 14 })

      Text('定价理由')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor(TEXT_PRIMARY)
        .alignSelf(ItemAlign.Start)
      Text(result.reason)
        .fontSize(14)
        .lineHeight(22)
        .fontColor(TEXT_SECONDARY)
        .margin({ top: 8 })

      Text('议价建议')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor(TEXT_PRIMARY)
        .margin({ top: 14 })
        .alignSelf(ItemAlign.Start)
      Text(result.bargainAdvice)
        .fontSize(14)
        .lineHeight(22)
        .fontColor(TEXT_SECONDARY)
        .margin({ top: 8 })

      Text(result.riskTip)
        .fontSize(12)
        .fontColor(TEXT_MUTED)
        .lineHeight(18)
        .margin({ top: 12 })
    }
    .width(FULL_SIZE)
    .padding(CARD_PADDING)
    .backgroundColor(CARD_BACKGROUND)
    .borderRadius(CARD_RADIUS)
    .border({ width: 1, color: DIVIDER_COLOR })
    .margin({ top: 14 })
  }

  build() {
    Navigation() {
      Scroll() {
        Column() {
          Text('AI 智能估价')
            .fontSize(26)
            .fontWeight(FontWeight.Bold)
            .fontColor(TEXT_PRIMARY)
            .alignSelf(ItemAlign.Start)

          Text('结合商品信息、校园交易圈和本地同类商品价格，生成更贴近校园二手场景的成交建议。')
            .fontSize(13)
            .fontColor(TEXT_MUTED)
            .lineHeight(20)
            .margin({ top: 6, bottom: 16 })

          Column() {
            this.ContextPanel()

            this.FormInput('商品名称', this.titleValue, '例如：机械键盘 87 键', (value: string) => {
              this.titleValue = value;
            })
            this.FormInput('商品分类', this.categoryValue, '教材 / 考研 / 数码 / 生活 / 运动', (value: string) => {
              this.categoryValue = value;
            })
            this.FormInput('当前成色', this.conditionValue, '例如：八成新', (value: string) => {
              this.conditionValue = value;
            })
            this.FormInput('原价', this.originalPriceValue, '例如：199', (value: string) => {
              this.originalPriceValue = value;
            })
            this.FormInput('当前挂牌价', this.listedPriceValue, '例如：99', (value: string) => {
              this.listedPriceValue = value;
            })
            this.FormInput('使用时间（月）', this.usageMonthsValue, '例如：6', (value: string) => {
              this.usageMonthsValue = value;
            })
            this.FormInput('商品描述', this.descriptionValue, '补充品牌、配件、磨损情况', (value: string) => {
              this.descriptionValue = value;
            })

            Button(this.loading ? '生成中...' : '生成 AI 估价')
              .width(FULL_SIZE)
              .height(46)
              .fontSize(16)
              .fontColor(Color.White)
              .backgroundColor(PRIMARY_COLOR)
              .borderRadius(CARD_RADIUS)
              .enabled(!this.loading)
              .onClick(() => {
                this.estimate();
              })
          }
          .width(FULL_SIZE)
          .padding(CARD_PADDING)
          .backgroundColor(CARD_BACKGROUND)
          .borderRadius(CARD_RADIUS)
          .border({ width: 1, color: DIVIDER_COLOR })

          if (this.result !== undefined) {
            this.ResultPanel(this.result)
          }
        }
        .width(FULL_SIZE)
        .padding(PAGE_PADDING)
      }
      .width(FULL_SIZE)
      .height(FULL_SIZE)
      .backgroundColor(PAGE_BACKGROUND)
    }
    .title('AI 估价')
    .titleMode(NavigationTitleMode.Mini)
  }
}
