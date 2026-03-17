import { WallpaperItem } from '../model/WallpaperModel';
import { AppConstants, SelectOption } from '../common/Constants';
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
        .fontSize(12)
        .fontWeight(this.isSelected ? FontWeight.Bold : FontWeight.Medium)
        .fontColor(this.isSelected ? '#FFFFFF' : 'rgba(255,255,255,0.8)')
    }
    .padding({ left: 12, right: 12, top: 6, bottom: 6 })
    .backgroundColor('rgba(0,0,0,0.4)')
    .backgroundBlurStyle(BlurStyle.Thin)
    .borderRadius(24)
    .margin({ right: 8 })
    .border({
      width: 0.5,
      color: this.isSelected ? '#007DFF' : 'rgba(255,255,255,0.1)'
    })
    .scale(this.isSelected ? { x: 1.02, y: 1.02 } : { x: 1, y: 1 })
    .shadow(this.isSelected ? { radius: 15, color: 'rgba(0,125,255,0.3)', offsetY: 4 } : { radius: 0 })
    .animation({ duration: 350, curve: Curve.FastOutSlowIn })
    .onClick(() => {
      if (this.onClickAction) this.onClickAction();
    })
  }
}

/**
 * 现代下拉筛选标签组件 - 用于多选项切换
 */
@Component
export struct ModernDropdownChip {
  @Prop label: string;
  @Prop valueLabel: string;
  options: SelectOption[] = [];
  onSelect: (value: string) => void = () => {};

  build() {
    Row() {
      Text(this.label + ': ')
        .fontSize(12)
        .fontWeight(FontWeight.Medium)
        .fontColor('rgba(255,255,255,0.6)')
      
      Text(this.valueLabel)
        .fontSize(12)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
      
      SymbolGlyph($r('sys.symbol.chevron_down'))
        .fontSize(10)
        .fontColor(['rgba(255,255,255,0.6)'])
        .margin({ left: 4 })
    }
    .padding({ left: 14, right: 14, top: 8, bottom: 8 })
    .backgroundColor('rgba(255,255,255,0.12)')
    .backgroundBlurStyle(BlurStyle.Thin)
    .borderRadius(24)
    .margin({ right: 10, bottom: 8 })
    .border({
      width: 0.5,
      color: 'rgba(255,255,255,0.1)'
    })
    .bindMenu(this.MenuBuilder())
    .animation({ duration: 350, curve: Curve.FastOutSlowIn })
  }

  @Builder
  MenuBuilder() {
    Menu() {
      ForEach(this.options, (option: SelectOption) => {
        MenuItem({ content: option.label as string })
          .onClick(() => {
            this.onSelect(option.value);
          })
      })
    }
  }
}

/**
 * 现代点击操作标签组件 - 用于点击触发弹窗等操作
 */
@Component
export struct ModernActionChip {
  @Prop label: string;
  @Prop valueLabel: string;
  onClickAction: () => void = () => {};

  build() {
    Row() {
      Text(this.label + ': ')
        .fontSize(12)
        .fontWeight(FontWeight.Medium)
        .fontColor('rgba(255,255,255,0.6)')
      
      Text(this.valueLabel)
        .fontSize(12)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
      
      SymbolGlyph($r('sys.symbol.chevron_down'))
        .fontSize(10)
        .fontColor(['rgba(255,255,255,0.6)'])
        .margin({ left: 4 })
    }
    .padding({ left: 14, right: 14, top: 8, bottom: 8 })
    .backgroundColor('rgba(255,255,255,0.12)')
    .backgroundBlurStyle(BlurStyle.Thin)
    .borderRadius(24)
    .margin({ right: 10, bottom: 8 })
    .border({
      width: 0.5,
      color: 'rgba(255,255,255,0.1)'
    })
    .animation({ duration: 350, curve: Curve.FastOutSlowIn })
    .onClick(() => {
      this.onClickAction();
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
      Stack({ alignContent: Alignment.Bottom }) {
        // 底层：骨架屏 (同样带圆角和边距)
        if (!this.isImageLoaded) {
          Column()
            .width('100%')
            .height('100%')
            .backgroundColor('rgba(255,255,255,0.05)')
            .borderRadius(20)
        }

        // 中层：壁纸图片
        Image(this.wallpaper.thumbUrl)
          .width('100%')
          .height('100%')
          .objectFit(ImageFit.Cover)
          .borderRadius(20)
          .opacity(this.isImageLoaded ? 1 : 0)
          .shadow({ radius: 20, color: 'rgba(0,0,0,0.3)', offsetY: 10 })
          .animation({ duration: 400, curve: Curve.Sharp })
          .onComplete(() => {
            this.isImageLoaded = true;
          })
          .geometryTransition(this.wallpaper.id)

        // 上层：右下角分辨率胶囊徽章（极简水印风格，不遮挡壁纸）
        if (this.isImageLoaded && this.wallpaper.resolution) {
          Text(AppConstants.simplifyResolution(this.wallpaper.resolution))
            .fontSize(8)
            .fontWeight(FontWeight.Medium)
            .fontColor('rgba(255,255,255,0.9)')
            .padding({ left: 5, right: 5, top: 2, bottom: 2 })
            .backgroundColor('rgba(0,0,0,0.35)')
            .backgroundBlurStyle(BlurStyle.Thin)
            .borderRadius(8)
            .border({ width: 0.5, color: 'rgba(255,255,255,0.1)' })
            .position({ x: '100%', y: '100%' })
            .markAnchor({ x: '100%', y: '100%' })
            .margin({ bottom: 20, right: 20 })
        }

        // 上层：右上角收藏徽章
        if (globalState.isFavorite(this.wallpaper.id)) {
          Row() {
            SymbolGlyph($r('sys.symbol.heart_fill'))
              .fontSize(12)
              .fontColor(['#FF5252'])
          }
          .padding(6)
          .position({ x: '100%', y: 0 })
          .markAnchor({ x: '100%', y: 0 })
          .margin({ top: 12, right: 12 })
          .backgroundColor('rgba(0, 0, 0, 0.4)')
          .backgroundBlurStyle(BlurStyle.Thin)
          .borderRadius(12)
          .border({ width: 0.5, color: 'rgba(255,255,255,0.1)' })
        }
      }
      .width('100%')
      .aspectRatio(this.wallpaper.aspectRatio || 0.7)
      .padding(4)
    }
    .width('100%')
    .backgroundColor('transparent')
  }
}
