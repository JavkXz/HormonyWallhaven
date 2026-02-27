@Component
struct HomePage {
  @State message: string = 'HarmonyOS壁纸应用';

  build() {
    Stack() {
      // 统一沉浸式背景
      Image($r('app.media.wallhavenrqgpm7'))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover)
        .blur(100)
        .brightness(0.3)
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])

      Column() {
        Text(this.message)
          .fontSize(28)
          .fontWeight(FontWeight.Bolder)
          .fontColor('#FFFFFF')
          .margin({ bottom: 40 })
          .shadow({ radius: 10, color: 'rgba(0,0,0,0.5)', offsetY: 5 })

        // 导航到主壁纸页面
        Button('Discover Beauty')
          .width(260)
          .height(56)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .backgroundColor('#007DFF')
          .borderRadius(28)
          .shadow({ radius: 20, color: 'rgba(0,125,255,0.4)', offsetY: 8 })
          .onClick(() => {
            router.pushUrl({ url: 'pages/Index' });
            console.info('[HomePage] 导航到壁纸列表页');
          })
          .margin({ bottom: 24 })

        Column({ space: 8 }) {
          Text('Powered by HarmonyOS Next')
            .fontSize(12)
            .fontColor('rgba(255,255,255,0.4)')
          Text('Styled with Immersive Fluidity')
            .fontSize(12)
            .fontColor('rgba(255,255,255,0.3)')
        }
        .margin({ top: 60 })
      }
      .width('100%')
      .padding(20)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#000000')
  }

  async testHttpRequest() {
    try {
      console.info('[HomePage] 开始测试HTTP请求');
      
      // 创建一个简单的HTTP请求来测试日志
      const HttpUtil = await import('../utils/HttpUtil');
      
      // 测试请求（使用一个简单的公开API）
      const response = await HttpUtil.HttpUtil.doGet('https://httpbin.org/get');
      console.info('[HomePage] HTTP请求测试完成');
      
    } catch (error) {
      console.error('[HomePage] HTTP请求测试失败:', error);
    }
  }
}