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

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Text(this.message)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Start)

        // 搜索图标占位
        Image($r('app.media.foreground'))
          .width(24)
          .height(24)
          .visibility(Visibility.Hidden) // 暂时隐藏，后续可替换为真实的搜索图标
      }
      .width('100%')
      .height(50)
      .padding({ left: 16, right: 16 })
      .alignItems(VerticalAlign.Center)

      // 网格布局展示壁纸
      Scroll() {
        Column() {
          // 使用GridRow来创建两列布局
          GridRow({ columns: 2, gutter: 8 }) {
            ForEach(this.wallpaperList, (item: WallpaperItem) => {
              GridCol({
                span: 1,
                offset: 0
              }) {
                // 壁纸卡片
                Column() {
                  Image(item.imageUrl)
                    .width('100%')
                    .height(item.calculatedHeight ? item.calculatedHeight : 200)  // 使用计算后的高度
                    .objectFit(ImageFit.Cover)  // 保持图片比例并裁剪
                    .borderRadius(12)

                  // 壁纸信息
                  Row() {
                    Column() {
                      Text(item.name)
                        .fontSize(14)
                        .fontWeight(FontWeight.Medium)
                        .maxLines(1)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })

                      if (item.aspectRatio) {
                        Text(`宽高比: ${item.aspectRatio.toFixed(2)}`)
                          .fontSize(12)
                          .fontColor('#888888')
                          .margin({ top: 4 })
                      }
                    }
                    .layoutWeight(1)

                    // 下载按钮
                    Button('下载')
                      .width(60)
                      .height(30)
                      .fontSize(12)
                      .backgroundColor('#FF4081')
                      .borderRadius(15)
                      .onClick(() => {
                        console.info(`正在下载壁纸: ${item.name}`);
                        // 实现下载功能
                      })
                  }
                  .width('100%')
                  .margin({ top: 8 })
                }
                .backgroundColor('#ffffff')
                .padding(12)
                .borderRadius(12)
                .shadow({
                  radius: 4,
                  color: '#1F000000',
                  offsetX: 0,
                  offsetY: 2
                })
                .onClick(() => {
                  // 这里可以处理点击事件，如跳转到详情页
                  console.log(`点击了壁纸: ${item.name}`);
                })
              }
            })
          }
          .padding({ left: 12, right: 12 })
        }
      }
      .layoutWeight(1)
      .scrollBar(BarState.On)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f0f0f0')
  }
}