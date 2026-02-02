import { HttpUtil } from '../utils/HttpUtil';
import { WallhavenResponse, WallpaperApiItem, SearchParams, WallpaperItem } from '../model/WallpaperModel';

const WALLHAVEN_API_BASE_URL = 'https://wallhaven.cc/api/v1';

// 定义壁纸详情响应数据结构
interface WallpaperDetailResponse {
  data: WallpaperApiItem;
}

/**
 * Wallhaven API服务类
 */
export class WallhavenService {
  private apiKey: string | undefined;

  constructor(apiKey?: string) {
    this.apiKey = apiKey;
    console.info(`[WallhavenService] Service initialized ${apiKey ? 'with API key' : 'without API key'}`);
  }

  /**
   * 构建查询参数字符串
   * @param params 搜索参数
   */
  private buildQueryString(params?: SearchParams): string {
    const queryParts: string[] = [];
    
    if (params) {
      if (params.q) queryParts.push(`q=${encodeURIComponent(params.q)}`);
      if (params.categories) queryParts.push(`categories=${params.categories}`);
      if (params.purity) queryParts.push(`purity=${params.purity}`);
      if (params.sorting) queryParts.push(`sorting=${params.sorting}`);
      if (params.order) queryParts.push(`order=${params.order}`);
      if (params.topRange) queryParts.push(`topRange=${params.topRange}`);
      if (params.atleast) queryParts.push(`atleast=${params.atleast}`);
      if (params.resolutions) queryParts.push(`resolutions=${params.resolutions}`);
      if (params.ratios) queryParts.push(`ratios=${params.ratios}`);
      if (params.colors) queryParts.push(`colors=${params.colors}`);
      if (params.page) queryParts.push(`page=${params.page.toString()}`);
      if (params.seed) queryParts.push(`seed=${params.seed}`);
    }

    // 添加API密钥
    if (this.apiKey) {
      queryParts.push(`apikey=${this.apiKey}`);
    }

    const queryString = queryParts.length > 0 ? queryParts.join('&') : '';
    console.info(`[WallhavenService] Query string built: ${queryString}`);
    
    return queryString;
  }

  /**
   * 验证API响应数据的完整性
   * @param apiItem API返回的壁纸数据
   */
  private isValidWallpaperData(apiItem: WallpaperApiItem): boolean {
    if (!apiItem) {
      console.warn('[WallhavenService] Invalid wallpaper data: null or undefined');
      return false;
    }
    
    if (!apiItem.id) {
      console.warn('[WallhavenService] Invalid wallpaper data: missing id');
      return false;
    }
    
    if (!apiItem.path) {
      console.warn('[WallhavenService] Invalid wallpaper data: missing path');
      return false;
    }
    
    // 根据Wallhaven API文档，使用dimension_x和dimension_y字段
    if (apiItem.dimension_x === undefined || apiItem.dimension_y === undefined) {
      console.warn('[WallhavenService] Invalid wallpaper data: missing dimension_x or dimension_y');
      console.debug('[WallhavenService] Available fields:', Object.keys(apiItem).join(', '));
      return false;
    }
    
    return true;
  }

  /**
   * 搜索壁纸
   * @param params 搜索参数
   */
  async searchWallpapers(params?: SearchParams): Promise<WallpaperItem[]> {
    console.info(`[WallhavenService] Searching wallpapers with params:`, params);
    
    try {
      const queryString = this.buildQueryString(params);
      const url = queryString ? `${WALLHAVEN_API_BASE_URL}/search?${queryString}` : `${WALLHAVEN_API_BASE_URL}/search`;
      
      console.info(`[WallhavenService] Request URL: ${url}`);
      
      const responseData = await HttpUtil.doGet(url);
      console.info(`[WallhavenService] Raw API response received, length: ${responseData.length} characters`);
      
      const wallhavenResponse: WallhavenResponse = JSON.parse(responseData);
      
      if (!wallhavenResponse.data || !Array.isArray(wallhavenResponse.data)) {
        console.error('[WallhavenService] Invalid API response: data field is missing or not an array');
        console.debug('[WallhavenService] Full response structure:', JSON.stringify(wallhavenResponse));
        return [];
      }
      
      console.info(`[WallhavenService] Search successful, found ${wallhavenResponse.data.length} wallpapers`);
      
      // 详细检查第一个壁纸的数据结构
      if (wallhavenResponse.data.length > 0) {
        const firstItem = wallhavenResponse.data[0];
        console.debug('[WallhavenService] First wallpaper data preview:', JSON.stringify({
          id: firstItem.id,
          path: firstItem.path,
          dimension_x: firstItem.dimension_x,
          dimension_y: firstItem.dimension_y,
          resolution: firstItem.resolution
        }));
      }
      
      // 将API响应转换为应用内部使用的壁纸数据结构
      const wallpaperItems: WallpaperItem[] = [];
      let validCount = 0;
      let invalidCount = 0;
      
      for (const item of wallhavenResponse.data) {
        if (this.isValidWallpaperData(item)) {
          const convertedItem = this.convertToWallpaperItem(item);
          if (convertedItem) {
            wallpaperItems.push(convertedItem);
            validCount++;
          } else {
            invalidCount++;
          }
        } else {
          console.warn(`[WallhavenService] Skipping invalid wallpaper data: ${item.id || 'unknown'}`);
          invalidCount++;
        }
      }
      
      console.info(`[WallhavenService] Successfully converted ${validCount} wallpaper items, skipped ${invalidCount}`);
      
      return wallpaperItems;
    } catch (error) {
      console.error('[WallhavenService] Search failed:', error);
      // 不重新抛出错误，返回空数组
      console.warn('[WallhavenService] Returning empty array due to search failure');
      return [];
    }
  }

