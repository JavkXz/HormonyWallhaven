import { WallpaperItem } from '../model/WallpaperModel';
import { AppConstants } from '../common/Constants';
import { globalState } from '../common/GlobalState';

/**
 * 现代风格的筛选标签组件
 */
@Component
export struct ModernFilterChip {
  @Prop label: string;
  @Prop isSelected: boolean;
  onClickAction: () => void = () => {};

  build() {
    Row() {
      Text(this.label)
        .fontSize(14)
        .fontWeight(this.isSelected ? FontWeight.Medium : FontWeight.Normal)
        .fontColor(this.isSelected ? '#FFFFFF' : '#666666')
    }
    .padding({ left: 16, right: 16, top: 8, bottom: 8 })
    .backgroundColor(this.isSelected ? '#007DFF' : 'rgba(0,0,0,0.05)')
    .borderRadius(20)
    .margin({ right: 10 })
    .scale(this.isSelected ? { x: 1.05, y: 1.05 } : { x: 1, y: 1 })
    .shadow(this.isSelected ? { radius: 10, color: 'rgba(0,125,255,0.3)', offsetY: 4 } : { radius: 0 })
    .animation({ duration: 300, curve: Curve.FastOutSlowIn })
    .onClick(() => {
      if (this.onClickAction) this.onClickAction();
    })
  }
}

/**
 * 现代风格的壁纸卡片组件
 */
@Component
export struct ModernWallpaperCard {
  @Prop wallpaper: WallpaperItem;
  @State isHover: boolean = false;
  @State isImageLoaded: boolean = false;

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      // 占位背景
      Column()
        .width('100%')
        .aspectRatio(this.wallpaper.aspectRatio || 0.7)
        .backgroundColor('#F1F3F5')
        .borderRadius(20)
        .visibility(this.isImageLoaded ? Visibility.None : Visibility.Visible)

      Image(this.wallpaper.thumbUrl)
        .width('100%')
        .aspectRatio(this.wallpaper.aspectRatio || 0.7)
        .objectFit(ImageFit.Cover)
        .borderRadius(20)
        .opacity(this.isImageLoaded ? 1 : 0)
        .animation({ duration: 500, curve: Curve.EaseInOut })
        .onComplete(() => {
          this.isImageLoaded = true;
        })
        .geometryTransition(this.wallpaper.id)

      // 底部渐变层
      Column()
        .width('100%')
        .height('40%')
        .borderRadius({ bottomLeft: 20, bottomRight: 20 })
        .linearGradient({
          angle: 180,
          colors: [['rgba(0,0,0,0)', 0], ['rgba(0,0,0,0.5)', 1]]
        })
        .hitTestBehavior(HitTestMode.None)

      // 信息层
      Row() {
        Column() {
          Text(this.wallpaper.resolution || 'HD')
            .fontSize(10)
            .fontColor('#FFFFFF')
            .fontWeight(FontWeight.Bold)
            .padding({ left: 6, right: 6, top: 2, bottom: 2 })
            .backgroundColor('rgba(255,255,255,0.2)')
            .borderRadius(4)
            .backgroundBlurStyle(BlurStyle.Thin)
        }
        .alignItems(HorizontalAlign.Start)

        Blank()

        SymbolGlyph($r('sys.symbol.heart_fill'))
          .fontSize(16)
          .fontColor(['#FF5252'])
          .visibility(globalState.isFavorite(this.wallpaper.id) ? Visibility.Visible : Visibility.None)
      }
      .width('100%')
      .padding(12)
    }
    .width('100%')
    .clip(true)
    .shadow({ radius: 15, color: 'rgba(0,0,0,0.08)', offsetY: 8 })
    .transition(TransitionEffect.asymmetric(
      TransitionEffect.OPACITY.combine(TransitionEffect.scale({ x: 0.9, y: 0.9 })),
      TransitionEffect.OPACITY
    ))
  }
}
