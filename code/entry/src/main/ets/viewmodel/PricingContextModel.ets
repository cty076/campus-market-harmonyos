export class PricingContext {
  currentRegionId: string;
  currentRegionName: string;
  goodsRegionNames: string;
  sameCategoryCount: number;
  sameCampusCategoryCount: number;
  sameCategoryAveragePrice: number;
  sameCategoryMinPrice: number;
  sameCategoryMaxPrice: number;
  tradeMatchText: string;

  constructor(
    currentRegionId: string,
    currentRegionName: string,
    goodsRegionNames: string,
    sameCategoryCount: number,
    sameCampusCategoryCount: number,
    sameCategoryAveragePrice: number,
    sameCategoryMinPrice: number,
    sameCategoryMaxPrice: number,
    tradeMatchText: string
  ) {
    this.currentRegionId = currentRegionId;
    this.currentRegionName = currentRegionName;
    this.goodsRegionNames = goodsRegionNames;
    this.sameCategoryCount = sameCategoryCount;
    this.sameCampusCategoryCount = sameCampusCategoryCount;
    this.sameCategoryAveragePrice = sameCategoryAveragePrice;
    this.sameCategoryMinPrice = sameCategoryMinPrice;
    this.sameCategoryMaxPrice = sameCategoryMaxPrice;
    this.tradeMatchText = tradeMatchText;
  }
}
