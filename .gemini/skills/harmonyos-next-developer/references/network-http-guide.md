# 网络请求封装指南

## HTTP 工具类完整实现

### 基础封装
```typescript
// entry/src/main/ets/common/network/HttpUtil.ts

import { http, HttpResponse } from '@kit.NetworkKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG = 'HttpUtil';
const FORMAT = '%{public}s, %{public}s';

// 响应数据结构
export interface ApiResponse<T> {
  code: number;
  message: string;
  data: T;
}

// 请求配置
export interface RequestConfig {
  timeout?: number;
  header?: Record<string, string>;
  useAuth?: boolean;  // 是否携带认证 token
}

export class HttpUtil {
  private static BASE_URL = 'https://api.example.com';
  private static DEFAULT_TIMEOUT = 10000;
  private static token: string = '';

  // 设置认证 token
  static setToken(token: string): void {
    this.token = token;
  }

  // 清除 token
  static clearToken(): void {
    this.token = '';
  }

  // GET 请求
  static async get<T>(
    url: string,
    params?: Record<string, string>,
    config?: RequestConfig
  ): Promise<T> {
    const httpRequest = http.createHttp();
    const timeout = config?.timeout ?? this.DEFAULT_TIMEOUT;

    try {
      const fullUrl = params
        ? `${this.BASE_URL}${url}?${this.buildQueryString(params)}`
        : `${this.BASE_URL}${url}`;

      const response: HttpResponse = await httpRequest.request(fullUrl, {
        method: http.RequestMethod.GET,
        header: this.buildHeaders(config),
        connectTimeout: timeout,
        readTimeout: timeout
      });

      hilog.info(TAG, 'GET', FORMAT, url, `Status: ${response.responseCode}`);

      if (response.responseCode === 200) {
        return response.result as T;
      }

      throw new HttpError(`HTTP Error: ${response.responseCode}`, response.responseCode);
    } catch (error) {
      hilog.error(TAG, 'GET', FORMAT, url, (error as BusinessError).message);
      throw this.handleError(error);
    } finally {
      httpRequest.destroy();
    }
  }

  // POST 请求
  static async post<T>(
    url: string,
    data: Record<string, unknown>,
    config?: RequestConfig
  ): Promise<T> {
    const httpRequest = http.createHttp();
    const timeout = config?.timeout ?? this.DEFAULT_TIMEOUT;

    try {
      const response: HttpResponse = await httpRequest.request(
        `${this.BASE_URL}${url}`,
        {
          method: http.RequestMethod.POST,
          header: this.buildHeaders(config),
          extraData: JSON.stringify(data),
          connectTimeout: timeout,
          readTimeout: timeout
        }
      );

      hilog.info(TAG, 'POST', FORMAT, url, `Status: ${response.responseCode}`);

      if (response.responseCode === 200) {
        return response.result as T;
      }

      throw new HttpError(`HTTP Error: ${response.responseCode}`, response.responseCode);
    } catch (error) {
      hilog.error(TAG, 'POST', FORMAT, url, (error as BusinessError).message);
      throw this.handleError(error);
    } finally {
      httpRequest.destroy();
    }
  }

  // PUT 请求
  static async put<T>(
    url: string,
    data: Record<string, unknown>,
    config?: RequestConfig
  ): Promise<T> {
    const httpRequest = http.createHttp();
    const timeout = config?.timeout ?? this.DEFAULT_TIMEOUT;

    try {
      const response: HttpResponse = await httpRequest.request(
        `${this.BASE_URL}${url}`,
        {
          method: http.RequestMethod.PUT,
          header: this.buildHeaders(config),
          extraData: JSON.stringify(data),
          connectTimeout: timeout,
          readTimeout: timeout
        }
      );

      if (response.responseCode === 200) {
        return response.result as T;
      }

      throw new HttpError(`HTTP Error: ${response.responseCode}`, response.responseCode);
    } catch (error) {
      throw this.handleError(error);
    } finally {
      httpRequest.destroy();
    }
  }

  // DELETE 请求
  static async delete<T>(
    url: string,
    config?: RequestConfig
  ): Promise<T> {
    const httpRequest = http.createHttp();
    const timeout = config?.timeout ?? this.DEFAULT_TIMEOUT;

    try {
      const response: HttpResponse = await httpRequest.request(
        `${this.BASE_URL}${url}`,
        {
          method: http.RequestMethod.DELETE,
          header: this.buildHeaders(config),
          connectTimeout: timeout,
          readTimeout: timeout
        }
      );

      if (response.responseCode === 200) {
        return response.result as T;
      }

      throw new HttpError(`HTTP Error: ${response.responseCode}`, response.responseCode);
    } catch (error) {
      throw this.handleError(error);
    } finally {
      httpRequest.destroy();
    }
  }

  // 构建查询字符串
  private static buildQueryString(params: Record<string, string>): string {
    return Object.entries(params)
      .map(([key, value]) => `${encodeURIComponent(key)}=${encodeURIComponent(value)}`)
      .join('&');
  }

  // 构建请求头
  private static buildHeaders(config?: RequestConfig): Record<string, string> {
    const headers: Record<string, string> = {
      'Content-Type': 'application/json',
      ...config?.header
    };

    if (config?.useAuth && this.token) {
      headers['Authorization'] = `Bearer ${this.token}`;
    }

    return headers;
  }

  // 统一错误处理
  private static handleError(error: unknown): HttpError {
    if (error instanceof HttpError) {
      return error;
    }

    const businessError = error as BusinessError;
    
    // 网络错误码判断
    if (businessError.name === 'NetworkError') {
      return new NetworkError('网络连接失败，请检查网络设置');
    }

    if (businessError.name === 'TimeoutError') {
      return new TimeoutError('请求超时，请重试');
    }

    return new HttpError(businessError.message || '未知错误');
  }
}

// 自定义错误类
export class HttpError extends Error {
  code?: number;

  constructor(message: string, code?: number) {
    super(message);
    this.name = 'HttpError';
    this.code = code;
  }
}

export class NetworkError extends HttpError {
  constructor(message: string) {
    super(message);
    this.name = 'NetworkError';
  }
}

export class TimeoutError extends HttpError {
  constructor(message: string) {
    super(message);
    this.name = 'TimeoutError';
  }
}
```

