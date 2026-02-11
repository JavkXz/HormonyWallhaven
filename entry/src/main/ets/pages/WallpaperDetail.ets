import { router, promptAction, LengthMetrics } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { WallpaperItem, TagInfo } from '../model/WallpaperModel';
import { image } from '@kit.ImageKit';
import { http } from '@kit.NetworkKit';
import { fileIo as fs } from '@kit.CoreFileKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { AppConfig } from '../utils/AppConfig';
import wallpaper from '@ohos.wallpaper';
import { FavoriteRepository } from '../utils/FavoriteRepository';
import { HapticFeedback } from '../utils/HapticFeedback';
import { globalState } from '../common/GlobalState';

// ----------------------------------------
// 自定义精美选择弹窗
// ----------------------------------------
@CustomDialog
struct WallpaperSelectDialog {
  controller: CustomDialogController;
  onSelect: (type: 'home' | 'lock' | 'both') => void = () => {};
  onCancel: () => void = () => {};

  build() {
    Column() {
      Row() {
        Column().width(36).height(4).backgroundColor('rgba(0,0,0,0.1)').borderRadius(2)
      }
      .width('100%').height(20).justifyContent(FlexAlign.Center)

      Text('Apply Wallpaper')
        .fontSize(21).fontWeight(FontWeight.Bolder).fontColor('#212121')
        .margin({ top: 12, bottom: 28 })

      Row({ space: 24 }) {
        this.OptionItem('Home', $r('sys.symbol.house'), () => this.onSelect('home'))
        this.OptionItem('Lock', $r('sys.symbol.lock'), () => this.onSelect('lock'))
        this.OptionItem('Both', $r('sys.symbol.plus_square'), () => this.onSelect('both'))
      }
      .width('100%').justifyContent(FlexAlign.Center).margin({ bottom: 40 })

      Button('Cancel')
        .width('85%').height(48).backgroundColor('#F5F5F5').fontColor('#424242').borderRadius(24).margin({ bottom: 32 })
        .onClick(() => { this.onCancel(); this.controller.close(); })
    }
    .width('100%').backgroundColor('rgba(255, 255, 255, 0.95)').backgroundBlurStyle(BlurStyle.COMPONENT_ULTRA_THICK).borderRadius({ topLeft: 32, topRight: 32 })
  }

  @Builder
  OptionItem(label: string, icon: Resource, action: () => void) {
    Column() {
      Stack() {
        Circle({ width: 64, height: 64 }).fill('rgba(33, 150, 243, 0.08)')
        SymbolGlyph(icon).fontSize(32).fontColor(['#2196F3'])
      }
      Text(label).fontSize(13).fontWeight(FontWeight.Medium).fontColor('#757575').margin({ top: 12 })
    }
    .onClick(() => { action(); this.controller.close(); })
  }
}

@Entry
@Component
struct WallpaperDetail {
  @State wallpaper: WallpaperItem | null = null;
  @State isDownloading: boolean = false;
  @State isSetting: boolean = false;
  @State isFavorite: boolean = false;
  @State isImageLoaded: boolean = false;
  @State infoOpacity: number = 0;
  @State infoTranslateY: number = 40;
  @State imageScale: number = 0.9;
  @State isDialogActive: boolean = false;

