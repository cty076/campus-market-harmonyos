import { campusGoodsList } from '../viewmodel/CampusGoodsData';
import { formatRegionNames, getRegionNameById } from '../viewmodel/CampusRegion';
import { GoodsModel } from '../viewmodel/GoodsModel';
import { PricingContext } from '../viewmodel/PricingContextModel';

export class PricingContextService {
  private static parsePrice(priceText: string): number {
    const normalized = priceText
      .replace('¥', '')
      .replace('￥', '')
      .replace('楼', '')
      .trim();
    const value = Number(normalized);
    return Number.isNaN(value) ? 0 : value;
  }

  private static tradeMatchText(currentRegionId: string, goodsRegionIds: string[]): string {
    if (currentRegionId === 'all' || currentRegionId.length === 0) {
      return '当前未限定校园区域，估价以全校二手商品价格作为参考。';
    }

    if (goodsRegionIds.includes(currentRegionId)) {
      return '商品所属学校与当前定位学校一致，适合同校当面验货交易，成交阻力较低。';
    }

    return '商品所属学校与当前定位学校不一致，可能需要跨校沟通交易地点，估价应预留议价空间。';
  }

  static buildContext(category: string, currentRegionId: string, goodsRegionIds: string[]): PricingContext {
    const sameCategoryGoods = campusGoodsList.filter((item: GoodsModel) => item.category === category);
    const prices = sameCategoryGoods
      .map((item: GoodsModel) => PricingContextService.parsePrice(item.price))
      .filter((price: number) => price > 0);
    const sameCampusCategoryCount = currentRegionId === 'all'
      ? sameCategoryGoods.length
      : sameCategoryGoods.filter((item: GoodsModel) => item.regionIds.includes(currentRegionId)).length;
    const sum = prices.reduce((total: number, price: number) => total + price, 0);
    const average = prices.length === 0 ? 0 : Math.round(sum / prices.length);
    const minPrice = prices.length === 0 ? 0 : Math.min(...prices);
    const maxPrice = prices.length === 0 ? 0 : Math.max(...prices);

    return new PricingContext(
      currentRegionId,
      getRegionNameById(currentRegionId),
      formatRegionNames(goodsRegionIds),
      sameCategoryGoods.length,
      sameCampusCategoryCount,
      average,
      minPrice,
      maxPrice,
      PricingContextService.tradeMatchText(currentRegionId, goodsRegionIds)
    );
  }
}
