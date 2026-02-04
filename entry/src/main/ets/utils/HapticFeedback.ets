import vibrator from '@ohos.vibrator';

/**
 * 触感反馈工具类
 * 封装系统振动效果，用于增强交互体验
 */
export class HapticFeedback {

  /**
   * 成功操作反馈
   * 使用场景：设置壁纸成功、收藏成功等
   */
  static success(): void {
    try {
      vibrator.startVibration({
        type: 'time',
        duration: 100
      }, {
        id: 0,
        usage: 'unknown'
      }, (error) => {
        if (error) {
          console.warn('[HapticFeedback] 振动失败:', error.message);
        }
      });
      console.info('[HapticFeedback] 触发成功反馈');
    } catch (error) {
      console.warn('[HapticFeedback] 振动失败:', error);
    }
  }

  /**
   * 轻微反馈
   * 使用场景：收藏按钮点击、长按菜单等
   */
  static light(): void {
    try {
      vibrator.startVibration({
        type: 'preset',
        effectId: 'haptic.clock.timer'
      }, {
        id: 0,
        usage: 'unknown'
      }, (error) => {
        if (error) {
          console.warn('[HapticFeedback] 振动失败:', error.message);
        }
      });
      console.info('[HapticFeedback] 触发轻微反馈');
    } catch (error) {
      console.warn('[HapticFeedback] 振动失败:', error);
    }
  }

  /**
   * 中等强度反馈
   * 使用场景：删除确认、重要操作等
   */
  static medium(): void {
    try {
      vibrator.startVibration({
        type: 'time',
        duration: 80
      }, {
        id: 0,
        usage: 'unknown'
      }, (error) => {
        if (error) {
          console.warn('[HapticFeedback] 振动失败:', error.message);
        }
      });
      console.info('[HapticFeedback] 触发中等反馈');
    } catch (error) {
      console.warn('[HapticFeedback] 振动失败:', error);
    }
  }

  /**
   * 警示反馈（双次短震）
   * 使用场景：删除确认、危险操作等
   */
  static warning(): void {
    try {
      // 第一次震动
      vibrator.startVibration({
        type: 'time',
        duration: 50
      }, {
        id: 0,
        usage: 'unknown'
      });

      // 延迟50ms后第二次震动
      setTimeout(() => {
        vibrator.startVibration({
          type: 'time',
          duration: 50
        }, {
          id: 0,
          usage: 'unknown'
        });
      }, 50);

      console.info('[HapticFeedback] 触发警示反馈');
    } catch (error) {
      console.warn('[HapticFeedback] 振动失败:', error);
    }
  }

  /**
   * 错误反馈
   * 使用场景：操作失败、网络错误等
   */
  static error(): void {
    try {
      vibrator.startVibration({
        type: 'time',
        duration: 200
      }, {
        id: 0,
        usage: 'unknown'
      }, (error) => {
        if (error) {
          console.warn('[HapticFeedback] 振动失败:', error.message);
        }
      });
      console.info('[HapticFeedback] 触发错误反馈');
    } catch (error) {
      console.warn('[HapticFeedback] 振动失败:', error);
    }
  }
}
