# ArkUI 布局组件速查表

## 基础布局

### Column - 垂直布局
```typescript
Column() {
  Text('顶部')
  Text('中间')
  Text('底部')
}
.width('100%')
.justifyContent(FlexAlign.SpaceBetween)  // 主轴对齐
.alignItems(HorizontalAlign.Center)       // 交叉轴对齐
.space(10)  // 子组件间距
```

### Row - 水平布局
```typescript
Row() {
  Text('左')
  Text('中')
  Text('右')
}
.width('100%')
.justifyContent(FlexAlign.SpaceEvenly)
.alignItems(VerticalAlign.Bottom)
.space(15)
```

### Stack - 层叠布局
```typescript
Stack() {
  // 底层
  Image($r('app.media.background'))
    .width('100%')
    .height('100%')
  
  // 中间层
  Text('标题')
    .fontSize(20)
    .fontColor(Color.White)
  
  // 顶层（右上角）
  Button('关闭')
    .position({ x: 200, y: 20 })
}
.width('100%')
.height(200)
```

### Flex - 弹性布局
```typescript
Flex({ direction: FlexDirection.Row, wrap: FlexWrap.Wrap }) {
  ForEach([1, 2, 3, 4, 5], (item: number) => {
    Text(`Item ${item}`)
      .width(100)
      .height(50)
      .flexGrow(1)  // 分配剩余空间
      .flexShrink(1)  // 允许收缩
  })
}
.width('100%')
.justifyContent(FlexAlign.Center)
.alignItems(VerticalAlign.Center)
```

---

## 列表组件

### List - 列表
```typescript
@Entry
@Component
struct NewsList {
  @State newsList: NewsItem[] = [];

  build() {
    List({ space: 10 }) {
      ForEach(this.newsList, (item: NewsItem) => {
        ListItem() {
          NewsCard({ news: item })
        }
      }, (item: NewsItem) => item.id)
    }
    .width('100%')
    .height('100%')
    .padding(10)
    .scrollBar(BarState.Auto)
  }
}
```

### LazyForEach - 懒加载长列表
```typescript
class NewsDataSource implements BasicDataSource {
  private data: NewsItem[] = [];

  getData(index: number): NewsItem {
    return this.data[index];
  }

  totalCount(): number {
    return this.data.length;
  }
}

@Entry
@Component
struct LongList {
  @State dataSource: NewsDataSource = new NewsDataSource();

  build() {
    List({ space: 8 }) {
      LazyForEach(this.dataSource, (item: NewsItem) => {
        ListItem() {
          NewsCard({ news: item })
        }
      }, (item: NewsItem) => item.id)
    }
  }
}
```

### WaterFlow - 瀑布流
```typescript
@Entry
@Component
struct PhotoWall {
  @State photos: PhotoItem[] = [];

  build() {
    WaterFlow() {
      ForEach(this.photos, (item: PhotoItem) => {
        FlowItem() {
          PhotoCard({
            photo: item,
            aspectRatio: item.width / item.height
          })
        }
      }, (item: PhotoItem) => item.id)
    }
    .columnsTemplate((width: number) => {
      // 根据屏幕宽度动态计算列数
      if (width > 800) return [1, 1, 1, 1];
      if (width > 500) return [1, 1, 1];
      return [1, 1];
    })
    .columnsGap(10)
    .rowsGap(10)
    .padding(10)
  }
}
```

---

## 网格组件

### Grid - 网格布局
```typescript
@Entry
@Component
struct AppGrid {
  build() {
    Grid() {
      ForEach([1, 2, 3, 4, 5, 6], (item: number) => {
        GridItem() {
          AppIcon({ index: item })
        }
        .width(100)
        .height(100)
      })
    }
    .columnsTemplate([1, 1, 1])  // 3 列
    .rowsGap(15)
    .columnsGap(15)
    .padding(15)
  }
}
```

---

## 常用组件

### Text - 文本
```typescript
Text('显示内容')
  .fontSize(16)
  .fontWeight(FontWeight.Medium)
  .fontColor('#333333')
  .maxLines(2)
  .textOverflow({ overflow: TextOverflow.Ellipsis })
  .textAlign(TextAlign.Center)
  .letterSpacing(1)
  .lineHeight(24)
```

