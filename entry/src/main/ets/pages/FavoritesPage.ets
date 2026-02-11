import { router, promptAction } from '@kit.ArkUI';
import { FavoriteRepository, FavoriteEntity } from '../utils/FavoriteRepository';
import { WallpaperItem } from '../model/WallpaperModel';
import { HapticFeedback } from '../utils/HapticFeedback';
import { globalState } from '../common/GlobalState';
import { EmptyStateComponent, EmptyStateType } from '../components/EmptyStateComponent';
import { ModernWallpaperCard } from '../components/ModernComponents';

/**
 * 我的收藏页面
 */
@Entry
@Component
struct FavoritesPage {
  @State favorites: WallpaperItem[] = [];
  @State isLoading: boolean = false;
  @State isEmpty: boolean = false;

  aboutToAppear() {
    this.loadFavorites();
  }

  onPageShow() {
    // 页面显示时刷新数据，并过滤掉在详情页取消收藏的项
    if (this.favorites.length > 0) {
      this.favorites = this.favorites.filter(item => globalState.isFavorite(item.id));
      this.isEmpty = this.favorites.length === 0;
    } else {
      this.loadFavorites();
    }
  }

  /**
   * 加载收藏列表
   */
  async loadFavorites() {
    this.isLoading = true;
    try {
      const entities = await FavoriteRepository.getFavorites();
      this.favorites = entities.map(entity => FavoriteRepository.toWallpaperItem(entity));
      
      // 同步到全局状态 (确保一致性)
      const ids = this.favorites.map(f => f.id);
      globalState.initFavorites(ids);
      
      this.isEmpty = this.favorites.length === 0;
      console.info(`[FavoritesPage] 加载收藏列表，共 ${this.favorites.length} 条`);
    } catch (error) {
      console.error('[FavoritesPage] 加载收藏列表失败:', error);
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * 处理壁纸点击
   */
  handleWallpaperClick(wallpaper: WallpaperItem) {
    router.pushUrl({
      url: 'pages/WallpaperDetail',
      params: {
        wallpaper: wallpaper,
        fromFavorites: true
      }
    });
  }

  /**
   * 处理长按（取消收藏）
   */
  async handleLongPress(wallpaper: WallpaperItem) {
    HapticFeedback.medium();
    
    AlertDialog.show({
      title: '取消收藏',
      message: '确定要将这张壁纸移出收藏吗？',
      primaryButton: {
        value: '取消',
        action: () => {}
      },
      secondaryButton: {
        value: '确定',
        fontColor: '#FF5252',
        action: async () => {
          const success = await FavoriteRepository.removeFavorite(wallpaper.id);
          if (success) {
            // 同步全局状态
            globalState.updateFavoriteStatus(wallpaper.id, false);
            // 本地列表移除
            this.favorites = this.favorites.filter(f => f.id !== wallpaper.id);
            this.isEmpty = this.favorites.length === 0;
            promptAction.showToast({ message: '已移除收藏' });
            HapticFeedback.light();
          }
        }
      }
    });
    
    console.info(`[FavoritesPage] 长按壁纸: ${wallpaper.id}`);
  }

  /**
   * 跳转到首页
   */
  navigateToHome() {
    router.back();
  }

  build() {
    Column() {
      // 标题栏
      Row() {
        // 返回按钮
        Button({ type: ButtonType.Circle }) {
          SymbolGlyph($r('sys.symbol.chevron_left'))
            .fontSize(22)
            .fontColor(['#333333'])
        }
        .width(40).height(40).backgroundColor('transparent')
        .onClick(() => {
          router.back();
        })

        Text('我的收藏')
          .fontSize(20)
          .fontColor('#182431')
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .margin({ right: 40 }) // 抵消返回按钮宽度使文字居中
      }
      .width('100%')
      .height(64)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF')

      // 收藏列表
      if (this.isLoading) {
        Column() {
          LoadingProgress()
            .width(48)
            .height(48)
            .color('#007DFF')
          Text('加载中...')
            .fontSize(14)
            .fontColor('#999999')
            .margin({ top: 12 })
        }
        .width('100%')
        .height('80%')
        .justifyContent(FlexAlign.Center)
      } else if (this.isEmpty) {
        // 空状态
        Column() {
          EmptyStateComponent({
            type: EmptyStateType.NO_FAVORITES,
            onAction: () => {
              this.navigateToHome();
            }
          })
        }
        .width('100%')
        .height('80%')
      } else {
        // 收藏列表（使用 WaterFlow 保持与首页一致的体验）
        WaterFlow({ scroller: new Scroller() }) {
          ForEach(this.favorites, (wallpaper: WallpaperItem, index: number) => {
            FlowItem() {
              ModernWallpaperCard({ wallpaper: wallpaper })
            }
            .width('100%')
            .gesture(
              GestureGroup(GestureMode.Exclusive,
                TapGesture()
                  .onAction(() => {
                    this.handleWallpaperClick(wallpaper);
                  }),
                LongPressGesture({ duration: 500 })
                  .onAction(() => {
                    this.handleLongPress(wallpaper);
                  })
              )
            )
          }, (wallpaper: WallpaperItem) => wallpaper.id)
        }
        .columnsTemplate('1fr 1fr')
        .columnsGap(12)
        .rowsGap(12)
        .width('100%')
        .layoutWeight(1)
        .padding({ left: 12, right: 12, bottom: 12 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F7')
  }

  // 页面转场配置
  pageTransition() {
    PageTransitionEnter({ duration: 300, curve: Curve.EaseInOut })
      .slide(SlideEffect.Right)
    PageTransitionExit({ duration: 300, curve: Curve.EaseInOut })
      .slide(SlideEffect.Right)
  }
}
