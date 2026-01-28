// 壁纸数据类型定义
interface WallpaperItem {
  id: number;
  name: string;
  imageUrl: string; // 在实际项目中，这里会是具体的图片资源路径
}

@Entry
@Component
struct Index {
  @State message: string = '壁纸应用';
  @State wallpaperList: WallpaperItem[] = [
    { id: 1, name: '风景壁纸1', imageUrl: $r('app.media.background').toString() },
    { id: 2, name: '风景壁纸2', imageUrl: $r('app.media.startIcon').toString() },
    { id: 3, name: '风景壁纸3', imageUrl: $r('app.media.foreground').toString() },
    { id: 4, name: '风景壁纸4', imageUrl: $r('app.media.background').toString() },
    { id: 5, name: '风景壁纸5', imageUrl: $r('app.media.startIcon').toString() },
    { id: 6, name: '风景壁纸6', imageUrl: $r('app.media.foreground').toString() },
    { id: 7, name: '风景壁纸7', imageUrl: $r('app.media.background').toString() },
    { id: 8, name: '风景壁纸8', imageUrl: $r('app.media.startIcon').toString() },
    { id: 9, name: '风景壁纸9', imageUrl: $r('app.media.foreground').toString() },
    { id: 10, name: '风景壁纸10', imageUrl: $r('app.media.background').toString() },
    { id: 11, name: '风景壁纸11', imageUrl: $r('app.media.startIcon').toString() },
    { id: 12, name: '风景壁纸12', imageUrl: $r('app.media.foreground').toString() },
  ];

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Text(this.message)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Start)

        // 搜索图标占位
        Image($r('app.media.foreground'))
          .width(24)
          .height(24)
          .visibility(Visibility.Hidden) // 暂时隐藏，后续可替换为真实的搜索图标
      }
      .width('100%')
      .height(50)
      .padding({ left: 16, right: 16 })
      .alignItems(VerticalAlign.Center)

      // 网格布局展示壁纸
      Scroll() {
        Column() {
          // 使用GridRow来创建两列布局
          GridRow({ columns: 2, gutter: 8 }) {
            ForEach(this.wallpaperList, (item: WallpaperItem) => {
              GridCol({
                span: 1,
                offset: 0
              }) {
                // 壁纸卡片
                Column() {
                  Image(item.imageUrl)
                    .width('100%')
                    .height(200)  // 固定高度，可根据实际需求调整
                    .objectFit(ImageFit.Cover)
                    .borderRadius(12)

                  // 壁纸信息
                  Row() {
                    Column() {
                      Text(item.name)
                        .fontSize(14)
                        .fontWeight(FontWeight.Medium)
                        .maxLines(1)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })

                      Text(`ID: ${item.id}`)
                        .fontSize(12)
                        .fontColor('#888888')
                        .margin({ top: 4 })
                    }
                    .layoutWeight(1)

                    // 下载按钮
                    Button('下载')
                      .width(60)
                      .height(30)
                      .fontSize(12)
                      .backgroundColor('#FF4081')
                      .borderRadius(15)
                      .onClick(() => {
                        console.info(`正在下载壁纸: ${item.name}`);
                        // 实现下载功能
                      })
                  }
                  .width('100%')
                  .margin({ top: 8 })
                }
                .backgroundColor('#ffffff')
                .padding(12)
                .borderRadius(12)
                .shadow({
                  radius: 4,
                  color: '#1F000000',
                  offsetX: 0,
                  offsetY: 2
                })
                .onClick(() => {
                  // 这里可以处理点击事件，如跳转到详情页
                  console.log(`点击了壁纸: ${item.name}`);
                })
              }
            })
          }
          .padding({ left: 12, right: 12 })
        }
      }
      .layoutWeight(1)
      .scrollBar(BarState.On)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f0f0f0')
  }
}