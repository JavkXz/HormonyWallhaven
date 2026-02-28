import { ModernFilterChip, ModernWallpaperCard, ModernDropdownChip } from '../components/ModernComponents';
import { image } from '@kit.ImageKit';
import { router } from '@kit.ArkUI';
import { WallpaperItem } from '../model/WallpaperModel';
import { MainViewModel } from '../viewmodel/MainViewModel';
import { AppConstants, SelectOption } from '../common/Constants';
import { PreferencesUtil } from '../utils/PreferencesUtil';
import { FavoriteRepository } from '../utils/FavoriteRepository';
import { globalState } from '../common/GlobalState';
import { SearchHistoryComponent } from '../components/SearchHistoryComponent';
import { ColorPickerComponent } from '../components/ColorPickerComponent';

@Entry
@Component
struct Index {
  @State viewModel: MainViewModel = new MainViewModel();

  // 本地筛选状态
  @State isCategoryGeneral: boolean = true;
  @State isCategoryAnime: boolean = true;
  @State isCategoryPeople: boolean = true;
  @State isPuritySFW: boolean = true;
  @State isPuritySketchy: boolean = false;
  @State isPurityNSFW: boolean = false;

  // 本地排序状态
  @State currentSorting: string = 'toplist';
  @State currentOrder: string = 'desc';
  @State currentTopRange: string = '1M';
  @State currentResolution: string = '';
  @State currentRatio: string = '';
  @State showSearchHistory: boolean = false;
  @State selectedColors: string[] = [];
  @State showColorPicker: boolean = false;
  @State showSearchHistory: boolean = false;

  // 安全区域高度（从 AppStorage 全局读取）
  @StorageProp('statusBarHeight') statusBarHeight: number = 48;
  @StorageProp('bottomBarHeight') bottomBarHeight: number = 28;

  // 沉浸式滚动联动状态
  @State isScrolledDown: boolean = false;
  @State isToolbarVisible: boolean = true;
  @State isSearchExpanded: boolean = false;
  private lastScrollOffset: number = 0;

  async aboutToAppear() {
    console.info('[Index] 页面加载完成');
    this.currentSorting = this.viewModel.selectedSorting;
    this.currentOrder = this.viewModel.selectedOrder;
    this.currentTopRange = this.viewModel.selectedTopRange;
    this.currentResolution = this.viewModel.selectedResolution;
    this.currentRatio = this.viewModel.selectedRatio;
    
    this.syncViewModelFilters();

    const favoriteIds = await FavoriteRepository.getAllFavoriteIds();
    globalState.initFavorites(favoriteIds);

    this.viewModel.loadWallpapers();
  }

  onPageShow() {
    const params = router.getParams() as Record<string, Object>;
    if (params && params.searchKeyword) {
      const newKeyword = params.searchKeyword as string;
      if (newKeyword !== this.viewModel.searchKeyword) {
        this.viewModel.searchKeyword = newKeyword;
        this.viewModel.loadWallpapers();
      }
    }
  }

  private syncViewModelFilters() {
    this.viewModel.isCategoryGeneral = this.isCategoryGeneral;
    this.viewModel.isCategoryAnime = this.isCategoryAnime;
    this.viewModel.isCategoryPeople = this.isCategoryPeople;
    this.viewModel.isPuritySFW = this.isPuritySFW;
    this.viewModel.isPuritySketchy = this.isPuritySketchy;
    this.viewModel.isPurityNSFW = this.isPurityNSFW;
    this.viewModel.selectedSorting = this.currentSorting;
    this.viewModel.selectedOrder = this.currentOrder;
    this.viewModel.selectedTopRange = this.currentTopRange;
    this.viewModel.selectedResolution = this.currentResolution;
    this.viewModel.selectedRatio = this.currentRatio;
  }

  private getSortingLabel(value?: string): string {
    const sortingValue = value || this.currentSorting;
    const option = AppConstants.SORTING_OPTIONS.find((o: SelectOption) => o.value === sortingValue);
    return option ? option.label : sortingValue;
  }

  private getTopRangeLabel(value?: string): string {
    const rangeValue = value || this.currentTopRange;
    const option = AppConstants.TOPRANGE_OPTIONS.find((o: SelectOption) => o.value === rangeValue);
    return option ? option.label : rangeValue;
  }

