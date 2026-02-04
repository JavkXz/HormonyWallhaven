import { image } from '@kit.ImageKit';
import { router } from '@kit.ArkUI';
import { WallpaperItem } from '../model/WallpaperModel';
import { MainViewModel } from '../viewmodel/MainViewModel';
import { AppConstants, SelectOption } from '../common/Constants';

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

  aboutToAppear() {
    console.info('[Index] 页面加载完成');
    this.syncViewModelFilters();
    this.currentSorting = this.viewModel.selectedSorting;
    this.viewModel.loadWallpapers();
  }

  onPageShow() {
    // 检查是否有返回参数 (例如从详情页点击标签返回)
    const params = router.getParams() as Record<string, Object>;
    if (params && params.searchKeyword) {
      const newKeyword = params.searchKeyword as string;
      if (newKeyword !== this.viewModel.searchKeyword) {
        console.info(`[Index] 收到返回搜索请求: ${newKeyword}`);
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
        // 1. 顶部 Header & 搜索栏
        Row() {
          Search({ 
            value: this.viewModel.searchKeyword, 
            placeholder: 'Search wallpapers...',
            controller: new SearchController() 
          })
            .height(40)
            .layoutWeight(1)
            .backgroundColor('#f5f5f5')
            .placeholderColor('#999999')
            .placeholderFont({ size: 14 })
            .textFont({ size: 14 })
            .onChange((value: string) => {
              this.viewModel.searchKeyword = value;
            })
            .onSubmit((value: string) => {
              this.viewModel.searchKeyword = value;
              this.viewModel.loadWallpapers();
            })
            .onCopy(() => {
              console.info('Search text copied');
            })
            .margin({ right: 12 })

          Button({ type: ButtonType.Circle }) {
            SymbolGlyph($r('sys.symbol.magnifyingglass'))
              .fontSize(20)
              .fontColor(['#ffffff'])
          }
          .width(40)
          .height(40)
          .backgroundColor('#2262db')
          .onClick(() => {
            this.viewModel.loadWallpapers();
          })
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 32, bottom: 8 }) // 优化间距，由 48/12 调整为 32/8

        // 2. 筛选栏 (横向滚动 - 仅保留 Categories)
        Column() {
          Scroll() {
            Row() {
              // Categories Group
              Row() {
                FilterChip({
                  label: 'General',
                  isSelected: this.isCategoryGeneral,
                  onClickAction: () => {
                    this.isCategoryGeneral = !this.isCategoryGeneral;
                    this.syncViewModelFilters();
                    this.viewModel.loadWallpapers();
                  }
                })
                FilterChip({
                  label: 'Anime',
                  isSelected: this.isCategoryAnime,
                  onClickAction: () => {
                    this.isCategoryAnime = !this.isCategoryAnime;
                    this.syncViewModelFilters();
                    this.viewModel.loadWallpapers();
                  }
                })
                FilterChip({
                  label: 'People',
                  isSelected: this.isCategoryPeople,
                  onClickAction: () => {
                    this.isCategoryPeople = !this.isCategoryPeople;
                    this.syncViewModelFilters();
                    this.viewModel.loadWallpapers();
                  }
                })
              }
            }
            .padding({ left: 16, right: 16 })
          }
          .scrollable(ScrollDirection.Horizontal)
          .scrollBar(BarState.Off)
          .width('100%')
          .height(40)
          .align(Alignment.Start)

          // 3. 高级筛选展开按钮 & 状态显示
          Row() {
            // 当前排序状态简略显示
            Text(`Sorted by: ${this.currentSorting}`)
              .fontSize(12)
              .fontColor('#999999')
            
            Blank()

            Row() {
              Text(this.viewModel.isFilterExpanded ? 'Hide Filters' : 'More Filters')
                .fontSize(12)
                .fontColor('#2262db')
              SymbolGlyph(this.viewModel.isFilterExpanded ? $r('sys.symbol.chevron_up') : $r('sys.symbol.chevron_down'))
                .fontSize(14)
                .fontColor(['#2262db'])
                .margin({ left: 4 })
            }
            .onClick(() => {
              this.viewModel.isFilterExpanded = !this.viewModel.isFilterExpanded;
            })
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 8, bottom: 8 })

          // 4. 展开的筛选面板 (包含 Sorting, Purity, TopRange, Resolution)
          if (this.viewModel.isFilterExpanded) {
            Column() {
              Divider().color('#f0f0f0')

              // Sorting (移回这里)
              Text('Sorting').fontSize(12).fontColor('#999').margin({ top: 12, bottom: 8, left: 16 })
              Scroll() {
                Row() {
                  ForEach(AppConstants.SORTING_OPTIONS, (option: SelectOption) => {
                    SelectChip({
                      label: option.label,
                      value: option.value,
                      currentValue: this.currentSorting,
                      onSelectAction: () => {
                        this.currentSorting = option.value;
                        this.syncViewModelFilters();
                        this.viewModel.loadWallpapers();
                      }
                    })
                  })
                }
                .padding({ left: 16, right: 16 })
              }
              .scrollable(ScrollDirection.Horizontal)
              .scrollBar(BarState.Off)
              .width('100%')
              .height(40)
              
              // Purity
              Text('Purity').fontSize(12).fontColor('#999').margin({ top: 12, bottom: 8, left: 16 })
              Scroll() {
                Row() {
                  FilterChip({
                    label: 'SFW',
                    isSelected: this.isPuritySFW,
                    onClickAction: () => {
                      this.isPuritySFW = !this.isPuritySFW;
                      this.syncViewModelFilters();
                      this.viewModel.loadWallpapers();
                    }
                  })
                  FilterChip({
                    label: 'Sketchy',
                    isSelected: this.isPuritySketchy,
                    onClickAction: () => {
                      this.isPuritySketchy = !this.isPuritySketchy;
                      this.syncViewModelFilters();
                      this.viewModel.loadWallpapers();
                    }
                  })
                }
                .padding({ left: 16, right: 16 })
              }
              .scrollable(ScrollDirection.Horizontal)
              .scrollBar(BarState.Off)
              .width('100%')
              .height(40)

              // TopRange (仅当 Sorting == toplist 时显示)
              if (this.currentSorting === 'toplist') {
                Text('Time Range').fontSize(12).fontColor('#999').margin({ top: 12, bottom: 8, left: 16 })
                Scroll() {
                  Row() {
                    ForEach(AppConstants.TOPRANGE_OPTIONS, (option: SelectOption) => {
                      SelectChip({
                        label: option.label,
                        value: option.value,
                        currentValue: this.viewModel.selectedTopRange,
                        onSelectAction: () => {
                          this.viewModel.selectedTopRange = option.value;
                          this.viewModel.loadWallpapers();
                        }
                      })
                    })
                  }
                  .padding({ left: 16, right: 16 })
                }
                .scrollable(ScrollDirection.Horizontal)
                .scrollBar(BarState.Off)
                .width('100%')
                .height(40)
              }

              // Resolution
              Text('Resolution').fontSize(12).fontColor('#999').margin({ top: 12, bottom: 8, left: 16 })
               Scroll() {
                Row() {
                    ForEach(AppConstants.RESOLUTION_OPTIONS, (option: SelectOption) => {
                      SelectChip({
                        label: option.label,
                        value: option.value,
                        currentValue: this.viewModel.selectedResolution,
                        onSelectAction: () => {
                          this.viewModel.selectedResolution = option.value;
                          this.viewModel.loadWallpapers();
                        }
                      })
                    })
                  }
                  .padding({ left: 16, right: 16 })
              }
              .scrollable(ScrollDirection.Horizontal)
              .scrollBar(BarState.Off)
              .width('100%')
              .height(40)

              // 底部留白
              Blank().height(16)
            }
            .width('100%')
            .backgroundColor('#fafafa')
            .animation({ duration: 300 })
          }
        }
        .width('100%')
        .backgroundColor('#ffffff')
        .shadow({ radius: 4, color: 'rgba(0,0,0,0.05)', offsetY: 2 })
        .zIndex(1) // 确保在 WaterFlow 上方

        // 错误信息显示
        if (this.viewModel.errorMessage) {
          Text(this.viewModel.errorMessage)
            .fontSize(14)
            .fontColor('#ff0000')
            .margin({ top: 10, bottom: 10 })
            .textAlign(TextAlign.Center)
        }

        // 加载状态 (初次加载)
        if (this.viewModel.isLoading) {
          Column() {
            Progress({ value: 0, total: 100, type: ProgressType.ScaleRing })
              .width(50)
              .height(50)
              .color('#2262db')
            Text('Loading awesome wallpapers...')
              .fontSize(12)
              .fontColor('#999')
              .margin({ top: 16 })
          }
          .width('100%')
          .height('50%')
          .justifyContent(FlexAlign.Center)
        }

        // 壁纸列表
        WaterFlow({ scroller: new Scroller() }) {
          LazyForEach(this.viewModel.dataSource, (wallpaper: WallpaperItem) => {
            FlowItem() {
              WallpaperCardComponent({ wallpaper: wallpaper })
            }
            .width('100%')
            .onClick(() => {
              console.info(`[Index] 点击壁纸: ${wallpaper.id}`);
              router.pushUrl({
                url: 'pages/WallpaperDetail',
                params: {
                  wallpaper: wallpaper
                }
              });
            })
          }, (item: WallpaperItem) => item.id) // 使用 ID 作为 Key

          // 加载更多提示
          if (this.viewModel.isLoadingMore) {
            FlowItem() {
              Row() {
                Progress({ value: 0, total: 100 })
                  .width(24)
                  .height(24)
                Text('加载中...')
                  .fontSize(12)
                  .fontColor('#666666')
                  .margin({ left: 8 })
              }
              .width('100%')
              .height(50)
              .justifyContent(FlexAlign.Center)
            }
            .width('100%')
            .height(50)
          }

          if (!this.viewModel.hasMoreData && this.viewModel.dataSource.totalCount() > 0) {
            FlowItem() {
              Text('没有更多了')
                .fontSize(12)
                .fontColor('#999999')
                .width('100%')
                .height(50)
                .textAlign(TextAlign.Center)
            }
            .width('100%')
            .height(50)
          }
        }
        .columnsTemplate('1fr 1fr')
        .columnsGap(8)
        .rowsGap(8)
        .width('100%')
        .layoutWeight(1)
        .padding(8)
        .onReachEnd(() => {
          console.info('[Index] 滑动到底部，触发加载更多');
          this.viewModel.loadMore();
        })
      }
      .width('100%')
      .height('100%')
      .alignItems(HorizontalAlign.Center)

      // 浮动刷新按钮
      Button() {
        SymbolGlyph($r('sys.symbol.arrow_clockwise'))
          .fontSize(24)
          .fontColor(['#ffffff'])
          .symbolEffect(new PulseSymbolEffect(), this.viewModel.isLoading)
      }
      .width(56)
      .height(56)
      .backgroundColor('#2262db')
      .borderRadius(28)
      .shadow({
        radius: 8,
        color: 'rgba(34, 98, 219, 0.4)',
        offsetX: 0,
        offsetY: 4
      })
      .position({ x: '100%', y: '100%' })
      .markAnchor({ x: 76, y: 76 })
      .onClick(() => {
        this.viewModel.loadWallpapers(false);
      })
    }
    .width('100%')
    .height('100%')
  }
}

