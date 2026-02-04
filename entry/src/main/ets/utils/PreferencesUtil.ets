import preferences from '@ohos.data.preferences';

/**
 * 搜索历史工具类
 * 使用 Preferences 存储用户的搜索关键词
 */
export class PreferencesUtil {
  private static readonly PREFERENCES_NAME = 'wallpaper_prefs';
  private static readonly SEARCH_HISTORY_KEY = 'search_history';
  private static readonly MAX_HISTORY_COUNT = 20;

  private static preferencesInstance: preferences.Preferences | null = null;

  /**
   * 获取 Preferences 实例
   */
  private static async getPreferences(): Promise<preferences.Preferences> {
    if (!PreferencesUtil.preferencesInstance) {
      PreferencesUtil.preferencesInstance = await preferences.getPreferences(
        getContext(),
        PreferencesUtil.PREFERENCES_NAME
      );
    }
    return PreferencesUtil.preferencesInstance;
  }

  /**
   * 添加搜索关键词
   * @param keyword 搜索关键词
   */
  static async addSearchKeyword(keyword: string): Promise<void> {
    if (!keyword || keyword.trim().length === 0) {
      return;
    }

    try {
      const prefs = await PreferencesUtil.getPreferences();
      let history = await PreferencesUtil.getSearchHistory();

      // 去重：如果已存在，先移除旧的
      history = history.filter((item: string) => item !== keyword);

      // 新搜索置顶
      history.unshift(keyword);

      // 限制数量
      if (history.length > PreferencesUtil.MAX_HISTORY_COUNT) {
        history = history.slice(0, PreferencesUtil.MAX_HISTORY_COUNT);
      }

      await prefs.put(PreferencesUtil.SEARCH_HISTORY_KEY, JSON.stringify(history));
      await prefs.flush();

      console.info(`[PreferencesUtil] 添加搜索历史: ${keyword}`);
    } catch (error) {
      console.error('[PreferencesUtil] 添加搜索历史失败:', error);
    }
  }

  /**
   * 获取搜索历史列表
   * @returns 搜索历史数组（时间倒序）
   */
  static async getSearchHistory(): Promise<string[]> {
    try {
      const prefs = await PreferencesUtil.getPreferences();
      const historyStr = await prefs.get(PreferencesUtil.SEARCH_HISTORY_KEY, '[]') as string;
      const history = JSON.parse(historyStr) as string[];
      return Array.isArray(history) ? history : [];
    } catch (error) {
      console.error('[PreferencesUtil] 获取搜索历史失败:', error);
      return [];
    }
  }

  /**
   * 清空搜索历史
   */
  static async clearSearchHistory(): Promise<void> {
    try {
      const prefs = await PreferencesUtil.getPreferences();
      await prefs.delete(PreferencesUtil.SEARCH_HISTORY_KEY);
      await prefs.flush();
      console.info('[PreferencesUtil] 搜索历史已清空');
    } catch (error) {
      console.error('[PreferencesUtil] 清空搜索历史失败:', error);
    }
  }

  /**
   * 移除单个搜索关键词
   * @param keyword 要移除的关键词
   */
  static async removeSearchKeyword(keyword: string): Promise<void> {
    try {
      const prefs = await PreferencesUtil.getPreferences();
      let history = await PreferencesUtil.getSearchHistory();

      history = history.filter((item: string) => item !== keyword);

      await prefs.put(PreferencesUtil.SEARCH_HISTORY_KEY, JSON.stringify(history));
      await prefs.flush();

      console.info(`[PreferencesUtil] 移除搜索历史: ${keyword}`);
    } catch (error) {
      console.error('[PreferencesUtil] 移除搜索历史失败:', error);
    }
  }

  /**
   * 检查关键词是否已在历史中
   * @param keyword 搜索关键词
   */
  static async isKeywordInHistory(keyword: string): Promise<boolean> {
    const history = await PreferencesUtil.getSearchHistory();
    return history.includes(keyword);
  }
}
