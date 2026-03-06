import 'package:flutter/widgets.dart';

/// 纵向普通列表配置
///
/// 作为纯流式布局引擎，列表本级仅保留容器整体属性
class YFileListConfig {
  /// 列表整体内边距
  final EdgeInsets padding;

  const YFileListConfig({
    this.padding = EdgeInsets.zero,
  });

  YFileListConfig copyWith({
    EdgeInsets? padding,
  }) {
    return YFileListConfig(
      padding: padding ?? this.padding,
    );
  }
}