  private getOrderLabel(value?: string): string {
    const orderValue = value || this.currentOrder;
    const option = AppConstants.ORDER_OPTIONS.find((o: SelectOption) => o.value === orderValue);
    return option ? option.label : orderValue;
  }

  private getResolutionLabel(value?: string): string {
    const resValue = value || this.currentResolution;
    const option = AppConstants.RESOLUTION_OPTIONS.find((o: SelectOption) => o.value === resValue);
    return option ? option.label : resValue;
  }

  private getRatioLabel(value?: string): string {
    const ratioValue = value || this.currentRatio;
    const option = AppConstants.RATIO_OPTIONS.find((o: SelectOption) => o.value === ratioValue);
    return option ? option.label : ratioValue;
  }

  build() {
    Stack() {
      // 0. 底层沉浸式背景组件 (使用子组件确保响应式更新)
      BackgroundWallpaper({ 
        url: this.viewModel.firstWallpaper ? this.viewModel.firstWallpaper.thumbUrl : '' 
      })

      Column() {
        // ═══════ 顶部操作栏（统一详情页设计语言）═══════
        Column() {
          if (!this.isScrolledDown || this.isSearchExpanded) {
            // ── 完整态：搜索栏 + 操作按钮 ──
            Column() {
              // Row 1: 搜索框 + 搜索按钮
              Row({ space: 10 }) {
                Search({
                  value: this.viewModel.searchKeyword,
                  placeholder: 'Search... (e.g. +tag1 -tag2, @username, type:jpg)',
                  controller: new SearchController()
                })
                  .height(42)
                  .layoutWeight(1)
                  .backgroundColor('rgba(255,255,255,0.15)')
                  .backgroundBlurStyle(BlurStyle.Thin)
                  .borderRadius(24)
                  .border({ width: 0.5, color: 'rgba(255,255,255,0.15)' })
                  .placeholderColor('rgba(255,255,255,0.45)')
                  .fontColor('#FFFFFF')
                  .shadow({ radius: 10, color: 'rgba(0,0,0,0.2)', offsetY: 4 })
                  .onChange((value: string) => { this.viewModel.searchKeyword = value; })
                  .onSubmit(async (value: string) => {
                    this.viewModel.searchKeyword = value;
                    this.showSearchHistory = false;
                    this.isSearchExpanded = false;
                    if (value.trim()) await PreferencesUtil.addSearchKeyword(value.trim());
                    this.viewModel.loadWallpapers();
                  })
                  .onFocus(() => { this.showSearchHistory = true; })

                // 搜索按钮 (36px, 与搜索框同高协调)
                Button({ type: ButtonType.Circle }) {
                  SymbolGlyph($r('sys.symbol.magnifyingglass')).fontSize(18).fontColor(['#FFFFFF'])
                }
                .width(42).height(42) // 42px 保持一致
                .backgroundColor('#007DFF')
                .shadow({ radius: 15, color: 'rgba(0,125,255,0.4)', offsetY: 6 })
                .onClick(async () => {
                  if (this.viewModel.searchKeyword.trim()) await PreferencesUtil.addSearchKeyword(this.viewModel.searchKeyword.trim());
                  this.showSearchHistory = false;
                  this.isSearchExpanded = false;
                  this.viewModel.loadWallpapers();
                })
              }
              .width('100%')

              // Row 2: 排序胶囊 (左对齐) + 占位 + 筛选 + 收藏 (右对齐)
              Row({ space: 10 }) {
                // 排序胶囊 (移除图标，仅保留文字)
                Row() {
                  Text(this.getSortingLabel())
                    .fontSize(13)
                    .fontColor('#FFFFFF')
                    .fontWeight(FontWeight.Medium)
                }
                .height(36)
                .padding({ left: 16, right: 16 })
                .backgroundColor('rgba(255,255,255,0.15)')
                .backgroundBlurStyle(BlurStyle.Thin)
                .borderRadius(24)
                .shadow({ radius: 10, color: 'rgba(0,0,0,0.2)', offsetY: 4 })
                .bindMenu(this.SortingMenuBuilder())

                Blank()

                // 筛选按钮 (尺寸 36px)
                Button({ type: ButtonType.Circle }) {
                  SymbolGlyph($r('sys.symbol.line_3_horizontal'))
                    .fontSize(18)
                    .fontColor([this.viewModel.isFilterExpanded ? '#007DFF' : '#FFFFFF'])
                }
                .width(36).height(36)
                .backgroundColor(this.viewModel.isFilterExpanded ? 'rgba(0,125,255,0.2)' : 'rgba(255,255,255,0.15)')
                .backgroundBlurStyle(BlurStyle.Thin)
                .shadow({ radius: 10, color: 'rgba(0,0,0,0.2)', offsetY: 4 })
                .onClick(() => { this.viewModel.isFilterExpanded = !this.viewModel.isFilterExpanded; })

                // 收藏按钮 (尺寸 36px)
                Button({ type: ButtonType.Circle }) {
                  SymbolGlyph($r('sys.symbol.heart_fill')).fontSize(18).fontColor(['#FF5252'])
                }
                .width(36).height(36)
                .backgroundColor('rgba(255,255,255,0.15)')
                .backgroundBlurStyle(BlurStyle.Thin)
                .shadow({ radius: 10, color: 'rgba(0,0,0,0.2)', offsetY: 4 })
                .onClick(() => { router.pushUrl({ url: 'pages/FavoritesPage' }); })
              }
              .width('100%')
              .margin({ top: 12 }) // 增加行间距
            }
            .transition(TransitionEffect.OPACITY.combine(TransitionEffect.translate({ y: -20 })))
          } else {
            // ── 胶囊态（滚动收缩）──
            Row() {
              SymbolGlyph($r('sys.symbol.magnifyingglass'))
                .fontSize(16)
                .fontColor(['rgba(255,255,255,0.6)'])
                .margin({ right: 8 })
              Text(this.viewModel.searchKeyword || 'Search...')
                .fontSize(13)
                .fontColor(this.viewModel.searchKeyword ? '#FFFFFF' : 'rgba(255,255,255,0.45)')
                .fontWeight(FontWeight.Medium)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .layoutWeight(1)

              SymbolGlyph($r('sys.symbol.heart_fill'))
                .fontSize(18)
                .fontColor(['#FF5252'])
                .margin({ left: 12 })
                .onClick(() => { router.pushUrl({ url: 'pages/FavoritesPage' }); })
            }
            .width('55%')
            .height(40)
            .padding({ left: 16, right: 16 })
            .backgroundColor('rgba(255,255,255,0.15)')
            .backgroundBlurStyle(BlurStyle.Thin)
            .borderRadius(24)
            .shadow({ radius: 10, color: 'rgba(0,0,0,0.2)', offsetY: 4 })
            .onClick(() => { this.isSearchExpanded = true; })
            .transition(TransitionEffect.OPACITY.combine(TransitionEffect.translate({ y: -10 })))
          }

          // 搜索历史（重构样式）
          if (this.showSearchHistory && (!this.isScrolledDown || this.isSearchExpanded)) {
            SearchHistoryComponent({
              onHistoryItemClick: async (keyword: string) => {
                this.viewModel.searchKeyword = keyword;
                this.showSearchHistory = false;
                this.isSearchExpanded = false;
                await PreferencesUtil.addSearchKeyword(keyword);
                this.viewModel.loadWallpapers();
              }
            })
            .zIndex(100)
            .margin({ top: 12 })
          }
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: this.statusBarHeight + 12, bottom: 8 })
        .alignItems(this.isScrolledDown && !this.isSearchExpanded ? HorizontalAlign.Center : HorizontalAlign.Start)
        .animation({ duration: 350, curve: Curve.FastOutSlowIn })

        // ── 高级筛选展开面板（修复面板间距）──
        if (this.viewModel.isFilterExpanded && this.isToolbarVisible) {
          Column() {
            this.AdvancedFilterSection()
          }
          .width('90%') // 缩小宽度，创造边距
          .padding({ left: 16, right: 16, top: 8, bottom: 12 })
          .backgroundColor('rgba(255,255,255,0.08)')
          .backgroundBlurStyle(BlurStyle.Thin)
          .borderRadius(24)
          .margin({ bottom: 12 }) // 移除左右 margin，靠 width 控制
          .border({ width: 0.5, color: 'rgba(255,255,255,0.1)' })
          .transition(TransitionEffect.OPACITY.combine(TransitionEffect.translate({ y: -20 })))
          .animation({ duration: 350, curve: Curve.FastOutSlowIn })
        }

        // ═══════ 壁纸瀑布流 ═══════
        Stack({ alignContent: Alignment.Top }) {
          Refresh({ refreshing: this.viewModel.isLoading }) {
            WaterFlow({ scroller: new Scroller() }) {
              LazyForEach(this.viewModel.dataSource, (wallpaper: WallpaperItem) => {
                FlowItem() { ModernWallpaperCard({ wallpaper: wallpaper }) }
                .width('100%')
                .onClick(() => { router.pushUrl({ url: 'pages/WallpaperDetail', params: { wallpaper: wallpaper } }); })
              }, (item: WallpaperItem) => item.id)

              if (this.viewModel.isLoadingMore) {
                FlowItem() { Column() { LoadingProgress().width(32).height(32).color('#007DFF') }.width('100%').height(80).justifyContent(FlexAlign.Center) }.width('100%')
              }
              if (!this.viewModel.hasMoreData && this.viewModel.dataSource.totalCount() > 0) {
                FlowItem() { Text('No more wallpapers').fontSize(12).fontColor('rgba(255,255,255,0.4)').width('100%').height(80).textAlign(TextAlign.Center) }.width('100%')
              }
            }
            .columnsTemplate('1fr 1fr')
            .columnsGap(12)
            .rowsGap(12)
            .width('100%')
            .height('100%')
            .padding({ left: 12, right: 12, bottom: 12 })
            .onReachEnd(() => { this.viewModel.loadMore(); })
            .onScrollFrameBegin((offset: number) => {
              const scrollingDown = offset > 0;
              const scrollingUp = offset < 0;
              const significantScroll = Math.abs(offset - this.lastScrollOffset) > 5;

              if (significantScroll) {
                if (scrollingDown && !this.isScrolledDown) {
                  this.isScrolledDown = true;
                  this.isToolbarVisible = false;
                  this.isSearchExpanded = false;
                  this.showSearchHistory = false;
                } else if (scrollingUp && this.isScrolledDown) {
                  this.isScrolledDown = false;
                  this.isToolbarVisible = true;
                }
              }
              this.lastScrollOffset = offset;
              return { offsetRemain: offset };
            })
          }
          .onRefreshing(() => {
            this.isScrolledDown = false;
            this.isToolbarVisible = true;
            this.viewModel.loadWallpapers(false);
          })
          .backgroundColor('transparent')

          // 居中加载动画
          if (this.viewModel.isLoading && this.viewModel.dataSource.totalCount() === 0) {
            Column() {
              LoadingProgress().width(56).height(56).color('#007DFF')
              Text('Discovering beauty...').fontSize(14).fontColor('rgba(255,255,255,0.7)').margin({ top: 16 })
            }
            .width('100%').height('100%').backgroundColor('transparent').justifyContent(FlexAlign.Center).zIndex(1)
          }

          // 刷新提示胶囊
          if (this.viewModel.isLoading && this.viewModel.dataSource.totalCount() > 0) {
            Row({ space: 10 }) {
              LoadingProgress().width(18).height(18).color('#007DFF')
              Text('Refreshing...')
                .fontSize(13)
                .fontWeight(FontWeight.Medium)
                .fontColor('#FFFFFF')
            }
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .margin({ top: 12 })
            .backgroundColor('rgba(255, 255, 255, 0.15)')
            .backgroundBlurStyle(BlurStyle.Thin)
            .border({ width: 0.5, color: 'rgba(255,255,255,0.1)' })
            .borderRadius(24)
            .shadow({ radius: 10, color: 'rgba(0,0,0,0.2)', offsetY: 4 })
            .transition(TransitionEffect.asymmetric(
              TransitionEffect.OPACITY.combine(TransitionEffect.translate({ y: -50 })),
              TransitionEffect.OPACITY.combine(TransitionEffect.translate({ y: -50 }))
            ))
            .zIndex(10)
          }

          // 错误状态
          if (this.viewModel.errorMessage && this.viewModel.dataSource.totalCount() === 0) {
            Column() {
              SymbolGlyph($r('sys.symbol.wifi_slash')).fontSize(48).fontColor(['rgba(255,255,255,0.4)'])
              Text(this.viewModel.errorMessage).fontSize(14).fontColor('rgba(255,255,255,0.4)').margin({ top: 16 })
              Button('Retry').margin({ top: 24 }).onClick(() => this.viewModel.loadWallpapers())
            }
            .width('100%').height('100%').backgroundColor('transparent').justifyContent(FlexAlign.Center)
          }
        }
      }
      .width('100%').height('100%')
      // 浮动刷新按钮
      Button({ type: ButtonType.Circle }) {
        SymbolGlyph($r('sys.symbol.arrow_clockwise'))
          .fontSize(24).fontColor(['#ffffff'])
          .symbolEffect(new PulseSymbolEffect(), this.viewModel.isLoading)
      }
      .width(56).height(56)
      .backgroundColor('#007DFF')
      .shadow({ radius: 15, color: 'rgba(0, 125, 255, 0.45)', offsetY: 8 })
      .position({ x: '100%', y: '100%' }).markAnchor({ x: 76, y: this.bottomBarHeight + 48 })
      .onClick(() => { this.viewModel.loadWallpapers(false); })
      
      // 半透明遮罩层
      if (this.showColorPicker) {
        Row()
          .width('100%')
          .height('100%')
          .backgroundColor('rgba(0, 0, 0, 0.5)')
          .zIndex(999)
          .onClick(() => {
            this.showColorPicker = false;
          })
      }
      
      // 颜色选择器弹窗
      if (this.showColorPicker) {
        ColorPickerComponent({
          selectedColors: this.selectedColors,
          onClose: (colors: string[]) => {
            this.selectedColors = colors;
            this.showColorPicker = false;
            this.viewModel.loadWallpapers();
          }
        })
        .zIndex(1000)
        .position({ x: '50%', y: '50%' })
        .translate({ x: '-50%', y: '-50%' })
      }
    }
    .width('100%').height('100%').backgroundColor('#000000')
  }

  @Builder
  SortingMenuBuilder() {
    Menu() {
      ForEach(AppConstants.SORTING_OPTIONS, (option: SelectOption) => {
        MenuItem({ content: option.label })
          .onClick(() => {
            this.currentSorting = option.value;
            this.syncViewModelFilters();
            this.viewModel.loadWallpapers();
          })
      })
    }
  }

  @Builder
  AdvancedFilterSection() {
    Column() {
      // Category & Purity (Keep Chips as they are multi-select)
      Row() {
        Column() {
          this.FilterTitle('Category')
          Row() {
            ModernFilterChip({ label: 'General', isSelected: this.isCategoryGeneral, onClickAction: () => { this.isCategoryGeneral = !this.isCategoryGeneral; this.syncViewModelFilters(); this.viewModel.loadWallpapers(); } })
            ModernFilterChip({ label: 'Anime', isSelected: this.isCategoryAnime, onClickAction: () => { this.isCategoryAnime = !this.isCategoryAnime; this.syncViewModelFilters(); this.viewModel.loadWallpapers(); } })
            ModernFilterChip({ label: 'People', isSelected: this.isCategoryPeople, onClickAction: () => { this.isCategoryPeople = !this.isCategoryPeople; this.syncViewModelFilters(); this.viewModel.loadWallpapers(); } })
          }
        }.alignItems(HorizontalAlign.Start)
      }.width('100%')

      Row() {
        Column() {
          this.FilterTitle('Purity')
          Row() {
            ModernFilterChip({ label: 'SFW', isSelected: this.isPuritySFW, onClickAction: () => { this.isPuritySFW = !this.isPuritySFW; this.syncViewModelFilters(); this.viewModel.loadWallpapers(); } })
            ModernFilterChip({ label: 'Sketchy', isSelected: this.isPuritySketchy, onClickAction: () => { this.isPuritySketchy = !this.isPuritySketchy; this.syncViewModelFilters(); this.viewModel.loadWallpapers(); } })
          }
        }.alignItems(HorizontalAlign.Start)
      }.width('100%')

      // Dropdown Filters
      this.FilterTitle('Refinement')
      Flex({ wrap: FlexWrap.Wrap }) {
        // Sorting Dropdown
        ModernDropdownChip({
          label: 'Sort',
          valueLabel: this.getSortingLabel(),
          options: AppConstants.SORTING_OPTIONS,
          onSelect: (val) => {
            this.currentSorting = val;
            this.syncViewModelFilters();
            this.viewModel.loadWallpapers();
          }
        })

        // Top Range (Conditional)
        if (this.currentSorting === 'toplist') {
          ModernDropdownChip({
            label: 'Range',
            valueLabel: this.getTopRangeLabel(),
            options: AppConstants.TOPRANGE_OPTIONS,
            onSelect: (val) => {
              this.currentTopRange = val;
              this.syncViewModelFilters();
              this.viewModel.loadWallpapers();
            }
          })
        }

        // Order
        ModernDropdownChip({
          label: 'Order',
          valueLabel: this.getOrderLabel(),
          options: AppConstants.ORDER_OPTIONS,
          onSelect: (val) => {
            this.currentOrder = val;
            this.syncViewModelFilters();
            this.viewModel.loadWallpapers();
          }
        })

        // Resolution
        ModernDropdownChip({
          label: 'Res',
          valueLabel: this.getResolutionLabel(),
          options: AppConstants.RESOLUTION_OPTIONS,
          onSelect: (val) => {
            this.currentResolution = val;
            this.syncViewModelFilters();
            this.viewModel.loadWallpapers();
          }
        })

        // Ratio
        ModernDropdownChip({
          label: 'Ratio',
          valueLabel: this.getRatioLabel(),
          options: AppConstants.RATIO_OPTIONS,
          onSelect: (val) => {
            this.currentRatio = val;
            this.syncViewModelFilters();
            this.viewModel.loadWallpapers();
          }
        })

        // Color Filter
        ModernDropdownChip({
          label: 'Color',
          valueLabel: this.selectedColors.length > 0 ? `${this.selectedColors.length} colors` : 'Any Color',
          options: [],
          onSelect: () => {
            this.showColorPicker = true;
          }
        })
      }
      .width('100%')
      .margin({ top: 4 })
    }
    .padding({ top: 4, bottom: 4 })
  }

  @Builder FilterTitle(title: string) {
    Text(title)
      .fontSize(11)
      .fontWeight(FontWeight.Bold)
      .fontColor('rgba(255,255,255,0.6)')
      .margin({ top: 10, bottom: 6 })
  }

  pageTransition() {
    PageTransitionEnter({ duration: 350, curve: Curve.FastOutSlowIn }).opacity(0)
    PageTransitionExit({ duration: 350, curve: Curve.FastOutSlowIn }).opacity(0)
  }
}

/**
 * 独立的背景组件，通过 @Prop 确保响应式更新
 */
@Component
struct BackgroundWallpaper {
  @Prop url: string;

  build() {
    Stack() {
      // 默认/兜底背景
      Image($r('app.media.wallhavenrqgpm7'))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover)
        .blur(80)
        .saturate(1.8)
        .brightness(0.5)
        .scale({ x: 1.2, y: 1.2 })
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])

      // 动态背景
      if (this.url && this.url.length > 0) {
        Image(this.url)
          .width('100%')
          .height('100%')
          .objectFit(ImageFit.Cover)
          .blur(80)
          .saturate(1.8) // 显著提升饱和度，即使是暗色壁纸也能提取出色彩
          .brightness(0.5) // 提高亮度系数，避免暗图变纯黑
          .scale({ x: 1.2, y: 1.2 }) // 放大消除模糊边缘
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
          .animation({ duration: 800, curve: Curve.EaseInOut })
          .onError((e) => {
            console.error('[BackgroundWallpaper] Image load failed:', JSON.stringify(e));
          })
      }
    }
    .width('100%')
    .height('100%')
  }
}