  dialogController: CustomDialogController = new CustomDialogController({
    builder: WallpaperSelectDialog({
      onSelect: (type: 'home' | 'lock' | 'both') => {
        this.isDialogActive = false;
        if (type === 'home') this.setAsWallpaper(wallpaper.WallpaperType.WALLPAPER_SYSTEM);
        else if (type === 'lock') this.setAsWallpaper(wallpaper.WallpaperType.WALLPAPER_LOCKSCREEN);
        else this.setAsWallpaperBoth();
      },
      onCancel: () => { this.isDialogActive = false; }
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
      this.checkFavoriteStatus();
      animateTo({ duration: 800, curve: Curve.FastOutSlowIn }, () => { this.imageScale = 1.0; })
      animateTo({ duration: 600, curve: Curve.EaseOut, delay: 300 }, () => { this.infoOpacity = 1; this.infoTranslateY = 0; })
    }
  }

  async toggleFavorite() {
    if (!this.wallpaper) return;
    try {
      const newStatus = await FavoriteRepository.toggleFavorite(this.wallpaper);
      this.isFavorite = newStatus;
      globalState.updateFavoriteStatus(this.wallpaper.id, newStatus);
      if (newStatus) { HapticFeedback.success(); promptAction.showToast({ message: '已收藏' }); }
      else { HapticFeedback.light(); promptAction.showToast({ message: '已取消收藏' }); }
    } catch (error) { promptAction.showToast({ message: '操作失败' }); }
  }

  private async loadFullDetails() {
    if (this.wallpaper?.id) {
      try {
        const service = AppConfig.getInstance().getWallhavenService();
        const fullDetail = await service.getWallpaperById(this.wallpaper.id);
        if (fullDetail) this.wallpaper = fullDetail;
      } catch (err) { console.error(`[Detail] Load failed: ${err}`); }
    }
  }

  private async downloadImageData(url: string): Promise<ArrayBuffer | null> {
    try {
      const downloadTask = http.createHttp();
      const response = await downloadTask.request(url, {
        expectDataType: http.HttpDataType.ARRAY_BUFFER,
        connectTimeout: 60000, readTimeout: 60000
      });
      return response.responseCode === 200 ? (response.result as ArrayBuffer) : null;
    } catch (err) { return null; }
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
      pixelMap.release(); imageSource.release();
      promptAction.showToast({ message: 'Applied to both!' });
    } catch (e) { promptAction.showToast({ message: 'Apply failed.' }); }
    finally { this.isSetting = false; }
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
      pixelMap.release(); imageSource.release();
      promptAction.showToast({ message: 'Applied successfully!' });
    } catch (error) { promptAction.showToast({ message: 'Failed to apply.' }); }
    finally { this.isSetting = false; }
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
      promptAction.showToast({ message: 'Saved to Gallery!' });
    } catch (error) { promptAction.showToast({ message: 'Save failed.' }); }
    finally { this.isDownloading = false; }
  }

  async checkFavoriteStatus() {
    if (this.wallpaper?.id) {
      this.isFavorite = await FavoriteRepository.isFavorite(this.wallpaper.id);
    }
  }

  @Builder
  InfoCapsule(label: string, icon?: Resource) {
    Row({ space: 6 }) {
      if (icon) SymbolGlyph(icon).fontSize(12).fontColor(['#FFFFFF'])
      Text(label).fontSize(12).fontColor('#FFFFFF').fontWeight(FontWeight.Medium)
    }
    .padding({ left: 12, right: 12, top: 8, bottom: 8 })
    .backgroundColor('rgba(255, 255, 255, 0.15)')
    .backgroundBlurStyle(BlurStyle.Thin)
    .borderRadius(16)
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      if (this.wallpaper !== null) {
        // 1. 视差背景层
        Image(this.wallpaper!.imageUrl)
          .width('100%').height('100%').objectFit(ImageFit.Cover).blur(60).brightness(0.6).scale({ x: 1.2, y: 1.2 }) 

        Scroll() {
          Column() {
            Stack() {
              Image(this.wallpaper!.imageUrl)
                .width('100%').objectFit(ImageFit.Contain)
                .borderRadius((this.wallpaper!.aspectRatio ?? 1) > 1 ? 24 : 0) 
                .shadow({ radius: 40, color: 'rgba(0,0,0,0.4)', offsetY: 20 }).scale({ x: this.imageScale, y: this.imageScale })
                .geometryTransition(this.wallpaper!.id).onComplete(() => { this.isImageLoaded = true; })
            }
            .width((this.wallpaper!.aspectRatio ?? 1) > 1.2 ? '90%' : '100%')
            .margin({ top: (this.wallpaper!.aspectRatio ?? 1) > 1.2 ? '15%' : 0 }) 
            
            Column({ space: 20 }) {
              Column({ space: 8 }) {
                Text(this.wallpaper!.resolution || 'Ultra HD').fontSize(28).fontWeight(FontWeight.Bold).fontColor('#FFFFFF').shadow({ radius: 4, color: 'rgba(0,0,0,0.3)' })
                Row({ space: 10 }) {
                  this.InfoCapsule(this.wallpaper!.category || 'General', $r('sys.symbol.square_grid_2x2'))
                  this.InfoCapsule((this.wallpaper!.purity || 'sfw').toUpperCase(), $r('sys.symbol.lock'))
                }
              }
              .alignItems(HorizontalAlign.Start).width('100%').padding({ left: 24, right: 24 })

              if (this.wallpaper!.tags && this.wallpaper!.tags.length > 0) {
                Flex({ wrap: FlexWrap.Wrap, space: { main: LengthMetrics.vp(8), cross: LengthMetrics.vp(8) } }) {
                  ForEach(this.wallpaper!.tags, (t: TagInfo) => {
                    Text(`# ${t.name}`).fontSize(13).fontColor('rgba(255,255,255,0.8)').padding({ left: 14, right: 14, top: 8, bottom: 8 }).backgroundColor('rgba(255,255,255,0.1)').borderRadius(18)
                      .onClick(() => router.back({ url: 'pages/Index', params: { searchKeyword: t.name } }))
                  })
                }
                .padding({ left: 24, right: 24 })
              }
              Blank().height(150)
            }
            .width('100%').margin({ top: 32 }).opacity(this.infoOpacity).translate({ y: this.infoTranslateY })
          }
          .width('100%')
        }
        .scrollBar(BarState.Off).edgeEffect(EdgeEffect.Spring)

        Row() {
          Button({ type: ButtonType.Circle }) { SymbolGlyph($r('sys.symbol.chevron_left')).fontSize(24).fontColor(['#FFFFFF']) }
          .width(44).height(44).backgroundColor('rgba(255,255,255,0.2)').backgroundBlurStyle(BlurStyle.Thin).onClick(() => router.back())
          Blank()
          Button({ type: ButtonType.Circle }) { SymbolGlyph(this.isFavorite ? $r('sys.symbol.heart_fill') : $r('sys.symbol.heart')).fontSize(24).fontColor([this.isFavorite ? '#FF5252' : '#FFFFFF']) }
          .width(44).height(44).backgroundColor('rgba(255,255,255,0.2)').backgroundBlurStyle(BlurStyle.Thin).onClick(() => this.toggleFavorite())
        }
        .width('100%').padding({ left: 16, right: 16, top: 48, bottom: 16 }).zIndex(100)

        Row({ space: 16 }) {
          Button({ type: ButtonType.Capsule }) {
            Row({ space: 8 }) {
              if (this.isSetting) LoadingProgress().width(20).height(20).color('#FFFFFF')
              else SymbolGlyph($r('sys.symbol.picture')).fontSize(20).fontColor(['#FFFFFF'])
              Text(this.isSetting ? 'Applying...' : 'Set Wallpaper').fontSize(16).fontWeight(FontWeight.Bold).fontColor('#FFFFFF')
            }
          }
          .height(56).layoutWeight(1).backgroundColor('#007DFF').shadow({ radius: 20, color: 'rgba(0,125,255,0.4)', offsetY: 8 }).onClick(() => { this.isDialogActive = true; this.dialogController.open(); }).enabled(!this.isSetting)

          Button({ type: ButtonType.Circle }) {
            if (this.isDownloading) LoadingProgress().width(24).height(24).color('#182431')
            else SymbolGlyph($r('sys.symbol.square_and_arrow_down')).fontSize(24).fontColor(['#182431'])
          }
          .width(56).height(56).backgroundColor('#FFFFFF').shadow({ radius: 20, color: 'rgba(0,0,0,0.15)', offsetY: 8 }).onClick(() => this.saveWallpaper()).enabled(!this.isDownloading)
        }
        .width('90%').position({ x: '5%', y: '100%' }).markAnchor({ x: 0, y: '100%' }).margin({ bottom: 40 }).zIndex(110)
      }
    }
    .width('100%').height('100%').backgroundColor('#000000')
  }

  pageTransition() {
    PageTransitionEnter({ duration: 600, curve: Curve.LinearOutSlowIn }).opacity(0)
    PageTransitionExit({ duration: 600, curve: Curve.LinearOutSlowIn }).opacity(0)
  }
}
