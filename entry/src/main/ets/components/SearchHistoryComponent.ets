import { PreferencesUtil } from '../utils/PreferencesUtil';

/**
 * 搜索历史组件
 * 展示搜索历史标签云，支持点击搜索和删除
 */
@Component
export struct SearchHistoryComponent {
  @State searchHistory: string[] = [];
  @State isLoading: boolean = false;

  // 回调函数
  onHistoryItemClick?: (keyword: string) => void;
  onClearAll?: () => void;

  aboutToAppear() {
    this.loadSearchHistory();
  }

  /**
   * 加载搜索历史
   */
  async loadSearchHistory() {
    this.isLoading = true;
    try {
      this.searchHistory = await PreferencesUtil.getSearchHistory();
      console.info(`[SearchHistory] 加载搜索历史，共 ${this.searchHistory.length} 条`);
    } catch (error) {
      console.error('[SearchHistory] 加载搜索历史失败:', error);
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * 删除单个历史记录
   */
  async removeHistoryItem(keyword: string) {
    try {
      await PreferencesUtil.removeSearchKeyword(keyword);
      await this.loadSearchHistory();
      console.info(`[SearchHistory] 删除历史记录: ${keyword}`);
    } catch (error) {
      console.error('[SearchHistory] 删除历史记录失败:', error);
    }
  }

  /**
   * 清空所有历史记录
   */
  async clearAllHistory() {
    try {
      await PreferencesUtil.clearSearchHistory();
      await this.loadSearchHistory();
      if (this.onClearAll) {
        this.onClearAll();
      }
      console.info('[SearchHistory] 清空所有历史记录');
    } catch (error) {
      console.error('[SearchHistory] 清空历史记录失败:', error);
    }
  }

  /**
   * 处理历史项点击
   */
  handleHistoryItemClick(keyword: string) {
    if (this.onHistoryItemClick) {
      this.onHistoryItemClick(keyword);
    }
  }

  build() {
    Column() {
      // 标题栏
      Row() {
        Text('搜索历史')
          .fontSize(14)
          .fontColor('#666666')
          .fontWeight(FontWeight.Medium)

        Blank()

        if (this.searchHistory.length > 0) {
          Text('清空')
            .fontSize(12)
            .fontColor('#FF5252')
            .onClick(() => {
              this.clearAllHistory();
            })
        }
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 8 })

      // 历史标签列表
      if (this.searchHistory.length > 0) {
        Scroll() {
          Row({ space: 8 }) {
            ForEach(this.searchHistory, (keyword: string, index: number) => {
              this.HistoryTagBuilder(keyword, index)
            }, (keyword: string) => keyword)
          }
          .padding({ left: 16, right: 16, top: 4, bottom: 12 })
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
        .width('100%')
      } else {
        // 空状态提示
        Text('暂无搜索记录')
          .fontSize(12)
          .fontColor('#999999')
          .padding({ top: 8, bottom: 16 })
          .width('100%')
          .textAlign(TextAlign.Center)
      }
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
  }

  /**
   * 历史标签构建器
   */
  @Builder
  HistoryTagBuilder(keyword: string, index: number) {
    Row({ space: 4 }) {
      Text(keyword)
        .fontSize(13)
        .fontColor('#333333')
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .constraintSize({ maxWidth: 120 })

      // 删除按钮 - 使用 Gesture 手势避免冒泡
      SymbolGlyph($r('sys.symbol.xmark'))
        .fontSize(12)
        .fontColor(['#999999'])
        .gesture(
          TapGesture()
            .onAction(() => {
              this.removeHistoryItem(keyword);
            })
        )
    }
    .padding({ left: 12, right: 8, top: 6, bottom: 6 })
    .backgroundColor('#F5F5F5')
    .borderRadius(16)
    .onClick(() => {
      this.handleHistoryItemClick(keyword);
    })
  }
}
