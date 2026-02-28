/**
 * Immersive Fluidity 风格的颜色选择器组件
 * 严格遵循现有设计规范：
 * - backgroundBlurStyle(BlurStyle.Thin)
 * - borderRadius: 24
 * - 动画曲线：Curve.FastOutSlowIn (350ms)
 * - 选中边框：#007DFF
 */
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
    // 使用 Stack 作为根容器，确保正确显示
    Stack() {
      Column() {
        // 标题
        Text('Color Filter')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
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
          // 清除按钮
          Button('Clear')
            .layoutWeight(1)
            .height(44)
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .backgroundColor('rgba(255,255,255,0.1)')
            .fontColor('#FFFFFF')
            .borderRadius(22)
            .onClick(() => {
              this.localSelectedColors = [];
              this.onClose([]);
            })
          
          // 确认按钮
          Button('Apply')
            .layoutWeight(1)
            .height(44)
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
            .backgroundColor('#007DFF')
            .fontColor('#FFFFFF')
            .borderRadius(22)
            .shadow({ radius: 10, color: 'rgba(0,125,255,0.4)', offsetY: 4 })
            .onClick(() => {
              this.onClose([...this.localSelectedColors]);
            })
        }
        .width('100%')
      }
      .width('100%')
      .padding({ left: 28, right: 28, top: 24, bottom: 24 })
    }
    .width('90%')
    .height('auto')
    .backgroundColor('#1a1a1a')
    .borderRadius(24)
    .border({ width: 1, color: 'rgba(255,255,255,0.1)' })
    .shadow({ radius: 40, color: 'rgba(0,0,0,0.6)', offsetY: 20 })
  }
  
  @Builder
  ColorItem(color: string) {
    Circle()
      .width(36)
      .height(36)
      .fill(color)
      .stroke(this.localSelectedColors.includes(color) ? '#007DFF' : 'rgba(255,255,255,0.3)')
      .strokeWidth(this.localSelectedColors.includes(color) ? 3 : 1)
      .shadow(this.localSelectedColors.includes(color) ? { radius: 15, color: 'rgba(0,125,255,0.4)', offsetY: 4 } : { radius: 0 })
      .animation({ duration: 350, curve: Curve.FastOutSlowIn })
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
    .margin({ right: 8, bottom: 8 })
  }
}
