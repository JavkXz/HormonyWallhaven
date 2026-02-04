/**
 * 空状态类型枚举
 */
export enum EmptyStateType {
  NO_NETWORK = 'no_network',      // 断网状态
  NO_RESULT = 'no_result',        // 搜索无结果
  NO_FAVORITES = 'no_favorites',  // 收藏为空
  GENERIC = 'generic'             // 通用空状态
}

/**
 * 空状态配置接口
 */
interface EmptyStateConfig {
  icon: Resource;
  title: string;
  subtitle?: string;
  actionText?: string;
}

/**
 * 空状态配置映射
 */
const EMPTY_STATE_CONFIGS: Record<EmptyStateType, EmptyStateConfig> = {
  [EmptyStateType.NO_NETWORK]: {
    icon: $r('sys.symbol.wifi_slash'),
    title: '网络连接失败',
    subtitle: '请检查网络设置后重试',
    actionText: '重新加载'
  },
  [EmptyStateType.NO_RESULT]: {
    icon: $r('sys.symbol.magnifyingglass'),
    title: '未找到相关壁纸',
    subtitle: '换个关键词试试？',
    actionText: '清除搜索'
  },
  [EmptyStateType.NO_FAVORITES]: {
    icon: $r('sys.symbol.heart_slash'),
    title: '还没有收藏任何壁纸',
    subtitle: '去发现精美壁纸吧~',
    actionText: '去逛逛'
  },
  [EmptyStateType.GENERIC]: {
    icon: $r('sys.symbol.doc'),
    title: '暂无内容',
    subtitle: '这里什么都没有',
    actionText: '刷新'
  }
};

/**
 * 空状态组件
 * 用于展示断网、无结果、空收藏等状态
 */
@Component
export struct EmptyStateComponent {
  @Prop type: EmptyStateType = EmptyStateType.GENERIC;
  @Prop customTitle?: string;
  @Prop customSubtitle?: string;
  @Prop customActionText?: string;
  onAction?: () => void = () => {};

  // 获取配置的方法
  private getTitle(): string {
    const config = EMPTY_STATE_CONFIGS[this.type];
    return this.customTitle || config.title;
  }

  private getSubtitle(): string | undefined {
    const config = EMPTY_STATE_CONFIGS[this.type];
    return this.customSubtitle || config.subtitle;
  }

  private getActionText(): string | undefined {
    const config = EMPTY_STATE_CONFIGS[this.type];
    return this.customActionText || config.actionText;
  }

  private getIcon(): Resource {
    return EMPTY_STATE_CONFIGS[this.type].icon;
  }

  build() {
    Column() {
      // 图标
      SymbolGlyph(this.getIcon())
        .fontSize(80)
        .fontColor(['#CCCCCC'])
        .margin({ bottom: 16 })

      // 标题
      Text(this.getTitle())
        .fontSize(18)
        .fontColor('#333333')
        .fontWeight(FontWeight.Medium)

      // 副标题
      if (this.getSubtitle()) {
        Text(this.getSubtitle())
          .fontSize(14)
          .fontColor('#999999')
          .textAlign(TextAlign.Center)
          .maxLines(2)
          .margin({ top: 8 })
      }

      // 操作按钮
      if (this.getActionText()) {
        Button(this.getActionText(), { type: ButtonType.Capsule })
          .fontSize(14)
          .fontColor('#FFFFFF')
          .backgroundColor('#2262db')
          .height(40)
          .padding({ left: 32, right: 32 })
          .margin({ top: 24 })
          .onClick(() => {
            if (this.onAction) {
              this.onAction();
            }
          })
      }
    }
    .width('100%')
    .height('100%')
    .padding(32)
    .justifyContent(FlexAlign.Center)
  }
}

/**
 * 空状态容器组件
 * 包装子组件，在数据为空时自动显示空状态
 */
@Component
export struct EmptyStateContainer {
  @Prop isEmpty: boolean = false;
  @Prop emptyType: EmptyStateType = EmptyStateType.GENERIC;
  @Prop customTitle?: string;
  @Prop customSubtitle?: string;
  @Prop customActionText?: string;
  onEmptyAction?: () => void = () => {};
  @BuilderParam contentBuilder: () => void;

  build() {
    Column() {
      if (this.isEmpty) {
        EmptyStateComponent({
          type: this.emptyType,
          customTitle: this.customTitle,
          customSubtitle: this.customSubtitle,
          customActionText: this.customActionText,
          onAction: this.onEmptyAction
        })
        .width('100%')
        .height('100%')
      } else {
        this.contentBuilder()
      }
    }
    .width('100%')
    .height('100%')
  }
}
