import { router } from '@kit.ArkUI';
import { FavoriteRepository, FavoriteEntity } from '../utils/FavoriteRepository';
import { WallpaperItem } from '../model/WallpaperModel';
import { HapticFeedback } from '../utils/HapticFeedback';
import { EmptyStateComponent, EmptyStateType } from '../components/EmptyStateComponent';

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
    // 页面显示时刷新数据
    this.loadFavorites();
  }

  /**
   * 加载收藏列表
   */
  async loadFavorites() {
    this.isLoading = true;
    try {
      const entities = await FavoriteRepository.getFavorites();
      this.favorites = entities.map(entity => FavoriteRepository.toWallpaperItem(entity));
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
    // 显示确认对话框
    // 实际实现中可以使用 AlertDialog 或自定义弹窗
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
        SymbolGlyph($r('sys.symbol.chevron_left'))
          .fontSize(24)
          .fontColor(['#333333'])
          .onClick(() => {
            router.back();
          })

        Text('我的收藏')
          .fontSize(18)
          .fontColor('#333333')
          .fontWeight(FontWeight.Medium)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        // 占位，保持标题居中
        Blank()
          .width(24)
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF')

      // 收藏列表
      if (this.isLoading) {
        Column() {
          Progress({ value: 0, total: 100, type: ProgressType.ScaleRing })
            .width(40)
            .height(40)
            .color('#2262db')
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
              this.FavoriteCardBuilder(wallpaper)
            }
            .width('100%')
            .gesture(
              GestureGroup(GestureMode.Sequence,
                // 点击手势
                TapGesture()
                  .onAction(() => {
                    this.handleWallpaperClick(wallpaper);
                  }),
                // 长按手势
                LongPressGesture({ duration: 500 })
                  .onAction(() => {
                    this.handleLongPress(wallpaper);
                  })
              )
            )
          }, (wallpaper: WallpaperItem) => wallpaper.id)
        }
        .columnsTemplate('1fr 1fr')
        .columnsGap(8)
        .rowsGap(8)
        .width('100%')
        .layoutWeight(1)
        .padding(8)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  /**
   * 收藏卡片构建器
   */
  @Builder
  FavoriteCardBuilder(wallpaper: WallpaperItem) {
    Stack({ alignContent: Alignment.Bottom }) {
      // 1. 图片层
      Image(wallpaper.thumbUrl)
        .width('100%')
        .aspectRatio(wallpaper.aspectRatio || 1.78)
        .objectFit(ImageFit.Fill)
        .borderRadius(12)
        .backgroundColor('#f5f5f5')
        .alt($r('app.media.startIcon'))

      // 2. 渐变遮罩层
      Column()
        .width('100%')
        .height(50)
        .borderRadius({ bottomLeft: 12, bottomRight: 12 })
        .linearGradient({
          angle: 180,
          colors: [
            ['rgba(0,0,0,0)', 0.0],
            ['rgba(0,0,0,0.5)', 1.0]
          ]
        })
        .hitTestBehavior(HitTestMode.None)

      // 3. 信息层
      Row() {
        Text(wallpaper.resolution || 'Unknown')
          .fontSize(10)
          .fontColor('rgba(255,255,255,0.9)')
          .padding({ left: 6, right: 6, top: 2, bottom: 2 })
          .backgroundColor('rgba(0,0,0,0.4)')
          .borderRadius(4)

        Blank()

        // 收藏图标（表示已收藏）
        SymbolGlyph($r('sys.symbol.heart_fill'))
          .fontSize(14)
          .fontColor(['#FF5252'])
      }
      .width('100%')
      .padding(8)
    }
    .width('100%')
  }

  // 页面转场配置
  pageTransition() {
    PageTransitionEnter({ duration: 300, curve: Curve.EaseInOut })
      .slide(SlideEffect.Right)
    PageTransitionExit({ duration: 300, curve: Curve.EaseInOut })
      .slide(SlideEffect.Right)
  }
}