### Button - 按钮
```typescript
// 普通按钮
Button('点击')
  .width('100%')
  .height(45)
  .fontSize(16)
  .fontColor(Color.White)
  .backgroundColor('#007DFF')
  .borderRadius(8)
  .onClick(() => {
    // 点击处理
  })

// 带图标按钮
Button({
  type: ButtonType.Circle,
  stateEffect: true
}) {
  Image($r('app.media.icon_add'))
    .width(24)
    .height(24)
}
```

### Image - 图片
```typescript
Image($r('app.media.cover'))
  .width('100%')
  .height(200)
  .objectFit(ImageFit.Cover)
  .borderRadius(8)

// 网络图片
Image('https://example.com/image.jpg')
  .width(200)
  .height(150)
  .objectFit(ImageFit.Contain)
```

### TextInput - 文本输入
```typescript
@Entry
@Component
struct LoginForm {
  @State username: string = '';
  @State password: string = '';

  build() {
    Column() {
      TextInput({ placeholder: '用户名', text: this.username })
        .onChange((value: string) => {
          this.username = value;
        })
        .type(InputType.Text)

      TextInput({ placeholder: '密码', text: this.password })
        .onChange((value: string) => {
          this.password = value;
        })
        .type(InputType.Password)
    }
    .padding(20)
  }
}
```

### Swiper - 轮播图
```typescript
@Entry
@Component
struct Banner {
  @State currentIndex: number = 0;
  private banners: string[] = ['banner1', 'banner2', 'banner3'];

  build() {
    Column() {
      Swiper() {
        ForEach(this.banners, (item: string) => {
          Image($r(`app.media.${item}`))
            .width('100%')
            .height(180)
            .objectFit(ImageFit.Cover)
        })
      }
      .autoPlay(true)
      .loop(true)
      .interval(3000)
      .onChange((index: number) => {
        this.currentIndex = index;
      })

      // 指示器
      Row() {
        ForEach(this.banners, (_, index: number) => {
          Div()
            .width(this.currentIndex === index ? 20 : 8)
            .height(8)
            .backgroundColor(this.currentIndex === index ? '#007DFF' : '#CCCCCC')
            .borderRadius(4)
            .margin({ left: 5, right: 5 })
        })
      }
      .justifyContent(FlexAlign.Center)
      .margin({ top: 10 })
    }
  }
}
```

---

## 动画

### 显式动画
```typescript
@Entry
@Component
struct AnimationDemo {
  @State scale: number = 1;
  @State opacity: number = 1;

  build() {
    Column() {
      Image($r('app.media.logo'))
        .width(100)
        .height(100)
        .scale(this.scale)
        .opacity(this.opacity)

      Button('执行动画')
        .onClick(() => {
          animateTo({
            duration: 500,
            curve: Curve.EaseInOut,
            delay: 0
          }, () => {
            this.scale = 1.2;
            this.opacity = 0.8;
          });
        })
    }
  }
}
```

### 属性动画
```typescript
Button('旋转')
  .rotation(0)
  .rotate({ angle: 360 })
  .animation({
    duration: 1000,
    iterations: -1,  // 无限循环
    direction: Direction.Normal,
    curve: Curve.Linear
  })
```

---

## 响应式布局

### 断点适配
```typescript
@Entry
@Component
struct ResponsivePage {
  build() {
    Column() {
      // 根据屏幕宽度显示不同列数
      Grid() {
        ForEach([1, 2, 3, 4, 5, 6], (item: number) => {
          GridItem() {
            ContentBox({ index: item })
          }
        })
      }
      .columnsTemplate(this.getColumnsTemplate())
    }
  }

  getColumnsTemplate(): number[] {
    // 获取屏幕宽度
    const windowProps = getContext(this) as common.UIAbilityContext;
    const width = windowProps.window?.getWindowProperties()?.width ?? 0;

    if (width > 1200) return [1, 1, 1, 1];  // 平板
    if (width > 600) return [1, 1, 1];       // 大屏手机
    return [1, 1];                            // 普通手机
  }
}
```
