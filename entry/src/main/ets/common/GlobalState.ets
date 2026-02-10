/**
 * 全局状态管理中心 (API 12+ 状态管理 V2)
 * 用于跨页面同步收藏状态、网络状态等
 */
@ObservedV2
export class GlobalState {
  private static instance: GlobalState | null = null;

  // 使用 @Trace 标记需要响应式更新的属性
  @Trace isOffline: boolean = false;
  
  /**
   * 存储已收藏壁纸的 ID 集合
   * 使用 Set 提高查询效率
   */
  @Trace favoriteIds: Set<string> = new Set();

  private constructor() {}

  /**
   * 获取单例实例
   */
  public static getInstance(): GlobalState {
    if (!GlobalState.instance) {
      GlobalState.instance = new GlobalState();
    }
    return GlobalState.instance;
  }

  /**
   * 更新收藏状态
   * @param id 壁纸 ID
   * @param isFav 是否收藏
   */
  public updateFavoriteStatus(id: string, isFav: boolean) {
    if (isFav) {
      this.favoriteIds.add(id);
    } else {
      this.favoriteIds.delete(id);
    }
  }

  /**
   * 检查是否已收藏
   * @param id 壁纸 ID
   * @returns boolean
   */
  public isFavorite(id: string): boolean {
    return this.favoriteIds.has(id);
  }

  /**
   * 批量初始化收藏状态
   * @param ids ID 数组
   */
  public initFavorites(ids: string[]) {
    this.favoriteIds = new Set(ids);
  }
}

// 导出单例方便直接使用
export const globalState = GlobalState.getInstance();
