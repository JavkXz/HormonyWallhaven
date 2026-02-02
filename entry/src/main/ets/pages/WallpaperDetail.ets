import { router, promptAction } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { WallpaperItem, TagInfo } from '../model/WallpaperModel';
import { image } from '@kit.ImageKit';
import { http } from '@kit.NetworkKit';
import { fileIo as fs } from '@kit.CoreFileKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { BusinessError } from '@kit.BasicServicesKit';

@Entry
@Component
struct WallpaperDetail {
  @State wallpaper: WallpaperItem | null = null;
  @State isDownloading: boolean = false;
  @State isInfoExpanded: boolean = false; // 是否展开详情

  aboutToAppear() {
    const params = router.getParams() as Record<string, Object>;
    if (params && params.wallpaper) {
      this.wallpaper = params.wallpaper as WallpaperItem;
    }
  }

  // 下载并保存壁纸 (通过 SaveButton 触发)
  async saveWallpaper() {
    if (!this.wallpaper || !this.wallpaper.imageUrl) return;

    this.isDownloading = true;
    const url = this.wallpaper.imageUrl;
    const context = getContext(this) as common.UIAbilityContext;

    try {
      console.info(`[WallpaperDetail] Starting download: ${url}`);
      
      // 1. 下载图片数据
      const downloadTask = http.createHttp();
      const response = await downloadTask.request(url, {
        expectDataType: http.HttpDataType.ARRAY_BUFFER,
        connectTimeout: 60000,
        readTimeout: 60000
      });

      if (response.responseCode !== 200) {
        throw new Error(`Download failed with code ${response.responseCode}`);
      }

      const imageData = response.result as ArrayBuffer;
      console.info(`[WallpaperDetail] Downloaded ${imageData.byteLength} bytes`);

      // 2. 创建相册资产
      const helper = photoAccessHelper.getPhotoAccessHelper(context);
      
      // 根据编译器提示，当前 SDK 版本的 createImageAssetRequest 第二个参数期望 string。
      // 通常这代表文件扩展名 (extension) 或显示名称。我们尝试传入扩展名。
      const assetRequest = photoAccessHelper.MediaAssetChangeRequest.createImageAssetRequest(context, 'jpg');
      
      // 3. 写入数据
      // 注意: createImageAssetRequest 返回的 changeRequest 并不直接提供写入流，
      // 我们需要先拿到临时 URI 或者使用 buffer 写入。
      // API 11+ 正确做法:
      // 使用 assetRequest.addResource(photoAccessHelper.ResourceType.IMAGE_RESOURCE, dataBuffer) 是不对的，addResource 通常用于文件路径。
      // 正确流程: 
      // A. 使用 fs 将数据写入 cache 目录的临时文件
      // B. 使用 assetRequest.addResource(..., tempFilePath)
      
      const tempFileName = `wallhaven_${new Date().getTime()}.jpg`;
      const tempFilePath = `${context.cacheDir}/${tempFileName}`;
      
      const file = fs.openSync(tempFilePath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
      fs.writeSync(file.fd, imageData);
      fs.closeSync(file);
      console.info(`[WallpaperDetail] Saved temp file: ${tempFilePath}`);

      assetRequest.addResource(photoAccessHelper.ResourceType.IMAGE_RESOURCE, tempFilePath);
      
      // 4. 应用更改 (保存到相册)
      await helper.applyChanges(assetRequest);
      
      // 5. 清理临时文件
      try {
        fs.unlinkSync(tempFilePath);
      } catch (ignore) {}

      promptAction.showToast({ message: 'Saved to Gallery successfully!', duration: 2000 });

    } catch (error) {
      console.error(`[WallpaperDetail] Save failed: ${JSON.stringify(error)}`);
      promptAction.showToast({ message: 'Download failed. Check network.', duration: 2000 });
    } finally {
      this.isDownloading = false;
    }
  }

  @Builder
  TagChip(tag: TagInfo) {
    Text(tag.name)
      .fontSize(12)
      .fontColor('#e0e0e0')
      .padding({ left: 10, right: 10, top: 4, bottom: 4 })
      .backgroundColor('rgba(255,255,255,0.15)')
      .borderRadius(16)
      .margin({ right: 6, bottom: 6 })
  }

  @Builder
  ColorCircle(color: string) {
    Circle({ width: 24, height: 24 })
      .fill(color)
      .stroke('#ffffff')
      .strokeWidth(1)
      .margin({ right: 8 })
  }

  build() {
    Stack() {
      if (this.wallpaper) {
        // 1. 背景大图 (支持简单的点击查看)
        Image(this.wallpaper.imageUrl)
          .width('100%')
          .height('100%')
          .objectFit(ImageFit.Contain)
          .backgroundColor('#000000')

        // 2. 顶部导航栏 (透明)
        Row() {
          Button({ type: ButtonType.Circle, stateEffect: true }) {
            Text('<')
              .fontSize(20)
              .fontColor('#ffffff')
          }
          .width(40)
          .height(40)
          .backgroundColor('rgba(0,0,0,0.3)')
          .onClick(() => router.back())
          .margin({ left: 16, top: 48 }) // 避开状态栏
        }
        .width('100%')
        .alignItems(VerticalAlign.Top)
        .justifyContent(FlexAlign.Start)
        .position({ x: 0, y: 0 })

        // 3. 底部详细信息面板
        Column() {
          // 抓手 (Handle)
          Row() {
            Column()
              .width(40)
              .height(4)
              .backgroundColor('rgba(255,255,255,0.4)')
              .borderRadius(2)
          }
          .width('100%')
          .justifyContent(FlexAlign.Center)
          .padding({ top: 12, bottom: 12 })
          .onClick(() => {
             this.isInfoExpanded = !this.isInfoExpanded;
          })

          // 主要信息行
          Row() {
            Column() {
              Text(this.wallpaper.resolution)
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor('#ffffff')
              Text(`${this.wallpaper.category || 'General'} • ${(this.wallpaper.purity || 'sfw').toUpperCase()}`)
                .fontSize(12)
                .fontColor('rgba(255,255,255,0.7)')
                .margin({ top: 4 })
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)

            // 安全保存按钮 (SaveButton)
            // 注意：SaveButton 必须由用户点击触发，不能通过代码模拟点击
            if (this.isDownloading) {
              Button('Downloading...')
                .fontSize(14)
                .height(40)
                .padding({ left: 24, right: 24 })
                .backgroundColor('#424242')
                .fontColor('#ffffff')
                .borderRadius(20)
                .enabled(false)
            } else {
              SaveButton({ icon: SaveIconStyle.FULL_FILLED, text: SaveDescription.DOWNLOAD, buttonType: ButtonType.Capsule })
                .onClick(async (event, result: SaveButtonOnClickResult) => {
                  if (result == SaveButtonOnClickResult.SUCCESS) {
                     await this.saveWallpaper();
                  } else {
                     promptAction.showToast({ message: 'Permission denied to save photo.' });
                  }
                })
                .fontColor('#ffffff')
                .backgroundColor('#2262db')
                // SaveButton 的样式属性可能受限，需查阅文档确认是否支持所有通用属性
                // 通常支持 width, height, backgroundColor, fontColor
            }
          }
          .width('100%')
          .padding({ left: 16, right: 16, bottom: 16 })

          // 扩展信息 (Tags & Colors) - 仅在有足够空间或展开时显示
          List() {
             // 颜色板
             if (this.wallpaper.colors && this.wallpaper.colors.length > 0) {
               ListItem() {
                 Row() {
                   ForEach(this.wallpaper.colors, (color: string) => {
                     this.ColorCircle(color)
                   })
                 }
                 .width('100%')
                 .padding({ left: 16, right: 16, bottom: 16 })
               }
             }

             // 标签云
             if (this.wallpaper.tags && this.wallpaper.tags.length > 0) {
               ListItem() {
                 Flex({ wrap: FlexWrap.Wrap }) {
                   ForEach(this.wallpaper.tags, (tag: TagInfo) => {
                     this.TagChip(tag)
                   })
                 }
                 .width('100%')
                 .padding({ left: 16, right: 16, bottom: 32 })
               }
             }
             
             // 底部留白
             ListItem().height(20)
          }
          .width('100%')
          .layoutWeight(1) // 占用剩余空间
        }
        .width('100%')
        // 根据是否展开调整高度
        .height(this.isInfoExpanded ? '60%' : '35%') 
        .backgroundColor('rgba(30, 30, 30, 0.95)') // 深色毛玻璃背景
        .borderRadius({ topLeft: 24, topRight: 24 })
        .position({ x: 0, y: '100%' })
        .markAnchor({ x: 0, y: '100%' })
        .animation({ duration: 300, curve: Curve.FastOutSlowIn }) // 动画效果
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#000000')
  }
}
