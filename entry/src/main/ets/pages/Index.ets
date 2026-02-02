import { image } from '@kit.ImageKit';
import { WallpaperItem, SearchParams } from '../model/WallpaperModel';
import { WallhavenService } from '../service/WallhavenService';
import { AppConfig } from '../utils/AppConfig';

// 选择器选项接口
interface SelectOption {
  value: string;
  label: string;
}

// Builder函数参数接口
interface FilterSectionParams {
  title: string;
}

interface SelectButtonGroupParams {
  options: SelectOption[];
  selected: string;
  onSelect: (value: string) => void;
}

interface WallpaperCardParams {
  wallpaper: WallpaperItem;
}

@Entry
@Component
struct Index {
  @State wallpapers: WallpaperItem[] = [];
  @State isLoading: boolean = false;
  @State isLoadingMore: boolean = false; // 加载更多状态
  @State errorMessage: string = '';
  @State currentPage: number = 1; // 当前页码
  @State hasMoreData: boolean = true; // 是否还有更多数据

  // 筛选条件状态
  @State selectedCategories: number = 111; // 分类选择：100(通用)/110(动漫)/111(全部)
  @State isFilterExpanded: boolean = false; // 筛选面板展开状态
  @State selectedPurity: string = '100'; // 纯净度
  @State selectedSorting: string = 'date_added'; // 排序方式
  @State selectedOrder: string = 'desc'; // 排序顺序
  @State selectedResolution: string = ''; // 分辨率

  private wallhavenService: WallhavenService = AppConfig.getInstance().getWallhavenService();

  // 筛选选项数组
  private purityOptions: SelectOption[] = [
    { value: '100', label: 'SFW (安全)' },
    { value: '110', label: 'Sketchy (成人)' },
    { value: '111', label: '全部' }
  ];

  private sortingOptions: SelectOption[] = [
    { value: 'date_added', label: '按日期添加' },
    { value: 'relevance', label: '按相关性' },
    { value: 'random', label: '随机' },
    { value: 'views', label: '按浏览量' },
    { value: 'favorites', label: '按收藏数' },
    { value: 'toplist', label: '热门榜单' }
  ];

  private orderOptions: SelectOption[] = [
    { value: 'desc', label: '降序' },
    { value: 'asc', label: '升序' }
  ];

  private resolutionOptions: SelectOption[] = [
    { value: '', label: '全部' },
    { value: '1920x1080', label: '1920x1080' },
    { value: '1920x1200', label: '1920x1200' },
    { value: '2560x1440', label: '2560x1440' },
    { value: '3840x2160', label: '4K (3840x2160)' }
  ];

  aboutToAppear() {
    console.info('[Index] 页面加载完成');
    this.loadWallpapers();
  }

  // 加载壁纸（支持首次加载和加载更多）
  async loadWallpapers(isLoadMore: boolean = false) {
    if (this.isLoading || this.isLoadingMore) return;

    if (isLoadMore) {
      this.isLoadingMore = true;
    } else {
      this.isLoading = true;
      this.currentPage = 1;
      this.hasMoreData = true;
    }
    this.errorMessage = '';

    try {
      console.info(`[Index] 开始加载壁纸，页码: ${this.currentPage}`);

      // 构建搜索参数
      const searchParams: SearchParams = {
        purity: this.selectedPurity,
        sorting: this.selectedSorting,
        order: this.selectedOrder,
        categories: this.selectedCategories.toString(),
        page: this.currentPage
      };

      // 仅在选择分辨率时添加
      if (this.selectedResolution && this.selectedResolution.length > 0) {
        (searchParams as Record<string, string>).resolutions = this.selectedResolution;
      }

      const newWallpapers = await this.wallhavenService.searchWallpapers(searchParams);
      console.info(`[Index] 壁纸加载完成，本页共 ${newWallpapers.length} 张`);

      if (isLoadMore) {
        // 加载更多：追加到现有数据
        this.wallpapers = [...this.wallpapers, ...newWallpapers];
      } else {
        // 首次加载或刷新：替换数据
        this.wallpapers = newWallpapers;
      }

      // 如果返回的数据为空或少于预期，认为没有更多数据了
      if (newWallpapers.length === 0) {
        this.hasMoreData = false;
      }

    } catch (error) {
      console.error('[Index] 加载壁纸失败:', error);
      this.errorMessage = '加载壁纸失败，请检查网络连接';

      if (!isLoadMore) {
        // 使用回退数据
        this.wallpapers = this.getFallbackWallpapers();
      }
    } finally {
      this.isLoading = false;
      this.isLoadingMore = false;
    }
  }

