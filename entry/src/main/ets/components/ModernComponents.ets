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
        .fontSize(13)
        .fontWeight(this.isSelected ? FontWeight.Bold : FontWeight.Medium)
        .fontColor(this.isSelected ? '#FFFFFF' : '#666666')
    }
    .padding({ left: 16, right: 16, top: 8, bottom: 8 })
    .backgroundColor(this.isSelected ? '#007DFF' : 'rgba(0,0,0,0.05)')
    .borderRadius(20)
    .margin({ right: 10 })
    .scale(this.isSelected ? { x: 1.05, y: 1.05 } : { x: 1, y: 1 })
    .shadow(this.isSelected ? { radius: 10, color: 'rgba(0,125,255,0.2)', offsetY: 4 } : { radius: 0 })
    .animation({ duration: 250, curve: Curve.EaseInOut })
    .onClick(() => {
      if (this.onClickAction) this.onClickAction();
    })
  }
}

/**
 * 彻底重构的现代壁纸卡片组件
 * 采用悬浮图片布局，增加精致感与视觉层次
 */
@Component
export struct ModernWallpaperCard {
  @Prop wallpaper: WallpaperItem;
  @State isImageLoaded: boolean = false;

  build() {
    Column() {
      // 1. 图片容器区域 (增加内边距以产生悬浮感)
      Stack({ alignContent: Alignment.TopEnd }) {
        // 底层：骨架屏 (同样带圆角和边距)
        if (!this.isImageLoaded) {
          Column()
            .width('100%')
            .height('100%')
            .backgroundColor('#F1F3F5')
            .borderRadius(10)
        }

        // 中层：壁纸图片 (全圆角，四周留空)
        Image(this.wallpaper.thumbUrl)
          .width('100%')
          .height('100%')
          .objectFit(ImageFit.Cover)
          .borderRadius(10) // 减小图片圆角弧度
          .opacity(this.isImageLoaded ? 1 : 0)
          .shadow({ radius: 15, color: 'rgba(0,0,0,0.15)', offsetY: 8 }) // 图片独立投影
          .animation({ duration: 400, curve: Curve.Sharp })
          .onComplete(() => {
            this.isImageLoaded = true;
          })
          .geometryTransition(this.wallpaper.id)

        // 上层：精美的收藏徽章
        if (globalState.isFavorite(this.wallpaper.id)) {
          Row() {
            SymbolGlyph($r('sys.symbol.heart_fill'))
              .fontSize(10) // 缩小图标
              .fontColor(['#FF5252'])
          }
          .padding(5)
          .margin({ top: 12, right: 12 })
          .backgroundColor('rgba(255, 255, 255, 0.95)')
          .backgroundBlurStyle(BlurStyle.Thin)
          .borderRadius(10)
          .shadow({ radius: 6, color: 'rgba(0,0,0,0.1)', offsetY: 3 })
        }
      }
      .width('100%')
      .aspectRatio(this.wallpaper.aspectRatio || 0.7)
      .padding({ left: 8, right: 8, top: 8 }) // 缩小图片与卡片边缘的间隙

      // 2. 下层：信息区域
      Column() {
        Text(this.wallpaper.resolution || 'Ultra HD Wallpaper')
          .fontSize(12)
          .fontWeight(FontWeight.Bold)
          .fontColor('#182431')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')

        Row() {
          Text(this.wallpaper.category || 'General')
            .fontSize(10)
            .fontColor('#888888')
            .backgroundColor('#F5F5F7')
            .padding({ left: 6, right: 6, top: 2, bottom: 2 })
            .borderRadius(4)
          
          Blank()
          
          Text((this.wallpaper.purity || 'sfw').toUpperCase())
            .fontSize(9)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.wallpaper.purity === 'sketchy' ? '#E64A19' : '#007DFF')
            .opacity(0.8)
        }
        .width('100%')
        .margin({ top: 8 }) // 微调间距
      }
      .padding({ left: 12, right: 12, top: 10, bottom: 12 }) // 微调内边距
    }
    .width('100%')
    .borderRadius(20)
    .backgroundColor('#FFFFFF')
    .clip(true) // 关键：开启剪裁，确保子组件不遮挡底部圆角
    .shadow({ radius: 24, color: 'rgba(0,0,0,0.12)', offsetY: 12 })
    .transition(TransitionEffect.OPACITY.combine(TransitionEffect.scale({ x: 0.98, y: 0.98 })))
  }
}
