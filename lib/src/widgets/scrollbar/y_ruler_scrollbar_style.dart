import 'package:flutter/widgets.dart';

/// YRulerScrollbar 的外观配置，类似 [ScrollbarThemeData]。
///
/// 可以同时定制：
/// - Thumb（滑块）的颜色、尺寸、圆角
/// - Track（轨道）的颜色和边框
/// - 刻度线（主节点 / 辅节点）的颜色与尺寸
/// - 节点标签的文字样式
class YRulerScrollbarStyle {
  // ─── Thumb（滑块）────────────────────────────────────────────────────────
  /// 默认状态下 thumb 的颜色
  final Color thumbColor;

  /// 拖拽进行中 thumb 的颜色
  final Color thumbDraggingColor;

  /// Thumb 的宽度（即 Scrollbar 的"厚度"），单位 dp
  final double thumbWidth;

  /// Thumb 高度下限，防止内容极多时 thumb 缩得太小，单位 dp
  final double thumbMinHeight;

  /// Thumb 高度上限，防止内容极少时 thumb 占满整个轨道，单位 dp
  final double thumbMaxHeight;

  /// Thumb 的圆角半径
  final BorderRadius thumbRadius;

  // ─── Track（轨道）────────────────────────────────────────────────────────
  /// 轨道背景色；若 [showTrack] 为 false 则不绘制
  final Color trackColor;

  /// 轨道左侧边线颜色
  final Color trackBorderColor;

  /// 是否绘制轨道背景
  final bool showTrack;

  // ─── 刻度线 ────────────────────────────────────────────────────────────
  /// 刻度线颜色
  final Color tickColor;

  /// 刻度线笔画宽度
  final double tickStrokeWidth;

  /// 主节点刻度线长度（如年份），从 thumb 右边缘向左延伸
  final double majorTickLength;

  /// 辅节点刻度线长度（如月份）
  final double minorTickLength;

  // ─── 节点标签 ──────────────────────────────────────────────────────────
  /// 绘制在刻度线旁的标签文字样式；为 null 时不绘制标签
  final TextStyle? labelStyle;

  // ─── 尺寸与间距 ──────────────────────────────────────────────────────────
  /// Scrollbar 整体的内边距（上下会影响轨道高度）
  final EdgeInsets padding;

  /// 交互热区宽度（由于滑块和刻度线可能很细，增加该值可扩大滑动触发范围）。
  /// 单位 dp。如果不传，则默认为滑块+刻度线+标签占用的视觉总宽度。
  final double? hitTestWidth;

  /// 轨道背景宽度。如果不传，则默认跟随 [hitTestWidth]（即占满热区）。
  final double? trackWidth;

  /// 交互热区背景色。默认透明。
  /// 设置此值可用于调试或在特定设计下为整个热区提供背景感。
  final Color hitTestBackgroundColor;

  const YRulerScrollbarStyle({
    this.thumbColor = const Color(0xFFBBBBBB),
    this.thumbDraggingColor = const Color(0xFF888888),
    this.thumbWidth = 4.0,
    this.thumbMinHeight = 24.0,
    this.thumbMaxHeight = double.infinity,
    this.thumbRadius = const BorderRadius.all(Radius.circular(2)),
    this.trackColor = const Color(0x0F000000),
    this.trackBorderColor = const Color(0x1F000000),
    this.showTrack = false,
    this.tickColor = const Color(0xFFCCCCCC),
    this.tickStrokeWidth = 1.0,
    this.majorTickLength = 14.0,
    this.minorTickLength = 8.0,
    this.labelStyle,
    this.padding = const EdgeInsets.symmetric(vertical: 0),
    this.hitTestWidth,
    this.trackWidth,
    this.hitTestBackgroundColor = const Color(0x00000000),
  });

  /// 复制并覆盖部分属性
  YRulerScrollbarStyle copyWith({
    Color? thumbColor,
    Color? thumbDraggingColor,
    double? thumbWidth,
    double? thumbMinHeight,
    double? thumbMaxHeight,
    BorderRadius? thumbRadius,
    Color? trackColor,
    Color? trackBorderColor,
    bool? showTrack,
    Color? tickColor,
    double? tickStrokeWidth,
    double? majorTickLength,
    double? minorTickLength,
    TextStyle? labelStyle,
    EdgeInsets? padding,
    double? hitTestWidth,
    double? trackWidth,
    Color? hitTestBackgroundColor,
  }) {
    return YRulerScrollbarStyle(
      thumbColor: thumbColor ?? this.thumbColor,
      thumbDraggingColor: thumbDraggingColor ?? this.thumbDraggingColor,
      thumbWidth: thumbWidth ?? this.thumbWidth,
      thumbMinHeight: thumbMinHeight ?? this.thumbMinHeight,
      thumbMaxHeight: thumbMaxHeight ?? this.thumbMaxHeight,
      thumbRadius: thumbRadius ?? this.thumbRadius,
      trackColor: trackColor ?? this.trackColor,
      trackBorderColor: trackBorderColor ?? this.trackBorderColor,
      showTrack: showTrack ?? this.showTrack,
      tickColor: tickColor ?? this.tickColor,
      tickStrokeWidth: tickStrokeWidth ?? this.tickStrokeWidth,
      majorTickLength: majorTickLength ?? this.majorTickLength,
      minorTickLength: minorTickLength ?? this.minorTickLength,
      labelStyle: labelStyle ?? this.labelStyle,
      padding: padding ?? this.padding,
      hitTestWidth: hitTestWidth ?? this.hitTestWidth,
      trackWidth: trackWidth ?? this.trackWidth,
      hitTestBackgroundColor:
          hitTestBackgroundColor ?? this.hitTestBackgroundColor,
    );
  }
}