  // 加载更多壁纸
  async loadMoreWallpapers() {
    if (!this.hasMoreData || this.isLoadingMore || this.isLoading) return;

    this.currentPage++;
    console.info(`[Index] 加载更多，页码: ${this.currentPage}`);
    await this.loadWallpapers(true);
  }

  // 回退壁纸数据（当API不可用时使用）
  private getFallbackWallpapers(): WallpaperItem[] {
    return [
      {
        id: 'fallback1',
        name: '默认壁纸1',
        imageUrl: 'https://example.com/fallback1.jpg',
        width: 1920,
        height: 1080,
        aspectRatio: 1.78,
        calculatedHeight: 150
      },
      {
        id: 'fallback2',
        name: '默认壁纸2',
        imageUrl: 'https://example.com/fallback2.jpg',
        width: 1920,
        height: 1080,
        aspectRatio: 1.78,
        calculatedHeight: 150
      }
    ];
  }

  // 筛选区域组件
  @Builder
  FilterSection(title: string) {
    Column() {
      Text(title)
        .fontSize(14)
        .fontColor('#666666')
        .margin({ bottom: 8 })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  // 选择器组件
  @Builder
  SelectButtonGroup(options: SelectOption[], selected: string, onSelect: (value: string) => void) {
    Row({ space: 8 }) {
      ForEach(options, (option: SelectOption) => {
        Button(option.label)
          .fontSize(12)
          .height(28)
          .padding({ left: 12, right: 12 })
          .backgroundColor(selected === option.value ? '#ff2262db' : '#e0e0e0')
          .fontColor(selected === option.value ? '#ffffff' : '#666666')
          .onClick(() => {
            onSelect(option.value);
          })
      })
    }
    .width('100%')
  }

  // 壁纸卡片组件
  @Builder
  WallpaperCard(wallpaper: WallpaperItem) {
    Column() {
      // 图片区域
      Stack() {
        Image(wallpaper.imageUrl)
          .width('100%')
          .height(wallpaper.calculatedHeight || 100)
          .objectFit(ImageFit.Fill)
          .borderRadius({ topLeft: 12, topRight: 12 })
      }
      .width('100%')

      // 信息区域
      Column() {
        Row() {
          // 分辨率标签
          Text(`${wallpaper.width}x${wallpaper.height}`)
            .fontSize(11)
            .fontColor('#ffffff')
            .padding({ left: 6, right: 6, top: 2, bottom: 2 })
            .backgroundColor('#2262db')
            .borderRadius(4)

          // 纯净度标签
          Text(wallpaper.purity === 'sfw' ? 'SFW' : wallpaper.purity === 'sketchy' ? 'Sketchy' : 'NSFW')
            .fontSize(10)
            .fontWeight(FontWeight.Bold)
            .fontColor('#ffffff')
            .padding({ left: 6, right: 6, top: 2, bottom: 2 })
            .backgroundColor(wallpaper.purity === 'sfw' ? '#4CAF50' : wallpaper.purity === 'sketchy' ? '#FF9800' : '#F44336')
            .borderRadius(4)
            .margin({ left: 8 })

          Blank()
        }
        .width('100%')

        // 收藏数
        if (wallpaper.favorites && wallpaper.favorites > 0) {
          Row() {
            Blank()
            Text('❤')
              .fontSize(10)
              .fontColor('#F44336')
            Text(`${wallpaper.favorites}`)
              .fontSize(10)
              .fontColor('#666666')
              .margin({ left: 2 })
          }
          .width('100%')
          .margin({ top: 6 })
        }
      }
      .width('100%')
      .padding(12)
      .backgroundColor('#ffffff')
      .borderRadius({ bottomLeft: 12, bottomRight: 12 })
    }
    .width('100%')
    .backgroundColor('#ffffff')
    .borderRadius(12)
    .shadow({
      radius: 8,
      color: 'rgba(0, 0, 0, 0.15)',
      offsetX: 0,
      offsetY: 4
    })
  }

  build() {
    Stack() {
      Column() {
        // 顶部导航栏
        Column() {
          Row() {
            Text('壁纸应用')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .layoutWeight(1)
              .textAlign(TextAlign.Center)
              .backgroundColor('#ffffff')
          }
          .width('100%')
          .height(50)
          .padding({ left: 16, right: 16 })
          .alignItems(VerticalAlign.Center)
          .backgroundColor('#ffffff')

          // 基础筛选栏（始终显示）
          Row() {
            // 分类选择
            Row({ space: 8 }) {
              Text('分类:')
                .fontSize(14)
                .fontColor('#666666')

              Button('全部')
                .fontSize(12)
                .height(28)
                .padding({ left: 10, right: 10 })
                .backgroundColor(this.selectedCategories === 111 ? '#ff2262db' : '#f0f0f0')
                .fontColor(this.selectedCategories === 111 ? '#ffffff' : '#666666')
                .onClick(() => {
                  this.selectedCategories = 111;
                  this.loadWallpapers();
                })

              Button('通用')
                .fontSize(12)
                .height(28)
                .padding({ left: 10, right: 10 })
                .backgroundColor(this.selectedCategories === 100 ? '#ff2262db' : '#f0f0f0')
                .fontColor(this.selectedCategories === 100 ? '#ffffff' : '#666666')
                .onClick(() => {
                  this.selectedCategories = 100;
                  this.loadWallpapers();
                })

              Button('动漫')
                .fontSize(12)
                .height(28)
                .padding({ left: 10, right: 10 })
                .backgroundColor(this.selectedCategories === 110 ? '#ff2262db' : '#f0f0f0')
                .fontColor(this.selectedCategories === 110 ? '#ffffff' : '#666666')
                .onClick(() => {
                  this.selectedCategories = 110;
                  this.loadWallpapers();
                })
            }
            .layoutWeight(1)

            // 下拉按钮
            Button(this.isFilterExpanded ? '收起筛选 ▲' : '更多筛选 ▼')
              .fontSize(12)
              .height(28)
              .padding({ left: 12, right: 12 })
              .backgroundColor('#f0f0f0')
              .fontColor('#666666')
              .onClick(() => {
                this.isFilterExpanded = !this.isFilterExpanded;
              })
          }
          .width('100%')
          .padding({
            left: 16,
            right: 16,
            top: 8,
            bottom: 8
          })
        }
        .width('100%')
        .backgroundColor('#ffffff')

        // 展开的筛选面板
        if (this.isFilterExpanded) {
          Column() {
            // 分隔线
            Divider()
              .color('#eeeeee')

            Column() {
              // 排序方式
              this.FilterSection('排序方式')

              // 按钮组
              Row({ space: 8 }) {
                ForEach(this.sortingOptions, (option: SelectOption) => {
                  Button(option.label)
                    .fontSize(12)
                    .height(28)
                    .padding({ left: 12, right: 12 })
                    .backgroundColor(this.selectedSorting === option.value ? '#ff2262db' : '#e0e0e0')
                    .fontColor(this.selectedSorting === option.value ? '#ffffff' : '#666666')
                    .onClick(() => {
                      this.selectedSorting = option.value;
                      this.loadWallpapers();
                    })
                })
              }
              .width('100%')

              // 分隔线
              Divider()
                .color('#eeeeee')
                .margin({ top: 8, bottom: 8 })

              // 排序顺序
              this.FilterSection('排序顺序')

              // 按钮组
              Row({ space: 8 }) {
                ForEach(this.orderOptions, (option: SelectOption) => {
                  Button(option.label)
                    .fontSize(12)
                    .height(28)
                    .padding({ left: 12, right: 12 })
                    .backgroundColor(this.selectedOrder === option.value ? '#ff2262db' : '#e0e0e0')
                    .fontColor(this.selectedOrder === option.value ? '#ffffff' : '#666666')
                    .onClick(() => {
                      this.selectedOrder = option.value;
                      this.loadWallpapers();
                    })
                })
              }
              .width('100%')

              // 分隔线
              Divider()
                .color('#eeeeee')
                .margin({ top: 8, bottom: 8 })

              // 纯净度
              this.FilterSection('纯净度')

              // 按钮组
              Row({ space: 8 }) {
                ForEach(this.purityOptions, (option: SelectOption) => {
                  Button(option.label)
                    .fontSize(12)
                    .height(28)
                    .padding({ left: 12, right: 12 })
                    .backgroundColor(this.selectedPurity === option.value ? '#ff2262db' : '#e0e0e0')
                    .fontColor(this.selectedPurity === option.value ? '#ffffff' : '#666666')
                    .onClick(() => {
                      this.selectedPurity = option.value;
                      this.loadWallpapers();
                    })
                })
              }
              .width('100%')

              // 分隔线
              Divider()
                .color('#eeeeee')
                .margin({ top: 8, bottom: 8 })

              // 分辨率
              this.FilterSection('分辨率')

              // 按钮组
              Row({ space: 8 }) {
                ForEach(this.resolutionOptions, (option: SelectOption) => {
                  Button(option.label)
                    .fontSize(12)
                    .height(28)
                    .padding({ left: 12, right: 12 })
                    .backgroundColor(this.selectedResolution === option.value ? '#ff2262db' : '#e0e0e0')
                    .fontColor(this.selectedResolution === option.value ? '#ffffff' : '#666666')
                    .onClick(() => {
                      this.selectedResolution = option.value;
                      this.loadWallpapers();
                    })
                })
              }
              .width('100%')
            }
            .padding({
              left: 16,
              right: 16,
              top: 12,
              bottom: 12
            })
            .backgroundColor('#fafafa')
          }
          .width('100%')
          .backgroundColor('#ffffff')
        }

        // 错误信息显示
        if (this.errorMessage) {
          Text(this.errorMessage)
            .fontSize(14)
            .fontColor('#ff0000')
            .margin({ bottom: 10 })
            .textAlign(TextAlign.Center)
        }

        // 加载状态
        if (this.isLoading) {
          Progress({ value: 0, total: 100 })
            .width(60)
            .height(60)
            .margin({ bottom: 20 })
        }

        // 壁纸列表（使用WaterFlow瀑布流布局）
        WaterFlow({ scroller: new Scroller() }) {
          ForEach(this.wallpapers, (wallpaper: WallpaperItem) => {
            FlowItem() {
              this.WallpaperCard(wallpaper)
            }
            .width('100%')
            .height(wallpaper.calculatedHeight ? wallpaper.calculatedHeight + 70 : 170)
            .onClick(() => {
              console.info(`[Index] 点击壁纸: ${wallpaper.id}`);
              // 这里可以添加壁纸详情页面跳转
            })
          })

          // 加载更多提示
          if (this.isLoadingMore) {
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

          if (!this.hasMoreData && this.wallpapers.length > 0) {
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
          this.loadMoreWallpapers();
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
        this.loadWallpapers(false);
      })
    }
    .width('100%')
    .height('100%')
  }}