import { BasicDataSource } from '../common/BasicDataSource';
import { WallpaperItem } from '../model/WallpaperModel';

export class WallpaperDataSource extends BasicDataSource {
  private dataArray: WallpaperItem[] = [];

  public totalCount(): number {
    return this.dataArray.length;
  }

  public getData(index: number): WallpaperItem {
    return this.dataArray[index];
  }

  public addData(index: number, data: WallpaperItem): void {
    this.dataArray.splice(index, 0, data);
    this.notifyDataAdd(index);
  }

  public pushData(data: WallpaperItem): void {
    this.dataArray.push(data);
    this.notifyDataAdd(this.dataArray.length - 1);
  }
  
  public appendData(dataList: WallpaperItem[]): void {
    if (!dataList || dataList.length === 0) return;
    const startIndex = this.dataArray.length;
    this.dataArray = this.dataArray.concat(dataList);
    // 注意：LazyForEach 通常需要精确的 notify，但在大量添加时，notifyDataReload 可能更简单，
    // 或者循环调用 notifyDataAdd。为了性能和标准，循环调用 notifyDataAdd 可能会导致 UI 频繁刷新。
    // HarmonyOS 文档建议批量更新时使用 notifyDataReload 或者精确计算。
    // 这里为了平滑滚动，我们使用 notifyDataAdd 循环通知。
    // 但更高效的是：
    dataList.forEach((_, i) => {
        this.notifyDataAdd(startIndex + i);
    });
  }

  public setData(dataList: WallpaperItem[]): void {
    this.dataArray = dataList;
    this.notifyDataReload();
  }

  public clear(): void {
    this.dataArray = [];
    this.notifyDataReload();
  }
}
