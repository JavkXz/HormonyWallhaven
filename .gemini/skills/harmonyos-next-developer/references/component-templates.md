# 常用组件模板库

## 卡片组件

### 用户信息卡片
```typescript
// entry/src/main/ets/components/UserCard.ets

import type { User } from '../common/interfaces/User';

interface UserCardParams {
  user: User;
  onEdit?: () => void;
}

@Component
export struct UserCard {
  @Param user: User;
  @Param onEdit?: () => void;

  build() {
    Column() {
      // 头像区域
      Stack() {
        Image(this.user.avatar || $r('app.media.default_avatar'))
          .width(80)
          .height(80)
          .borderRadius(40)
          .objectFit(ImageFit.Cover)

        // 在线状态
        Circle()
          .width(16)
          .height(16)
          .fill('#4CD964')
          .position({ x: 60, y: 60 })
      }
      .margin({ bottom: 12 })

      // 用户名
      Text(this.user.username)
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor('#1F1F1F')

      // 邮箱
      Text(this.user.email)
        .fontSize(14)
        .fontColor('#999999')
        .margin({ top: 4 })

      // 编辑按钮
      Button('编辑资料')
        .onClick(() => {
          this.onEdit?.();
        })
        .width(120)
        .height(36)
        .fontSize(14)
        .backgroundColor('#007DFF')
        .borderRadius(18)
        .margin({ top: 12 })
    }
    .width('100%')
    .padding(20)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .shadow({
      radius: 8,
      color: 'rgba(0, 0, 0, 0.1)',
      offsetX: 0,
      offsetY: 2
    })
  }
}
```

### 新闻卡片
```typescript
// entry/src/main/ets/components/NewsCard.ets

interface NewsItem {
  id: number;
  title: string;
  summary: string;
  coverImage: string;
  source: string;
  publishTime: string;
  readCount: number;
}

interface NewsCardParams {
  news: NewsItem;
  onClick?: (id: number) => void;
}

@Component
export struct NewsCard {
  @Param news: NewsItem;
  @Param onClick?: (id: number) => void;

  build() {
    Row() {
      // 封面图
      Image(this.news.coverImage)
        .width(120)
        .height(90)
        .objectFit(ImageFit.Cover)
        .borderRadius(8)

      // 内容区域
      Column() {
        Text(this.news.title)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1F1F1F')
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text(this.news.summary)
          .fontSize(13)
          .fontColor('#666666')
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ top: 8 })

        // 底部信息
        Row() {
          Text(this.news.source)
            .fontSize(12)
            .fontColor('#999999')

          Text(`· ${this.news.publishTime}`)
            .fontSize(12)
            .fontColor('#999999')
            .margin({ left: 8 })

          Text(`· ${this.formatReadCount(this.news.readCount)}阅读`)
            .fontSize(12)
            .fontColor('#999999')
            .margin({ left: 8 })
        }
        .margin({ top: 8 })
      }
      .layoutWeight(1)
      .margin({ left: 12 })
      .alignContent(VerticalAlign.Top)
    }
    .width('100%')
    .padding(12)
    .backgroundColor(Color.White)
    .borderRadius(10)
    .onClick(() => {
      this.onClick?.(this.news.id);
    })
  }

  private formatReadCount(count: number): string {
    if (count >= 10000) {
      return `${(count / 10000).toFixed(1)}万`;
    }
    return `${count}`;
  }
}
```

### 商品卡片
```typescript
// entry/src/main/ets/components/ProductCard.ets

interface ProductItem {
  id: number;
  name: string;
  price: number;
  originalPrice?: number;
  image: string;
  sales: number;
  isFavorite: boolean;
}

interface ProductCardParams {
  product: ProductItem;
  onFavoriteToggle?: (id: number, isFavorite: boolean) => void;
  onClick?: (id: number) => void;
}

@Component
export struct ProductCard {
  @Param product: ProductItem;
  @Param onFavoriteToggle?: (id: number, isFavorite: boolean) => void;
  @Param onClick?: (id: number) => void;

  build() {
    Column() {
      Stack() {
        // 商品图片
        Image(this.product.image)
          .width('100%')
          .aspectRatio(1)
          .objectFit(ImageFit.Cover)
          .borderRadius(10)

        // 收藏按钮
        Button({ type: ButtonType.Circle }) {
          Image(this.product.isFavorite ? $r('app.media.icon_favorite_filled') : $r('app.media.icon_favorite_outline'))
            .width(20)
            .height(20)
        }
        .width(32)
        .height(32)
        .backgroundColor('rgba(255, 255, 255, 0.9)')
        .position({ x: 130, y: 10 })
        .onClick(() => {
          this.onFavoriteToggle?.(this.product.id, !this.product.isFavorite);
        })
      }

      // 商品名称
      Text(this.product.name)
        .fontSize(14)
        .fontColor('#1F1F1F')
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .margin({ top: 8 })

      // 价格区域
      Row() {
        Text('¥')
          .fontSize(12)
          .fontColor('#FF4444')
          .fontWeight(FontWeight.Medium)

        Text(this.product.price.toFixed(2))
          .fontSize(18)
          .fontColor('#FF4444')
          .fontWeight(FontWeight.Bold)

        if (this.product.originalPrice && this.product.originalPrice > this.product.price) {
          Text(`¥${this.product.originalPrice.toFixed(2)}`)
            .fontSize(12)
            .fontColor('#CCCCCC')
            .decoration(TextDecoration.LineThrough)
            .margin({ left: 6 })
        }
      }
      .margin({ top: 6 })

      // 销量
      Text(`${this.formatSales(this.product.sales)}人付款`)
        .fontSize(11)
        .fontColor('#999999')
        .margin({ top: 4 })
    }
    .width('100%')
    .padding(10)
    .backgroundColor(Color.White)
    .borderRadius(10)
    .onClick(() => {
      this.onClick?.(this.product.id);
    })
  }

  private formatSales(sales: number): string {
    if (sales >= 10000) {
      return `${(sales / 10000).toFixed(1)}万`;
    }
    return `${sales}`;
  }
}
```

