import relationalStore from '@ohos.data.relationalStore';
import { WallpaperItem } from '../model/WallpaperModel';

/**
 * 收藏实体接口
 */
export interface FavoriteEntity {
  id?: number;              // 数据库自增ID
  wallpaperId: string;      // 壁纸ID
  url: string;              // 原图URL
  thumbnail: string;        // 缩略图URL
  title: string;            // 标题/名称
  author: string;           // 作者
  resolution: string;       // 分辨率
  purity: string;           // 纯净度
  createTime: number;       // 收藏时间戳
}

/**
 * 收藏数据仓库类
 * 使用 RelationalStore (RDB) 管理收藏数据
 */
export class FavoriteRepository {
  private static readonly STORE_NAME = 'favorites.db';
  private static readonly TABLE_NAME = 'favorites';
  private static rdbStore: relationalStore.RdbStore | null = null;

  /**
   * 获取 RDBStore 实例
   */
  private static async getRdbStore(): Promise<relationalStore.RdbStore> {
    if (FavoriteRepository.rdbStore) {
      return FavoriteRepository.rdbStore;
    }

    const STORE_CONFIG: relationalStore.StoreConfig = {
      name: FavoriteRepository.STORE_NAME,
      securityLevel: relationalStore.SecurityLevel.S1
    };

    try {
      FavoriteRepository.rdbStore = await relationalStore.getRdbStore(getContext(), STORE_CONFIG);
      await FavoriteRepository.createTable();
      return FavoriteRepository.rdbStore;
    } catch (error) {
      console.error('[FavoriteRepository] 初始化数据库失败:', error);
      throw new Error('Failed to initialize database');
    }
  }

  /**
   * 创建收藏表
   */
  private static async createTable(): Promise<void> {
    const createTableSql = `
      CREATE TABLE IF NOT EXISTS ${FavoriteRepository.TABLE_NAME} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        wallpaper_id TEXT NOT NULL UNIQUE,
        url TEXT NOT NULL,
        thumbnail TEXT,
        title TEXT,
        author TEXT,
        resolution TEXT,
        purity TEXT,
        create_time INTEGER
      )
    `;

    try {
      await FavoriteRepository.rdbStore?.executeSql(createTableSql);
      console.info('[FavoriteRepository] 收藏表创建成功');
    } catch (error) {
      console.error('[FavoriteRepository] 创建表失败:', error);
    }
  }

  /**
   * 将 WallpaperItem 转换为 FavoriteEntity
   */
  private static toEntity(wallpaper: WallpaperItem): FavoriteEntity {
    return {
      wallpaperId: wallpaper.id,
      url: wallpaper.imageUrl,
      thumbnail: wallpaper.thumbUrl,
      title: wallpaper.name || `Wallpaper ${wallpaper.id}`,
      author: wallpaper.uploader || 'Unknown',
      resolution: wallpaper.resolution || `${wallpaper.width || 0}x${wallpaper.height || 0}`,
      purity: wallpaper.purity || 'sfw',
      createTime: Date.now()
    };
  }

  /**
   * 将数据库记录转换为 FavoriteEntity
   */
  private static fromResultSet(resultSet: relationalStore.ResultSet): FavoriteEntity {
    return {
      id: resultSet.getLong(resultSet.getColumnIndex('id')),
      wallpaperId: resultSet.getString(resultSet.getColumnIndex('wallpaper_id')),
      url: resultSet.getString(resultSet.getColumnIndex('url')),
      thumbnail: resultSet.getString(resultSet.getColumnIndex('thumbnail')),
      title: resultSet.getString(resultSet.getColumnIndex('title')),
      author: resultSet.getString(resultSet.getColumnIndex('author')),
      resolution: resultSet.getString(resultSet.getColumnIndex('resolution')),
      purity: resultSet.getString(resultSet.getColumnIndex('purity')),
      createTime: resultSet.getLong(resultSet.getColumnIndex('create_time'))
    };
  }

  /**
   * 将 FavoriteEntity 转换为 WallpaperItem
   */
  static toWallpaperItem(entity: FavoriteEntity): WallpaperItem {
    // 从分辨率字符串解析宽高
    let width = 1920;
    let height = 1080;
    let aspectRatio = 1.78;

    if (entity.resolution) {
      const parts = entity.resolution.split('x');
      if (parts.length === 2) {
        width = parseInt(parts[0], 10) || 1920;
        height = parseInt(parts[1], 10) || 1080;
        aspectRatio = width / height;
      }
    }

    return {
      id: entity.wallpaperId,
      name: entity.title,
      imageUrl: entity.url,
      thumbUrl: entity.thumbnail,
      resolution: entity.resolution,
      purity: entity.purity,
      uploader: entity.author,
      width: width,
      height: height,
      aspectRatio: aspectRatio,
      calculatedHeight: Math.round(150 / aspectRatio) // 根据实际宽高比计算高度
    };
  }

