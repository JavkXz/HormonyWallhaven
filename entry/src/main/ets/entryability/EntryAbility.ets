import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';

const DOMAIN = 0x0000;

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    try {
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    } catch (err) {
      hilog.error(DOMAIN, 'testTag', 'Failed to set colorMode. Cause: %{public}s', JSON.stringify(err));
    }
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onCreate');
  }

  onDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  async onWindowStageCreate(windowStage: window.WindowStage): Promise<void> {
    // Main window is created, set main page for this ability
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    try {
      // 获取主窗口
      const mainWindow: window.Window = await windowStage.getMainWindow();
      // 启用边缘到边缘布局（全屏布局模式）
      await mainWindow.setWindowLayoutFullScreen(true);

      // 集中获取安全区域高度，写入 AppStorage 全局共享
      // 避免各页面重复获取，确保多设备多分辨率下动态适配
      const sysArea = mainWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
      const navArea = mainWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR);
      AppStorage.setOrCreate('statusBarHeight', px2vp(sysArea.topRect.height));
      AppStorage.setOrCreate('bottomBarHeight', px2vp(navArea.bottomRect.height));
      hilog.info(DOMAIN, 'testTag', 'SafeArea initialized: statusBar=%{public}d, bottomBar=%{public}d',
        px2vp(sysArea.topRect.height), px2vp(navArea.bottomRect.height));
      // 定义系统栏属性对象
      const systemBarProperties: window.SystemBarProperties = {
        statusBarColor: '#00000000', // 透明
        statusBarContentColor: '#FFFFFF', // 白色文字
        navigationBarColor: '#00000000', // 透明
        navigationBarContentColor: '#FFFFFF' // 白色文字
      };
      await mainWindow.setWindowSystemBarProperties(systemBarProperties);
      
      // 全屏布局模式下不需要启用系统栏（已透明）
      hilog.info(DOMAIN, 'testTag', 'Edge-to-Edge layout enabled successfully');
    } catch (err) {
      hilog.error(DOMAIN, 'testTag', 'Failed to set edge-to-edge layout. Cause: %{public}s', JSON.stringify(err));
    }

    windowStage.loadContent('pages/Index', (err: BusinessError) => {
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onBackground');
  }
}