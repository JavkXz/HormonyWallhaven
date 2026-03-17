/**
 * 全局主题常量定义
 * 
 * 设计风格：Immersive Fluidity（沉浸式流体美学）
 */

// ═══════════════════════════════════════════════════════════
// 阴影接口定义
// ═══════════════════════════════════════════════════════════
export interface ShadowOptions {
  radius: number;
  color: string;
  offsetY: number;
}

// ═══════════════════════════════════════════════════════════
// 动画预设接口定义
// ═══════════════════════════════════════════════════════════
export interface AnimationOptions {
  duration: number;
  curve: Curve;
}

// ═══════════════════════════════════════════════════════════
// 主题色彩系统
// ═══════════════════════════════════════════════════════════
export class ThemeColors {
  // 主色调 - 鸿蒙蓝
  static readonly primary: string = '#007DFF';
  static readonly primaryLight: string = 'rgba(0,125,255,0.2)';
  static readonly primaryLighter: string = 'rgba(0,125,255,0.1)';
  
  // 阴影色
  static readonly primaryShadow: string = 'rgba(0,125,255,0.4)';
  static readonly primaryShadowStrong: string = 'rgba(0,125,255,0.5)';
  
  // 背景色系
  static readonly background: string = '#000000';
  static readonly backgroundSurface: string = 'rgba(30,30,30,0.85)';
  static readonly backgroundOverlay: string = 'rgba(0,0,0,0.35)';
  
  // 表面层（毛玻璃）
  static readonly surface: string = 'rgba(255,255,255,0.08)';
  static readonly surfaceLight: string = 'rgba(255,255,255,0.12)';
  static readonly surfaceLighter: string = 'rgba(255,255,255,0.15)';
  static readonly surfaceDark: string = 'rgba(0,0,0,0.25)';
  
  // 文字色系
  static readonly textPrimary: string = '#FFFFFF';
  static readonly textSecondary: string = 'rgba(255,255,255,0.6)';
  static readonly textTertiary: string = 'rgba(255,255,255,0.4)';
  static readonly textDisabled: string = 'rgba(255,255,255,0.3)';
  
  // 边框色
  static readonly border: string = 'rgba(255,255,255,0.1)';
  static readonly borderLight: string = 'rgba(255,255,255,0.15)';
  static readonly borderStrong: string = 'rgba(255,255,255,0.2)';
  
  // 功能色
  static readonly error: string = '#FF5252';
  static readonly errorLight: string = 'rgba(255,82,82,0.2)';
  static readonly success: string = '#4CD964';
  static readonly successLight: string = 'rgba(76,217,100,0.2)';
  static readonly warning: string = '#FFB800';
  static readonly info: string = '#007DFF';
  
  // 收藏色
  static readonly favorite: string = '#FF5252';
}

// ═══════════════════════════════════════════════════════════
// 阴影系统
// ═══════════════════════════════════════════════════════════
export class ThemeShadows {
  static readonly small: ShadowOptions = {
    radius: 8,
    color: 'rgba(0,0,0,0.15)',
    offsetY: 2
  };
  
  static readonly medium: ShadowOptions = {
    radius: 12,
    color: 'rgba(0,0,0,0.2)',
    offsetY: 4
  };
  
  static readonly large: ShadowOptions = {
    radius: 20,
    color: 'rgba(0,0,0,0.25)',
    offsetY: 8
  };
  
  static readonly primary: ShadowOptions = {
    radius: 15,
    color: ThemeColors.primaryShadow,
    offsetY: 6
  };
  
  static readonly floating: ShadowOptions = {
    radius: 25,
    color: ThemeColors.primaryShadowStrong,
    offsetY: 10
  };
}

// ═══════════════════════════════════════════════════════════
// 动画预设
// ═══════════════════════════════════════════════════════════
export class AnimationPresets {
  static readonly standard: AnimationOptions = {
    duration: 350,
    curve: Curve.FastOutSlowIn
  };
  
  static readonly enter: AnimationOptions = {
    duration: 350,
    curve: Curve.FastOutSlowIn
  };
  
  static readonly exit: AnimationOptions = {
    duration: 300,
    curve: Curve.Sharp
  };
  
  static readonly quick: AnimationOptions = {
    duration: 200,
    curve: Curve.EaseInOut
  };
  
  static readonly slow: AnimationOptions = {
    duration: 600,
    curve: Curve.EaseInOut
  };
  
  static readonly spring: AnimationOptions = {
    duration: 500,
    curve: Curve.Rhythm
  };
}

// ═══════════════════════════════════════════════════════════
// 圆角系统
// ═══════════════════════════════════════════════════════════
export class BorderRadius {
  static readonly small: number = 8;
  static readonly medium: number = 12;
  static readonly large: number = 16;
  static readonly xlarge: number = 20;
  static readonly circle: number = 999;
  static readonly capsule: number = 24;
}

// ═══════════════════════════════════════════════════════════
// 间距系统（单位：vp）
// ═══════════════════════════════════════════════════════════
export class Spacing {
  static readonly xs: number = 4;
  static readonly sm: number = 8;
  static readonly md: number = 12;
  static readonly lg: number = 16;
  static readonly xl: number = 20;
  static readonly xxl: number = 24;
  static readonly xxxl: number = 32;
}

// ═══════════════════════════════════════════════════════════
// 按钮尺寸规范
// ═══════════════════════════════════════════════════════════
export class ButtonSizes {
  static readonly circleSmall: number = 36;
  static readonly circleMedium: number = 42;
  static readonly circleLarge: number = 48;
  static readonly circleXLarge: number = 56;
  
  static readonly capsuleSmall: number = 36;
  static readonly capsuleMedium: number = 44;
  static readonly capsuleLarge: number = 48;
  static readonly capsuleXLarge: number = 58;
}
