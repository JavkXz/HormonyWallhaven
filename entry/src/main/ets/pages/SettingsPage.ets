import { router, promptAction } from '@kit.ArkUI';
import { AppConfig } from '../utils/AppConfig';
import { ThemeColors, ThemeShadows, AnimationPresets, BorderRadius, ButtonSizes } from '../common/ThemeConstants';

/**
 * 设置页面 - 深色沉浸主题
 * 统一采用 Immersive Fluidity 设计语言
 */
@Entry
@Component
struct SettingsPage {
  @State apiKey: string = '';
  @StorageProp('statusBarHeight') statusBarHeight: number = 48;

  aboutToAppear() {
    this.apiKey = AppConfig.getInstance().getApiKey() || '';
  }

  build() {
    Stack() {
      // 1. 底层沉浸式模糊背景
      Image($r('app.media.wallhavenrqgpm7'))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover)
        .blur(80)
        .saturate(1.8)
        .brightness(0.5)
        .scale({ x: 1.2, y: 1.2 })

      Column() {
        // 2. 标题栏 - 毛玻璃深色风格
        Row() {
          Button({ type: ButtonType.Circle }) {
            SymbolGlyph($r('sys.symbol.chevron_left'))
              .fontSize(22)
              .fontColor([ThemeColors.textPrimary])
          }
          .width(ButtonSizes.circle.medium.width)
          .height(ButtonSizes.circle.medium.height)
          .backgroundColor(ThemeColors.surfaceLight)
          .backgroundBlurStyle(BlurStyle.Thin)
          .shadow(ThemeShadows.medium)
          .onClick(() => router.back())

          Text('设置')
            .fontSize(20)
            .fontColor(ThemeColors.textPrimary)
            .fontWeight(FontWeight.Bold)
            .layoutWeight(1)
            .textAlign(TextAlign.Center)
            .margin({ right: 40 })
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: this.statusBarHeight + 8, bottom: 12 })
        .backgroundColor('rgba(30,30,30,0.6)')
        .backgroundBlurStyle(BlurStyle.Thin)

        // 3. 设置内容区
        Scroll() {
          Column() {
            // API 密钥设置卡片
            this.ApiKeySection()

            // 关于卡片
            this.AboutSection()
          }
          .width('100%')
          .padding({ left: 20, right: 20, top: 20, bottom: 40 })
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor(ThemeColors.background)
  }

  // ═══════════════════════════════════════════════════════════
  // API 密钥设置区域
  // ═══════════════════════════════════════════════════════════
  @Builder
  ApiKeySection() {
    Column() {
      // 标题
      Row() {
        SymbolGlyph($r('sys.symbol.key'))
          .fontSize(18)
          .fontColor([ThemeColors.primary])
          .margin({ right: 8 })
        Text('Wallhaven API')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(ThemeColors.textPrimary)
      }
      .width('100%')
      .margin({ bottom: 16 })

      // 说明文字
      Text('请输入您的 Wallhaven API 密钥以解锁更多功能')
        .fontSize(13)
        .fontColor(ThemeColors.textSecondary)
        .width('100%')
        .margin({ bottom: 16 })

      // 输入框 - 毛玻璃风格
      TextInput({
        text: this.apiKey,
        placeholder: '请输入 API 密钥'
      })
        .height(52)
        .fontSize(15)
        .fontColor(ThemeColors.textPrimary)
        .placeholderColor(ThemeColors.textTertiary)
        .backgroundColor(ThemeColors.surface)
        .backgroundBlurStyle(BlurStyle.Thin)
        .borderRadius(BorderRadius.large)
        .border({ width: 0.5, color: ThemeColors.border })
        .padding({ left: 20, right: 20 })
        .onChange((value: string) => { this.apiKey = value; })
        .margin({ bottom: 20 })

      // 保存按钮 - 胶囊悬浮风格
      Button('保存 API 密钥')
        .width('100%')
        .height(ButtonSizes.capsule.large)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor(ThemeColors.textPrimary)
        .backgroundColor(ThemeColors.primary)
        .borderRadius(BorderRadius.capsule)
        .shadow(ThemeShadows.primary)
        .onClick(() => this.saveApiKey())
    }
    .width('100%')
    .padding(20)
    .backgroundColor(ThemeColors.surfaceDark)
    .backgroundBlurStyle(BlurStyle.Thin)
    .borderRadius(BorderRadius.xlarge)
    .border({ width: 0.5, color: ThemeColors.borderLight })
  }

  // ═══════════════════════════════════════════════════════════
  // 关于区域
  // ═══════════════════════════════════════════════════════════
  @Builder
  AboutSection() {
    Column() {
      // 标题
      Row() {
        SymbolGlyph($r('sys.symbol.info_circle'))
          .fontSize(18)
          .fontColor([ThemeColors.primary])
          .margin({ right: 8 })
        Text('关于')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(ThemeColors.textPrimary)
      }
      .width('100%')
      .margin({ bottom: 16 })

      // 版本信息
      this.InfoRow('版本', '1.0.0')
      this.InfoRow('构建', '2026.02.28')
      this.InfoRow('技术支持', 'HarmonyOS Next')

      // 版权信息
      Text('Powered by HarmonyOS Next')
        .fontSize(12)
        .fontColor(ThemeColors.textTertiary)
        .margin({ top: 20 })
      Text('Designed with Immersive Fluidity')
        .fontSize(12)
        .fontColor(ThemeColors.textTertiary)
        .margin({ top: 4 })
    }
    .width('100%')
    .padding(20)
    .marginTop(16)
    .backgroundColor(ThemeColors.surfaceDark)
    .backgroundBlurStyle(BlurStyle.Thin)
    .borderRadius(BorderRadius.xlarge)
    .border({ width: 0.5, color: ThemeColors.borderLight })
  }

  // ═══════════════════════════════════════════════════════════
  // 信息行组件
  // ═══════════════════════════════════════════════════════════
  @Builder
  InfoRow(label: string, value: string) {
    Row() {
      Text(label)
        .fontSize(14)
        .fontColor(ThemeColors.textSecondary)
        .width(80)
      Text(value)
        .fontSize(14)
        .fontColor(ThemeColors.textPrimary)
        .layoutWeight(1)
        .textAlign(TextAlign.End)
    }
    .width('100%')
    .padding({ top: 10, bottom: 10 })
  }

  // ═══════════════════════════════════════════════════════════
  // 保存 API 密钥
  // ═══════════════════════════════════════════════════════════
  saveApiKey() {
    if (!this.apiKey.trim()) {
      promptAction.showToast({ message: '请输入 API 密钥' });
      return;
    }
    AppConfig.getInstance().setApiKey(this.apiKey.trim());
    promptAction.showToast({ message: 'API 密钥已保存' });
    HapticFeedback.success();
  }

  // 页面转场配置
  pageTransition() {
    PageTransitionEnter(AnimationPresets.enter).opacity(0)
    PageTransitionExit(AnimationPresets.exit).opacity(0)
  }
}