---

## 加载状态组件

### 空状态
```typescript
// entry/src/main/ets/components/EmptyState.ets

interface EmptyStateParams {
  icon?: Resource;
  message: string;
  actionText?: string;
  onAction?: () => void;
}

@Component
export struct EmptyState {
  @Param message: string;
  @Param icon?: Resource;
  @Param actionText?: string;
  @Param onAction?: () => void;

  build() {
    Column() {
      Image(this.icon || $r('app.media.empty_state'))
        .width(120)
        .height(120)
        .objectFit(ImageFit.Contain)

      Text(this.message)
        .fontSize(14)
        .fontColor('#999999')
        .margin({ top: 16 })

      if (this.actionText) {
        Button(this.actionText)
          .onClick(() => {
            this.onAction?.();
          })
          .width(120)
          .height(36)
          .fontSize(14)
          .backgroundColor('#007DFF')
          .borderRadius(18)
          .margin({ top: 16 })
      }
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
}
```

### 加载状态
```typescript
// entry/src/main/ets/components/LoadingState.ets

interface LoadingStateParams {
  text?: string;
}

@Component
export struct LoadingState {
  @Param text: string = '加载中...';

  build() {
    Column() {
      LoadingProgress()
        .width(40)
        .height(40)
        .color('#007DFF')

      Text(this.text)
        .fontSize(14)
        .fontColor('#999999')
        .margin({ top: 12 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
}
```

### 错误状态
```typescript
// entry/src/main/ets/components/ErrorState.ets

interface ErrorStateParams {
  message: string;
  retryText?: string;
  onRetry?: () => void;
}

@Component
export struct ErrorState {
  @Param message: string;
  @Param retryText?: string;
  @Param onRetry?: () => void;

  build() {
    Column() {
      Image($r('app.media.error_state'))
        .width(100)
        .height(100)
        .objectFit(ImageFit.Contain)

      Text(this.message)
        .fontSize(14)
        .fontColor('#999999')
        .margin({ top: 16 })

      if (this.retryText) {
        Button(this.retryText)
          .onClick(() => {
            this.onRetry?.();
          })
          .width(100)
          .height(36)
          .fontSize(14)
          .backgroundColor('#007DFF')
          .borderRadius(18)
          .margin({ top: 16 })
      }
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
}
```

---

## 表单组件

### 登录表单
```typescript
// entry/src/main/ets/components/LoginForm.ets

interface LoginFormParams {
  onLogin: (username: string, password: string) => Promise<void>;
}

@Component
export struct LoginForm {
  @Param onLogin: (username: string, password: string) => Promise<void>;
  @State username: string = '';
  @State password: string = '';
  @State isLoading: boolean = false;
  @State errorMessage: string = '';

  build() {
    Column() {
      // 用户名输入
      TextInput({
        placeholder: '请输入用户名',
        text: this.username
      })
        .onChange((value: string) => {
          this.username = value;
          this.errorMessage = '';
        })
        .type(InputType.Text)
        .width('100%')
        .height(48)
        .backgroundColor('#F5F5F5')
        .borderRadius(8)
        .padding({ left: 16 })

      // 密码输入
      TextInput({
        placeholder: '请输入密码',
        text: this.password
      })
        .onChange((value: string) => {
          this.password = value;
          this.errorMessage = '';
        })
        .type(InputType.Password)
        .width('100%')
        .height(48)
        .backgroundColor('#F5F5F5')
        .borderRadius(8)
        .padding({ left: 16 })
        .margin({ top: 12 })

      // 错误提示
      if (this.errorMessage) {
        Text(this.errorMessage)
          .fontSize(13)
          .fontColor('#FF4444')
          .width('100%')
          .margin({ top: 8 })
      }

      // 登录按钮
      Button(this.isLoading ? '登录中...' : '登录')
        .onClick(() => this.handleSubmit())
        .width('100%')
        .height(48)
        .fontSize(16)
        .fontColor(Color.White)
        .backgroundColor('#007DFF')
        .borderRadius(8)
        .margin({ top: 24 })
        .enabled(!this.isLoading)

      if (this.isLoading) {
        LoadingProgress()
          .width(32)
          .height(32)
          .margin({ top: 12 })
      }
    }
    .width('100%')
    .padding(20)
  }

  async handleSubmit(): Promise<void> {
    if (!this.username || !this.password) {
      this.errorMessage = '请输入用户名和密码';
      return;
    }

    this.isLoading = true;
    this.errorMessage = '';

    try {
      await this.onLogin(this.username, this.password);
    } catch (error) {
      this.errorMessage = (error as Error).message;
    } finally {
      this.isLoading = false;
    }
  }
}
```

