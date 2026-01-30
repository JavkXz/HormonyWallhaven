import { http } from '@kit.NetworkKit';

/**
 * HTTP请求工具类
 */
export class HttpUtil {
  private static httpRequest: http.HttpRequest = http.createHttp();

  /**
   * 打印HTTP请求日志
   * @param method 请求方法
   * @param url 请求URL
   * @param options 请求选项
   */
  private static logRequest(method: string, url: string, options?: http.HttpRequestOptions): void {
    console.info(`[HTTP Request] ${method} ${url}`);
    if (options) {
      console.info(`[HTTP Headers] ${JSON.stringify(options.header || {})}`);
      if (options.connectTimeout) {
        console.info(`[HTTP Timeout] Connect: ${options.connectTimeout}ms, Read: ${options.readTimeout || 'default'}ms`);
      }
    }
    console.info(`[HTTP Request Start] ${new Date().toISOString()}`);
  }

  /**
   * 打印HTTP响应日志
   * @param method 请求方法
   * @param url 请求URL
   * @param responseCode 响应状态码
   * @param responseSize 响应数据大小
   * @param duration 请求耗时
   */
  private static logResponse(method: string, url: string, responseCode: number, responseSize: number, duration: number): void {
    console.info(`[HTTP Response] ${method} ${url} -> Status: ${responseCode}, Size: ${responseSize} bytes, Duration: ${duration}ms`);
    console.info(`[HTTP Request End] ${new Date().toISOString()}`);
  }

  /**
   * 打印HTTP错误日志
   * @param method 请求方法
   * @param url 请求URL
   * @param error 错误信息
   * @param duration 请求耗时
   */
  private static logError(method: string, url: string, error: Error, duration: number): void {
    console.error(`[HTTP Error] ${method} ${url} -> Error: ${error.message}, Duration: ${duration}ms`);
    console.error(`[HTTP Request Failed] ${new Date().toISOString()}`);
  }

  /**
   * GET请求
   * @param url 请求地址
   * @param options 请求选项
   */
  static async doGet(url: string, options?: http.HttpRequestOptions): Promise<string> {
    const startTime = Date.now();
    const method = 'GET';
    
    // 记录请求开始日志
    HttpUtil.logRequest(method, url, options);
    
    return new Promise((resolve, reject) => {
      const requestOptions: http.HttpRequestOptions = {
        method: http.RequestMethod.GET
      };
      
      // 合并选项（不使用Object.assign）
      if (options) {
        if (options.header) requestOptions.header = options.header;
        if (options.connectTimeout) requestOptions.connectTimeout = options.connectTimeout;
        if (options.readTimeout) requestOptions.readTimeout = options.readTimeout;
      }
      
      HttpUtil.httpRequest.request(url, requestOptions, (err: Error, data: http.HttpResponse) => {
        const duration = Date.now() - startTime;
        
        if (err) {
          // 记录错误日志
          HttpUtil.logError(method, url, err, duration);
          reject(err);
        } else {
          // 记录响应日志
          const responseSize = typeof data.result === 'string' ? data.result.length : 0;
          HttpUtil.logResponse(method, url, data.responseCode, responseSize, duration);
          
          // 记录响应数据摘要（避免打印过大的响应体）
          if (typeof data.result === 'string') {
            const responsePreview = data.result.length > 200 ? 
              data.result.substring(0, 200) + '...' : data.result;
            console.info(`[HTTP Response Data Preview] ${responsePreview}`);
          }
          
          resolve(data.result as string);
        }
      });
    });
  }

  /**
   * POST请求
   * @param url 请求地址
   * @param data 请求体数据
   * @param options 请求选项
   */
  static async doPost(url: string, data: string, options?: http.HttpRequestOptions): Promise<string> {
    const startTime = Date.now();
    const method = 'POST';
    
    // 记录请求开始日志
    HttpUtil.logRequest(method, url, options);
    console.info(`[HTTP Request Body Size] ${data.length} bytes`);
    
    return new Promise((resolve, reject) => {
      const requestOptions: http.HttpRequestOptions = {
        method: http.RequestMethod.POST,
        extraData: data
      };
      
      // 合并选项（不使用Object.assign）
      if (options) {
        if (options.header) requestOptions.header = options.header;
        if (options.connectTimeout) requestOptions.connectTimeout = options.connectTimeout;
        if (options.readTimeout) requestOptions.readTimeout = options.readTimeout;
      }
      
      HttpUtil.httpRequest.request(url, requestOptions, (err: Error, data: http.HttpResponse) => {
        const duration = Date.now() - startTime;
        
        if (err) {
          // 记录错误日志
          HttpUtil.logError(method, url, err, duration);
          reject(err);
        } else {
          // 记录响应日志
          const responseSize = typeof data.result === 'string' ? data.result.length : 0;
          HttpUtil.logResponse(method, url, data.responseCode, responseSize, duration);
          
          // 记录响应数据摘要
          if (typeof data.result === 'string') {
            const responsePreview = data.result.length > 200 ? 
              data.result.substring(0, 200) + '...' : data.result;
            console.info(`[HTTP Response Data Preview] ${responsePreview}`);
          }
          
          resolve(data.result as string);
        }
      });
    });
  }

  /**
   * 销毁HttpClient实例
   */
  static destroy() {
    if (HttpUtil.httpRequest) {
      console.info('[HTTP Client] Destroying HTTP client instance');
      HttpUtil.httpRequest.destroy();
    }
  }
}