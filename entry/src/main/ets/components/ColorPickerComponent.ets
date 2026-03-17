/**
 * Immersive Fluidity 风格的颜色选择器组件
 */
import { ThemeColors, ThemeShadows, AnimationPresets, BorderRadius } from '../common/ThemeConstants';

@Component
export struct ColorPickerComponent {
  // 已选颜色数组
  @Prop selectedColors: string[];
  // 选择器关闭回调
  onClose: (colors: string[]) => void = () => {};
  
  // 28 种预定义颜色 (来自 Wallhaven API)
  private readonly COLORS: string[] = [
    '#000000', '#999999', '#cccccc', '#ffffff',
    '#990000', '#cc0000', '#cc3333', '#ea4c88',
    '#993399', '#663399', '#333399', '#0066cc',
    '#0099cc', '#66cccc', '#77cc33', '#669900',
    '#336600', '#666600', '#999900', '#cccc33',
    '#ffff00', '#ffcc33', '#ff9900', '#ff6600',
    '#cc6633', '#996633', '#663300', '#424153'
  ];
  
  // 本地选中状态
  @State localSelectedColors: string[] = [];
  
  aboutToAppear() {
    this.localSelectedColors = [...this.selectedColors];
  }
  
  build() {
    Column() {
      // 标题
      Text('Color Filter')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor(ThemeColors.textPrimary)
        .margin({ bottom: 20 })
      
      // 颜色网格 (7 列 x4 行)
      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(this.COLORS, (color: string) => {
          this.ColorItem(color)
        }, (color: string) => color)
      }
      .width('100%')
      .margin({ bottom: 24 })
      
      // 底部按钮
      Row({ space: 16 }) {
        // 清除按钮 (透明毛玻璃)
        Button('Clear')
          .layoutWeight(1)
          .height(44)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor(ThemeColors.textPrimary)
          .backgroundColor(ThemeColors.surface)
          .backgroundBlurStyle(BlurStyle.Thin)
          .border({ width: 0.5, color: ThemeColors.border })
          .borderRadius(BorderRadius.capsule / 2)
          .onClick(() => {
            this.localSelectedColors = [];
            this.onClose([]);
          })
        
        // 确认按钮 (主色调，微发光)
        Button('Apply')
          .layoutWeight(1)
          .height(44)
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor(ThemeColors.textPrimary)
          .backgroundColor(ThemeColors.primary)
          .borderRadius(BorderRadius.capsule / 2)
          .shadow(ThemeShadows.primary)
          .onClick(() => {
            this.onClose([...this.localSelectedColors]);
          })
      }
      .width('100%')
    }
    .width('90%')
    .padding({ left: 28, right: 28, top: 24, bottom: 24 })
    .backgroundColor(ThemeColors.surfaceDark)
    .backgroundBlurStyle(BlurStyle.Thin)
    .borderRadius(BorderRadius.xlarge)
    .border({ width: 0.5, color: ThemeColors.border })
    .shadow(ThemeShadows.large)
  }
  
  @Builder
  ColorItem(color: string) {
    Stack({ alignContent: Alignment.Center }) {
      // 内部对勾动画图标
      if (this.localSelectedColors.includes(color)) {
        SymbolGlyph($r('sys.symbol.checkmark'))
          .fontSize(16)
          .fontColor([['#ffffff', '#cccccc', '#ffff00', '#ffcc33'].includes(color) ? '#000000' : ThemeColors.textPrimary])
          .fontWeight(FontWeight.Bold)
          .transition(TransitionEffect.scale({ x: 0, y: 0 }).combine(TransitionEffect.opacity(0)))
      }
    }
    .width(36)
    .height(36)
    .backgroundColor(color)
    .borderRadius(18)
    .border({ 
      width: this.localSelectedColors.includes(color) ? 2 : 0.5,
      color: this.localSelectedColors.includes(color) ? ThemeColors.primary : ThemeColors.borderStrong
    })
    .shadow(this.localSelectedColors.includes(color) ? ThemeShadows.primary : { radius: 0 })
    .margin({ right: 8, bottom: 12 })
    .scale(this.localSelectedColors.includes(color) ? { x: 1.1, y: 1.1 } : { x: 1, y: 1 })
    .animation({ duration: AnimationPresets.standard.duration, curve: AnimationPresets.standard.curve })
    .onClick(() => {
      // 切换选中状态
      const index: number = this.localSelectedColors.indexOf(color);
      if (index > -1) {
        this.localSelectedColors.splice(index, 1);
      } else {
        this.localSelectedColors.push(color);
      }
    })
  }
}
