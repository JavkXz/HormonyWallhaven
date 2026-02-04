import { router, promptAction } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { WallpaperItem, TagInfo } from '../model/WallpaperModel';
import { image } from '@kit.ImageKit';
import { http } from '@kit.NetworkKit';
import { fileIo as fs } from '@kit.CoreFileKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { AppConfig } from '../utils/AppConfig';
import wallpaper from '@ohos.wallpaper';

// ----------------------------------------
// 自定义精美选择弹窗 (浅色方案)
// ----------------------------------------
@CustomDialog
struct WallpaperSelectDialog {
  controller: CustomDialogController;
  onSelect: (type: 'home' | 'lock' | 'both') => void = () => {};
  onCancel: () => void = () => {};

  build() {
    Column() {
      // 装饰条
      Row() {
        Column().width(36).height(4).backgroundColor('rgba(0,0,0,0.1)').borderRadius(2)
      }
      .width('100%').height(20).justifyContent(FlexAlign.Center)

      Text('Apply Wallpaper')
        .fontSize(21)
        .fontWeight(FontWeight.Bolder)
        .fontColor('#212121')
        .margin({ top: 12, bottom: 28 })

      Row({ space: 24 }) {
        this.OptionItem('Home', $r('sys.symbol.house'), () => this.onSelect('home'))
        this.OptionItem('Lock', $r('sys.symbol.lock'), () => this.onSelect('lock'))
        this.OptionItem('Both', $r('sys.symbol.plus_square'), () => this.onSelect('both'))
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .margin({ bottom: 40 })

      Button('Cancel')
        .width('85%')
        .height(48)
        .backgroundColor('#F5F5F5')
        .fontColor('#424242')
        .fontWeight(FontWeight.Medium)
        .borderRadius(24)
        .margin({ bottom: 32 })
        .onClick(() => {
          this.onCancel();
          this.controller.close();
        })
    }
    .width('100%')
    .backgroundColor('rgba(255, 255, 255, 0.95)')
    .backgroundBlurStyle(BlurStyle.COMPONENT_ULTRA_THICK)
    .borderRadius({ topLeft: 32, topRight: 32 })
  }

  @Builder
  OptionItem(label: string, icon: Resource, action: () => void) {
    Column() {
      Stack() {
        Circle({ width: 64, height: 64 })
          .fill('rgba(33, 150, 243, 0.08)')
        SymbolGlyph(icon)
          .fontSize(32)
          .fontColor(['#2196F3'])
      }
      Text(label)
        .fontSize(13)
        .fontWeight(FontWeight.Medium)
        .fontColor('#757575')
        .margin({ top: 12 })
    }
    .onClick(() => {
      action();
      this.controller.close();
    })
  }
}

@Entry
@Component
struct WallpaperDetail {
  @State wallpaper: WallpaperItem | null = null;
  @State isDownloading: boolean = false;
  @State isSetting: boolean = false;
  @State isInfoExpanded: boolean = false;
  @State isPanelVisible: boolean = true; // 控制完整模式 vs 极简模式
  @State isDialogActive: boolean = false; // 控制面板是否完全隐藏（用于弹窗避让）

  // 弹窗控制器
  dialogController: CustomDialogController = new CustomDialogController({
    builder: WallpaperSelectDialog({
      onSelect: (type: 'home' | 'lock' | 'both') => {
        this.isDialogActive = false;
        if (type === 'home') this.setAsWallpaper(wallpaper.WallpaperType.WALLPAPER_SYSTEM);
        else if (type === 'lock') this.setAsWallpaper(wallpaper.WallpaperType.WALLPAPER_LOCKSCREEN);
        else this.setAsWallpaperBoth();
      },
      onCancel: () => {
        this.isDialogActive = false;
      }
    }),
    autoCancel: true,
    cancel: () => { this.isDialogActive = false; },
    alignment: DialogAlignment.Bottom,
    customStyle: true
  })

  aboutToAppear() {
    const params = router.getParams() as Record<string, Object>;
    if (params && params.wallpaper) {
      this.wallpaper = params.wallpaper as WallpaperItem;
      this.loadFullDetails();
    }
  }

  private async loadFullDetails() {
    if (this.wallpaper?.id) {
      try {
        const service = AppConfig.getInstance().getWallhavenService();
        const fullDetail = await service.getWallpaperById(this.wallpaper.id);
        if (fullDetail && this.wallpaper.id === fullDetail.id) {
          this.wallpaper = fullDetail;
        }
      } catch (err) {
        console.error(`[WallpaperDetail] Failed: ${JSON.stringify(err)}`);
      }
    }
  }