---

## 导航栏组件

### 自定义导航栏
```typescript
// entry/src/main/ets/components/CustomNavBar.ets

interface CustomNavBarParams {
  title: string;
  showBack?: boolean;
  rightText?: string;
  onRightClick?: () => void;
}

@Component
export struct CustomNavBar {
  @Param title: string;
  @Param showBack: boolean = true;
  @Param rightText?: string;
  @Param onRightClick?: () => void;

  build() {
    Row() {
      // 返回按钮
      if (this.showBack) {
        Button({ type: ButtonType.Circle }) {
          Image($r('app.media.icon_back'))
            .width(20)
            .height(20)
        }
        .width(36)
        .height(36)
        .backgroundColor('rgba(0, 0, 0, 0.05)')
        .onClick(() => {
          router.back();
        })
      } else {
        Blank()
          .width(36)
      }

      // 标题
      Text(this.title)
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor('#1F1F1F')
        .layoutWeight(1)
        .textAlign(TextAlign.Center)

      // 右侧按钮
      if (this.rightText) {
        Text(this.rightText)
          .fontSize(15)
          .fontColor('#007DFF')
          .onClick(() => {
            this.onRightClick?.();
          })
          .padding({ left: 12, right: 12 })
      } else {
        Blank()
          .width(36)
      }
    }
    .width('100%')
    .height(50)
    .alignItems(VerticalAlign.Center)
    .padding({ left: 12, right: 12 })
    .backgroundColor(Color.White)
  }
}
```

---

## 使用示例

```typescript
// entry/src/main/ets/pages/HomePage.ets

import { UserCard } from '../components/UserCard';
import { NewsCard } from '../components/NewsCard';
import { EmptyState } from '../components/EmptyState';
import { LoadingState } from '../components/LoadingState';
import { CustomNavBar } from '../components/CustomNavBar';
import type { User, NewsItem } from '../common/interfaces/User';

@Entry
@Component
struct HomePage {
  @State user: User | null = null;
  @State newsList: NewsItem[] = [];
  @State isLoading: boolean = true;
  @State pullRefreshing: boolean = false;

  aboutToAppear(): void {
    this.loadData();
  }

  async loadData(): Promise<void> {
    try {
      // 模拟加载
      await new Promise((resolve) => setTimeout(resolve, 1000));
      
      this.user = {
        id: 1,
        username: '张三',
        email: 'zhangsan@example.com',
        avatar: '',
        createdAt: '2024-01-01'
      };

      this.newsList = [
        {
          id: 1,
          title: '鸿蒙生态大会今日召开',
          summary: '华为开发者大会 2024 正式开幕，发布多项鸿蒙生态新特性',
          coverImage: '',
          source: '科技日报',
          publishTime: '2 小时前',
          readCount: 15234
        }
      ];
    } finally {
      this.isLoading = false;
      this.pullRefreshing = false;
    }
  }

  build() {
    Column() {
      // 自定义导航栏
      CustomNavBar({ title: '首页', showBack: false, rightText: '消息' })

      if (this.isLoading) {
        LoadingState()
      } else if (this.newsList.length === 0) {
        EmptyState({
          message: '暂无内容',
          actionText: '刷新',
          onRetry: () => this.loadData()
        })
      } else {
        List({ space: 10 }) {
          // 用户信息卡片
          if (this.user) {
            ListItem() {
              UserCard({
                user: this.user,
                onEdit: () => {
                  router.pushUrl({ url: 'pages/ProfilePage' });
                }
              })
            }
          }

          // 新闻列表
          ForEach(this.newsList, (item: NewsItem) => {
            ListItem() {
              NewsCard({
                news: item,
                onClick: (id: number) => {
                  router.pushUrl({
                    url: 'pages/NewsDetailPage',
                    params: { id: id }
                  });
                }
              })
            }
          })
        }
        .width('100%')
        .height('100%')
        .padding(10)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}
```
