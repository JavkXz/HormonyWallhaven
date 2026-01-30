import { AppConfig } from '../utils/AppConfig';

@Entry
@Component
struct SettingsPage {
  @State apiKey: string = '';
  @State message: string = '设置';
  
  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Text(this.message)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .backgroundColor('#ffffff')

        // 返回按钮
        Button('返回')
          .fontSize(16)
          .fontColor('#007DFF')
          .type(ButtonType.Capsule)
          .backgroundColor(Color.Transparent)
          .onClick(() => {
            // 在实际应用中，这里会导航回主页
            console.info('返回主页面');
          })
      }
      .width('100%')
      .height(50)
      .padding({ left: 16, right: 16 })
      .alignItems(VerticalAlign.Center)
      .backgroundColor('#ffffff')

      // API密钥设置区域
      Column() {
        Text('Wallhaven API密钥设置')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .margin({ top: 20, bottom: 10 })
          .alignSelf(ItemAlign.Start)

        TextInput({
          controller: undefined
        })
        .placeholder('请输入您的Wallhaven API密钥')
        .text(this.apiKey)
        .onChange((value: string) => {
          this.apiKey = value;
        })
        .height(40)
        .width('90%')
        .border({
          width: 1,
          color: '#CCCCCC'
        })
        .borderRadius(8)
        .margin({ bottom: 20 })

        Button('保存')
          .width('90%')
          .height(40)
          .backgroundColor('#007DFF')
          .fontColor('#FFFFFF')
          .borderRadius(8)
          .fontSize(16)
          .onClick(() => {
            // 保存API密钥到配置
            AppConfig.getInstance().setApiKey(this.apiKey);
            console.info('API密钥已保存');
          })
      }
      .width('100%')
      .padding({ top: 20 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f0f0f0')
  }
}