  private async downloadImageData(url: string): Promise<ArrayBuffer | null> {
    try {
      const downloadTask = http.createHttp();
      const response = await downloadTask.request(url, {
        expectDataType: http.HttpDataType.ARRAY_BUFFER,
        connectTimeout: 60000,
        readTimeout: 60000
      });
      return response.responseCode === 200 ? (response.result as ArrayBuffer) : null;
    } catch (err) {
      return null;
    }
  }

  async setAsWallpaperBoth() {
    if (!this.wallpaper?.imageUrl) return;
    this.isSetting = true;
    try {
      const imageData = await this.downloadImageData(this.wallpaper.imageUrl);
      if (!imageData) throw new Error('Download failed');
      const imageSource = image.createImageSource(imageData);
      const pixelMap = await imageSource.createPixelMap();
      await wallpaper.setWallpaper(pixelMap, wallpaper.WallpaperType.WALLPAPER_SYSTEM);
      await wallpaper.setWallpaper(pixelMap, wallpaper.WallpaperType.WALLPAPER_LOCKSCREEN);
      pixelMap.release();
      imageSource.release();
      promptAction.showToast({ message: 'Home & Lock screen updated!', duration: 2500 });
    } catch (e) {
      promptAction.showToast({ message: 'Set failed.' });
    } finally {
      this.isSetting = false;
    }
  }

  async setAsWallpaper(type: wallpaper.WallpaperType) {
    if (!this.wallpaper?.imageUrl) return;
    this.isSetting = true;
    try {
      const imageData = await this.downloadImageData(this.wallpaper.imageUrl);
      if (!imageData) throw new Error('Download failed');
      const imageSource = image.createImageSource(imageData);
      const pixelMap = await imageSource.createPixelMap();
      await wallpaper.setWallpaper(pixelMap, type);
      pixelMap.release();
      imageSource.release();
      promptAction.showToast({ message: 'Applied successfully!', duration: 2500 });
    } catch (error) {
      promptAction.showToast({ message: 'Failed to apply.' });
    } finally {
      this.isSetting = false;
    }
  }

  async saveWallpaper() {
    if (!this.wallpaper) return;
    this.isDownloading = true;
    try {
      const imageData = await this.downloadImageData(this.wallpaper.imageUrl);
      if (!imageData) throw new Error('Download failed');
      const helper = photoAccessHelper.getPhotoAccessHelper(getContext(this));
      const assetUri = await helper.createAsset(photoAccessHelper.PhotoType.IMAGE, 'jpg');
      const file = fs.openSync(assetUri, fs.OpenMode.READ_WRITE);
      fs.writeSync(file.fd, imageData);
      fs.closeSync(file);
      promptAction.showToast({ message: 'Saved to Gallery!', duration: 2000 });
    } catch (error) {
      promptAction.showToast({ message: 'Save failed.' });
    } finally {
      this.isDownloading = false;
    }
  }

  @Builder
  TagChip(tag: TagInfo) {
    Row() {
      Text(`# ${tag.name}`).fontSize(12).fontColor('#616161').fontWeight(FontWeight.Bold)
    }
    .padding({ left: 12, right: 12, top: 6, bottom: 6 })
    .backgroundColor('#F5F5F5')
    .borderRadius(16).margin({ right: 8, bottom: 8 })
    .onClick(() => {
      router.back({ url: 'pages/Index', params: { searchKeyword: tag.name } });
    })
  }

