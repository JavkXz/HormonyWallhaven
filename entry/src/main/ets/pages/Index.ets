import { image } from '@kit.ImageKit';

// 壁纸数据类型定义
interface WallpaperItem {
  id: number;
  name: string;
  imageUrl: Resource; // 使用Resource类型来兼容资源对象
  width?: number; // 图片原始宽度
  height?: number; // 图片原始高度
  aspectRatio?: number; // 图片宽高比
  calculatedHeight?: number; // 计算后的高度
}

// 图片尺寸信息接口
interface ImageSizeInfo {
  width: number;
  height: number;
  aspectRatio: number;
}

@Entry
@Component
struct Index {
  @State message: string = '壁纸应用';
  @State wallpaperList: WallpaperItem[] = [];

  // 统一定义间距常量
  private readonly CARD_MARGIN_HORIZONTAL: number = 6; // 卡片水平间距
  private readonly CARD_MARGIN_VERTICAL: number = 6;  // 卡片垂直间距
  private readonly CARD_PADDING: number = 8;          // 卡片内边距

  aboutToAppear() {
    // 从应用的资源配置中获取wallhaven开头的文件列表
    // 这种方式模拟了从外部获取文件列表的场景（例如从服务器或本地数据库）
    // 在实际项目中，这里可能会是一个网络请求或数据库查询
    this.loadWallpaperListFromAssets();
  }

  loadWallpaperListFromAssets() {
    try {
      // 获取已知的wallhaven文件列表
      // 在真实场景中，这可能是从服务器API获取的动态列表
      const knownWallhavenFiles = this.getKnownWallhavenFiles();

      // 创建壁纸列表
      const wallpapers: WallpaperItem[] = [];
      for (let i = 0; i < knownWallhavenFiles.length; i++) {
        const fileName = knownWallhavenFiles[i];
        const imageUrl = $r(`app.media.${fileName}`);

        // 对于media目录下的资源，我们使用预设的宽高比
        // 在实际应用中，这些信息应该从服务器获取或预定义
        const aspectRatio = this.getPresetAspectRatio(fileName);

        const wallpaper: WallpaperItem = {
          id: i + 1,
          name: fileName, // 使用文件名作为壁纸名称
          imageUrl: imageUrl,
          aspectRatio: aspectRatio,
          calculatedHeight: Math.round(150 / aspectRatio) // 基础宽度为150vp
        };
        wallpapers.push(wallpaper);
      }

      this.wallpaperList = wallpapers;
    } catch (error) {
      console.error('加载壁纸失败:', error);

      // 如果无法动态加载，则使用默认列表
      const fallbackWallpapers: WallpaperItem[] = [
        { 
          id: 1, 
          name: '风景壁纸1', 
          imageUrl: $r('app.media.background'),
          aspectRatio: 1.78,
          calculatedHeight: Math.round(150 / 1.78)
        },
        { 
          id: 2, 
          name: '风景壁纸2', 
          imageUrl: $r('app.media.startIcon'),
          aspectRatio: 1.0,
          calculatedHeight: 150
        },
        { 
          id: 3, 
          name: '风景壁纸3', 
          imageUrl: $r('app.media.foreground'),
          aspectRatio: 1.78,
          calculatedHeight: Math.round(150 / 1.78)
        },
      ];
      this.wallpaperList = fallbackWallpapers;
    }
  }

  // 获取预设的宽高比
  private getPresetAspectRatio(fileName: string): number {
    switch (fileName) {
      case 'wallhaven8go6ro':
        return 1.78; // 16:9
      case 'wallhavenlyzdl2':
        return 1.33; // 4:3
      case 'wallhavenrqgpm7':
        return 1.78; // 16:9
      case 'wallhavenvpz2g5':
        return 0.75; // 3:4
      default:
        return 1.78; // 默认16:9
    }
  }

  // 模拟从资源或其他地方获取wallhaven文件列表
  getKnownWallhavenFiles(): string[] {
    // 这里可以是从服务器获取的列表，或从本地数据库读取的列表
    // 目前我们返回已知的文件列表，但在实际应用中这应该是动态的
    return [
      'wallhaven8go6ro',
      'wallhavenlyzdl2',
      'wallhavenrqgpm7',
      'wallhavenvpz2g5'
    ];
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
      Image(item.imageUrl)
        .width('100%')
        .height(item.calculatedHeight ? item.calculatedHeight : 180)
        .objectFit(ImageFit.Cover)
        .borderRadius(8)

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
          }
        }
        .layoutWeight(1)
        .margin({ right: 8 }) // 增加右边距给下载按钮更多空间

        // 下载按钮 - 优化显示
        Button('下载')
          .width(58) // 增加宽度确保文字完整显示
          .height(28) // 略微增加高度
          .fontSize(12) // 使用标准字体大小
          .fontColor('#ffffff')
          .backgroundColor('#ff2262db')
          .borderRadius(14) // 圆角与高度匹配
          .padding({ left: 8, right: 8 }) // 增加内边距
          .onClick(() => {
            console.info(`正在下载壁纸: ${item.name}`);
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
      console.log(`点击了壁纸: ${item.name}`);
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

        // 搜索图标占位
        Image($r('app.media.foreground'))
          .width(24)
          .height(24)
          .visibility(Visibility.Hidden)
      }
      .width('100%')
      .height(50)
      .padding({ left: 16, right: 16 })
      .alignItems(VerticalAlign.Center)
      .backgroundColor('#ffffff')

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
    .width('100%')
    .height('100%')
    .backgroundColor('#f0f0f0')
  }
}