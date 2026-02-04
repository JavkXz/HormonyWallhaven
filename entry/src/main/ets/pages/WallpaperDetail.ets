import { router, promptAction } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { WallpaperItem, TagInfo } from '../model/WallpaperModel';
import { image } from '@kit.ImageKit';
import { http } from '@kit.NetworkKit';
import { fileIo as fs } from '@kit.CoreFileKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { AppConfig } from '../utils/AppConfig';

@Entry
@Component
struct WallpaperDetail {
  @State wallpaper: WallpaperItem | null = null;
  @State isDownloading: boolean = false;
  @State isInfoExpanded: boolean = false; // 是否展开详情
  @State isPanelVisible: boolean = true; // 是否显示信息面板

  aboutToAppear() {
    const params = router.getParams() as Record<string, Object>;
    if (params && params.wallpaper) {
      this.wallpaper = params.wallpaper as WallpaperItem;
      this.loadFullDetails();
    }
  }

  // 异步加载壁纸详情 (获取完整的标签等信息)
  private async loadFullDetails() {
    if (this.wallpaper && this.wallpaper.id) {
      try {
        const service = AppConfig.getInstance().getWallhavenService();
        const fullDetail = await service.getWallpaperById(this.wallpaper.id);
        if (fullDetail) {
          // 只有当 ID 匹配时才更新，防止异步竞争
          if (this.wallpaper.id === fullDetail.id) {
            this.wallpaper = fullDetail;
          }
        }
      } catch (err) {
        console.error(`[WallpaperDetail] Failed to load details: ${JSON.stringify(err)}`);
      }
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

      // 2. 创建相册资产 (使用 helper.createAsset 直接创建)
      const helper = photoAccessHelper.getPhotoAccessHelper(context);
      
      // 注意: createAsset 的第二个参数是扩展名 (不带点)
      // 这会创建一个空的 Asset 并返回其 URI
      const assetUri = await helper.createAsset(photoAccessHelper.PhotoType.IMAGE, 'jpg');
      console.info(`[WallpaperDetail] Created asset URI: ${assetUri}`);
      
      // 3. 写入数据到 Asset URI
      // 使用 fs 打开 URI 进行写入
      const file = fs.openSync(assetUri, fs.OpenMode.READ_WRITE);
      fs.writeSync(file.fd, imageData);
      fs.closeSync(file);
      
      // 4. 不需要 ChangeRequest，直接写入即完成
      // 但为了确保系统索引更新，有时可以显式关闭或触发媒体扫描，通常 createAsset 后系统会自动处理。
      
      promptAction.showToast({ message: 'Saved to Gallery successfully!', duration: 2000 });

    } catch (error) {
      console.error(`[WallpaperDetail] Save failed: ${JSON.stringify(error)}`);
      // 如果是权限或取消问题，给出特定提示
      let msg = 'Download failed.';
      const err = error as BusinessError;
      if (err && err.code === 13900002) {
        msg = 'System error: No such file.';
      }
      promptAction.showToast({ message: msg, duration: 2000 });
    } finally {
      this.isDownloading = false;
    }
  }

  @Builder
  TagChip(tag: TagInfo) {
    Row() {
      Text(`# ${tag.name}`)
        .fontSize(12)
        .fontColor('#ffffff')
        .fontWeight(FontWeight.Medium)
    }
    .padding({ left: 12, right: 12, top: 6, bottom: 6 })
    .backgroundColor('rgba(255,255,255,0.1)')
    .backgroundBlurStyle(BlurStyle.Thin)
    .borderRadius(16)
    .margin({ right: 8, bottom: 8 })
    .onClick(() => {
      // 点击标签，返回首页并执行搜索
      console.info(`[WallpaperDetail] Tag clicked: ${tag.name}, returning to search.`);
      router.back({
        url: 'pages/Index',
        params: {
          searchKeyword: tag.name
        }
      });
    })
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
          .onClick(() => {
            // 点击壁纸切换面板显示/隐藏状态
            this.isPanelVisible = !this.isPanelVisible;
          })

        // 2. 顶部导航栏 (透明)
        Row() {
          Button({ type: ButtonType.Circle, stateEffect: true }) {
            SymbolGlyph($r('sys.symbol.chevron_left'))
              .fontSize(24)
              .fontColor(['#ffffff'])
          }
          .width(44)
          .height(44)
          .backgroundColor('rgba(0,0,0,0.2)')
          .backgroundBlurStyle(BlurStyle.Thin) // 毛玻璃效果
          .onClick(() => router.back())
          .margin({ left: 16, top: 48 }) // 避开状态栏
        }
        .width('100%')
        .alignItems(VerticalAlign.Top)
        .justifyContent(FlexAlign.Start)
        .position({ x: 0, y: 0 })
        .zIndex(10)

        // 3. 底部详细信息面板
        Column() {
          // 抓手 (Handle) - 仅在非极简模式下显示
          Row() {
            Column()
              .width(40)
              .height(4)
              .backgroundColor('rgba(255,255,255,0.4)')
              .borderRadius(2)
          }
          .width('100%')
          .height(this.isPanelVisible ? 28 : 0)
          .visibility(this.isPanelVisible ? Visibility.Visible : Visibility.None)
          .justifyContent(FlexAlign.Center)
          .onClick(() => {
             this.isInfoExpanded = !this.isInfoExpanded;
          })

          // 主要信息行 (始终显示)
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
            }
          }
          .width('100%')
          .height(80) // 固定高度确保在极简模式下显示一致
          .padding({ left: 16, right: 16 })

          // 扩展信息 (Tags & Colors) - 仅在有足够空间或展开时显示
          if (this.isPanelVisible) {
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
                   .padding({ left: 16, right: 16, top: 12, bottom: 16 })
                 }
               }

               // 标签云标题
               if (this.wallpaper.tags && this.wallpaper.tags.length > 0) {
                 ListItem() {
                   Row() {
                     Text('#')
                       .fontSize(16)
                       .fontWeight(FontWeight.Bold)
                       .fontColor('rgba(255,255,255,0.6)')
                       .margin({ right: 8 })
                     Text('Keywords')
                       .fontSize(14)
                       .fontWeight(FontWeight.Medium)
                       .fontColor('rgba(255,255,255,0.6)')
                   }
                   .padding({ left: 16, bottom: 8 })
                 }
               }

               // 标签云内容
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
            .layoutWeight(1) 
          }
        }
        .width('100%')
        // 动态调整高度：极简模式 80vp，普通模式 35% 或 60%
        .height(this.isPanelVisible ? (this.isInfoExpanded ? '60%' : '35%') : 80) 
        .backgroundColor('rgba(30, 30, 30, 0.85)') // 降低不透明度配合毛玻璃
        .backgroundBlurStyle(BlurStyle.Thin) // 面板也增加毛玻璃效果
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