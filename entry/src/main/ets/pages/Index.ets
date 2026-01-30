import { image } from '@kit.ImageKit';
import { WallpaperItem } from '../model/WallpaperModel';
import { WallhavenService } from '../service/WallhavenService';
import { AppConfig } from '../utils/AppConfig';

@Entry
@Component
struct Index {
  @State message: string = '壁纸应用';
  @State wallpaperList: WallpaperItem[] = [];
  @State isLoading: boolean = false;

  // 统一定义间距常量
  private readonly CARD_MARGIN_HORIZONTAL: number = 6; // 卡片水平间距
  private readonly CARD_MARGIN_VERTICAL: number = 6;  // 卡片垂直间距
  private readonly CARD_PADDING: number = 8;          // 卡片内边距

  // 获取Wallhaven服务实例
  private wallhavenService: WallhavenService = AppConfig.getInstance().getWallhavenService();

  aboutToAppear() {
    // 从wallhaven API获取壁纸列表
    this.loadWallpaperListFromApi();
  }

  async loadWallpaperListFromApi() {
    try {
      this.isLoading = true;

      // 调用wallhaven API获取壁纸列表
      const wallpapers = await this.wallhavenService.searchWallpapers({
        purity: '100',  // 只获取SFW壁纸
        sorting: 'date_added',  // 按日期排序
        order: 'desc',  // 降序排列
        page: 1  // 第一页
      });

      this.wallpaperList = wallpapers;
    } catch (error) {
      console.error('[Index] 从API加载壁纸失败:', error);

      // 如果API调用失败，使用默认列表
      const fallbackWallpapers: WallpaperItem[] = [
        {
          id: '1',
          name: '风景壁纸1',
          imageUrl: 'https://w.wallhaven.cc/full/8g/wallhaven-8go6ro.jpg',
          aspectRatio: 1.78,
          calculatedHeight: Math.round(150 / 1.78)
        },
        {
          id: '2',
          name: '风景壁纸2',
          imageUrl: 'https://w.wallhaven.cc/full/ly/wallhaven-lyzdl2.jpg',
          aspectRatio: 1.0,
          calculatedHeight: 150
        },
        {
          id: '3',
          name: '风景壁纸3',
          imageUrl: 'https://w.wallhaven.cc/full/rq/wallhaven-rqgpm7.jpg',
          aspectRatio: 1.78,
          calculatedHeight: Math.round(150 / 1.78)
        },
      ];
      this.wallpaperList = fallbackWallpapers;
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * 执行搜索
   * @param query 搜索关键词
   */
  async performSearch(query: string) {
    try {
      this.isLoading = true;

      // 调用wallhaven API搜索壁纸
      const wallpapers = await this.wallhavenService.searchWallpapers({
        q: query,        // 搜索关键词
        purity: '100',   // 只获取SFW壁纸
        sorting: 'relevance',  // 按相关性排序
        order: 'desc',   // 降序排列
        page: 1         // 第一页
      });

      this.wallpaperList = wallpapers;
    } catch (error) {
      console.error(`[Index] 搜索 "${query}" 失败:`, error);
    } finally {
      this.isLoading = false;
    }
  }

  // 带间距的壁纸卡片组件
  @Builder
  WallpaperCardWithMargin(item: WallpaperItem) {
    Column() {
      this.WallpaperCardContent(item)
    }
    .margin({
      left: this.CARD_MARGIN_HORIZONTAL,
      right: this.CARD_MARGIN_HORIZONTAL,
      top: this.CARD_MARGIN_VERTICAL,
      bottom: this.CARD_MARGIN_VERTICAL
    })
  }

  // 壁纸卡片内容组件
  @Builder
  WallpaperCardContent(item: WallpaperItem) {
    Column() {
      // 使用远程图片URL
      Image(item.imageUrl)
        .width('100%')
        .height(item.calculatedHeight ? item.calculatedHeight : 180)
        .objectFit(ImageFit.Cover)
        .borderRadius(8)
        .onComplete(() => {
          console.info(`[Index] 图片加载完成: ${item.name}`);
        })
        .onError(() => {
          console.error(`[Index] 图片加载失败: ${item.name}`);
        })

      // 壁纸信息
      Row() {
        Column() {
          Text(item.name)
            .fontSize(13)
            .fontWeight(FontWeight.Medium)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          if (item.aspectRatio) {
            Text(`宽高比: ${item.aspectRatio.toFixed(2)}`)
              .fontSize(11)
              .fontColor('#888888')
              .margin({ top: 2 })

            // 显示分辨率信息
            if (item.resolution) {
              Text(`分辨率: ${item.resolution}`)
                .fontSize(11)
                .fontColor('#888888')
                .margin({ top: 2 })
            }
          }
        }
        .layoutWeight(1)
        .margin({ right: 8 })

        // 下载按钮
        Button('下载')
          .width(58)
          .height(28)
          .fontSize(12)
          .fontColor('#ffffff')
          .backgroundColor('#ff2262db')
          .borderRadius(14)
          .padding({ left: 8, right: 8 })
          .onClick(() => {
            console.info(`[Index] 正在下载壁纸: ${item.name} (${item.id})`);
          })
      }
      .width('100%')
      .margin({ top: 6 })
    }
    .backgroundColor('#ffffff')
    .padding(this.CARD_PADDING)
    .borderRadius(8)
    .width('100%')
    .shadow({
      radius: 3,
      color: '#1F000000',
      offsetX: 0,
      offsetY: 1
    })
    .onClick(() => {
      console.log(`[Index] 点击了壁纸: ${item.name} (${item.id})`);
    })
  }

  // 原始壁纸卡片组件（保持兼容性）
  @Builder
  WallpaperCard(item: WallpaperItem) {
    this.WallpaperCardContent(item)
  }

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Text(this.message)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .backgroundColor('#ffffff')

        // 搜索图标
        Image($r('app.media.foreground'))
          .width(24)
          .height(24)
          .onClick(() => {
            this.performSearch('nature'); // 示例搜索
          })
      }
      .width('100%')
      .height(50)
      .padding({ left: 16, right: 16 })
      .alignItems(VerticalAlign.Center)
      .backgroundColor('#ffffff')

      // 显示加载状态
      if (this.isLoading) {
        Column() {
          Text('正在加载壁纸...')
            .fontSize(16)
            .fontColor('#666666')
          Progress({
            value: 50,
            total: 100
          })
          .width(100)
          .height(10)
          .margin({ top: 10 })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      } else {
        // 使用WaterFlow组件实现两列瀑布流布局
        WaterFlow() {
          ForEach(this.wallpaperList, (item: WallpaperItem) => {
            FlowItem() {
              this.WallpaperCardWithMargin(item)
            }
          })
        }
        .columnsTemplate('1fr 1fr') // 两列等宽布局
        .columnsGap(0) // 使用卡片margin控制列间距
        .rowsGap(0)   // 使用卡片margin控制行间距
        .padding({ left: 0, right: 0, top: 8, bottom: 8 }) // 只保留上下边距
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f0f0f0')
  }
}