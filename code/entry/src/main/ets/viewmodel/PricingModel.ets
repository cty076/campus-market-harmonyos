import { PricingContext } from './PricingContextModel';

export class PricingRequest {
  title: string;
  category: string;
  condition: string;
  originalPrice: number;
  usageMonths: number;
  description: string;
  listedPrice: number;
  currentRegionId: string;
  goodsRegionIds: string[];
  context: PricingContext | undefined;

  constructor(
    title: string,
    category: string,
    condition: string,
    originalPrice: number,
    usageMonths: number,
    description: string,
    listedPrice: number = 0,
    currentRegionId: string = 'all',
    goodsRegionIds: string[] = [],
    context: PricingContext | undefined = undefined
  ) {
    this.title = title;
    this.category = category;
    this.condition = condition;
    this.originalPrice = originalPrice;
    this.usageMonths = usageMonths;
    this.description = description;
    this.listedPrice = listedPrice;
    this.currentRegionId = currentRegionId;
    this.goodsRegionIds = goodsRegionIds;
    this.context = context;
  }
}

export class PricingResult {
  success: boolean;
  suggestedPrice: string;
  priceRange: string;
  confidence: string;
  marketReference: string;
  reason: string;
  bargainAdvice: string;
  riskTip: string;

  constructor(
    success: boolean,
    suggestedPrice: string,
    priceRange: string,
    confidence: string,
    marketReference: string,
    reason: string,
    bargainAdvice: string,
    riskTip: string
  ) {
    this.success = success;
    this.suggestedPrice = suggestedPrice;
    this.priceRange = priceRange;
    this.confidence = confidence;
    this.marketReference = marketReference;
    this.reason = reason;
    this.bargainAdvice = bargainAdvice;
    this.riskTip = riskTip;
  }
}
