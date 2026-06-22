import { INITIAL_PAGE_SIZE, LOAD_PAGE_SIZE, MAX_VISIBLE_COUNT } from '../common/CommonConstants';
import { campusGoodsList, filterGoodsByRegion } from './CampusGoodsData';
import { GoodsModel } from './GoodsModel';

class BasicDataSource implements IDataSource {
  private listeners: DataChangeListener[] = [];

  public totalCount(): number {
    return 0;
  }

  public getData(_index: number): GoodsModel | undefined {
    return undefined;
  }

  registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) < 0) {
      this.listeners.push(listener);
    }
  }

  unregisterDataChangeListener(listener: DataChangeListener): void {
    const index = this.listeners.indexOf(listener);
    if (index >= 0) {
      this.listeners.splice(index, 1);
    }
  }

  notifyDataReload(): void {
    this.listeners.forEach((listener: DataChangeListener) => {
      listener.onDataReloaded();
    });
  }

  notifyDataAdd(index: number): void {
    this.listeners.forEach((listener: DataChangeListener) => {
      listener.onDataAdd(index);
    });
  }

  notifyDataChange(index: number): void {
    this.listeners.forEach((listener: DataChangeListener) => {
      listener.onDataChange(index);
    });
  }

  notifyDataDelete(index: number): void {
    this.listeners.forEach((listener: DataChangeListener) => {
      listener.onDataDelete(index);
    });
  }

  notifyDataMove(from: number, to: number): void {
    this.listeners.forEach((listener: DataChangeListener) => {
      listener.onDataMove(from, to);
    });
  }
}

export class CampusGoodsDataSource extends BasicDataSource {
  private allData: GoodsModel[] = campusGoodsList;
  private visibleData: GoodsModel[] = campusGoodsList.slice(0, INITIAL_PAGE_SIZE);
  private keyword: string = '';
  private category: string = '全部';
  private regionId: string = 'all';
  private visibleCount: number = INITIAL_PAGE_SIZE;

  public totalCount(): number {
    return this.visibleData.length;
  }

  public getData(index: number): GoodsModel {
    return this.visibleData[index];
  }

  public isEmpty(): boolean {
    return this.visibleData.length === 0;
  }

  public hasMore(): boolean {
    return this.visibleData.length < this.allData.length && this.visibleData.length < MAX_VISIBLE_COUNT;
  }

  public updateFilter(keyword: string, category: string): void {
    this.keyword = keyword;
    this.category = category;
    this.visibleCount = INITIAL_PAGE_SIZE;
    this.reloadData();
  }

  public updateRegion(regionId: string): void {
    this.regionId = regionId;
    this.visibleCount = INITIAL_PAGE_SIZE;
    this.reloadData();
  }

  public refresh(): void {
    this.visibleCount = INITIAL_PAGE_SIZE;
    this.reloadData();
  }

  public loadMore(): void {
    if (!this.hasMore()) {
      return;
    }
    this.visibleCount = Math.min(this.visibleCount + LOAD_PAGE_SIZE, this.allData.length, MAX_VISIBLE_COUNT);
    this.reloadData();
  }

  private reloadData(): void {
    this.allData = filterGoodsByRegion(this.keyword, this.category, this.regionId);
    this.visibleData = this.allData.slice(0, this.visibleCount);
    this.notifyDataReload();
  }
}
