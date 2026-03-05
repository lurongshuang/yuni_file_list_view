import 'package:flutter/widgets.dart';

/// 纵向普通列表配置
class YFileListConfig {
  /// 单个列表项的固定高度；为 null 时由 item 内容决定
  final double? itemHeight;

  /// 左侧缩略图尺寸（宽高相等）
  final double thumbnailSize;

  /// 缩略图圆角半径
  final double thumbnailBorderRadius;

  /// 是否显示分割线
  final bool showDivider;

  /// 分割线缩进（左起偏移量）
  final double dividerIndent;

  /// 是否在右侧显示多选 checkbox
  final bool showCheckbox;

  /// 列表整体内边距
  final EdgeInsets padding;

  /// 列表项内边距
  final EdgeInsets itemPadding;

  const YFileListConfig({
    this.itemHeight,
    this.thumbnailSize = 56.0,
    this.thumbnailBorderRadius = 4.0,
    this.showDivider = true,
    this.dividerIndent = 72.0,
    this.showCheckbox = false,
    this.padding = EdgeInsets.zero,
    this.itemPadding = const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
  });

  YFileListConfig copyWith({
    double? itemHeight,
    double? thumbnailSize,
    double? thumbnailBorderRadius,
    bool? showDivider,
    double? dividerIndent,
    bool? showCheckbox,
    EdgeInsets? padding,
    EdgeInsets? itemPadding,
  }) {
    return YFileListConfig(
      itemHeight: itemHeight ?? this.itemHeight,
      thumbnailSize: thumbnailSize ?? this.thumbnailSize,
      thumbnailBorderRadius: thumbnailBorderRadius ?? this.thumbnailBorderRadius,
      showDivider: showDivider ?? this.showDivider,
      dividerIndent: dividerIndent ?? this.dividerIndent,
      showCheckbox: showCheckbox ?? this.showCheckbox,
      padding: padding ?? this.padding,
      itemPadding: itemPadding ?? this.itemPadding,
    );
  }
}