---

## 使用示例

### 定义数据模型
```typescript
// entry/src/main/ets/common/interfaces/User.ts

export interface User {
  id: number;
  username: string;
  email: string;
  avatar?: string;
  createdAt: string;
}

export interface LoginRequest {
  username: string;
  password: string;
}

export interface LoginResponse {
  token: string;
  user: User;
}
```

### 创建 API 服务层
```typescript
// entry/src/main/ets/common/network/UserService.ts

import { HttpUtil, ApiResponse } from './HttpUtil';
import type { User, LoginRequest, LoginResponse } from '../interfaces/User';

export class UserService {
  // 用户登录
  static async login(credentials: LoginRequest): Promise<LoginResponse> {
    const response = await HttpUtil.post<ApiResponse<LoginResponse>>(
      '/auth/login',
      credentials
    );
    
    // 保存 token
    if (response.data.token) {
      HttpUtil.setToken(response.data.token);
    }
    
    return response.data;
  }

  // 获取用户信息
  static async getUserInfo(userId: number): Promise<User> {
    const response = await HttpUtil.get<ApiResponse<User>>(
      `/user/${userId}`,
      undefined,
      { useAuth: true }
    );
    return response.data;
  }

  // 更新用户信息
  static async updateUserProfile(data: Partial<User>): Promise<User> {
    const response = await HttpUtil.put<ApiResponse<User>>(
      '/user/profile',
      data,
      { useAuth: true }
    );
    return response.data;
  }

  // 登出
  static async logout(): Promise<void> {
    await HttpUtil.post('/auth/logout', {}, { useAuth: true });
    HttpUtil.clearToken();
  }
}
```

