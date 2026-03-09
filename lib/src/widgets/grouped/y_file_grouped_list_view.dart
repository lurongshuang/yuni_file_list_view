import 'package:flutter/widgets.dart';
import '../../config/y_file_grouped_config.dart';
import '../../model/y_file_group.dart';
import '../../delegate/y_file_item_builder.dart';
import 'sliver_y_file_grouped_list_view.dart';

/// 分组文件列表（可独立滚动，支持 header 吸顶）
///
/// 内部使用 [CustomScrollView] + [buildSliverYFileGroupedListView] 实现。
/// 吸顶效果通过内置 [SliverPersistentHeader] 实现，其内容会随滚动实时更新。
///
/// 需与其他 Sliver 组合时请直接使用 [buildSliverYFileGroupedListView]。
///
/// ```dart
/// YFileGroupedListView<MyFile>(
///   groups: myGroups,
///   config: YFileGroupedConfig(
///     pinnedHeader: true,
///     groupHeaderHeight: 46, // 与 headerBuilder 返回的高度一致
///   ),
///   headerBuilder: (ctx, group, i) => MyHeader(group),
///   itemBuilder: (ctx, group, item, gi, i) => MyItem(item),
/// )
/// ```
class YFileGroupedListView<T> extends StatelessWidget {
  final List<YFileGroup<T>> groups;
  final YFileGroupedConfig config;
  final YFileGroupHeaderBuilder<T> headerBuilder;
  final YFileGroupItemBuilder<T> itemBuilder;
  final ScrollController? controller;
  final bool reverse;
  final ScrollPhysics? physics;
  final bool shrinkWrap;

  const YFileGroupedListView({
    super.key,
    required this.groups,
    required this.headerBuilder,
    required this.itemBuilder,
    this.config = const YFileGroupedConfig(),
    this.controller,
    this.reverse = false,
    this.physics,
    this.shrinkWrap = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final gridConfig = config.gridConfig;
        final availableWidth = constraints.maxWidth -
            (config.mode == YFileGroupedMode.grid
                ? gridConfig.padding.horizontal
                : config.listConfig.padding.horizontal);

        return CustomScrollView(
          controller: controller,
          reverse: reverse,
          physics: physics,
          shrinkWrap: shrinkWrap,
          slivers: [
            ...buildSliverYFileGroupedListView<T>(
              groups: groups,
              headerBuilder: headerBuilder,
              itemBuilder: itemBuilder,
              config: config,
              availableWidth: availableWidth,
            ),
          ],
        );
      },
    );
  }
}
