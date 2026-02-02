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

  // 壁纸卡片组件 (Material Design)
  @Builder
  WallpaperCard(wallpaper: WallpaperItem) {
    Stack({ alignContent: Alignment.Bottom }) {
      // 1. 图片层
      Image(wallpaper.thumbUrl)
        .width('100%')
        .aspectRatio(wallpaper.aspectRatio)
        .objectFit(ImageFit.Fill)
        .borderRadius(12)
        .backgroundColor('#f0f0f0')

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
        .hitTestBehavior(HitTestMode.None) // 不拦截点击

      // 3. 信息层 (浮动在底部)
      Row() {
        // 分辨率 Chip
        Text(wallpaper.resolution || `${wallpaper.width}x${wallpaper.height}`)
          .fontSize(10)
          .fontColor('rgba(255,255,255,0.9)')
          .padding({ left: 6, right: 6, top: 2, bottom: 2 })
          .backgroundColor('rgba(0,0,0,0.4)')
          .borderRadius(4)
          .backdropBlur(10) // 毛玻璃背景

        Blank()

        // 收藏数
        if (wallpaper.favorites && wallpaper.favorites > 0) {
          Row({ space: 2 }) {
            Text('❤')
              .fontSize(10)
              .fontColor('#FF5252') // Material Red A200
            Text(`${wallpaper.favorites}`)
              .fontSize(10)
              .fontColor('#ffffff')
          }
        }
      }
      .width('100%')
      .padding(8)

      // 4. Purity 指示器 (右上角)
      if (wallpaper.purity) {
        Circle({ width: 8, height: 8 })
          .fill(wallpaper.purity === 'sfw' ? '#4CAF50' : wallpaper.purity === 'sketchy' ? '#FFC107' : '#F44336')
          .position({ x: '100%', y: 0 })
          .markAnchor({ x: 16, y: -8 }) // 右上角偏移
          .shadow({ radius: 4, color: 'rgba(0,0,0,0.3)' })
      }
    }
    .width('100%')
  }

  build() {
    Stack() {
      Column() {
        // 1. 顶部 Header
        Row() {
          Text('Wallhaven')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
          Blank()
          Button({ type: ButtonType.Circle }) {
            Text('🔍').fontSize(16)
          }
          .width(36)
          .height(36)
          .backgroundColor('#f5f5f5')
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 12, bottom: 12 })

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
              Text(this.viewModel.isFilterExpanded ? ' ▲' : ' ▼')
                .fontSize(10)
                .fontColor('#2262db')
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
              this.WallpaperCard(wallpaper)
            }
            .width('100%')
            // 移除固定高度，让内容根据 aspectRatio 自适应
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
        Text('🔄')
          .fontSize(24)
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
// 外部自定义组件 (解决状态刷新问题)
// ----------------------------------------

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