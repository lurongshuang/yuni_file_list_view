import 'package:flutter/widgets.dart';

/// 宫格列表配置
///
/// 当 [crossAxisCount] 为 0（或不设置）时，组件会根据 [minItemWidth] 和
/// 当前可用宽度自动计算列数，实现动态自适应布局。
///
/// ```dart
/// // 固定 3 列
/// const YFileGridConfig(crossAxisCount: 3)
///
/// // 自动计算列数，每格最小 100px
/// const YFileGridConfig(crossAxisCount: 0, minItemWidth: 100)
/// ```
class YFileGridConfig {
  /// 每行列数。设为 0 时根据 [minItemWidth] 自动计算
  final int crossAxisCount;

  /// 自动计算列数时，每格的最小宽度（px）
  final double minItemWidth;

  /// 交叉轴（列）间距
  final double crossAxisSpacing;

  /// 主轴（行）间距
  final double mainAxisSpacing;

  /// 宫格宽高比（宽 / 高）
  final double childAspectRatio;

  /// 列表内边距
  final EdgeInsets padding;

  /// 自动计算模式下，最少列数限制
  final int minColumns;

  /// 自动计算模式下，最多列数限制
  final int maxColumns;

  const YFileGridConfig({
    this.crossAxisCount = 3,
    this.minItemWidth = 90.0,
    this.crossAxisSpacing = 2.0,
    this.mainAxisSpacing = 2.0,
    this.childAspectRatio = 1.0,
    this.padding = EdgeInsets.zero,
    this.minColumns = 2,
    this.maxColumns = 10,
  });

  /// 是否启用自动列数计算
  bool get isAutoColumn => crossAxisCount <= 0;

  YFileGridConfig copyWith({
    int? crossAxisCount,
    double? minItemWidth,
    double? crossAxisSpacing,
    double? mainAxisSpacing,
    double? childAspectRatio,
    EdgeInsets? padding,
    int? minColumns,
    int? maxColumns,
  }) {
    return YFileGridConfig(
      crossAxisCount: crossAxisCount ?? this.crossAxisCount,
      minItemWidth: minItemWidth ?? this.minItemWidth,
      crossAxisSpacing: crossAxisSpacing ?? this.crossAxisSpacing,
      mainAxisSpacing: mainAxisSpacing ?? this.mainAxisSpacing,
      childAspectRatio: childAspectRatio ?? this.childAspectRatio,
      padding: padding ?? this.padding,
      minColumns: minColumns ?? this.minColumns,
      maxColumns: maxColumns ?? this.maxColumns,
    );
  }
}
