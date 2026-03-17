import { router, promptAction } from '@kit.ArkUI';
import { FavoriteRepository } from '../utils/FavoriteRepository';
import { WallpaperItem } from '../model/WallpaperModel';
import { HapticFeedback } from '../utils/HapticFeedback';
import { globalState } from '../common/GlobalState';
import { ModernWallpaperCard } from '../components/ModernComponents';
import { ThemeColors, ThemeShadows, AnimationPresets } from '../common/ThemeConstants';

/**
 * 我的收藏页面 - 深色沉浸主题
 * 统一采用 Immersive Fluidity 设计语言
 */
@Entry
@Component
struct FavoritesPage {
  @State favorites: WallpaperItem[] = [];
  @State isLoading: boolean = false;
  @State isEmpty: boolean = false;
  @StorageProp('statusBarHeight') statusBarHeight: number = 48;
  @StorageProp('bottomBarHeight') bottomBarHeight: number = 28;

  aboutToAppear() {
    this.loadFavorites();
  }

  onPageShow() {
    if (this.favorites.length > 0) {
      this.favorites = this.favorites.filter(item => globalState.isFavorite(item.id));
      this.isEmpty = this.favorites.length === 0;
    } else {
      this.loadFavorites();
    }
  }

  async loadFavorites() {
    this.isLoading = true;
    try {
      const entities = await FavoriteRepository.getFavorites();
      this.favorites = entities.map(entity => FavoriteRepository.toWallpaperItem(entity));
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

  handleWallpaperClick(wallpaper: WallpaperItem) {
    router.pushUrl({
      url: 'pages/WallpaperDetail',
      params: { wallpaper: wallpaper, fromFavorites: true }
    });
  }

  async handleLongPress(wallpaper: WallpaperItem) {
    HapticFeedback.medium();
    AlertDialog.show({
      title: '取消收藏',
      message: '确定要将这张壁纸移出收藏吗？',
      primaryButton: {
        value: '取消',
        action: () => {
        }
      },
      secondaryButton: {
        value: '确定',
        fontColor: ThemeColors.error,
        action: async () => {
          const success = await FavoriteRepository.removeFavorite(wallpaper.id);
          if (success) {
            globalState.updateFavoriteStatus(wallpaper.id, false);
            this.favorites = this.favorites.filter(f => f.id !== wallpaper.id);
            this.isEmpty = this.favorites.length === 0;
            promptAction.showToast({ message: '已移除收藏' });
            HapticFeedback.light();
          }
        }
      }
    });
    console.info(`[FavoritesPage] 长按壁纸：${wallpaper.id}`);
  }

  navigateToHome() {
    router.back();
  }

  build() {
    Stack() {
      // 1. 底层沉浸式模糊背景（与 Index 页一致）
      Image($r('app.media.wallhavenrqgpm7'))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover)
        .blur(80)
        .saturate(1.8)
        .brightness(0.5)
        .scale({ x: 1.2, y: 1.2 })
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])

      Column() {
        // 2. 标题栏 - 毛玻璃深色风格
        Row() {
          Button({ type: ButtonType.Circle }) {
            SymbolGlyph($r('sys.symbol.chevron_left'))
              .fontSize(22)
              .fontColor([ThemeColors.textPrimary])
          }
          .width(40)
          .height(40)
          .backgroundColor(ThemeColors.surfaceLight)
          .backgroundBlurStyle(BlurStyle.Thin)
          .shadow(ThemeShadows.medium)
          .onClick(() => router.back())

          Text('我的收藏')
            .fontSize(20)
            .fontColor(ThemeColors.textPrimary)
            .fontWeight(FontWeight.Bold)
            .layoutWeight(1)
            .textAlign(TextAlign.Center)
            .margin({ right: 40 })
        }
        .width('100%')
        .padding({
          left: 16,
          right: 16,
          top: this.statusBarHeight + 8,
          bottom: 12
        })
        .backgroundColor('transparent')

        // 3. 收藏列表
        if (this.isLoading) {
          this.LoadingState()
        } else if (this.isEmpty) {
          this.EmptyState()
        } else {
          this.FavoritesGrid()
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor('transparent')
    }
    .width('100%')
    .height('100%')
    .backgroundColor(ThemeColors.background)
  }

  // ═══════════════════════════════════════════════════════════
  // 加载状态组件（统一文案和样式）
  // ═══════════════════════════════════════════════════════════
  @Builder
  LoadingState() {
    Column() {
      LoadingProgress()
        .width(56)
        .height(56)
        .color(ThemeColors.primary)
      Text('Loading favorites...')
        .fontSize(14)
        .fontColor(ThemeColors.textSecondary)
        .margin({ top: 16 })
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
  }

  // ═══════════════════════════════════════════════════════════
  // 空状态组件（情感化设计）
  // ═══════════════════════════════════════════════════════════
  @Builder
  EmptyState() {
    Column() {
      Stack() {
        Circle()
          .width(96)
          .height(96)
          .fill(ThemeColors.surfaceLight)
        SymbolGlyph($r('sys.symbol.heart_slash'))
          .fontSize(44)
          .fontColor([ThemeColors.textSecondary])
      }

      Text('No favorites yet')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor(ThemeColors.textPrimary)
        .margin({ top: 24 })
      Text('Discover beautiful wallpapers')
        .fontSize(14)
        .fontColor(ThemeColors.textSecondary)
        .margin({ top: 8 })
      Button('Discover Wallpapers', { type: ButtonType.Capsule })
        .width(200)
        .height(48)
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .fontColor(ThemeColors.textPrimary)
        .backgroundColor(ThemeColors.primary)
        .shadow(ThemeShadows.medium)
        .margin({ top: 32 })
        .onClick(() => this.navigateToHome())
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
    .padding({ bottom: 80 })
  }

  // ═══════════════════════════════════════════════════════════
  // 收藏网格（与首页一致的瀑布流）
  // ═══════════════════════════════════════════════════════════
  @Builder
  FavoritesGrid() {
    WaterFlow({ scroller: new Scroller() }) {
      ForEach(this.favorites, (wallpaper: WallpaperItem) => {
        FlowItem() {
          ModernWallpaperCard({ wallpaper: wallpaper })
        }
        .width('100%')
        .gesture(
          GestureGroup(GestureMode.Exclusive,
            TapGesture().onAction(() => this.handleWallpaperClick(wallpaper)),
            LongPressGesture({ duration: 500 }).onAction(() => this.handleLongPress(wallpaper))
          )
        )
      }, (wallpaper: WallpaperItem) => wallpaper.id)
    }
    .columnsTemplate('1fr 1fr')
    .columnsGap(12)
    .rowsGap(12)
    .width('100%')
    .layoutWeight(1)
    .padding({ left: 12, right: 12, bottom: this.bottomBarHeight + 12 })
  }

  // 页面转场配置（统一动画）
  pageTransition() {
    PageTransitionEnter(AnimationPresets.enter).opacity(0)
    PageTransitionExit(AnimationPresets.exit).opacity(0)
  }
}
