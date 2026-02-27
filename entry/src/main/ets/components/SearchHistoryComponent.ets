import { PreferencesUtil } from '../utils/PreferencesUtil';

/**
 * 搜索历史组件 (沉浸式暗色磨砂风格)
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

  async loadSearchHistory() {
    this.isLoading = true;
    try {
      this.searchHistory = await PreferencesUtil.getSearchHistory();
    } catch (error) {
      console.error('[SearchHistory] 加载失败:', error);
    } finally {
      this.isLoading = false;
    }
  }

  async removeHistoryItem(keyword: string) {
    try {
      await PreferencesUtil.removeSearchKeyword(keyword);
      await this.loadSearchHistory();
    } catch (error) {
      console.error('[SearchHistory] 删除失败:', error);
    }
  }

  async clearAllHistory() {
    try {
      await PreferencesUtil.clearSearchHistory();
      await this.loadSearchHistory();
      if (this.onClearAll) this.onClearAll();
    } catch (error) {
      console.error('[SearchHistory] 清空失败:', error);
    }
  }

  handleHistoryItemClick(keyword: string) {
    if (this.onHistoryItemClick) this.onHistoryItemClick(keyword);
  }

  build() {
    Column() {
      // 标题栏
      Row() {
        Text('Search History')
          .fontSize(13)
          .fontColor('rgba(255,255,255,0.6)')
          .fontWeight(FontWeight.Bold)

        Blank()

        if (this.searchHistory.length > 0) {
          Text('Clear')
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
        // 空状态
        Text('No history yet')
          .fontSize(12)
          .fontColor('rgba(255,255,255,0.4)')
          .padding({ top: 8, bottom: 16 })
          .width('100%')
          .textAlign(TextAlign.Center)
      }
    }
    .width('100%')
    .backgroundColor('transparent') // 去除背景色，依赖外部的 BlurStyle
  }

  @Builder
  HistoryTagBuilder(keyword: string, index: number) {
    Row({ space: 6 }) {
      Text(keyword)
        .fontSize(13)
        .fontColor('#FFFFFF')
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .constraintSize({ maxWidth: 120 })

      // 删除按钮
      SymbolGlyph($r('sys.symbol.xmark'))
        .fontSize(12)
        .fontColor(['rgba(255,255,255,0.6)'])
        .onClick(() => {
          this.removeHistoryItem(keyword);
        })
    }
    .padding({ left: 12, right: 10, top: 6, bottom: 6 })
    .backgroundColor('rgba(255,255,255,0.1)')
    .backgroundBlurStyle(BlurStyle.Thin)
    .borderRadius(20)
    .border({ width: 0.5, color: 'rgba(255,255,255,0.1)' })
    .onClick(() => {
      this.handleHistoryItemClick(keyword);
    })
  }
}
