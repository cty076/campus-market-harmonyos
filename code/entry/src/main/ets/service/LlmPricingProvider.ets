import { http } from '@kit.NetworkKit';
import { DEEPSEEK_API_KEY, DEEPSEEK_CHAT_COMPLETIONS_URL, DEEPSEEK_MODEL } from '../common/ApiConfig';
import { PricingRequest, PricingResult } from '../viewmodel/PricingModel';

class DeepSeekMessage {
  role: string;
  content: string;

  constructor(role: string, content: string) {
    this.role = role;
    this.content = content;
  }
}

class DeepSeekResponseFormat {
  type: string = 'json_object';
}

class DeepSeekRequestBody {
  model: string = DEEPSEEK_MODEL;
  messages: DeepSeekMessage[];
  temperature: number = 0.2;
  response_format: DeepSeekResponseFormat = new DeepSeekResponseFormat();

  constructor(messages: DeepSeekMessage[]) {
    this.messages = messages;
  }
}

interface DeepSeekChoiceMessage {
  content?: string;
}

interface DeepSeekChoice {
  message?: DeepSeekChoiceMessage;
}

interface DeepSeekResponse {
  choices?: DeepSeekChoice[];
}

interface PricingJson {
  suggestedPrice?: Object | string | number;
  priceRange?: Object | string | number;
  confidence?: Object | string | number;
  marketReference?: Object | string | number;
  reason?: Object | string | number;
  bargainAdvice?: Object | string | number;
  riskTip?: Object | string | number;
}

function buildPrompt(request: PricingRequest): string {
  const context = request.context;
  const contextText = context === undefined ? '暂无本地市场上下文' : `当前定位学校：${context.currentRegionName}
商品所属学校：${context.goodsRegionNames}
当前挂牌价：${request.listedPrice}
同类商品数量：${context.sameCategoryCount}
同校同类商品数量：${context.sameCampusCategoryCount}
同类商品均价：${context.sameCategoryAveragePrice}
同类商品最低价：${context.sameCategoryMinPrice}
同类商品最高价：${context.sameCategoryMaxPrice}
交易匹配提示：${context.tradeMatchText}`;

  return `请为校园二手交易商品生成定价建议，只返回 JSON，不要输出 Markdown。
JSON 字段必须是 suggestedPrice、priceRange、confidence、marketReference、reason、bargainAdvice、riskTip。
字段值必须是字符串，不要返回嵌套对象。

商品名称：${request.title}
商品分类：${request.category}
当前成色：${request.condition}
原价：${request.originalPrice}
使用时间（月）：${request.usageMonths}
商品描述：${request.description}

校园市场上下文：
${contextText}

定价要求：
1. suggestedPrice 给出一个建议成交价，格式类似 ¥68。
2. priceRange 给出合理区间，格式类似 ¥60 - ¥75。
3. confidence 只能是 高 / 中 / 低。
4. marketReference 说明如何参考同类商品数量、均价和同校商品数量。
5. reason 解释折旧、成色、类别和校园交易便利性。
6. bargainAdvice 给出卖家挂牌和买家议价建议。
7. riskTip 提醒版本、配件、磨损、线下验货等风险。`;
}

function normalizePricingText(value: Object | string | number | undefined, fallback: string): string {
  if (value === undefined || value === null) {
    return fallback;
  }

  if (typeof value === 'string') {
    return value.length === 0 ? fallback : value;
  }

  if (typeof value === 'number') {
    return `¥${value}`;
  }

  if (Array.isArray(value)) {
    return value.map((item: Object | string | number) => normalizePricingText(item, '')).filter((item: string) => {
      return item.length > 0;
    }).join(' - ');
  }

  const record = value as Record<string, Object | string | number>;
  const minValue = record.min ?? record.low ?? record.lower ?? record.start;
  const maxValue = record.max ?? record.high ?? record.upper ?? record.end;
  if (minValue !== undefined && maxValue !== undefined) {
    return `${normalizePricingText(minValue, '')} - ${normalizePricingText(maxValue, '')}`;
  }

  const textValue = record.text ?? record.value ?? record.price ?? record.range ?? record.amount;
  if (textValue !== undefined) {
    return normalizePricingText(textValue, fallback);
  }

  return JSON.stringify(value);
}

function toPricingResult(content: string): PricingResult {
  const parsed = JSON.parse(content) as PricingJson;
  return new PricingResult(
    true,
    normalizePricingText(parsed.suggestedPrice, '-'),
    normalizePricingText(parsed.priceRange, '-'),
    normalizePricingText(parsed.confidence, '中'),
    normalizePricingText(parsed.marketReference, '已结合本地同类商品价格进行参考。'),
    normalizePricingText(parsed.reason, 'DeepSeek 已返回定价建议，但理由字段为空。'),
    normalizePricingText(parsed.bargainAdvice, '建议结合校内同类商品价格进行议价。'),
    normalizePricingText(parsed.riskTip, 'AI 定价仅作参考，最终成交价以买卖双方沟通为准。')
  );
}

export class LlmPricingProvider {
  static async estimateWithLlm(request: PricingRequest): Promise<PricingResult> {
    const httpRequest = http.createHttp();
    const body = new DeepSeekRequestBody([
      new DeepSeekMessage('system', '你是校园二手商品定价助手，必须输出严格 JSON。'),
      new DeepSeekMessage('user', buildPrompt(request))
    ]);

    try {
      const response = await httpRequest.request(DEEPSEEK_CHAT_COMPLETIONS_URL, {
        method: http.RequestMethod.POST,
        header: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${DEEPSEEK_API_KEY}`
        },
        extraData: JSON.stringify(body),
        readTimeout: 30000,
        connectTimeout: 30000
      });

      const responseText = typeof response.result === 'string' ? response.result : JSON.stringify(response.result);
      const responseJson = JSON.parse(responseText) as DeepSeekResponse;
      const content = responseJson.choices?.[0]?.message?.content;
      if (content === undefined || content.length === 0) {
        throw new Error('DeepSeek response content is empty');
      }

      return toPricingResult(content);
    } catch (err) {
      return new PricingResult(
        false,
        '-',
        '-',
        '-',
        '-',
        `DeepSeek 定价接口调用失败：${JSON.stringify(err)}`,
        '请检查网络、API Key、模型名称和接口额度后重试。',
        '接口失败时不使用本地假数据，避免误导定价。'
      );
    } finally {
      httpRequest.destroy();
    }
  }
}
