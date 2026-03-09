import 'package:flutter/widgets.dart';

/// 纵向普通列表配置
///
/// 作为纯流式布局引擎，列表本级仅保留容器整体属性
class YFileListConfig {
  /// 列表整体内边距
  final EdgeInsets padding;

  /// 每个 item 的固定高度（dp），用于吸顶分组的高度估算。
  ///
  /// 仅影响 [pinnedHeader] 模式下分组切换时机的精度，不影响实际渲染高度。
  /// 如果列表 item 高度固定，建议填写此值以获得精确的分组吸顶效果；
  /// 不填写时将使用默认估算值（44.0）。
  final double? itemExtent;

  const YFileListConfig({
    this.padding = EdgeInsets.zero,
    this.itemExtent,
  });

  YFileListConfig copyWith({
    EdgeInsets? padding,
    double? itemExtent,
  }) {
    return YFileListConfig(
      padding: padding ?? this.padding,
      itemExtent: itemExtent ?? this.itemExtent,
    );
  }
}
