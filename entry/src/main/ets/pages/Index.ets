import { ModernFilterChip, ModernWallpaperCard } from '../components/ModernComponents';
import { image } from '@kit.ImageKit';
import { router } from '@kit.ArkUI';
import { WallpaperItem } from '../model/WallpaperModel';
import { MainViewModel } from '../viewmodel/MainViewModel';
import { AppConstants, SelectOption } from '../common/Constants';
import { PreferencesUtil } from '../utils/PreferencesUtil';
import { FavoriteRepository } from '../utils/FavoriteRepository';
import { globalState } from '../common/GlobalState';
import { SearchHistoryComponent } from '../components/SearchHistoryComponent';

@Entry
@Component
struct Index {
  @State viewModel: MainViewModel = new MainViewModel();

  // 本地筛选状态 (确保 UI 响应性)
  @State isCategoryGeneral: boolean = true;
  @State isCategoryAnime: boolean = true;
  @State isCategoryPeople: boolean = true;
  @State isPuritySFW: boolean = true;
  @State isPuritySketchy: boolean = false;
  @State isPurityNSFW: boolean = false;
  
  // 本地排序状态
  @State currentSorting: string = 'toplist';
  @State showSearchHistory: boolean = false; // 是否显示搜索历史

  async aboutToAppear() {
    console.info('[Index] 页面加载完成');
    this.syncViewModelFilters();
    this.currentSorting = this.viewModel.selectedSorting;
    
    // 初始化全局收藏状态
    const favoriteIds = await FavoriteRepository.getAllFavoriteIds();
    globalState.initFavorites(favoriteIds);
    
    this.viewModel.loadWallpapers();
  }

  onPageShow() {
    // 检查是否有返回参数
    const params = router.getParams() as Record<string, Object>;
    if (params && params.searchKeyword) {
      const newKeyword = params.searchKeyword as string;
      if (newKeyword !== this.viewModel.searchKeyword) {
        this.viewModel.searchKeyword = newKeyword;
        this.viewModel.loadWallpapers();
      }
    }
  }

  // 同步状态到 ViewModel
  private syncViewModelFilters() {
    this.viewModel.isCategoryGeneral = this.isCategoryGeneral;
    this.viewModel.isCategoryAnime = this.isCategoryAnime;
    this.viewModel.isCategoryPeople = this.isCategoryPeople;
    this.viewModel.isPuritySFW = this.isPuritySFW;
    this.viewModel.isPuritySketchy = this.isPuritySketchy;
    this.viewModel.isPurityNSFW = this.isPurityNSFW;
    this.viewModel.selectedSorting = this.currentSorting;
  }

