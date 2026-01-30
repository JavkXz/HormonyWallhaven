@Component
struct HomePage {
  @State message: string = 'HarmonyOS壁纸应用';

  build() {
    Column() {
      Text(this.message)
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 40 })

      // 导航到主壁纸页面
      Button('进入壁纸应用')
        .width(250)
        .height(50)
        .fontSize(16)
        .onClick(() => {
          // 在实际应用中，这里会使用路由跳转
          console.info('[HomePage] 导航到壁纸应用');
        })
        .margin({ bottom: 20 })

      // 测试按钮 - 直接在首页测试日志
      Button('快速测试日志输出')
        .width(250)
        .height(50)
        .fontSize(16)
        .backgroundColor('#4caf50')
        .onClick(() => {
          console.info('[HomePage] 快速日志测试开始');
          
          // 测试不同级别的日志
          console.debug('[HomePage] DEBUG - 调试信息');
          console.info('[HomePage] INFO - 一般信息');
          console.warn('[HomePage] WARN - 警告信息');
          console.error('[HomePage] ERROR - 错误信息');
          
          // 测试HTTP请求日志
          this.testHttpRequest();
        })
        .margin({ bottom: 20 })

      Text('查看日志方法:')
        .fontSize(14)
        .fontColor('#666')
        .margin({ top: 40, bottom: 10 })

      Text('1. DevEco Studio → Logcat窗口')
        .fontSize(12)
        .fontColor('#888')
      Text('2. 命令行: hdc shell hilog')
        .fontSize(12)
        .fontColor('#888')
        .margin({ top: 5 })
      Text('3. 过滤标签: hdc shell hilog -T "HTTP"')
        .fontSize(12)
        .fontColor('#888')
        .margin({ top: 5 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .padding(20)
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