// ----------------------------------------
// 外部自定义组件
// ----------------------------------------

@Component
struct WallpaperCardComponent {
  @Prop wallpaper: WallpaperItem;
  @State isLoaded: boolean = false;

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      // 1. 图片层 (带渐入动画)
      Image(this.wallpaper.thumbUrl)
        .width('100%')
        .aspectRatio(this.wallpaper.aspectRatio)
        .objectFit(ImageFit.Fill)
        .borderRadius(12)
        .backgroundColor('#f5f5f5')
        .alt($r('app.media.startIcon')) // 占位图
        .opacity(this.isLoaded ? 1 : 0)
        .animation({ duration: 400, curve: Curve.EaseIn })
        .onComplete(() => {
          this.isLoaded = true;
        })

      // 2. 渐变遮罩层 (提升文字可读性)
      Column()
        .width('100%')
        .height(60)
        .borderRadius({ bottomLeft: 12, bottomRight: 12 })
        .linearGradient({
          angle: 180, // 从上到下
          colors: [
            ['rgba(0,0,0,0)', 0.0],
            ['rgba(0,0,0,0.6)', 1.0]
          ]
        })
        .hitTestBehavior(HitTestMode.None)

      // 3. 信息层 (浮动在底部)
      Row() {
        // 分辨率 Chip
        Text(this.wallpaper.resolution || `${this.wallpaper.width}x${this.wallpaper.height}`)
          .fontSize(10)
          .fontColor('rgba(255,255,255,0.9)')
          .padding({ left: 6, right: 6, top: 2, bottom: 2 })
          .backgroundColor('rgba(0,0,0,0.4)')
          .borderRadius(4)
          .backdropBlur(10)

        Blank()

        // 收藏数
        if (this.wallpaper.favorites && this.wallpaper.favorites > 0) {
          Row({ space: 2 }) {
            SymbolGlyph($r('sys.symbol.heart_fill'))
              .fontSize(12)
              .fontColor(['#FF5252'])
            Text(`${this.wallpaper.favorites}`)
              .fontSize(10)
              .fontColor('#ffffff')
          }
        }
      }
      .width('100%')
      .padding(8)