  build() {
    Stack() {
      Column() {
        // 1. 顶部 Header & 搜索栏 - 重新设计为悬浮感
        Column() {
          Row() {
            Search({
              value: this.viewModel.searchKeyword,
              placeholder: 'Search wallpapers...',
              controller: new SearchController()
            })
              .height(46)
              .layoutWeight(1)
              .backgroundColor('rgba(0,0,0,0.05)')
              .placeholderColor('#999999')
              .onChange((value: string) => { this.viewModel.searchKeyword = value; })
              .onSubmit(async (value: string) => {
                this.viewModel.searchKeyword = value;
                this.showSearchHistory = false;
                if (value.trim()) await PreferencesUtil.addSearchKeyword(value.trim());
                this.viewModel.loadWallpapers();
              })
              .onFocus(() => { this.showSearchHistory = true; })
              .margin({ right: 12 })

            // 快捷入口
            Row({ space: 8 }) {
              Button({ type: ButtonType.Circle }) {
                SymbolGlyph($r('sys.symbol.heart_fill')).fontSize(22).fontColor(['#FF5252'])
              }
              .width(46).height(46).backgroundColor('rgba(255,82,82,0.1)')
              .onClick(() => { router.pushUrl({ url: 'pages/FavoritesPage' }); })

              Button({ type: ButtonType.Circle }) {
                SymbolGlyph($r('sys.symbol.magnifyingglass')).fontSize(22).fontColor(['#FFFFFF'])
              }
              .width(46).height(46).backgroundColor('#007DFF')
              .shadow({ radius: 10, color: 'rgba(0,125,255,0.3)', offsetY: 4 })
              .onClick(async () => {
                if (this.viewModel.searchKeyword.trim()) await PreferencesUtil.addSearchKeyword(this.viewModel.searchKeyword.trim());
                this.showSearchHistory = false;
                this.viewModel.loadWallpapers();
              })
            }
          }
          .width('100%')

          if (this.showSearchHistory) {
            SearchHistoryComponent({
              onHistoryItemClick: async (keyword: string) => {
                this.viewModel.searchKeyword = keyword;
                this.showSearchHistory = false;
                await PreferencesUtil.addSearchKeyword(keyword);
                this.viewModel.loadWallpapers();
              }
            })
            .zIndex(100).backgroundColor('#FFFFFF').shadow({ radius: 10, color: 'rgba(0,0,0,0.05)', offsetY: 5 })
            .borderRadius(16).margin({ top: 8 })
          }
        }
        .width('100%').padding({ left: 16, right: 16, top: 48, bottom: 12 })

        // 2. 筛选栏 - 增加间距和视觉呼吸感
        Column() {
          Scroll() {
            Row() {
              ModernFilterChip({ label: 'General', isSelected: this.isCategoryGeneral, onClickAction: () => { this.isCategoryGeneral = !this.isCategoryGeneral; this.syncViewModelFilters(); this.viewModel.loadWallpapers(); } })
              ModernFilterChip({ label: 'Anime', isSelected: this.isCategoryAnime, onClickAction: () => { this.isCategoryAnime = !this.isCategoryAnime; this.syncViewModelFilters(); this.viewModel.loadWallpapers(); } })
              ModernFilterChip({ label: 'People', isSelected: this.isCategoryPeople, onClickAction: () => { this.isCategoryPeople = !this.isCategoryPeople; this.syncViewModelFilters(); this.viewModel.loadWallpapers(); } })
            }
            .padding({ left: 16, right: 16 })
          }
          .scrollable(ScrollDirection.Horizontal).scrollBar(BarState.Off).width('100%').height(60).align(Alignment.Center)

          // 3. 排序提示
          Row() {
            Row() {
              SymbolGlyph($r('sys.symbol.chevron_up_chevron_down')).fontSize(12).fontColor(['#999999']).margin({ right: 4 })
              Text(`Sorted by ${this.currentSorting}`).fontSize(12).fontColor('#999999').fontWeight(FontWeight.Medium)
            }
            Blank()
            Row() {
              Text(this.viewModel.isFilterExpanded ? 'Hide Filters' : 'More Filters').fontSize(12).fontColor('#007DFF').fontWeight(FontWeight.Bold)
              SymbolGlyph(this.viewModel.isFilterExpanded ? $r('sys.symbol.chevron_up') : $r('sys.symbol.chevron_down')).fontSize(14).fontColor(['#007DFF']).margin({ left: 4 })
            }
            .padding({ left: 12, right: 12, top: 6, bottom: 6 })
            .backgroundColor('rgba(0,125,255,0.05)')
            .borderRadius(14)
            .onClick(() => { this.viewModel.isFilterExpanded = !this.viewModel.isFilterExpanded; })
          }
          .width('100%').padding({ left: 20, right: 20, top: 4, bottom: 12 })

          if (this.viewModel.isFilterExpanded) {
            Column() {
              this.AdvancedFilterSection()
              Blank().height(16)
            }
            .width('100%').backgroundColor('#FFFFFF').animation({ duration: 300, curve: Curve.FastOutSlowIn })
          }
        }
        .width('100%').backgroundColor('rgba(255, 255, 255, 0.8)').backgroundBlurStyle(BlurStyle.Thin)

        // 列表容器
        Stack({ alignContent: Alignment.Top }) {
          // 下拉刷新组件
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
                FlowItem() { Text('No more wallpapers').fontSize(12).fontColor('#BBB').width('100%').height(80).textAlign(TextAlign.Center) }.width('100%')
              }
            }
            .columnsTemplate('1fr 1fr').columnsGap(16).rowsGap(16).width('100%').height('100%').padding({ left: 16, right: 16, bottom: 16 })
            .onReachEnd(() => { this.viewModel.loadMore(); })
          }
          .onRefreshing(() => { this.viewModel.loadWallpapers(false); })
          .backgroundColor('#FFFFFF')

          // 居中大动画 (仅在列表为空时显示)
          if (this.viewModel.isLoading && this.viewModel.dataSource.totalCount() === 0) {
            Column() {
              LoadingProgress().width(56).height(56).color('#2262db')
              Text('Discovering beauty...').fontSize(14).fontColor('#666').margin({ top: 16 })
            }
            .width('100%').height('100%').backgroundColor('#FFFFFF').justifyContent(FlexAlign.Center).zIndex(1)
          }

          // 🚀 重新设计的刷新胶囊提示 (Pill Loading)
          if (this.viewModel.isLoading && this.viewModel.dataSource.totalCount() > 0) {
            Row({ space: 10 }) {
              LoadingProgress().width(18).height(18).color('#2262db')
              Text('Refreshing Wallpapers...')
                .fontSize(13)
                .fontWeight(FontWeight.Medium)
                .fontColor('#2262db')
            }
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .margin({ top: 12 })
            .backgroundColor('rgba(255, 255, 255, 0.9)')
            .backgroundBlurStyle(BlurStyle.COMPONENT_ULTRA_THICK)
            .borderRadius(20)
            .shadow({ radius: 15, color: 'rgba(0,0,0,0.1)', offsetY: 5 })
            .transition(TransitionEffect.asymmetric(
              TransitionEffect.OPACITY.combine(TransitionEffect.translate({ y: -50 })),
              TransitionEffect.OPACITY.combine(TransitionEffect.translate({ y: -50 }))
            ))
            .zIndex(10)
          }

          if (this.viewModel.errorMessage && this.viewModel.dataSource.totalCount() === 0) {
            Column() {
              SymbolGlyph($r('sys.symbol.wifi_slash')).fontSize(48).fontColor(['#999999'])
              Text(this.viewModel.errorMessage).fontSize(14).fontColor('#999').margin({ top: 16 })
              Button('Retry').margin({ top: 24 }).onClick(() => this.viewModel.loadWallpapers())
            }
            .width('100%').height('100%').backgroundColor('#FFFFFF').justifyContent(FlexAlign.Center)
          }
        }
        .width('100%').layoutWeight(1)
      }
      .width('100%').height('100%')

      // 浮动刷新按钮
      Button() {
        SymbolGlyph($r('sys.symbol.arrow_clockwise'))
          .fontSize(24).fontColor(['#ffffff'])
          .symbolEffect(new PulseSymbolEffect(), this.viewModel.isLoading)
      }
      .width(56).height(56).backgroundColor('#007DFF').borderRadius(28)
      .shadow({ radius: 12, color: 'rgba(0, 125, 255, 0.4)', offsetY: 6 })
      .position({ x: '100%', y: '100%' }).markAnchor({ x: 76, y: 76 })
      .onClick(() => { this.viewModel.loadWallpapers(false); })
    }
    .width('100%').height('100%')
  }

  @Builder
  AdvancedFilterSection() {
    Column() {
      // Sorting
      this.FilterTitle('Sorting')
      Scroll() { Row() { ForEach(AppConstants.SORTING_OPTIONS, (o: SelectOption) => { SelectChip({ label: o.label, value: o.value, currentValue: this.currentSorting, onSelectAction: () => { this.currentSorting = o.value; this.syncViewModelFilters(); this.viewModel.loadWallpapers(); } }) }) }.padding({ left: 16, right: 16 }) }.scrollable(ScrollDirection.Horizontal).scrollBar(BarState.Off).height(40)

      // Purity
      this.FilterTitle('Purity')
      Scroll() { Row() { 
        FilterChip({ label: 'SFW', isSelected: this.isPuritySFW, onClickAction: () => { this.isPuritySFW = !this.isPuritySFW; this.syncViewModelFilters(); this.viewModel.loadWallpapers(); } })
        FilterChip({ label: 'Sketchy', isSelected: this.isPuritySketchy, onClickAction: () => { this.isPuritySketchy = !this.isPuritySketchy; this.syncViewModelFilters(); this.viewModel.loadWallpapers(); } })
      }.padding({ left: 16, right: 16 }) }.scrollable(ScrollDirection.Horizontal).scrollBar(BarState.Off).height(40)

      // Time Range
      if (this.currentSorting === 'toplist') {
        this.FilterTitle('Time Range')
        Scroll() { Row() { ForEach(AppConstants.TOPRANGE_OPTIONS, (o: SelectOption) => { SelectChip({ label: o.label, value: o.value, currentValue: this.viewModel.selectedTopRange, onSelectAction: () => { this.viewModel.selectedTopRange = o.value; this.viewModel.loadWallpapers(); } }) }) }.padding({ left: 16, right: 16 }) }.scrollable(ScrollDirection.Horizontal).scrollBar(BarState.Off).height(40)
      }

      // Resolution
      this.FilterTitle('Resolution')
      Scroll() { Row() { ForEach(AppConstants.RESOLUTION_OPTIONS, (o: SelectOption) => { SelectChip({ label: o.label, value: o.value, currentValue: this.viewModel.selectedResolution, onSelectAction: () => { this.viewModel.selectedResolution = o.value; this.viewModel.loadWallpapers(); } }) }) }.padding({ left: 16, right: 16 }) }.scrollable(ScrollDirection.Horizontal).scrollBar(BarState.Off).height(40)
    }
  }

  @Builder FilterTitle(title: string) {
    Text(title).fontSize(12).fontColor('#999').margin({ top: 12, bottom: 8, left: 16 })
  }

  pageTransition() {
    PageTransitionEnter({ duration: 400, curve: Curve.Linear }).opacity(0)
    PageTransitionExit({ duration: 400, curve: Curve.Linear }).opacity(0)
  }
}

