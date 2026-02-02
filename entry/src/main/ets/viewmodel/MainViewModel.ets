import { WallpaperItem, SearchParams } from '../model/WallpaperModel';
import { WallhavenService } from '../service/WallhavenService';
import { AppConfig } from '../utils/AppConfig';
import { WallpaperDataSource } from '../model/WallpaperDataSource';

@Observed
export class MainViewModel {
  // 数据源 (用于 LazyForEach)
  dataSource: WallpaperDataSource = new WallpaperDataSource();
  
  // 页面状态
  isLoading: boolean = false;
  isLoadingMore: boolean = false;
  errorMessage: string = '';
  currentPage: number = 1;
  hasMoreData: boolean = true;

  // 筛选条件状态 (多选)
  isCategoryGeneral: boolean = true;
  isCategoryAnime: boolean = true;
  isCategoryPeople: boolean = true;

  isPuritySFW: boolean = true;
  isPuritySketchy: boolean = false;
  isPurityNSFW: boolean = false;

  isFilterExpanded: boolean = false;
  selectedSorting: string = 'date_added';
  selectedOrder: string = 'desc';
  selectedTopRange: string = '1M'; // Default for Toplist
  selectedResolution: string = '';
  selectedRatio: string = '';

  private wallhavenService: WallhavenService = AppConfig.getInstance().getWallhavenService();

  constructor() {}

  /**
   * 获取分类参数字符串 (e.g. "110")
   */
  getCategoryParam(): string {
    return `${this.isCategoryGeneral ? '1' : '0'}${this.isCategoryAnime ? '1' : '0'}${this.isCategoryPeople ? '1' : '0'}`;
  }

  /**
   * 获取纯净度参数字符串 (e.g. "100")
   */
  getPurityParam(): string {
    return `${this.isPuritySFW ? '1' : '0'}${this.isPuritySketchy ? '1' : '0'}${this.isPurityNSFW ? '1' : '0'}`;
  }

  /**
   * 加载壁纸
   * @param isLoadMore 是否为加载更多
   */
  async loadWallpapers(isLoadMore: boolean = false) {
    if (this.isLoading || this.isLoadingMore) return;

    if (isLoadMore) {
      this.isLoadingMore = true;
    } else {
      this.isLoading = true;
      this.currentPage = 1;
      this.hasMoreData = true;
    }
    this.errorMessage = '';

    try {
      console.info(`[ViewModel] 开始加载壁纸，页码: ${this.currentPage}`);

      const searchParams: SearchParams = {
        purity: this.getPurityParam(),
        sorting: this.selectedSorting,
        order: this.selectedOrder,
        categories: this.getCategoryParam(),
        page: this.currentPage,
        topRange: this.selectedSorting === 'toplist' ? this.selectedTopRange : undefined,
        resolutions: this.selectedResolution || undefined,
        ratios: this.selectedRatio || undefined
      };

      const newWallpapers = await this.wallhavenService.searchWallpapers(searchParams);
      console.info(`[ViewModel] 壁纸加载完成，本页共 ${newWallpapers.length} 张`);

      if (isLoadMore) {
        this.dataSource.appendData(newWallpapers);
      } else {
        this.dataSource.setData(newWallpapers);
      }

      if (newWallpapers.length === 0) {
        this.hasMoreData = false;
      }

    } catch (error) {
      console.error('[ViewModel] 加载壁纸失败:', error);
      this.errorMessage = '加载壁纸失败，请检查网络连接';

      if (!isLoadMore) {
        this.dataSource.setData(this.getFallbackWallpapers());
      }
    } finally {
      this.isLoading = false;
      this.isLoadingMore = false;
    }
  }

  async loadMore() {
    if (!this.hasMoreData || this.isLoadingMore || this.isLoading) return;
    this.currentPage++;
    await this.loadWallpapers(true);
  }

  private getFallbackWallpapers(): WallpaperItem[] {
    return [
      {
        id: 'fallback1',
        name: '默认壁纸1',
        imageUrl: 'https://example.com/fallback1.jpg',
        thumbUrl: 'https://example.com/fallback1_thumb.jpg',
        width: 1920,
        height: 1080,
        aspectRatio: 1.78,
        calculatedHeight: 150
      },
      {
        id: 'fallback2',
        name: '默认壁纸2',
        imageUrl: 'https://example.com/fallback2.jpg',
        thumbUrl: 'https://example.com/fallback2_thumb.jpg',
        width: 1920,
        height: 1080,
        aspectRatio: 1.78,
        calculatedHeight: 150
      }
    ];
  }
}
