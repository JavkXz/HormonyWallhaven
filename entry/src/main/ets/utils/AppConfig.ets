import { WallhavenService } from '../service/WallhavenService';

/**
 * 应用配置管理器
 */
export class AppConfig {
  private static instance: AppConfig;
  private wallhavenService: WallhavenService;

  private constructor() {
    // 初始化Wallhaven服务，可以使用默认的API密钥或从配置中获取
    const apiKey = this.getApiKey();
    this.wallhavenService = new WallhavenService(apiKey);
  }

  public static getInstance(): AppConfig {
    if (!AppConfig.instance) {
      AppConfig.instance = new AppConfig();
    }
    return AppConfig.instance;
  }

  /**
   * 获取Wallhaven服务实例
   */
  public getWallhavenService(): WallhavenService {
    return this.wallhavenService;
  }

  /**
   * 设置API密钥
   */
  public setApiKey(apiKey: string) {
    // 在实际应用中，这里会保存到安全的存储中
    // 例如使用@kit.MiscKit中的Preferences API
    this.wallhavenService = new WallhavenService(apiKey);
  }

  /**
   * 获取API密钥
   * 在实际应用中，这里会从安全的存储中读取
   */
  private getApiKey(): string | undefined {
    // 示例：返回一个硬编码的API密钥或undefined
    // 在实际应用中，应从安全存储中获取
    return undefined; // 暂时返回undefined，让应用使用无API密钥模式
  }
}