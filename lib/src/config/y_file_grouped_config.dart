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
/// 作为纯流式布局引擎，仅保留影响 Sliver 布局体系的基础属性。
/// 具体的 Header 高度与样式完全由外部 `headerBuilder` 的返回值决定。
class YFileGroupedConfig {
  /// 分组内容展示模式
  final YFileGroupedMode mode;

  /// 分组内宫格配置（当 [mode] 为 [YFileGroupedMode.grid] 时生效）
  final YFileGridConfig gridConfig;

  /// 分组内纵向列表配置（当 [mode] 为 [YFileGroupedMode.list] 时生效）
  final YFileListConfig listConfig;

  /// Header 是否粘性吸顶（在 CustomScrollView 中生效）
  final bool pinnedHeader;

  /// 列表整体内边距
  final EdgeInsets padding;

  /// 分组 header 的高度（dp），需与 [headerBuilder] 实际返回的 widget 高度一致。
  ///
  /// 仅在 [pinnedHeader] 为 true 时用于计算各分组的边界，从而确定吸顶显示哪个分组。
  /// 默认 44.0。
  final double groupHeaderHeight;

  const YFileGroupedConfig({
    this.mode = YFileGroupedMode.grid,
    this.gridConfig = const YFileGridConfig(),
    this.listConfig = const YFileListConfig(),
    this.pinnedHeader = true,
    this.padding = EdgeInsets.zero,
    this.groupHeaderHeight = 44.0,
  });

  YFileGroupedConfig copyWith({
    YFileGroupedMode? mode,
    YFileGridConfig? gridConfig,
    YFileListConfig? listConfig,
    bool? pinnedHeader,
    EdgeInsets? padding,
    double? groupHeaderHeight,
  }) {
    return YFileGroupedConfig(
      mode: mode ?? this.mode,
      gridConfig: gridConfig ?? this.gridConfig,
      listConfig: listConfig ?? this.listConfig,
      pinnedHeader: pinnedHeader ?? this.pinnedHeader,
      padding: padding ?? this.padding,
      groupHeaderHeight: groupHeaderHeight ?? this.groupHeaderHeight,
    );
  }
}