  /**
   * 获取壁纸详情
   * @param id 壁纸ID
   */
  async getWallpaperById(id: string): Promise<WallpaperItem | null> {
    console.info(`[WallhavenService] Getting wallpaper details for ID: ${id}`);
    
    try {
      const apiKeyParam = this.apiKey ? `apikey=${this.apiKey}` : '';
      const queryString = apiKeyParam ? `?${apiKeyParam}` : '';
      const url = `${WALLHAVEN_API_BASE_URL}/w/${id}${queryString}`;
      
      console.info(`[WallhavenService] Detail request URL: ${url}`);
        
      const responseData = await HttpUtil.doGet(url);
      const wallpaperData: WallpaperDetailResponse = JSON.parse(responseData);
      
      if (!this.isValidWallpaperData(wallpaperData.data)) {
        console.error(`[WallhavenService] Invalid wallpaper detail data for ID: ${id}`);
        return null;
      }
      
      console.info(`[WallhavenService] Successfully retrieved details for wallpaper ${id}`);
      
      return this.convertToWallpaperItem(wallpaperData.data);
    } catch (error) {
      console.error(`[WallhavenService] Failed to get wallpaper ${id}:`, error);
      // 不重新抛出错误，返回null
      console.warn(`[WallhavenService] Returning null for wallpaper ${id}`);
      return null;
    }
  }

  /**
   * 将API响应数据转换为应用内部使用的壁纸数据结构
   * @param apiItem API返回的壁纸数据
   */
  private convertToWallpaperItem(apiItem: WallpaperApiItem): WallpaperItem | null {
    try {
      // 使用dimension_x和dimension_y字段获取尺寸信息
      const width = apiItem.dimension_x;
      const height = apiItem.dimension_y;
      
      // 计算宽高比
      const aspectRatio = width / height;

      // 计算预览高度（基于固定宽度 150，根据宽高比计算高度）
      // 瀑布流布局：宽度固定，高度根据图片原始比例计算
      const CARD_WIDTH = 150;
      const calculatedHeight = Math.round(CARD_WIDTH / aspectRatio);
      
      const wallpaperItem: WallpaperItem = {
        id: apiItem.id,
        name: `Wallpaper ${apiItem.id}`,
        imageUrl: apiItem.path, // 使用原图路径
        width: width,
        height: height,
        aspectRatio: aspectRatio,
        calculatedHeight: calculatedHeight,
        uploader: apiItem.uploader?.username || 'Unknown',
        tags: apiItem.tags?.map(tag => tag.name) || [],
        favorites: apiItem.favorites || 0,
        purity: apiItem.purity || 'sfw',
        category: apiItem.category || 'general',
        colors: apiItem.colors || [],
        resolution: apiItem.resolution || `${width}x${height}`
      };

      console.debug(`[WallhavenService] Converted wallpaper: ${apiItem.id}, dimensions: ${width}x${height}, aspect ratio: ${aspectRatio.toFixed(2)}`);

      return wallpaperItem;
    } catch (error) {
      console.error(`[WallhavenService] Failed to convert wallpaper data for ID: ${apiItem.id}`, error);
      return null;
    }
  }
}