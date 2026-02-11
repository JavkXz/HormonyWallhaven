import { WallpaperItem } from '../model/WallpaperModel';
import { AppConstants } from '../common/Constants';
import { globalState } from '../common/GlobalState';

/**
 * 现代风格的筛选标签组件 - 更加灵动
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
        .fontWeight(this.isSelected ? FontWeight.Bold : FontWeight.Medium)
        .fontColor(this.isSelected ? '#FFFFFF' : '#182431')
    }
    .padding({ left: 20, right: 20, top: 10, bottom: 10 })
    .backgroundColor(this.isSelected ? '#007DFF' : 'rgba(0,0,0,0.03)')
    .borderRadius(24)
    .margin({ right: 12 })
    .scale(this.isSelected ? { x: 1.02, y: 1.02 } : { x: 1, y: 1 })
    .shadow(this.isSelected ? { radius: 15, color: 'rgba(0,125,255,0.25)', offsetY: 6 } : { radius: 0 })
    .animation({ duration: 300, curve: Curve.Friction })
    .onClick(() => {
      if (this.onClickAction) this.onClickAction();
    })
  }
}

/**
 * 彻底重构的现代壁纸卡片组件
 * 修复了顶部阴影问题，提升了沉浸感
 */
@Component
export struct ModernWallpaperCard {
  @Prop wallpaper: WallpaperItem;
  @State isImageLoaded: boolean = false;

  build() {
    Column() {
      Stack({ alignContent: Alignment.TopEnd }) {
        // 1. 底层：动态骨架屏占位
        if (!this.isImageLoaded) {
          Column()
            .width('100%')
            .height('100%')
            .backgroundColor('#F1F3F5')
            .linearGradient({
              angle: 90,
              colors: [['#F1F3F5', 0], ['#E5E8EA', 0.5], ['#F1F3F5', 1]]
            })
            .borderRadius(20)
        }

        // 2. 中层：壁纸图片 (强制铺满)
        Image(this.wallpaper.thumbUrl)
          .width('100%')
          .height('100%')
          .objectFit(ImageFit.Cover)
          .borderRadius(20)
          .opacity(this.isImageLoaded ? 1 : 0)
          .animation({ duration: 400, curve: Curve.Sharp })
          .onComplete(() => {
            this.isImageLoaded = true;
          })
          .geometryTransition(this.wallpaper.id)

        // 3. 上层：顶部的收藏状态 (轻量化)
        if (globalState.isFavorite(this.wallpaper.id)) {
          Stack() {
            Circle({ width: 32, height: 32 })
              .fill('rgba(255, 255, 255, 0.85)')
              .backdropBlur(10)
            
            SymbolGlyph($r('sys.symbol.heart_fill'))
              .fontSize(16)
              .fontColor(['#FF5252'])
          }
          .margin({ top: 10, right: 10 })
        }

        // 4. 下层：信息浮层 (玻璃拟态增强)
        Column() {
          Blank()
          Row() {
            Text(this.wallpaper.resolution || 'HD')
              .fontSize(11)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
              .padding({ left: 8, right: 8, top: 4, bottom: 4 })
              .backgroundColor('rgba(0,0,0,0.3)')
              .backgroundBlurStyle(BlurStyle.Thin)
              .borderRadius(8)
          }
          .width('100%')
          .padding(12)
        }
        .width('100%')
        .height('100%')
        .borderRadius(20)
        .linearGradient({
          angle: 180,
          colors: [['rgba(0,0,0,0)', 0.6], ['rgba(0,0,0,0.4)', 1]]
        })
      }
      .width('100%')
      .aspectRatio(this.wallpaper.aspectRatio || 0.7) // 关键：将比例应用在 Stack 容器上
    }
    .width('100%')
    .borderRadius(20)
    .shadow({ radius: 20, color: 'rgba(0,0,0,0.12)', offsetY: 10 })
    .transition(TransitionEffect.OPACITY.combine(TransitionEffect.scale({ x: 0.95, y: 0.95 })))
  }
}
