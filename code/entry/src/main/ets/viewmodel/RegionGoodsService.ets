import { CampusRegion } from './CampusRegion';
import { GoodsModel } from './GoodsModel';

export class RegionRecommendSummary {
  regionId: string;
  regionName: string;
  goodsCount: number;
  reason: string;
  tradeAdvice: string;

  constructor(regionId: string, regionName: string, goodsCount: number, reason: string, tradeAdvice: string) {
    this.regionId = regionId;
    this.regionName = regionName;
    this.goodsCount = goodsCount;
    this.reason = reason;
    this.tradeAdvice = tradeAdvice;
  }
}

export class RegionGoodsService {
  static filterGoodsForRegion(goodsList: GoodsModel[], regionId: string, keyword: string, category: string): GoodsModel[] {
    return goodsList.filter((item: GoodsModel) => {
      const regionMatched = regionId.length === 0 || regionId === 'all' || item.regionIds.includes(regionId);
      return regionMatched && item.matches(keyword, category);
    });
  }

  static buildSummary(goodsList: GoodsModel[], region: CampusRegion): RegionRecommendSummary {
    const matchedCount = region.id === 'all'
      ? goodsList.length
      : goodsList.filter((item: GoodsModel) => item.regionIds.includes(region.id)).length;

    return new RegionRecommendSummary(
      region.id,
      region.shortName,
      matchedCount,
      region.tradeAdvice,
      region.fallbackAdvice
    );
  }
}
