// 壁纸数据类型定义
export interface WallpaperItem {
  id: string;           // 壁纸ID
  name: string;         // 壁纸名称
  imageUrl: string;     // 壁纸图片URL
  width?: number;       // 图片原始宽度
  height?: number;      // 图片原始高度
  aspectRatio?: number; // 图片宽高比
  calculatedHeight?: number; // 计算后的高度
  uploader?: string;    // 上传者
  tags?: string[];      // 标签
  favorites?: number;   // 收藏数
  purity?: string;      // 纯净度 (sfw/sketchy/nsfw)
  category?: string;    // 类别 (general/anime/people)
  colors?: string[];    // 主要颜色
  resolution?: string;  // 分辨率
}

// Wallhaven API响应数据结构
export interface WallhavenResponse {
  data: WallpaperApiItem[];
  meta: MetaInfo;
}

// Wallhaven单个壁纸数据结构
export interface WallpaperApiItem {
  id: string;
  url: string;
  short_url: string;
  uploader: UploaderInfo;
  tags: TagInfo[];
  views: number;
  favorites: number;
  source: string;
  purity: string;
  category: string;
  created_at: string;
  dimension_x: number;  // 图片宽度
  dimension_y: number;  // 图片高度
  resolution: string;
  ratio: string;
  file_size: number;
  file_type: string;
  pixel_ratio: number;
  path: string;
  thumbs: ThumbnailInfo;
  colors: string[];
}

// 上传者信息
export interface UploaderInfo {
  username: string;
  group: string;
}

// 标签信息
export interface TagInfo {
  id: number;
  name: string;
  alias: string;
  category_id: number;
  category: string;
  purity: string;
}

// 缩略图信息
export interface ThumbnailInfo {
  large: string;
  original: string;
  small: string;
}

// 分页信息
export interface MetaInfo {
  current_page: number;
  last_page: number;
  per_page: number;
  total: number;
  query: string;
  seed: string;
}

// 搜索参数
export interface SearchParams {
  q?: string;           // 搜索查询
  categories?: string;  // 类别
  purity?: string;      // 纯净度
  sorting?: string;     // 排序方式
  order?: string;       // 排序顺序
  topRange?: string;    // 仅当排序设为'toplist'时有效
  atleast?: string;     // 最小分辨率
  resolutions?: string; // 精确分辨率列表
  ratios?: string;      // 宽高比列表
  colors?: string;      // 按颜色搜索
  page?: number;        // 分页
  seed?: string;        // 随机结果的种子
}