  build() {
    Stack() {
            if (this.wallpaper) {
              // 1. 背景大图 (支持共享元素转场)
              Image(this.wallpaper.imageUrl)
                .width('100%')
                .height('100%')
                .objectFit(ImageFit.Contain)
                .backgroundColor('#000000')
                .geometryTransition(this.wallpaper.id) // 匹配首页的 ID
                .onClick(() => { 
                  this.isPanelVisible = !this.isPanelVisible; // 切换 完整/极简 模式
                })

        // 顶部返回
        Row() {
          Button({ type: ButtonType.Circle }) {
            SymbolGlyph($r('sys.symbol.chevron_left')).fontSize(24).fontColor(['#212121'])
          }
          .width(44).height(44).backgroundColor('rgba(255,255,255,0.6)').backgroundBlurStyle(BlurStyle.Thin)
          .onClick(() => router.back())
          .margin({ left: 16, top: 48 })
        }
        .width('100%').position({ x: 0, y: 0 }).zIndex(10)

        // 详情面板
        Column() {
          // Handle - 仅在完整模式下显示
          Row() {
            Column().width(40).height(4).backgroundColor('rgba(0,0,0,0.1)').borderRadius(2)
          }
          .width('100%')
          .height(this.isPanelVisible ? 28 : 0)
          .visibility(this.isPanelVisible ? Visibility.Visible : Visibility.None)
          .justifyContent(FlexAlign.Center)
          .onClick(() => { this.isInfoExpanded = !this.isInfoExpanded; })

          // 核心操作行 (始终显示)
          Row() {
            Column() {
              Text(this.wallpaper?.resolution || 'Original')
                .fontSize(18).fontWeight(FontWeight.Bold).fontColor('#212121')
              Text(`${this.wallpaper?.category || 'General'} • ${(this.wallpaper?.purity || 'sfw').toUpperCase()}`)
                .fontSize(12).fontColor('#757575').margin({ top: 4 })
            }
            .alignItems(HorizontalAlign.Start).layoutWeight(1)

            Row({ space: 12 }) {
              Button({ type: ButtonType.Capsule }) {
                Row({ space: 6 }) {
                  if (this.isSetting) LoadingProgress().width(18).height(18).color('#ffffff')
                  else SymbolGlyph($r('sys.symbol.picture')).fontSize(18).fontColor(['#ffffff'])
                  Text(this.isSetting ? 'Applying' : 'Set').fontSize(15).fontColor('#ffffff').fontWeight(FontWeight.Bold)
                }
              }
              .height(44).layoutWeight(1).backgroundColor('#2196F3')
              .shadow({ radius: 12, color: 'rgba(33, 150, 243, 0.3)', offsetY: 4 })
              .onClick(() => {
                this.isDialogActive = true; // 准备显示弹窗，面板完全收起
                this.dialogController.open();
              })
              .enabled(!this.isSetting)

              if (this.isDownloading) {
                Button() { LoadingProgress().width(18).height(18).color('#424242') }
                .height(44).layoutWeight(1).backgroundColor('#F5F5F5').borderRadius(22)
              } else {
                Row() {
                  SaveButton({ icon: SaveIconStyle.FULL_FILLED, text: SaveDescription.DOWNLOAD, buttonType: ButtonType.Capsule })
                    .height(44)
                    .fontColor('#424242')
                    .fontSize(15).fontWeight(FontWeight.Bold)
                    .backgroundColor('#F5F5F5')
                    .onClick((event: ClickEvent, result: SaveButtonOnClickResult) => {
                      if (result === SaveButtonOnClickResult.SUCCESS) this.saveWallpaper();
                    })
                }
                .layoutWeight(1)
              }
            }
            .layoutWeight(1).margin({ left: 24 })
          }
          .width('100%').height(80).padding({ left: 16, right: 16 })

          // 扩展列表 (颜色/标签) - 仅在非极简模式下显示
          if (this.isPanelVisible) {
            List() {
              if (this.wallpaper?.colors) {
                ListItem() {
                  Row() {
                    ForEach(this.wallpaper?.colors || [], (c: string) => {
                      Circle({ width: 24, height: 24 }).fill(c).margin({ right: 8 }).stroke('rgba(0,0,0,0.05)').strokeWidth(1)
                    })
                  }
                  .padding({ left: 16, top: 12, bottom: 16 })
                }
              }
              if (this.wallpaper?.tags) {
                ListItem() {
                  Row() {
                    Text('#').fontSize(16).fontWeight(FontWeight.Bold).fontColor('#757575').margin({ right: 8 });
                    Text('Keywords').fontSize(14).fontWeight(FontWeight.Bold).fontColor('#757575')
                  }
                  .padding({ left: 16, bottom: 8 })
                }
                ListItem() {
                  Flex({ wrap: FlexWrap.Wrap }) {
                    ForEach(this.wallpaper?.tags || [], (t: TagInfo) => this.TagChip(t))
                  }
                  .padding({ left: 16, right: 16, bottom: 32 })
                }
              }
              ListItem().height(20)
            }
            .layoutWeight(1)
          }
        }
        .width('100%')
        // 核心高度逻辑：弹窗时 0，否则根据 isPanelVisible 决定是 35%/60% 还是 80vp
        .height(this.isDialogActive ? 0 : (this.isPanelVisible ? (this.isInfoExpanded ? '60%' : '35%') : 80))
        .backgroundColor('rgba(255, 255, 255, 0.9)')
        .backgroundBlurStyle(BlurStyle.COMPONENT_ULTRA_THICK)
        .borderRadius({ topLeft: 24, topRight: 24 })
        .position({ x: 0, y: '100%' }).markAnchor({ x: 0, y: '100%' })
        .animation({ duration: 300, curve: Curve.FastOutSlowIn })
      }
    }
    .width('100%').height('100%').backgroundColor('#000000')
  }

  // 页面转场配置
  pageTransition() {
    PageTransitionEnter({ duration: 400, curve: Curve.Linear })
      .opacity(0)
    PageTransitionExit({ duration: 400, curve: Curve.Linear })
      .opacity(0)
  }
}