// --- 子组件保持原有逻辑但稍微优化视觉 ---
@Component
struct WallpaperCardComponent {
  @Prop wallpaper: WallpaperItem;
  @State isLoaded: boolean = false;
  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Image(this.wallpaper.thumbUrl).width('100%').aspectRatio(this.wallpaper.aspectRatio).objectFit(ImageFit.Fill).borderRadius(16).backgroundColor('#f2f3f5').opacity(this.isLoaded ? 1 : 0).geometryTransition(this.wallpaper.id).animation({ duration: 400, curve: Curve.EaseIn }).onComplete(() => { this.isLoaded = true; })
      Column().width('100%').height(56).borderRadius({ bottomLeft: 16, bottomRight: 16 }).linearGradient({ angle: 180, colors: [['rgba(0,0,0,0)', 0.0], ['rgba(0,0,0,0.45)', 1.0]] }).hitTestBehavior(HitTestMode.None)
      Row() {
        Text(this.wallpaper.resolution || `${this.wallpaper.width}x${this.wallpaper.height}`).fontSize(10).fontColor('rgba(255,255,255,0.9)').padding({ left: 6, right: 6, top: 2, bottom: 2 }).backgroundColor('rgba(0,0,0,0.4)').borderRadius(4).backdropBlur(10)
        Blank()
        Row({ space: 4 }) {
          SymbolGlyph(globalState.isFavorite(this.wallpaper.id) ? $r('sys.symbol.heart_fill') : $r('sys.symbol.heart')).fontSize(14).fontColor([globalState.isFavorite(this.wallpaper.id) ? '#FF5252' : '#ffffff'])
          if (this.wallpaper.favorites && this.wallpaper.favorites > 0) { Text(`${this.wallpaper.favorites}`).fontSize(10).fontColor('#ffffff') }
        }
        .padding({ left: 8, right: 8, top: 4, bottom: 4 }).backgroundColor('rgba(0,0,0,0.2)').borderRadius(12)
      }.width('100%').padding(8)
    }.width('100%')
  }
}

@Component
struct FilterChip {
  @Prop label: string; @Prop isSelected: boolean; onClickAction: () => void = () => {};
  build() {
    Text(this.label).fontSize(12).fontColor(this.isSelected ? '#ffffff' : '#666666').padding({ left: 16, right: 16, top: 6, bottom: 6 }).backgroundColor(this.isSelected ? '#2262db' : '#f0f0f0').borderRadius(16).margin({ right: 8 }).onClick(() => { if (this.onClickAction) this.onClickAction(); }).animation({ duration: 200 })
  }
}

@Component
struct SelectChip {
  @Prop label: string; @Prop value: string; @Prop currentValue: string; onSelectAction: () => void = () => {};
  build() {
    Text(this.label).fontSize(12).fontColor(this.currentValue === this.value ? '#ffffff' : '#666666').padding({ left: 16, right: 16, top: 6, bottom: 6 }).backgroundColor(this.currentValue === this.value ? '#2262db' : '#f0f0f0').borderRadius(16).margin({ right: 8 }).onClick(() => { if (this.onSelectAction) this.onSelectAction(); }).animation({ duration: 200 })
  }
}
