// 提前导入服务
import { WallhavenService } from '../service/WallhavenService';

@Entry
@Component
struct TestLogPage {
  @State message: string = '日志测试页面';
  
  private wallhavenService: WallhavenService = new WallhavenService();

  aboutToAppear() {
    console.info('[TestLogPage] 页面已加载');
    this.testHttpLogs();
  }

  async testHttpLogs() {
    console.info('[TestLogPage] 开始测试HTTP日志功能');
    
    try {
      // 测试1: 简单的HTTP请求
      console.info('[TestLogPage] 测试1: 搜索壁纸');
      const wallpapers = await this.wallhavenService.searchWallpapers({
        purity: '100',
        sorting: 'date_added',
        page: 1
      });
      
      console.info(`[TestLogPage] 搜索完成，找到 ${wallpapers.length} 张壁纸`);
      
      // 测试2: 获取单张壁纸详情
      if (wallpapers.length > 0) {
        console.info(`[TestLogPage] 测试2: 获取壁纸详情 ${wallpapers[0].id}`);
        const detail = await this.wallhavenService.getWallpaperById(wallpapers[0].id);
        console.info(`[TestLogPage] 详情获取完成: ${detail ? '成功' : '失败'}`);
      }
      
    } catch (error) {
      console.error('[TestLogPage] 测试过程中发生错误:', error);
    }
  }

  build() {
    Column() {
      Text(this.message)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 20 })

      Button('手动测试日志')
        .width(200)
        .height(40)
        .onClick(() => {
          console.info('[TestLogPage] 手动触发日志测试');
          this.testHttpLogs();
        })

      Button('测试不同日志级别')
        .width(200)
        .height(40)
        .margin({ top: 10 })
        .onClick(() => {
          console.debug('[TestLogPage] 这是DEBUG级别日志');
          console.info('[TestLogPage] 这是INFO级别日志');
          console.warn('[TestLogPage] 这是WARN级别日志');
          console.error('[TestLogPage] 这是ERROR级别日志');
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
}