      // 4. Purity 指示器 (右上角)
      if (this.wallpaper.purity) {
        Circle({ width: 8, height: 8 })
          .fill(this.wallpaper.purity === 'sfw' ? '#4CAF50' : this.wallpaper.purity === 'sketchy' ? '#FFC107' : '#F44336')
          .position({ x: '100%', y: 0 })
          .markAnchor({ x: 16, y: -8 })
          .shadow({ radius: 4, color: 'rgba(0,0,0,0.3)' })
      }
    }
    .width('100%')
  }
}

@Component
struct FilterChip {
  @Prop label: string;
  @Prop isSelected: boolean;
  onClickAction: () => void = () => {};

  build() {
    Text(this.label)
      .fontSize(12)
      .fontColor(this.isSelected ? '#ffffff' : '#666666')
      .padding({ left: 16, right: 16, top: 6, bottom: 6 })
      .backgroundColor(this.isSelected ? '#2262db' : '#f0f0f0')
      .borderRadius(16)
      .margin({ right: 8 })
      .onClick(() => {
        if (this.onClickAction) {
          this.onClickAction();
        }
      })
      .animation({ duration: 200 })
  }
}

@Component
struct SelectChip {
  @Prop label: string;
  @Prop value: string;
  @Prop currentValue: string;
  onSelectAction: () => void = () => {};

  build() {
    Text(this.label)
      .fontSize(12)
      .fontColor(this.currentValue === this.value ? '#ffffff' : '#666666')
      .padding({ left: 16, right: 16, top: 6, bottom: 6 })
      .backgroundColor(this.currentValue === this.value ? '#2262db' : '#f0f0f0') // 统一使用主题蓝
      .borderRadius(16)
      .margin({ right: 8 })
      .onClick(() => {
        if (this.onSelectAction) {
          this.onSelectAction();
        }
      })
      .animation({ duration: 200 })
  }
}