### 在页面中使用
```typescript
// entry/src/main/ets/pages/LoginPage.ets

import { UserService } from '../common/network/UserService';
import { HttpError, NetworkError, TimeoutError } from '../common/network/HttpUtil';
import { router } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG = 'LoginPage';

@Entry
@Component
struct LoginPage {
  @State username: string = '';
  @State password: string = '';
  @State isLoading: boolean = false;
  @State errorMessage: string = '';

  build() {
    Column() {
      Text('用户登录')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 30 })

      TextInput({
        placeholder: '请输入用户名',
        text: this.username
      })
        .onChange((value: string) => {
          this.username = value;
          this.errorMessage = '';
        })
        .type(InputType.Text)
        .width('85%')
        .height(45)
        .margin({ bottom: 15 })

      TextInput({
        placeholder: '请输入密码',
        text: this.password
      })
        .onChange((value: string) => {
          this.password = value;
          this.errorMessage = '';
        })
        .type(InputType.Password)
        .width('85%')
        .height(45)
        .margin({ bottom: 15 })

      if (this.errorMessage) {
        Text(this.errorMessage)
          .fontColor(Color.Red)
          .fontSize(14)
          .margin({ bottom: 10 })
      }

      Button(this.isLoading ? '登录中...' : '登录')
        .onClick(() => {
          this.handleLogin();
        })
        .width('85%')
        .height(45)
        .fontSize(16)
        .fontColor(Color.White)
        .backgroundColor('#007DFF')
        .borderRadius(8)
        .enabled(!this.isLoading)

      if (this.isLoading) {
        LoadingProgress()
          .width(40)
          .height(40)
          .margin({ top: 20 })
      }
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  async handleLogin(): Promise<void> {
    if (!this.username || !this.password) {
      this.errorMessage = '请输入用户名和密码';
      return;
    }

    this.isLoading = true;
    this.errorMessage = '';

    try {
      const result = await UserService.login({
        username: this.username,
        password: this.password
      });

      hilog.info(TAG, 'login', '登录成功：用户 %{public}s', result.user.username);

      // 跳转到首页
      router.pushUrl({ url: 'pages/HomePage' });
    } catch (error) {
      if (error instanceof NetworkError) {
        this.errorMessage = '网络连接失败，请检查网络设置';
      } else if (error instanceof TimeoutError) {
        this.errorMessage = '请求超时，请重试';
      } else if (error instanceof HttpError) {
        this.errorMessage = error.message;
      } else {
        this.errorMessage = '登录失败，请稍后重试';
      }
      hilog.error(TAG, 'login', '登录失败：%{public}s', this.errorMessage);
    } finally {
      this.isLoading = false;
    }
  }
}
```

---

## 文件上传

```typescript
// entry/src/main/ets/common/network/FileService.ts

import { http, HttpResponse } from '@kit.NetworkKit';

export class FileService {
  private static BASE_URL = 'https://api.example.com';

  static async uploadFile(
    filePath: string,
    fileName: string
  ): Promise<string> {
    const httpRequest = http.createHttp();

    try {
      // 读取文件内容
      const fileData = await this.readFile(filePath);

      const response: HttpResponse = await httpRequest.request(
        `${this.BASE_URL}/upload`,
        {
          method: http.RequestMethod.POST,
          header: {
            'Content-Type': 'multipart/form-data;boundary=----WebKitFormBoundary'
          },
          extraData: this.buildMultipartData(fileData, fileName),
          connectTimeout: 60000,
          readTimeout: 60000
        }
      );

      if (response.responseCode === 200) {
        const result = JSON.parse(response.result as string);
        return result.data.fileUrl;
      }

      throw new Error(`Upload failed: ${response.responseCode}`);
    } finally {
      httpRequest.destroy();
    }
  }

  private static async readFile(filePath: string): Promise<ArrayBuffer> {
    // 使用文件管理模块读取
    const fs = requireNodeModule('fs');
    return fs.readFileSync(filePath);
  }

  private static buildMultipartData(
    fileData: ArrayBuffer,
    fileName: string
  ): string {
    const boundary = '----WebKitFormBoundary';
    let data = '';

    data += `--${boundary}\r\n`;
    data += `Content-Disposition: form-data; name="file"; filename="${fileName}"\r\n`;
    data += `Content-Type: application/octet-stream\r\n\r\n`;
    data += `[FILE_DATA]\r\n`;
    data += `--${boundary}--\r\n`;

    return data;
  }
}
```

---

## 请求拦截器

```typescript
// 带请求拦截的封装
export class HttpUtilWithInterceptor {
  private static interceptors: Array<(config: RequestConfig) => RequestConfig> = [];

  // 添加拦截器
  static addInterceptor(
    interceptor: (config: RequestConfig) => RequestConfig
  ): void {
    this.interceptors.push(interceptor);
  }

  // 执行拦截器
  private static applyInterceptors(config: RequestConfig): RequestConfig {
    let newConfig = config;
    for (const interceptor of this.interceptors) {
      newConfig = interceptor(newConfig);
    }
    return newConfig;
  }

  static async get<T>(url: string, params?: Record<string, string>, config?: RequestConfig): Promise<T> {
    const finalConfig = this.applyInterceptors(config || {});
    return HttpUtil.get<T>(url, params, finalConfig);
  }
}

// 使用：添加日志拦截器
HttpUtilWithInterceptor.addInterceptor((config) => {
  hilog.info('HttpInterceptor', 'request', 'URL: %{public}s', config);
  return config;
});
```
