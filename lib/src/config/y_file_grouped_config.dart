import 'package:flutter/widgets.dart';
import 'y_file_grid_config.dart';
import 'y_file_list_config.dart';

/// 分组列表内容展示模式
enum YFileGroupedMode {
  /// 宫格模式（默认）
  grid,
  /// 纵向普通列表模式
  list,
}

/// 分组列表配置
///
/// 分组列表由「分组标题 Header」+ 「分组内宫格内容区」组成。
/// 内容区默认使用 [gridConfig] 配置宫格，也可通过 Builder 回调完全自定义。
class YFileGroupedConfig {
  /// 分组内容展示模式
  final YFileGroupedMode mode;

  /// 分组内宫格配置（当 [mode] 为 [YFileGroupedMode.grid] 时生效）
  final YFileGridConfig gridConfig;

  /// 分组内纵向列表配置（当 [mode] 为 [YFileGroupedMode.list] 时生效）
  final YFileListConfig listConfig;

  /// 分组 Header 高度
  final double headerHeight;

  /// Header 是否粘性吸顶（在 CustomScrollView 中生效）
  ///
  /// `true` 时会使用 [SliverPersistentHeader] 实现吸顶效果。
  final bool pinnedHeader;

  /// Header 背景色；为 null 时透明
  final Color? headerBackgroundColor;

  /// Header 内边距
  final EdgeInsets headerPadding;

  /// 列表整体内边距
  final EdgeInsets padding;

  const YFileGroupedConfig({
    this.mode = YFileGroupedMode.grid,
    this.gridConfig = const YFileGridConfig(),
    this.listConfig = const YFileListConfig(showDivider: false),
    this.headerHeight = 40.0,
    this.pinnedHeader = true,
    this.headerBackgroundColor,
    this.headerPadding = const EdgeInsets.symmetric(horizontal: 16.0),
    this.padding = EdgeInsets.zero,
  });

  YFileGroupedConfig copyWith({
    YFileGroupedMode? mode,
    YFileGridConfig? gridConfig,
    YFileListConfig? listConfig,
    double? headerHeight,
    bool? pinnedHeader,
    Color? headerBackgroundColor,
    EdgeInsets? headerPadding,
    EdgeInsets? padding,
  }) {
    return YFileGroupedConfig(
      mode: mode ?? this.mode,
      gridConfig: gridConfig ?? this.gridConfig,
      listConfig: listConfig ?? this.listConfig,
      headerHeight: headerHeight ?? this.headerHeight,
      pinnedHeader: pinnedHeader ?? this.pinnedHeader,
      headerBackgroundColor: headerBackgroundColor ?? this.headerBackgroundColor,
      headerPadding: headerPadding ?? this.headerPadding,
      padding: padding ?? this.padding,
    );
  }
}
