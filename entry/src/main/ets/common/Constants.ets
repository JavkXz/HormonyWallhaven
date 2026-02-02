// 选择器选项接口
export interface SelectOption {
  value: string;
  label: string;
}

export class AppConstants {
  // 纯净度选项 (用于 UI 显示，逻辑层需组合)
  // Wallhaven 使用位掩码: SFW(100), Sketchy(010), NSFW(001)
  // 这里定义单项值
  static readonly PURITY_SFW = '100';
  static readonly PURITY_SKETCHY = '010';
  static readonly PURITY_NSFW = '001';

  static readonly SORTING_OPTIONS: SelectOption[] = [
    { value: 'date_added', label: 'Latest' },
    { value: 'relevance', label: 'Relevance' },
    { value: 'random', label: 'Random' },
    { value: 'views', label: 'Most Viewed' },
    { value: 'favorites', label: 'Most Fav' },
    { value: 'toplist', label: 'Toplist' },
    { value: 'hot', label: 'Hot' }
  ];

  static readonly TOPRANGE_OPTIONS: SelectOption[] = [
    { value: '1d', label: 'Last Day' },
    { value: '3d', label: 'Last 3 Days' },
    { value: '1w', label: 'Last Week' },
    { value: '1M', label: 'Last Month' },
    { value: '3M', label: 'Last 3 Months' },
    { value: '6M', label: 'Last 6 Months' },
    { value: '1y', label: 'Last Year' }
  ];

  static readonly ORDER_OPTIONS: SelectOption[] = [
    { value: 'desc', label: 'Desc' },
    { value: 'asc', label: 'Asc' }
  ];

  static readonly RESOLUTION_OPTIONS: SelectOption[] = [
    { value: '', label: 'Any Res' },
    { value: '1920x1080', label: '1080p' },
    { value: '2560x1440', label: '1440p' },
    { value: '3840x2160', label: '4K UHD' },
    { value: '7680x4320', label: '8K UHD' }
  ];
  
  static readonly RATIO_OPTIONS: SelectOption[] = [
    { value: '', label: 'Any Ratio' },
    { value: '16x9', label: '16:9' },
    { value: '16x10', label: '16:10' },
    { value: '21x9', label: '21:9 (Ultrawide)' },
    { value: '32x9', label: '32:9' },
    { value: '9x16', label: '9:16 (Portrait)' }
  ];
}