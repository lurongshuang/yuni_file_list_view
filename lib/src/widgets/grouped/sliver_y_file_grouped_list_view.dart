import 'package:flutter/widgets.dart';
import '../../config/y_file_grouped_config.dart';
import '../../model/y_file_group.dart';
import '../../delegate/y_file_item_builder.dart';
import '../../utils/y_grid_column_calculator.dart';
import 'package:sliver_tools/sliver_tools.dart';

/// 构建分组宫格文件列表的 Sliver 组件
///
/// 返回一个包含多个 Sliver 的列表（基于每个分组单独包装的 [SliverMainAxisGroup] 实现）
///
///   Key? key,
///   required List<YFileGroup<T>> groups,
///   required YFileGroupHeaderBuilder<T> headerBuilder,
List<Widget> buildSliverYFileGroupedListView<T>({
  Key? key,
  required List<YFileGroup<T>> groups,
  required YFileGroupHeaderBuilder<T> headerBuilder,
  required YFileGroupItemBuilder<T> itemBuilder,
  YFileGroupedConfig config = const YFileGroupedConfig(),
  double? availableWidth,
}) {
  final gridConfig = config.gridConfig;
  final w = availableWidth ?? 0;
  final crossAxisCount = gridConfig.isAutoColumn
      ? YGridColumnCalculator.calculate(
          availableWidth: w,
          minItemWidth: gridConfig.minItemWidth,
          spacing: gridConfig.crossAxisSpacing,
          minColumns: gridConfig.minColumns,
          maxColumns: gridConfig.maxColumns,
        )
      : gridConfig.crossAxisCount;

  final List<Widget> groupSlivers = [];

  for (var gi = 0; gi < groups.length; gi++) {
    final group = groups[gi];

    // ── Header Sliver ──
    Widget headerSliver;

    if (config.pinnedHeader) {
      headerSliver = SliverPinnedHeader(
        child: Builder(builder: (context) => headerBuilder(context, group, gi)),
      );
    } else {
      headerSliver = SliverToBoxAdapter(
        child: Builder(builder: (context) => headerBuilder(context, group, gi)),
      );
    }

    // ── Content Sliver (Grid or List) ──
    final items = group.items;
    Widget contentSliver;

    if (config.mode == YFileGroupedMode.grid) {
      contentSliver = SliverPadding(
        padding: gridConfig.padding,
        sliver: SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: gridConfig.crossAxisSpacing,
            mainAxisSpacing: gridConfig.mainAxisSpacing,
            childAspectRatio: gridConfig.childAspectRatio,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final item = items[index];
              return itemBuilder(context, group, item, gi, index);
            },
            childCount: items.length,
          ),
        ),
      );
    } else {
      // 竖向分组列表
      final listConfig = config.listConfig;
      contentSliver = SliverPadding(
        padding: listConfig.padding,
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final item = items[index];
              return itemBuilder(context, group, item, gi, index);
            },
            childCount: items.length,
          ),
        ),
      );
    }

    // ── 每个分组使用 MultiSliver 包裹，支持 pushPinnedChildren ──
    groupSlivers.add(
      MultiSliver(
        pushPinnedChildren: true,
        children: [
          headerSliver,
          contentSliver,
        ],
      ),
    );
  }

  // 返回被顶层 MultiSliver 托管的所有分组，确保全局推挤效果正常
  return [
    MultiSliver(
      pushPinnedChildren: true,
      children: groupSlivers,
    ),
  ];
}
