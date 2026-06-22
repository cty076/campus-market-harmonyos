export class GoodsModel {
  id: string;
  title: string;
  category: string;
  price: string;
  condition: string;
  description: string;
  seller: string;
  publishTime: string;
  image: Resource;
  tags: string[];
  regionIds: string[];

  constructor(
    id: string,
    title: string,
    category: string,
    price: string,
    condition: string,
    description: string,
    seller: string,
    publishTime: string,
    image: Resource,
    tags: string[],
    regionIds: string[] = []
  ) {
    this.id = id;
    this.title = title;
    this.category = category;
    this.price = price;
    this.condition = condition;
    this.description = description;
    this.seller = seller;
    this.publishTime = publishTime;
    this.image = image;
    this.tags = tags;
    this.regionIds = regionIds;
  }

  matches(keyword: string, category: string): boolean {
    const normalizedKeyword = keyword.trim().toLowerCase();
    const categoryMatched = category === '全部' || this.category === category;
    if (!categoryMatched) {
      return false;
    }

    if (normalizedKeyword.length === 0) {
      return true;
    }

    const searchableText =
      `${this.title} ${this.category} ${this.condition} ${this.description} ${this.seller} ${this.tags.join(' ')}`.toLowerCase();
    return searchableText.includes(normalizedKeyword);
  }
}