  /**
   * 添加收藏
   * @param wallpaper 壁纸项
   * @returns 是否添加成功
   */
  static async addFavorite(wallpaper: WallpaperItem): Promise<boolean> {
    try {
      const store = await FavoriteRepository.getRdbStore();
      const entity = FavoriteRepository.toEntity(wallpaper);

      const valueBucket: relationalStore.ValuesBucket = {
        'wallpaper_id': entity.wallpaperId,
        'url': entity.url,
        'thumbnail': entity.thumbnail,
        'title': entity.title,
        'author': entity.author,
        'resolution': entity.resolution,
        'purity': entity.purity,
        'create_time': entity.createTime
      };

      const rowId = await store.insert(FavoriteRepository.TABLE_NAME, valueBucket);
      console.info(`[FavoriteRepository] 添加收藏成功, rowId: ${rowId}`);
      return rowId !== -1;
    } catch (error) {
      // 可能是唯一约束冲突（已存在）
      console.warn('[FavoriteRepository] 添加收藏失败:', error);
      return false;
    }
  }

  /**
   * 移除收藏
   * @param wallpaperId 壁纸ID
   * @returns 是否移除成功
   */
  static async removeFavorite(wallpaperId: string): Promise<boolean> {
    try {
      const store = await FavoriteRepository.getRdbStore();
      const predicates = new relationalStore.RdbPredicates(FavoriteRepository.TABLE_NAME);
      predicates.equalTo('wallpaper_id', wallpaperId);

      const rows = await store.delete(predicates);
      console.info(`[FavoriteRepository] 移除收藏成功, rows: ${rows}`);
      return rows > 0;
    } catch (error) {
      console.error('[FavoriteRepository] 移除收藏失败:', error);
      return false;
    }
  }

  /**
   * 获取所有收藏
   * @returns 收藏列表（时间倒序）
   */
  static async getFavorites(): Promise<FavoriteEntity[]> {
    try {
      const store = await FavoriteRepository.getRdbStore();
      const predicates = new relationalStore.RdbPredicates(FavoriteRepository.TABLE_NAME);
      predicates.orderByDesc('create_time');

      const resultSet = await store.query(predicates, ['*']);
      const favorites: FavoriteEntity[] = [];

      while (resultSet.goToNextRow()) {
        favorites.push(FavoriteRepository.fromResultSet(resultSet));
      }

      resultSet.close();
      console.info(`[FavoriteRepository] 获取收藏列表, 共 ${favorites.length} 条`);
      return favorites;
    } catch (error) {
      console.error('[FavoriteRepository] 获取收藏列表失败:', error);
      return [];
    }
  }

  /**
   * 检查是否已收藏
   * @param wallpaperId 壁纸ID
   * @returns 是否已收藏
   */
  static async isFavorite(wallpaperId: string): Promise<boolean> {
    try {
      const store = await FavoriteRepository.getRdbStore();
      const predicates = new relationalStore.RdbPredicates(FavoriteRepository.TABLE_NAME);
      predicates.equalTo('wallpaper_id', wallpaperId);

      const resultSet = await store.query(predicates, ['id']);
      const hasResult = resultSet.goToFirstRow();
      resultSet.close();

      return hasResult;
    } catch (error) {
      console.error('[FavoriteRepository] 检查收藏状态失败:', error);
      return false;
    }
  }

  /**
   * 切换收藏状态
   * @param wallpaper 壁纸项
   * @returns 操作后的收藏状态（true=已收藏，false=未收藏）
   */
  static async toggleFavorite(wallpaper: WallpaperItem): Promise<boolean> {
    const isFav = await FavoriteRepository.isFavorite(wallpaper.id);

    if (isFav) {
      await FavoriteRepository.removeFavorite(wallpaper.id);
      return false;
    } else {
      await FavoriteRepository.addFavorite(wallpaper);
      return true;
    }
  }

  /**
   * 清空所有收藏
   */
  static async clearAllFavorites(): Promise<void> {
    try {
      const store = await FavoriteRepository.getRdbStore();
      const predicates = new relationalStore.RdbPredicates(FavoriteRepository.TABLE_NAME);
      await store.delete(predicates);
      console.info('[FavoriteRepository] 已清空所有收藏');
    } catch (error) {
      console.error('[FavoriteRepository] 清空收藏失败:', error);
    }
  }
}
