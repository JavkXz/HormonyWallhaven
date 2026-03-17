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
        Column().width(36).height(4).backgroundColor('rgba(255,255,255,0.2)').borderRadius(2)
      }
      .width('100%').height(20).justifyContent(FlexAlign.Center)

      Text('Apply Wallpaper')
        .fontSize(21).fontWeight(FontWeight.Bolder).fontColor('#FFFFFF')
        .margin({ top: 12, bottom: 28 })

      Row({ space: 24 }) {
        this.OptionItem('Home', $r('sys.symbol.house'), () => this.onSelect('home'))
        this.OptionItem('Lock', $r('sys.symbol.lock'), () => this.onSelect('lock'))
        this.OptionItem('Both', $r('sys.symbol.plus_square'), () => this.onSelect('both'))
      }
      .width('100%').justifyContent(FlexAlign.Center).margin({ bottom: 40 })

      Button('Cancel')
        .width('85%').height(48).backgroundColor('rgba(255,255,255,0.1)').fontColor('#FFFFFF').borderRadius(24)
        .backgroundBlurStyle(BlurStyle.Thin)
        .border({ width: 0.5, color: 'rgba(255,255,255,0.1)' })
        .margin({ bottom: 32 })
        .onClick(() => { this.onCancel(); this.controller.close(); })
    }
    .width('100%').backgroundColor('rgba(0, 0, 0, 0.25)').backgroundBlurStyle(BlurStyle.Thin).borderRadius({ topLeft: 32, topRight: 32 })
    .border({ width: 0.5, color: 'rgba(255,255,255,0.08)' })
  }

  @Builder
  OptionItem(label: string, icon: Resource, action: () => void) {
    Column() {
      Stack() {
        Circle({ width: 64, height: 64 }).fill('rgba(0,125,255,0.15)')
        SymbolGlyph(icon).fontSize(32).fontColor(['#007DFF'])
      }
      Text(label).fontSize(13).fontWeight(FontWeight.Medium).fontColor('rgba(255,255,255,0.8)').margin({ top: 12 })
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
  @State imageScale: number = 0.92; // 略微增加初始缩放
  @State isDialogActive: boolean = false;
  @StorageProp('statusBarHeight') statusBarHeight: number = 48;
  @StorageProp('bottomBarHeight') bottomBarHeight: number = 28;

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
    .backgroundColor('rgba(255, 255, 255, 0.12)')
    .backgroundBlurStyle(BlurStyle.Thin)
    .borderRadius(16)
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      if (this.wallpaper !== null) {
        // 1. 视差背景层 (层叠加载逻辑)
        Stack() {
          // 缩略图模糊背景 (立即显示)
          Image(this.wallpaper!.thumbUrl)
            .width('100%').height('100%').objectFit(ImageFit.Cover).blur(60).brightness(0.4).scale({ x: 1.2, y: 1.2 }) 
          
          // 原图模糊背景 (加载后覆盖)
          Image(this.wallpaper!.imageUrl)
            .width('100%').height('100%').objectFit(ImageFit.Cover).blur(60).brightness(0.4).scale({ x: 1.2, y: 1.2 })
            .opacity(this.isImageLoaded ? 1 : 0)
            .animation({ duration: 800, curve: Curve.EaseInOut })
        }

        // 2. 核心内容区 (统一画框布局)
        Scroll() {
          Column() {
            // 图片展示区
            Stack() {
              // A. 缩略图占位 (大幅模糊，体现加载中)
              Image(this.wallpaper!.thumbUrl)
                .width('100%')
                .objectFit(ImageFit.Contain)
                .borderRadius(24)
                .blur(20) // 显著提高模糊度
                .opacity(this.isImageLoaded ? 0 : 1)
                .animation({ duration: 400 })

              // B. 显式加载进度条 (仅加载中显示)
              if (!this.isImageLoaded) {
                LoadingProgress()
                  .width(40).height(40)
                  .color('rgba(255,255,255,0.6)')
              }

              // C. 原图展示 (加载后渐现)
              Image(this.wallpaper!.imageUrl)
                .width('100%').objectFit(ImageFit.Contain)
                .borderRadius(24) 
                .shadow({ radius: 50, color: 'rgba(0,0,0,0.45)', offsetY: 25 })
                .scale({ x: this.imageScale, y: this.imageScale })
                .geometryTransition(this.wallpaper!.id)
                .opacity(this.isImageLoaded ? 1 : 0)
                .onComplete(() => { 
                  animateTo({ duration: 600, curve: Curve.EaseInOut }, () => {
                    this.isImageLoaded = true; 
                  })
                })
            }
            .width('92%') // 强制统一 92% 宽度，修复竖图边距消失问题
            .margin({ top: this.statusBarHeight + 72 }) // 状态栏高度 + 操作栏(8+48+16)间距
            
            Column({ space: 24 }) {
              Column({ space: 10 }) {
                Text(this.wallpaper!.resolution || 'Ultra HD')
                  .fontSize(30).fontWeight(FontWeight.Bold).fontColor('#FFFFFF')
                  .shadow({ radius: 8, color: 'rgba(0,0,0,0.4)', offsetY: 2 })
                
                Row({ space: 12 }) {
                  this.InfoCapsule(this.wallpaper!.category || 'General', $r('sys.symbol.square_grid_2x2'))
                  this.InfoCapsule((this.wallpaper!.purity || 'sfw').toUpperCase(), $r('sys.symbol.lock'))
                }
              }
              .alignItems(HorizontalAlign.Start).width('100%').padding({ left: 24, right: 24 })

              if (this.wallpaper!.tags && this.wallpaper!.tags.length > 0) {
                Flex({ wrap: FlexWrap.Wrap, space: { main: LengthMetrics.vp(10), cross: LengthMetrics.vp(10) } }) {
                  ForEach(this.wallpaper!.tags, (t: TagInfo) => {
                    Text(`# ${t.name}`).fontSize(13).fontColor('rgba(255,255,255,0.85)')
                      .padding({ left: 16, right: 16, top: 10, bottom: 10 })
                      .backgroundColor('rgba(255,255,255,0.08)')
                      .borderRadius(20)
                      .onClick(() => router.back({ url: 'pages/Index', params: { searchKeyword: t.name } }))
                  })
                }
                .padding({ left: 24, right: 24 })
              }
              Blank().height(180) // 增加底部预留空间
            }
            .width('100%').margin({ top: 40 }).opacity(this.infoOpacity).translate({ y: this.infoTranslateY })
          }
          .width('100%')
        }
        .scrollBar(BarState.Off).edgeEffect(EdgeEffect.Spring)

        // 3. 顶部操作栏 (悬浮感按钮)
        Row() {
          Button({ type: ButtonType.Circle }) { SymbolGlyph($r('sys.symbol.chevron_left')).fontSize(24).fontColor(['#FFFFFF']) }
          .width(48).height(48).backgroundColor('rgba(255,255,255,0.15)').backgroundBlurStyle(BlurStyle.Thin).onClick(() => router.back())
          .shadow({ radius: 10, color: 'rgba(0,0,0,0.2)', offsetY: 4 })
          
          Blank()
          
          Button({ type: ButtonType.Circle }) { SymbolGlyph(this.isFavorite ? $r('sys.symbol.heart_fill') : $r('sys.symbol.heart')).fontSize(24).fontColor([this.isFavorite ? '#FF5252' : '#FFFFFF']) }
          .width(48).height(48).backgroundColor('rgba(255,255,255,0.15)').backgroundBlurStyle(BlurStyle.Thin).onClick(() => this.toggleFavorite())
          .shadow({ radius: 10, color: 'rgba(0,0,0,0.2)', offsetY: 4 })
        }
        .width('100%').padding({ left: 20, right: 20, top: this.statusBarHeight + 8, bottom: 16 }).zIndex(100)

        // 4. 底部固定的“灵动操作岛”
        Row({ space: 16 }) {
          Button({ type: ButtonType.Capsule }) {
            Row({ space: 8 }) {
              if (this.isSetting) LoadingProgress().width(20).height(20).color('#FFFFFF')
              else SymbolGlyph($r('sys.symbol.picture')).fontSize(20).fontColor(['#FFFFFF'])
              Text(this.isSetting ? 'Applying...' : 'Set Wallpaper').fontSize(16).fontWeight(FontWeight.Bold).fontColor('#FFFFFF')
            }
          }
          .height(58).layoutWeight(1).backgroundColor('#007DFF').shadow({ radius: 25, color: 'rgba(0,125,255,0.45)', offsetY: 10 }).onClick(() => { this.isDialogActive = true; this.dialogController.open(); }).enabled(!this.isSetting)

          Button({ type: ButtonType.Circle }) {
            if (this.isDownloading) LoadingProgress().width(24).height(24).color('#182431')
            else SymbolGlyph($r('sys.symbol.square_and_arrow_down')).fontSize(24).fontColor(['#182431'])
          }
          .width(58).height(58).backgroundColor('#FFFFFF').shadow({ radius: 25, color: 'rgba(0,0,0,0.2)', offsetY: 10 }).onClick(() => this.saveWallpaper()).enabled(!this.isDownloading)
        }
        .width('100%')
        .padding({ left: 24, right: 24, bottom: this.bottomBarHeight + 12 })
        .position({ x: 0, y: '100%' })
        .markAnchor({ x: 0, y: '100%' })
      }
    }
    .width('100%').height('100%').backgroundColor('#000000')
  }

  pageTransition() {
    // 入场：快速切入，350ms 黄金时长
    PageTransitionEnter({ duration: 300, curve: Curve.FastOutSlowIn }).opacity(0)
    // 出场：干脆利落，不拖泥带水
    PageTransitionExit({ duration: 300, curve: Curve.FastOutSlowIn }).opacity(0)
  }
}
