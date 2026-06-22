export class FavoriteStore {
  private static favoriteIds: string[] = [];

  static isFavorite(goodsId: string): boolean {
    return FavoriteStore.favoriteIds.includes(goodsId);
  }

  static toggle(goodsId: string): boolean {
    const index = FavoriteStore.favoriteIds.indexOf(goodsId);
    if (index >= 0) {
      FavoriteStore.favoriteIds.splice(index, 1);
      return false;
    }
    FavoriteStore.favoriteIds.push(goodsId);
    return true;
  }

  static remove(goodsId: string): void {
    const index = FavoriteStore.favoriteIds.indexOf(goodsId);
    if (index >= 0) {
      FavoriteStore.favoriteIds.splice(index, 1);
    }
  }

  static getIds(): string[] {
    return FavoriteStore.favoriteIds.slice();
  }
}
