import { LlmPricingProvider } from './LlmPricingProvider';
import { PricingContextService } from './PricingContextService';
import { PricingRequest, PricingResult } from '../viewmodel/PricingModel';

export class PricingService {
  static async estimate(request: PricingRequest): Promise<PricingResult> {
    if (request.title.trim().length === 0 || request.originalPrice <= 0) {
      return new PricingResult(
        false,
        '-',
        '-',
        '-',
        '-',
        '商品名称和原价是生成定价建议的必要信息。',
        '请补充商品名称，并填写大于 0 的原价后重试。',
        '输入信息不足时，不建议直接给出价格。'
      );
    }

    request.context = PricingContextService.buildContext(
      request.category,
      request.currentRegionId,
      request.goodsRegionIds
    );

    return LlmPricingProvider.estimateWithLlm(request);
  }
}
